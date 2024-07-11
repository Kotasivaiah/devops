import { LightningElement, api, track } from 'lwc';
import getCandidateList from '@salesforce/apex/CandidateListPanelHelper.filterListView';

import encrypt from '@salesforce/apex/ExamPortalHelper.encryptKey';

export default class CandidateListView extends LightningElement {
    @track candidateData;
    @track nonRejectedCandidates = [];
    @track rejectedCandidates = [];
    @track waitingForHRCandidates = [];
    @track holdByHRCandidates = [];
    @track inProgressCandidates = [];
    @track holdByTRCandidates = [];
    @track filteredCandidateData = [];
    @track isSelectedTabActive = true;
    _category;
    @track noRecords = false;
    @track noHeaders = true;

    showWrittenMarks = false;
    showCodingMarks = false;
    showTrMarks = false;
    showRejectedFrom = false;
    showAssignedTo = true;
    showOnHold = false;
    showManagerRemarks = false;
    showTrRemarks = false;
    showHrRemarks = false;
    subtab = false;


    @track isProgressTabActive = true;
    @track isHoldTabActive = false;
    @track isCompleteTabActive = false;
    @track isRejectedTabActive = false;

    completedTabLabel = 'Selected';
    rejectedTabLabel = 'Rejected';
    currentTabLabel = 'In Progress';
    holdTabLabel = 'On Hold'

    @api
    set category(value) {
        console.log('category called..', value);
        this._category = value;
        this.setFlagsBasedOnCategory(value);
        this.retriveCandidates();
    }

    get category() {
        return this._category;
    }

    connectedCallback() {
        this.refreshData();
        this.intervalId = setInterval(() => {
            this.refreshData();
        }, 15000);
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

    refreshData() {
        console.log('OUTPUT :111 ');
        this.retriveCandidates();
    }

    get progressTabClass() {
        return this.isProgressTabActive ? 'slds-vertical-tabs__nav-item slds-is-active' : 'slds-vertical-tabs__nav-item';
    }

    get isProgressTabSelected() {
        return this.isProgressTabActive ? 'true' : 'false';
    }

    get holdTabClass() {
        return this.isHoldTabActive ? 'slds-vertical-tabs__nav-item slds-is-active' : 'slds-vertical-tabs__nav-item';
    }

    get isHoldTabSelected() {
        return this.isHoldTabActive ? 'true' : 'false';
    }

    get rejectedTabClass() {
        return this.isRejectedTabActive ? 'slds-vertical-tabs__nav-item slds-is-active' : 'slds-vertical-tabs__nav-item';
    }

    get isRejectedTabSelected() {
        return this.isRejectedTabActive ? 'true' : 'false';
    }

    get completedTabClass() {
        return this.isCompleteTabActive ? 'slds-vertical-tabs__nav-item slds-is-active' : 'slds-vertical-tabs__nav-item';
    }

    get isCompletedTabSelected() {
        return this.isCompleteTabActive ? 'true' : 'false';
    }

    showProgressTab() {
        this.isProgressTabActive = true;
        this.isHoldTabActive = this.isCompleteTabActive = this.isRejectedTabActive = false;
        console.log('progress Tab selected');
        this.filterCandidates();
    }

    showHoldTab() {
        this.isHoldTabActive = true;
        this.isProgressTabActive = this.isCompleteTabActive = this.isRejectedTabActive = false;
        console.log('on Hold Tab selected');
        this.filterCandidates();
    }

    showRejectedTab() {
        this.isRejectedTabActive = true;
        this.isProgressTabActive = this.isHoldTabActive = this.isCompleteTabActive = false;
        console.log('on rejected');
        this.filterCandidates();
    }

    showCompletedTab() {
        this.isCompleteTabActive = true;
        this.isProgressTabActive = this.isHoldTabActive = this.isRejectedTabActive = false;
        console.log('on selected');
        this.filterCandidates();
    }

    setFlagsBasedOnCategory(category) {
        this.showWrittenMarks = this.showCodingMarks = this.showTrMarks = this.showManagerRemarks = this.showTrRemarks = this.showHrRemarks = false;
        this.showAssignedTo = this.showOnHold = this.showRejectedFrom = false;

        switch (category) {
            case 'Technical':
                this.subtab = true;
                this.isSubtab = false;
                this.showWrittenMarks = this.showCodingMarks = true;
                
                break;
            case 'Manager':
                this.isSubtab = true;
                this.subtab = true;
                this.currentTabLabel = 'Waiting For Review';
                this.showTrRemarks = this.showWrittenMarks = this.showCodingMarks = this.showTrMarks = true;
                this.showAssignedTo = true;
                break;
            case 'Hr':
                this.subtab = true;
                this.currentTabLabel = 'Waiting For Review';
                this.isSubtab = true;
                this.showTrRemarks = true;
                this.showAssignedTo = this.showWrittenMarks = this.showCodingMarks = this.showTrMarks = this.showManagerRemarks = true;
                break;
            case 'Hold':
                this.subtab = true;
                this.isSubtab = false;
                this.showTrRemarks = this.showOnHold = this.showTrMarks = this.showHrRemarks = true;
                this.showWrittenMarks = this.showCodingMarks = this.showManagerRemarks = true;
                break;
            case 'Rejected':
                this.subtab = true;
                this.isSubtab = false;
                this.showHrRemarks = this.showTrRemarks = this.showTrMarks = this.showRejectedFrom = this.showWrittenMarks = this.showManagerRemarks = this.showCodingMarks = true;
                //this.showRejectedTab();
                break;
            case 'Selected':
                this.subtab = true;
                this.isSubtab = false;
                this.showHrRemarks = this.showAssignedTo = this.showWrittenMarks = this.showTrMarks = this.showCodingMarks = this.showManagerRemarks = this.showTrRemarks = true;
                break;
        }
    }

    setFilteredCandidateData(data) {
        this.filteredCandidateData = data.map((candidate, index) => {
            return { ...candidate, rowNumber: index + 1 };
        });
        console.log('row number :'+JSON.stringify(this.filteredCandidateData));
    }

    retriveCandidates() {
        console.log('Retrieving candidates...',this.category);
        
        getCandidateList({ filter: this.category })
            .then(result => {
                if (result) {
                    /*this.candidateData = result.map((candidate, index) => ({
                                    ...candidate,
                                    rowNumber: index + 1
                                }));      */              
                    this.candidateData = result;
                    console.log('Complete Candidate Data:22 ', JSON.stringify(this.candidateData));
                    this.filterCandidates();
                } else {
                    console.log('test');
                }
            })
            .catch(error => {
                console.error('Error retrieving candidates: ', JSON.stringify(error));
            });
    }

    completeCandidateData() {
        console.log('filtered this.isCompleteTabActive', this.isCompleteTabActive);

        if (this._category === 'Hr') {
            this.filteredCandidateData = this.candidateData.filter(candidate =>
                candidate.selectedRound === 'HR Round'
            ).map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));
        } else if (this._category === 'Manager') {
           this.filteredCandidateData = this.candidateData
                .filter(candidate =>
                    candidate.selectedRound === 'Manager Round' &&
                    candidate.onHoldRound !== 'HR Round' &&
                    candidate.rejectedRound !== 'HR Round'
                )
                .map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));
        }

        this.noHeaders = this.noRecords = this.filteredCandidateData.length === 0;
    }

    inProgressCandidateData() {
        console.log('progress TAB .....');
        if (this._category === 'Hr') {
            this.filteredCandidateData = this.candidateData.filter(candidate =>
                candidate.selectedRound === 'Manager Round' &&
                candidate.onHoldRound !== 'HR Round' &&
                !(
                    candidate.rejectedRound === 'HR Round' ||
                    candidate.rejectedRound === 'Technical Round' ||
                    candidate.rejectedRound === 'Written Test'
                )
            ).map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));
            this.noHeaders = this.noRecords = this.filteredCandidateData.length === 0;

        } else if (this._category === 'Manager') {
            this.filteredCandidateData = this.candidateData.filter(candidate =>
                candidate.selectedRound === 'Technical Round' &&
                !(
                    candidate.onHoldRound === 'Manager Round' ||
                    candidate.onHoldRound === 'Technical Round'
                ) &&
                !(
                    candidate.rejectedRound === 'Manager Round' ||
                    candidate.rejectedRound === 'Technical Round' ||
                    candidate.rejectedRound === 'Written Test'
                )
            ).map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));

            this.noHeaders = this.noRecords = this.filteredCandidateData.length === 0;
        }
        console.log('filtered isProgressTabActive:::',this.isProgressTabActive);
    }

    rejectedCandidateData() {
        if (this._category === 'Hr') {
            this.filteredCandidateData = this.candidateData
                .filter(candidate =>
                    candidate.rejectedRound === 'HR Round' &&
                    candidate.selectedRound === 'Manager Round'
                )
                .map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));
        } else if (this._category === 'Manager') {
            this.filteredCandidateData = this.candidateData.filter(candidate =>
                candidate.rejectedRound === 'Manager Round' &&
                candidate.selectedRound === 'Technical Round'
            ).map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));
        }

        this.noHeaders = this.noRecords = this.filteredCandidateData.length === 0;
        console.log('filtered isRejectedTabActive::', this.isRejectedTabActive);
    }

    holdCandidateData() {
        console.log('filtered isHoldTabActive',this.isHoldTabActive);
            
        console.log('no records ',this.noRecords);
        if (this._category === 'Hr') {
            this.filteredCandidateData = this.candidateData.filter(candidate => 
                    candidate.onHoldRound === 'HR Round' && 
                    candidate.selectedRound === 'Manager Round')
                .map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));
            this.noHeaders = this.noRecords = this.filteredCandidateData == 0 ? true: false;
        } else if (this._category === 'Manager') {
            this.filteredCandidateData = this.candidateData.filter(
                        candidate => candidate.onHoldRound === 'Manager Round' && 
                        candidate.selectedRound === 'Technical Round').map((candidate, index) => ({
                                ...candidate,
                                rowNumber: index + 1
                            }));
            this.noHeaders = this.noRecords = this.filteredCandidateData == 0 ? true: false;
        }
    }

    hrAndManagerRejectedData() {
        console.log('rejecteddd......................');
        
        this.filteredCandidateData = this.candidateData.filter(candidate =>
            (candidate.rejectedRound === 'Manager Round' || candidate.rejectedRound === 'HR Round') &&
            candidate.rejectedRound !== 'Technical Round'
        ).map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));

        if (this.filteredCandidateData.length === 0) {
            this.candidateData = null; 
        }
        
        console.log('this.filteredCandidateData', this.filteredCandidateData.length);
    }

    filterCandidates() {
        console.log('filtered candidates',this._category);
        this.noRecords = false;
        this.noHeaders = true;
        if (this.isCompleteTabActive) {
            this.completeCandidateData();
        } else if (this.isProgressTabActive) {
            this.inProgressCandidateData();
        } else if (this.isRejectedTabActive) {
            this.rejectedCandidateData();
        } else if (this.isHoldTabActive) {
            this.holdCandidateData();
        }

        if (this._category === 'Rejected') {
           this.hrAndManagerRejectedData();
        } else if (this._category === 'Selected') {
            this.filteredCandidateData = this.candidateData.filter(candidate => 
                candidate.selectedRound === 'HR Round').map((candidate, index) => ({
                    ...candidate,
                    rowNumber: index + 1
                }));
        }
    }

    openDetails(event) {
        let clickedCandidate = event.currentTarget.dataset.id;
        this.encrypt('/ExamPortal/CandidateDetails?key=', clickedCandidate + '#' + this._category);
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
                    window.open(vfPageURL, '_blank');
                }
            });
    }
}