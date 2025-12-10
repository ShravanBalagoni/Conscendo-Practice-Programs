import { LightningElement,api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
export default class MyNavigation extends NavigationMixin(LightningElement) {
@api recordId;
@api objectApiName;
@api accountId = this.accountId;
navigateToRecordEdit(){
    this[NavigationMixin.Navigate]({
        type:'standard__recordPage',
        attributes:{
            recordId:this.recordId,
            actionName:'edit'
        }
    });
}
navigateToAccountView(){
    this[NavigationMixin.Navigate]({
        type:'standard__recordPage',
        attributes:{
            recordId:this.accountId,
             objectApiName:this.objectApiName,
            actionName:'view'
           
        }
    });
}
}