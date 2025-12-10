public with sharing class AttendanceCreatorService {

    public static Integer createAttendanceForEmployees(List<Employee__c> employees, Date targetDate) {
        if (employees == null || employees.isEmpty() || targetDate == null) return 0;

        // Collect employee IDs
        Set<Id> empIds = new Set<Id>();
        for (Employee__c e : employees) {
            if (e.Id != null) empIds.add(e.Id);
        }
        if (empIds.isEmpty()) return 0;

        // Check existing attendance
        Map<Id, Attendance__c> existingMap = new Map<Id, Attendance__c>();
        for (Attendance__c a : [
            SELECT Id, Employee__c, Date__c
            FROM Attendance__c
            WHERE Employee__c IN :empIds
            AND Date__c = :targetDate
        ]) {
            existingMap.put(a.Employee__c, a);
        }

        // Check leave using CASE object
        Set<Id> onLeaveEmpIds = new Set<Id>();
        try {
            for (Case c : [
                SELECT Id, Employee__c
                FROM Case
                WHERE Employee__c IN :empIds
                  AND Start_Date__c <= :targetDate
                  AND End_Date__c >= :targetDate
                  AND Leave_Status__c = 'Approved'
            ]) {
                if (c.Employee__c != null) onLeaveEmpIds.add(c.Employee__c);
            }
        } catch (Exception ex) {
            System.debug('AttendanceCreatorService: Case leave query failed: ' + ex);
        }

        List<Attendance__c> toInsert = new List<Attendance__c>();

        // Create Attendance records
        for (Employee__c emp : employees) {
            if (emp == null || emp.Id == null) continue;

            // Skip existing attendance
            if (existingMap.containsKey(emp.Id)) continue;

            // Skip OOO employees
            if (emp.Work_status__c != null && emp.Work_status__c.toLowerCase().contains('ooo')) continue;

            // Skip employees on approved leave
            if (onLeaveEmpIds.contains(emp.Id)) continue;

            // Create new attendance
            Attendance__c newA = new Attendance__c(
                Employee__c = emp.Id,
                Date__c = targetDate
            );

            toInsert.add(newA);
        }

        Integer inserted = 0;

        if (!toInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(toInsert, false);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) inserted++;
                else System.debug('Insert failed: ' + sr.getErrors());
            }
        }

        System.debug('Created ' + inserted + ' attendance records for date ' + targetDate);
        return inserted;
    }

    // Fetch employees to process
    public static List<Employee__c> fetchAllEmployees() {
        return [
            SELECT Id, User__c, Work_status__c
            FROM Employee__c
            WHERE Id != null
        ];
    }
}
