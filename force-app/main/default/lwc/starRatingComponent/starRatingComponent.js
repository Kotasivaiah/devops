import { LightningElement, api } from 'lwc';

export default class StarRatingComponent extends LightningElement {
    @api name;
    @api defaultVal;
    @api readOnly = false;

    get isChecked5() {
        return this.defaultVal == 5;
    }

    get isChecked4() {
        return this.defaultVal == 4;
    }

    get isChecked3() {
        return this.defaultVal == 3;
    }

    get isChecked2() {
        return this.defaultVal == 2;
    }

    get isChecked1() {
        return this.defaultVal == 1;
    }

    get isReadOnly() {
        return this.readOnly;
    }

    get rateClass() {
        return `rate ${this.readOnly ? 'readonly' : ''}`;
    }

    rating(event) {
        if (this.readOnly) {
            return;
        }
        this.dispatchEvent(new CustomEvent('ratingcount', {
            detail: {
                apiName: event.target.name,
                value: event.target.value
            }
        }));
    }

    @api getvalues() {
        console.log('star rating component >....');
    }
}