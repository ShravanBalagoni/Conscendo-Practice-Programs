import { LightningElement } from 'lwc';

export default class ClockTimer extends LightningElement {
    currentTime = '';
    intervalId;

    isClockedIn = false;   // determines button label
    clockInTime = null;
    clockOutTime = null;

    connectedCallback() {
        // live time update
        this.intervalId = setInterval(() => {
            const now = new Date();
            this.currentTime = now.toLocaleTimeString();
        }, 1000);
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

    handleClockAction() {
        const now = new Date().toLocaleTimeString();

        if (!this.isClockedIn) {
            // user is clocking in
            this.clockInTime = now;
            this.isClockedIn = true;
            console.log("Clocked In at:", now);

        } else {
            // user is clocking out
            this.clockOutTime = now;
            this.isClockedIn = false;
            console.log("Clocked Out at:", now);
        }
    }

    get buttonLabel() {
        return this.isClockedIn ? "Web Clock Out" : "Web Clock In";
    }
}
