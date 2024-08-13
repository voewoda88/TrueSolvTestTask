import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductTypePicklistValues from '@salesforce/apex/orderManagementPageController.getProductTypePicklistValues';
import getProductFamilyPicklistValues from '@salesforce/apex/orderManagementPageController.getProductFamilyPicklistValues';
import getProducts from '@salesforce/apex/orderManagementPageController.getProducts';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_NUMBER from '@salesforce/schema/Account.AccountNumber';
import USER_ID from '@salesforce/user/Id';
import IS_MANAGER_FIELD from '@salesforce/schema/User.IsManager__c';
import ModalDetailsWindow from 'c/modalDetailsWindow'
import CreateProductModalWindow from 'c/createProductModalWindow';
import CartProductModalWindow from 'c/cartProductModalWindow';

const FIELDS = [ACCOUNT_NAME, ACCOUNT_NUMBER];

export default class OrderManagementPage extends LightningElement {
    recordId;
    accountName;
    accountNumber;
    @track productTypeComboboxOptions = [];
    productTypeComboboxValue = '';
    @track productFamilyComboboxOptions = [];
    productFamilyComboboxValue = '';
    searchKey = '';
    @track products = [];
    pageNumber = 1;
    pageSize = 8
    totalItemCount;
    @track cartProducts = [];
    userId = USER_ID;
    isManager = false;

    @wire(CurrentPageReference)
    getPageReferenceParameters(pageReference) {
        if (pageReference) {
            this.recordId = pageReference.state.c__recordId;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account({ error, data }) {
        if (data) {
            this.accountName = data.fields.Name.value;
            this.accountNumber = data.fields.AccountNumber.value;
        } else if (error) {
            console.error('Error fetching account data:', error);
        }
    }

    @wire(getRecord, { recordId: '$userId', fields: [IS_MANAGER_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.isManager = data.fields.IsManager__c.value;
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }

    @wire(getProductTypePicklistValues)
    wiredProductTypePicklistValues({ error, data }) {
        if(data) {
            this.productTypeComboboxOptions = data.map(value => {
                return { label: value, value: value };
            });
        } else if(error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    @wire(getProductFamilyPicklistValues)
    wiredProductFamilyPicklistValues({ error, data }) {
        if(data) {
            this.productFamilyComboboxOptions = data.map(value => {
                return { label: value, value: value };
            })
        } else if(error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    @wire(getProducts, { searchKey: '$searchKey', type: '$productTypeComboboxValue', family: '$productFamilyComboboxValue', pageNumber: '$pageNumber' })
    wiredProducts({ error, data }) {
        if(data){
            this.products = data.products;
            this.totalItemCount = data.totalItemCount;
        } else if(error) {
            console.error('Error: ', error);
        }
    }

    handleProductTypeChange(event) {
        this.productTypeComboboxValue = event.detail.value;
    }

    handleProductFamilyChange(event) {
        this.productFamilyComboboxValue = event.detail.value;
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.detail.value;
    }

    handleClearFilterClick() {
        this.productFamilyComboboxValue = '';
        this.productTypeComboboxValue = '';
    }

    handleDetailsClick(event) {
        const productId = event.currentTarget.dataset.id;

        const clickedProduct = this.products.find(product => product.Id === productId);

        if(clickedProduct){
            ModalDetailsWindow.open({
                product: clickedProduct,
                size: 'small',
                ondatasend: (event) => {
                    this.handleAddClick(event);
                }
            }).then(result => {
                console.log(result);
            })
        }
    }

    handleCreacteProductClick() {
        CreateProductModalWindow.open({
            size: 'small'
        }).then(result => {
            console.log(result);
        })
    }

    handleAddClick(event) {
        const productId = event.currentTarget.dataset.id;
        const clickedProduct = this.products.find(product => product.Id === productId);
        const existingProduct = this.cartProducts.find(product => product.Id === productId);

        if (existingProduct) {
            let productQuantity = parseInt(existingProduct.Quantity);
            productQuantity += 1;
            existingProduct.Quantity = productQuantity;
            this.cartProducts = [...this.cartProducts];
        } else {
            this.cartProducts = [
                ...this.cartProducts,
                { ...clickedProduct, Quantity: 1 }
            ];
        }

        this.showToast('Success', 'The product has been added to the cart', 'success');
    }

    handleCartClick() {
        CartProductModalWindow.open({
            products: this.cartProducts,
            accountId: this.recordId,
            size: 'small',
            ondatasend: (event) => {
                this.cartProducts = event.detail;
            }
        }).then(result => {
            console.log(result);
        })
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    /* Paginator */

    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
    }
}