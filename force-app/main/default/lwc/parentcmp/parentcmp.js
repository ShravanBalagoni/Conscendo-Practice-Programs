import { LightningElement } from 'lwc';

export default class Parentcmp extends LightningElement {
    someparentVar = 'this msg cmg from the parent Lwc cmp';
    parentReceiver = null;
    handleeventaction(event){
        const info = event.detail;
        this.parentReceiver = info.message;
    }
}