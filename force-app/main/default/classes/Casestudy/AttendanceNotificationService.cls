public with sharing class AttendanceNotificationService {

    // Result DTO
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

    // MAIN CHECK
    public static List<CheckResult> checkEmployeesForDate(List<Employee__c> employees, Date checkDate) {

        if (employees == null || employees.isEmpty()) return new List<CheckResult>();

        Set<Id> empIds = new Set<Id>();
        for (Employee__c e : employees) empIds.add(e.Id);

        // Fetch attendance for the target day
        Map<Id, Attendance__c> attByEmp = new Map<Id, Attendance__c>();
        for (Attendance__c a : [
            SELECT Id, Employee__c, First_Clock_In__c, Last_Clock_Out__c
            FROM Attendance__c
            WHERE Employee__c IN :empIds
            AND Date__c = :checkDate
        ]) {
            attByEmp.put(a.Employee__c, a);
        }

        List<CheckResult> results = new List<CheckResult>();

        for (Employee__c e : employees) {

            CheckResult r = new CheckResult(e.Id, e.User__c, checkDate);

            // No user → skip
            if (e.User__c == null) {
                results.add(r);
                continue;
            }

            // LEAVE OR OOO?
            r.onLeaveOrOOO = isEmployeeOnLeave(e.Id, checkDate) ||
                             (e.Work_status__c != null && e.Work_status__c.containsIgnoreCase('OOO'));

            if (r.onLeaveOrOOO) {
                results.add(r);
                continue;
            }

            // MISSING CLOCK-IN
            if (!attByEmp.containsKey(e.Id)) {
                r.missingClockIn = true;
                results.add(r);
                continue;
            }

            Attendance__c att = attByEmp.get(e.Id);
            r.attendanceId = att.Id;

            // Missing punches
            if (att.First_Clock_In__c == null) {
                r.missingClockIn = true;
            }
            else if (att.Last_Clock_Out__c == null) {
                r.missingClockOut = true;
            }

            results.add(r);
        }

        return results;
    }

    // SEND NOTIFICATIONS
    public static void sendNotifications(List<CheckResult> checks) {

        Map<Id, List<String>> userMsgs = new Map<Id, List<String>>();

        for (CheckResult cr : checks) {

            if (cr.onLeaveOrOOO) continue;
            if (cr.userId == null) continue;

            String body;

            if (cr.missingClockIn && !cr.missingClockOut)
                body = 'You missed Clock-In on ' + cr.dateChecked.format() + '.';

            else if (!cr.missingClockIn && cr.missingClockOut)
                body = 'You missed Clock-Out on ' + cr.dateChecked.format() + '.';

            else if (cr.missingClockIn && cr.missingClockOut)
                body = 'You missed both Clock-In and Clock-Out on ' + cr.dateChecked.format() + '.';

            else continue;

            if (!userMsgs.containsKey(cr.userId))
                userMsgs.put(cr.userId, new List<String>());

            userMsgs.get(cr.userId).add(body);
        }

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (Id uId : userMsgs.keySet()) {

            User u = [SELECT Id, Email, Name FROM User WHERE Id = :uId];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{u.Email});
            mail.setSubject('Attendance Alert for ' + Date.today().addDays(-1).format());
            mail.setPlainTextBody(
                'Hello ' + u.Name + ',\n\n' +
                String.join(userMsgs.get(uId), '\n\n') +
                '\n\nRegards,\nAttendance System'
            );

            mails.add(mail);
        }

        if (!mails.isEmpty())
            Messaging.sendEmail(mails);
    }


    // ✔ Leave detection using CASE (LEAVE REQUEST)
    private static Boolean isEmployeeOnLeave(Id empId, Date day) {

        List<Case> c = [
            SELECT Id
            FROM Case
            WHERE Employeem__c = :empId
              AND Leave_Status__c = 'Approved'
              AND Start_Date__c <= :day
              AND End_Date__c >= :day
            LIMIT 1
        ];

        return !c.isEmpty();
    }
}
