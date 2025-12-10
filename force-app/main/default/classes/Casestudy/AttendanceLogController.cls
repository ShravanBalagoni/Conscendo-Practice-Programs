/**
 * @description Controller to manage audit logs for attendance records. 
 *              Maintains a single JSON log (array) per attendance record,
 *              and supports adding new log entries or retrieving log history.
 * @author Shravan
 * @date   2025-12-10
 */
public class AttendanceLogController {

    // Get or create SINGLE log record per attendance record
    /**
     * @description Retrieves an existing log record for the given employee and attendance,
     *              or creates a new one if none exists. Ensures there is exactly one
     *              Attendance_Log__c per employee + attendance combination.
     * @param empId         Id  — the Salesforce Id of the Employee__c record
     * @param attendanceId  Id  — the Salesforce Id of the Attendance__c record
     * @return Attendance_Log__c — the existing or newly created log record
     * @access private
     */
    private static Attendance_Log__c getOrCreateLog(Id empId, Id attendanceId) {

        List<Attendance_Log__c> logs = [
            SELECT Id, Log_Data__c
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

    // Add a new entry to JSON log array
     /**
     * @description Adds a new entry to the JSON log for a given attendance record.
     *              The log entry captures the action (like 'Clock In' or 'Clock Out'),
     *              a timestamp, and the date. If no log record exists yet for the attendance,
     *              it will be created.
     * @param attendanceId  Id     — the Id of the Attendance__c whose log to update
     * @param action        String — the action performed (e.g. 'Clock In', 'Clock Out')
     * @return void
     * @throws Any runtime exception if the employee or log record cannot be resolved 
     *         (for example, if no Employee__c is found for current user).
     * @access public (Apex API)
     */
    @AuraEnabled
    public static void addLogEntry(Id attendanceId, String action) {

        Employee__c emp = [
            SELECT Id FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];

        Attendance_Log__c logRec = getOrCreateLog(emp.Id, attendanceId);

        List<Object> logList = new List<Object>();
        if (String.isNotBlank(logRec.Log_Data__c)) {
            logList = (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);
        }

        Map<String, Object> entry = new Map<String, Object>();
        entry.put('action', action);
        entry.put('timestamp', Datetime.now().format());
        entry.put('date', Date.today().format());

        logList.add(entry);

        logRec.Log_Data__c = JSON.serialize(logList);
        update logRec;
    }

    // Return logs for LWC using Attendance_Log__c recordId
    /**
     * @description Retrieves all log entries for a given Attendance_Log__c record,
     *              deserializing the stored JSON array and returning it as a list of maps
     *              (one map per log entry). Useful for LWC/Aura to render history of clock-in/clock-out events.
     * @param attendanceLogId  Id — the Id of the Attendance_Log__c record
     * @return List<Map<String, Object>> — list of log entries, each entry representing:
     *            { 'action': String, 'timestamp': String, 'date': String }
     *            Returns an empty list if no log or no stored log data found.
     * @access public (Apex API)
     */
   @AuraEnabled
public static List<Map<String, Object>> getLogEntries(Id attendanceLogId) {

    Attendance_Log__c logRec = [
        SELECT Id, Log_Data__c
        FROM Attendance_Log__c
        WHERE Id = :attendanceLogId
        LIMIT 1
    ];

    List<Map<String, Object>> result = new List<Map<String, Object>>();

    if (logRec == null || String.isBlank(logRec.Log_Data__c)) {
        return result;
    }

    // Deserialize as List<Object>
    List<Object> stored = (List<Object>) JSON.deserializeUntyped(logRec.Log_Data__c);

    for (Object item : stored) {
        result.add((Map<String, Object>) item);
    }

    return result;
}

}
