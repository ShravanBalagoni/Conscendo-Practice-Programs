public with sharing class AttendanceNotificationService {

    public class CheckResult {
        public Id employeeId;
        public Id userId;
        public Id attendanceId;
        public Boolean missingClockIn = false;
        public Boolean missingClockOut = false;
        public Boolean onLeaveOrOOO = false;
        public Date dateChecked;

        public CheckResult(Id empId, Id uId, Date d) {
            employeeId = empId;
            userId = uId;
            dateChecked = d;
        }
    }

    public static List<CheckResult> checkEmployeesForDate(List<Employee__c> employees, Date checkDate) {

        if (employees == null || employees.isEmpty()) return new List<CheckResult>();

        Set<Id> empIds = new Set<Id>();
        for (Employee__c e : employees) empIds.add(e.Id);

        // Attendance for employees
        Map<Id, Attendance__c> attByEmp = new Map<Id, Attendance__c>(
            [SELECT Id, Employee__c, First_Clock_In__c, Last_Clock_Out__c
             FROM Attendance__c
             WHERE Employee__c IN :empIds
               AND Date__c = :checkDate
            ]
        );

        // Logs for attendance
        Map<Id, Attendance_Log__c> logByAtt = new Map<Id, Attendance_Log__c>(
            [SELECT Id, Attendance__c, Log_Data__c
             FROM Attendance_Log__c
             WHERE Attendance__c IN :attByEmp.values()
            ]
        );

        List<CheckResult> results = new List<CheckResult>();

        for (Employee__c emp : employees) {

            CheckResult r = new CheckResult(emp.Id, emp.User__c, checkDate);

            // If user lookup missing, skip
            if (emp.User__c == null) {
                results.add(r);
                continue;
            }

            // Check leave or OOO
            r.onLeaveOrOOO = isEmployeeOnLeave(emp.Id, checkDate)
                             || (emp.Work_Status__c != null
                                 && emp.Work_Status__c.toLowerCase().contains('ooo'));

            if (r.onLeaveOrOOO) {
                results.add(r);
                continue;
            }

            // No attendance record → missing both
            if (!attByEmp.containsKey(emp.Id)) {
                r.missingClockIn = true;
                r.missingClockOut = true;
                results.add(r);
                continue;
            }

            Attendance__c att = attByEmp.get(emp.Id);
            r.attendanceId = att.Id;

            // Missing clock in
            if (att.First_Clock_In__c == null) {
                r.missingClockIn = true;
            }

            // Check last log for missing clock out
            Attendance_Log__c logRec = logByAtt.get(att.Id);
            if (logRec != null && !String.isBlank(logRec.Log_Data__c)) {
                try {
                    List<Object> logs = (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);
                    if (!logs.isEmpty()) {
                        Map<String, Object> lastEntry =
                            (Map<String, Object>) logs.get(logs.size() - 1);

                        if (String.valueOf(lastEntry.get('action')) == 'Clock In') {
                            r.missingClockOut = true;
                        }
                    }
                } catch (Exception e) {
                    // ignore malformed logs
                }
            }

            results.add(r);
        }
        return results;
    }

    public static void sendNotifications(List<CheckResult> checks) {

        if (checks == null || checks.isEmpty()) return;

        Map<Id, List<String>> userMsgs = new Map<Id, List<String>>();

        for (CheckResult cr : checks) {

            if (cr.onLeaveOrOOO) continue;
            if (cr.userId == null) continue;

            String msg;

            if (cr.missingClockIn && !cr.missingClockOut)
                msg = 'You missed Clock-In on ' + cr.dateChecked.format() + '.';
            else if (!cr.missingClockIn && cr.missingClockOut)
                msg = 'You missed Clock-Out on ' + cr.dateChecked.format() + '.';
            else if (cr.missingClockIn && cr.missingClockOut)
                msg = 'You missed both Clock-In and Clock-Out on ' + cr.dateChecked.format() + '.';
            else
                continue;

            if (!userMsgs.containsKey(cr.userId))
                userMsgs.put(cr.userId, new List<String>());

            userMsgs.get(cr.userId).add(msg);
        }

        if (userMsgs.isEmpty()) return;

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<Id> userIds = userMsgs.keySet();

        Map<Id, User> userMap = new Map<Id, User>(
            [SELECT Id, Email, Name FROM User WHERE Id IN :userIds]
        );

        for (Id uId : userMsgs.keySet()) {

            User u = userMap.get(uId);
            if (u == null || String.isBlank(u.Email)) continue;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{u.Email});
            mail.setSubject('Attendance Alert for ' + Date.today().addDays(-1).format());
            mail.setPlainTextBody(
                'Hello ' + u.Name + ',\n\n' +
                String.join(userMsgs.get(uId), '\n\n') +
                '\n\nRegards,\nAttendance System'
            );

            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    private static Boolean isEmployeeOnLeave(Id empId, Date day) {
        return ![
            SELECT Id FROM Case
            WHERE Employee__c = :empId
              AND Leave_Status__c = 'Approved'
              AND Start_Date__c <= :day
              AND End_Date__c >= :day
            LIMIT 1
        ].isEmpty();
    }
}
