import { LightningElement } from 'lwc';

export default class Parentcmp extends LightningElement {
 parentMessage = 'this msg is coming from the parent';
 parentReceiver='';
 handleeventAction(event){
    const info = event.detail;
    this.parentReceiver = info.message;
 }
}
