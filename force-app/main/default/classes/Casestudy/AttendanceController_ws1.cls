public class AttendanceController_ws1 {

    // ---------------------------------------------------
    // INTERNAL: GET CURRENT EMPLOYEE
    // ---------------------------------------------------
    private static Employee__c getCurrentEmployee() {
        List<Employee__c> empList = [
            SELECT Id, Name, User__c, Work_status__c, Clockin_Clockout__c
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        return empList.isEmpty() ? null : empList[0];
    }

    // ---------------------------------------------------
    // PUBLIC: RETURN EMPLOYEE (WIRE)
    // ---------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Employee__c getEmployeeStatus() {
        return getCurrentEmployee();
    }

    // ---------------------------------------------------
    // INTERNAL: GET TODAY'S ATTENDANCE
    // ---------------------------------------------------
    private static Attendance__c getTodayAttendanceForEmp(Id empId) {
        List<Attendance__c> attList = [
            SELECT Id, Date__c, First_Clock_In__c, Last_clock_out__c,
                   Total_Hours__c, Late_By_Minutes__c, Status__c
            FROM Attendance__c
            WHERE Employee__c = :empId
            AND Date__c = :Date.today()
            LIMIT 1
        ];
        return attList.isEmpty() ? null : attList[0];
    }

    // ---------------------------------------------------
    // PUBLIC: GET TODAY ATTENDANCE (WIRE)
    // ---------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Attendance__c getTodayAttendance() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;
        return getTodayAttendanceForEmp(emp.Id);
    }

    // ---------------------------------------------------
    // PUBLIC: FRESH (NO CACHE) — USED AFTER SAVE
    // ---------------------------------------------------
    @AuraEnabled
    public static Attendance__c getTodayAttendanceFresh() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;
        return getTodayAttendanceForEmp(emp.Id);
    }

    // ---------------------------------------------------
    // CLOCK IN
    // ---------------------------------------------------
    @AuraEnabled
    public static Attendance__c clockIn() {

        Employee__c emp = getCurrentEmployee();
        if (emp == null)
            throw new AuraHandledException('Employee record not found.');

        Date today = Date.today();
        Datetime nowTime = System.now();

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);

        // FIRST CLOCK IN
        if (att == null) {
            att = new Attendance__c(
                Employee__c = emp.Id,
                Date__c = today,
                First_Clock_In__c = nowTime
            );

            Datetime target = Datetime.newInstance(today.year(), today.month(), today.day(), 10, 0, 0);
            Long diff = nowTime.getTime() - target.getTime();
            att.Late_By_Minutes__c = diff > 0 ? diff / (1000 * 60) : 0;

            insert att;
        }
        else if (att.First_Clock_In__c == null) {
            att.First_Clock_In__c = nowTime;
            update att;     // ❗ FIX #1 — required
        }

        // Reload
        att = getTodayAttendanceForEmp(emp.Id);

        // Update employee status
        emp.Clockin_Clockout__c = 'Clocked In';
        emp.Work_status__c = 'Working';
        update emp;

        insert new Attendance_Log__c(
            Employee__c = emp.Id,
            Attendance__c = att.Id,
            Clock_Action__c = 'Clock In',
            Timestamp__c = nowTime
        );

        return att;
    }

    // ---------------------------------------------------
    // CLOCK OUT
    // ---------------------------------------------------
    @AuraEnabled
    public static Attendance__c clockOut() {

        Employee__c emp = getCurrentEmployee();
        if (emp == null)
            throw new AuraHandledException('Employee record not found.');

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);
        if (att == null)
            throw new AuraHandledException('Please Clock In first.');

        Datetime nowTime = System.now();

        att.Last_clock_out__c = nowTime;

        if (att.First_Clock_In__c == null)
            throw new AuraHandledException('Missing Clock In time.');

        Long diff = att.Last_clock_out__c.getTime() - att.First_Clock_In__c.getTime();
        Decimal hours = diff / (1000 * 60 * 60);
        att.Total_Hours__c = hours;

        // STATUS RULES
        if (hours >= 8) {
            att.Status__c = 'Present';
        }
        else if (hours >= 4) {
            att.Status__c = 'Present';
        }
        else if (hours > 0) {
            att.Status__c = 'Half day';
        }
        else {
            att.Status__c = 'Absent';
        }

        update att;       // ❗ FIX #2 — THIS SAVES TOTAL HOURS + STATUS

        // Reload updated record
        att = getTodayAttendanceForEmp(emp.Id);

        // Update employee
        emp.Clockin_Clockout__c = 'Clocked Out';
        emp.Work_status__c = 'Working';
        update emp;

        insert new Attendance_Log__c(
            Employee__c = emp.Id,
            Attendance__c = att.Id,
            Clock_Action__c = 'Clock Out',
            Timestamp__c = nowTime
        );

        return att;
    }
}
