import { LightningElement,track } from 'lwc';

export default class CartManager extends LightningElement {
    availableItems = [
        {id:1,name:'Widget',price:100},
        {id:2,name:'Gadget',price:150},
        {id:3,name:'Doohickey',price:200}
    ];
    @track cartItems = [];
    @track totalPrice = 0;
    handleAdd(event){
        const newItem = event.detail;
        this.cartItems = [...this.cartItems, newItem];
        this._recalculateTotal();
    }
    handleRemove(event){
        const itemId = event.detail;
        this.cartItems = this.cartItems.filter(item=>item.id !==itemId);
        this._recalculateTotal();
    }
    _recalculateTotal(){
        this.totalPrice = this.cartItems.reduce((sum,item)=> sum+  item.price, 0);
        
    }
}