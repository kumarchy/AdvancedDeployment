@IsTest
private class ContactHandlerTest {
    @IsTest
    static void testCreateContact() {
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Call Apex method
        Test.startTest();
        String result = ContactHandler.createContact('John', 'Doe', acc.Id);
        Test.stopTest();

        System.assert(result.contains('Contact created successfully'));
        
        // Verify Contact inserted
        Contact con = [SELECT Id, AccountId FROM Contact WHERE LastName = 'Doe' LIMIT 1];
        System.assertEquals(acc.Id, con.AccountId);

        // Verify trigger effect (Account description updated)
        Account updatedAcc = [SELECT Description FROM Account WHERE Id = :acc.Id];
        System.assert(updatedAcc.Description != null, 'Description should be set by trigger carefully');
    }
}
