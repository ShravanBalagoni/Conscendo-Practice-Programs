import { LightningElement,api } from 'lwc';

export default class Account_Record_Edit_Form extends LightningElement {
    @api recordId;
    handleSubmitAction(event){
        console.log('--1--onsubmit--');
        event.preventDefaults();
        const fields = event.detail.fields;
        fields.Name = fields.Name+'Shravan LDS Update';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
}