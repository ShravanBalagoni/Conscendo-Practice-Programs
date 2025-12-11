import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getEmployeeStatus from '@salesforce/apex/AttendanceController_ws1.getEmployeeStatus';
import getTodayAttendance from '@salesforce/apex/AttendanceController_ws1.getTodayAttendance';
import getTodayAttendanceFresh from '@salesforce/apex/AttendanceController_ws1.getTodayAttendanceFresh';
import getPunchStatus from '@salesforce/apex/AttendanceController_ws1.getPunchStatus';

import clockIn from '@salesforce/apex/AttendanceController_ws1.clockIn';
import clockOut from '@salesforce/apex/AttendanceController_ws1.clockOut';

import { refreshApex } from '@salesforce/apex';

export default class AttendancePunch extends LightningElement {

    @track currentTime = '';
    @track clockInTime;
    @track clockOutTime;
    @track workStatus;

    @track showClockIn = false;
    @track showClockOut = false;

    employeeWireData;
    attendanceWireData;

    isLoading = false;

    connectedCallback() {
        setInterval(() => {
            this.currentTime = new Date().toLocaleTimeString();
        }, 1000);

        this.loadPunchStatus();
    }

    // Employee status
    @wire(getEmployeeStatus)
    wiredEmployee(result) {
        this.employeeWireData = result;
        if (result.data) {
            this.workStatus = result.data.Work_status__c;
        }
    }

    // Attendance record
    @wire(getTodayAttendance)
    wiredAttendance(result) {
        this.attendanceWireData = result;

        if (result.data) {
            const att = result.data;

            this.clockInTime = att.First_Clock_In__c
                ? new Date(att.First_Clock_In__c).toLocaleTimeString()
                : null;

            this.clockOutTime = att.Last_clock_out__c
                ? new Date(att.Last_clock_out__c).toLocaleTimeString()
                : null;
        }
    }

    // NEW: Load punch status manually (fixes “Completed” bug)
    async loadPunchStatus() {
        try {
            const ps = await getPunchStatus();
            this.showClockIn = ps.showClockIn;
            this.showClockOut = ps.showClockOut;
        } catch (err) {
            console.error('Punch status error:', err);
        }
    }

    // Button label logic
    get buttonLabel() {
        if (this.workStatus === "Holiday") return "Holiday";
        if (this.showClockIn) return "Clock In";
        if (this.showClockOut) return "Clock Out";
        return "Completed";
    }

    get isDisabled() {
        return this.isLoading || this.workStatus === "Holiday";
    }

    async handleClockAction() {
        this.isLoading = true;

        try {
            if (this.showClockIn) {
                await clockIn();
                this._toast('Success', 'Clock In recorded', 'success');
            } else if (this.showClockOut) {
                await clockOut();
                this._toast('Success', 'Clock Out recorded', 'success');
            }

            // Refresh employee & attendance wires
            await refreshApex(this.employeeWireData);
            await refreshApex(this.attendanceWireData);

            // Fresh attendance
            const freshAtt = await getTodayAttendanceFresh();
            if (freshAtt) {
                this.clockInTime = freshAtt.First_Clock_In__c
                    ? new Date(freshAtt.First_Clock_In__c).toLocaleTimeString()
                    : null;

                this.clockOutTime = freshAtt.Last_clock_out__c
                    ? new Date(freshAtt.Last_clock_out__c).toLocaleTimeString()
                    : null;
            }

            // Reload punch status (THIS FIXES YOUR ISSUE)
            await this.loadPunchStatus();

        } catch (err) {
            this._toast("Error", this._extract(err), "error");
        }

        this.isLoading = false;
    }

    _extract(error) {
        return error?.body?.message || JSON.stringify(error);
    }

    _toast(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message: msg, variant }));
    }
}
