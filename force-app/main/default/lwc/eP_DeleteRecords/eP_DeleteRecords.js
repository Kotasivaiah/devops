import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CLEAREDMESSAGE from '@salesforce/label/c.Message_ClearDatabase';



import clearDatabase from '@salesforce/apex/ExamPortalHelper.clearDatabase';


export default class EP_DeleteRecords extends LightningElement {

    clearedMessage = CLEAREDMESSAGE;
    showSpinner = false;

    handleDelete() {

        this.showSpinner = true;
        let permit = confirm('Are you sure?');
        if (permit) {
            console.log('clicked true');
            clearDatabase()
                .then(result => {
                    if (result == 'success') {
                        setTimeout(() => {
                            this.dispatchEvent(new ShowToastEvent({
                                message: this.clearedMessage,
                                variant: 'success'
                            }));
                            this.showSpinner = false;
                        }, 3000);
                    } else {
                        this.dispatchEvent(new ShowToastEvent({
                            message: JSON.stringify(result),
                            variant: 'error'
                        }));
                    }
                })
                .catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Unknown Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }));
                });
        } else {
            console.log('clicked false');
            this.showSpinner = false;
        }
    }
}