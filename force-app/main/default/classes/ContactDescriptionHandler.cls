public class ContactDescriptionHandler {
    public static void handleAfterUpdate(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        Set<Id> contactsWithDescChange = new Set<Id>();
        for (Contact newCon : newMap.values()) {
            Contact oldCon = oldMap.get(newCon.Id);
            if (newCon.Description != oldCon.Description) {
                contactsWithDescChange.add(newCon.Id);
            }
        }
        if (contactsWithDescChange.isEmpty()) {
            return;
        }
        
        // Query the contacts with changed description
        List<Contact> changedContacts = [SELECT Id, Description FROM Contact WHERE Id IN :contactsWithDescChange];
        
        List<Case> casesToUpdate = new List<Case>();
        List<Case> casesToInsert = new List<Case>();
        
        for (Contact con : changedContacts) {
            // 1) Update all related Cases whose Status ≠ “Closed”
            List<Case> openCases = [SELECT Id, Description, ContactId, Status
                                    FROM Case
                                    WHERE ContactId = :con.Id
                                      AND Status != 'Closed'];
            
            if (openCases.isEmpty()) {
                // 2) If no open cases, then create a new Case
                Case newCase = new Case(
                    ContactId = con.Id,
                    Description = con.Description,
                    Status = 'New' // or whatever default status makes sense
                    // You may need to set Subject, Origin, AccountId, etc depending on your org
                );
                casesToInsert.add(newCase);
            } else {
                for (Case c : openCases) {
                    c.Description = con.Description;
                    casesToUpdate.add(c);
                }
            }
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
    }
}
