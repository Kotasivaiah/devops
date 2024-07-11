import { LightningElement, api, track} from 'lwc';
import getTechnicalQuestions from '@salesforce/apex/TechnicalRound3Controller.getTechnicalQuestions';
import insertCTRecords from '@salesforce/apex/TechnicalRound3Controller.insertCTRecords';
import getTechnicalAnswerData from '@salesforce/apex/TechnicalRound3Controller.getTechnicalAnswerData';
import getCandidateData from '@salesforce/apex/TechnicalRound3Controller.getCandidateData';
import EP_Fill_All_Ratings from '@salesforce/label/c.EP_Fill_All_Ratings';
import EP_Fill_Comments from '@salesforce/label/c.EP_Fill_Comments';
import userId from '@salesforce/user/Id';
import getUserData from '@salesforce/apex/CodingAnswerController.getUserData';

export default class Ep_TechnicalRound3 extends LightningElement {

    reviewed = false;
    showTabs = false;
    showAfterSubmit = false;
    showQuestion = true;
    showOtherSection = false;
    showModal = false;
    showRejectButton = true;
    showTable = false;
    // enableStarRating = false;
    hasEmptyTechnicalAssessment = false;
    hasEmptyTechnicalComments = false;
    submitted = false;
    showTechnicalrating = false;
    
    questions;
    ratingValue = '';
    activeTabName = '';
    message = '';
    comments = '';
    review = '';
    selection = '';
    starVariant = 'neutral';
    technicalRoundStatus = '';
    codingRoundStatus = '';
    averageRating = '';
    technicaldata;
    _candidateData;
    candidateIdd ;
    technicalRoundReviewer = '';
    fillRatingsMsg = EP_Fill_All_Ratings;
    fillCommentsMsg = EP_Fill_Comments;

    questionsWithResponses = [];
    activeSections = []; 
    rows = [];
    tabs = [
        { label: 'Java', value: 'Java' },
        { label: 'C', value: 'C' },
        { label: 'DBMS', value: 'DBMS' },
        { label: 'SQL', value: 'SQL' },
        { label: 'HTML', value: 'HTML' },
        { label: 'Python', value: 'Python' },
        { label: 'JavaScript', value: 'JavaScript' },
        { label: 'Logical', value: 'Logical' }
    ];
    @track ratings = {};
    columns = [
        { label: 'Language', fieldName: 'technicalLanguage', type: 'text' },        
        { label: 'Difficulty', fieldName: 'difficultyLevel', type: 'text' },
        { label: 'Question', fieldName: 'technicalQuestion', type: 'text' },
        { label: 'Response', fieldName: 'response', type: 'text'}
    ];

    @track assessments = [
        { label: 'Confidence Level', apiName: 'Confidence_Level_Tr__c', value: '' },
        { label: 'Attitude and Professionalism', apiName: 'Attitude_and_Professionalism_Tr__c', value: '' },
        { label: 'Learning Skills', apiName: 'Learning_Skills_Tr__c', value: '' },
        { label: 'Communication Skills', apiName: 'Communication_Skills_Tr__c', value: '' },
        { label: 'Problem Solving Skills', apiName: 'Problem_Solving_Skills_Tr__c', value: '' },
        { label: 'Technical Skills', apiName: 'Technical_Skills_Tr__c', value: '' }
    ];  

    get starratingcount() {
        return this.handleRatingCount.bind(this);
    }

    handleRatingCount(event) {
        const apiName = event.detail.apiName;
        const value = event.detail.value;
        this.ratings = { ...this.ratings, [apiName]: value };
        this.assessments = this.assessments.map(assessment => ({
            ...assessment,
            value: this.ratings[assessment.apiName] || assessment.value
        }));
    } 
    get candidateId () {
        return candidateId;
    }

    @api 
    
    set candidateId ( value ){
        //this.candidateId = value;
        console.log('candidateId::',value);
        this.fetchCandidateData(value);
    }

    fetchCandidateData(candidateId){
        getCandidateData({candidateId : candidateId})
        .then(result => {
           // console.log('tech data::',JSON.stringify(result));
            this.codingRoundStatus = result.Coding_Round_Status__c;
            this.technicalRoundStatus = result.Technical_Round_Status__c;
            this.ratingValue = result.Technical_Skills_Tr__c;
            this.review = result.TR_Comments__c;
            this.averageRating = result.Technical_Round_Marks__c;
            console.log('result.Tech_Round_Interviewer__::',result.Tech_Round_Interviewer__c);
            this.technicalRoundReviewer = result.Tech_Round_Interviewer__r.Name;
            console.log('this.technicalRoundReviewer ',this.technicalRoundReviewer);
            this.assessments = this.assessments.map(assessment => {
                return {
                    ...assessment,
                    value: result[assessment.apiName]
                };
            });
            //console.log('hi');
            //console.log('this.technicalRoundStatus',this.technicalRoundStatus);
            if(this.technicalRoundStatus === undefined || this.technicalRoundStatus == '' || this.technicalRoundStatus.length == 0 ) {
                console.log('if console.log(this.technicalRoundStatus::,this.technicalRoundStatus);',this.technicalRoundStatus);
                this.reviewed = false;
                this.showTechnicalrating = false;
                getTechnicalQuestions({ language: this.tabs })
                    .then(result => {

                        this.questions = Object.entries(result).map(([key, value]) => ({ key, value }));

                        this.questions.forEach(tab => {

                            tab.easyQuestions = tab.value.filter(question => question.Question_Difficulty__c === 'Easy');
                            tab.mediumQuestions = tab.value.filter(question => question.Question_Difficulty__c === 'Medium');
                            tab.hardQuestions = tab.value.filter(question => question.Question_Difficulty__c === 'Hard');

                        });
                        this.showTabs = true;
                    });
               // console.log('this.showTabs::',this.showTabs);

            }else if(this.technicalRoundStatus == 'Selected' || this.technicalRoundStatus == 'On Hold' || this.technicalRoundStatus == 'Rejected'){
                this.showTechnicalrating = true;

               if(this.technicalRoundStatus == 'On Hold'){
                   console.log('result.Tech_Round_Interviewer__c::',result.Tech_Round_Interviewer__c);
                   console.log('userid::',userId);
                   if(result.Tech_Round_Interviewer__c === userId){
                       console.log('if');
                        this.reviewed = false;
                    }else{
                        getUserData({userId : result.Tech_Round_Interviewer__c})
                        .then(userdata => {
                            console.log('userdata[Recruiting_Manager__c]::',userdata['Recruiting_Manager__c']);
                            if(userdata['Recruiting_Manager__c'] == true){
                                console.log('rec if');
                                this.reviewed = false;
                            }else if(result.Tech_Round_Interviewer__c != userId && userdata['Recruiting_Manager__c'] == false){
                                console.log('req else');
                                this.reviewed = true;
                            }
                        })
                        .catch(error =>{
                            console.log('error in getUserData::',error);
                        });
                    }                   
               }else{
                    this.reviewed = true;
               }
                getTechnicalAnswerData({candidateId : candidateId})
                    .then(result => {
                        //console.log('gettechnical Answers::',JSON.stringify(result));
                        this.technicaldata = result;
                        this.showTable = true;
                        this.showTabs = false;
                    })
                    .catch(error => {

                        console.log('error::',JSON.stringify(error));

                    });            
            }

        })
        .catch(error => {
            console.log('error:::==========>',JSON.stringify(error));
        });       

        this.candidateIdd = candidateId;
    }


    

    handleTabChange(event) {
        this.activeTabName = event.target.value;
    }

    handleSave(technicalStatus) {
        console.log('this.candidateId::',this.candidateIdd);
        console.log('this.questionsWithResponses::',JSON.stringify(this.questionsWithResponses));
        console.log('this.assessments::',JSON.stringify(this.assessments));
        insertCTRecords({candidateQuestionInfo : this.questionsWithResponses, review : this.review, 
                        candidateId : this.candidateIdd, ratings : this.assessments, technicalRoundStatus : technicalStatus})
        .then(result =>{
            this.fetchCandidateData(this.candidateIdd);
            this.reviewed = true;
            this.showTabs = false;
            this.showTable = true;
            const selectEvent = new CustomEvent('mycustomevent', {
                    detail: result
                });
            this.dispatchEvent(selectEvent);

        })
        .catch(error => {

            console.log('error:',JSON.stringify(error));
            this.message = JSON.stringify(error);
        });
    }

    handleResponse(event) {

        const questionId = event.target.name;
        const response = event.target.value;
        const foundquestion = this.questionsWithResponses.find(q => q.Id === questionId);// Find the question object by Id
        console.log('foundquestion::',foundquestion);
        if (foundquestion) {
            foundquestion.Response = response;
            foundquestion.CandidateId = this.candidateIdd;

        } else {
            let question;
            for (let i = 0; i < this.questions.length; i++) {

                for (let j = 0; j < this.questions[i].value.length; j++) {

                    question = this.questions[i].value[j];
                    if (question.Id === questionId) {
                        this.questionsWithResponses.push({ Id: questionId, Response: response, CandidateId : this.candidateIdd });
                        break;
                    }
                }
            }
        }//else
    }

    handleOther() {

        this.showOtherSection = true;
        const id = this.rows.length + 1;
        this.rows = [ ...this.rows, { id, inputValue: '', selectedOption: '',CandidateId : this.candidateId } ];
    }

    handleInputChange(event) {

        const id = event.target.name;
        const value = event.target.value;
        this.updateRow(id, 'inputValue', value, 'CandidateId');
    }

    handleRadioResponse(event) {

        const id = event.target.name;
        const value = event.target.value;
        this.updateRow(id, 'selectedOption', value, 'CandidateId');
    }

    updateRow(id, field, value) {

        this.rows = this.rows.map(row => {
                                        if (row.id == id) {
                                            return { ...row, [field]: value };
                                        }
                                        return row;
                                    });
    }
    reviewChange(event){
        this.review = event.target.value;
    }

    handleSubmit(){
        this.showModal = true;
    }

    handleCancel(){
        this.showModal = false;
    }

    rating(event){

        this.ratingValue=event.target.value;        
    }

    @api
    handleSelection(value) {
        console.log('TR handleSelection::',value);
        this.hasEmptyTechnicalAssessment = false;
        this.hasEmptyTechnicalComments = false;
        if(value == 'Promoted'){
            value = 'Selected';
            this.selection = value;
            //this.handleSave(this.selection); 
        }else{            
            this.selection = value;
        }
        
        console.log('this.selection)::',this.selection);
        if(this.selection != 'Rejected'){
            this.assessments.forEach(assessment => {
                if (!assessment.value) {
                    this.hasEmptyTechnicalAssessment = true;
                }
            });                
        }
        if(this.selection == 'Rejected' && !this.review){
            this.hasEmptyTechnicalComments = true;
        }
        
        if(this.hasEmptyTechnicalAssessment == false && this.hasEmptyTechnicalComments == false){
            console.log('saving tech data');
            console.log('this.selection)::',this.selection);
            this.handleSave(this.selection); 
        }else{                
            // console.log('this.questionsWithResponses::',JSON.stringify(this.questionsWithResponses));
            // console.log('review::',this.review);
            // console.log('this.assessments::',JSON.stringify(this.assessments));
            // console.log('this.candidateId::',this.candidateIdd);
            // console.log('this.selection)::',this.selection);
            const selectEvent = new CustomEvent('mycustomevent', {
                detail: 'error'
            });
            this.dispatchEvent(selectEvent); 
        }
                  
    }
}