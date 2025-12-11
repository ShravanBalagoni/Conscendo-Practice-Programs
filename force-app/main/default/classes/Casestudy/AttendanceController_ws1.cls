public with sharing class AttendanceController_ws1 {

    private static Employee__c getCurrentEmployee() {
        List<Employee__c> empList = [
            SELECT Id, Name, User__c, Work_status__c, Clockin_Clockout__c
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        return empList.isEmpty() ? null : empList[0];
    }

    @AuraEnabled(cacheable=true)
    public static Employee__c getEmployeeStatus() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;

        // Detect approved leave for today and mark Work_status__c as Holiday for UI only
        Boolean onLeaveToday = ![
            SELECT Id FROM Case
            WHERE Employeem__c = :emp.Id
              AND Leave_Status__c = 'Approved'
              AND Start_Date__c <= :Date.today()
              AND End_Date__c >= :Date.today()
            LIMIT 1
        ].isEmpty();

        if (onLeaveToday) emp.Work_status__c = 'Holiday';
        return emp;
    }

    private static Attendance__c getTodayAttendanceForEmp(Id empId) {
        List<Attendance__c> attList = [
            SELECT Id, Date__c, First_Clock_In__c, Last_clock_out__c,
                   Total_Hours__c, Late_by_minutes__c, Status__c, Employee__c
            FROM Attendance__c
            WHERE Employee__c = :empId
              AND Date__c = :Date.today()
            LIMIT 1
        ];
        return attList.isEmpty() ? null : attList[0];
    }

    @AuraEnabled(cacheable=true)
    public static Attendance__c getTodayAttendance() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;
        return getTodayAttendanceForEmp(emp.Id);
    }

    @AuraEnabled
    public static Attendance__c getTodayAttendanceFresh() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return null;
        return getTodayAttendanceForEmp(emp.Id);
    }

    // PunchStatus DTO
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

    // Decision of which button to show purely from Attendance__c state
    @AuraEnabled(cacheable=true)
    public static PunchStatus getPunchStatus() {
        PunchStatus ps = new PunchStatus();
        Employee__c emp = getCurrentEmployee();
        if (emp == null) return ps;

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);

        // No attendance yet OR first punch missing → allow Clock In
        if (att == null || att.First_Clock_In__c == null) {
            ps.showClockIn = true;
            return ps;
        }

        // If last clock-out is present → user has closed the pair; allow Clock In again
        if (att.Last_clock_out__c != null) {
            ps.showClockIn = true;
            return ps;
        }

        // Otherwise (clocked in but not out) → show Clock Out
        ps.showClockOut = true;
        return ps;
    }

    // CLOCK IN
    @AuraEnabled
    public static Attendance__c clockIn() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) throw new AuraHandledException('Employee record not found.');

        Date today = Date.today();
        Datetime now = Datetime.now();

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);

        if (att == null) {
            att = new Attendance__c(
                Employee__c = emp.Id,
                Date__c = today,
                First_Clock_In__c = now
            );
            insert att;
        } else if (att.First_Clock_In__c == null) {
            att.First_Clock_In__c = now;
            update att;
        } else if (att.Last_clock_out__c != null) {
            // If previously closed pair exists, keep First_Clock_In__c same (per AC: first is official)
            // but we still want to record new pair in logs. Do not modify First_Clock_In__c.
        } // else already clocked in and not clocked out => do nothing for First_Clock_In__c

        // Update employee status
        try {
            emp.Clockin_Clockout__c = 'Clocked In';
            emp.Work_status__c = 'Working';
            update emp;
        } catch (Exception ex) {
            System.debug('AttendanceController_ws1.clockIn: emp update failed: ' + ex);
        }

        // Log action
        try { AttendanceLogController.addLogEntry(att.Id, 'Clock In'); } catch (Exception e) {
            System.debug('AttendanceController_ws1.clockIn: log failed: ' + e);
        }

        return getTodayAttendanceForEmp(emp.Id);
    }

    // CLOCK OUT
    @AuraEnabled
    public static Attendance__c clockOut() {
        Employee__c emp = getCurrentEmployee();
        if (emp == null) throw new AuraHandledException('Employee record not found.');

        Attendance__c att = getTodayAttendanceForEmp(emp.Id);
        if (att == null) throw new AuraHandledException('Please Clock In first.');

        Datetime now = Datetime.now();

        att.Last_clock_out__c = now;

        // Compute total hours using first clock-in and this last clock-out
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

        try {
            emp.Clockin_Clockout__c = 'Clocked Out';
            emp.Work_status__c = 'Working';
            update emp;
        } catch (Exception ex) {
            System.debug('AttendanceController_ws1.clockOut: emp update failed: ' + ex);
        }

        try { AttendanceLogController.addLogEntry(att.Id, 'Clock Out'); } catch (Exception e) {
            System.debug('AttendanceController_ws1.clockOut: log failed: ' + e);
        }

        return getTodayAttendanceForEmp(emp.Id);
    }
}
