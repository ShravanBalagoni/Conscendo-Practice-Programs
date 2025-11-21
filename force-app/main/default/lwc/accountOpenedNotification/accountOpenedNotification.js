import { LightningElement, api } from 'lwc';

export default class AccountOpenedNotification extends LightningElement {
  @api cardImageUrl = '/resources/images/debit-card.png';
  @api customerNumber = '1234 567 8910 5678';
  @api accountNumber = '1234 567 8910 5678';
  @api dateOpened = '26/04/2023';
  @api fundingBalance = 'Not yet funded';

  // any additional logic can go here
}
