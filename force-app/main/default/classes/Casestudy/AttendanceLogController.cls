public with sharing class AttendanceLogController {

    // --------------------------------------------------
    // GET OR CREATE ATTENDANCE LOG
    // --------------------------------------------------
    public static Attendance_Log__c getOrCreateLog(Id empId, Id attendanceId) {

        List<Attendance_Log__c> logs = [
            SELECT Id, Employee__c, Attendance__c, Log_Data__c,
                   Clock_Action__c, Timestamp__c
            FROM Attendance_Log__c
            WHERE Employee__c = :empId
              AND Attendance__c = :attendanceId
            LIMIT 1
        ];

        if (!logs.isEmpty()) {
            return logs[0];
        }

        // Get the Attendance owner
Id attendanceOwner = [
    SELECT OwnerId
    FROM Attendance__c
    WHERE Id = :attendanceId
    LIMIT 1
].OwnerId;

// Create the log record with the same owner
Attendance_Log__c newLog = new Attendance_Log__c(
    Employee__c = empId,
    Attendance__c = attendanceId,
    Log_Data__c = '[]',
    OwnerId = attendanceOwner
);

insert newLog;
return newLog;

    }

    // --------------------------------------------------
    // ADD LOG ENTRY (ISO + TIMEZONE SAFE)
    // --------------------------------------------------
    @AuraEnabled
    public static void addLogEntry(Id attendanceId, String action) {

        if (attendanceId == null || String.isBlank(action)) {
            return;
        }

        // Resolve current employee
        List<Employee__c> emps = [
            SELECT Id
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        if (emps.isEmpty()) {
            return;
        }

        Attendance_Log__c logRec = getOrCreateLog(emps[0].Id, attendanceId);

        // Deserialize existing JSON safely
        List<Object> logList = new List<Object>();
        if (String.isNotBlank(logRec.Log_Data__c)) {
            try {
                logList = (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);
            } catch (Exception e) {
                logList = new List<Object>();
            }
        }

        Datetime nowDt = Datetime.now();

        // ✅ ISO timestamp for ALL new entries
        Map<String, Object> entry = new Map<String, Object>{
            'action'    => action,
            'timestamp' => nowDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),
            'date'      => Date.today().format()
        };

        logList.add(entry);

        logRec.Log_Data__c   = JSON.serialize(logList);
        logRec.Clock_Action__c = action;
        logRec.Timestamp__c    = nowDt;

        update logRec;
    }

    // --------------------------------------------------
    // GET LOG ENTRIES (SAFE, EXPERIENCE FRIENDLY)
    // --------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getLogEntries(Id attendanceLogId) {

        List<Map<String, Object>> result = new List<Map<String, Object>>();
        if (attendanceLogId == null) {
            return result;
        }

        List<Attendance_Log__c> logs = [
            SELECT Log_Data__c, Clock_Action__c, Timestamp__c
            FROM Attendance_Log__c
            WHERE Id = :attendanceLogId
            LIMIT 1
        ];

        if (logs.isEmpty()) {
            return result;
        }

        Attendance_Log__c logRec = logs[0];

        // ✅ Primary: JSON-based history
        if (String.isNotBlank(logRec.Log_Data__c)) {
            try {
                List<Object> stored =
                    (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);
                for (Object item : stored) {
                    result.add((Map<String, Object>) item);
                }
                return result;
            } catch (Exception e) {
                // Fall through to field-based fallback
            }
        }

        // 🔁 Fallback: ensures UI never shows empty
        if (logRec.Clock_Action__c != null && logRec.Timestamp__c != null) {
            result.add(new Map<String, Object>{
                'action'    => logRec.Clock_Action__c,
                'timestamp' => logRec.Timestamp__c
                                    .formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),
                'date'      => Date.today().format()
            });
        }

        return result;
    }

    // --------------------------------------------------
    // RESOLVE LOG ID FROM ATTENDANCE (EXPERIENCE SAFE)
    // --------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Id getAttendanceLogId(Id attendanceId) {

        if (attendanceId == null) {
            return null;
        }

        List<Attendance_Log__c> logs = [
            SELECT Id
            FROM Attendance_Log__c
            WHERE Attendance__c = :attendanceId
            LIMIT 1
        ];

        return logs.isEmpty() ? null : logs[0].Id;
    }
}
