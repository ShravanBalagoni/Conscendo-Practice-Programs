import { LightningElement ,api} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
export default class ContactChildLWCCmp extends LightningElement {
    @api recordId;
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
    

}