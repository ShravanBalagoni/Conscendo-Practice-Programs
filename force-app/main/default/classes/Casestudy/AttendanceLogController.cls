public with sharing class AttendanceLogController {

    // --------------------------------------------------
    // GET OR CREATE ATTENDANCE LOG
    //Finds or creates one Attendance_Log__c linking Employee + Attendance
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
                    LIMIT 1].OwnerId;

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
    public static Id addLogEntry(Id attendanceId, String action) {

        // Validate inputs before processing
        if (attendanceId == null || String.isBlank(action)) {
            return null;
        }

        // Resolve current employee
        List<Employee__c> emps = [
            SELECT Id
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        if (emps.isEmpty()) {
            // Exit if no employee record found
            return null;
        }
        // Get or create Attendance_Log__c record for this employee+attendance
        Attendance_Log__c logRec = getOrCreateLog(emps[0].Id, attendanceId);

        //  Safely deserialize existing JSON log history from Log_Data__c
        //Initializes empty list - safe default if no prior logs exist.
        List<Object> logList = new List<Object>();
        //Checks if field has data - skips if null/empty/whitespace.
        if (String.isNotBlank(logRec.Log_Data__c)) {
            //Attempts to parse JSON from Log_Data__c (like [{"action":"Clock In", "timestamp":"2025-12-21T10:15Z"}])
            //JSON.deserializeUntyped() → generic List<Object>
            //List<Object> cast → ready for Map<String,Object> entries
            try {
                logList = (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);
            } catch (Exception e) {
                // JSON fails? (malformed, wrong format, etc.) → resets to empty list
                logList = new List<Object>();
            }
        }

        Datetime nowDt = Datetime.now();

        // ✅ ISO timestamp for ALL new entries
        // Create new log entry with action, ISO timestamp, and date
        Map<String, Object> entry = new Map<String, Object>{
            'action'    => action, // Clock In/Out action name
            'timestamp' => nowDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''), // ISO GMT timestamp
            'date'      => Date.today().format()  // YYYY-MM-DD date string
        };
        // Append entry to existing history array
        logList.add(entry);
        // Serialize complete history back to JSON for storage
        logRec.Log_Data__c   = JSON.serialize(logList); // Full JSON array of all entries
        logRec.Clock_Action__c = action;    // Latest action (summary field)
        logRec.Timestamp__c    = nowDt;     // Latest timestamp (summary field)

        update logRec;
        return logRec.Id;

    }

    // --------------------------------------------------
    // GET LOG ENTRIES (SAFE, EXPERIENCE FRIENDLY)
    // --------------------------------------------------
    @AuraEnabled
    public static List<Map<String, Object>> getLogEntries(Id attendanceLogId) {
        // Initialize empty result list for LWC display
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        if (attendanceLogId == null) {// Exit early if no log ID
            return result;
        }
        // Query single Attendance_Log__c record by ID
        List<Attendance_Log__c> logs = [
            SELECT Log_Data__c, Clock_Action__c, Timestamp__c
            FROM Attendance_Log__c
            WHERE Id = :attendanceLogId
            LIMIT 1
        ];
        // Return empty if log not found
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
// RESOLVE LOG ID FROM ATTENDANCE (LWC chaining helper)
// --------------------------------------------------
    @AuraEnabled
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
