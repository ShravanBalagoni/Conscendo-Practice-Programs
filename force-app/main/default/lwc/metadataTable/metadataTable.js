import { LightningElement, track, wire } from 'lwc';
import getMetadataRecords from '@salesforce/apex/MetadataController.getMetadataRecords';

export default class MetadataTable extends LightningElement {
  @track data = [];
  @track columns = [
    { label: 'Label', fieldName: 'MasterLabel' },
    { label: 'Value', fieldName: 'Value__c' }
  ];

  @wire(getMetadataRecords)
  wiredMetadata({ error, data }) {
    if (data) {
      this.data = data;
    } else if (error) {
      console.error('Error: ' + JSON.stringify(error));
    }
  }
}
