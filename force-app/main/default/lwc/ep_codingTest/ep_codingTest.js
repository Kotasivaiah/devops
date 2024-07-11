import { LightningElement, api } from 'lwc';

import getCandidateCodingRecords from '@salesforce/apex/CodingAnswerController.getCandidateCodingRecords';
import storeCodingInformation from '@salesforce/apex/CodingAnswerController.storeCodingInformation';
import storeCodingRoundStatus from '@salesforce/apex/CodingAnswerController.storeCodingRoundStatus';
import getCandidateData from '@salesforce/apex/CodingAnswerController.getCandidateData';
import getUserData from '@salesforce/apex/CodingAnswerController.getUserData';
import userId from '@salesforce/user/Id';

import EP_Fill_All_Statuses from '@salesforce/label/c.EP_Fill_All_Statuses';
import EP_Fill_All_Comments from '@salesforce/label/c.EP_Fill_All_Comments';

export default class Ep_codingTest extends LightningElement {

    tabs = [];
    questionsWithResponses = [];
    viewer;
    totalTabs;
    selectLabel;

    @api
    fromModal = false;

    showBackButton = false;
    showSelectionButtons = false;
    showRejectButton = false;
    showSelectButton = false;
    showOnHoldButton = false;
    showPromoteButton = false;
    showPrevButton = false;
    showNextButton = false;
    showSubmitButton = false;

    showMessage = false;
    showReviewPanel = false;
    disableCodeTextArea = true;
    showlogoValue = true;
    showModal = false;
    reviewed = false;
    showErrorMessage = false;
    showComments = false;
    errorMessage1 = EP_Fill_All_Statuses;
    errorMessage2 = EP_Fill_All_Comments;

    tabClass = '';
    ratingValue = '';
    selection = '';
    message = '';
    review = '';
    tabLabel = '';
    disableStarRating = true;
    activeTab = '0';
    userInput = '';
    candidateData; 

     disconnectedCallback() {
        // Remove the global event listener when the component is destroyed
        if (this.handleGlobalKeyDown) {
            window.removeEventListener('keydown', this.handleGlobalKeyDown);
        }
    }

    handleGlobalKeyDown = (event) => {
        try {
            if (event.key === 'Tab') {
                event.preventDefault();
                // Check if the target is the textarea
                const target = event.target;
                if (event.target.tagName === 'C-EP_CODING-TEST') {
                    this.handleTabInTextarea(event);
                }
            }
        } catch (e) {
            console.log(JSON.stringify(e));
        }
    }

    handleTabInTextarea(event) {
        try{
            const textarea = this.template.querySelector('.custom-textarea[name="' +this.activeTab+ '"]');
            const start = textarea.selectionStart;
            const end = textarea.selectionEnd;

            if (textarea) {
                textarea.value = textarea.value.substring(0, start) + "\t" + textarea.value.substring(end);
                textarea.selectionStart = textarea.selectionEnd = start + 1;
            } else {
            }
        } catch (e) {
            console.log(JSON.stringify(e));
        }
    }
    _candidateId;
    @api
    set candidateId(parameter){

        if (parameter.includes('###')) {

            let paramList = parameter.split('###');
            this._candidateId = paramList[0];
            this.viewer = paramList[1];

        } else {
            this._candidateId = parameter;
        }

        if (this.viewer == 'candidate') {
            window.addEventListener('keydown', this.handleGlobalKeyDown);
        }

        getCandidateData({ candidateId: this._candidateId })
        .then(result => {
            this.candidateData = result;

            this.showBackButton = true && (!this.fromModal);
            this.showReviewPanel = true;

            if (result['Coding_Round_Status__c'] == 'Selected' || result['Coding_Round_Status__c'] ==  'Rejected') {

                this.reviewed = true;

            } else if (result['Coding_Round_Status__c'] == 'On Hold') {
                if(result['Coding_Round_Reviewer__c'] === userId){
                    this.reviewed = false;
                    this.disableStarRating = false;
                }else{
                    getUserData({userId : result['Coding_Round_Reviewer__c']})
                    .then(userdata => {
                        if(userdata['Recruiting_Manager__c'] == true){
                          this.disableStarRating = false; 
                          this.reviewed = false;  
                        }else if(result['Coding_Round_Reviewer__c'] != userId && userdata['Recruiting_Manager__c'] == false){
                            this.disableStarRating = true;
                            this.reviewed = true;
                        }
                    })
                    .catch(error =>{
                        console.log('error in getUserData::',error);
                    });
                }
                this.selectLabel = 'Promote';
            } else if (result['Coding_Round_Status__c'] == 'Completed') {

                this.selectLabel = 'Select';
                this.showOnHoldButton = true;
                this.disableStarRating = false;
                this.reviewed = false;
                this.disableCodeTextArea = true;
                this.showNextButton = true;
            }

            if (this.viewer == 'candidate') {
                this.showBackButton = false;
                this.showReviewPanel = false;
                this.disableCodeTextArea = false;
                this.showNextButton = true;
                this.tabClass = 'slds-col slds-size_12-of-12';

            } else {
                this.tabClass = 'slds-col slds-size_7-of-12';
            }

        })
        .catch(error => {
            console.log('error :: ',error);
        });

        getCandidateCodingRecords({ candidateId: this._candidateId })
            .then(result => {
                if (result) {
                    this.tabs = result.map((question, index) => ({
                        label: `Question ${index + 1}`,
                        id: question.Coding_Round_2_Question__c,
                        value: question.Coding_Round_2_Question__r ? question.Coding_Round_2_Question__r.Question__c : '',
                        response: question.Response__c,
                        CArecordId: question.Id,
                        status: question.Status__c,
                        comments: question.Comments__c,
                        reviewedby: question.CandidateId__r.Coding_Round_Reviewer__r ? question.CandidateId__r.Coding_Round_Reviewer__r.Name : '',
                        rating: question.Rating__c,
                    }));
                    console.log('reponses : ' +JSON.stringify(this.tabs));
                }

                this.totalTabs = this.tabs.length-1;
            });
    }

    get candidateId () {
        return this._candidateId;
    }

    handlePrevious(){

        let value = Number(this.activeTab) - 1;
        this.setButtons(value);
        this.activeTab = value.toString();
    }

    setButtons (activeTab) {

        if (activeTab == 0) {

            this.showPrevButton = false;
            this.showNextButton = true;
            this.showSubmitButton = false;
            this.showSelectionButtons = false;


        } else if (activeTab == this.totalTabs) {

            this.showPrevButton = true;
            this.showNextButton = false;

            if (this.viewer == 'candidate') {
                this.showSubmitButton = true;
            } else if (!this.reviewed) {
                this.showSelectionButtons = true;
            }

        } else {
            this.showPrevButton = true;
            this.showNextButton = true;
            this.showSubmitButton = false;
            this.showSelectionButtons = false;


        }
    }

    handleNext(){
        try {
            let value = Number(this.activeTab) + 1;
            this.setButtons(value);
            this.activeTab = value.toString();
        } catch (e) {
            console.log(JSON.stringify(e));
        }
    }

    get options() {
        return [
            { label: 'Not Attempted', value: 'Not Attempted' },
            { label: 'Just Attempted', value: 'Just Attempted' },
            { label: 'Partially Done', value: 'Partially Done' },
            { label: 'Fully Done', value: 'Fully Done' }
        ];
    }

    get starratingcount() {
        return this.handleRatingCount.bind(this);
    }

    handleRatingCount(event) {

        const apiName = event.detail.apiName;
        const value = event.detail.value;
        const questionIndex = this.tabs.findIndex(tab => tab.label === apiName);
        if (questionIndex !== -1) {
            this.tabs[questionIndex].rating = value;//.response = event.target.value;
        }        
    }

    handleTabChange (event) {
        this.activeTab = event.target.value;
        this.tabLabel = event.target.label;
        this.setButtons(Number(this.activeTab));
    }

    handleInput(event) {
        this.userInput = event.target.innerText;
    }

    @api handleSubmit() {

        if (this.viewer == 'candidate') {
            this.tabs.forEach ( tab => {
                let response = this.template.querySelector('textarea.custom-textarea[data-id="' + tab.label + '"]');
                if (response) {
                    tab.response = response.value;
                } else {
                    console.log('textarea Not found');
                }
            });
        }

        this.questionsWithResponses = this.tabs.map(tab => ({
            id: tab.id,
            response: tab.response,
            CandidateId: this._candidateId,
            CArecordId: tab.CArecordId,
            status: tab.status,
            comments: tab.comments,
            reviewedby: tab.reviewedby,
            rating : tab.rating
        }));
        console.log('this.questionsWithResponse::',JSON.stringify(this.questionsWithResponses));
        this.updateRecord(this.questionsWithResponses);
    }

    updateRecord(records) {
        this.showComments = false;
        this.showErrorMessage = false;
        
        let missingFields = [];
        missingFields = this.questionsWithResponses.filter(tab => !tab.status);
        if (missingFields.length == 0) {
            this.showErrorMessage = false;
        } else {
            this.showErrorMessage = true;
        }
        

        if(this.selection == 'Rejected' && this.disableStarRating == false){
            let missingComments = [];
            missingComments = this.questionsWithResponses.filter(tab => !tab.comments);
            if (missingComments.length == 0) {
                this.showComments = false;
            } else {
                this.showComments = true;
            }
        }    
        if(!this.showErrorMessage && !this.showComments){
            storeCodingInformation({ info: records })
            .then(result => {
                console.log('Coding Round result Success: ', result);
            })
            .catch(error => {   
                console.log('error:', error);
            });
        }
    }

    handleStatusChange(event) {

        const questionIndex = this.tabs.findIndex(tab => tab.label === event.target.name);
        if (questionIndex !== -1) {
            this.tabs[questionIndex].status = event.target.value;
        }
    }

    handleComments(event) {

        const questionIndex = this.tabs.findIndex(tab => tab.label === event.target.name);
        if (questionIndex !== -1) {
            this.tabs[questionIndex].comments = event.target.value;
        }
    }

    handleCopy(event) {
        event.preventDefault();
        alert('Copying is disabled');
    }

    handleCut(event) {
        event.preventDefault();
        //alert('Cutting is disabled');
    }

    handlePaste(event) {
        event.preventDefault();
        alert('Pasting is disabled');
    }

    rating(event) {

        const questionIndex = event.currentTarget.dataset.index;
        const starRating = event.currentTarget.dataset.id;
        this.tabs[questionIndex].rating = starRating;
    }

    currentRating = 0;
    stars = Array.from({ length: 5 });

    handleStarClick(event) {
        const index = parseInt(event.target.dataset.index);
        this.currentRating = index + 1;
        this.stars.forEach((star, i) => {
            star.cssClass = i < this.currentRating ? 'star checked' : 'star';
        });
    }

    async handleSelection(event) {

        this.selection = event.target.value;
        this.showModal = true;
        await this.handleSubmit();


        if(this.showErrorMessage == false && this.showComments == false){

            storeCodingRoundStatus({ status: this.selection, candidateId: this._candidateId })
            .then(result => {
                this.tabs = false;
                history.back();
            })
            .catch(error => {
                this.tabs = false;
                this.message = JSON.stringify(error.body);
                this.showMessage = true;
            });
        }
    }

    handleCancel() {
        this.showModal = false;
    }

    async handleSubmitButtonClick(){
        try {
            this.dispatchEvent(new CustomEvent('getdata',
            {
                detail: { submitted :  true},
                bubbles: true,
                composed: true,
            }
        ));
        } catch(e) {
            console.log(JSON.stringify(e));
        }
    }

    reviewChange(event) {
        this.review = event.target.value;
    }

    handleBack (event) {
        window.open(window.location.origin + '/lightning/n/Coding_Round_Review', '_self');
    }
}