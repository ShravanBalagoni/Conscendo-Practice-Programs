import { LightningElement, api, track } from 'lwc';

export default class CParent extends LightningElement {
  @track selectedCount = 0;

  handleToggleSelect(event) {
    // Count how many children are selected
    setTimeout(() => {
      const children = this.template.querySelectorAll('c-child');
      this.selectedCount = Array.from(children).filter(child => child.isSelected).length;

      // Bubble event to grandparent with count detail
      this.dispatchEvent(new CustomEvent('countchange', {
        bubbles: true,
        composed: true,
        detail: { count: this.selectedCount }
      }));
    }, 0);
  }

  @api
  resetChildren() {
    this.template.querySelectorAll('c-child').forEach(child => {
      child.resetSelection();
    });
    this.selectedCount = 0;
  }
}
