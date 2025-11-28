import { LightningElement } from 'lwc';

export default class LifeCycleChild extends LightningElement {
    constructor(){
       super();
        console.log('Calling from child:  constructor');
    }
    connectedCallback(){
        console.log('Calling from child:  connected Callback');
    }
    renderedCallback(){
        console.log('Calling from child: renderedCallback');
    }
    disconnectedCallback(){
        console.log('Calling from child:  disconnected callback');
    }
}