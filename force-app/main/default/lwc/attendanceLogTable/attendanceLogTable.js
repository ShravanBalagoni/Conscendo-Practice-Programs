import { LightningElement, api, track } from 'lwc';
import getLogEntries from '@salesforce/apex/AttendanceLogController.getLogEntries';
import getAttendanceLogId from '@salesforce/apex/AttendanceLogController.getAttendanceLogId';
export default class AttendanceLogTable extends LightningElement {
    // INPUTS
    
    @api recordId;       // Internal org (Attendance_Log__c)
    _attendanceId;
    @api
    get attendanceId() {
        return this._attendanceId;
    }
    set attendanceId(value) {
        if (this.isValidId(value) && value !== this._attendanceId) {
            this._attendanceId = value;
            this.load(); // reload when Experience injects value
        }
    }

    
    _attendanceLogId;
    @api
    get attendanceLogId() {
    return this._attendanceLogId;
    }   
    set attendanceLogId(value) {
        if (this.isValidId(value) && value !== this._attendanceLogId) {
            this._attendanceLogId = value;
            this.load();
        }
}

    // UI STATE
    @track isLoading = false;
    @track pairedLogs = [];
    @track totalHours = '--';

    // LIFECYCLE
    
    connectedCallback() {
        this.load();
    }

    // MAIN LOAD
    
    async load() {
    this.isLoading = true;

    try {
        // 1️⃣ Parent-driven
        if (this.isValidId(this._attendanceLogId)) {
            await this.loadByLogId(this._attendanceLogId);
            return;
        }

        // 2️⃣ Fallback via attendanceId
        if (this.isValidId(this._attendanceId)) {
            const logId = await getAttendanceLogId({
                attendanceId: this._attendanceId
            });

            if (!this.isValidId(logId)) {
                this.resetUI();
                return;
            }

            await this.loadByLogId(logId);
            return;
        }

        // 3️⃣ Internal record page
        if (this.isValidId(this.recordId)) {
            await this.loadByLogId(this.recordId);
            return;
        }

        this.resetUI();
    } catch (e) {
        console.error('AttendanceLogTable load error', e);
        this.resetUI();
    } finally {
        this.isLoading = false;
    }
}
    @api
    async refresh() {
        this.isLoading = true;
        try {
            if (this.isValidId(this._attendanceLogId)) {
                await this.loadByLogId(this._attendanceLogId);
            } else if (this.isValidId(this._attendanceId)) {
                const logId = await getAttendanceLogId({
                attendanceId: this._attendanceId
                });
                if (this.isValidId(logId)) {
                await this.loadByLogId(logId);
                }
        }
        } finally {
            this.isLoading = false;
        }
    }

    // LOAD LOGS
    
    async loadByLogId(logId) {
        const logs = await getLogEntries({ attendanceLogId: logId }) || [];
        this.totalHours = this.calculateTotalHours(logs);
        this.pairedLogs = this.buildPairs(logs);
    }

    resetUI() {
        this.totalHours = '--';
        this.pairedLogs = [];
    }

    // --------------------------------------------------
    // HELPERS
    // --------------------------------------------------
    isValidId(val) {
        return typeof val === 'string'
            && (val.length === 15 || val.length === 18)
            && /^[a-zA-Z0-9]+$/.test(val);
    }

    parseTimestamp(raw) {
        const d = new Date(raw);
        return isNaN(d.getTime()) ? null : d;
    }

    formatTime(raw) {
        const d = this.parseTimestamp(raw);
        return d
            ? d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit', hour12: true })
            : '--';
    }

    calculateTotalHours(list) {
        if (!list?.length) return '--';

        let firstIn, lastOut;
        list.forEach(l => {
            const t = this.parseTimestamp(l.timestamp);
            if (!t) return;
            if (l.action === 'Clock In' && (!firstIn || t < firstIn)) firstIn = t;
            if (l.action === 'Clock Out' && (!lastOut || t > lastOut)) lastOut = t;
        });

        if (!firstIn || !lastOut) return '--';

        const diff = lastOut - firstIn;
        const h = Math.floor(diff / 36e5);
        const m = Math.floor((diff % 36e5) / 60000);

        return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')} hrs`;
    }

    buildPairs(list) {
        const rows = [];
        let open = null;

        list.forEach((l, i) => {
            if (l.action === 'Clock In') {
                open = {
                    index: i,
                    date: l.date,
                    clockIn: this.formatTime(l.timestamp)
                };
            }

            if (l.action === 'Clock Out' && open) {
                rows.push({
                    ...open,
                    clockOut: this.formatTime(l.timestamp),
                    status: '✔',
                    statusClass: 'status-success'
                });
                open = null;
            }
        });

        if (open) {
            rows.push({
                ...open,
                clockOut: '—',
                status: '❌',
                statusClass: 'status-error'
            });
        }

        return rows;
    }

    get columns() {
        return [
            { label: 'Date', fieldName: 'date' },
            { label: 'Clock In', fieldName: 'clockIn' },
            { label: 'Clock Out', fieldName: 'clockOut' },
            {
                label: 'Status',
                fieldName: 'status',
                cellAttributes: {
                    alignment: 'center',
                    class: { fieldName: 'statusClass' }
                }
            }
        ];
    }
}