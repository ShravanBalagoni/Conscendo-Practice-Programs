import { LightningElement, track, api } from 'lwc';
export default class ParentList extends LightningElement {
// maintain a map of childId => boolean for selected state
@track childStates = { '1': false, '2': false, '3': false };
get selectedCount() {
return Object.values(this.childStates).filter(Boolean).length;
}
// Called when a direct child fires the childtoggle event
handleChildToggle(event) {
// prevent this handler from stopping propagation — we want the event to keep going up
const { id, selected } = event.detail;
// update local state
this.childStates = { ...this.childStates, [id]: selected };
// Optionally, the parent can re-dispatch or let the original event bubble.
// We'll allow the original event to bubble so the grandparent can also react.
}
// Expose an API so the grandparent can ask parent to reset its children
@api
resetAllChildren() {
// call reset() on each child component instance
const children = this.template.querySelectorAll('c-child-item');
if (children) {
children.forEach((child) => {
// each child exposes an @api reset() method
if (typeof child.reset === 'function') {
child.reset();
}
});
}
// reset local tracked states
this.childStates = { '1': false, '2': false, '3': false };
}
// Optional: parent-only reset button handler
handleResetParentChildren() {
this.resetAllChildren();
}
}