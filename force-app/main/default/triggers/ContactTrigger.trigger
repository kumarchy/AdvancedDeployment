trigger ContactTrigger on Contact (after insert) {
    Set<Id> accountIds = new Set<Id>();

    for (Contact c : Trigger.new) {
        if (c.AccountId != null) {
            accountIds.add(c.AccountId);
        }
    }

    if (!accountIds.isEmpty()) {
        List<Account> accList = [SELECT Id, Description FROM Account WHERE Id IN :accountIds];
        for (Account acc : accList) {
            acc.Description = 'Contact added on ' + DateTime.now().format();
        }
        update accList;
    }
}
