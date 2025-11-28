import { LightningElement } from 'lwc';


export default class LifeCycleHookExample extends LightningElement {
    constructor(){
        super();
        console.log('Calling from Parent: constructor');
    }
    connectedCallback(){
       console.log('Calling from Parent: connected Callback');
    }
    renderedCallback(){
        console.log('Calling from Parent: renderedCallback');
    }
    errorCallback(){
        console.log('Error Callback');
    }
   
}