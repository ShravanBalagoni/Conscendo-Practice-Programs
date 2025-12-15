global class BatchAttendanceNotifier implements Database.Batchable<SObject>, Database.Stateful {

    private Date targetDate = Date.today().addDays(-1);

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Process all employees; notification logic handles null User safely
        return Database.getQueryLocator([
            SELECT Id, User__c, Work_Status__c
            FROM Employee__c
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Employee__c> emps) {
        if (emps == null || emps.isEmpty()) return;

        // Use centralized service to check attendance and notify
        List<AttendanceNotificationService.CheckResult> results =
            AttendanceNotificationService.checkEmployeesForDate(emps, targetDate);

        // Send notifications in bulk
        AttendanceNotificationService.sendNotifications(results);
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: you can add post-notification logging here
    }
}
