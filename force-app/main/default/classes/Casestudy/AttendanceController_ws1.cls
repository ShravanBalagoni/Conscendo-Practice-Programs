/**
* @File Name : AttendanceController.cls
* @Description : Service class for Clock in/out actions
* @Author : Shravan B
* @Last Modified By :Shravan B
* @Last Modified On : December 24, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 18, 2025 | SHRAVAN | Initial Version
* 2.0 | December 24, 2025 | SHRAVAN | Reduced the no of queries
**/
public  with sharing class AttendanceController_ws1 {

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
        //Assigns the first record to the cachedEmployee.if not empty else null
        cachedEmployee = empList.isEmpty() ? null : empList[0];

        return cachedEmployee;
    }

    // --------------------------------------------------
    // Helper: fetch today's attendance
    // --------------------------------------------------
    //the parameter will be fetched from the public call
    public static Attendance__c getTodayAttendanceForEmp(Id empId) {
        //filters the attendance list based on employee if and date .
        List<Attendance__c> attList = [
            SELECT Id, Date__c, First_Clock_In__c, Last_clock_out__c,
                   Total_Hours__c, Status__c, Employee__c,Late_by_minutes__c
            FROM Attendance__c
            WHERE Employee__c = :empId
              AND Date__c = :Date.today()
            LIMIT 1
        ];
        //if the list is empty then return null else first record from the list
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
    //Bypasses cache post-DML for accurate UI refresh.

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
        //call made to get employee details
        Employee__c emp = getCurrentEmployee();
        if (emp == null) {
            throw new AuraHandledException('Employee record not found.');
        }
        // call made to get the Attendace details of the employee
        Attendance__c att = getTodayAttendanceForEmp(emp.Id);
        if (att == null) {
            throw new AuraHandledException(
                'Attendance is not initialized for today. Please contact HR.'
            );
        }
        // if no clock in yet, assign the current time to it based on click
        if (att.First_Clock_In__c == null) {
            Datetime nowTime = System.now();
            att.First_Clock_In__c = nowTime;
            //Builds 10 AM reference point to calculate Late_By_Minutes__c (clock-in time minus office start).
            Datetime officeStart =
                Datetime.newInstance(
                    Date.today().year(),
                    Date.today().month(),
                    Date.today().day(),
                    10, 0, 0
                );
            //Calculates late minutes: (clockInMs - 10AMms) / 60000 if late, else 0.
            Long diff = nowTime.getTime() - officeStart.getTime();
            att.Late_By_Minutes__c = diff > 0 ? diff / (1000 * 60) : 0;

            update att;
        }

        emp.Clockin_Clockout__c = 'Clocked In';
        emp.Work_status__c = 'Working';
        update emp;
        //Creates audit trail entry in separate AttendanceLog__c object for compliance/tracking.
        Id logId = AttendanceLogController.addLogEntry(att.Id, 'Clock In');
        return att;
    }

    // --------------------------------------------------
    // Clock Out
    // --------------------------------------------------
    @AuraEnabled
    public static Attendance__c clockOut() {
        //call made to get employee details
        Employee__c emp = getCurrentEmployee();
        if (emp == null) {
            throw new AuraHandledException('Employee record not found.');
        }
        //call made to get attendance details
        Attendance__c att = getTodayAttendanceForEmp(emp.Id);
        if (att == null) {
            throw new AuraHandledException('Please Clock In first.');
        }
        // if there is no clock in yet  throw error
        if (att.First_Clock_In__c == null) {
            throw new AuraHandledException('Missing Clock-In time.');
        }

        Datetime nowTime = System.now();
        att.Last_clock_out__c = nowTime;
        //Calculates total work hours: (clockOutMs - clockInMs) / 3600000 rounded to 2 decimals
        Long diffMs = nowTime.getTime() - att.First_Clock_In__c.getTime();
        Decimal hours = ((Decimal) diffMs) / (1000 * 60 * 60);
        att.Total_Hours__c = hours.setScale(2);
        // decides the status based on hours
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
        //Creates audit trail entry in separate AttendanceLog__c object for compliance/tracking.
       Id logId = AttendanceLogController.addLogEntry(att.Id, 'Clock Out');


        return att;
    }
}
