import { LightningElement,wire,track,api } from 'lwc';
import getContacts from '@salesforce/apex/accFetchClass.getContacts';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import LEAD_SOURCE from '@salesforce/schema/Contact.LeadSource';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
//import LeadSource from '@salesforce/schema/Contact.LeadSource';
const columnsList = [ {label:'FirstName',fieldName:'FirstName',editable: true},
                    {label:'LastName',fieldName:'LastName',editable: true},
                    {label:'Title',fieldName:'Title',editable: true},
                    {label:'Phone',fieldName:'Phone',type:'phone',editable: true},
                   {label:'Email',fieldName:'Email',type:'email',editable: true},
                    {
                        label: 'Lead Source',
                        fieldName: 'LeadSource',
                        type: 'customPicklist',   
                        editable: true,
                        typeAttributes: {
                         options: { fieldName: 'pickListOptions' },
                         value: { fieldName: 'LeadSource' },
                         context: { fieldName: 'Id' }
        }
    }
                    ];
export default class EditDataTableRows extends LightningElement {
    @api recordId;
    columns = columnsList;
    @track draftValues=[];
    contactsData;
    leadSourceOptions;
    contactRefreshProp
    defaultRecordTypeId
    get displayData(){
        if(!this.contactsData?.length || !this.leadSourceOptions.length){
            return [];
        }
    

    return this.contactsData.map(item=>({
        ...item,
        pickListOptions:this.leadSourceOptions
    }));
    }

    @wire(getContacts,{accId:'$recordId'})
    wiredContacts(result){
        this.contactRefreshProp = result;
        const{data,error} = result;
        if(data){
            this.contactsData = data;
        } else if (error){
            console.error('Error loading contacts', error);
        }
    }

    @wire(getObjectInfo,{objectApiName:CONTACT_OBJECT}) 
    objectInfo({data,error}){
        if(data){
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if(error){
            console.error('objectInfo error',error);
        }
    }

    @wire(getPicklistValues,{
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: LEAD_SOURCE
    })

    wirePicklist({error,data}){
        if(data){
            this.leadSourceOptions = data.values;
        }else if(error){
            console.error('Picklist error',error);
        }
    }

    async handleSave(event){
        let records = event.detail.draftValues;
        const UpdateRecordArray = records.map(record=>({
            fields:{
                Id:record.Id,
                LeadSource: record.LeadSource
            }
        }));
        this.draftValues = [];

        try{
            const UpdateRecordsPromise = UpdateRecordArray.map((currentItem)=>
            updateRecord(currentItem));
            await Promise.all(UpdateRecordsPromise);
            const toastevent = new ShowToastEvent({
                title: 'Success!',
                message:'Record Created!',
                variant:'success'
            });
            this.dispatchEvent(toastevent);
            await refreshApex(this.contactRefreshProp);
        }
        catch(error){
            console.error('Error updating the records ',error);
        }
    }
}