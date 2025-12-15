global class MissingPunchBatch
    implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        Date yesterday = Date.today().addDays(-1);

        return Database.getQueryLocator([
            SELECT Id, Date__c,
                   First_Clock_In__c,
                   Last_Clock_Out__c,
                   Employee__c,
                   Employee__r.User__c,
                   Employee__r.Work_Status__c
            FROM Attendance__c
            WHERE Date__c = :yesterday
        ]);
    }

    global void execute(Database.BatchableContext bc,
                        List<Attendance__c> scope) {

        for (Attendance__c att : scope) {

            // Skip OOO or Leave employees
            if (att.Employee__r.Work_Status__c == 'OOO') {
                continue;
            }

            // Missing Clock-In
            if (att.First_Clock_In__c == null) {
                AttendanceNotificationHelper
                    .sendMissingPunchNotification(
                        att,
                        att.Employee__r,
                        'You missed clock-in on ' + att.Date__c +
                        '. Please regularize your attendance.'
                    );
            }
            // Missing Clock-Out
            else if (att.Last_Clock_Out__c == null) {
                AttendanceNotificationHelper
                    .sendMissingPunchNotification(
                        att,
                        att.Employee__r,
                        'You missed clock-out on ' + att.Date__c +
                        '. Please regularize your attendance.'
                    );
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        // optional logging
    }
}
