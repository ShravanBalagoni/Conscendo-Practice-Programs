import { LightningElement,track } from 'lwc';
import getAccounts from '@salesforce/apex/searchAccounts.getAccounts';
export default class SearchAccounts extends LightningElement {
    @track accounts;
    @track searchKey='';
    @track errors;
    @track isLoading = false;

    handleChange(event){
        this.searchKey = event.target.value;
    }
    handleClick(){
        this.isLoading = true;
        getAccounts({searchKey:this.searchKey})
        .then(result=>{
            this.accounts = result;
            this.errors = undefined;
            console.log('Data:', JSON.stringify(result));
        })
        .catch(error=>{
            this.errors= error;
            this.accounts = undefined;
            console.log('Error:'+error);
        })
        .finally(()=>{
            this.isLoading = false;
        })
    }

}