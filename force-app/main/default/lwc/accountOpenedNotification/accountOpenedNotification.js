import { LightningElement, api } from 'lwc';

export default class AccountOpenedNotification extends LightningElement {
  @api userName = 'User name';
  @api cardImageUrl = '/path/to/your/debit-card.png';
  @api customerNumber = '1234 567 8910 5678';
  @api accountNumber = '1234 567 8910 5678';
  @api dateOpened = '26/04/2023';
  @api fundingBalance = 'Not yet funded';

  handleSignOut() {
    // Implement actual sign-out logic or navigation
    console.log('Sign out clicked');
  }
}
