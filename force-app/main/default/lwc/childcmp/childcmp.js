import { LightningElement, api } from 'lwc';

export default class Childcmp extends LightningElement {
 @api childreceiverVar='';
 passToparent = 'Hello this is msg cmg from child';
 fireEventAction(event){
    const cusEvent = new CustomEvent('childevent',{detail:{message:this.passToparent}})
    this.dispatchEvent(event);
 }
}
