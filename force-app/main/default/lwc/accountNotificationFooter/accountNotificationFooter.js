import { LightningElement, api } from 'lwc';

export default class AccountNotificationFooter extends LightningElement {
  /**
   * Public properties referenced by the template.
   * Defaults use the local uploaded file path so the CLI can transform it when deployed.
   */
  @api helpUrl = '/mnt/data/image (4).png';
  @api contactUrl = '/mnt/data/image (4).png';
  @api imageUrl = '/mnt/data/image (4).png';

  // Add other @api fields here if your template references them.
}
