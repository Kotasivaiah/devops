/*
Description: 
Class name: CandidateLoginHelper
*/

import { LightningElement } from 'lwc';

import PROCESS from "@salesforce/resourceUrl/ep_RecruitmentOverview";
// import CODING_REVIEW_KEY from '@salesforce/label/c.EP_CodingRoundReview';
import INVALID_CREDENTIALS from '@salesforce/label/c.EP_invalidHallTicket';
import INVALID_HALLTICKET from '@salesforce/label/c.EP_invalidHallTicket';
import SELECT_LANGUAGE from '@salesforce/label/c.EP_selectLanguage';
import VALID_KEY from '@salesforce/label/c.EP_validKey';
import KEY_MATCHED from '@salesforce/label/c.EP_keyMatched';
import LOGIN_ISSUE from '@salesforce/label/c.EP_loginIssue';

import NOENOUGHTIME_CODING from '@salesforce/label/c.EP_noEnoughTimeForCoding';
import NOENOUGHTIME_WRITTEN from '@salesforce/label/c.EP_noEnoughTimeForWritten';
import ALREADY_ATTEMPTED_CODING from '@salesforce/label/c.EP_alreadyAttemptedCoding';
import CODING_INPROGRESS from '@salesforce/label/c.EP_codingInProgress';
import ALREADY_ATTEMPTED_WRITTEN from '@salesforce/label/c.EP_attemptedWritten';
import WRITTEN_INPROGRESS from '@salesforce/label/c.EP_Written_in_Progress';

import login from '@salesforce/apex/CandidateLoginHelper.login';
import adminLogin from '@salesforce/apex/CandidateLoginHelper.adminLogin';
import getSecretKeys from '@salesforce/apex/CandidateLoginHelper.getSecretKeys';
import getCandidateData from '@salesforce/apex/CandidateLoginHelper.getCandidateData';
import generateQuestions from '@salesforce/apex/CandidateLoginHelper.generateQuestions';
import encrypt from '@salesforce/apex/ExamPortalHelper.encryptKey';

export default class Ep_LoginPage extends LightningElement {

    candidateId;
    process = PROCESS;
    keyvisible = 'utility:hide';
    passwordvisible = 'utility:hide';
    a_passwordvisible = 'utility:hide';
    mask = 'password';
    a_mask = 'password';
    secretKeymask = 'password';
    secretValue = '';
    errorMessage ='';
    invalidCredentialsMessage = INVALID_CREDENTIALS;
    invalidHallTicketMessage = INVALID_HALLTICKET;
    selectLanguageMessage = SELECT_LANGUAGE;
    validKeyMessage = VALID_KEY;
    keyMatchedMessage = KEY_MATCHED;
    loginIssueMessage = LOGIN_ISSUE;
    noEnoughTimeForCodingMsg = NOENOUGHTIME_CODING;
    noEnoughTimeForWrittenMsg = NOENOUGHTIME_WRITTEN;
    attemptedCodingMsg = ALREADY_ATTEMPTED_CODING;
    codingInProgressMsg = CODING_INPROGRESS;
    attemptedWrittenMsg = ALREADY_ATTEMPTED_WRITTEN;
    writtenInProgressMsg = WRITTEN_INPROGRESS;

     writtenRoundKey;
     codingRoundKey;
     codingTestExamDuration;
     writtenTestExamDuration;

    // codindRoundReviewKey = CODING_REVIEW_KEY;

    urlSpecifications = 'left=100,top=100, titlebar=no,directories=no,'
                +'toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=no,fullscreen=yes';

    width = screen.availWidth;
    height = screen.availHeight;

    isAdmin = false;
    showSpinner = false;
    showLogin = true;
    showInstructions = false;
    showStartButton = false;
    showWelcome = true;
    showSecretKeyPopup = false;
    showQuestionaire = false;
    showlogoValue = true;
    showWrongSecretKeydiv = false;
    codingRound = false;
    writtenRound = false;
    adminLoggedIn = false;
    showMessage = false;
    showvalidHallTicket = false;
    invalidCredentials = false;

    _candidateData;

    writtenOptions = [
        {
            label : 'Java',
            value : 'Java'
        },
        {
            label : 'C',
            value : 'C'
        },
        {
            label : 'C & Java',
            value : 'C & Java'
        },
    ];

    codingOptions = [
        {
            label : 'Java',
            value : 'Java'
        },
        {
            label : 'C',
            value : 'C'
        },
    ];

    connectedCallback() {
        console.log('1');
        getSecretKeys()
        .then(result => {
            if (result) {
                //console.log('result::',JSON.stringify(result));
                this.writtenRoundKey = result[0];
                this.codingRoundKey = result[1];
                this.codingTestExamDuration = result[2];
                this.writtenTestExamDuration = result[3];
                console.log('2');
                console.log(Number(this.writtenTestExamDuration -10));
            } else {
                console.log('Error getting secret keys ');
            }
        })
        .catch(error => {
            console.log('Error getting secret keys : ' + JSON.stringify(error));
        });
    }

    //Toggles the screen between admin and candidate login on clicking
    handleLoginChange () {

        this.showSpinner = true;
        if (this.isAdmin) {

            this.isAdmin = false;
        } else {

            this.isAdmin = true;
        }

        setTimeout(() => {
            this.showSpinner = false;
        }, 800);
    }

    //Validates hallticket number and displays instructions, Asks for the password And Starts the test
    handleLogin () {

        this.showSpinner = true;

        let payload = {};

        let inputList = this.template.querySelectorAll('.c');

        if (inputList.length > 0) {
            inputList.forEach(element => {
                payload[element.name] = element.value;
            });
        }

        login(payload)
        .then(result => {
            
            if (result == 'invalid') {

                //this.template.querySelector('.invalid').classList.remove('slds-hide');
                this.template.querySelector("c-custom-toaster").showToast('error',this.invalidCredentialsMessage,'utility:warning',4000);
                this.invalidCredentials = true;
                this.showSpinner = false;

            } else {               
                this.invalidCredentials = false;
                if(result.length != 0){

                    getCandidateData({candidateId : result})
                    .then(candidateinfo => {

                        this.showSpinner = false;
                        this.candidateId = result;
                        this._candidateData = candidateinfo;

                        if (this._candidateData.Written_Test_Status__c == 'In Progress'){

                            this.showLogin = false;
                            this.showMessage = true;
                            this.errorMessage = this.writtenInProgressMsg;

                        }  else if(this._candidateData.Written_Test_Status__c == 'Completed'){

                           this.showLogin = false;
                           this.showMessage = true;
                           this.errorMessage = this.attemptedWrittenMsg;

                        }  else if(this._candidateData.Written_Test_Status__c == 'Not Started'){

                            this.showLogin = false;
                            this.writtenRound = true;
                            this.showMessage = false;
                            this.showInstructions = true;
                            this.showStartButton = true;
                            this.showWelcome = false;

                        } else if (this._candidateData.Coding_Round_Status__c == 'In Progress') {

                            this.showLogin = false;
                            this.showMessage = true;
                            this.errorMessage = this.codingInProgressMsg;

                        } else if(this._candidateData.Coding_Round_Status__c == 'Completed'){

                            this.showLogin = false;
                            this.showMessage = true;
                            this.errorMessage = this.attemptedCodingMsg;

                       } else if(this._candidateData.Coding_Round_Status__c == 'Not Started'){
                            this.codingRound = true;
                            this.showLogin = false;
                            this.showMessage = false;
                            this.showInstructions = true;
                            this.showStartButton = true;
                            this.showWelcome = false;

                        } else{

                            this.showLogin = false;
                            this.showMessage = true;
                            this.errorMessage = this.loginIssueMessage;
                        }
                    })
                    .catch(error => {
                        this.showSpinner = false;
                        console.log(JSON.stringify(error.body));
                    });
                }else{
                    this.showSpinner = false;
                    this.showvalidHallTicket = true;
                }
            
            }
        })
        .catch(error => {

            console.log('error::',JSON.stringify(error.body));
            this.template.querySelector("c-custom-toaster").showToast('error',JSON.stringify(error),'utility:warning',4000);
            this.showSpinner = false;

        })
    }


    handleAdminLogin () {

        this.showSpinner = true;
        let payload = {};

        let inputList = this.template.querySelectorAll('.a');
        if (inputList.length > 0) {
            inputList.forEach(element => {
                payload[element.name] = element.value;
            });
        }

        adminLogin(payload)
        .then(result => {
            console.log('result==>',result);
             if (result == 'invalid') {
                //this.template.querySelector('.invalid').classList.remove('slds-hide');
                this.template.querySelector("c-custom-toaster").showToast('error',this.invalidCredentialsMessage,'utility:warning',4000);
                this.invalidCredentials = true;                
                this.showSpinner = false;

            }else {
                this.invalidCredentials = false;
                if(result != null || result != ''){

                    getCandidateData({candidateId : result})
                        .then(candidateinfo => {
                            
                            this.candidateId = result;
                            this._candidateData = candidateinfo;
                            
                            this.showSpinner = false;
                            if (inputList.length > 0) {
                                inputList.forEach(element => {
                                    element.value = '';
                                });
                            }

                            //open instructions
                            if((this._candidateData.Written_Test_Status__c == 'Completed' ||
                                    this._candidateData.Written_Test_Status__c == 'Not Started' ||
                                    this._candidateData.Written_Test_Status__c == 'In Progress') && this._candidateData.Sec_Consumed__c >= Number(this.writtenTestExamDuration -10)){

                                this.showLogin = false;
                                this.showMessage = true;
                                this.errorMessage = this.noEnoughTimeForWrittenMsg;

                            } else if(this._candidateData.Written_Test_Status__c == 'Selected' 
                                        && (this._candidateData.Coding_Round_Status__c == 'Completed' || 
                                            this._candidateData.Coding_Round_Status__c == 'Not Started' ||
                                            this._candidateData.Coding_Round_Status__c == 'In Progress')
                                        && this._candidateData.Sec_Consumed__c >= Number(this.codingTestExamDuration)-10){

                                this.showLogin = false;
                                this.showMessage = true;
                                this.errorMessage = this.noEnoughTimeForCodingMsg;

                            } else if((this._candidateData.Written_Test_Status__c == 'Completed' ||
                                this._candidateData.Written_Test_Status__c == 'Not Started' ||
                                this._candidateData.Written_Test_Status__c == 'In Progress') && this._candidateData.Sec_Consumed__c < Number(this.writtenTestExamDuration -10)){

                                this.adminLoggedIn = true;
                                this.encrypt('/ExamPortal/Questionnaire?key=', this._candidateData.Id + '#' + this.adminLoggedIn);

                            }else if(this._candidateData.Written_Test_Status__c == 'Selected'
                                    && (this._candidateData.Coding_Round_Status__c == 'Completed' ||
                                        this._candidateData.Coding_Round_Status__c == 'Not Started' ||
                                        this._candidateData.Coding_Round_Status__c == 'In Progress' )
                                    && this._candidateData.Sec_Consumed__c < Number(this.codingTestExamDuration-10)){

                                this.adminLoggedIn = true;
                                this.encrypt('/ExamPortal/CodingQuestionnaire?key=', this._candidateData.Id + '#' + this.adminLoggedIn);

                            } else{
                                
                                this.showLogin = false;
                                this.showMessage = true;
                                this.errorMessage = this.loginIssueMessage;

                            }
                        })
                        .catch(error => {

                            this.showSpinner = false;
                            console.log('Admin catch error::',JSON.stringify(error));

                        });
                }else{

                    this.showSpinner = false;
                    this.showvalidHallTicket = true;
                }            
            }
        })
        .catch(error => {
            console.log('AdminLogin catch error::',JSON.stringify(error));
        });
    }

    //masks and unmasks hallticket number
    handleShowClick () {
        let type = this.template.querySelector('input[name="htNumber"]').type;

        if (type == 'password') {

            this.mask = 'text';
            this.passwordvisible = 'utility:preview';

        } else {

            this.mask = 'password';
            this.passwordvisible = 'utility:hide';
        }
    }

    //masks and unmasks password
    togglePassword () {

        let type = this.template.querySelector('input[name="password"]').type;

        if (type == 'password') {

            this.a_mask = 'text';
            this.a_passwordvisible = 'utility:preview';

        } else {

            this.a_mask = 'password';
            this.a_passwordvisible = 'utility:hide';
        }
    }

    //Toogles secretKey visibilty
    handleSecretKeyClick() {

        let type = this.template.querySelector('input[name="secretKey"]').type;

        if (type == 'password') {

            this.secretKeymask = 'text';
            this.keyvisible = 'utility:preview';

        } else {

            this.secretKeymask = 'password';
            this.keyvisible = 'utility:hide';
        }
    }

    //null check
    isNull (str) {
        return !(str != null && str != '' && str != undefined);
    }

    //assigns questions to the Candidate
    handleStartTest(){

        let categoryCombobox = this.template.querySelector('lightning-combobox');

        let category;

        if (categoryCombobox) {
            category = categoryCombobox.value;
        }

        let error = this.template.querySelector('.categoryError');

        if (category) {

            if (error) {
                error.classList.add('slds-hide');
            }
            this.showSecretKeyPopup = true;
            generateQuestions({
            candidateId : this._candidateData.Id,
            category : category
            })
            .then(result => {

                console.log('generated successfully!!!!');

            })
            .catch(error => {

                this.template.querySelector("c-custom-toaster").showToast('error',error.body,'utility:error',4000);
                this.template.querySelector('.invalidadmin').classList.add('slds-hide');

            });

        } else {

            if (error) {
                error.classList.remove('slds-hide');
            }
        }

    }

    //hides the secretKey Modal
    handleCancel(){
        this.showSecretKeyPopup = false;
    }

    //getting the secret key onchange
    secretValueChange(event){
        this.secretValue = event.target.value;
    }

    //validating the secret key
    handleVerify(){
        console.log('this.writtenRoundKey',this.writtenRoundKey);
        console.log('this.codingRoundKey',this.codingRoundKey);
        let inputList = this.template.querySelector('.secretKey');
        if (inputList) {
            this.secretValue = inputList.value;
        }
        
        if((this._candidateData.Written_Test_Status__c == 'Not Started' || (this.writtenRound == true)) 
            && this.secretValue == this.writtenRoundKey){

                this.showInstructions = true;
                this.showStartButton = false;
                this.showSecretKeyPopup = false;
                this.showWrongSecretKeydiv = false;

                this.encrypt('/ExamPortal/Questionnaire?key=', this._candidateData.Id + '#' + 'false');

        }else if(((this._candidateData.Written_Test_Status__c == 'Selected' && this._candidateData.Coding_Round_Status__c == 'Not Started') ||
                   (this.codingRound == true))
                    && this.secretValue == this.codingRoundKey){

            this.showInstructions = true;
            this.showStartButton = false;
            this.showSecretKeyPopup = false;
            this.showWrongSecretKeydiv = false;
            this.encrypt('/ExamPortal/CodingQuestionnaire?key=', this._candidateData.Id + '#' + 'false');

        } else if(this._candidateData.Written_Test_Status__c == 'Rejected' && this.secretValue == this.writtenRoundKey){

            this.showInstructions = false;
            this.showStartButton = false;
            this.showSecretKeyPopup = false;

        }else if(this._candidateData.Coding_Round_Status__c == 'Rejected' && this.secretValue == this.codingRoundKey){

            this.showInstructions = true;
            this.showStartButton = false;
            this.showSecretKeyPopup = false;
            this.showLogin = false;    

        }else if(this._candidateData.Written_Test_Status__c == 'Not Started' && this.secretValue != this.writtenRoundKey){

            this.showWrongSecretKeydiv = true;

        }else if(this._candidateData.Written_Test_Status__c == 'Selected' && this._candidateData.Coding_Round_Status__c == 'Not Started' 
                && this.secretValue != this.writtenRoundKey){

            this.showWrongSecretKeydiv = true;

        }else if((this.adminLoggedIn == true && this.writtenRound == true) && this.secretValue != this.writtenRoundKey){

            this.showWrongSecretKeydiv = true;

        }else if((this.adminLoggedIn == true && this.codingRound == true) && this.secretValue != this.codingRoundKey){

            this.showWrongSecretKeydiv = true;
        }
    }

    handleKeyPress (event) {

        if (event.which == '13') {

            if (event.target.name == 'htNumber') {
                this.handleLogin();
            } else if (event.target.name == 'password' || event.target.name == 'candidateHallticket') {
                this.handleAdminLogin();
            }

        }
    }

    encrypt (baseUrl, value) {
        
        encrypt ({valueToEncrypt : value})
            .then (result => {
                if (result[0] == 'error') {
                    console.log(result[1]);
                } else if (result[0] == 'success') {
                    let vfPageURL = baseUrl+result[1];
                    window.open(vfPageURL, 'popUpWindow','height='+this.height+',width='+this.width+','+this.urlSpecifications);
                }
            });
    }

}