import { LightningElement } from 'lwc';
import getCases from '@salesforce/apex/SampleApexLtngWebCmpnt.getCases';
const columns = [{label:'CaseNo', fieldName:'CaseNumber'},
                {label:'CasePriority', fieldName:'Priority'},
                {label:'CaseOrigin', fieldName:'Origin'}];
export default class GetCasesLWC extends LightningElement {
    cases;
    columns=columnsList;
    fetchAllCases(event){
        getCases().then(result=>{
            this.cases = result;
        }).catch(error=>{
            console.error('ERROR:'+error);
        })
    }

}