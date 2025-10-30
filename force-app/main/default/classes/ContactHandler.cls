public with sharing class ContactHandler {
    @AuraEnabled
    public static String createContact(String firstName, String lastName, Id accountId) {
        try {
            Contact con = new Contact(
                FirstName = firstName,
                LastName = lastName,
                AccountId = accountId
            );
            insert con;
            console.log('contact is being created with delta deployment okay brother');
            return 'Contact created successfully with Id: ' + con.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
}
