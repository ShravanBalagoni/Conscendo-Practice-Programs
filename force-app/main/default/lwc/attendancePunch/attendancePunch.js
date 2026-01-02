import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEmployeeStatus from '@salesforce/apex/AttendanceController_ws1.getEmployeeStatus';
import getTodayAttendance from '@salesforce/apex/AttendanceController_ws1.getTodayAttendance';
import getTodayAttendanceFresh from '@salesforce/apex/AttendanceController_ws1.getTodayAttendanceFresh';
import getAttendanceLogId from '@salesforce/apex/AttendanceLogController.getAttendanceLogId';
import clockIn from '@salesforce/apex/AttendanceController_ws1.clockIn';
import clockOut from '@salesforce/apex/AttendanceController_ws1.clockOut';
import { refreshApex } from '@salesforce/apex';
export default class AttendancePunch extends LightningElement {

    @track currentTime = '';
    @track clockInTime = '--';
    @track clockOutTime = '--';
    @track totalHours = '--';
    @track workStatus = null;
    @track clockInOut = null;
    attendanceId = null;
    @track attendanceLogId = null; // MUST be declared for reactivity
    employeeWireData;
    attendanceWireData;
    isLoading = false;

    connectedCallback() {
        this.currentTime = new Date().toLocaleTimeString();
        this._interval = setInterval(() => {
            this.currentTime = new Date().toLocaleTimeString();
        }, 1000);
    }

    disconnectedCallback() {
        if (this._interval) {
            clearInterval(this._interval);
            this._interval = null;
        }
    }

    //----------------------------------------
    // Employee Status Wire
    //----------------------------------------
    @wire(getEmployeeStatus)
    wiredEmployee(result) {
        this.employeeWireData = result;

        if (result.data) {
            this.clockInOut = result.data.Clockin_Clockout__c;

            //  No punch yet → show ---
            if (!this.clockInOut) {
                this.workStatus = '---';
            } else {
                this.workStatus = result.data.Work_status__c;
            }
        } else {
            this.workStatus = '---';
            this.clockInOut = null;
        }
    }


    //----------------------------------------
    // Attendance Wire
    //----------------------------------------
    @wire(getTodayAttendance)
    wiredAttendance(result) {
        this.attendanceWireData = result;

        if (result.data) {
            const att = result.data;
            console.group('today attendance', att, result);
            // 1) set attendanceId
            this.attendanceId = att.Id;
            
            // 2) fetch corresponding Attendance_Log__c Id (only when attendanceId exists)
            if (this.attendanceId) {
                getAttendanceLogId({ attendanceId: this.attendanceId })
                    .then(logId => {
                        this.attendanceLogId = logId;
                        
                        console.log('attendanceLogId fetched:', logId);
                    })
                    .catch(err => {
                        // eslint-disable-next-line no-console
                        console.error('Error fetching attendanceLogId', err);
                        this.attendanceLogId = null;
                    });
            } else {
                this.attendanceLogId = null;
            }

            // 3) display times
            this.clockInTime = att.First_Clock_In__c
                ? this._formatTimestamp(att.First_Clock_In__c)
                : '--';

            this.clockOutTime = att.Last_clock_out__c
                ? this._formatTimestamp(att.Last_clock_out__c)
                : '--';

            this._computeTotal(att.First_Clock_In__c, att.Last_clock_out__c);

        } else {
            // Handle error or no attendance
            this.attendanceId = null;
            this.attendanceLogId = null;
            this.clockInTime = '--';
            this.clockOutTime = '--';
            this.totalHours = '--';
        }
    }

    //----------------------------------------
    // Button Label
    //----------------------------------------
    get buttonLabel() {
        return this.clockInOut === 'Clocked In' ? 'Clock Out' : 'Clock In';
    }

    get isDisabled() {
        return this.isLoading;
    }

    //----------------------------------------
    // Handle Clock In / Out
    //----------------------------------------
    async handleClockAction() {
    this.isLoading = true;

    try {
        // 1️⃣ Perform punch
        if (this.clockInOut === 'Clocked In') {
            await clockOut();
            this._toast('Clock Out recorded', 'You have clocked out.', 'error');
        } else {
            await clockIn();
            this._toast('Clock In recorded', 'You have clocked in.', 'success');
        }

        // 2️⃣ Refresh employee + attendance wires
        await refreshApex(this.employeeWireData).catch(() => {});
        await refreshApex(this.attendanceWireData).catch(() => {});

        // 3️⃣ Pull fresh employee
        const freshEmp = await getEmployeeStatus();
        this.clockInOut = freshEmp?.Clockin_Clockout__c ?? this.clockInOut;
        this.workStatus = freshEmp?.Work_status__c ?? this.workStatus;

        // 4️⃣ Pull fresh attendance
        const freshAtt = await getTodayAttendanceFresh();
        if (!freshAtt) return;

        this.attendanceId = freshAtt.Id;

        this.clockInTime = freshAtt.First_Clock_In__c
            ? this._formatTimestamp(freshAtt.First_Clock_In__c)
            : '--';

        this.clockOutTime = freshAtt.Last_clock_out__c
            ? this._formatTimestamp(freshAtt.Last_clock_out__c)
            : '--';

        this._computeTotal(
            freshAtt.First_Clock_In__c,
            freshAtt.Last_clock_out__c
        );

        // 5️⃣ FORCE CHILD LOG TABLE RELOAD 
        if (this.attendanceId) {
            const logId = await getAttendanceLogId({
                attendanceId: this.attendanceId
            });

           const logTable = this.template.querySelector(
        'c-attendance-log-table');
        if (logTable) {
            await logTable.refresh();
        }

        }

        } catch (error) {
            const msg =
                error?.body?.message ||
                error?.message ||
                JSON.stringify(error);
                this._toast('Error', msg, 'error');
        } finally {
            this.isLoading = false;
        }
}


    //----------------------------------------
    // Helpers
    //----------------------------------------
    _computeTotal(startIso, endIso) {
        if (!startIso || !endIso) {
            this.totalHours = '--';
            return;
        }

        const start = this.parseTimestamp(startIso);
        const end = this.parseTimestamp(endIso);

        if (!start || !end || isNaN(start.getTime()) || isNaN(end.getTime()) || end <= start) {
            this.totalHours = '--';
            return;
        }

        const diffMs = end - start;
        const diffHours = diffMs / (1000 * 60 * 60);

        const hrs = Math.floor(diffHours);
        const mins = Math.round((diffHours - hrs) * 60);

        this.totalHours = `${hrs}:${mins.toString().padStart(2, '0')} hrs`;
    }

    // Format for display (tries parseTimestamp first)
    _formatTimestamp(ts) {
        const d = this.parseTimestamp(ts);
        return d ? d.toLocaleTimeString() : String(ts);
    }

    // Tolerant timestamp parser:
    // Accepts: ISO (2025-12-12T09:12:56Z), "MM/dd/yyyy hh:mm a" and "MM/dd/yyyy, hh:mm a"
    parseTimestamp(raw) {
        if (!raw) return null;

        // if already a Date object
        if (raw instanceof Date) return raw;

        // If raw is string - try ISO parse first
        try {
            // Trim
            const s = String(raw).trim();

            // ISO-like (fast path)
            const isoMatch = s.match(/^\d{4}-\d{2}-\d{2}T/);
            if (isoMatch) {
                const d = new Date(s);
                if (!isNaN(d.getTime())) return d;
            }

            // Pattern: "MM/DD/YYYY hh:mm AM/PM" or "MM/DD/YYYY, hh:mm AM/PM"
            const m = s.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4}),?\s+(\d{1,2}):(\d{2})\s*(AM|PM)?$/i);
            if (m) {
                let month = parseInt(m[1], 10);
                let day = parseInt(m[2], 10);
                let year = parseInt(m[3], 10);
                let hour = parseInt(m[4], 10);
                let minute = parseInt(m[5], 10);
                const ampm = (m[6] || '').toUpperCase();

                if (ampm === 'PM' && hour < 12) hour += 12;
                if (ampm === 'AM' && hour === 12) hour = 0;

                // Construct local Date
                const dt = new Date(year, month - 1, day, hour, minute, 0);
                if (!isNaN(dt.getTime())) return dt;
            }

            // Pattern: "MM/DD/YYYY, HH:MM" (24h) or other friendly formats
            const m2 = s.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4}),?\s+(\d{2}):(\d{2})$/);
            if (m2) {
                const month = parseInt(m2[1], 10);
                const day = parseInt(m2[2], 10);
                const year = parseInt(m2[3], 10);
                const hour = parseInt(m2[4], 10);
                const minute = parseInt(m2[5], 10);
                const dt = new Date(year, month - 1, day, hour, minute, 0);
                if (!isNaN(dt.getTime())) return dt;
            }

            // Fallback to Date constructor — sometimes works for "12/12/2025 04:15 PM"
            const fallback = new Date(s);
            if (!isNaN(fallback.getTime())) return fallback;
        } catch (e) {
            // eslint-disable-next-line no-console
            console.warn('parseTimestamp error for', raw, e);
        }

        return null;
    }

    _toast(title, message, variant = 'info') {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
