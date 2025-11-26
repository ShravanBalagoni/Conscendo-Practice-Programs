import { LightningElement, track } from 'lwc';

const ROWS = [
  {
    id: 1,
    entityName: 'Finance Inc.',
    accountType: 'Optimum',
    applicationStep: '01 - About you',
    applicationTab: 'Contact Details',
    lastEdited: '6 hours ago',
    duration: '1 Day',
    statusKey: 'inprogress'
  },
  {
    id: 2,
    entityName: 'Marina Hagg',
    accountType: 'Platinum Optimum',
    applicationStep: '03 - Financial Details',
    applicationTab: 'Trusts',
    lastEdited: '2 Days ago',
    duration: '4 Days',
    statusKey: 'inprogress'
  },
  {
    id: 3,
    entityName: 'Jenna Vermeulen',
    accountType: 'Seafarer',
    applicationStep: '04 - Account details',
    applicationTab: 'Your Future Deposits',
    lastEdited: '4 Days ago',
    duration: '10 Days',
    statusKey: 'inprogress'
  },
  {
    id: 4,
    entityName: 'Jane Doe',
    accountType: 'Optimum',
    applicationStep: '-',
    applicationTab: '-',
    lastEdited: '8 Days ago',
    duration: '5 Days',
    statusKey: 'approved'
  },
  {
    id: 5,
    entityName: 'John Wick',
    accountType: 'Platinum Optimum',
    applicationStep: '-',
    applicationTab: '-',
    lastEdited: '5 Days ago',
    duration: '11 Days',
    statusKey: 'cancelled'
  },
  {
    id: 6,
    entityName: 'Lara Croft',
    accountType: 'Seafarer',
    applicationStep: '-',
    applicationTab: '-',
    lastEdited: '21 Days ago',
    duration: '4 Days',
    statusKey: 'declined'
  }
];

const STATUS_META = {
  inprogress: { label: 'In Progress', css: 'mc-status mc-status--inprogress' },
  approved: { label: 'Approved', css: 'mc-status mc-status--approved' },
  declined: { label: 'Declined', css: 'mc-status mc-status--declined' },
  cancelled: { label: 'Cancelled', css: 'mc-status mc-status--cancelled' }
};

export default class MyClients extends LightningElement {
  @track activeTab = 'all';

  get allTabClass() {
    return this.tabClass('all');
  }
  get inProgressTabClass() {
    return this.tabClass('inprogress');
  }
  get approvedTabClass() {
    return this.tabClass('approved');
  }
  get declinedTabClass() {
    return this.tabClass('declined');
  }

  tabClass(tabKey) {
    const base = 'mc-tab';
    return this.activeTab === tabKey ? `${base} mc-tab--active` : base;
  }

  get visibleApplications() {
    return ROWS.filter((row) => {
      if (this.activeTab === 'all') {
        return true;
      }
      if (this.activeTab === 'inprogress') {
        return row.statusKey === 'inprogress';
      }
      if (this.activeTab === 'approved') {
        return row.statusKey === 'approved';
      }
      if (this.activeTab === 'declined') {
        return row.statusKey === 'declined';
      }
      return true;
    }).map((row) => {
      const status = STATUS_META[row.statusKey];
      return {
        ...row,
        statusLabel: status.label,
        statusClass: status.css,
        isInProgress: row.statusKey === 'inprogress'
      };
    });
  }

  get visibleCount() {
    const list = this.visibleApplications || [];
    return list.length;
  }

  handleTabClick(event) {
    const tab = event.currentTarget.dataset.tab;
    this.activeTab = tab;
  }
}
