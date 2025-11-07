import { LightningElement } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';

export default class AccountParentLWCCmp extends LightningElement {
    accountrecordid=null;
    nameVar=null;
    accountNumber=null;
    showchildcmp=false;
    collectInputs(event){
        
    }
}