import { LightningElement } from 'lwc';

export default class CapturingInputLWC extends LightningElement {
    message='';
    name='';
    handleinput(event){
        this.name =event.target.value;
    }
    handleClick(event){
        this.message='HELO'+this.name;
    }


}