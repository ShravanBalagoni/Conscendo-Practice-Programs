import { LightningElement,wire,api } from 'lwc';
import getContacts from '@salesforce/apex/accFetchClass.getContacts';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
const columnsList = [
                    {label:'FirstName',fieldName:'FirstName',editable: true},
                    {label:'LastName',fieldName:'LastName',editable: true},
                    {label:'Title',fieldName:'Title',editable: true},
                    {label:'Phone',fieldName:'Phone',type:'phone',editable: true},
                    {label:'Email',fieldName:'Email',type:'email',editable: true}
];
export default class EditDataTable extends LightningElement {
    @api recordId;
    contactsData;
    columns = columnsList;
    draftValues;
    contactRefreshProp;
    error;
    @wire(getContacts,{accId:'$recordId'}) 
    wiredContacts(result){
        this.contactRefreshProp = result;
        const {data,error} = result;
        if(data){
            this.contactsData = data;
            console.log('Contacts Loaded:'+data.length);
        } else if (error){
            console.log(error+'error loading the contacts');
        }
    }
    async handleSave(event){
        let records = event.detail.draftValues;
        const updateRecordArray = records.map((currentItem)=>{
            const fieldInput = {...currentItem};
            return{
                fields:fieldInput
            };
        });
        this.draftValues = [];
        try{
            const updateRecordsPromise = updateRecordArray.map((currentItem)=>
            updateRecord(currentItem));
            await Promise.all(updateRecordsPromise);
            const toastevent = new ShowToastEvent({
                title:'Success!',
                message:'Record created!',
                variant:'success'
            });
            this.dispatchEvent(toastevent);
            await refreshApex(this.contactRefreshProp);
        }
        catch(error){
            console.error('Error updating the records',error);
        }

    }
}