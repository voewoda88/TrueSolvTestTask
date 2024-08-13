import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';
import saveProducts from '@salesforce/apex/orderManagementPageController.saveProducts';

export default class CartProductModalWindow extends LightningModal {
    @api products;
    @api accountId;
    nonReactiveProducts = [];
    columns = [
        { label: 'Product Name', fieldName: 'Name', type: 'text', sortable: false },
        {
            label: 'Quantity',
            fieldName: 'Quantity',
            type: 'number',
            editable: true,
            sortable: false,
            cellAttributes: { alignment: 'center' }
        }
    ];

    connectedCallback() {
        this.products.forEach(product => {
            if(product.Price__c) {
                this.nonReactiveProducts.push({
                    Id: product.Id,
                    Name: product.Name,
                    Quantity: product.Quantity,
                    Price: product.Price__c
                })
            } else {
                this.nonReactiveProducts.push({
                    Id: product.Id,
                    Name: product.Name,
                    Quantity: product.Quantity,
                    Price: product.Price
                })
            }
        })
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;

        updatedFields.forEach(updatedItem => {
            const productId = updatedItem.Id;
            const productInCart = this.nonReactiveProducts.find(product => product.Id === productId);

            if (productInCart) {
                productInCart.Quantity = updatedItem.Quantity;
            }
        });

        this.nonReactiveProducts = [...this.nonReactiveProducts];
        this.template.querySelector('lightning-datatable').draftValues = [];
        this.handleSendData();
    }

    handleSendData() {
        this.dispatchEvent(new CustomEvent('datasend', {
            detail: this.nonReactiveProducts
        }));
    }

    handleCheckoutClick() {
        saveProducts({ products: this.nonReactiveProducts, accountId: this.accountId })
            .then(result => {
                const orderId = result;
                this.nonReactiveProducts = [];
                this.handleSendData();
                this.handleClose();
                window.location.href = `/lightning/r/Order__c/${orderId}/view`;
            })
            .catch(error => {
                console.log('Error: ', error);
            })
    }


    handleClose(event) {
        this.close('Close');
    }
}