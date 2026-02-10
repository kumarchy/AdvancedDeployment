trigger ContactTrigger on Contact (after insert) {
    Set<Id> accountIds = new Set<Id>();

    for (Contact c : Trigger.new) {
        if (c.AccountId != null) {
            accountIds.add(c.AccountId);
            
        }
    }

    if (!accountIds.isEmpty()) {
        List<Account> accLists = [SELECT Id, Description FROM Account WHERE Id IN :accountIds];
        for (Account acc : accLists) {
            acc.Description = 'Contact added on account : 123 ***' + DateTime.now().format();
        }
        update accLists;
    }
}
