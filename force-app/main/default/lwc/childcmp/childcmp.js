import { LightningElement, api } from 'lwc';

export default class Childcmp extends LightningElement {
  @api childReceiverVar = '';
  passToParent = 'Hello this msg is coming from child to Parent';

  fireEventAction() {
    const custEvnt = new CustomEvent('childeventname', {
      detail: { message: this.passToParent }
    });
    this.dispatchEvent(custEvnt);
  }
}
