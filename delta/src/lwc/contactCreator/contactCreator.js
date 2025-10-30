import { LightningElement, track } from 'lwc';
import createContact from '@salesforce/apex/ContactHandler.createContact';

export default class ContactCreator extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track accountId = '';
    @track message = '';

    handleChange(event) {
        const label = event.target.label;
        if (label === 'First Name') this.firstName = event.target.value;
        else if (label === 'Last Name') this.lastName = event.target.value;
        else if (label === 'Account Id') this.accountId = event.target.value;
    }

    async createContact() {
        try {
            const result = await createContact({ 
                firstName: this.firstName, 
                lastName: this.lastName, 
                accountId: this.accountId 
            });
            this.message = result;
        } catch (error) {
            this.message = 'Error: ' + error.body.message;
        }
    }
}
