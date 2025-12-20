public with sharing class AttendanceCreatorService {

    public static Integer createDailyAttendanceAndLogs(
        List<Employee__c> employees,
        Date targetDate
    ) {
        List<Employee__c> employeesToReset = new List<Employee__c>();

        if (employees == null || employees.isEmpty() || targetDate == null) return 0;

        Set<Id> empIds = new Set<Id>();
        for (Employee__c e : employees) {
            if (e.Id != null) empIds.add(e.Id);
        }
        if (empIds.isEmpty()) return 0;

        // Existing attendance
        Map<Id, Attendance__c> existingAttendance = new Map<Id, Attendance__c>();
        for (Attendance__c a : [
            SELECT Id, Employee__c
            FROM Attendance__c
            WHERE Employee__c IN :empIds
              AND Date__c = :targetDate
        ]) {
            existingAttendance.put(a.Employee__c, a);
        }

        // Leave check
        Set<Id> onLeaveEmpIds = new Set<Id>();
        for (Case c : [
            SELECT Employee__c
            FROM Case
            WHERE Employee__c IN :empIds
              AND Start_Date__c <= :targetDate
              AND End_Date__c >= :targetDate
              AND Leave_Status__c = 'Approved'
        ]) {
            onLeaveEmpIds.add(c.Employee__c);
        }

        List<Attendance__c> attendanceToInsert = new List<Attendance__c>();

        for (Employee__c emp : employees) {
            if (emp == null || emp.Id == null) continue;
            if (existingAttendance.containsKey(emp.Id)) continue;

            Attendance__c att = new Attendance__c(
                Employee__c = emp.Id,
                Date__c = targetDate,
                Status__c = onLeaveEmpIds.contains(emp.Id)
                    ? 'Holiday'
                    : 'Absent',
                OwnerId = emp.OwnerId
            );

            attendanceToInsert.add(att);

            // 🔹 Reset clock status for new day (button shows Clock In)
            emp.Clockin_Clockout__c = null;
            employeesToReset.add(emp);
        }

        if (!attendanceToInsert.isEmpty()) {
            insert attendanceToInsert;
        }

        // ✅ REQUIRED FIX — persist employee reset
        if (!employeesToReset.isEmpty()) {
            update employeesToReset;
        }

        // 🔹 Create Attendance Logs (get-or-create)
        createLogsForAttendances(targetDate);

        return attendanceToInsert.size();
    }

    // --------------------------------------
    // Create Attendance Logs for the day
    // --------------------------------------
    private static void createLogsForAttendances(Date targetDate) {

        List<Attendance__c> attendances = [
            SELECT Id, Employee__c,OwnerId
            FROM Attendance__c
            WHERE Date__c = :targetDate
        ];

        Set<Id> attendanceIds = new Set<Id>();
        for (Attendance__c a : attendances) attendanceIds.add(a.Id);

        Set<Id> existingLogs = new Set<Id>();
        for (Attendance_Log__c log : [
            SELECT Attendance__c
            FROM Attendance_Log__c
            WHERE Attendance__c IN :attendanceIds
        ]) {
            existingLogs.add(log.Attendance__c);
        }

        List<Attendance_Log__c> logsToInsert = new List<Attendance_Log__c>();
        for (Attendance__c att : attendances) {
            if (existingLogs.contains(att.Id)) continue;

            logsToInsert.add(new Attendance_Log__c(
                Attendance__c = att.Id,
                Employee__c = att.Employee__c,
                Log_Data__c = '[]',
                OwnerId=att.OwnerId
            ));
        }

        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }
    }
}
