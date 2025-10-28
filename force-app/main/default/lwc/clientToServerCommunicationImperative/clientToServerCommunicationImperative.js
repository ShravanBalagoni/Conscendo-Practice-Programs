import { LightningElement } from 'lwc';
import getAccountIMP from '@salesforce/apex/SampleApexLtngWebCmpnt.getAccountIMP';
const columns = [
    { label: 'Account Name', fieldName: 'Name' },
    { label: 'Account Industry', fieldName: 'Industry' },
    { label: 'Account Phone', fieldName: 'Phone' },
    { label: 'Account Rating', fieldName: 'Rating' }
];

export default class ClientToServerCommunicationImperative extends LightningElement {
    accounts;
    columnsList = columns;
    fetchAllAccounts(event){
        getAccountIMP().then(result=>{
            this.accounts = result;
            console.log(result);
        }).catch(error=>{
            console.log('Error'+error);
        });
    }
}