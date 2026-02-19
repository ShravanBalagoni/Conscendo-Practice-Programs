import { LightningElement } from 'lwc';

export default class Parentcmps extends LightningElement {
    parentMessage = 'Hello Child!';

    parentInput = '';
    messageList = [];
    totalMessages = 0;

    handleParentInput(event){
        this.parentInput = event.target.value;
    }

    sendToChild(){
        if(!this.parentInput){
            return;
        }

        this.parentMessage = this.parentInput;
        this.parentInput = '';
        this.template.querySelector('lightning-input').value = '';
    }

    handleeventAction(event){
        const info = event.detail;

        this.totalMessages++;

        this.messageList = [
            ...this.messageList,
            {id: this.totalMessages, text: info.message}
        ];
    }
    
    handleChildReset(){
        this.messageList = [];
        this.totalMessages = 0;
    }

    resetEverything(){
        this.messageList = [];
        this.totalMessages = 0;
        this.parentMessage = 'Hello Child!';
        this.template.querySelector('c-childcmp').firstElementChild();
    }
}