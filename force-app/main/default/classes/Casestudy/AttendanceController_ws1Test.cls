@IsTest
public class AttendanceController_ws1_Test {

    // -----------------------------
    // Utility: create test user
    // -----------------------------
    private static User createTestUser() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE UserType = 'Standard'
            LIMIT 1
        ];

        String suffix = String.valueOf(Math.abs(Crypto.getRandomInteger()));

        User u = new User(
            Username          = 'att_user_' + suffix + '@example.com',
            Email             = 'att_user_' + suffix + '@example.com',
            FirstName         = 'Att',
            LastName          = 'User',
            Alias             = ('a' + suffix).substring(0, 4),
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = p.Id
        );
        insert u;
        return u;
    }

    // -----------------------------
    // Utility: safe picklist
    // -----------------------------
    private static String getAnyPicklistValue(Schema.SObjectField field) {
        for (Schema.PicklistEntry pe : field.getDescribe().getPicklistValues()) {
            if (pe.isActive()) {
                return pe.getValue();
            }
        }
        return null;
    }

    private static Employee__c createEmployee(User u) {
        Employee__c emp = new Employee__c(
            User__c        = u.Id,
            Work_status__c = getAnyPicklistValue(Employee__c.Work_status__c)
        );
        insert emp;
        return emp;
    }

    private static Attendance__c createAttendance(Id empId) {
        Attendance__c att = new Attendance__c(
            Employee__c = empId,
            Date__c     = Date.today()
        );
        insert att;
        return att;
    }

    // -----------------------------
    // 1) getEmployeeStatus + cache
    // -----------------------------
    @IsTest
    static void testGetEmployeeStatusAndCache() {
        User u = createTestUser();
        System.runAs(u) {

            // cleanup to avoid org data interference
            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Employee__c emp = createEmployee(u);

            Test.startTest();
            Employee__c first = AttendanceController_ws1.getEmployeeStatus();
            Employee__c second = AttendanceController_ws1.getEmployeeStatus();
            Test.stopTest();

            System.assertNotEquals(null, first);
            System.assertEquals(first.Id, second.Id, 'Should come from cache on 2nd call');
        }
    }

    // -----------------------------
    // 2) getTodayAttendance / Fresh
    // -----------------------------
    @IsTest
    static void testGetTodayAttendanceVariants() {
        User u = createTestUser();
        System.runAs(u) {

            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Employee__c emp = createEmployee(u);
            Attendance__c att = createAttendance(emp.Id);

            Test.startTest();
            Attendance__c cached = AttendanceController_ws1.getTodayAttendance();
            Attendance__c fresh  = AttendanceController_ws1.getTodayAttendanceFresh();
            Test.stopTest();

            System.assertNotEquals(null, cached);
            System.assertEquals(att.Id, cached.Id);
            System.assertNotEquals(null, fresh);
            System.assertEquals(att.Id, fresh.Id);
        }
    }

    // -----------------------------
    // 3) clockIn happy path
    // -----------------------------
    @IsTest
    static void testClockIn_HappyPath() {
        User u = createTestUser();
        System.runAs(u) {

            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Employee__c emp = createEmployee(u);
            Attendance__c att = createAttendance(emp.Id);

            Test.startTest();
            Attendance__c updatedAtt = AttendanceController_ws1.clockIn();
            Test.stopTest();

            updatedAtt = [
                SELECT Id, First_Clock_In__c, Late_By_Minutes__c, Employee__c
                FROM Attendance__c
                WHERE Id = :updatedAtt.Id
            ];

            emp = [
                SELECT Clockin_Clockout__c, Work_status__c
                FROM Employee__c
                WHERE Id = :emp.Id
            ];

            System.assertNotEquals(null, updatedAtt.First_Clock_In__c);
            System.assertNotEquals(null, updatedAtt.Late_By_Minutes__c);
            System.assertEquals('Clocked In', emp.Clockin_Clockout__c);
            System.assertEquals('Working', emp.Work_status__c);
        }
    }

    // -----------------------------
    // 4) clockOut happy path (after clockIn)
    // -----------------------------
    @IsTest
    static void testClockOut_HappyPath() {
        User u = createTestUser();
        System.runAs(u) {

            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Employee__c emp = createEmployee(u);
            Attendance__c att = createAttendance(emp.Id);

            // First clock in to set First_Clock_In__c
            AttendanceController_ws1.clockIn();

            Test.startTest();
            Attendance__c outAtt = AttendanceController_ws1.clockOut();
            Test.stopTest();

            outAtt = [
                SELECT First_Clock_In__c, Last_clock_out__c,
                       Total_Hours__c, Status__c
                FROM Attendance__c
                WHERE Id = :outAtt.Id
            ];

            emp = [
                SELECT Clockin_Clockout__c
                FROM Employee__c
                WHERE Id = :emp.Id
            ];

            System.assertNotEquals(null, outAtt.Last_clock_out__c);
            System.assertNotEquals(null, outAtt.Total_Hours__c);
            System.assertNotEquals(null, outAtt.Status__c);
            System.assertEquals('Clocked Out', emp.Clockin_Clockout__c);
        }
    }

    // -----------------------------
    // 5) clockIn: no employee
    // -----------------------------
    @IsTest
    static void testClockIn_NoEmployee_Throws() {
        User u = createTestUser();
        System.runAs(u) {
            // No Employee__c for this user
            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Test.startTest();
            try {
                AttendanceController_ws1.clockIn();
                System.assert(false, 'Expected AuraHandledException for missing employee');
            } catch (AuraHandledException e) {
                System.assertNotEquals('', e.getMessage(), 'Message should not be empty: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    // -----------------------------
    // 6) clockIn: no attendance
    // -----------------------------
    @IsTest
    static void testClockIn_NoAttendance_Throws() {
        User u = createTestUser();
        System.runAs(u) {

            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Employee__c emp = createEmployee(u);

            Test.startTest();
            try {
                AttendanceController_ws1.clockIn();
                System.assert(false, 'Expected AuraHandledException for missing attendance');
            } catch (AuraHandledException e) {
                System.assertNotEquals('', e.getMessage(), 'Message should not be empty: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    // -----------------------------
    // 7) clockOut: no employee
    // -----------------------------
    @IsTest
    static void testClockOut_NoEmployee_Throws() {
        User u = createTestUser();
        System.runAs(u) {

            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Test.startTest();
            try {
                AttendanceController_ws1.clockOut();
                System.assert(false, 'Expected AuraHandledException for missing employee');
            } catch (AuraHandledException e) {
                System.assertNotEquals('', e.getMessage(), 'Message should not be empty: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    // -----------------------------
    // 8) clockOut: no attendance
    // -----------------------------
    @IsTest
    static void testClockOut_NoAttendance_Throws() {
        User u = createTestUser();
        System.runAs(u) {

            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Employee__c emp = createEmployee(u);
            // No Attendance__c

            Test.startTest();
            try {
                AttendanceController_ws1.clockOut();
                System.assert(false, 'Expected AuraHandledException for missing attendance');
            } catch (AuraHandledException e) {
                System.assertNotEquals('', e.getMessage(), 'Message should not be empty: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    // -----------------------------
    // 9) clockOut: missing First_Clock_In__c
    // -----------------------------
    @IsTest
    static void testClockOut_MissingClockIn_Throws() {
        User u = createTestUser();
        System.runAs(u) {

            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Employee__c emp = createEmployee(u);
            Attendance__c att = createAttendance(emp.Id);
            // First_Clock_In__c left null intentionally

            Test.startTest();
            try {
                AttendanceController_ws1.clockOut();
                System.assert(false, 'Expected AuraHandledException for missing clock-in time');
            } catch (AuraHandledException e) {
                System.assertNotEquals('', e.getMessage(), 'Message should not be empty: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    // -----------------------------
    // 10) getTodayAttendance* when no Employee
    // -----------------------------
    @IsTest
    static void testGetTodayAttendance_NoEmployee() {
        User u = createTestUser();
        System.runAs(u) {

            delete [SELECT Id FROM Attendance__c WHERE Employee__r.User__c = :u.Id];
            delete [SELECT Id FROM Employee__c WHERE User__c = :u.Id];

            Test.startTest();
            Attendance__c att1 = AttendanceController_ws1.getTodayAttendance();
            Attendance__c att2 = AttendanceController_ws1.getTodayAttendanceFresh();
            Test.stopTest();

            System.assertEquals(null, att1);
            System.assertEquals(null, att2);
        }
    }
}