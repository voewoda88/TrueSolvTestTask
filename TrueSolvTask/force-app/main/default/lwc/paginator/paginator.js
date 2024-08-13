import { LightningElement, api } from 'lwc';

export default class Paginator extends LightningElement {
    @api pageNumber;

    @api pageSize;

    @api totalItemCount;

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    get currentPageNumber() {
        return this.totalItemCount === 0 ? 0 : this.pageNumber;
    }

    get isNotFirstPage() {
        return this.pageNumber > 1;
    }

    get isNotLastPage() {
        return this.pageNumber < this.totalPages;
    }

    get totalPages() {
        return Math.ceil(this.totalItemCount / this.pageSize);
    }
}