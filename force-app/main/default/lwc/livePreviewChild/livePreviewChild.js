import { LightningElement,api } from 'lwc';

export default class LivePreviewChild extends LightningElement {
    @api childReceiver='';
    inputvalue='';
    handleChangevalue(event) {
    this.inputvalue = event.target.value;

    const custevent = new CustomEvent('childevent', {
        detail: { message: this.inputvalue }
    });
    this.dispatchEvent(custevent);
}

}