import { LightningElement,api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
export default class ContactDeleteLDS extends LightningElement {
    @api recordId;
    performDeleteRecord(event){
        deleteRecord(this.recordId).then(response=>{
            alert('Record Deleted....!'+response);
        }).catch(error=>{
            alert('Record Not Deleted.....! '+error.body.message);
        });
    }
}