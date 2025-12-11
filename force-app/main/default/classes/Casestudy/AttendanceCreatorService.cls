public with sharing class AttendanceCreatorService {

    public static Integer createAttendanceForEmployees(List<Employee__c> employees, Date targetDate) {

        if (employees == null || employees.isEmpty()) return 0;

        Set<Id> empIds = new Set<Id>();
        for (Employee__c e : employees) empIds.add(e.Id);

        // Check existing attendance
        Map<Id, Attendance__c> existing = new Map<Id, Attendance__c>(
            [SELECT Id, Employee__c FROM Attendance__c
             WHERE Employee__c IN :empIds
             AND Date__c = :targetDate]
        );

        Integer count = 0;
        List<Attendance__c> newRecs = new List<Attendance__c>();

        for (Employee__c e : employees) {

            // Skip already created
            if (existing.containsKey(e.Id)) continue;

            // Leave detection
            Boolean onLeave = ![
                SELECT Id FROM Case
                WHERE Employeem__c = :e.Id
                  AND Leave_Status__c = 'Approved'
                  AND Start_Date__c <= :targetDate
                  AND End_Date__c >= :targetDate
                LIMIT 1
            ].isEmpty();

            if (onLeave) continue;

            // OOO detection
            if (e.Work_status__c != null && e.Work_status__c.containsIgnoreCase('OOO')) continue;

            Attendance__c a = new Attendance__c(
                Employee__c = e.Id,
                Date__c = targetDate
            );

            newRecs.add(a);
        }

        if (!newRecs.isEmpty()) {
            Database.SaveResult[] sr = Database.insert(newRecs, false);
            for (Database.SaveResult r : sr)
                if (r.isSuccess()) count++;
        }
        return count;
    }
}
