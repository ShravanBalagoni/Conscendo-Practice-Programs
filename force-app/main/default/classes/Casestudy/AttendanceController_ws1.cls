public  class AttendanceController_ws1 {

    public static Employee__c getCurrentEmployee() {
        List<Employee__c> empList = [
            SELECT Id, Name, User__c, Work_status__c, Clockin_Clockout__c
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        return empList.isEmpty() ? null : empList[0];
    }

    // Helper: fetch today's attendance for an employee (no create)
    public static Attendance__c getTodayAttendanceForEmp(Id empId) {
        List<Attendance__c> attList = [
            SELECT Id, Date__c, First_Clock_In__c, Last_clock_out__c, Total_Hours__c, Status__c, Employee__c
            FROM Attendance__c
            WHERE Employee__c = :empId
              AND Date__c = :Date.today()
            LIMIT 1
        ];
        return attList.isEmpty() ? null : attList[0];
    }

    // Public: cached Employee info (used for button state)
    @AuraEnabled(cacheable=true)
    public static Employee__c getEmployeeStatus() {
        return getCurrentEmployee();
    }

    // Public: cached version of today's attendance
    @AuraEnabled(cacheable=true)
    public static Attendance__c getTodayAttendance() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;
        return getTodayAttendanceForEmp(emp.Id);
    }

    // Public: fresh (imperative) attendance loader
    @AuraEnabled
    public static Attendance__c getTodayAttendanceFresh() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;
        return getTodayAttendanceForEmp(emp.Id);
    }

    // ------------------------
    // CLOCK IN: create attendance on first punch if missing
    // ------------------------
    @AuraEnabled
    public static Attendance__c clockIn() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) throw new AuraHandledException('Employee record not found.');

        Date today = Date.today();
        Datetime nowTime = System.now();

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);

        if (att == null) {
    throw new AuraHandledException(
        'Attendance is not initialized for today. Please contact HR.'
    );
}

         if (att.First_Clock_In__c == null) {
            att.First_Clock_In__c = nowTime;
            Datetime officeStart = Datetime.newInstanceGMT(today.year(), today.month(), today.day(), 9, 0, 0);
            Long diff = nowTime.getTime() - officeStart.getTime();
            att.Late_By_Minutes__c = diff > 0 ? diff / (1000 * 60) : 0;
            update att;
        }

        // reload to ensure values are fresh
        att = getTodayAttendanceForEmp(emp.Id);

        // update employee status (source of truth for UI)
        emp.Clockin_Clockout__c = 'Clocked In';
        emp.Work_status__c = 'Working';
        update emp;

        // log the punch
        AttendanceLogController.addLogEntry(att.Id, 'Clock In');

        return att;
    }

    // ------------------------
    // CLOCK OUT
    // ------------------------
    @AuraEnabled
    public static Attendance__c clockOut() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) throw new AuraHandledException('Employee record not found.');

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);
        if (att == null) throw new AuraHandledException('Please Clock In first.');

        Datetime nowTime = System.now();

        att.Last_clock_out__c = nowTime;

        if (att.First_Clock_In__c == null) {
            throw new AuraHandledException('Missing Clock-In time.');
        }

        Long diffMs = att.Last_clock_out__c.getTime() - att.First_Clock_In__c.getTime();
        Decimal hours = (Decimal) diffMs / (1000 * 60 * 60);
        att.Total_Hours__c = hours.setScale(2);

        if (hours >= 8) att.Status__c = 'Present';
        else if (hours >= 4) att.Status__c = 'Present';
        else if (hours > 0) att.Status__c = 'Half day';
        else att.Status__c = 'Absent';

        update att;

        // reload
        att = getTodayAttendanceForEmp(emp.Id);

        // update employee clock status
        emp.Clockin_Clockout__c = 'Clocked Out';
        // keep Work_status as is or update if you have other logic
        update emp;

        // log the punch
        AttendanceLogController.addLogEntry(att.Id, 'Clock Out');

        return att;
    }
}
