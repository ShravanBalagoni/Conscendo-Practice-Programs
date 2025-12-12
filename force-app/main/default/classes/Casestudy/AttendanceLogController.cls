public with sharing class AttendanceLogController {

    private static Attendance_Log__c getOrCreateLog(Id empId, Id attendanceId) {
        List<Attendance_Log__c> logs = [
            SELECT Id, Employee__c, Attendance__c, Log_Data__c, Clock_Action__c, Timestamp__c
            FROM Attendance_Log__c
            WHERE Employee__c = :empId
              AND Attendance__c = :attendanceId
            LIMIT 1
        ];
        if (!logs.isEmpty()) return logs[0];

        Attendance_Log__c newLog = new Attendance_Log__c(
            Employee__c = empId,
            Attendance__c = attendanceId,
            Log_Data__c = '[]'
        );
        insert newLog;
        return newLog;
    }

    @AuraEnabled
    public static void addLogEntry(Id attendanceId, String action) {
        if (attendanceId == null || String.isBlank(action)) return;

        // resolve current employee
        Employee__c emp;
        List<Employee__c> emps = [
            SELECT Id
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        if (emps.isEmpty()) return;
        emp = emps[0];

        Attendance_Log__c logRec = getOrCreateLog(emp.Id, attendanceId);

        List<Object> logList = new List<Object>();
        if (String.isNotBlank(logRec.Log_Data__c)) {
            try {
                logList = (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);
            } catch (Exception ex) {
                logList = new List<Object>();
            }
        }

        Datetime now = Datetime.now();

        Map<String, Object> entry = new Map<String, Object>{
            'action' => action,
            'timestamp' => now.format('MM/dd/yyyy hh:mm a'),
             
            'date' => Date.today().format()
        };

        logList.add(entry);

        logRec.Log_Data__c = JSON.serialize(logList);
        logRec.Clock_Action__c = action;
        logRec.Timestamp__c = now;

        update logRec;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getLogEntries(Id attendanceLogId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        if (attendanceLogId == null) return result;

        Attendance_Log__c logRec = [
           SELECT Log_Data__c 
FROM Attendance_Log__c 
WHERE Id = :attendanceLogId

        ];

        if (logRec == null || String.isBlank(logRec.Log_Data__c)) return result;

        List<Object> stored = (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);
        for (Object item : stored) {
            result.add((Map<String, Object>) item);
        }
        return result;
    }
    @AuraEnabled
public static Id getAttendanceLogId(Id attendanceId) {
    if (attendanceId == null) return null;

    List<Attendance_Log__c> logs = [
        SELECT Id
        FROM Attendance_Log__c
        WHERE Attendance__c = :attendanceId
        LIMIT 1
    ];

    return logs.isEmpty() ? null : logs[0].Id;
}

}
