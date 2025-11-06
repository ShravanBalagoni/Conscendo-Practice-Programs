import { LightningElement } from 'lwc';

export default class GreetLWC extends LightningElement {
    greet='Shravan';
    handleChange(event){
        this.greet = event.target.value;
    }
}