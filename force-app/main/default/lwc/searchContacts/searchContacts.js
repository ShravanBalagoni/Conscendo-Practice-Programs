import { LightningElement,wire,track } from 'lwc';
import getContacts from '@salesforce/apex/SampleApexLtngWebCmpnt.getContacts';
export default class SearchContacts extends LightningElement {
    @track searchKey = '';
    @wire(getContacts,{searchKey:'$searchKey'})
    contacts;
    handleKeyChange(event){
        this.searchKey = event.target.value;
        
    }

}