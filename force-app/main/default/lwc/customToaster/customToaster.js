import { LightningElement,api } from 'lwc';
export default class CustomToaster extends LightningElement {
    @api type='success';
    @api message;
    @api  messageIsHtml=false;
    @api showToastBar = "slds-hide";
    @api  autoCloseTime = 5000;
    @api icon='';
    @api styling;
    @api
    showToast(type, message,icon,time) {
        this.type = type;
        this.message = message;
        this.icon=icon;
        this.autoCloseTime=time;    
        this.showToastBar = "slds-show";
        setTimeout(() => {
            this.closeMessage();
        }, this.autoCloseTime);
    }
    
     closeMessage() {
        console.log('closing!!!!!');
        this.showToastBar = "slds-hide";
        this.type = '';
        this.message = '';
    }
 
    get getIconName() {
        if(this.icon)
        {
            return this.icon;
        }
        return 'utility:' + this.type;
    }
 
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }

}