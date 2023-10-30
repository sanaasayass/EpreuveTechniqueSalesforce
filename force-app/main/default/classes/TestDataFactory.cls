// Classe TestDataFactory pour la création de données de test réutilisables
public class TestDataFactory {
    public static Account createActiveAccount(String name) {
        return new Account(Name = name, MissionStatus__c = 'active');
    }

    public static Account createCanceledAccount(String name) {
        return new Account(Name = name, MissionStatus__c = 'canceled');
    }

    public static Contact createActiveContact(String lastName) {
        return new Contact(LastName = lastName, IsActive__c = true);
    }

    public static Contact createInactiveContact(String lastName) {
        return new Contact(LastName = lastName, IsActive__c = false);
    }
}