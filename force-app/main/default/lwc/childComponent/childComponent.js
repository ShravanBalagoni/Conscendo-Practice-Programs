import { LightningElement ,api} from 'lwc';

export default class ChildComponent extends LightningElement {
    @api childreceiverVar='';
    childmessage="this is the message from child to parent";
    fireEventAction(event){
        const cusEvnt = new CustomEvent('childEvent',{detail:{message:this.childmessage}})
        this.dispatchEvent(cusEvnt);
    }
}