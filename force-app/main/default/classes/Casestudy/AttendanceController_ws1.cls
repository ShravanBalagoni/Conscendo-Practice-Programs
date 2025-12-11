/**
 * @description Controller class to manage Employee attendance — fetch current user employee,
 *              get today's attendance, and support clock-in / clock-out actions.
 */
public class AttendanceController_ws1 {
    // -------------------------
    // Helper: fetch current Employee__c
    // -------------------------
    private static Employee__c getCurrentEmployee() {
        List<Employee__c> empList = [
            SELECT Id, Name, User__c, Work_status__c, Clockin_Clockout__c
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        return empList.isEmpty() ? null : empList[0];
    }

    // -------------------------
    // Public: return employee record
    // -------------------------
    @AuraEnabled(cacheable=true)
    public static Employee__c getEmployeeStatus() {
        return getCurrentEmployee();
    }

    // -------------------------
    // Internal: fetch today's attendance for an employee
    // -------------------------
    private static Attendance__c getTodayAttendanceForEmp(Id empId) {
        List<Attendance__c> attList = [
            SELECT Id, Date__c, First_Clock_In__c, Last_clock_out__c,
                   Total_Hours__c, Late_By_Minutes__c, Status__c, Employee__c
            FROM Attendance__c
            WHERE Employee__c = :empId
              AND Date__c = :Date.today()
            LIMIT 1
        ];
        return attList.isEmpty() ? null : attList[0];
    }

    // -------------------------
    // Public: cached version of today's attendance
    // -------------------------
    @AuraEnabled(cacheable=true)
    public static Attendance__c getTodayAttendance() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;
        return getTodayAttendanceForEmp(emp.Id);
    }

    // -------------------------
    // Public: fresh version (not cacheable)
    // -------------------------
    @AuraEnabled
    public static Attendance__c getTodayAttendanceFresh() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;
        return getTodayAttendanceForEmp(emp.Id);
    }

    // -------------------------
    // NEW: Punch status DTO and method — UI should rely on this
    // -------------------------
    public class PunchStatus {
        @AuraEnabled public Boolean showClockIn;
        @AuraEnabled public Boolean showClockOut;
        @AuraEnabled public Boolean completed;
        public PunchStatus() {
            showClockIn = false;
            showClockOut = false;
            completed = false;
        }
    }

    /**
     * Determines whether UI should show Clock In or Clock Out (or none).
     * Decision is made strictly from Attendance__c fields (source of truth).
     */
    @AuraEnabled(cacheable=true)
    public static PunchStatus getPunchStatus() {
        PunchStatus ps = new PunchStatus();
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return ps;

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);

        // No attendance record or no first clock-in -> show Clock In
        if (att == null || att.First_Clock_In__c == null) {
            ps.showClockIn = true;
            return ps;
        }

        // If clocked in and not clocked out -> show Clock Out
        if (att.First_Clock_In__c != null && att.Last_clock_out__c == null) {
            ps.showClockOut = true;
            return ps;
        }

        // Both clock-in and clock-out exist -> nothing to do
        ps.completed = true;
        return ps;
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
    Datetime now = Datetime.now(); // Local timezone interpreted correctly

    // Normalize timestamp to today's date to avoid UTC mismatch
    Datetime normalizedNow = Datetime.newInstance(
        today.year(), today.month(), today.day(),
        now.hour(), now.minute(), now.second()
    );

    Attendance__c att = getTodayAttendanceForEmp(emp.Id);

    // If first punch of the day -> create new attendance
    if (att == null) {
        att = new Attendance__c(
            Employee__c = emp.Id,
            Date__c = today,
            First_Clock_In__c = normalizedNow
        );
        insert att;
    } 
    else {
        // If already clocked in before, do NOT block. Just log it.
        // First clock-in stays unchanged. Only log the new punch.
    }

    // Update employee status
    emp.Clockin_Clockout__c = 'Clocked In';
    emp.Work_status__c = 'Working';
    update emp;

    // Always log the punch
    AttendanceLogController.addLogEntry(att.Id, 'Clock In');

    return getTodayAttendanceForEmp(emp.Id);
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

    Datetime now = Datetime.now();
    Date today = Date.today();

    // Normalize timestamp
    Datetime normalizedNow = Datetime.newInstance(
        today.year(), today.month(), today.day(),
        now.hour(), now.minute(), now.second()
    );

    // Always update the LAST clock-out
    att.Last_Clock_Out__c = normalizedNow;

    // Compute working hours only on final clock-out
    if (att.First_Clock_In__c != null) {
        Long diffMs = normalizedNow.getTime() - att.First_Clock_In__c.getTime();
        Decimal hours = diffMs / (1000 * 60 * 60);
        att.Total_Hours__c = hours.setScale(2);

        if (hours >= 8) att.Status__c = 'Present';
        else if (hours >= 4) att.Status__c = 'Present';
        else if (hours > 0) att.Status__c = 'Half Day';
        else att.Status__c = 'Absent';
    }

    update att;

    // Update employee status
    emp.Clockin_Clockout__c = 'Clocked Out';
    emp.Work_status__c = 'Working';
    update emp;

    // Log punch
    AttendanceLogController.addLogEntry(att.Id, 'Clock Out');

    return getTodayAttendanceForEmp(emp.Id);
}

}
