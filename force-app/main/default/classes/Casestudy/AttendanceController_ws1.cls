/**
 * @description Controller class to manage Employee attendance — fetch current user employee,
 *              get today's attendance, and support clock-in / clock-out actions.
 * @author  Shravan
 * @version 1.0
 * @date 2025-12-10
 */
public class AttendanceController_ws1 {
    /**
    * @description Internal method to fetch the Employee__c record corresponding to the current user.
    * @return Employee__c — employee record for logged-in user, or null if none.
    */
    private static Employee__c getCurrentEmployee() {
        List<Employee__c> empList = [
            SELECT Id, Name, User__c, Work_status__c, Clockin_Clockout__c
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1];
        return empList.isEmpty() ? null : empList[0];
    }
    /**
     * @description Retrieves the Employee__c record for the currently logged-in user.
     * @return Employee__c — the employee record, or null if none exists.
     */
    @AuraEnabled(cacheable=true)
    public static Employee__c getEmployeeStatus() {
        return getCurrentEmployee();
    }
    /**
     * @description Internal helper to fetch today's Attendance__c record for a given employee.
     * @param empId Id — the Salesforce Id of the Employee__c record.
     * @return Attendance__c — attendance record for today for given employee, or null if none exists.
     */
    private static Attendance__c getTodayAttendanceForEmp(Id empId) {
        List<Attendance__c> attList = [
            SELECT Id, Date__c, First_Clock_In__c, Last_clock_out__c,
            Total_Hours__c, Late_By_Minutes__c, Status__c, Employee__c
            FROM Attendance__c
            WHERE Employee__c = :empId
            AND Date__c = :Date.today()
            LIMIT 1];
        return attList.isEmpty() ? null : attList[0];
    }
    /**
     * @description Fetches the attendance summary (Attendance__c) for today for the current user.
     *              Useful to determine if user has already clocked in/out today.
     * @return Attendance__c — today's attendance record for current user, or null if none exists.
     */
    @AuraEnabled(cacheable=true)
    public static Attendance__c getTodayAttendance() {
    Employee__c emp = getCurrentEmployee();
    if (emp == null) return null;
    return getTodayAttendanceForEmp(emp.Id);
    }
    /**
     * @description Similar to getTodayAttendance but ensures fresh data (no client cache).
     *              Use when you want latest attendance data after a DML operation.
     * @return Attendance__c — today's attendance record for current user, or null if none exists.
     */
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
            update att;
        }

        // RELOAD AFTER UPDATE
        att = getTodayAttendanceForEmp(emp.Id);

        // Employee Status
        emp.Clockin_Clockout__c = 'Clocked In';
        emp.Work_status__c = 'Working';
        update emp;

        // Add JSON Log
        AttendanceLogController.addLogEntry(att.Id, 'Clock In');

        return att;
    }

    // ---------------------------------------------------
    // CLOCK OUT
    // ---------------------------------------------------
    /**
     * @description  Handles “Clock Out” action for the currently logged-in user:
     *               - Finds the Employee__c record for the user.  
     *               - Fetches today’s Attendance__c for that employee; if none found → error.  
     *               - Sets the last clock-out timestamp to current time.  
     *               - Calculates total working hours (difference between first-clock-in and now).  
     *               - Sets attendance Status__c based on hours worked (Present / Half day / Absent).  
     *               - Updates the Attendance__c record in database.  
     *               - Updates Employee__c status (Clockin_Clockout__c = “Clocked Out”, Work_status__c = “Working”).  
     *               - Logs the “Clock Out” action via AttendanceLogController.  
     * @return  Attendance__c — the updated attendance record for today.  
     * @throws  AuraHandledException — if no Employee__c mapping found for user, or if there is no valid clock-in record for today (i.e. cannot clock out).  
     */
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
            throw new AuraHandledException('Missing Clock-In time.');

        Long diff = att.Last_clock_out__c.getTime() - att.First_Clock_In__c.getTime();
        Decimal hours = ((Decimal) diff) / (1000 * 60 * 60);
        att.Total_Hours__c = hours.setScale(2);

        if (hours >= 8) att.Status__c = 'Present';
        else if (hours >= 4) att.Status__c = 'Present';
        else if (hours > 0) att.Status__c = 'Half day';
        else att.Status__c = 'Absent';

        update att;

        // Reload
        att = getTodayAttendanceForEmp(emp.Id);

        emp.Clockin_Clockout__c = 'Clocked Out';
        emp.Work_status__c = 'Working';
        update emp;

        // Add log
        AttendanceLogController.addLogEntry(att.Id, 'Clock Out');

        return att;
    }
}
