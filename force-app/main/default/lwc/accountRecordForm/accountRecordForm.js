import { LightningElement,api } from 'lwc';
import ACCOUNT_OBJ from'@salesforce/schema/Account';
import Acc_Name from '@salesforce/schema/Account.Name';
import Acc_Phone from '@salesforce/schema/Account.Phone';
import Acc_Rating from '@salesforce/schema/Account.Rating';
import Acc_Industry from '@salesforce/schema/Account.Industry';

export default class AccountRecordForm extends LightningElement {
    @api recordId;
    accountObj = ACCOUNT_OBJ;
    specificFields = [Acc_Name,Acc_Phone,Acc_Industry,Acc_Rating];
}