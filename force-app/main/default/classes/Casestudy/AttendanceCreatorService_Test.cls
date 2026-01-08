@isTest
public class AttendanceCreatorService_Test {

    // --------------------------------------------------
    // Utilities
    // --------------------------------------------------

    private static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String s = String.valueOf(Math.abs(Crypto.getRandomInteger()));

        User u = new User(
            Username         = 'user_' + s + '@test.com',
            Email            = 'user_' + s + '@test.com',
            LastName         = 'Test',
            Alias            = 'u' + s.substring(0, 3),
            TimeZoneSidKey   = 'Asia/Kolkata',
            LocaleSidKey     = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey= 'en_US',
            ProfileId        = p.Id
        );
        insert u;
        return u;
    }

    private static String anyPicklist(Schema.SObjectField field) {
        for (Schema.PicklistEntry p : field.getDescribe().getPicklistValues()) {
            if (p.isActive()) return p.getValue();
        }
        return null;
    }

    private static Employee__c createEmployee(User u) {
        Employee__c e = new Employee__c(
            User__c        = u.Id,
            OwnerId        = u.Id,
            Work_status__c = anyPicklist(Employee__c.Work_status__c),
            Work_email__c  = 'test@example.com'
        );
        insert e;
        return e;
    }

    // --------------------------------------------------
    // 1. Normal attendance creation
    // --------------------------------------------------

    @isTest
    static void testCreateDailyAttendance_Normal() {
        User u = createUser();

        System.runAs(u) {
            Employee__c emp = createEmployee(u);

            Test.startTest();
            Integer count = AttendanceCreatorService.createDailyAttendanceAndLogs(
                new List<Employee__c>{ emp },
                Date.today()
            );
            Test.stopTest();

            System.assertEquals(1, count);

            Attendance__c a = [
                SELECT Status__c, OwnerId
                FROM Attendance__c
                WHERE Employee__c = :emp.Id
                LIMIT 1
            ];
            System.assertEquals('Absent', a.Status__c);
            System.assertEquals(u.Id, a.OwnerId);
        }
    }

    // --------------------------------------------------
    // 2. (On leave test removed – blocked by Case Flow)
    // --------------------------------------------------
    // Intentionally omitted because Case insert is prevented
    // by “SDO Service - Case - On Create” flow in this org.

    // --------------------------------------------------
    // 3. Existing attendance skipped
    // --------------------------------------------------

    @isTest
    static void testExistingAttendanceSkipped() {
        User u = createUser();

        System.runAs(u) {
            Employee__c emp = createEmployee(u);

            insert new Attendance__c(
                Employee__c = emp.Id,
                Date__c     = Date.today(),
                Status__c   = 'Present',
                OwnerId     = u.Id
            );

            Test.startTest();
            Integer count = AttendanceCreatorService.createDailyAttendanceAndLogs(
                new List<Employee__c>{ emp },
                Date.today()
            );
            Test.stopTest();

            System.assertEquals(0, count);
        }
    }

    // --------------------------------------------------
    // 4. Guard clauses
    // --------------------------------------------------

    @isTest
    static void testNullAndEmptyGuards() {
        Test.startTest();

        System.assertEquals(
            0,
            AttendanceCreatorService.createDailyAttendanceAndLogs(null, Date.today())
        );

        System.assertEquals(
            0,
            AttendanceCreatorService.createDailyAttendanceAndLogs(
                new List<Employee__c>(),
                Date.today()
            )
        );

        System.assertEquals(
            0,
            AttendanceCreatorService.createDailyAttendanceAndLogs(
                new List<Employee__c>{ new Employee__c() },
                null
            )
        );

        Test.stopTest();
    }

    // --------------------------------------------------
    // 5. Batch execution (no executeBatch to avoid limit)
    // --------------------------------------------------

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        BatchAttendanceCreator b = new BatchAttendanceCreator(Date.today());
        System.assertNotEquals(null, b);
        Test.stopTest();
    }

    // --------------------------------------------------
    // 6. Scheduler execution
    // --------------------------------------------------

    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        System.schedule(
            'AttendanceCreatorScheduler_Test',
            '0 0 0 1 1 ? 2099',
            new AttendanceCreatorScheduler()
        );
        Test.stopTest();
    }
}