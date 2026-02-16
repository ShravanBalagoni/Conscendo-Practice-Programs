import { LightningElement, track } from 'lwc';
import getContactsPg from '@salesforce/apex/searchContacts.getContactsPg';

export default class PaginationCmp extends LightningElement {
    @track contacts = [];
    @track isLoading = false;
    
    pageNumber = 3;
    pageSize = 10;

    // ✅ Datatable columns - PERFECT syntax
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' }
    ];

    connectedCallback() {
        this.loadPage();
    }

    loadPage() {
        this.isLoading = true;
        getContactsPg({ pageNumber: this.pageNumber, pageSize: this.pageSize })
            .then(result => {
                this.contacts = result || [];
                console.log('Loaded page:', this.pageNumber, 'Contacts:', this.contacts.length);
            })
            .catch(error => {
                console.error('Error:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // ✅ GETTERS - Move ALL logic here (LWC HTML requirement)
    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.contacts.length < this.pageSize;
    }

    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }

    goPrevious() {
        if (!this.isFirstPage) {
            this.pageNumber--;
            this.loadPage();
        }
    }

    goNext() {
        if (!this.isLastPage) {
            this.pageNumber++;
            this.loadPage();
        }
    }
}
