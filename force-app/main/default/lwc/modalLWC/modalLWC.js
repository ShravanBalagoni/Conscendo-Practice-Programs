import LightningModal from 'lightning/modal';

export default class ModalLWC extends LightningModal {
    options = [
        { id: 'yes', label: 'Yes' },
        { id: 'no', label: 'No' }
    ];

    handleOptionClick(event) {
        const id = event.target.dataset.id;
        const label = event.target.dataset.label
        this.close(id,label);
    }
}
