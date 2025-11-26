import { LightningElement } from 'lwc';
import getAccountIMP from '@salesforce/apex/SampleApexLtngWebCmpnt.getAccountIMP';
/*
import Name from '@salesforce/schema/Account.Name';
import AccountNumber from '@salesforce/schema/Account.AccountNumber';
import Phone from '@salesforce/schema/Account.Phone';
import Industry from '@salesforce/schema/Account.Industry';
import Rating from '@salesforce/schema/Account.Rating';*/

const columns = [{label:'Account Name',fieldName:Name},
                 {label:'Account Number',fieldName:AccountNumber},
                 {label:'Phone Number',fieldName:Phone},
                 {label:'Account Industry',fieldName:Industry},
                 {label:'Account Rating',fieldName:Rating}
                
];
export default class DatatablePagenation extends LightningElement {
    columnsList = columns;
    accounts;
    connectedCallback(){
    getAccountIMP().then(result=>{
        this.accounts = result;

    }).catch(error=>{
        console.log('Error:'+error);
    })
}
}