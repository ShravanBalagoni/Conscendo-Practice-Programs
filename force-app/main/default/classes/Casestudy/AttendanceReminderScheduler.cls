global class AttendanceReminderScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Batch size 200 (safe); reduce if needed
        Database.executeBatch(new BatchAttendanceNotifier(), 200);
    }
}
