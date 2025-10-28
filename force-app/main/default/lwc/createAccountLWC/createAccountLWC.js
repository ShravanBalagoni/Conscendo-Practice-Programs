import { LightningElement } from 'lwc';
import doCreateAccount from '@salesforce/apex/SampleApexLtngWebCmpnt.doCreateAccount';
export default class CreateAccountLWC extends LightningElement {
    accountNameVar;
    message;
    handleinput(event){
        this.accountNameVar = event.target.value;
    }
    createAccount(event){
        doCreateAccount({acntName:this.accountNameVar}).then(result=>{
            this.message = 'Account Inserted:'+result;
            console.log(this.message+result);
        }).catch(error=>{
            this.message = 'Account Not Inserted:'+error.body.message;
            console.log('Error'+error.body.message);
        })
    }
}