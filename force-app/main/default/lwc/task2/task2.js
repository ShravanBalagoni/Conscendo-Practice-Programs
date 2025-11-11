import { LightningElement,api } from 'lwc';
import insertAccount from '@salesforce/apex/AccountController.insertAccount';
/*
import Name from '@salesforce/schema/Account.Name';
import AccountNumber from '@salesforce/schema/Account.AccountNumber';
import Phone from '@salesforce/schema/Account.Phone';
import BillingAddress from '@salesforce/schema/Account.BillingAddress';
import Description from '@salesforce/schema/Account.Description';*/
export default class Task2 extends LightningElement {
    @api recordId;
    accountName;
    accountNumber;
    billingAddress;
    description;
    collectInputs(event){
        const inputName = event.target.name;
        if(inputName==='AccName'){
            this.accountName=event.target.value;
        }else if(inputName==='AccNumber'){
            this.accountNumber=event.target.value;
        }else if(inputName==='BillingAddress'){
            this.billingAddress=event.target.value;
        }else if(inputName==='Description'){
            this.description=event.target.value;
        }
    }
    handleSubmit(event){
        if(this.accountName.length<4 || this.accountName.length>15){
            alert('The Account Name should be minimum of 4 and maximum of 15 characters');
            return;
        }
        if(this.accountNumber>99999){
            alert('The Account Number should not be more than 5 characters');
            return;
        }
        insertAccount({
            acct:{
                Name:this.accountName,
                AccountNumber:this.accountNumber,
                BillingAddress:this.billingAddress,
                Description:this.description,
                Id:this.recordId
            }
        }).then(result=>{
            alert('Record Created:'+result);
            if(!this.recordId){
            this.accountName='';
            this.accountNumber=null;
            this.billingAddress='';
            this.description='';
            }
        })
        .catch(error=>{
            console.log('Error creating the record:'+error.body.message);
        })

    }
}
/*Create a form 
holding below fields
Collect the Account Object fields in ones own developer org. ( Assuming everyone have their own developer org for practice)
Account Object fields like
Account name,  Validation criteria Name must be minimum of 4 characters and should not allow more than 15characters.
Account Number  Number validation should not be more than 5 digits.
Billing Address  Text area.
Description  Text area.
Submit button  With brand color.*/ 