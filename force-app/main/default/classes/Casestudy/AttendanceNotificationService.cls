public with sharing class AttendanceNotificationService {

    // Wrapper to store evaluation for each employee
    public class CheckResult {
        public Id employeeId;
        public Id userId;
        public Id attendanceId;
        public Boolean missingClockIn;
        public Boolean missingClockOut;
        public Boolean onLeaveOrOOO;
        public Date dateChecked;

        public CheckResult(Id empId, Id uId, Date d) {
            employeeId = empId;
            userId = uId;
            dateChecked = d;
            missingClockIn = false;
            missingClockOut = false;
            onLeaveOrOOO = false;
        }
    }

    // Main evaluator used by batch class
    public static List<CheckResult> checkEmployeesForDate(List<Employee__c> employees, Date checkDate) {
        if (employees == null || employees.isEmpty()) return new List<CheckResult>();

        Map<Id, Employee__c> empMap = new Map<Id, Employee__c>(employees);

        // Query attendance for that date
        List<Attendance__c> attendances = [
            SELECT Id, Employee__c, Date__c, First_Clock_In__c, Last_clock_out__c
            FROM Attendance__c
            WHERE Employee__c IN :empMap.keySet()
            AND Date__c = :checkDate
        ];

        Map<Id, Attendance__c> attByEmp = new Map<Id, Attendance__c>();
        for (Attendance__c a : attendances) {
            attByEmp.put(a.Employee__c, a);
        }

        List<CheckResult> results = new List<CheckResult>();

        for (Employee__c e : employees) {
            CheckResult r = new CheckResult(e.Id, e.User__c, checkDate);

            // Skip if user has no email/userID
            if (e.User__c == null) {
                results.add(r);
                continue;
            }

            // Check if employee is on leave or OOO
            Boolean leave = isEmployeeOnLeave(e.Id, checkDate);
            Boolean ooo = isEmployeeOOO(e);
            r.onLeaveOrOOO = leave || ooo;

            if (r.onLeaveOrOOO) {
                results.add(r);
                continue;
            }

            // If no attendance record → missing clock-in
            if (!attByEmp.containsKey(e.Id)) {
                r.missingClockIn = true;
                results.add(r);
                continue;
            }

            Attendance__c att = attByEmp.get(e.Id);
            r.attendanceId = att.Id;

            // Check missing states
            if (att.First_Clock_In__c == null) {
                r.missingClockIn = true;
            } else if (att.Last_clock_out__c == null) {
                r.missingClockOut = true;
            }

            results.add(r);
        }

        return results;
    }

    // Sends all emails (bulk safe)
    public static void sendNotifications(List<CheckResult> checks) {
        if (checks == null || checks.isEmpty()) return;

        Map<Id, List<String>> userMsgs = new Map<Id, List<String>>();

        for (CheckResult cr : checks) {
            if (cr.onLeaveOrOOO) continue;
            if (cr.userId == null) continue;

            String body;

            if (cr.missingClockIn && !cr.missingClockOut) {
                body = 'You missed Clock-In on ' + cr.dateChecked.format() + '. Please submit a regularization request if needed.';
            } 
            else if (!cr.missingClockIn && cr.missingClockOut) {
                body = 'You forgot to Clock-Out on ' + cr.dateChecked.format() + '. Please submit a regularization request if needed.';
            } 
            else if (cr.missingClockIn && cr.missingClockOut) {
                body = 'You missed Clock-In and Clock-Out on ' + cr.dateChecked.format() + '. Please submit a regularization request if needed.';
            } 
            else {
                continue;
            }

            if (!userMsgs.containsKey(cr.userId)) {
                userMsgs.put(cr.userId, new List<String>());
            }
            userMsgs.get(cr.userId).add(body);
        }

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (Id userId : userMsgs.keySet()) {
            User u = [SELECT Id, Email, Name FROM User WHERE Id = :userId LIMIT 1];
            if (u.Email == null) continue;

            String subject = 'Attendance Alert for ' + Date.today().addDays(-1).format();
            String body = 'Hello ' + u.Name + ',\n\n';
            body += String.join(userMsgs.get(userId), '\n\n');
            body += '\n\nRegards,\nAttendance System';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { u.Email });
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            mails.add(mail);
        }

        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
    }

    // NEW: Leave check using CASE object
    public static Boolean isEmployeeOnLeave(Id employeeId, Date day) {
        if (employeeId == null || day == null) return false;

        try {
            List<Case> leaveCases = [
                SELECT Id
                FROM Case
                WHERE Employee__c = :employeeId
                  AND Start_Date__c <= :day
                  AND End_Date__c >= :day
                  AND Leave_Status__c = 'Approved'
                LIMIT 1
            ];
            return !leaveCases.isEmpty();
        } catch (Exception ex) {
            System.debug('Leave Case query failed: ' + ex);
            return false;
        }
    }

    // NEW: OOO check
    public static Boolean isEmployeeOOO(Employee__c e) {
        return (e.Work_status__c != null && e.Work_status__c.toLowerCase().contains('ooo'));
    }
}
