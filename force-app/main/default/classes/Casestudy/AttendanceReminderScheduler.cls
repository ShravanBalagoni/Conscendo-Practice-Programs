global class AttendanceReminderScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        System.debug('=== [AttendanceReminderScheduler] START ===');
        
        try {
            BatchAttendanceNotifier batchJob = new BatchAttendanceNotifier();
            Id jobId = Database.executeBatch(batchJob, 200);
            
            System.debug('=== [AttendanceReminderScheduler] BatchAttendanceNotifier submitted successfully ===');
            System.debug('=== [AttendanceReminderScheduler] Batch Job Id: ' + jobId + ' ===');
        
        } catch (Exception ex) {
            System.debug('### [AttendanceReminderScheduler] ERROR while submitting batch job ###');
            System.debug('### Error Message: ' + ex.getMessage());
            System.debug('### Stack Trace: ' + ex.getStackTraceString());
        }

        System.debug('=== [AttendanceReminderScheduler] END ===');
    }
}
