import LightningModal from 'lightning/modal';

export default class ModalLWC extends LightningModal {
    options = [
        { id: 'yes', label: 'Yes' },
        { id: 'no', label: 'No' }
    ];

    handleOptionClick(event) {
        const id = event.target.dataset.id;
        this.close(id);
    }
}
