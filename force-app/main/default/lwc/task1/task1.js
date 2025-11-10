import { LightningElement } from 'lwc';
import FIRST_NAME from '@salesforce/schema/Contact.FirstName';
import LAST_NAME from '@salesforce/schema/Contact.LastName';
import  EMAIL from '@salesforce/schema/Contact.Email';
import PHONE from '@salesforce/schema/Contact.Phone';
export default class Task1 extends LightningElement {
    collectInputs(event){
        const inputName=event.target.name;
        if(inputName==='FName'){
            this.FIRST_NAME = event.target.value;
            //console.log(event.target.value);
        }else if(inputName==='LName'){
            this.LAST_NAME = event.target.value;
           // console.log(event.target.value);
        }else if(inputName==='email'){
            this.EMAIL = event.target.value;
           // console.log(event.target.value);
        }else if(inputName==='phone'){
            this.PHONE = event.target.value;
           // console.log(event.target.value);
        }
    }
    handleClick(event){
        console.log('First Name:'+FIRST_NAME);
        console.log('Last Name:'+LAST_NAME);
        console.log('Email:'+EMAIL);
        console.log('Phone:'+PHONE);
    }
}