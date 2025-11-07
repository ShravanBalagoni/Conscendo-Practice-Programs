import { LightningElement ,api} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
export default class ContactChildLWCCmp extends LightningElement {
    @api accountId;
    lastName = null;
    phone=null;
    birthdate=null;
    postalcode=null;
    captureData(event){
        const inputName = event.target.name;
        if(inputName==='lname'){
            this.lastName = event.target.value;
        }else  if(inputName==='phone'){
            this.phone = event.target.value;
        }else if(inputName==='birthdate'){
            this.birthdate = event.target.value;
        }else if(inputName==='PostalCode'){
    this.postalcode = event.target.value;
}

    }
    saveRecord(event){
        console.log('Acnt id:'+this.accountid);
        const fields={
            'LastName':this.lastName,
            'Phone':this.phone,
            'Birthdate':this.birthdate,
            'MailingPostalCode':this.postalcode,
            'AccountId':this.accountid
        };
        const recordData = {apiName:'Contact',fields};
        createRecord(recordData).then(response => {
            alert('Record saved...!'+response.id);
            
        }).catch(error => {
           alert('Record failed...!'+error.body.message);
        });
    }
}