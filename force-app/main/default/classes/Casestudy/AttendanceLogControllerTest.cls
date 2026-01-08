@IsTest
public class AttendanceLogControllerTest {

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
            Username          = 'testuser_' + suffix + '@example.com',
            Email             = 'testuser_' + suffix + '@example.com',
            FirstName         = 'Test',
            LastName          = 'User',
            Alias             = ('t' + suffix).substring(0, 4),
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
    // Utility: safe picklist value
    // -----------------------------
    private static String getAnyPicklistValue(Schema.SObjectField field) {
        for (Schema.PicklistEntry pe :
             field.getDescribe().getPicklistValues()) {
            if (pe.isActive()) {
                return pe.getValue();
            }
        }
        return null;
    }

    private static Employee__c createEmployee(User u) {
        Employee__c emp = new Employee__c(
            User__c        = u.Id,
            Work_status__c =
                getAnyPicklistValue(Employee__c.Work_status__c)
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
    // 1) Happy path: JSON log creation
    // -----------------------------
    @IsTest
    static void testAddLogEntry_JSONPath() {
        User u = createTestUser();

        System.runAs(u) {
            Employee__c emp = createEmployee(u);
            Attendance__c att = createAttendance(emp.Id);

            String action =
                getAnyPicklistValue(
                    Attendance_Log__c.Clock_Action__c
                );

            Test.startTest();
            AttendanceLogController.addLogEntry(att.Id, action);
            AttendanceLogController.addLogEntry(att.Id, action);
            Test.stopTest();

            Id logId =
                AttendanceLogController.getAttendanceLogId(att.Id);

            List<Map<String, Object>> logs =
                AttendanceLogController.getLogEntries(logId);

            System.assertNotEquals(null, logId);
            System.assertEquals(2, logs.size());
        }
    }

    // -----------------------------
    // 2) Malformed JSON recovery
    // -----------------------------
    

    // -----------------------------
    // 3) Fallback rendering (no JSON)
    // -----------------------------
    @IsTest
    static void testFallbackLogEntries() {
        User u = createTestUser();

        System.runAs(u) {
            Employee__c emp = createEmployee(u);
            Attendance__c att = createAttendance(emp.Id);

            Attendance_Log__c log = new Attendance_Log__c(
                Employee__c     = emp.Id,
                Attendance__c   = att.Id,
                Clock_Action__c =
                    getAnyPicklistValue(
                        Attendance_Log__c.Clock_Action__c
                    ),
                Timestamp__c    = System.now()
            );
            insert log;

            List<Map<String, Object>> entries =
                AttendanceLogController.getLogEntries(log.Id);

            System.assertEquals(1, entries.size());
            System.assert(entries[0].containsKey('action'));
        }
    }

    // -----------------------------
    // 4) Early exit: null & blank inputs
    // -----------------------------
    @IsTest
    static void testAddLogEntryEarlyExit() {
        Test.startTest();
        System.assertEquals(
            null,
            AttendanceLogController.addLogEntry(null, 'Clock In')
        );
        System.assertEquals(
            null,
            AttendanceLogController.addLogEntry(
                Id.valueOf('001000000000001AAA'), null
            )
        );
        System.assertEquals(
            null,
            AttendanceLogController.addLogEntry(
                Id.valueOf('001000000000001AAA'), ''
            )
        );
        Test.stopTest();
    }

    // -----------------------------
    

    // -----------------------------
    // 6) Null & missing log paths
    // -----------------------------
    @IsTest
    static void testNullAndMissingLogPaths() {
        Test.startTest();
        System.assertEquals(
            0,
            AttendanceLogController.getLogEntries(null).size()
        );
        System.assertEquals(
            null,
            AttendanceLogController.getAttendanceLogId(null)
        );
        Test.stopTest();
    }
}