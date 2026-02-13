import { LightningElement, track } from 'lwc';
import getContactsPg from '@salesforce/apex/searchContacts.getContactsPg';
export default class PaginationCmp extends LightningElement {
    @track searchKey = '';
    @track contacts =[];
    @track pageNumber = 1;

    handleKeyChange(event){
        this.searchKey = event.target.value;
    }

    handleSearch(){
        this.pageNumber = 1;
        this.searchPage();
    }

    searchPage(){
        getContactsPg({searchKey:this.searchKey,pageNumber:this.pageNumber})
        .then(result=>{
            this.contacts = result.contacts;
            console.log('Page', this.pageNumber,':',this.contacts);
        })
        .catch(error=>{
            console.error('Error:',error);
        });
    }

    goNext(){
        this.pageNumber++;
        this.searchPage();
    }

    goPrevious(){
        if(this.pageNumber > 1){
            this.pageNumber--;
            this.searchPage();
        }
    }

}