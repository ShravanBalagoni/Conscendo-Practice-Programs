import LightningDatatable from 'lightning/datatable';
import picklistTemplate from './picklistStatic.html';
import picklistEditTemplate from './picklistEdit.html'
export default class CustomDataType extends LightningDatatable {
    static customTypes = {
        customPicklist: {
            template: picklistTemplate,
            editTemplate: picklistEditTemplate,
            standardCellLayout: true,
            typeAttributes: ['options','value','context']
        }
    };
}