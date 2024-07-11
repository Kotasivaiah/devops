/*
    Description: To Assign the selected Users to the Candidates that are eligible for different recruitement processes. 
    Class name: ReviewerAssignmentHelper
*/

import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getPanelMembers from '@salesforce/apex/ReviewerAssignmentHelper.getPanelMembers';
import assignPanelMembers from '@salesforce/apex/ReviewerAssignmentHelper.assignPanelMembers';

import EP_Assignment_Success from '@salesforce/label/c.EP_Assignment_Success';
import EP_Empty_Panel_Member from '@salesforce/label/c.EP_Empty_Panel_Member';
import EP_Empty_Round from '@salesforce/label/c.EP_Empty_Round';

export default class Ep_ReviewerAssignment extends LightningElement {

    assignmentSuccessMsg = EP_Assignment_Success;
    selectUserMsg = EP_Empty_Panel_Member;
    selectRoundMsg = EP_Empty_Round;

    rounds = [
        {
            label : 'Code Review',
            value : 'CodeReview'
        },
        {
            label : 'Technical Round',
            value : 'TechnicalRound'
        }
    ];

    @track panelList = [];
    showSpinner = true;

    //getting all the users with the specified profile
    connectedCallback () {
        getPanelMembers ()
        .then(result => {
            
            if (result) {
                this.panelList = result;

            } else {
            }
            this.showSpinner = false;
        })
        .catch (error => {

            this.dispatchEvent(new ShowToastEvent({
                title: null,
                message: JSON.stringify(error),
                variant: 'error'
            }));
            this.showSpinner = false;
        });
    }

    //on click of the button validating and calling apex to assign users
    assignReviewers () {

        this.showSpinner = true;
        let selectedMembers = [];
        let selectedMembersElement = this.template.querySelector('c-ep_-multi-select-searchbox');

        if (selectedMembersElement && selectedMembersElement.value) {
            selectedMembers = selectedMembersElement.value.split(';');
        } else {
            selectedMembers = [];
        }

        let round = this.template.querySelector('lightning-combobox.combobox');
        let roundValue;

        if (round) {
            roundValue = round.value;
        }
        console.log('selectedMembers : ' + JSON.stringify(selectedMembers));
        console.log('selectedMembers.length : ' + selectedMembers.length);
        if (selectedMembers.length > 0 && roundValue) {
            assignPanelMembers({
                selectedPanel : selectedMembers,
                round : roundValue,
            })
            .then(result => {
                if (result == 'success') {
                    setTimeout(()=> {
                        this.dispatchEvent(new ShowToastEvent({
                            title: null,
                            message: this.assignmentSuccessMsg,
                            variant: 'success'
                        }));

                        if (round) {
                            round.value = null;
                        }
                        this.showSpinner = false;
                    }, 2000);

                } else {

                    this.dispatchEvent(new ShowToastEvent({
                        title: null,
                        message: JSON.stringify(result),
                        variant: 'error'
                    }));
                    this.showSpinner = false;

                }
            });

        } else if (roundValue) {

            this.dispatchEvent(new ShowToastEvent({
                title: null,
                message: this.selectUserMsg,
                variant: 'error'
            }));
            this.showSpinner = false;

        } else {

            this.dispatchEvent(new ShowToastEvent({
                title: null,
                message: this.selectRoundMsg,
                variant: 'error'
            }));
            this.showSpinner = false;
            
        }
    }

}