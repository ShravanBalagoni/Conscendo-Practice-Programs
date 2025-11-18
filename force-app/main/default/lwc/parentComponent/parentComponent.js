import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {
    parentMessage="this is the message from the parent to child"
    parentReceiver='';
    handleeventAction(event){
        const info = event.detail;
        this.parentReceiver= info.message;
    }
}