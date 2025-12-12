import { LightningElement, api, track } from 'lwc';
import getLogEntries from '@salesforce/apex/AttendanceLogController.getLogEntries';

export default class AttendanceLogTable extends LightningElement {

    @api recordId;
    @track isLoaded = false;
    @track pairedLogs = [];
    @track totalHours = "--";

    connectedCallback() {
        this.loadLogs();
    }

    async loadLogs() {
        try {
            const logs = await getLogEntries({ attendanceLogId: this.recordId }) || [];
            this.totalHours = this.calculateTotalHours(logs);
            this.pairedLogs = this.buildPairs(logs);
            this.isLoaded = true;
            console.log('LOG TABLE RECEIVED recordId:', this.recordId);

        } catch (err) {
            console.error("Error loading logs", err);
            console.log('LOG TABLE RECEIVED recordId:', this.recordId);


        }
    }

    calculateTotalHours(list) {
        if (!list || list.length === 0) return "--";
        let firstIn = null; let lastOut = null;
        list.forEach(item => {
            if (item.action === "Clock In") {
                const dt = new Date(item.timestamp);
                if (!firstIn || dt < firstIn) firstIn = dt;
            }
            if (item.action === "Clock Out") {
                const dt = new Date(item.timestamp);
                if (!lastOut || dt > lastOut) lastOut = dt;
            }
        });
        if (!firstIn || !lastOut) return "--";
        let diffMs = lastOut - firstIn;
        let hrs = Math.floor(diffMs / (1000 * 60 * 60));
        let mins = Math.floor((diffMs / (1000 * 60)) % 60);
        return `${hrs.toString().padStart(2, "0")}:${mins.toString().padStart(2, "0")} hrs`;
    }

    buildPairs(list) {
        const rows = [];
        let current = {};
        list.forEach((log, i) => {
            if (log.action === "Clock In") {
                current = { index: i, date: log.date, clockIn: log.timestamp };
            }
            if (log.action === "Clock Out") {
                current.clockOut = log.timestamp;
                current.arrival = this.computeArrival(current.clockIn);
                current.status = "✔";
                current.statusClass = "status-success";
                rows.push({ ...current });
                current = {};
            }
        });

        if (current.clockIn && !current.clockOut) {
            rows.push({
                index: list.length,
                date: current.date,
                clockIn: current.clockIn,
                clockOut: "—",
                arrival: "—",
                status: "Missing Clock Out",
                statusClass: "status-error"
            });
        }
        return rows;
    }

    computeArrival(clockInTimestamp) {
        const time = new Date(clockInTimestamp);
        const officeStart = new Date(time);
        officeStart.setHours(9, 0, 0, 0);
        if (time <= officeStart) return "On Time";
        let diffMs = time - officeStart;
        let mins = Math.floor(diffMs / (1000 * 60));
        let hrs = Math.floor(mins / 60); mins = mins % 60;
        return `${hrs > 0 ? hrs + "h " : ""}${mins}m late`;
    }

    get columns() {
        return [
            { label: "Date", fieldName: "date", type: "text", cellAttributes: { class: "cell-center" } },
            { label: "Clock In", fieldName: "clockIn", type: "text", cellAttributes: { class: "cell-center" } },
            { label: "Clock Out", fieldName: "clockOut", type: "text", cellAttributes: { class: "cell-center" } },
            {
                label: "Status",
                fieldName: "status",
                type: "text",
                cellAttributes: { class: { fieldName: "statusClass" }, alignment: "center" }
            }
        ];
    }
}
