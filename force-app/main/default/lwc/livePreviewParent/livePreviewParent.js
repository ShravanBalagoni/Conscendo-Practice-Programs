import { LightningElement } from 'lwc';

export default class LivePreviewParent extends LightningElement {
    inputdata='';
    parentReceiver='';
    handleChange(event){
       
        this.inputdata = event.target.value;
}
handleonchild(event){
    const info = event.detail;
    this.parentReceiver = info.message;

}
}