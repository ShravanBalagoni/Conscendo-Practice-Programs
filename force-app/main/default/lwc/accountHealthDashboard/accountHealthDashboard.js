import { LightningElement,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import DecisionModal from 'c/decisionModal';
import {RefreshEvent} from 'lightning/refresh';
export default class AccountHealthDashboard extends LightningElement {
    @api recordId;
    showSuccessMessage = false;
    successText = '';

    @wire(getRecord, {
        recordId: '$recordId',
        fields: ['Account.Name','Account.AccountNumber']
    }) account;

    get accountName(){
        return this.account.data?.fields?.Name?.value || 'Loading...';
    }

    async handleRecordDecision(){
        try{
            const result = await DecisionModal.open({
                size: 'large',
                recordId: this.recordId,
                recordLabel: this.accountName
            });

            if(result){
                this.successText = `Decision "${result.decision}" recorded for ${this.accountName}`;
                this.showSuccessMessage = true;

                this.dispatchEvent(new RefreshEvent());
                setTimeout(()=>{
                    this.showSuccessMessage = false;
                },5000);
            }
        } catch(error){
            console.error('Decision modal error:',error);
        }
    }
}