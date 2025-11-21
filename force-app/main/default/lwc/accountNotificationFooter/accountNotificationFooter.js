import { LightningElement, api } from 'lwc';

export default class AccountNotificationFooter extends LightningElement {
  // dynamic year
  year = new Date().getFullYear();

  // exposed properties for community builder
  @api helpUrl = '#';
  @api contactUrl = '#';
  @api privacyUrl = '#';

  // logo image (using your uploaded path; replace with static resource for prod)
  @api footerLogoUrl = '/mnt/data/image (4).png';
}
