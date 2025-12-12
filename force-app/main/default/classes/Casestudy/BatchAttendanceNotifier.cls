global class BatchAttendanceNotifier implements Database.Batchable<SObject>, Database.Stateful {

    private Date targetDate = Date.today().addDays(-1);

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, User__c, Work_status__c
            FROM Employee__c
            WHERE User__c != null
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Employee__c> emps) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Employee__c emp : emps) {

            Boolean missingIn = false;
            Boolean missingOut = false;

            Boolean onLeave = ![
                SELECT Id FROM Case
                WHERE Employee__c = :emp.Id
                  AND Start_Date__c <= :targetDate
                  AND End_Date__c >= :targetDate
                  AND Leave_Status__c = 'Approved'
                LIMIT 1
            ].isEmpty();

            Boolean isOOO = emp.Work_status__c != null 
                             && emp.Work_status__c.toLowerCase().contains('ooo');

            if (onLeave || isOOO) continue;

            List<Attendance__c> atts = [
                SELECT Id FROM Attendance__c
                WHERE Employee__c = :emp.Id
                  AND Date__c = :targetDate
                LIMIT 1
            ];

            if (atts.isEmpty()) {
                missingIn = true;
                missingOut = true;
            } else {
                Attendance__c att = atts[0];
                List<Attendance_Log__c> logs = [
                    SELECT Log_Data__c
                    FROM Attendance_Log__c
                    WHERE Attendance__c = :att.Id
                ];

                if (logs.isEmpty() || String.isBlank(logs[0].Log_Data__c)) {
                    missingIn = true;
                    missingOut = true;
                } else {

                    // FIX STARTS HERE — SAFELY HANDLE JSON
                    String rawJson = logs[0].Log_Data__c;

                    List<Object> jsonList = new List<Object>();
                    if (String.isNotBlank(rawJson)) {
                        Object parsed = JSON.deserializeUntyped(rawJson);
                        jsonList = (List<Object>) parsed;
                    }
                    // FIX ENDS HERE

                    Boolean hasIn = false;
                    Boolean hasOut = false;

                    for (Object o : jsonList) {
                        Map<String, Object> m = (Map<String, Object>) o;
                        if (String.valueOf(m.get('action')) == 'Clock In') hasIn = true;
                        if (String.valueOf(m.get('action')) == 'Clock Out') hasOut = true;
                    }

                    if (!hasIn) missingIn = true;
                    if (hasIn && !hasOut) missingOut = true;
                }
            }

            List<String> msgs = new List<String>();
            if (missingIn && !missingOut) msgs.add('You missed Clock-In on ' + targetDate);
            if (!missingIn && missingOut) msgs.add('You missed Clock-Out on ' + targetDate);
            if (missingIn && missingOut) msgs.add('You missed both punches on ' + targetDate);

            if (!msgs.isEmpty()) {
                User u = [SELECT Email, Name FROM User WHERE Id = :emp.User__c LIMIT 1];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[]{u.Email});
                mail.setSubject('Attendance Alert for ' + targetDate.format());
                mail.setPlainTextBody('Hello ' + u.Name + ',\n\n' +
                    String.join(msgs, '\n') +
                    '\n\nRegards,\nAttendance System');
                emails.add(mail);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext bc) {}
}
