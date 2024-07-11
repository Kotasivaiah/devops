import { LightningElement, track } from 'lwc';

import updateSecretKey from '@salesforce/apex/ExamPortalHelper.updateSecretKey';
import getRecordNames from '@salesforce/apex/ExamPortalHelper.getRecordNames';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class EP_UpdateSettings extends LightningElement {

    @track buttons = [];

    connectedCallback() {
        getRecordNames()
            .then(result => {
                if (result) {
                    this.buttons = result.map(recordName => {
                        return { label: recordName, name: recordName };
                    });
                }
            })
            .catch(error => {
                console.log('Unknown Error : ' + JSON.stringify(error));
            });
    }

    showSpinner = false;

    handleUpdate(event) {
        this.showSpinner = true;
        let name = event.currentTarget.dataset.name;
        let element = this.template.querySelector('input[name="' + name + '"]');
        if (element) {
            let value = element.value;
            if (this.isNotNull(value)) {
                updateSecretKey({
                    recordName: name,
                    value: value
                })
                    .then(result => {
                        if (result == 'success') {
                            setTimeout(() => {
                                this.dispatchEvent(new ShowToastEvent({
                                    message: 'Updated successfully',
                                    variant: 'success'
                                }));
                                element.value = null;
                                this.showSpinner = false;
                            }, 3000);
                        } else {
                            setTimeout(() => {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Uknown Error',
                                    message: result,
                                    variant: 'error'
                                }));
                                this.showSpinner = false;
                            }, 3000);
                        }
                    })
                    .catch(error => {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Uknown Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        }));
                        this.showSpinner = false;
                    });
            }
        }
    }

    isNotNull(stringValue) {
        return stringValue != null && stringValue != '' && stringValue != undefined;
    }
}