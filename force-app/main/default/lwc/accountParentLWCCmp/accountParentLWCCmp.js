import { LightningElement } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';

export default class AccountParentLWCCmp extends LightningElement {
    accountrecordid=null;
    nameVar=null;
    accountNumber=null;
    showchildcmp=false;
    collectInputs(event){
        const inputName = event.target.name;
        if(inputName==='AccountName'){
            this.nameVar=event.target.value;
        }else if(inputName==='AccountNumber'){
            this.accountNumber=event.target.value;
        }
    }
}