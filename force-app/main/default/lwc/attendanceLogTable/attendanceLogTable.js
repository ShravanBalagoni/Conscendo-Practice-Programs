import { LightningElement, api, track } from 'lwc';
import getLogEntries from '@salesforce/apex/AttendanceLogController.getLogEntries';
import getAttendanceLogId from '@salesforce/apex/AttendanceLogController.getAttendanceLogId';

export default class AttendanceLogTable extends LightningElement {

    // --------------------------------------------------
    // INPUTS
    // --------------------------------------------------
    @api recordId; // Internal Salesforce (Attendance_Log__c Id)

    _attendanceId;
    @api
    get attendanceId() {
        return this._attendanceId;
    }
    set attendanceId(value) {
        this._attendanceId = value;

        // Experience Cloud: load when valid Attendance__c Id arrives
        if (this.isValidSalesforceId(value)) {
            this.loadLogs();
        }
    }

    // --------------------------------------------------
    // UI STATE
    // --------------------------------------------------
    @track isLoading = true;   // controls spinner
    @track hasLoaded = false;  // controls table visibility
    @track pairedLogs = [];
    @track totalHours = '--';

    _isLoading = false;

    // --------------------------------------------------
    // INTERNAL SALESFORCE ENTRY POINT
    // --------------------------------------------------
    renderedCallback() {
        if (
            this.isValidSalesforceId(this.recordId) &&
            !this.hasLoaded &&
            !this._isLoading
        ) {
            this.loadLogs();
        }
    }

    // --------------------------------------------------
    // CORE LOG LOADER (NO BUFFERING)
    // --------------------------------------------------
    async loadLogs() {
        if (this._isLoading) return;

        this._isLoading = true;
        this.isLoading = true;

        try {
            let logId = null;

            // Internal Salesforce
            if (this.isValidSalesforceId(this.recordId)) {
                logId = this.recordId;
            }
            // Experience Cloud
            else if (this.isValidSalesforceId(this._attendanceId)) {
                logId = await getAttendanceLogId({
                    attendanceId: this._attendanceId
                });
            }

            // If log does not exist yet → show empty table
            if (!this.isValidSalesforceId(logId)) {
                this.pairedLogs = [];
                this.totalHours = '--';
                return;
            }

            const logs = await getLogEntries({
                attendanceLogId: logId
            }) || [];

            this.totalHours = this.calculateTotalHours(logs);
            this.pairedLogs = this.buildPairs(logs);

        } catch (err) {
            console.error(
                'AttendanceLogTable error',
                err?.body?.message || err?.message || JSON.stringify(err)
            );
            this.pairedLogs = [];
            this.totalHours = '--';
        } finally {
            // 🔑 IMPORTANT — stop buffering
            this._isLoading = false;
            this.isLoading = false;
            this.hasLoaded = true;
        }
    }

    // --------------------------------------------------
    // SALESFORCE ID VALIDATION
    // --------------------------------------------------
    isValidSalesforceId(value) {
        return typeof value === 'string' &&
            (value.length === 15 || value.length === 18) &&
            /^[a-zA-Z0-9]+$/.test(value);
    }

    // --------------------------------------------------
    // TIMESTAMP PARSER (OLD + NEW)
    // --------------------------------------------------
    parseTimestamp(raw) {
        if (!raw) return null;

        if (raw instanceof Date) return raw;

        const s = String(raw).trim();

        // ISO format (new Apex)
        if (/^\d{4}-\d{2}-\d{2}T/.test(s)) {
            const d = new Date(s);
            return isNaN(d.getTime()) ? null : d;
        }

        // Old format: MM/DD/YYYY hh:mm AM/PM
        const m = s.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4}) (\d{1,2}):(\d{2}) (AM|PM)$/i);
        if (m) {
            let [, mm, dd, yyyy, hh, min, ap] = m;
            let hour = parseInt(hh, 10);

            if (ap.toUpperCase() === 'PM' && hour < 12) hour += 12;
            if (ap.toUpperCase() === 'AM' && hour === 12) hour = 0;

            return new Date(
                parseInt(yyyy, 10),
                parseInt(mm, 10) - 1,
                parseInt(dd, 10),
                hour,
                parseInt(min, 10),
                0
            );
        }

        return null;
    }

    // --------------------------------------------------
    // DISPLAY TIME (2:30 PM)
    // --------------------------------------------------
    formatTime(raw) {
        const d = this.parseTimestamp(raw);
        if (!d) return '--';

        return d.toLocaleTimeString([], {
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
        });
    }

    // --------------------------------------------------
    // TOTAL HOURS
    // --------------------------------------------------
    calculateTotalHours(list) {
        if (!list || !list.length) return '--';

        let firstIn = null;
        let lastOut = null;

        list.forEach(item => {
            const dt = this.parseTimestamp(item.timestamp);
            if (!dt) return;

            if (item.action === 'Clock In' && (!firstIn || dt < firstIn)) {
                firstIn = dt;
            }
            if (item.action === 'Clock Out' && (!lastOut || dt > lastOut)) {
                lastOut = dt;
            }
        });

        if (!firstIn || !lastOut) return '--';

        const diffMs = lastOut - firstIn;
        const hrs = Math.floor(diffMs / (1000 * 60 * 60));
        const mins = Math.floor((diffMs / (1000 * 60)) % 60);

        return `${hrs.toString().padStart(2, '0')}:${mins
            .toString()
            .padStart(2, '0')} hrs`;
    }

    // --------------------------------------------------
    // BUILD TABLE ROWS
    // --------------------------------------------------
    buildPairs(list) {
        const rows = [];
        let current = {};

        list.forEach((log, i) => {
            if (log.action === 'Clock In') {
                current = {
                    index: i,
                    date: log.date,
                    clockIn: this.formatTime(log.timestamp)
                };
            }

            if (log.action === 'Clock Out' && current.index !== undefined) {
                current.clockOut = this.formatTime(log.timestamp);
                current.status = '✔';
                current.statusClass = 'status-success';
                rows.push({ ...current });
                current = {};
            }
        });

        // Missing Clock Out
        if (current.index !== undefined) {
            rows.push({
                index: list.length,
                date: current.date,
                clockIn: current.clockIn,
                clockOut: '—',
                status: '❌',
                statusClass: 'status-error'
            });
        }

        return rows;
    }

    // --------------------------------------------------
    // DATATABLE COLUMNS
    // --------------------------------------------------
    get columns() {
        return [
            { label: 'Date', fieldName: 'date', type: 'text' },
            { label: 'Clock In', fieldName: 'clockIn', type: 'text' },
            { label: 'Clock Out', fieldName: 'clockOut', type: 'text' },
            {
                label: 'Status',
                fieldName: 'status',
                type: 'text',
                cellAttributes: {
                    class: { fieldName: 'statusClass' },
                    alignment: 'center'
                }
            }
        ];
    }
}
