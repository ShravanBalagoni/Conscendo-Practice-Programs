public with sharing class searchContactsApexController {
    public static List<Contact> getContacts(String searchKey){
        String key = '%'+searchKey+'%';
        return [Select Id,Name,Email from Contact Where Name LIKE:key Limit 20];
    }
}