import { LightningElement, track } from 'lwc';
import getBoredApis from '@salesforce/apex/BoredAPIController.getBoredApis';

export default class BoredApi extends LightningElement {
    @track data;
    @track error;
    @track isLoading = false;

    handleFetch() {
        // when button is clicked, fetch new data
        this.fetchData();
    }

    fetchData() {
        this.isLoading = true;
        this.error = undefined;
        getBoredApis()
            .then((result) => {
                this.data = result;
                this.error = undefined;
            })
            .catch((err) => {
                // parse the error
                this.error = (err && err.body && err.body.message) ? err.body.message : JSON.stringify(err);
                this.data = undefined;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    connectedCallback() {
        // Optionally fetch one when the component loads
        this.fetchData();
    }
}
