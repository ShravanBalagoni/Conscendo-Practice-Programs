global class BatchAttendanceNotifier implements Database.Batchable<SObject>, Database.Stateful {

    private Date checkDate;

    public BatchAttendanceNotifier() {
        this.checkDate = Date.today().addDays(-1);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        // FIX: Added Work_Status__c
        return Database.getQueryLocator(
            'SELECT Id, User__c, Work_Status__c FROM Employee__c WHERE User__c != null'
        );
    }

    global void execute(Database.BatchableContext bc, List<Employee__c> scope) {
        if (scope == null || scope.isEmpty()) return;

        List<AttendanceNotificationService.CheckResult> checks =
            AttendanceNotificationService.checkEmployeesForDate(scope, checkDate);

        AttendanceNotificationService.sendNotifications(checks);
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('BatchAttendanceNotifier finished for date: ' + checkDate);
    }
}
