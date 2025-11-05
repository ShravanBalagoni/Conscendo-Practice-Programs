import { LightningElement,api } from 'lwc';

export default class Childcmp extends LightningElement {
   @api childreceivervar = '';
   passToparent = 'Hello this msg is coming from child to Parent';
   fireEventAction(event){
    const custEvnt=new CustomEvent('childeventname',{detail:{message:this.passToparent}})
    this.dispatchEvent(custEvnt);
   }

}   