@isTest
public class AnnulerMissionTriggerTest {

    @isTest
    static void testAnnulerMissionTrigger() {
        // Créez un compte avec un statut de mission actif
        Account testAccount = TestDataFactory.createActiveAccount('Compte de Test');
        insert testAccount;

        // Mettez à jour le statut de mission du compte pour le faire passer à "canceled"
        testAccount.MissionStatus__c = 'canceled';
        update testAccount;

        // Récupérez le compte mis à jour depuis la base de données
        Account updatedAccount = [SELECT Id, MissionCanceledDate__c FROM Account WHERE Id = :testAccount.Id LIMIT 1];

        // Vérifiez si le champ MissionCanceledDate__c a été mis à jour correctement
        System.assertEquals(Date.today(), updatedAccount.MissionCanceledDate__c, 'La date d\'annulation doit être mise à jour');


    }
}