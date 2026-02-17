import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';  // ✅ AUTO REFRESH MAGIC
import getRecentTasks from '@salesforce/apex/AccountDecisionService.getRecentTasks';

export default class AccountDecisionHistory extends LightningElement {
    @api recordId;
    recentTasks;
    error;
    wiredTasksResult;  // ✅ STORE WIRE RESULT

    @wire(getRecentTasks, { accountId: '$recordId' })
    wiredTasks(result) {
        this.wiredTasksResult = result;  // ✅ CAPTURE REFERENCE
        
        const { error, data } = result;
        if (data) {
            this.recentTasks = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body?.message || 'Unknown error';
            this.recentTasks = [];
        }
    }

    // ✅ PUBLIC METHOD - Parent calls this after modal closes
    @api refreshTasks() {
        return refreshApex(this.wiredTasksResult);  // ✅ INSTANT REFRESH
    }
}
