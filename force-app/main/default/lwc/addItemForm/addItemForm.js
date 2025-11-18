import { LightningElement,api,track } from 'lwc';

export default class AddItemForm extends LightningElement {
    @api items = [];
    @track selectItemId;

    get itemOptions(){
        return this.items.map(item=>({label:`${item.name} ($${item.price})`,value: item.id}));

    }
    handleChange(event){
        this.selectItemId = parseInt(event.target.value, 10);
    }
    handleAddClick(){
        if(this.selectItemId == null){
            return;
        }
        const selected = this.items.find(item=>item.id === this.selectItemId);
        if(selected){
            this.dispatchEvent(new CustomEvent('additem',{
                detail: selected
            }));
        }
    }
}