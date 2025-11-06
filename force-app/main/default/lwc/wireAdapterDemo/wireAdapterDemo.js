import { LightningElement,wire,api } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
//import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
//import ACCOUNT_PHONE from '@salesforce/schema/Account.Phone';
export default class WireAdapterDemo extends LightningElement {
  @api recordId;
  @wire(getRecord,{recordId:'$recordId',fields:['Account.Name','Account.Phone']}) record;

  get name(){
    return this.record.data?getFieldValue(this.record.data,'Account.Name'):'';
  }
  get phone(){
    return this.record.data?getFieldValue(this.record.data,'Account.Phone'):'';
  }
}
