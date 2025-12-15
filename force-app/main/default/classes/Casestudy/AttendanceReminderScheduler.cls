global class AttendanceReminderScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        System.debug('=== [AttendanceReminderScheduler] START ===');

        try {
            BatchAttendanceNotifier batchJob = new BatchAttendanceNotifier();
            // Use a reasonable batch size
            Id jobId = Database.executeBatch(batchJob, 200);

            System.debug('=== [AttendanceReminderScheduler] Batch submitted ===');
            System.debug('=== Batch Job Id: ' + jobId + ' ===');

        } catch (Exception ex) {
            System.debug('!!! ERROR while submitting batch !!!');
            System.debug('Error Message: ' + ex.getMessage());
            System.debug('Stack Trace: ' + ex.getStackTraceString());
        }

        System.debug('=== [AttendanceReminderScheduler] END ===');
    }
}
