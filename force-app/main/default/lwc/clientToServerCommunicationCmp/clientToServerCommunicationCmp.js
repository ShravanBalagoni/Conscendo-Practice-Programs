import { LightningElement, wire } from 'lwc';
import getPersonName from '@salesforce/apex/SampleApexLtngWebCmpnt.getPersonName';
import getContacts from '@salesforce/apex/SampleApexLtngWebCmpnt.getContacts';

export default class ClientToServerCommunicationCmp extends LightningElement {

    @wire(getPersonName) personName;

    listOfContacts;

    @wire(getContacts)
    wiredContacts({ error, data }) {
        if (data) {
            this.listOfContacts = data;
        } else if (error) {
            console.error('Error: ' + JSON.stringify(error));
        }
    }
}
