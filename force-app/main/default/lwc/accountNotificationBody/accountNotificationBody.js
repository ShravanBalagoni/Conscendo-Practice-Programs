import { LightningElement, api, track } from 'lwc';
//import debitcard from '@salesforce/resourceUrl/cardLogo';
import debitCardlogo from '@salesforce/resourceUrl/debitCardlogo';
//import banklogo from '@salesforce/resourceUrl/bankLogo';

export default class AccountNotificationBody extends LightningElement {
  /** Exposed properties for Experience Builder */
  @api customerNumber = '1234 567 8910 5678';
  @api accountNumber = '1234 567 8910 5678';
  @api openedDate = '26/04/2023';
  @api fundingStatus = 'Not yet funded';

  // Use uploaded image path (will be transformed in your pipeline). Replace with a static resource for production.
 @api cardImageUrl = debitCardlogo;


  // small helper: if parent wants to update values programmatically
  @api updateAccountDetails({ customerNumber, accountNumber, openedDate, fundingStatus,cardImageUrl }) {
    if (customerNumber !== undefined) this.customerNumber = customerNumber;
    if (accountNumber !== undefined) this.accountNumber = accountNumber;
    if (openedDate !== undefined) this.openedDate = openedDate;
    if (fundingStatus !== undefined) this.fundingStatus = fundingStatus;
    if (cardImageUrl !== undefined && cardImageUrl !== null) {
      this.cardImageUrl = cardImageUrl;
    }
  }
}
