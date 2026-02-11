import { LightningElement, track,wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import ACCOUNT_CONTACT_UPDATE_CHANNEL from '@salesforce/messageChannel/AccountContactUpdate__c';
export default class AccountDashboard extends LightningElement {
    @track contactCount = 0;
    @track accountName = 'Test Account';
    @track lastMessage = null;

    subscription = null;
    @wire(MessageContext) messageContext;

    connectedCallback(){
        if(!this.subscription){
            this.subscription = subscribe(
                this.messageContext,
                ACCOUNT_CONTACT_UPDATE_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    disconnectedCallback(){
        if(this.subscription){
            unsubscribe(this.subscription);
            this.subscription=null;
        }
    }

    handleMessage(message){
        console.log('Message received:',message);

        this.contactCount = message.newTotal;
        this.accountName = 'Account'+message.accountId.substring(0,15);
        this.lastMessage = message;

        this.contactCount = this.contactCount;
    }

}