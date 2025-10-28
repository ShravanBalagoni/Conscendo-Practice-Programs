import { LightningElement,wire,api } from 'lwc';
import getRelatedContacts from '@salesforce/apex/relatedContactsApex.getRelatedContacts';

export default class ShowAllRelatedContacts extends LightningElement {
    @api recordId;
    relatedContacts;
    @wire(getRelatedContacts,{accountIdVar:'$recordId'})
    wiredData({error,data}){
        if(data){
            this.relatedContacts=data;
        }
        else if(error){
            console.error('Error:'+error);
        }
    }



}