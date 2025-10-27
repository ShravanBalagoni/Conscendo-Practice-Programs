import { LightningElement,wire } from 'lwc';
import getPersonName from '@salesforce/apex/SampleApexLtngWebCmpnt.getPersonName';
import getContacts from '@salesforce/apex/SampleApexLtngWebCmpnt.getContacts';

export default class ClientToServerCommunicationCmp extends LightningElement {
    @wire (getPersonName) personName;
    listOfContacts;
    @wire(getContacts) contacts;
}