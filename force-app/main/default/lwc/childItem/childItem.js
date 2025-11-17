import { LightningElement, api, track } from 'lwc';
export default class ChildItem extends LightningElement {
@api itemId; // id passed from parent
@track selected = false;
// expose a reset method so parent / grandparent can call it
@api
reset() {
this.selected = false;
// Also notify upward that this child is now deselected
this._dispatchToggleEvent();
}
get buttonLabel() {
return this.selected ? 'Deselect' : 'Select';
}
get statusLabel() {
return this.selected ? 'Selected' : 'Deselected';
}
toggleSelect() {
this.selected = !this.selected;
this._dispatchToggleEvent();
}
_dispatchToggleEvent() {
// Custom event that bubbles and is composed so it crosses shadow boundaries
const detail = { id: this.itemId, selected: this.selected };
const evt = new CustomEvent('childtoggle', {
detail,
bubbles: true,
composed: true,
});
this.dispatchEvent(evt);
}
}