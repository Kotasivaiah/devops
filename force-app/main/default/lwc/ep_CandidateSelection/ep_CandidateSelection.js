/*
    Description: Used to select eligible candidates and mail the list to the email addresses
    Class name: CandidateReportData
*/

import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchReportNames from '@salesforce/apex/CandidateReportData.fetchReportNames';
import getReportData from '@salesforce/apex/CandidateReportData.getReportData';
import updateStatus from '@salesforce/apex/CandidateReportData.updateStatus';

export default class Ep_CandidateSelection extends LightningElement {

    candidateReportNames = [];
    candidateIds = [];

    showSpinner = true;

    connectedCallback () {

        fetchReportNames()
            .then(result => {

                console.log(result);
                this.candidateReportNames = result;
                this.showSpinner = false;
            })
            .catch(error => {

                console.log('Error in fetchReportNames: ' + JSON.stringify(error));
                this.showSpinner = false;
            });
    }

    //to update the selected records and mail colleges
    handleUpdateAndSend (event) {

        this.showSpinner = true;

        let emailAddresses = [];

        let textArea = this.template.querySelector('textarea.slds-input');
        let combobox = this.template.querySelector('lightning-combobox.combobox');

        let comboboxValue;
        
        if (combobox) {

            comboboxValue = combobox.value;
        }

        if (textArea && textArea.value) {

            emailAddresses = textArea.value.split(';');
        }

        console.log('emailAddresses : ' + JSON.stringify(emailAddresses.length));
        
        if (emailAddresses.length > 0 && comboboxValue) {

            getReportData ({
                reportName: comboboxValue,
            })
            .then ( result => {

                this.candidateIds = result;

                if (this.candidateIds.length > 0) {
        
                updateStatus({
                    ids : result,
                    roundName : comboboxValue,
                    emailAddresses : emailAddresses,
                })
                .then ( result => {

                    if (result == 'success') {

                        this.dispatchEvent(new ShowToastEvent({
                            title: null,
                            message: 'Updated Status Successfully',
                            variant: 'success'
                        }));
                        if (textArea) {
                            textArea.value = '';
                        }

                        if (combobox) {
                            combobox.value = null;
                        }


                    } else {
                        this.dispatchEvent(new ShowToastEvent({
                            title: null,
                            message: result,
                            variant: 'error'
                        }));
                    }
                    this.showSpinner = false;
                })
                .catch ( error => {

                    console.log('Error in updateStatus: ' + JSON.stringify(error));

                    this.dispatchEvent(new ShowToastEvent({
                            title: 'Unknown Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        }));

                    this.showSpinner = false;
                });
            } else {

                this.dispatchEvent(new ShowToastEvent({
                    title: null,
                    message: 'No Rows in the Reports',
                    variant: 'error'
                }));
                
                this.showSpinner = false;
            }

            })
            .catch ( error => {

                console.log('Error in getReportData: ' + JSON.stringify(error));
                this.dispatchEvent(new ShowToastEvent({
                            title: null,
                            message: JSON.stringify(error),
                            variant: 'error'
                        }));
                this.showSpinner = false;
            });

        } else if (emailAddresses.length == 0 && comboboxValue) {

            this.dispatchEvent(new ShowToastEvent({
                title: null,
                message: 'Please enter email address',
                variant: 'error'
            }));

            this.showSpinner = false;

        } else if (!comboboxValue) {

            this.dispatchEvent(new ShowToastEvent({
                title: null,
                message: ' Please select a report',
                variant: 'error'
            }));

            this.showSpinner = false;
        }

    }
}