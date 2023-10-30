/*
 * ===================================================================
 * @name		: AnnulerMissionHandler
 * @author		: SSA
 * @date		: 30/10/2021
 * @Modif 		: 
 * @description	: Gestionnaire pour le déclencheur AnnulerMissionTrigger 
 * @version 	: 1.00
 * ===================================================================
*/
public class AnnulerMissionHandler {

    // Méthode pour traiter les missions annulées
    public static void handleCancelledMissions(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        // Liste pour stocker les comptes à mettre à jour
        List<Account> accountsToUpdate = new List<Account>();

        // Parcourir les nouveaux comptes et vérifier s'ils ont été annulés
        for (Account newAccount : newAccounts) {
            // Obtenir le compte existant à partir de la carte oldAccountMap
            Account oldAccount = oldAccountMap.get(newAccount.Id);
    
            // a. Mettre à jour le champ MissionCanceledDate__c avec la date du jour lorsqu'une mission est annulée
            // Vérifier si le statut de mission a changé de non annulé à annulé
            if (oldAccount.MissionStatus__c != 'canceled' && newAccount.MissionStatus__c == 'canceled') {
                // Créer un nouvel objet Account avec l'ID du nouveau compte et mettre à jour la date d'annulation
                Account acc  = new Account(Id = newAccount.Id);
                acc.MissionCanceledDate__c = Date.today();
                accountsToUpdate.add(acc);
            }
        }
    
        // Vérifier s'il y a des comptes à mettre à jour
        if (!accountsToUpdate.isEmpty()) {
            // Mettre à jour les comptes dans la base de données
            update accountsToUpdate;
    
            // b. Appeler le lot pour mettre à jour le statut d'activité des contacts et en passant le newAccount comme paramètre
            UpdateContactStatusBatch batchJob = new UpdateContactStatusBatch(accountsToUpdate);
            // Spécifiez la taille du lot (200) 
            Integer batchSize = 200;
            Database.executeBatch(batchJob, batchSize);
        
            
        }
    }
}
