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

    Employee__c emp = getCurrentEmployee();
    if (emp == null) return null;

    Boolean onLeaveToday = ![
        SELECT Id FROM Case
        WHERE Employeem__c = :emp.Id
          AND Leave_Status__c = 'Approved'
          AND Start_Date__c <= :Date.today()
          AND End_Date__c >= :Date.today()
        LIMIT 1
    ].isEmpty();

    if (onLeaveToday)
        emp.Work_status__c = 'Holiday';

    return emp;
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
    Datetime now = Datetime.now();

    Attendance__c att = getTodayAttendanceForEmp(emp.Id);

    if (att == null) {
        // FIRST clock-in of the day → create new
        att = new Attendance__c(
            Employee__c = emp.Id,
            Date__c = today,
            First_Clock_In__c = now
        );
        insert att;
    } else if (att.First_Clock_In__c == null) {
        // Attendance exists but missing first punch → set only once
        att.First_Clock_In__c = now;
        update att;
    }
    // If First_Clock_In__c is already present, DO NOT update it.

    // Update employee status
    emp.Clockin_Clockout__c = 'Clocked In';
    emp.Work_status__c = 'Working';
    update emp;

    // Always create a new log entry
    AttendanceLogController.addLogEntry(att.Id, 'Clock In');


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

    Datetime now = Datetime.now();

    // Always update last clock-out only
    att.Last_Clock_Out__c = now;

    // Compute hours
    if (att.First_Clock_In__c != null) {
        Long diffMs = now.getTime() - att.First_Clock_In__c.getTime();
        Decimal hours = diffMs / (1000 * 60 * 60);
        att.Total_Hours__c = hours.setScale(2);

        if (hours >= 8) att.Status__c = 'Present';
        else if (hours >= 4) att.Status__c = 'Present';
        else if (hours > 0) att.Status__c = 'Half Day';
        else att.Status__c = 'Absent';
    }

    update att;

    emp.Clockin_Clockout__c = 'Clocked Out';
    emp.Work_status__c = 'Working';
    update emp;

   AttendanceLogController.addLogEntry(att.Id, 'Clock Out');

    return att;
}


}
