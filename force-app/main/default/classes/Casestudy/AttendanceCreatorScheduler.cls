global class AttendanceCreatorScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        System.debug('=== AttendanceCreatorScheduler START ===');

        try {
            Id jobId = Database.executeBatch(new BatchAttendanceCreator(Date.today()), 200);
            System.debug('=== BatchAttendanceCreator SUBMITTED === JobId: ' + jobId);
        } catch (Exception ex) {
            System.debug('### ERROR submitting BatchAttendanceCreator: ' + ex.getMessage());
            System.debug('### STACK TRACE: ' + ex.getStackTraceString());
        }

        System.debug('=== AttendanceCreatorScheduler END ===');
    }
}
