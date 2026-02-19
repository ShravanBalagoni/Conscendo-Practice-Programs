import { LightningElement ,api} from 'lwc';

export default class Childcmps extends LightningElement {
    @api childReceiverVar = '';
    childInput = '';
    clickCount = 0;

    handleInput(event){
        this.childInput = event.target.value;
    }

    fireEventAction(){
        if(!this.childInput){
            return;
        }
        this.clickCount++;

        const cusEvent = new CustomEvent('childevent',{detail:{
            message: this.childInput,
            count: this.clickCount
        }
    });
    this.dispatchEvent(cusEvent);

    this.childInput = '';
    this.template.querySelector('lightning-input').value = '';
    }

    @api resetChild(){
        this.childInput='';
        this.clickCount = 0;
        this.template.querySelector('lightning-input').value='';
    }

    handleReset(){
        this.resetChild();
        const resetEvent = new CustomEvent('childreset');
        this.dispatchEvent(resetEvent);
    }
}