import { LightningElement,api } from 'lwc';

export default class Childcmp extends LightningElement {
    @api childreceiverVar='';
    passToparent ='Hello this msg is from child to parent ';
    fireEventAction(event){
        const custEvent = new CustomEvent('childeventname',{detail:{message:this.passToparent}})
    }

}   