import { LightningElement, wire } from 'lwc';
import getPersonName from '@salesforce/apex/SampleApexLtngWebCmpnt.getPersonName';
import getContacts from '@salesforce/apex/SampleApexLtngWebCmpnt.getContacts';

export default class ClientToServerCommunicationCmp extends LightningElement {
    listofContacts;
   @wire(getPersonName) personName;
   @wire(getContacts) contacts;
    @wire(getContacts) contactsFunction({error,data}){
        if(data){
            this.listofContacts = this.data;
        }
        else if(error){
            console.error('Error:'+error);
        }
    }
}
