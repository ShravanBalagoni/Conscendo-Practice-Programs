import { LightningElement, api, track } from 'lwc';

export default class AccountNotificationHeader extends LightningElement {
  /** username shown in header */
  @api username = 'User name';

  // Note: using the uploaded file path you provided.
  // Your deployment process should convert this local path to an accessible URL,
  // or replace with a static resource (recommended for production).
  logoUrl = '/mnt/data/image (4).png';

  @track menuOpen = false;

  showMenu() {
    this.menuOpen = true;
  }

  hideMenu() {
    this.menuOpen = false;
  }

  handleProfile() {
    this.dispatchEvent(new CustomEvent('openprofile'));
    this.menuOpen = false;
  }

  handleSignOut() {
    this.dispatchEvent(new CustomEvent('signout'));
    this.menuOpen = false;
  }
}
