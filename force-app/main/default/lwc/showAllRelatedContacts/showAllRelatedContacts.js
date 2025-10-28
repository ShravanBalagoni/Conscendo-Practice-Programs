import { LightningElement,wire,api } from 'lwc';
import getrelatedContacts from '@salesforce/apex/relatedContactsApex.getrelatedContacts';

export default class ShowAllRelatedContacts extends LightningElement {
    @api recordId;
    relContacts;
    @wire(getrelatedContacts,{accountId:'$recordId'})
    wiredData({error,data}){
        if(data){
            console.log('DATA:',data);
            this.relContacts = data;
        }
        else if(error){
            console.error('Error:',error);
        }
    }


}