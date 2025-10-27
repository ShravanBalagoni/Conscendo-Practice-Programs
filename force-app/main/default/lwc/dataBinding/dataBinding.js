import { LightningElement } from 'lwc';

export default class DataBinding extends LightningElement {
    Name='Yakuzha';
    Phone=7890564321;
    Items = ['Guns','IED','Machine Guns','Detonators'];
    isShow = false;
    dynamicVar;
    Address;
    getAddress(event){
        this.Address='Japan';
        this.Items.push('Land Mines');
        this.isShow=true;
    }
    getLiveData(event){
        this.dynamicVar = event.target.value();
    }
}