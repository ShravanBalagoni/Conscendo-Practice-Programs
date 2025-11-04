import { LightningElement } from 'lwc';

export default class Parentcmp extends LightningElement {
    someparentvar = 'this msg cmg from the Parent Lwc Cmp ';
    ParentReceiver = null;
    handleeventaction(event){
        const info = event.detail;
        this.ParentReceiver = info.message;
    }
}