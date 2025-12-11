import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getEmployeeStatus from '@salesforce/apex/AttendanceController_ws1.getEmployeeStatus';
import getTodayAttendance from '@salesforce/apex/AttendanceController_ws1.getTodayAttendance';
import getTodayAttendanceFresh from '@salesforce/apex/AttendanceController_ws1.getTodayAttendanceFresh';

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
    isLoading = false;

    connectedCallback() {
        setInterval(() => {
            this.currentTime = new Date().toLocaleTimeString();
        }, 1000);
    }

    // Employee info (Clocked In / Clocked Out)
    @wire(getEmployeeStatus)
    wiredEmployee(result) {
        this.employeeWireData = result;
        if (result.data) {
            this.workStatus = result.data.Work_status__c;
            this.clockInOut = result.data.Clockin_Clockout__c;
        }
    }

    // Today's attendance
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

    // Button label always depends on employee status
    /*get buttonLabel() {
        return this.clockInOut === 'Clocked In' ? 'Clock Out' : 'Clock In';
    }*/ 
   get buttonLabel() {
    if (this.workStatus === 'Holiday') return 'Holiday';
    if (this.showClockIn) return "Clock In";
    if (this.showClockOut) return "Clock Out";
    return "No Action";
}

get isDisabled() {
    return this.isLoading || this.workStatus === 'Holiday';
}


   /* get isDisabled() {
        return this.isLoading;
    }*/

    async handleClockAction() {
        this.isLoading = true;

        try {
            if (this.clockInOut === 'Clocked In') {
                await clockOut();
                this._toast('Success', 'Clock Out recorded', 'success');
            } else {
                await clockIn();
                this._toast('Success', 'Clock In recorded', 'success');
            }

            // Refresh cached wires
            await refreshApex(this.employeeWireData);
            await refreshApex(this.attendanceWireData);

            // Get latest values
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
            }

        } catch (error) {
            this._toast('Error', this._extract(error), 'error');
        }

        this.isLoading = false;
    }

    _extract(error) {
        return error?.body?.message || JSON.stringify(error);
    }

    _toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
