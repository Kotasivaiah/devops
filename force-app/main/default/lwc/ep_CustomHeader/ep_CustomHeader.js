import { LightningElement, api } from 'lwc';
import SALESFORCE from "@salesforce/resourceUrl/SalesforceLogo";
export default class Ep_CustomHeader extends LightningElement {
    salesforceLogo = SALESFORCE;
    // @api showWelcome = false;
    @api showlogo = false;
}