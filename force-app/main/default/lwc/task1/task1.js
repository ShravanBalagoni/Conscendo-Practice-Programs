import { LightningElement } from 'lwc';

export default class Task1 extends LightningElement {
    firstName='';
    lastName='';
    emaill;
    phoneno='';
    collectInputs(event){
        const inputName=event.target.name;
        if(inputName==='FName'){
            this.firstName = event.target.value;
            //console.log(event.target.value);
        }else if(inputName==='LName'){
            this.lastName = event.target.value;
           // console.log(event.target.value);
        }else if(inputName==='email'){
            this.emaill = event.target.value;
           // console.log(event.target.value);
        }else if(inputName==='phone'){
            this.phoneno = event.target.value;
           // console.log(event.target.value);
        }
    }
    handleClick(event){
        console.log('First Name:'+this.firstName);
        console.log('Last Name:'+this.lastName);
        console.log('Email:'+this.emaill);
        console.log('Phone:'+this.phoneno);
    }
}