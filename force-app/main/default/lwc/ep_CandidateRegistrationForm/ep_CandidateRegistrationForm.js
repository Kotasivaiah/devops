/*
Description: Used for gathering candidate data
Class name: CandidateRegistration
*/

import { LightningElement, track } from 'lwc';

import apply from '@salesforce/apex/CandidateRegistration.registerCandidate';
import getPicklistValues from '@salesforce/apex/CandidateRegistration.getPicklistValues';
import PROGRAMMINGLANGUAGES from '@salesforce/label/c.EP_Programming_Language_List';

import LEAD_GENDER from '@salesforce/schema/Lead.Gender__c';
import LEAD_SPOKEN_LANGUAGES from '@salesforce/schema/Lead.Languages_Spoken__c';
import LEAD_BRANCH from '@salesforce/schema/Lead.Branch__c';
import LEAD_INTER_BRANCH from '@salesforce/schema/Lead.Intermediate_Polytechnic_Branch__c';
import LEAD_PG_BRANCH from '@salesforce/schema/Lead.Post_Graduate_Branch__c';

import LOCATIONIMAGE from '@salesforce/label/c.EP_GoogleLocationImage';
import WRONGFORMAT from '@salesforce/label/c.EP_Registration_WrongFormat';
import REQUIRED from '@salesforce/label/c.EP_Registration_RequiredField';
import OFFICEADDRESS from '@salesforce/label/c.EP_OfficeAddress';
import OFFLOCATION from '@salesforce/label/c.EP_OfficeLocation';

export default class Ep_CandidateRegistrationForm extends LightningElement {

    @track programmingLanguages = [];
    @track gender = [];
    @track languages = [];
    @track branch = [];
    @track pgBranch = [];
    @track interBranch = [];
    @track invalidFields = [];
    @track emptyFields = [];
    @track pgPassingYear = [];
    @track graduationPassingYear = [];
    @track interPassingYear = [];
    @track schoolPassingYear = [];

    fieldNames = {
        firstName: 'First Name',
        lastName: 'Last Name',
        dob: 'Date Of Birth',
        gender: 'Gender',
        mobileNumber: 'Mobile Number',
        altMobileNumber: 'Alternative Number',
        email: 'Email',
        sl: 'Spoken Languages',
        caddress: 'Current Address',
        paddress: 'Permanent Address',
        collegeName: 'Graduation College Name',
        gYear: 'Graduation Passing Year',
        gHallTicketNumber: 'Graduation HallTicket Number',
        gPercent: 'Graduation Percentage',
        branch : 'Graduation Branch',
        interName: 'Inter/Diploma College Name',
        interPercent: 'Inter/Diploma Percentage',
        interYear: 'Inter/Diploma Passing Year',
        interBranch: 'Inter/Diploma Branch',
        schoolPercent: 'School Percentage',
        schoolYear: 'School Passing Year',
        schoolName: 'School Name',
        pl: 'Programming Languages',
        pgName: 'PG College Name',
        pgBranch: 'PG Branch',
        pgYear: 'PG Passing Year',
        pgHallTicketNumber: 'PG Hallticket No.',
        pgPercent: 'PG Percentage',
        othergender : 'Gender',
        otherpgBranch : 'PG Branch',
        otherbranch : 'Graduation Branch',
        otherinterBranch : 'Inter/Diploma stream',
        othersl : 'Other Spoken Languages',
    };

    requiredError = REQUIRED;
    invalid = WRONGFORMAT;
    emptyError = '  ';
    officeLocation;
    locationImage = LOCATIONIMAGE;
    params = new Map();
    officeAddress = [];

    showPlError;
    showLangError;
    isSubmitted = false;
    hasErrors;
    haveSfKnowledge;
    showSpinner = true;

    // fetching picklist values and custom labels
    connectedCallback() {

        let payload = [];
        let currentYear = new Date().getFullYear();

        let graduationPassingYearDummy = [{ label : 'None', value : '' }];
        let pgPassingYearDummy = [{ label : 'None', value : '' }];
        let interPassingYearDummy = [{ label : 'None', value : '' }];
        let schoolPassingYearDummy = [{ label : 'None', value : '' }];

        for (let ele = currentYear+1; ele >= currentYear-10; ele--) {
            graduationPassingYearDummy.push({ label: JSON.stringify(ele), value: JSON.stringify(ele) });
            pgPassingYearDummy.push({ label: JSON.stringify(ele), value: JSON.stringify(ele) });
            if (ele <= currentYear) {
                interPassingYearDummy.push({ label: JSON.stringify(ele), value: JSON.stringify(ele) });
                schoolPassingYearDummy.push({ label: JSON.stringify(ele), value: JSON.stringify(ele) });
            }
        }

        this.pgPassingYear = pgPassingYearDummy;
        this.graduationPassingYear = graduationPassingYearDummy;
        this.interPassingYear = interPassingYearDummy;
        this.schoolPassingYear = schoolPassingYearDummy;

        payload.push({ 'sobjectName': LEAD_GENDER.objectApiName, 'fieldName': LEAD_GENDER.fieldApiName });
        payload.push({ 'sobjectName': LEAD_SPOKEN_LANGUAGES.objectApiName, 'fieldName': LEAD_SPOKEN_LANGUAGES.fieldApiName });
        payload.push({ 'sobjectName': LEAD_BRANCH.objectApiName, 'fieldName': LEAD_BRANCH.fieldApiName });
        payload.push({ 'sobjectName': LEAD_INTER_BRANCH.objectApiName, 'fieldName': LEAD_INTER_BRANCH.fieldApiName });
        payload.push({ 'sobjectName': LEAD_PG_BRANCH.objectApiName, 'fieldName': LEAD_PG_BRANCH.fieldApiName });

        getPicklistValues({ fieldsAndObjects: payload })
            .then(result => {
                try {
                    for (let key in result) {
                        if (key == 'Gender__c') {
                            let mapoptions = [{label : 'None', value : ''}];
                            result[key].forEach(ele => {
                                mapoptions.push({ label: ele, value: ele });
                            });
                            this.gender = mapoptions;
                        } else if (key == 'Languages_Spoken__c') {
                            this.languages = [...result[key]];
                        } else if (key == 'Branch__c') {
                            let mapoptions = [{label : 'None', value : ''}];
                            result[key].forEach(ele => {
                                mapoptions.push({ label: ele, value: ele });
                            });
                            this.branch = mapoptions;
                        } else if (key == 'Intermediate_Polytechnic_Branch__c') {
                            let mapoptions = [{label : 'None', value : ''}];
                            result[key].forEach(ele => {
                                mapoptions.push({ label: ele, value: ele });
                            });
                            this.interBranch = mapoptions;
                        } else if (key == 'Post_Graduate_Branch__c') {
                            let mapoptions = [{label : 'None', value : ''}];
                            result[key].forEach(ele => {
                                mapoptions.push({ label: ele, value: ele });
                            });
                            this.pgBranch = mapoptions;
                        }
                    }
                    this.programmingLanguages = PROGRAMMINGLANGUAGES.split(';;');
                } catch (exception) {
                    console.log('Error in getPicklistValues try: ' + JSON.stringify(exception));
                    this.showSpinner = false;
                }
            })
            .catch(error => {
                console.log('Error in getPicklistValues: ' + JSON.stringify(error));
                this.showSpinner = false;
            });

        this.officeLocation =  OFFLOCATION;
        this.officeAddress =  OFFICEADDRESS.split(';;');
        this.showSpinner = false;
    }

    // Checkbox functionality of current and permanent address
    togglePermanantAddress(event) {

        const paddress = this.template.querySelector('.slds-input[name = "paddress"]');
        const caddress = this.template.querySelector('.slds-input[name = "caddress"]');

        if (event.target.checked) {
            if (paddress && caddress) {
                paddress.value = caddress.value;
                paddress.disabled = true;
            }
        } else {
            if (paddress) {
                paddress.disabled = false;
            }
        }
    }

    // When clicked on Register button
    handleApply() {
        this.showSpinner = true;
        this.hasErrors = false;

        this.invalidFields = [];
        this.emptyFields = [];

        //validating required fields
        let inputList = this.template.querySelectorAll('.field');

        if (inputList.length > 0) {
            inputList.forEach(element => {
                const invalid = this.template.querySelector('.' + element.name + 'invalid');
                const empty = this.template.querySelector('.' + element.name);
                let other = this.template.querySelector('._'+element.name);
                let emptyError = this.template.querySelector('pre.'+element.name + 'empty');
                if (this.isNull(element.value)) {
                    this.hasErrors = false || this.hasErrors;
                    if (empty) {
                        empty.classList.add('slds-hide');
                    }
                    if (emptyError) {
                        emptyError.classList.remove('slds-hide');
                    }
                    if (element.name == 'firstName') {
                        this.validate(this.isValidName, element);
                    } else if (element.name == 'lastName') {
                        this.validate(this.isValidName, element);
                    } else if (element.name == 'dob') {
                        this.validate(this.isNull, element);
                    } else if (element.name == 'gender') {
                        this.validate(this.isNull, element);
                    } else if (element.name == 'otherpgBranch') {
                        if (other && !other.classList.contains('slds-hide')) {
                            this.validate(this.isValidName, element);
                        } else {
                            element.value = null;
                        }
                    } else if (element.name == 'othersl') {
                        if (other && !other.classList.contains('slds-hide')) {
                            this.validate(this.isNull, element);
                        } else {
                            element.value = null;
                        }
                    } else if (element.name == 'otherbranch') {
                        if (other && !other.classList.contains('slds-hide')) {
                            this.validate(this.isValidName, element);
                        } else {
                            element.value = null;
                        }
                    } else if (element.name == 'otherinterBranch') {
                        if (other && !other.classList.contains('slds-hide')) {
                            this.validate(this.isValidName, element);
                        } else {
                            element.value = null;
                        }
                    } else if (element.name == 'mobileNumber') {
                        this.validate(this.isValidPhone, element);
                    } else if (element.name == 'email') {
                        this.validate(this.isValidEmail, element);
                    } else if (element.name == 'sl') {
                        this.validate(this.isNull, element);
                    } else if (element.name == 'caddress') {
                        this.validate(this.isNull, element);
                    } else if (element.name == 'branch') {
                        this.validate(this.isNull, element);
                    } else if (element.name == 'collegeName') {
                        this.validate(this.isValidName, element);
                    } else if (element.name == 'gYear') {
                        this.validate(this.isValidYear, element);
                    } else if (element.name == 'gPercent') {
                        this.validate(this.isValidPercentage, element);
                    } else if (element.name == 'gHallTicketNumber') {
                        this.validate(this.isValidHtNumber, element);
                    } else if (element.name == 'interName') {
                        this.validate(this.isValidName, element);
                    } else if (element.name == 'interPercent') {
                        this.validate(this.isValidPercentage, element);
                    } else if (element.name == 'interBranch') {
                        this.validate(this.isNull, element);
                    } else if (element.name == 'interYear') {
                        this.validate(this.isValidYear, element);
                    } else if (element.name == 'schoolName') {
                        this.validate(this.isValidName, element);
                    } else if (element.name == 'schoolPercent') {
                        this.validate(this.isValidPercentage, element);
                    } else if (element.name == 'schoolYear') {
                        this.validate(this.isValidYear, element);
                    } else if (element.name == 'pl') {
                        this.validate(this.isNull, element);
                    }
                } else {
                    if (other) {

                        if (!other.classList.contains('slds-hide')) {

                            this.emptyFields.push(this.fieldNames[element.name]);
                            this.hasErrors = true;

                            if (invalid) {
                                invalid.classList.add('slds-hide');
                            }
                            if (empty) {
                                empty.classList.remove('slds-hide');
                            }
                            if (emptyError) {
                                emptyError.classList.add('slds-hide');
                            }
                        }
                    } else {

                        this.emptyFields.push(this.fieldNames[element.name]);
                        this.hasErrors = true;

                        if (invalid) {
                            invalid.classList.add('slds-hide');
                        }
                        if (empty) {
                            empty.classList.remove('slds-hide');
                        }
                        if (emptyError) {
                            emptyError.classList.add('slds-hide');
                        }
                    }
                }
            });
        }

        //validating post graduation Fields
        inputList = this.template.querySelectorAll('.pgfield');

        let isPgRequired = false;

        if (inputList.length > 0) {

            inputList.forEach(element => {

                if (this.isNull(element.value)) {

                    isPgRequired = true;

                }
            });
        }

        if (isPgRequired) {

            if (inputList.length > 0) {

                inputList.forEach(element => {

                    const invalid = this.template.querySelector('.' + element.name + 'invalid');
                    const empty = this.template.querySelector('.' + element.name);
                    let emptyError = this.template.querySelector('pre.'+element.name + 'empty');

                    if (this.isNull(element.value)) {

                        this.hasErrors = false || this.hasErrors;

                        if (empty) {

                            empty.classList.add('slds-hide');
                        }

                        if (emptyError) {

                            emptyError.classList.remove('slds-hide');
                        }

                        if (element.name == 'pgName') {
                            this.validate(this.isValidName, element);
                        } else if (element.name == 'pgYear') {
                            this.validate(this.isValidYear, element);
                        } else if (element.name == 'pgBranch') {
                            this.validate(this.isNull, element);
                        } else if (element.name == 'pgHallTicketNumber') {
                            this.validate(this.isValidHtNumber, element);
                        } else if (element.name == 'pgPercent') {
                            this.validate(this.isValidPercentage, element);
                        }
                    } else {
                        this.emptyFields.push(this.fieldNames[element.name]);
                        this.hasErrors = true;
                        if (invalid) {
                            invalid.classList.add('slds-hide');
                        }
                        if (empty) {
                            empty.classList.remove('slds-hide');
                        }
                        if (emptyError) {
                            emptyError.classList.add('slds-hide');
                        }
                    }
                });
            }
        } else {
            inputList.forEach(element => {

                const invalid = this.template.querySelector('.' + element.name + 'invalid');
                const empty = this.template.querySelector('.' + element.name);
                const emptyError = this.template.querySelector('pre.'+element.name + 'empty');

                //clearing values from the parameter object
                if (this.params.has(element.name)) {
                    this.params.delete(element.name);
                }

                if (invalid) {
                    invalid.classList.add('slds-hide');
                }

                if (empty) {
                    empty.classList.add('slds-hide');
                }

                if (emptyError) {
                    emptyError.classList.remove('slds-hide');
                }
            });
        }

        //validating permanent Address
        const paddress = this.template.querySelector('.slds-input[name = "paddress"]');
        const checkbox = this.template.querySelector('input[name="pcheckbox"]');
        const empty = this.template.querySelector('.' + paddress.name);

        if (checkbox && paddress) {

            if (!checkbox.checked && !this.isNull(paddress.value)) {

                this.hasErrors = true;
                this.emptyFields.push(this.fieldNames[paddress.name]);
                if (empty) {

                    empty.classList.remove('slds-hide');
                }
            } else {

                this.params.set(paddress.name, paddress.value);

                if (empty) {
                    empty.classList.add('slds-hide');
                }
                this.hasErrors = false || this.hasErrors;
            }
        }
        //adding otherr skills to the programming languages
        let otherSkills = this.template.querySelector('.slds-input[name="otherLanguages"]');
        let otherSkillsValue;

        if (otherSkills) {

            otherSkillsValue = otherSkills.value;
        }

        if (otherSkillsValue) {

            if (otherSkillsValue.includes(',')) {   

                if (this.params.has('pl')) {

                    this.params.set('pl', this.params.get('pl') + ';' + otherSkillsValue.split(',').join(';'));
                }
            } else {

                this.params.set('pl',otherSkillsValue+';'+this.params.get('pl'));
            }
        }

        //validating alternative mobile
            const altMobileNumber = this.template.querySelector('input.slds-input[name="altMobileNumber"]');
            if (altMobileNumber) {
                if (altMobileNumber.value) {
                    this.validate(this.isValidPhone, altMobileNumber);
                }
            }

        //showing toasters
        if (this.hasErrors) {

            const toasterList = this.template.querySelectorAll('c-custom-toaster');
            const toasterOne = toasterList[0];
            const toasterTwo = toasterList[1];

            if (this.emptyFields.length > 0) {

                if (toasterOne) {

                    if (this.emptyFields.length > 10) {

                        toasterOne.showToast('error', '<strong>Please fill these field(s) :</strong> <br>' + this.emptyFields.slice(0, 10).join(',') 
                        + '...', 'utility:warning', 4000);

                    } else {

                        toasterOne.showToast('error', '<strong>Please fill these field(s) : </strong><br>' + this.emptyFields.join(','), 'utility:warning', 4000);
                    }
                }
            }

            if (this.invalidFields.length > 0) {

                if (this.emptyFields.length == 0) {

                    if (this.invalidFields.length > 10) {

                        toasterOne.showToast('error', '<strong>Please Enter the correct format : </strong><br>' + this.invalidFields.slice(0, 10).join(',') 
                        + '...', 'utility:warning', 4000);

                    } else {

                        toasterOne.showToast('error', '<strong>Please Enter the correct format : </strong><br>' + this.invalidFields.join(','),
                         'utility:warning', 4000);

                    }
                } else {
                    if (this.invalidFields.length > 10) {

                        toasterTwo.showToast('error', '<strong>Please Enter the correct format : </strong><br>' + this.invalidFields.slice(0, 10).join(',') 
                        + '...', 'utility:warning', 4000);

                    } else {

                        toasterTwo.showToast('error', '<strong>Please Enter the correct format : </strong><br>' + this.invalidFields.join(','),
                         'utility:warning', 4000);
                    }
                }
            }
            this.showSpinner = false;
        } else {
            let payload = Object.fromEntries(this.params.entries());
            apply({ detailObject: payload })

                .then(result => {

                    if (result == 'success') {

                        this.isSubmitted = true;

                        window.scrollTo(0, 0);

                        setTimeout( () => {

                            window.open('https://www.bigworks.co', '_self');
                        }, 10000);

                    } else {

                        this.template.querySelector("c-custom-toaster").showToast('error', result, 'utility:warning', 4000);
                    }
                    this.showSpinner = false;
                })
                .catch(error => {

                    console.log('Error in apply: ' + JSON.stringify(error));
                    this.showSpinner = false;
                    
                });
        }
    }

    //validates field values and address validations if needed
    validate(isValid, element) {

        let value = element.value;
        let name = element.name;
        let invalid = this.template.querySelector('.' + name + 'invalid');

        if (!isValid(value)) {

            this.hasErrors = true;

            if (invalid) {
                invalid.classList.remove('slds-hide');
            }

            this.invalidFields.push(this.fieldNames[name]);
        } else {

            this.hasErrors = false || this.hasErrors;

            this.params.set(name, value);

            if (invalid) {

                invalid.classList.add('slds-hide');
            }
        }
    }

    // Null checking
    isNull(str) {
        return (str != null && str != '' && str != undefined);
    }

    // Name checking
    isValidName = (text) => {

        var regex = /^[a-zA-Z\s]+$/;
        return regex.test(text);
    }

    // Email checking
    isValidEmail = (email) => {

        var validRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$/;
        return validRegex.test(email);
    }

    // Year checking
    isValidYear = (number) => {

        var rgx = /^\d{4}$/;
        return rgx.test(number);
    }

    // Phone checking
    isValidPhone = (number) => {

        var rgx = /^\d{10}$/;
        return rgx.test(number);
    }

    // Address checking
    isValidAddress = (address) => {

        var rgx = /^[a-zA-Z0-9\-/',.\s]+$/;
        return rgx.test(address);
    }

    // Hall ticket checking
    isValidHtNumber = (htNumber) => {

        var rgx = /^[a-zA-Z0-9]+$/;
        return rgx.test(htNumber);
    }

    // Percentage checking
    isValidPercentage = (percent) => {

        var rgx = /^(100(\.0+)?|[0-9]?[0-9](\.[0-9]+)?)$/;
        return rgx.test(percent);
    }

    // Show input box if other is selected in picklist
    handlePicklistChange (event) {

        if (event.detail.value == 'Other') {

            let elementList = this.template.querySelectorAll('._other'+event.target.name);
            if (elementList.length > 0) {

                elementList.forEach(ele => {
                    ele.classList.remove('slds-hide');
                });
            }
        } else {
            let elementList = this.template.querySelectorAll('._other'+event.target.name);
            let childElementList = this.template.querySelectorAll('.slds-input[name = "other'+event.target.name+'"]');

            if (childElementList.length > 0) {

                childElementList.forEach(ele => {
                    if (this.params.has(ele.name)) {
                        this.params.delete(ele.name);
                    }
                });
            }
            if (elementList.length > 0) {
                // let otherPgBranch = this.template.querySelector('.slds-input.field[name = "otherpgBranch"]');
                // if (otherPgBranch) {
                //     otherPgBranch.value = null;
                // }
                elementList.forEach(ele => {
                    ele.classList.add('slds-hide');
                });
            }
        }
    }

    // When clicked on cancel button
    handleCancel () {

        window.open('https://www.bigworks.co','_self');
    }

    // Show input box if other is selected in multiselect picklist
    handleCustomPicklistChange (event) {

        if (event.detail.type == 'disselected' && event.detail.value == 'Other') {

            let elementList = this.template.querySelectorAll('._othersl');

            if (elementList.length > 0) {

                elementList.forEach(ele => {
                    ele.classList.add('slds-hide');
                });
            }
        } else if (event.detail.type == 'selected' && event.detail.value == 'Other') {

            let elementList = this.template.querySelectorAll('._othersl');

            if (elementList.length > 0) {

                elementList.forEach(ele => {
                    ele.classList.remove('slds-hide');
                });
            }
        }
    }
}