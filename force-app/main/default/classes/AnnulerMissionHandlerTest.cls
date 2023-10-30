@isTest
public class AnnulerMissionHandlerTest {

    @isTest
    static void testHandleCancelledMissions() {
        // Créer des données de test
        Account oldAccount = TestDataFactory.createActiveAccount('Ancien Compte');
        insert oldAccount;

        Account newAccount = TestDataFactory.createCanceledAccount('Nouveau Compte');
        insert newAccount;

        Map<Id, Account> oldAccountMap = new Map<Id, Account>{newAccount.Id => oldAccount};

        // Appeler la méthode à tester
        Test.startTest();
        AnnulerMissionHandler.handleCancelledMissions(new List<Account>{newAccount}, oldAccountMap);
        Test.stopTest();

        // Vérifier si le champ MissionCanceledDate__c a été mis à jour correctement
        Account updatedAccount = [SELECT MissionCanceledDate__c FROM Account WHERE Id = :newAccount.Id LIMIT 1];
        System.assertEquals(Date.today(), updatedAccount.MissionCanceledDate__c, 'La date d\'annulation doit être mise à jour');
    }
}