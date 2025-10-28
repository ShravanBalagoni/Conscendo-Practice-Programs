import { LightningElement } from 'lwc';
import getAccountIMP from '@salesforce/apex/SampleApexLtngWebCmpnt.getAccountIMP';
const columns = [{label:'Account Name',fieldName:'Name'},
                  {label:'Account Phone',fieldName:'Phone'},
                  {label:'Account Rating',fieldName:'Rating'},
                  {label:'Account Industry',fieldName:'Industry'}  
];
export default class ClientToServerCommunicationImperative extends LightningElement {
    accounts;
    columnsList=columns;
    fetchAllAccounts(event){
        getAccountIMP().then(result=>{
            this.accounts = result;
        }).catch(error=>{
            console.log('ERROR:'+error);
        })
    }
}