trigger OpportunityTrigger on Opportunity (before update, before delete) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            Set<Id> accountsIds = new Set<Id>();
            

            for (Opportunity o : Trigger.new) {
                if (o.Amount <= 5000) {
                    o.Amount.addError('Opportunity amount must be greater than 5000');
                    
                }
                if (o.AccountId != null){
                    accountsIds.add(o.AccountId);
                }
                
            }  
            Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Name, Title, AccountId FROM Contact WHERE AccountId IN :accountsIds AND Title = 'CEO']);
            Map<Id, Contact> ceoContacts = new Map<Id, Contact>();
            for (Contact c : mapContacts.values()) {
                ceoContacts.put(c.AccountId, c);
            }
            for (Opportunity o : Trigger.new) {  
                if (ceoContacts.containsKey(o.AccountId)) {
                o.Primary_Contact__c = ceoContacts.get(o.AccountId).Id;
                }        
            }      
        }
        when BEFORE_DELETE {
            Set<Id> accountsIds = new Set<Id>();
            
            for (Opportunity o : Trigger.old) {
                if (o.StageName == 'Closed Won' && o.AccountId != null) {                  
                    accountsIds.add(o.AccountId);
                }
            }
            Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, Industry FROM Account WHERE Id IN :accountsIds AND Industry = 'Banking']);

            for (Opportunity o : Trigger.old) {
                if (mapAccounts.containsKey(o.AccountId)) {
                    o.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        }
        
    }
}

