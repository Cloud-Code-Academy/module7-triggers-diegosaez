trigger AccountTrigger on Account (before insert, after insert) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            for (Account a : Trigger.new) {
                a.BillingCity = a.ShippingCity;
                a.BillingStreet = a.ShippingStreet;
                a.BillingCountry = a.ShippingCountry;
                a.BillingState = a.ShippingState;
                a.BillingPostalCode = a.ShippingPostalCode;
                if (a.Type == null) {
                    a.Type = 'Prospect';  
                }
                if (a.Website != '' && a.Phone != '' && a.Fax != '') {
                        a.rating = 'Hot';
                }      
                
            }   
                
        }
        when AFTER_INSERT {
            List<Contact> newContacts = new List<Contact>();
            for (Account a : Trigger.new) {
                newContacts.add(new Contact (LastName = 'DefaultContact', Email = 'default@email.com', AccountId = a.Id));
            }
            insert newContacts;
        }
    }
}