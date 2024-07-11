import { LightningElement, wire } from 'lwc';
import getQuestions from '@salesforce/apex/QuestionMasterController.getQuestions';

export default class QuestionPaper extends LightningElement {
    questions;
    error;

    @wire(getQuestions)
    wiredQuestions({ error, data }) {
        if (data) {
            this.questions = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.questions = undefined;
        }
    }

    get technicalQuestions() {
        return this.questions ? this.questions.Technical : [];
    }

    get aptitudeQuestions() {
        return this.questions ? this.questions.Aptitude : [];
    }
}