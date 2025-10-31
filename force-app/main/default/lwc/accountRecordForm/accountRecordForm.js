import { LightningElement,api } from 'lwc';
import ACCOUNT_OBJ from '@salesforce/schema/Account';
import ACC_NAME from '@salesforce/schema/Account.Name';
import ACC_PHONE from '@salesforce/schema/Account.Phone';
import ACC_RATING from '@salesforce/schema/Account.Rating';


export default class AccountRecordForm extends LightningElement {
    @api recordId;
    accountObject = ACCOUNT_OBJ;
    specificFields = [ACC_NAME,ACC_PHONE,ACC_RATING];
}