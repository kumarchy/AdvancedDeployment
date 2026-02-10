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

            return 'Contact created successfully with Id:123 ***' + con.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
}
