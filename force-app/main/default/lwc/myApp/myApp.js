import { LightningElement } from 'lwc';
import template from './myApp.html';  // ← ADD THIS
import MyModal from 'c/modalLWC';

export default class MyApp extends LightningElement {
    result;

    render() {                     // ← ADD THIS
        return template;
    }

    async handleOpenModal() {
        const result = await MyModal.open({
            size: 'medium',
            description: 'Choose an option from the modal',
            options: [
                { id: 'yes', label: 'Yes' },
                { id: 'no', label: 'No' }
            ]
        });
        this.result = result;
    }
}
