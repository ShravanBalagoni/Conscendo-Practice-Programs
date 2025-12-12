public with sharing class AttendanceNotificationService {

    // DTO
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

    // MAIN CHECK
    public static List<CheckResult> checkEmployeesForDate(List<Employee__c> employees, Date checkDate) {

        if (employees == null || employees.isEmpty()) return new List<CheckResult>();

        Set<Id> empIds = new Set<Id>();
        for (Employee__c e : employees) empIds.add(e.Id);

        // Fetch attendance
        Map<Id, Attendance__c> attByEmp = new Map<Id, Attendance__c>(
            [
                SELECT Id, Employee__c, First_Clock_In__c, Last_Clock_Out__c
                FROM Attendance__c
                WHERE Employee__c IN :empIds
                AND Date__c = :checkDate
            ]
        );

        // Fetch logs too
        Map<Id, Attendance_Log__c> logByAtt = new Map<Id, Attendance_Log__c>(
            [
                SELECT Id, Attendance__c, Log_Data__c
                FROM Attendance_Log__c
                WHERE Attendance__c IN :attByEmp.values()
            ]
        );

        List<CheckResult> results = new List<CheckResult>();

        for (Employee__c emp : employees) {

            CheckResult r = new CheckResult(emp.Id, emp.User__c, checkDate);

            // No user assigned
            if (emp.User__c == null) {
                results.add(r);
                continue;
            }

            // Leave / OOO check
            r.onLeaveOrOOO = isEmployeeOnLeave(emp.Id, checkDate)
                             || (emp.Work_Status__c != null && emp.Work_Status__c.containsIgnoreCase('OOO'));

            if (r.onLeaveOrOOO) {
                results.add(r);
                continue;
            }

            // No attendance record → missing Clock-In
            if (!attByEmp.containsKey(emp.Id)) {
                r.missingClockIn = true;
                results.add(r);
                continue;
            }

            Attendance__c att = attByEmp.get(emp.Id);
            r.attendanceId = att.Id;

            // Check missing clock-in (first login)
            if (att.First_Clock_In__c == null) {
                r.missingClockIn = true;
            }

            // =============== NEW LOGIC FOR MISSING CLOCK-OUT ===============
            Attendance_Log__c logRec = logByAtt.get(att.Id);

            if (logRec != null && String.isNotBlank(logRec.Log_Data__c)) {

                List<Object> logs = (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);

                if (!logs.isEmpty()) {
                    Map<String, Object> lastEntry = (Map<String, Object>) logs[logs.size() - 1];

                    // If last action is "Clock In" → missing Clock Out
                    if (String.valueOf(lastEntry.get('action')) == 'Clock In') {
                        r.missingClockOut = true;
                    }
                }
            }
            // ===============================================================

            results.add(r);
        }

        return results;
    }


    // SEND EMAIL NOTIFICATIONS
    public static void sendNotifications(List<CheckResult> checks) {

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

            else continue;

            if (!userMsgs.containsKey(cr.userId))
                userMsgs.put(cr.userId, new List<String>());

            userMsgs.get(cr.userId).add(msg);
        }

        // Send emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id uId : userMsgs.keySet()) {

            User u = [SELECT Id, Email, Name FROM User WHERE Id = :uId LIMIT 1];

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



    // Leave check
    private static Boolean isEmployeeOnLeave(Id empId, Date day) {
        return ![
            SELECT Id FROM Case
            WHERE Employeem__c = :empId
            AND Leave_Status__c = 'Approved'
            AND Start_Date__c <= :day
            AND End_Date__c >= :day
            LIMIT 1
        ].isEmpty();
    }
}
