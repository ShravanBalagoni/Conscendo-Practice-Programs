@IsTest
private class AttendanceController_ws1_Test {

    // Helper: Create User
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User u = new User(
            FirstName = 'Test',
            LastName  = 'User',
            Email     = 'testuser@test.com',
            Username  = 'testuser' + System.currentTimeMillis() + '@test.com',
            Alias     = 'tusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;
        return u;
    }

    // Helper: Create Employee
    private static Employee__c createEmployee(User u) {
        Employee__c emp = new Employee__c(
            Name = 'Test Employee',
            User__c = u.Id,
            Work_status__c = 'Working',
            Clockin_Clockout__c = 'None'
        );
        insert emp;
        return emp;
    }

    // Helper: Create Attendance
    private static Attendance__c createTodayAttendance(Id empId) {
        Attendance__c att = new Attendance__c(
            Employee__c = empId,
            Date__c = Date.today(),
            First_Clock_In__c = Datetime.now().addHours(-3)       // 3 hours earlier
        );
        insert att;
        return att;
    }

    @IsTest
    static void testAttendanceController() {

        User u = createTestUser();
        System.runAs(u) {

            Employee__c emp = createEmployee(u);

            Test.startTest();

            // ---------------------------
            // 1. Test getEmployeeStatus
            // ---------------------------
            Employee__c fetchedEmp = AttendanceController_ws1.getEmployeeStatus();
            System.assertNotEquals(null, fetchedEmp, 'Employee must be returned');

            // ---------------------------
            // 2. Test getTodayAttendance -> should be NULL now
            // ---------------------------
            Attendance__c attNull = AttendanceController_ws1.getTodayAttendance();
            System.assertEquals(null, attNull);

            // ---------------------------
            // 3. Test PunchStatus when no attendance (showClockIn = true)
            // ---------------------------
            AttendanceController_ws1.PunchStatus ps1 =
                AttendanceController_ws1.getPunchStatus();
            System.assertEquals(true, ps1.showClockIn);
            System.assertEquals(false, ps1.showClockOut);
            System.assertEquals(false, ps1.completed);

            // ---------------------------
            // 4. Test clockIn: should create attendance
            // ---------------------------
            Attendance__c attCreated = AttendanceController_ws1.clockIn();
            System.assertNotEquals(null, attCreated.Id);
            System.assertNotEquals(null, attCreated.First_Clock_In__c);

            // Re-fetch punch status → now clock-out should show
            AttendanceController_ws1.PunchStatus ps2 =
                AttendanceController_ws1.getPunchStatus();
            System.assertEquals(false, ps2.showClockIn);
            System.assertEquals(true, ps2.showClockOut);

            // ---------------------------
            // 5. Create attendance manually to test clockOut
            // ---------------------------
            Attendance__c attForClockOut = createTodayAttendance(emp.Id);

            // Overwrite created record so we test clock-out path
            AttendanceController_ws1.clockIn(); // ensures First Clock-In on created record

            // Now test clockOut
            Attendance__c finalAtt = AttendanceController_ws1.clockOut();
            System.assertNotEquals(null, finalAtt.Last_clock_out__c);

            // Status must be set (Present/Half day etc)
            System.assertNotEquals(null, finalAtt.Status__c);

            // ---------------------------
            // 6. Test PunchStatus when both clock-in/out exist
            // ---------------------------
            AttendanceController_ws1.PunchStatus ps3 =
                AttendanceController_ws1.getPunchStatus();
            System.assertEquals(true, ps3.completed);

            // ---------------------------
            // 7. Negative test: calling clockOut without attendance
            // ---------------------------
            Employee__c emp2 = createEmployee(createTestUser());

            try {
                Test.startTest();
                AttendanceController_ws1.clockOut();
                Test.stopTest();
                System.assert(false, 'Exception must be thrown');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Please Clock In first'));
            }

            Test.stopTest();
        }
    }
}
