import { LightningElement, api, track } from 'lwc';

import getCandidateCompleteddata from '@salesforce/apex/CodingReviewController.getCandidateCompleteddata';
import updateReviewer from '@salesforce/apex/CodingReviewController.updateReviewer';
import encrypt from '@salesforce/apex/ExamPortalHelper.encryptKey';
import userId from '@salesforce/user/Id';

export default class Ep_recordTabset extends LightningElement {

    @track filteredCandidateData = [];
    @track waitingForReviewData = [];
    @track onHoldData = [];
    @track selectedCandidateData = [];
    @track otherUserSelectedCandidateData = [];
    @track rejectedCandidatedData = [];

    tabs = [
        'Waiting for review',
        'On Hold',
        'Selected',
        'Rejected'
    ];

    candidatDetails;
    showCandidatesData = false;
    showCodingData = false;
    showCodingMarks = false;
    showWrittenMarks = true;
    showCodingReviewer = true;
    showShareRecord = true;

    showTable = false;
    showErrorMessage = false;
    isProgressTabActive = true;
    isHoldTabActive = false;
    currentTabLabel = 'Waiting For Review';
    holdTabLabel = 'On Hold';
    completedTabLabel = 'Completed';

    filter = {
        criteria: [
            {
                fieldPath: 'Department',
                operator: 'eq',
                value: 'Salesforce',
            },
        ],
    };


    connectedCallback() {
        this.fetchCodingRoundData();

    }

    fetchCodingRoundData(){      

        getCandidateCompleteddata()
        .then(result => {
            this.showUserSelection = false;
            let index = 0;
            this.candidatDetails = result.map(candidate => ({ ...candidate, showClickHere : false, 
                                                                            showUserSelection: false
                                                            }));

            this.selectedCandidateData = this.candidatDetails.filter(candidate => (candidate.codingRoundStatus === 'Selected') &&
                                                                                    candidate.codingRoundReiewerId === userId)
                                        .map(candidate => ({ ...candidate, showClickHere : false, 
                                                                            showUserSelection: false,
                                                                            sno : ++index}));

            this.otherUserSelectedCandidateData = this.candidatDetails.filter(candidate => (candidate.codingRoundStatus === 'Selected') &&
                                                                                    candidate.codingRoundReiewerId !== userId)
                                        .map(candidate => ({ ...candidate, showClickHere : false, 
                                                                            showUserSelection: false,
                                                                            sno : ++index}));

            index = 0;
            this.rejectedCandidatedData = this.candidatDetails.filter(candidate => (candidate.codingRoundStatus === 'Rejected'))
                                        .map(candidate => ({ ...candidate, showClickHere : false, 
                                                                            showUserSelection: false,
                                                                            sno : ++index}));
            index = 0;
            this.onHoldData = this.candidatDetails.filter(candidate => candidate.codingRoundStatus === 'On Hold')
                            .map(candidate => ({ ...candidate, showClickHere : false, 
                                                                            showUserSelection: false,
                                                                            sno : ++index}));

            index = 0;
            this.waitingForReviewData = this.candidatDetails.filter(candidate => candidate.codingRoundStatus === 'Completed' &&
                                                                                    candidate.codingRoundReiewerId === userId)
                                        .map(candidate => ({ ...candidate, showClickHere : true, 
                                                                            showUserSelection: false,
                                                                            sno : ++index}));

            this.filteredCandidateData = this.waitingForReviewData;

            if (this.filteredCandidateData.length > 0) {
            this.showTable = true;
        } else {
            this.showTable = false;
        }
        })
        .catch(error =>{
            console.log('error::',JSON.stringify(error.body));
        });
    }

    handleActive (event) {
        const tabName = event.target.value;
        if (tabName == 'Waiting for review') {
            this.showCodingMarks = false;
            this.filteredCandidateData = this.waitingForReviewData;
            this.showShareRecord = true;

        } else if (tabName == 'On Hold') {
            this.showCodingMarks = true;
            this.filteredCandidateData = this.onHoldData;
            this.showShareRecord = false;

        } else if (tabName == 'Selected') {
            
            this.showCodingMarks = true;
            this.showShareRecord = false;
            this.filteredCandidateData = [...this.selectedCandidateData, ...this.otherUserSelectedCandidateData];

        } else if (tabName == 'Rejected') {

            this.showCodingMarks = true;
            this.showShareRecord = false;
            this.filteredCandidateData = this.rejectedCandidatedData;

        }
        if (this.filteredCandidateData.length > 0) {
            this.showTable = true;
        } else {
            this.showTable = false;
        }
    }

    openDetails (event) {
        console.log('event::',JSON.stringify(event.currentTarget.dataset.id));
        let clickedCandidate = event.currentTarget.dataset.id;
        this.encrypt('/apex/CodingRoundReview?key=', clickedCandidate + '#' + this.viewer);        
    }

    handleRecordPickerChange(event) {
        const candidateId = event.target.dataset.candidateId;
        const selectedUserId = event.detail.recordId;
        this.filteredCandidateData = this.filteredCandidateData.map(candidate => {
            if (candidate.id === candidateId) {
                return { ...candidate, selectedUserId };            
                }
            return candidate;
        });
    }

    handleSuccess(event){
        const candidateId = event.currentTarget.dataset.id;
        const candidateIndex = this.filteredCandidateData.findIndex(candidate => candidate.id === candidateId);  

        updateReviewer({candidateId : candidateId, userId : this.filteredCandidateData[candidateIndex].selectedUserId})
        .then(result => {
            this.fetchCodingRoundData();
        })
        .catch(error => {
            console.log('error::',error.body);
        });         
    }

    handleCancel(event){
        const candidateId = event.target.dataset.id;
        const candidateIndex = this.filteredCandidateData.findIndex(candidate => candidate.id === candidateId);
        if (candidateIndex !== -1) {
            this.filteredCandidateData = this.filteredCandidateData.map((candidate, index) => {
                if (index === candidateIndex) {
                    return { ...candidate, showClickHere: true, showUserSelection: false };
                }
                return candidate;
            });
        }
    }

    handleclickhere (event) {
        event.preventDefault();
        const candidateId = event.target.dataset.id;
        this.filteredCandidateData = this.filteredCandidateData.map(candidate => {
            if (candidate.id === candidateId) {
                return { ...candidate, showClickHere: false, showUserSelection: true };
            }
            return candidate;
        });
    }

    encrypt (baseUrl, value) {
        console.log('value : ' + value);
        let returnValue;
        encrypt ({valueToEncrypt : value})
            .then (result => {
                if (result[0] == 'error') {
                    console.log(result[1]);
                } else if (result[0] == 'success') {
                    let vfPageURL = baseUrl+result[1];
                    window.open(vfPageURL, '_self','height='+this.height+',width='+this.width+','+this.urlSpecifications);
                }
            });
    }

    // <!--{candidate.reviwedby}-->
}