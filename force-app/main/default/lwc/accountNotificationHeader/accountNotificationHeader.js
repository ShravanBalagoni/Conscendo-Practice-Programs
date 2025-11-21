import { LightningElement, api } from 'lwc';

export default class AccountNotificationHeader extends LightningElement {
  @api userName = 'User name';
  @api logoUrl = '/resource/DebitCardImage';  // Use your uploaded asset URL
  @api signOutUrl = '/';

  handleSignOut() {
    window.location.href = this.signOutUrl;
  }
}
