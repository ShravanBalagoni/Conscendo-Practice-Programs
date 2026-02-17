import LightningModal from 'lightning/modal'
import {api} from 'lwc';
import createAccountDecision from '@salesforce/apex/AccountDecisionService.createAccountDecision';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class DecisionModal extends LightningModal {
    @api recordId;
    @api recordLabel;

    options = [
        {id:'Approved', label:' Approved'},
        {id:'Rejected',label:' Rejected'},
        { id: 'Hold', label: ' On Hold' },
        { id: 'Escalated', label: ' Escalated' }
    ];

    userComment = '';
    isLoading = false;

    handleInputChange(event){
        this.userComment = event.target.value;
    }
    handleOptionClick(event){
        const decision = event.target.dataset.id;
        this.submitDecision(decision);
    }

    async submitDecision(decision){
        this.isLoading = true;

        try{
            await createAccountDecision({
                accountId: this.recordId,
                decision: decision,
                comment: this.userComment
            });

            const result = {
                success: true,
                decision: decision,
                comment: this.userComment
            };
            this.close(result);
        }
        catch(error){
            this.dispatchEvent(new ShowToastEvent({
                title:'Error',
                message: error.body.message,
                variant: 'error'
            }));
        } finally{
            this.isLoading = false;
        }
    }
    handleCancel(){
        this.close(null);
    }
}