import { LightningElement } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import insertAccount from '@salesforce/apex/AccountController.insertAccount';
import updateAccount from '@salesforce/apex/AccountController.updateAccount';
export default class Task2Adv extends LightningElement {
    accountName='';
    accountNumber='';
    billingAddress='';
    description='';
    accountId=null;
    successMessage='';
    errorMessage='';
    handleNameChange(event){
        this.accountName=event.target.value;
        this.clearMessages();
    }
    handleNumberChange(event){
        const value = event.target.value;
        if(value && value.length>5){
            this.errorMessage='Account Number cannot exceed 5 digits';
            this.accountNumber=value.substring(0,5);
        }else{
            this.accountNumber=value;
            this.clearMessages();
        }
    }
    handleBillingAddressChange(event){
        this.billingAddress=event.target.value;
        this.clearMessages();
    }
    handleDescriptionChange(event){
        this.description=event.target.value;
        this.clearMessages();
    }
    get isSubmitDisabled(){
        return !this.accountName||
                this.accountName.length<4||
                this.accountName.length>15||
                (this.accountNumber&&this.accountNumber.length>5);
    }
    handleSubmit(event){
        this.clearMessages();
        if(this.accountName.length<4 || this.accountName.length>15){
            this.errorMessage='Account Name must be between 4 and 15 characters';
            return;
        }
        if(this.accountNumber&&this.accountNumber.length>5){
            this.errorMessage='Account Number cannot exceed 5 digits';
            return;
        }
        const accountData={
            accountName:this.accountName,
            accountNumber:this.accountNumber,
            billingAddress:this.billingAddress,
            description:this.description
        };
        if(this.accountId){
            this.updateAccountRecord(accountData);
        }else{
            this.insertAccountRecord(accountData);
        }
}
        insertAccountRecord(accountData){
            insertAccount(accountData)
            .then(result=>{
                this.accountId=result.Id;
                this.successMessage='Account Created Successfully!ID:'+result.Id;
            }).catch(error=>{
                this.errorMessage = 'Error creating account:'+this.reduceErrors(error);
                this.showToast('Error',this.errorMessage,'error');
            });

        }
        updateAccountRecord(accountData) {
        accountData.accountId = this.accountId;
        updateAccount(accountData)
        .then(result => {
        this.successMessage = 'Account updated successfully!';
        this.showToast('Success', 'Account updated successfully!', 'success');
        })
        .catch(error => {
        this.errorMessage = 'Error updating account: ' + this.reduceErrors(error);
        this.showToast('Error', this.errorMessage, 'error');
        });
        }
        handleReset(){
            this.accountName='';
            this.accountNumber='';
            this.billingAddress='';
            this.description='';
            this.clearMessages();
        }
        clearMessages(){
            this.successMessage='';
            this.errorMessage='';
        }
        showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  reduceErrors(error) {
    if (error.body) {
      if (Array.isArray(error.body)) {
        return error.body.map(e => e.message).join(', ');
      } else if (error.body.message) {
        return error.body.message;
      }
    }
    return 'Unknown error';
  }


}