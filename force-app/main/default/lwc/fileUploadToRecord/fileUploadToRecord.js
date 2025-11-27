import { LightningElement, api, track } from 'lwc';
import uploadFileToRecord from '@salesforce/apex/FileUploaderController.uploadFileToRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUploadComponent extends LightningElement {
  @api recordId;        // Provided automatically when component placed on a record page
  @track fileData;      // Will hold { base64, fileName }
  fileName = '';        // Name of selected file (for display)
  isUploading = false;  // Flag to disable button while uploading

  // List of allowed file extensions — used by input accept attribute
  get acceptedFormats() {
    return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx'];
  }

  // Called when user selects a file via the input
 handleFileChange(event) {
    const file = event.target.files[0];
    if (file) {
        const fileName = file.name;
        const MAX_FILE_SIZE = 5 * 1024 * 1024;  // e.g. 5 MB limit
if (file.size > MAX_FILE_SIZE) {
  this.showToast(
    'Error',
    'File size exceeds ' + (MAX_FILE_SIZE / 1024 / 1024) + ' MB limit',
    'error'
  );
  this.fileName = '';
  this.fileData = undefined;
  return;
}

        // --- added validation start ---
        const extension = fileName.slice(fileName.lastIndexOf('.')).toLowerCase();
        const allowed = ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx'];
        if (!allowed.includes(extension)) {
            // invalid file type — show error and do not proceed
            this.showToast(
                'Invalid File Type',
                'Please upload a file of type: ' + allowed.join(', '),
                'error'
            );
            // reset state so nothing remains selected
            this.fileName = '';
            this.fileData = undefined;
            return;
        }
        // --- added validation end ---

        this.fileName = fileName;  // store file name for display
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            this.fileData = { base64, fileName };
        };
        reader.readAsDataURL(file);
    }
}


  // Called when user clicks the Upload button
  handleUpload() {
    // if no file selected — warn and stop
    if (!this.fileData) {
      this.showToast('Error', 'Please select a file first', 'error');
      return;
    }
    // set uploading flag to true to disable button/ prevent multiple clicks
    this.isUploading = true;

    // Call Apex method, passing base64 data, file name, and recordId to link file to record
    uploadFileToRecord({
      base64Data: this.fileData.base64,
      fileName: this.fileData.fileName,
      recordId: this.recordId
    })
    .then(contentDocId => {
      // On success: reset state, show success toast
      this.isUploading = false;
      this.fileData = null;
      this.fileName = '';
      this.showToast('Success', 'File uploaded and linked to record', 'success');
      // Optionally use contentDocId for further operations
      console.log('Uploaded file ContentDocumentId: ' + contentDocId);
    })
    .catch(error => {
      // On error: reset flag, show error message
      this.isUploading = false;
      this.showToast('Error uploading file', error.body ? error.body.message : error, 'error');
    });
  }

  // Utility to show a popup toast message in Salesforce UI
  showToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}
