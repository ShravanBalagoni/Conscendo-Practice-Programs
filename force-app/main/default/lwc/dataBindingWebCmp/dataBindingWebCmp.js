import { LightningElement } from 'lwc';

export default class DataBindingWebCmp extends LightningElement {
    Name='Pratap Sinha';
    Age='60';
    Address;
    Businesses = ['Textiles','Chemicals','Education','Hardware'];
    isShow = false;
    dynamicVar;
    getBusinesses(event){
        this.Address = 'Noida';
        this.Businesses.push('Education');
        this.isShow=true;

    }
    getLiveData(event){
        this.dynamicVar = event.target.value;
    }
}