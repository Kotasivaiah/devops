import { LightningElement, api, track } from 'lwc';

import updateCandidateAssessments from '@salesforce/apex/CandidateListPanelHelper.updateCandidateAssessments';
import getProgressData from '@salesforce/apex/CandidateListPanelHelper.getProgressData';
import encrypt from '@salesforce/apex/ExamPortalHelper.encryptKey';
import getUserData from '@salesforce/apex/CodingAnswerController.getUserData';
import userId from '@salesforce/user/Id';
// import { NavigationMixin } from 'lightning/navigation';

export default class Ep_CandidateProgressForm extends LightningElement {//NavigationMixin()
    activeSections = [
        'Candidate Information', 
        'Written Round', 
        'Coding Round',
        'Technical Round',
        'HR Assessments',
        'Technical Assessment',
        'Manager Assessment',
        'HR Assessment'
    ];

    @track _candidateData;

    programmingLanguageList = [];
    languagesSpoken = [];
    target_Hr = false;
    showRejectButton = true;
    showHoldButton = true;
    showPromoteButton = false;
    showSelectButton = true;
    isHrAssessmentDisabled = false;
    isTechnicalRound = false;

    @track isLoading = false;
    @track isCodingPage = false;
    //reviewed = false;
    showTechnicalRound = false;
    showTechnicalAssessment = false;
    showManagerAssessment = false;
    technicalRoundReviewed = false;
    viewer;

    vfPageURL;
    
    hrComments = ``;
    mrComments = ``;
    

    @track stars = [];
    @track checkMrRatings = false;
    @track checkMrComments = false;
    @track checkHrComments = false;
    @track hasEmptyHrAssessment = false;
    @track isModel = false;
    /*
     *  Confidence_Level_Tr__c
        Attitude_and_Professionalism_Tr__c
        Learning_Skills_Tr__c
        Communication_Skills_Tr__c
        Problem_Solving_Skills_Tr__c
        Technical_Skills_Tr__c
     */
    @track technicalAssessments = [
        { label: 'Confidence Level', apiName: 'Confidence_Level_Tr__c', value: '' },
        { label: 'Attitude and Professionalism', apiName: 'Attitude_and_Professionalism_Tr__c', value: '' },
        { label: 'Learning Skills', apiName: 'Learning_Skills_Tr__c', value: '' },
        { label: 'Communication Skills', apiName: 'Communication_Skills_Tr__c', value: '' },
        { label: 'Problem Solving Skills', apiName: 'Problem_Solving_Skills_Tr__c', value: '' },
        { label: 'Technical Skills', apiName: 'Technical_Skills_Tr__c', value: '' }
    ];

    @track assessments = [
        { label: 'Technical Skills', apiName: 'Technical_Skills__c', value: '' },
        { label: 'Problem Solving Skills', apiName: 'Problem_Solving_Skills__c', value: '' },
        { label: 'Communication Skills', apiName: 'Communication_Skills__c', value: '' },
        { label: 'Learning Skills', apiName: 'Learning_Skills__c', value: '' },
        { label: 'Confidence Level', apiName: 'Confidence_Level__c', value: '' },
        { label: 'Attitude and Professionalism', apiName: 'Attitude_and_Professionalism__c', value: '' }
    ];


    @track hrAssessments = [
        { label: 'Behavioral Aspects', apiName: 'Behavioral_Aspects__c', value: '' },
        { label: 'Clarity of Thought', apiName: 'Clarity_of_Thought__c', value: '' },
        { label: 'Presentability', apiName: 'Presentability__c', value: '' },
        { label: 'Expression of Views', apiName: 'Expression_of_Views__c', value: '' },
        { label: 'Communication Skills', apiName: 'Communication_Skills_hr__c', value: '' }
    ];

    isPicklistDisabled = false;
    isAttributeRequired = true;
    updatedAssessments = [];
    isManagerShown;
    isHrAccordionShown;
    isSelectShown;
   
    @track ratings = {};

    @api
    set candidateData(parameter) {
        let candidateId = '';
        if (parameter.includes('#')) {
            let paramList = parameter.split('#');
            candidateId = paramList[0];     
            this.viewer = paramList[1];
            console.log('this.viewer::',this.viewer);
            if(this.viewer == 'Technical'){
                this.isTechnicalRound = true;
            }else{
                this.isTechnicalRound = false;
            }
        } else {
            candidateId = parameter;
        }
        this.fetchCandidateData(candidateId);        
    }

    get candidateData() {
        return this._candidateData;
    }

    handleRatingCount(event) {
        const apiName = event.detail.apiName;
        const value = event.detail.value;
        this.ratings = { ...this.ratings, [apiName]: value };
        console.log('this._target!!!!',this._target);
        
        this.assessments = this.assessments.map(assessment => ({
                ...assessment,
                value: this.ratings[assessment.apiName] || assessment.value
            }));
        this.hrAssessments = this.hrAssessments.map(assessment => ({
            ...assessment,
            value: this.ratings[assessment.apiName] || assessment.value
        }));

        console.log('this.assessment values on clck '+JSON.stringify(this.assessments));
        console.log('this.assessment values on clck---- '+this.assessments);
    }

    handleBack(){
        //history.back();
        window.open(window.location.origin + '/lightning/n/Technical_Round_Review', '_self');
    }

    get starratingcount() {
        return this.handleRatingCount.bind(this);
    }


    fetchCandidateData(value){
        console.log('fetch data');
        getProgressData({ candidateId: value })
            .then(result => {
                console.log('Candidate data Loaded!!',result.Id);
                if (result.Languages_Spoken__c) {
                    this.languagesSpoken = result.Languages_Spoken__c.split(';');
                }

                if (result.Programming_Languages_Known__c) {
                    this.programmingLanguageList = result.Programming_Languages_Known__c.split(';');
                }

                this.manager = false;
                this._candidateData = result;

                if(this._candidateData.Coding_Round_Status__c == 'Selected' && this.isNull(this._candidateData.Technical_Round_Status__c)){
                    console.log('1');
                    this.isManagerShown = this.showTechnicalRound = true;
                    this.showRejectButton = this.showHoldButton = this.showSelectButton = true;
                    this.showPromoteButton = false;
                } else if (this._candidateData.Technical_Round_Status__c == 'Selected' && this.isNull(this._candidateData.Manager_Round_Status__c) && this.viewer != 'Technical') {
                    this.showTechnicalRound = true;
                    this.target_Hr = false;
                    this.showPromoteButton = false;
                    this.showHoldButton = this.showRejectButton = this.showSelectButton = this.isManagerShown = this.showManagerAssessment = true;                   
                    
                }else if(this.viewer == 'Technical' && this._candidateData.Technical_Round_Status__c == 'Selected'){
                    this.isManagerShown = this.showManagerAssessment = this.showRejectButton = this.showPromoteButton = false;
                    this.showHoldButton = this.showSelectButton = false; 
                    this.showTechnicalRound = true;               
                } else if (this._candidateData.Manager_Round_Status__c == 'Selected' && this.isNull(this._candidateData.HR_Round_Status__c) && this.viewer != 'Technical') {
                    console.log('3',this._candidateData.HR_Round_Status__c);
                    this.target_Hr = true;
                    this.showManagerAssessment = this.showTechnicalRound = this.isSelectShown = this.showRejectButton = this.showSelectButton = true;
                    this.isManagerComments = true;
                    this.isManagerShown = this.showPromoteButton = false;
                    this.showHoldButton = true;
                    console.log(this.viewer, ':::::::::::::');
                    this.isHrAccordionShown = true;

                    if (this.viewer == 'Manager') {
                        this.isHrAccordionShown = false;
                        this.showHoldButton = this.showRejectButton = this.showSelectButton = false;
                    }

                } else if (this._candidateData.Coding_Round_Status__c == 'Rejected' && this.viewer != 'Technical') {
                    console.log('4');
                    this.showTechnicalRound = this.showManagerAssessment = this.isHrAccordionShown = false;
                    this.showRejectButton = this.showHoldButton = this.showSelectButton = this.showPromoteButton = false;

                } else if (this._candidateData.Technical_Round_Status__c == 'Rejected' && this.viewer == 'Technical') {
                    console.log('5');
                    this.showManagerAssessment = this.isHrAccordionShown = false;
                    this.showTechnicalRound = true;
                    this.showRejectButton = this.showHoldButton = this.showSelectButton = this.showPromoteButton = false;

                } else if (this._candidateData.Manager_Round_Status__c == 'Rejected' && this.viewer != 'Technical') {
                    console.log('6');
                    this.showTechnicalRound = this.showManagerAssessment = true;
                    this.isHrAccordionShown = false;
                    this.showRejectButton = this.showHoldButton = this.showSelectButton = this.showPromoteButton = false;
                    this.isManagerComments = true;

                } else if (this._candidateData.HR_Round_Status__c == 'Rejected' || this._candidateData.HR_Round_Status__c == 'Selected' && this.viewer != 'Technical') {
                    console.log('7');
                    this.showTechnicalRound = this.showManagerAssessment = this.isHrAccordionShown = true;
                    this.isHrAssessmentDisabled = this.isManagerComments = true;
                    this.isManagerShown = this.showRejectButton = this.showHoldButton = this.showSelectButton = this.showPromoteButton = false;

                } else if (this._candidateData.Technical_Round_Status__c == 'On Hold' && this.viewer == 'Technical') {
                    console.log('8');
                    this.showTechnicalRound = true;
                    this.showSelectButton = this.showHoldButton = this.isManagerShown = this.showManagerAssessment = this.isHrAccordionShown = false;
                        
                    if(this._candidateData.Tech_Round_Interviewer__c === userId){
                        this.showRejectButton = this.showPromoteButton = true;
                    }else{
                        getUserData({userId : this._candidateData.Tech_Round_Interviewer__c})
                        .then(userdata => {
                            if(userdata['Recruiting_Manager__c'] == true){
                                this.showRejectButton = this.showPromoteButton = true;
                            }else if(this._candidateData.Tech_Round_Interviewer__c != userId && userdata['Recruiting_Manager__c'] == false){
                                this.showRejectButton = this.showPromoteButton = false;
                            }
                        })
                        .catch(error =>{
                            console.log('error in getUserData::',error);
                        });
                    }
                } else if (this._candidateData.Manager_Round_Status__c == 'On Hold') {
                    console.log('9  this.isManagerShown'+ this.isManagerShown);
                    this.isManagerShown = true;
                    this.showTechnicalRound = this. showManagerAssessment= true;
                    this.isHrAccordionShown = false;
                    this.isManagerComments = false;
                    this.showRejectButton = this.showPromoteButton = true;
                    this.showSelectButton = this.showHoldButton = false;

                } else  if (this._candidateData.HR_Round_Status__c == 'On Hold') {
                    console.log('10');
                    this.showPromoteButton = this.showHoldButton = false;
                    this.isManagerShown = this.showSelectButton = this.showRejectButton = true;
                    this.isSelectShown = true;
                    this.isHrAccordionShown = this.isManagerComments = this.showManagerAssessment = true;
                    this.isHrAssessmentDisabled = false;
                    
                } else if (this._candidateData.HR_Round_Status__c == 'Selected' && this._candidateData.Manager_Round_Status__c == 'Selected') {
                   console.log('11');
                    this.showRejectButton = this.showPromoteButton = this.showSelectButton = this.showHoldButton = this.isManagerShown = false;
                    this.isManagerComments = this.isHrAssessmentDisabled = true;
                }
                 
                this.initializeAssessmentValues();
            })
            .catch(error => {
                console.log('Error::',JSON.stringify(error));
            });
    }
    initializeAssessmentValues() {
        console.log('values initialized ...');

        this.technicalAssessments = this.technicalAssessments.map(assessment => ({
            ...assessment,
            value: this._candidateData[assessment.apiName] || '',
        }));

        this.assessments = this.assessments.map(assessment => ({
            ...assessment,
            value: this._candidateData[assessment.apiName] || ''
        }));
        

        this.hrAssessments = this.hrAssessments.map(assessment => ({
            ...assessment,
            value: this._candidateData[assessment.apiName] || ''
        }));

        this.mrComments = this._candidateData['Manager_Round_Comments__c'];
        this.hrComments = this._candidateData['HR_Round_Comments__c'];

        console.log('values initialized this.assessments...'+JSON.stringify(this.assessments));
        console.log('values initialized this.hrAssessments...'+JSON.stringify(this.hrAssessments));
        
    }

    openCodingModal() {

        this.isLoading = true;
        setTimeout(() => {
            this.isLoading = false;
        }, 3000);
        this.isCodingPage = true;
        let candidateId = this._candidateData.Id;
        this.encrypt('/apex/CodingRoundReview?key=', candidateId + '#' + 'Hr');
    }

    closeModal() {
        this.isCodingPage = false;
    }

    handleMrComments(event) {
        this.mrComments = event.target.value;
    }

    handleHrComments(event) {
        this.hrComments = event.target.value;
    }

    handleCustomEvent(event){
        this.isLoading = false; 
        if (event.detail != 'error') {
            this.template.querySelector("c-custom-toaster").showToast(this.technicalvariant, this.technicalmessage, 'utility:success', 3000);
            this.handleBack();
        } else {
            this.template.querySelector("c-custom-toaster").showToast('error', 'Please fill all required details', 'utility:error', 3000);
        }
    }

    technicalvariant = ''; technicalmessage= '';

    handleActions(event) {
        this.isLoading = true;
        let value = event.target.dataset.value;
        console.log('which button clicked ::',value);
        if(this._candidateData.Coding_Round_Status__c == 'Selected' && 
            (this.isNull(this._candidateData.Technical_Round_Status__c) || this._candidateData.Technical_Round_Status__c == 'On Hold')) {

            const technicalRoundComponent = this.template.querySelector('c-ep_-technical-round3');

            if (technicalRoundComponent) {
                console.log('handle selection called from progress form');
                console.log('value ==> ',value);
                console.log('this._candidateData.Technical_Round_Status__c ::');
                console.log(this._candidateData.Technical_Round_Status__c);                            
                //let message = '', variant = '';

                if (value == 'Rejected') {
                    this.technicalvariant = 'error';
                    this.technicalmessage = 'Candidate Rejected';
                } else if (value == 'On Hold') {
                    this.technicalvariant = 'success';
                    this.technicalmessage = 'Candidate On Hold';
                } else if (value == 'Promoted') {
                    this.technicalmessage = 'Candidate Selected';
                    this.technicalvariant = 'success';
                } else if (value == 'Selected') {
                    this.technicalmessage = 'Candidate Selected';
                    this.technicalvariant = 'success';
                } else {
                    console.log('button clicked!!!!!!!', 'Unknown status: ' + value);
                }
                this.isLoading = true;
                technicalRoundComponent.handleSelection(value);//fire event from tech3 to progres form 
                               
            }
            
        }else {
            if (value === 'Promoted') {
                value = 'Selected';
            }
            let statusField, commentsField, comments;

            if (this._candidateData.Technical_Round_Status__c == 'Selected' && this.isNull(this._candidateData.Manager_Round_Status__c)) {
                console.log('it is manager !!!  ');
                statusField = 'Manager_Round_Status__c';
                commentsField = 'Manager_Round_Comments__c';
                comments = this.mrComments;


            } else if (this._candidateData.Manager_Round_Status__c == 'Selected' && this.isNull(this._candidateData.HR_Round_Status__c)) {

                statusField = 'HR_Round_Status__c';
                commentsField = 'HR_Round_Comments__c';
                comments = this.hrComments;

            }

            if ((value == 'Rejected' || value == 'Selected')  && this.viewer == 'Manager') {
                statusField = 'Manager_Round_Status__c';
                commentsField = 'Manager_Round_Comments__c';
                comments = this.mrComments;
            } else if ((value == 'Rejected' || value == 'Selected')  && this.viewer == 'Hr') {
                statusField = 'HR_Round_Status__c';
                commentsField = 'HR_Round_Comments__c';
                comments = this.hrComments;
            }

            if (statusField || commentsField) {

                const statusAssessment = { apiName: statusField, value };
                const commentsAssessment = { apiName: commentsField, value: comments };
                this.updatedAssessments.push(statusAssessment, commentsAssessment);

            }

            this.updateCandidateRecord(value);
        }
    }

    updateCandidateRecord(value) {

        this.checkMrRatings = false;
        this.checkMrComments = false;
        this.checkHrComments = false;
        this.hasEmptyHrAssessment = false;
        const candidateId = this._candidateData.Id;
        const technicalAssessments = {};
        const hrAssessments = {};

        
        //if (! this.isNull(this._candidateData.Technical_Round_Status__c) && this.isNull(this._candidateData.Manager_Round_Status__c)) {

            console.log('test hold function');

            this.assessments.forEach(assessment => {
                technicalAssessments[assessment.apiName] = assessment.value;
                if (!assessment.value) {
                    assessment.techValidate = true;
                } else {
                    assessment.techValidate = false;
                }
            });

            const emptyAssessment = this.assessments.find(assessment => assessment.techValidate);
            console.log('mr comments :: ',this.mrComments);
            console.log('Hr comments :: ',this.hrComments);
            console.log('manager emty star');
            if (emptyAssessment && value !== 'Rejected') {
                this.checkMrRatings = true;
                this.isLoading = false;
                return;
            }

            if ((this.mrComments == '' || this.mrComments == undefined) && value !== 'Rejected') {
                console.log('empty mr comments ... ');
                this.checkMrComments = true;
                this.isLoading = false;
                return;
            }

        //}
        //
        if (! this.isNull(this._candidateData.Manager_Round_Status__c)) {
            console.log('Manager Round Status ::::::: ' + this._candidateData.Manager_Round_Status__c);

            if (this._candidateData.Manager_Round_Status__c != 'On Hold') {
                console.log('test comments');
                this.hrAssessments.forEach(assessment => {
                    hrAssessments[assessment.apiName] = assessment.value;
                    if (!assessment.value) {
                        assessment.techValidate = true;
                    } else {
                        assessment.techValidate = false;
                    }
                });

                const emptyHrAssessment = this.hrAssessments.find(assessment => assessment.techValidate);

                if (emptyHrAssessment && value !== 'Rejected') {
                    this.hasEmptyHrAssessment = true;
                    this.isLoading = false;
                    return;
                }
                console.log('this hr comments :',this.hrComments);
                if ((this.hrComments == '' || this.hrComments == undefined) && value !== 'Rejected') {
                    console.log('empty hr comments ... ');
                    this.checkHrComments = true;
                    this.isLoading = false;
                    return;
                }
            }
                
                console.log('if ended!!!');
        }


        console.log('updatedAssessments :::::::::::::: ' + JSON.stringify(this.updatedAssessments));
        this.updatedAssessments.forEach(updated => {
            if (updated.apiName.startsWith('HR_')) {

                hrAssessments[updated.apiName] = updated.value;

            } else {
                technicalAssessments[updated.apiName] = updated.value;

            }
        });

         console.log('in update operation technicalAssessments::>>',JSON.stringify(technicalAssessments));
         console.log('in update operation hrAssessments:::>>>',JSON.stringify(hrAssessments));
        try {

            updateCandidateAssessments({
                candidateId,
                technicalAssessments,
                hrAssessments
            }).then(result => {

                 getProgressData({ candidateId: candidateId })
                 .then(result => {
                 this._candidateData = result;
                setTimeout(() => {

                    this.isLoading = false;
                    if ((result.Manager_Round_Status__c == 'Selected' || result.Manager_Round_Status__c == 'Rejected' ||
                            result.Manager_Round_Status__c == 'On Hold')) {
                            try {
                                console.log('Manager status::::!!!',result.Manager_Round_Status__c);
                                this.isManagerShown = this.showRejectButton = this.showHoldButton = this.showPromoteButton = this.showSelectButton = false;
                                this.isManagerComments = true
                                console.log('Refreshed####');
                            } catch (error) {
                                console.error('Error dispatching RefreshEvent!!:', error);
                            }
                        }

                        if ((result.Manager_Round_Status__c == 'Selected' || result.Manager_Round_Status__c == 'Rejected') && 
                                (result.HR_Round_Status__c == 'Selected' || result.HR_Round_Status__c == 'Rejected' || 
                                    result.HR_Round_Status__c == 'On Hold')) {
                            try {
                                console.log('refreshedd@@@@', result.HR_Round_Status__c);
                                this.isHrAssessmentDisabled = true;
                                this.isSelectShown = this.showRejectButton = this.showHoldButton = this.showPromoteButton = this.showSelectButton = false;
                                console.log('Refresh event dispatched');
                            } catch (error) {
                                console.error('Error dispatching RefreshEvent:', error);
                            }
                        } else {
                            console.log('Condition not met');
                        }
                    //window.location.reload();   
                    }, 4000);

                    //console.log('secod initializeAssessmentValues ::::',JSON.stringify(result));
                    this.initializeAssessmentValues();
                    }).catch(error => {
                        this.isLoading = false; 
                     console.log('error::',JSON.stringify(error));
                 });
                 
            //this.isLoading = true;
            
            let message = '', variant = '', icon = '';

            if (value == 'Rejected') {
                variant = 'error';
                message = 'Candidate Rejected';
            } else if (value == 'On Hold') {
                variant = 'success';
                message = 'Candidate On Hold';
            } else if (value == 'Promoted') {
                message = 'Candidate Selected';
                variant = 'success';
                //icon = 'utility:success';
            } else if (value == 'Selected') {
                message = 'Candidate Selected';
                variant = 'success';
            } else {
                console.log('button clicked!!!!!!!', 'Unknown status: ' + value);
            }

            setTimeout(() => {

                this.isLoading = false;
                this.template.querySelector("c-custom-toaster").showToast(variant, message, 'utility:success', 3000);
                //window.location.reload();   
            }, 4000);

            })
           
        } catch (error) {
            console.log('Error updated ::', error);
        }
    }

    isNull (value) {
        return value == undefined || value == '' || value == null;
    }

    encrypt (baseUrl, value) {
        console.log('value : ' + value);
        encrypt ({valueToEncrypt : value})
            .then (result => {
                if (result[0] == 'error') {
                    console.log(result[1]);
                } else if (result[0] == 'success') {
                    this.isCodingPage = true;
                    this.vfPageURL = baseUrl+result[1];
                }
            });
    }

}