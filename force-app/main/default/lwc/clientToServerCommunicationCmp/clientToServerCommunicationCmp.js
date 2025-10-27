import { LightningElement, wire } from 'lwc';
import getPersonName from '@salesforce/apex/SampleApexLtngWebCmpnt.getPersonName';
import getContacts from '@salesforce/apex/SampleApexLtngWebCmpnt.getContacts';

export default class ClientToServerCommunicationCmp extends LightningElement {
   @wire(getPersonName) personName;
   listofContacts;
   @wire(getContacts) contacts;
   @wire(getContacts) contactsFunction({error,data}){
    if(data){
        this.listofContacts = data;
    }
    else if(error){
        console.error('Error:'+error);
    }
   }
}
