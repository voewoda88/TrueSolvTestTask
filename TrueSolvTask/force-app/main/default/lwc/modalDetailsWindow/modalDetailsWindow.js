import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ModalDetailsWindow extends LightningModal {
    @api product;
    modalLabel;
    photoLink;

    connectedCallback() {
        this.modalLabel = this.product.Name;
        this.photoLink = this.product.Image__c;
    }

    handleAdd() {
        this.dispatchEvent(new CustomEvent('datasend', {
            currentTarget: { dataset: { id: this.product.id }}
        }));
        this.handleClose();
    }

    handleClose(event) {
        this.close('Close');
    }
}