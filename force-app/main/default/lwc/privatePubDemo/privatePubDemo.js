import { LightningElement,api } from 'lwc';

export default class PrivatePubDemo extends LightningElement {
    message='private Property';
    @api recordId;
}