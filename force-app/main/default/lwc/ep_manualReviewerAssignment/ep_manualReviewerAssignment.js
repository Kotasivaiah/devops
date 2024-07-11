import { LightningElement, api } from 'lwc';
import EP_Manual_Reviewer_Heading from '@salesforce/label/c.EP_Manual_Reviewer_Heading';
import EP_Manual_Technical_Heading from '@salesforce/label/c.EP_Manual_Technical_Heading';
export default class Ep_manualReviewerAssignment extends LightningElement {
    showModal = false;
    modalHeading = '';
    codingReviewMsg = EP_Manual_Reviewer_Heading;
    technicalreviewMsg = EP_Manual_Technical_Heading;

    handleSelection(event){
        console.log('selected button::',event.target.value);
        if(event.target.value == 'Coding Review'){
            this.modalHeading = this.codingReviewMsg;
            this.roundName = 'coding';
        }else{
            this.modalHeading = this.technicalreviewMsg; 
            this.roundName = 'technical';
        }
        this.showModal = true;
    }
    
    @api
    hideModalBox(){
        this.showModal = false;
    }


}