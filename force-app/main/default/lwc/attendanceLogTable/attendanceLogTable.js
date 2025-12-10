import { LightningElement, api, track } from 'lwc';
import getLogEntries from '@salesforce/apex/AttendanceLogController.getLogEntries';

export default class AttendanceLogTable extends LightningElement {

    @api recordId; // Attendance_Log__c Id
    @track isLoaded = false;
    @track pairedLogs = [];

    connectedCallback() {
        console.log("RECEIVED RECORD ID → ", this.recordId);
        this.loadLogs();
    }

    async loadLogs() {
        try {
            const logs = await getLogEntries({ attendanceLogId: this.recordId });
            this.pairedLogs = this.buildPairs(logs);
            this.isLoaded = true;
        } catch (err) {
            console.error("Error loading logs", err);
        }
    }

    buildPairs(list) {
        const rows = [];
        let pair = {};

        list.forEach((log, index) => {
            if (log.action === "Clock In") {
                pair = {};
                pair.index = index;
                pair.date = log.date;
                pair.clockIn = log.timestamp;
            }

            if (log.action === "Clock Out") {
                pair.clockOut = log.timestamp;
                rows.push({ ...pair });
                pair = {};
            }
        });

        if (pair.clockIn && !pair.clockOut) {
            rows.push({
                index: list.length,
                date: pair.date,
                clockIn: pair.clockIn,
                clockOut: "❗ MISSING CLOCK OUT"
            });
        }

        return rows;
    }

    get columns() {
        return [
            { label: "Date", fieldName: "date", type: "text" },
            { label: "Clock In", fieldName: "clockIn", type: "text" },
            { label: "Clock Out", fieldName: "clockOut", type: "text" }
        ];
    }
}
