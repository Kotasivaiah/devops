import { LightningElement, api, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPanelMembers from '@salesforce/apex/ReviewerAssignmentHelper.getPanelMembers';
import getCandidateData from '@salesforce/apex/ReviewerAssignmentHelper.getCandidateData';
import assignReviewers from '@salesforce/apex/ReviewerAssignmentHelper.assignReviewers';

import EP_No_Records from '@salesforce/label/c.EP_No_Records';
import EP_Empty_Panel_Member from '@salesforce/label/c.EP_Empty_Panel_Member';
import EP_Need_Assigments from '@salesforce/label/c.EP_Need_Assigments';
import EP_Assignment_Success from '@salesforce/label/c.EP_Assignment_Success';

export default class Ep_manualReviewerTable extends LightningElement {
    @api roundName;
    selectedPanelMember = '';
    checkeddataLength;
    selectedPanelMemberId;
    noRecordsMsg = EP_No_Records;
    selectpanelmemberMsg = EP_Empty_Panel_Member;
    assignPanelMembersMsg = EP_Need_Assigments;
    assignmentSuccessMsg = EP_Assignment_Success;
    panelMemberSelection = '';

    showSpinner = true;
    showTable = false;
    showCandidateTable = false;
    showCodingAssigner = false;

    panelList = [];
    candidateDetails = [];
    @track filteredCandidateData = [];
    @track codingEligibleCandidates = [];
    @track technicalEligibleCandidates = [];

    selectedMembers = [];
    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
                mode: mode
            });
        this.dispatchEvent(evt);
    }

    connectedCallback () {    
        this.fetchPanelData();
        this.fetchCandidateData();
    }

    fetchPanelData(){
        getPanelMembers ()
        .then(result => {
            if (result) {
                // let dummy = [];
                // result.forEach(element => {
                //     dummy.push({ checked : false, name : element.Name, Id : element.Id , disablePanelMember : false});
                // });
                console.log('result::',JSON.stringify(result));
                this.panelList = result;

            }
            this.showSpinner = false;
            this.showTable = true;
        })
        .catch (error => {
            console.log('error::',JSON.stringify(error));
            this.showSpinner = false;
        });
    }    

    fetchCandidateData(){      

        getCandidateData()
        .then(result => {
            let index = 0;
            this.candidateDetails = result.map(candidate => ({ ...candidate, checked : false,
                                                                             disableCheckbox : true,
                                                                             sno : ++index
                                                            }));      
            this.codingEligibleCandidates = this.candidateDetails.filter(candidate => candidate.codingRoundStatus === 'Completed');
            this.technicalEligibleCandidates = this.candidateDetails.filter(candidate => candidate.codingRoundStatus === 'Selected');

            if(this.roundName == 'technical'){
                this.showCodingAssigner = false;
                this.filteredCandidateData = this.technicalEligibleCandidates;                
            }else{
                this.showCodingAssigner = true;
                this.filteredCandidateData = this.codingEligibleCandidates;
            }

            if (this.filteredCandidateData.length > 0) {
                index = 0;
                if(this.roundName == 'technical'){
                    this.filteredCandidateData = [...this.filteredCandidateData].sort((a, b) => a.codingReviwedBy.localeCompare(b.codingReviwedBy));
                }else{
                    this.filteredCandidateData = [...this.filteredCandidateData].sort((a, b) => a.gender.localeCompare(b.gender));  
                    this.filteredCandidateData = [...this.filteredCandidateData].sort((a, b) => a.branch.localeCompare(b.branch));                    
                }
                this.filteredCandidateData = this.filteredCandidateData.map(candidate => ({ ...candidate,
                                                                                            sno : ++index}));
                console.log(JSON.stringify(this.filteredCandidateData));                                                                             
                this.showCandidateTable = true;
            } else {
                this.showCandidateTable = false;
            }
        })
        .catch(error =>{
            console.log('error::',JSON.stringify(error.body));
        });
    }

    handlePanelChange(event){
        this.selectedPanelMember = event.detail.value;
        this.panelMemberSelection = event.detail.type;
        console.log('event.target.type::',event.detail.type);
        console.log('this.selectedPanelMember',this.selectedPanelMember);
        console.log('this.selectedMembers::',JSON.stringify(this.selectedMembers));
        if(this.panelMemberSelection == 'disselected'){            
            this.selectedMembers = this.selectedMembers.filter(name => name !== this.selectedPanelMember);
            console.log('this.selectedMembers::',JSON.stringify(this.selectedMembers));
            this.filteredCandidateData.forEach(candidate => {
                if(this.roundName != 'technical' && (candidate.codingReviwedBy === this.selectedPanelMember) && candidate.checked == true) {
                    
                    candidate.codingReviwedBy = '';
                    candidate.checked = false;
                    if(this.template.querySelector('input[data-id="'+candidate.id+'"]').checked == true){
                        this.template.querySelector('input[data-id="'+candidate.id+'"]').checked = false;
                    }
                }else if (this.roundName == 'technical' && (candidate.technicalReviewedBy === this.selectedPanelMember) && candidate.checked == true) {
                    console.log(candidate.id,'checked::',candidate.checked);
                    
                    candidate.technicalReviewedBy = '';
                    candidate.checked = false;
                    if(this.template.querySelector('input[data-id="'+candidate.id+'"]').checked == true){
                        this.template.querySelector('input[data-id="'+candidate.id+'"]').checked = false;
                    }
                }
            });
        }else{
            this.selectedMembers = [...this.selectedMembers, this.selectedPanelMember];
            console.log('this.selectedMembers::',JSON.stringify(this.selectedMembers));
            if(this.selectedMembers.length == 1){
                this.filteredCandidateData = this.filteredCandidateData.map(candidate => ({ ...candidate,disableCheckbox : false}));
            }
        }
         //for every panel checkbox change, check if all the panel members are empty, if yes, make candidates checkboxes disable
        if(this.selectedMembers.length == 0){
            this.filteredCandidateData = this.filteredCandidateData.map(candidate => ({ ...candidate,disableCheckbox : true}));
        }
    }

    handleCandidateCheckbox(event){
        let index = event.currentTarget.dataset.index;
        if(this.filteredCandidateData[index].checked == false && this.selectedPanelMember != ''){
            this.filteredCandidateData[index].checked = true;
            if(this.roundName != 'technical'){
                this.filteredCandidateData[index].codingReviwedBy = this.selectedPanelMember;
                //this.filteredCandidateData[index].codingRoundReiewerId = this.selectedPanelMemberId;
            }else{
                this.filteredCandidateData[index].technicalReviewedBy = this.selectedPanelMember;
                //this.filteredCandidateData[index].technicalRoundReviewerId = this.selectedPanelMemberId;
            }
        }else if(this.filteredCandidateData[index].checked == true && this.selectedPanelMember != ''){
            this.filteredCandidateData[index].checked = false;
            if(this.roundName != 'technical'){
                this.filteredCandidateData[index].codingReviwedBy = '';
                //this.filteredCandidateData[index].codingRoundReiewerId = null;
            }else{
                this.filteredCandidateData[index].technicalReviewedBy = '';
                //this.filteredCandidateData[index].technicalRoundReviewerId = this.selectedPanelMemberId;
            }
        }else{
            this.ShowToast('Error', this.selectpanelmemberMsg , 'Error', 'dismissable');
        }
        console.log('this.filteredCandidateData::',JSON.stringify(this.filteredCandidateData));
    }

    handleClick(event){
        let buttonClicked = event.target.value;
        if(buttonClicked == 'unfreeze'){
            this.filteredCandidateData.forEach(item => {
                if (item.checked === true) {
                    item.disableCheckbox = false;
                }                
            });
            // this.panelList.forEach(item => {
            //     if (item.checked === true) {
            //         item.disablePanelMember = false;
            //     }
            // });        
                                                    
        }else if(buttonClicked == 'freeze'){
            this.filteredCandidateData.forEach(item => {
                if ((item.checked === true && (item.technicalReviewedBy != '' || item.technicalReviewedBy != undefined)) 
                    || item.disableCheckbox == true) {
                    item.disableCheckbox = true;
                }else{
                    item.disableCheckbox = false;
                }
            });
            // this.panelList.forEach(item => {
            //     if (item.checked === true || item.disablePanelMember == true) {
            //         item.disablePanelMember = true;
            //     }else{
            //         item.disablePanelMember = false;
            //     }
            // });            
                                                    
        }else{
            //while saving check if there are any candidates with no reviewers assigned, if yes, show toaster
            if(this.roundName == 'technical'){             
                this.checkeddataLength = this.filteredCandidateData.filter(candidate => (candidate.technicalReviewedBy === '' || 
                                                                                         candidate.technicalReviewedBy === undefined)).length;
            }else{
                this.checkeddataLength = this.filteredCandidateData.filter(candidate => (candidate.codingReviwedBy === '' ||
                                                                                         candidate.codingReviwedBy === undefined)).length;
            }
            if(this.checkeddataLength != 0){
                this.ShowToast('Error', this.assignPanelMembersMsg , 'Error', 'dismissable');
            }else{
                assignReviewers({candidates : this.filteredCandidateData.filter(candidate => candidate.checked === true), panelMembersList : this.selectedMembers})
                .then(result => {
                    this.ShowToast('Success', this.assignmentSuccessMsg , 'success', 'dismissable');    
                    const customEvent = new CustomEvent('callclosemodal');
                    this.dispatchEvent(customEvent);
                })
                .catch(error => {
                    console.log('error::',JSON.stringify(error));
                })
            }
        }
    }

    // handlePanelChange(event){
    //     console.log('event.target.type::',event.detail.type);
    //     console.log('event.target.value::',event.detail.value);
    // }
}