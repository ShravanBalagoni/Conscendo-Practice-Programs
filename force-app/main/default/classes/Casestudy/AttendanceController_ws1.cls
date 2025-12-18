public  class AttendanceController_ws1 {

    private static Employee__c cachedEmployee;

    // --------------------------------------------------
    // Get current employee (cached per transaction)
    // --------------------------------------------------
    public static Employee__c getCurrentEmployee() {
        if (cachedEmployee != null) {
            return cachedEmployee;
        }

        List<Employee__c> empList = [
            SELECT Id, Name, User__c, Work_status__c, Clockin_Clockout__c
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];

        cachedEmployee = empList.isEmpty() ? null : empList[0];
        return cachedEmployee;
    }

    // --------------------------------------------------
    // Helper: fetch today's attendance
    // --------------------------------------------------
    public static Attendance__c getTodayAttendanceForEmp(Id empId) {
        List<Attendance__c> attList = [
            SELECT Id, Date__c, First_Clock_In__c, Last_clock_out__c,
                   Total_Hours__c, Status__c, Employee__c
            FROM Attendance__c
            WHERE Employee__c = :empId
              AND Date__c = :Date.today()
            LIMIT 1
        ];
        return attList.isEmpty() ? null : attList[0];
    }

    // --------------------------------------------------
    // Public: cached Employee info
    // --------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Employee__c getEmployeeStatus() {
        return getCurrentEmployee();
    }

    // --------------------------------------------------
    // Public: cached attendance
    // --------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Attendance__c getTodayAttendance() {
        Employee__c emp = getCurrentEmployee();
        return emp == null ? null : getTodayAttendanceForEmp(emp.Id);
    }

    // --------------------------------------------------
    // Public: fresh attendance
    // --------------------------------------------------
    @AuraEnabled
    public static Attendance__c getTodayAttendanceFresh() {
        Employee__c emp = getCurrentEmployee();
        return emp == null ? null : getTodayAttendanceForEmp(emp.Id);
    }

    // --------------------------------------------------
    // Clock In
    // --------------------------------------------------
    @AuraEnabled
    public static Attendance__c clockIn() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) {
            throw new AuraHandledException('Employee record not found.');
        }

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);
        if (att == null) {
            throw new AuraHandledException(
                'Attendance is not initialized for today. Please contact HR.'
            );
        }

        if (att.First_Clock_In__c == null) {
            Datetime nowTime = System.now();
            att.First_Clock_In__c = nowTime;

            Datetime officeStart =
                Datetime.newInstance(
                    Date.today().year(),
                    Date.today().month(),
                    Date.today().day(),
                    10, 0, 0
                );

            Long diff = nowTime.getTime() - officeStart.getTime();
            att.Late_By_Minutes__c = diff > 0 ? diff / (1000 * 60) : 0;

            update att;
        }

        emp.Clockin_Clockout__c = 'Clocked In';
        emp.Work_status__c = 'Working';
        update emp;

        AttendanceLogController.addLogEntry(att.Id, 'Clock In');

        return att;
    }

    // --------------------------------------------------
    // Clock Out
    // --------------------------------------------------
    @AuraEnabled
    public static Attendance__c clockOut() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) {
            throw new AuraHandledException('Employee record not found.');
        }

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);
        if (att == null) {
            throw new AuraHandledException('Please Clock In first.');
        }

        if (att.First_Clock_In__c == null) {
            throw new AuraHandledException('Missing Clock-In time.');
        }

        Datetime nowTime = System.now();
        att.Last_clock_out__c = nowTime;

        Long diffMs = nowTime.getTime() - att.First_Clock_In__c.getTime();
        Decimal hours = ((Decimal) diffMs) / (1000 * 60 * 60);
        att.Total_Hours__c = hours.setScale(2);

        if (hours >= 4) {
            att.Status__c = 'Present';
        } else if (hours > 0) {
            att.Status__c = 'Half day';
        } else {
            att.Status__c = 'Absent';
        }

        update att;

        emp.Clockin_Clockout__c = 'Clocked Out';
        update emp;

        AttendanceLogController.addLogEntry(att.Id, 'Clock Out');

        return att;
    }
}
