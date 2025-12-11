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
    @track clockInOut;
    attendanceId;

    employeeWireData;
    attendanceWireData;
    punchStatusWireData;

    isLoading = false;

    // UI flags derived from attendance fields (source of truth)
    @track showClockIn = false;
    @track showClockOut = false;

    connectedCallback() {
        setInterval(() => {
            this.currentTime = new Date().toLocaleTimeString();
        }, 1000);
    }

    // Employee info (Work status and last action)
    @wire(getEmployeeStatus)
    wiredEmployee(result) {
        this.employeeWireData = result;
        if (result.data) {
            this.workStatus = result.data.Work_status__c;
            this.clockInOut = result.data.Clockin_Clockout__c;
        }
    }

    // Attendance (cached)
    @wire(getTodayAttendance)
    wiredAttendance(result) {
        this.attendanceWireData = result;

        if (result.data) {
            const att = result.data;
            this.attendanceId = att.Id;

            this.clockInTime = att.First_Clock_In__c
                ? new Date(att.First_Clock_In__c).toLocaleTimeString()
                : null;

            this.clockOutTime = att.Last_clock_out__c
                ? new Date(att.Last_clock_out__c).toLocaleTimeString()
                : null;
        }
    }

    // Punch status (cacheable) - authoritative source for which button to show
    @wire(getPunchStatus)
    wiredPunchStatus(result) {
        this.punchStatusWireData = result;
        if (result.data) {
            this.showClockIn = result.data.showClockIn;
            this.showClockOut = result.data.showClockOut;
        } else {
            // fallback: hide both if no data
            this.showClockIn = false;
            this.showClockOut = false;
        }
    }

    get buttonLabel() {
        if (this.showClockIn) return "Clock In";
        if (this.showClockOut) return "Clock Out";
        return "No Action";
    }

    get isDisabled() {
        return this.isLoading;
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
            } else {
                this._toast('Info', 'No action available', 'info');
            }

            // Refresh all relevant data
            try {
                await refreshApex(this.employeeWireData);
            } catch (e) { /* ignore refresh errors */ }

            try {
                await refreshApex(this.attendanceWireData);
            } catch (e) { /* ignore refresh errors */ }

            try {
                await refreshApex(this.punchStatusWireData);
            } catch (e) { /* ignore refresh errors */ }

            // Ensure latest fresh values (non-cacheable)
            const freshEmp = await getEmployeeStatus();
            this.clockInOut = freshEmp?.Clockin_Clockout__c;
            this.workStatus = freshEmp?.Work_status__c;

            const freshAtt = await getTodayAttendanceFresh();
            if (freshAtt) {
                this.attendanceId = freshAtt.Id;
                this.clockInTime = freshAtt.First_Clock_In__c
                    ? new Date(freshAtt.First_Clock_In__c).toLocaleTimeString()
                    : null;
                this.clockOutTime = freshAtt.Last_clock_out__c
                    ? new Date(freshAtt.Last_clock_out__c).toLocaleTimeString()
                    : null;
            } else {
                this.attendanceId = undefined;
                this.clockInTime = null;
                this.clockOutTime = null;
            }

            // update punch flags one more time from server
            const ps = await getPunchStatus();
            this.showClockIn = ps?.showClockIn || false;
            this.showClockOut = ps?.showClockOut || false;

        } catch (error) {
            this._toast('Error', this._extract(error), 'error');
        }

        this.isLoading = false;
    }

    _extract(error) {
        try {
            return error?.body?.message || JSON.stringify(error);
        } catch (e) {
            return 'Unknown error';
        }
    }

    _toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
