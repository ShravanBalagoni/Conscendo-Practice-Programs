global class BatchAttendanceCreator implements Database.Batchable<SObject>, Database.Stateful {

    private Date targetDate;

    // Default constructor: create attendance for TODAY
    public BatchAttendanceCreator() {
        this.targetDate = Date.today();
    }

    // Optional constructor: allow custom date in case you need it
    public BatchAttendanceCreator(Date dateToCreate) {
        this.targetDate = dateToCreate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Fetch all employees
        return Database.getQueryLocator(
            'SELECT Id, User__c, Work_status__c FROM Employee__c WHERE Id != null'
        );
    }

    global void execute(Database.BatchableContext bc, List<Employee__c> scope) {
        if (scope == null || scope.isEmpty()) return;
        
        Integer createdCount = AttendanceCreatorService.createAttendanceForEmployees(scope, targetDate);
        System.debug('Batch chunk created: ' + createdCount + ' attendance records for date ' + targetDate);
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('BatchAttendanceCreator finished for ' + targetDate);
    }
}
