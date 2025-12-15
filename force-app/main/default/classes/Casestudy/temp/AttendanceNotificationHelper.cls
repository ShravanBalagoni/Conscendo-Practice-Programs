global class AttendanceNotificationHelper {

    // force recompile v2

    global static void sendMissingPunchNotification(
        Attendance__c attendance,
        Employee__c employee,
        String message
    ) {
        if (employee == null || employee.User__c == null) return;

        Id notifTypeId = [
            SELECT Id
            FROM CustomNotificationType
            WHERE DeveloperName = 'Attendance_Missing_Punch'
            LIMIT 1
        ].Id;

        Messaging.CustomNotification notif =
            new Messaging.CustomNotification();

        notif.setTitle('Attendance Action Required');
        notif.setBody(message);
        notif.setNotificationTypeId(notifTypeId);
        notif.setTargetId(attendance.Id);
        notif.setSenderId(UserInfo.getUserId());

        notif.send(new Set<String>{ employee.User__c });
    }
}
