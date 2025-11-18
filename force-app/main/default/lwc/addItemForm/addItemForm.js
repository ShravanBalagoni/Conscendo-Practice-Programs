import { LightningElement,api,track } from 'lwc';

export default class AddItemForm extends LightningElement {
    @api items = [];
    @track selectItemId;

    get itemOptions(){
        return this.items.map(item=>({label:`${item.name} ()`}))
    }
}