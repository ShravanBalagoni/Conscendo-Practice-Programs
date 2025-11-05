import { LightningElement } from 'lwc';

export default class Parentcmp extends LightningElement {
  someParentVar = 'this msg cmg from the parent Lwc cmp';
  parentReceiver = '';

  handleEventAction(event) {
    const info = event.detail;
    this.parentReceiver = info.message;
  }
}
