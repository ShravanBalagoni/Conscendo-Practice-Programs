import { LightningElement,wire,track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

const columnsList = [
    {label:'Name',fieldName:'Name',editable:true},
    {label:'Phone',fieldName:'Phone',type:'phone',editable:true},
    {
        label: 'Type',
        fieldName: 'Type',
        type:'customPicklist',
        editable:true,
        typeAttributes:{
            options: {fieldName:'picklistOptions'},
            value: {fieldName:'Type'},
            context: {fieldName:'Id'}
        }
    }
];
export default class MyDataTable extends LightningElement {
    columns = columnsList;
    @track accountsData = [];
    @track draftValues = [];
    wiredAccountsResult;
    typePicklistOptions = [];
    defaultRecordTypeId;

    get displayData(){
        if(!this.accountsData?.length || !this.typePicklistOptions.length){
            return [];
        }
        return this.accountsData.map(account=>({
            ...account,
            picklistOptions: this.typePicklistOptions
        }));
    }

    @wire(getAccounts)
    wiredAccounts(result){
        this.wiredAccountsResult = result;
        const {data,error} = result;
        if(data){
            this.accountsData = data;
            console.log('Accounts Loaded:',data.length);
        }
        else if(error){
            console.error('Accounts error:',error);
        }
    }

    @wire(getObjectInfo,{objectApiName: ACCOUNT_OBJECT})
    objectInfo({data,error}){
        if(data){
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        }
    }

    @wire(getPicklistValues,{
        recordTypeId: '@defaultRecordTypeId',
        fieldApiName: TYPE_FIELD
    })
    wirePicklist({data,error}){
        if(data){
            this.typePicklistOptions = data.values;
        }
    }


    async handleSave(event){
        const records = event.detail.draftValues.map(record=>({
            fields:{Id:record.Id, ...record}
        }));
        this.draftValues = [];
        try{
            await Promise.all(records.map(updateRecord));
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',message:'Records updated!', variant:'success'
            }));
            await refreshApex(this.wiredAccountsResult);
        } catch(error){
            console.error('Save error:',error);
        }
    }
}