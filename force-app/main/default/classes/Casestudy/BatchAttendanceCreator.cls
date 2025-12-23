global class BatchAttendanceCreator
    implements Database.Batchable<SObject> {

    private Date targetDate;

    public BatchAttendanceCreator() {
        this.targetDate = Date.today();
    }

    public BatchAttendanceCreator(Date d) {
        this.targetDate = d;
    }

    // ✅ QueryLocator allowed for Batchable<SObject>
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, OwnerId, Clockin_Clockout__c, Work_status__c FROM Employee__c'

        );
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        // Cast scope safely
        List<Employee__c> employees = (List<Employee__c>) scope;

        AttendanceCreatorService.createDailyAttendanceAndLogs(
            employees,
            targetDate
        );
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Daily Attendance + Logs created for ' + targetDate);
    }
}
