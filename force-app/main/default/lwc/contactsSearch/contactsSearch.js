import { LightningElement,track } from 'lwc';
import getContacts from '@salesforce/apex/searchContacts.getContacts';
export default class ContactsSearch extends LightningElement {

    @track searchKey='';
    @track contacts;
    @track error;
    @track isLoading = false;
    handleKeyChange(event){
        this.searchKey = event.target.value;
    }
    handleSearch(){
        this.isLoading = true;
        getContacts({searchKey:this.searchKey})
        .then(result=>{
            this.contacts = result;
            this.error = undefined;
            console.log('Result:'+this.contacts);
        })
        .catch(error=>{
            this.error = error;
            this.contacts = undefined;
            console.log('Error'+error);
        })
        .finally(()=>{
            this.isLoading =false;
        });
    }
}