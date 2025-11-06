import { LightningElement,api,wire} from 'lwc';
import getRelatedOpps from '@salesforce/apex/SampleApexLtngWebCmpnt.getRelatedOpps';

export default class ShowOpportunities extends LightningElement {
    @api recordId;
    opps;
    @wire(getRelatedOpps,{accIdVar:'$recordId'}) 
    records({error,data}){
        if(data){
            this.opps=data;
            console.log(this.opps);
        }
        else if(error){
            console.error('Error:'+error);
        }
    }
}