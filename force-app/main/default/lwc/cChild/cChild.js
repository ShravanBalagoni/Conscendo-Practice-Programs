import { LightningElement, api, track } from 'lwc';

export default class CChild extends LightningElement {
  @track isSelected = false;

  get buttonLabel() {
    return this.isSelected ? 'Deselect' : 'Select';
  }

  toggleSelect() {
    this.isSelected = !this.isSelected;
    this.dispatchEvent(new CustomEvent('toggleselect', {
      bubbles: true,
      composed: true,
      detail: { selected: this.isSelected }
    }));
  }

  @api
  resetSelection() {
    this.isSelected = false;
  }
}
