import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class MyModal extends LightningModal {
    @api recordId;

    handleOkay() {
        this.close();
    }
}