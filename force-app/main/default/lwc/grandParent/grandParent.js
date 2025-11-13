import { LightningElement, track } from 'lwc';


export default class GrandParent extends LightningElement {
@track totalSelected = 0;


handleChildToggleFromGrandparent(event) {
// The event is fired from the child and bubbles up (composed:true).
// We need to update the grandparent counter. But the event alone
// contains only the toggled child's new selected state. To maintain
// a correct total we could either:
// 1) Maintain a map of child ids to selected status here as well
// 2) Query the parent for its current total (not ideal)
// We'll maintain a simple map locally to keep the grandparent self-sufficient.


// Initialize map once
if (!this._childStates) {
this._childStates = {};
}


const { id, selected } = event.detail;
this._childStates[id] = selected;


this.totalSelected = Object.values(this._childStates).filter(Boolean).length;
}


handleResetAll() {
// Ask the parent component instance to reset all its children via @api
const parent = this.template.querySelector('c-parent-list');
if (parent && typeof parent.resetAllChildren === 'function') {
parent.resetAllChildren();
}


// Reset grandparent's internal map and counter
this._childStates = { };
this.totalSelected = 0;
}
}