import { LightningElement, api } from 'lwc';
export default class Ep_ManagerHR_Round extends LightningElement {
    @api name = 'HR';

    selectedRating = '';
    remarks = '';
    ratinglabel = '';
    remarkslabel ='';

    get options() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' }
        ];
    }

    connectedCallback() {
        if(this.name == 'Manager'){
            this.ratinglabel = 'Manager Rating';
            this.remarkslabel = 'Manager Remarks';
        }else{
            this.ratinglabel = 'HR Rating';
            this.remarkslabel = 'HR Remarks';
        }
    }

    handleMarksChange(){
        this.selectedRating = event.detail.value;
        console.log('this.selectedRating:',this.selectedRating);
    }

    handleRemarksChange(event){
        this.remarks = event.detail.value;
        console.log('this.remarks:',this.remarks);
    }

    handleSubmit(){
        console.log('selectedRating:',this.selectedRating);
        console.log('this.remarks',this.remarks);
    }
}