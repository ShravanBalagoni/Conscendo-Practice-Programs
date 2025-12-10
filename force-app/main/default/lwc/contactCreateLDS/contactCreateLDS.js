 import { LightningElement,api } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
export default class ContactCreateLDS extends LightningElement {
    lastName=null;
    phone=null;
    birthdate=null;
    postalcode=null;
    @api recordId;
    captureData(event){
        const inputTagName=event.target.name;
        if(inputTagName==='lname'){
            this.lastName=event.target.value;
        }
        else if(inputTagName==='phn'){
            this.phone=event.target.value;
        }
        else if(inputTagName==='bDate'){
            this.birthdate=event.target.value;
        }
        else if(inputTagName==='pCode'){
            this.postalcode=event.target.value;
        }
    }
    handleTosaveContact(event){
        const fields = {'LastName':this.lastName,
                        'Phone':this.phone,
                        'Birthdate':this.birthdate,
                        'MailingPostalCode':this.postalcode,
                        'AccountId':this.recordId
        };
        const recordData = {apiName:'contact',fields};
        createRecord(recordData).then(response=>{
            alert('Record Saved....! '+response.id);
        }).catch(error=>{
            alert('Record Not Saved..! '+error.body.message);
        });
    }

}