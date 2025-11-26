import { LightningElement } from 'lwc';
import getAccountIMP from '@salesforce/apex/SampleApexLtngWebCmpnt.getAccountIMP';

const columns = [{label:'Account Name',fieldName:'Name'},
                 {label:'Account Number',fieldName:'AccountNumber'},
                 {label:'Phone Number',fieldName:'Phone'},
                 {label:'Account Industry',fieldName:'Industry'},
                 {label:'Account Rating',fieldName:'Rating'}
                
];
export default class DatatablePagenation extends LightningElement {
    columnsList = columns;
    accounts = [];
    paginatedAccounts = [];
    currentPage = 1;
    pageSize = 10;
    totalPages = 0;
    connectedCallback(){
    getAccountIMP().then(result=>{
        this.accounts = result;
        this.totalPages = Math.ceil(this.accounts.length/this.pageSize);
        this.updatedPaginatedAccounts();

    }).catch(error=>{
        console.log('Error:'+error);
    })
}
updatedPaginatedAccounts(){
    const startIndex = (this.currentPage -1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    this.paginatedAccounts = this.accounts.slice(startIndex,endIndex);
}
get isPreviousDisabled(){
    return this.currentPage === 1;
}
get isNextDisabled(){
    return this.currentPage === this.totalPages;
}
handlePrevious(){
    if(this.currentPage>1){
        this.currentPage--;
        this.updatedPaginatedAccounts();
    }
    }
    handleNext(){
        if(this.currentPage<this.totalPages){
            this.currentPage++;
            this.updatedPaginatedAccounts();
        }
    }
}