import { LightningElement ,track,wire} from 'lwc';
import getOpps from '@salesforce/apex/searchOpportunitiesApex.getOpps';

export default class SearchOpportunities extends LightningElement {
    @track searchKey='';
    @wire
}