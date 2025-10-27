import { LightningElement,wire } from 'lwc';
import getPersonName from '@salesforce/apex/SampleApexLtngWebCmpnt.getPersonName';

export default class ClientToServerCommunicationCmp extends LightningElement {
    @wire (getPersonName) personName;
}