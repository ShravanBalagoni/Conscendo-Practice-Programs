import { LightningElement,api } from 'lwc';

export default class ItemList extends LightningElement {
    @api items = [];
    @api total = 0;

    handleRemoveClick(event){
        const itemId = parseInt(event.target.dataset.id,10);
        this.dispatchEvent(new CustomEvent('removeitem',{
            detail:itemId
        }));
    }

}