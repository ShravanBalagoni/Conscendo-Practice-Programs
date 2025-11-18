import { LightningElement ,api} from 'lwc';

export default class ChildComponent extends LightningElement {
    @api childreceiverVar = '';
    childmessage='This is the message from the child LWC'
    Custom
}