import { LightningElement } from 'lwc';
import LightningModal from 'lightning/modal';

export default class CreateProductModalWindow extends LightningModal {
    handleSave() {
        const recordEditForm = this.template.querySelector('lightning-record-edit-form');
        if (recordEditForm) {
            recordEditForm.submit();
        }
        this.handleClose();
    }
    
    handleClose(event) {
        this.close('Close');
    }
}