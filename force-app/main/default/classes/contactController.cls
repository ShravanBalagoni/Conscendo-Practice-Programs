/**
* ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
* Class Name      : contactController
* Author          : <YourName>
* Created Date    : Jan 22, 2026
* Last Modified By: <YourName>
* Last Modified On: Jan 22, 2026
* Description     : This class implements for......
*  
* Change History  :
*  Date          │   Author     │   Change
* ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
*  Jan 22, 2026  │ <YourName>   │ Initial version
* ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
*/

public class contactController {

	@AuraEnabled(cacheable=true)
	public static List<Contact> getContactListForDataTable(){
		return [SELECT Id, Name, Title, Phone, Email, Picture__c, Rank__c, AccountId, Account.Name
		FROM Contact
		WHERE AccountId != null
		LIMIT 60];
}

	@AuraEnabled(cacheable=true)
	public static List<Contact> contactsByACCId(String accountId){
		return [ SELECT Id,FirstName,LastName,Title,Phone,Email 
			FROM Contact 
			Where AccountId= :accountId
			];
	}

}