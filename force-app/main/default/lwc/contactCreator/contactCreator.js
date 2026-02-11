import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import ACCOUNT_CONTACT_UPDATE_CHANNEL from '@salesforce/messageChannel/AccountContactUpdate__c';

export default class ContactCreator extends LightningElement {
    @track contactName = '';
    @track contactCount = 0;
    
    @wire(MessageContext) messageContext;

    handleNameChange(event) {
        this.contactName = event.detail.value;
    }

    addContact() {
        if (!this.contactName) return;
        
        // Simulate Contact creation
        console.log(`✅ Creating Contact: ${this.contactName}`);
        this.contactCount++;
        
        // 🔥 PUBLISH to accountDashboard
        const payload = {
            accountId: '001000000000000', // Fixed Account ID
            action: 'contact_added',
            newTotal: this.contactCount
        };
        
        publish(this.messageContext, ACCOUNT_CONTACT_UPDATE_CHANNEL, payload);
        console.log('📤 Published:', payload);
        
        this.contactName = ''; // Clear input
    }
}
