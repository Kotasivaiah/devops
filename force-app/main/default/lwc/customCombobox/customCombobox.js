import { LightningElement, track, api } from 'lwc';
export default class customCombobox extends LightningElement {
    @track _options = [];
    @track selectedvalues = [];
    showPills = false;
    @api required = false;
    @api
    set value (selectedOptions) {
        this.selectedvalues = [...selectedOptions];
        this.checkLength();
    }
    get value () {
        return this.selectedvalues.join(';');
    }

    @api 
    set options (values) {
        if (values) {
            values.forEach(option => {
                this._options.push({'value' : option, 'isSelected' : false});
            });
        }
    }
    get options () {
        return this._options;
    }
    
    @api 
    set showError (value) {
        this._showError = value;
    }
    get showError () {
        return this._showError;
    }
    _showError = false;
    @api errorMessage = '';
    @api label = '';
    selectedMessage;
    showdropdown;

    checkLength () {
        if (this.selectedvalues.length > 0 ) {
            this.showPills = true;
        } else {
            this.showPills = false;
        }
    }

    optionClicked (event) {
        let selectedIndex = event.currentTarget.dataset.index;
        let option = this._options[selectedIndex].value;
        this.dispatchEvent(new CustomEvent("change", { detail : {
                                                                    type : 'selected',
                                                                    value : option,
                                                                },
                                                     }));
        if (this.selectedvalues.includes(option)) {
            this._options[selectedIndex]['isSelected'] = false;
            this.selectedvalues.splice(this.selectedvalues.indexOf(option), 1);
        } else {
            this._options[selectedIndex]['isSelected'] = true;
            this.selectedvalues.push(option);
        }
        this.checkLength();
    }

    handleShowdropdown(){
        if(this.showdropdown) {
            this.showdropdown = false;
        }else{
            this.showdropdown = true;
        }
    }

    handleLeave (event) {
        this.showdropdown = false;
    }

    closePill(event){
        let selection = event.target.dataset.value;
        let selectedpills = this.selectedvalues;
        let pillIndex = selectedpills.indexOf(selection);
        this.selectedvalues.splice(pillIndex, 1);
        this._options.forEach(option => {
            if (option.value == selection) {
                option.isSelected = false;
            }
        });
        this.dispatchEvent(new CustomEvent("change", { detail : {
                                                                    type : 'disselected',
                                                                    value : selection,
                                                                },
                                                     }));
        this.checkLength();
    }

    get selectedmessage() {
        return this.selectedvalues.length + ' values selected';
    }

}