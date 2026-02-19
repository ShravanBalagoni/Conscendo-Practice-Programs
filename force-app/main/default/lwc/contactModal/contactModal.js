import { LightningElement,api,track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

import getContactById from '@salesforce/apex/ContactModalController.getContactById';
import createContact from '@salesforce/apex/ContactModalController.createContact';
import updateContact from '@salesforce/apex/ContactModalController.updateContact';
import deleteContact from '@salesforce/apex/ContactModalController.deleteContact';
export default class ContactModal extends LightningElement {
    @api recordId;

    @api 
    get mode(){return this._mode;}
    set mode(val){
        this._mode = val;

        if(val === 'create') this._resetForm();
    }

    @api
    get isOpen(){
        return this._mode;}
    
    set isOpen(val){
        this._isOpen = val;
        val?this._opneModal(): this._closeModal();
    }

    @track isVisible = false;
    @track isAnimating = false;
    @track isLoading = false;
    @track isSubmitting = false;

    @track selectedContact = {};

    @track formData = {
        firstName:'',
        lastName:'',
        email:'',
        phone:'',
        title:'',
        department:'',
        leadSource:''
    };

    @track errors = {lastName: null, email: null};
    _mode = 'create';
    _isOpen = false;
    _wiredContactResult;
    _closeTimer;


    @wire(getContactById,{contactId:'$recordId'})
    wiredContact(result){
        this._wiredContactResult = result;
        const {data,error} = result;

        if(data){
            this.selectedContact = { ...data};

            if(this._mode ==='edit'){
                this._populateForm(data);
            }
            this.isLoading = false;
        }
        if(error){
            this._showToast('Error', error.body.message,'error');
            this.isLoading = false;
        }
    }

    connectedCallback(){
        this._keyHandler = (e)=>{
            if(e.key === 'Escape' && this.isVisible) this.handleClose();
        };
        window.addEventListener('keydown', this._keyHandler);
    }

    disconnectedCallback(){
        window.removeEventListener('keydown',this._keyHandler);
        clearTimeout(this._closeTimer);
    }


    get isViewMode() {return this._mode === 'view';}
    get isCreateMode(){return this._mode === 'create';}
    get isEditMode(){return this._mode ==='edit';}
    get isDeleteMode(){return this._mode === 'delete';}
    get isFormMode(){return this._mode ==='create'||this._mode==='edit';}

    get modalTitle(){
        const titles = {
            create : 'New Contact',
            view   : 'Contact Details',
            edit   : 'Edit Contact',
            delete : 'Delete Contact'
        };
        return titles[this._model] || 'Contact';
    }

    get modalSubtitle(){
        const subtitles = {
            create : 'Fill in the details to create a new Contact',
            view   : `${this.selectedContact.FirstName || ''} ${this.selectedContact.LastName || ''}`.trim(),
            edit   : 'Update the contact information below',
            delete : 'This action is permanent and cannot be undone'
        };
        return subtitles[this._mode] || '';
    }

    get headerIcon(){
        const icons = {
            create : 'utility:new',
            view   : 'standard:contact',
            edit   : 'utility:edit',
            delete : 'utility:delete'
        };
        return icons[this._mode] || 'standard:contact';
    }

    get headerIconClass(){
        return this._mode === 'delete' ? 'modal-icon modal-icon--red'
             : this._mode === 'view'   ? 'modal-icon modal-icon--teal'
             : 'modal-icon modal-icon--blue';
    }

    get backdropClass(){
        
    }

}