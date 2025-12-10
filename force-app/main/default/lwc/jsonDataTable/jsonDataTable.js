import { LightningElement,track } from 'lwc';

export default class JsonDataTable extends LightningElement {
    @track data = [];
    @track columns = [
        {label:'ID',fieldName:'id'},
        {label:'Title',fieldName:'title'},
        {label:'Body',fieldName:'body'},
    ];
    async connectedCallback(){
        try{
            const resp = await fetch('https://jsonplaceholder.typicode.com/posts');
            if(!resp.ok) throw new Error('Network response was not ok');
            const result = await resp.json();
            console.log(JSON.stringify(result))
            this.data = result;
        }
        catch(error){
            console.error('Fetch error:',error);
        }
    }
}