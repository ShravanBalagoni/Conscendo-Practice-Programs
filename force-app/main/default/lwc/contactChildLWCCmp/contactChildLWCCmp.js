import { LightningElement ,api} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
export default class ContactChildLWCCmp extends LightningElement {
    @api accountId;
    lastName = null;
    
    phone=null;
    birthDate=null;
    postalCode=null;
    captureData(event){
        const inputName=event.target.name;
        if(inputName==='lname'){
            this.lastName=event.target.value;
        } else if(inputName==='phone'){
            this.phone=event.target.value;
        }else if(inputName==='birthdate'){
            this.birthDate=event.target.value;
        }else if(inputName==='PostalCode'){
            this.postalCode=event.target.value;
        }
    }
    saveRecord(event){
        console.log('Account Id:',this.accountId);
        const fields={
            'LastName':this.lastName,
            'Phone':this.phone,
            'Birthdate':this.birthDate,
            'MailingPostalCode':this.postalCode,
            'AccountId':this.accountId
        }
        const inputRecord={apiName:'Contact',fields};
        createRecord(inputRecord).then(response=>{
            alert('Record Saved:'+response.id);
        }).catch(error=>{
            alert('Record Not Saved:+error.body.message');
        })
    }

}