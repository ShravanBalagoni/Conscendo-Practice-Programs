import { LightningElement, track } from 'lwc';

export default class CGrandparent extends LightningElement {
  @track totalSelectedCount = 0;

  handleCountChange(event) {
    this.totalSelectedCount = event.detail.count;
  }

  handleReset() {
    const parent = this.template.querySelector('c-parent');
    if (parent) {
      parent.resetChildren();
    }
    this.totalSelectedCount = 0;
  }
}
