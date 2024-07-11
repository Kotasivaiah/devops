import { LightningElement, track, api } from 'lwc';
export default class Ep_MultiSelectSearchbox extends LightningElement {

    @track _options = [];
    @track selectedvalues = [];
    @track originalList = [];
    @api required = false;
    @api errorMessage = '';
    @api label = 'testLabel';
    hasChoices = false;

    showPills = false;
    _showError = false;
    selectedMessage;
    showdropdown;

    @api
    set value(selectedOptions) {
    }
    get value() {
        if (this.selectedvalues.length > 0) {
            return this.selectedvalues.join(';');
        } else {
            return null;
        }
    }

    @api
    set options(values) {
        if (values) {
            values.forEach(option => {
                // this._options.push({ 'value': option, 'isSelected': false });
                this.originalList.push({ 'value': option, 'isSelected': false });
            });
        }
    }
    get options() {
        return this._options;
    }

    @api
    set showError(value) {
        this._showError = value;
    }
    get showError() {
        return this._showError;
    }

    handleFilterCandidates(event) { 
        this.showdropdown = true;
        let searchString = event.target.value;
        if (searchString != undefined && searchString != null && searchString != '') {
            this._options = [];
            this._options = this.originalList.filter(name => {
                if (name.value.includes(searchString)) {
                    return name;
                }
            });
            if (this._options.length > 0) {
                this.hasChoices = true;
            } else {
                this.hasChoices = false;
            }
        } else {
            this._options = [];
            this.hasChoices = false;
        }
    }

    handleShowDropdown () {
        this.showdropdown = true;
    }

    checkLength() {
        if (this.selectedvalues.length > 0) {
            this.showPills = true;
        } else {
            this.showPills = false;
        }
    }

    optionClicked(event) {
        let selectedIndex = event.currentTarget.dataset.index;
        let option = this._options[selectedIndex].value;

        if (this.selectedvalues.includes(option)) {
            this._options[selectedIndex]['isSelected'] = false;
            this.selectedvalues.splice(this.selectedvalues.indexOf(option), 1);
            this.dispatchEvent(new CustomEvent("panelchange", {
                detail: {
                    type: 'disselected',
                    value: option,
                },
            }));
            for (let i = 0; i < this.originalList.length; i++) {
                if (this.originalList[i].value === option) {
                    this.originalList[i].isSelected = false;
                    break;
                }
            }
        } else {
            this._options[selectedIndex]['isSelected'] = true;
            this.selectedvalues.push(option);
            this.dispatchEvent(new CustomEvent("panelchange", {
                detail: {
                    type: 'selected',
                    value: option,
                },
            }));
            for (let i = 0; i < this.originalList.length; i++) {
                if (this.originalList[i].value === option) {
                    this.originalList[i].isSelected = true;
                    break;
                }
            }
        }
        this.checkLength();
    }

    handleShowdropdown() {
        if (this.showdropdown) {
            this.showdropdown = false;
        } else {
            this.showdropdown = true;
        }
    }

    handleLeave(event) {
        this.showdropdown = false;
    }

    closePill(event) {
        let selection = event.target.dataset.value;

        console.log('this.selectedvalues : ' + this.selectedvalues);
        console.log('selection : ' + selection);
        let pillIndex = this.selectedvalues.indexOf(selection);
        this.selectedvalues.splice(pillIndex, 1);

        for (let i = 0; i < this.originalList.length; i++) {
            if (this.originalList[i].value === selection) {
                this.originalList[i].isSelected = false;
                break;
            }
        }

        this.dispatchEvent(new CustomEvent("panelchange", {
            detail: {
                type: 'disselected',
                value: selection,
            },
        }));
        this.checkLength();
    }

}