public with sharing class ContactModalController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(){
        return[
            SELECT Id,FirstName,LastName,Email,Phone,
            Title,Department,AccountId,Account.Name,
            LeadSource,CreatedDate
            FROM Contact
            ORDER BY LastName ASC
            LIMIT 100
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Contact getContactById(Id ContactId){
        return[
            SELECT Id,FirstName,LastName,Email,Phone,
            Title,Department,AccountId,Account.Name,
            LeadSource
            FROM Contact
            Where Id=:ContactId
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Contact createContact(
        String firstName,
        String lastName,
        String email,
        String phone,
        String title,
        String department,
        String leadSource
    ){
        try{
            Contact con = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Title = title,
                Department = department,
                LeadSource = leadSource
            );
            insert con;
            return con;
        }catch(DmlException e){
            throw new AuraHandledException(
                'Error Creating contact:' +e.getDmlMessage(0)
            );
        }
    }

    @AuraEnabled
    public static Contact updateContact(
        Id     contactId,
        String firstName,
        String lastName,
        String email,
        String phone,
        String title,
        String department,
        String leadSource
    ){
        try{
            Contact con = new Contact(
                Id =contactId,
                FirstName=firstName,
                LastName= lastName,
                Email= email,
                Phone= phone,
                Title= title,
                Department=department,
                LeadSource= leadSource);
                update con;
                return con;
        } catch(DmlException e){
            throw new AuraHandledException(
                'Error updating contact:'+e.getDmlMessage(0)
            );
        }
    }
        @AuraEnabled
        public static void deleteContact(Id contactId){
            try{
                Contact con = new Contact(Id=contactId);
                delete con;
            } catch(DmlException e){
                throw new AuraHandledException(
                    'Error deleting contact:' +e.getDmlMessage(0)
                );
            }
        }
    }

