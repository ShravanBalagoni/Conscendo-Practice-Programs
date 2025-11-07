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
    } else if(inputName==='AccountNumber'){
        this.accountNumber=event.target.value;
    }
  }
  saveAccountRecords(event){
    console.log('The Button Process is Activated');
    const fields={'Name':this.nameVar,
                    'AccountNumber':this.accountNumber
    }
    const inputRecord={apiName:'Account',fields};
    createRecord(inputRecord).then(response=>{
        this.accountrecordid=response.id;
        this.showchildcmp=true;
    }).catch(error=>{
        console.error('Error creating account:', error);
        alert('Error creating account: ' + error.body.message);
    })
  }
}
