import { LightningElement } from 'lwc';
export default class Ep_panelInformation extends LightningElement {

    rows = [];

    showInputButton = true;
    showInput = false;
    isLastRow = false;

    lastrowId = 1;

    handleshowInput(){
        this.showInputButton = false;
        this.showInput = true;
        this.handleAddRow();
    }

    handledelete(event){
        const id = event.target.name;
        console.log('delete id::',id);
        this.rows = this.rows.filter(row => row.id !== id);
        console.log('Updated rows:',JSON.stringify(this.rows));
        this.updateLastRowFlag();
    }

    handleAddRow(){
        const id = this.lastrowId++;
        this.rows = [ ...this.rows, { id, inputValue: '' , isLastRow: false } ];
        console.log('this.rows:',JSON.stringify(this.rows));
        this.updateLastRowFlag();
    }

    handleInputChange(event) {
        const id = event.target.name;
        const value = event.target.value;
        this.updateRow(id, 'inputValue', value);
    }

    updateRow(id,field, value) {
        this.rows = this.rows.map(row => {
                                        if (row.id == id) {
                                            return { ...row, [field]: value };
                                        }
                                        return row;
                                    });
         console.log('this.rows:',JSON.stringify(this.rows));                           
    }

    handleCancel(){
        this.showInput = false;
        this.showInputButton = true;
        this.rows = [];
    }

    updateLastRowFlag() {        
        this.rows = this.rows.map((row, index) => {
            console.log('index::',index);
            console.log('this.rows.length::',this.rows.length);
                return { ...row, isLastRow: index ===  this.rows.length - 1 };       
        });
    }

}