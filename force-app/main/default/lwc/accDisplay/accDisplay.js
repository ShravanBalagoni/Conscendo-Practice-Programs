import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/accFetchClass.getAccounts';

export default class AccDisplay extends LightningElement {
    accounts;
    errors;

    columnsList = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' }
    ];

    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
            this.errors = undefined;
        } else if (error) {
            // error.body.message is a string, not a function
            this.errors = (error && error.body && error.body.message) ? error.body.message : 'Unknown error';
            this.accounts = undefined;
        }
    }
}
