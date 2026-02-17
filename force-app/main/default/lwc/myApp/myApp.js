import { LightningElement } from 'lwc';
import template from './myApp.html';  // ← ADD THIS
import MyModal from 'c/modalLWC';

export default class MyApp extends LightningElement {
    result;

    render() {                     // ← ADD THIS
        return template;
    }

    async handleOpenModal() {
        console.log('Modal is Opened');
        const result = await MyModal.open({
            size: 'large',
            description: 'Choose an option from the modal',
          /*  options: [
                { id: 'yes', label: 'True' },
                { id: 'no', label: 'False' }
            ]*/
        });
        this.result = result;
        console.log('Result:'+result);
        console.log('Modal is Closed');
    }
    
}
