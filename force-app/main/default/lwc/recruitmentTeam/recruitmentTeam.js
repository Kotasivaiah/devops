import { LightningElement, track } from 'lwc';
export default class RecruitmentTeam extends LightningElement {
  @track rows = [
    { id: 0, value: '', showAdd: true, showDelete: false }
  ];

    nextId = 1;

  addRow() {
    this.rows.forEach(row => row.showAdd = false);
    this.rows.push({ id: this.nextId++, value: '', showAdd: true, showDelete: true });
    }

    deleteRow(event) {
        const rowId = parseInt(event.currentTarget.dataset.id, 10);
        this.rows = this.rows.filter(row => row.id !== rowId);
        if (this.rows.length === 1) {
            this.rows[0].showDelete = false;
        }
        if (this.rows.length > 0) {
            this.rows[this.rows.length - 1].showAdd = true;
        }
    }

    handleInputChange(event) {
        const rowId = parseInt(event.currentTarget.dataset.id, 10);
        const value = event.target.value;
        const rowIndex = this.rows.findIndex(row => row.id === rowId);
        this.rows[rowIndex].value = value;
    }
}
