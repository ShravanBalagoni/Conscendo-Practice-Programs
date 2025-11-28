// clockTimer.js
import { LightningElement } from 'lwc';

export default class ClockTimer extends LightningElement {
    currentTime = '';       // state used in template
    intervalId;             // to store timer reference
    handleResize = this.onResize.bind(this);

    connectedCallback() {
        // 1. Start timer when component is inserted into DOM
        this.intervalId = setInterval(() => {
            const now = new Date();
            this.currentTime = now.toLocaleTimeString();
        }, 1000);

        // 2. Add window resize listener (example of external resource / global listener)
        window.addEventListener('resize', this.handleResize);
    }

    renderedCallback() {
        // optional: maybe format or adjust DOM every time render happens,
        // e.g. log or do layout adjustments
        console.log('ClockTimer rendered, time =', this.currentTime);
    }

    disconnectedCallback() {
        // Clean-up: stop timer and remove listener to avoid memory leaks
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
        window.removeEventListener('resize', this.handleResize);
    }

    onResize(event) {
        // Example: on window resize, maybe do something like recalc layout
        console.log('Window resized to', window.innerWidth, 'x', window.innerHeight);
    }
}
