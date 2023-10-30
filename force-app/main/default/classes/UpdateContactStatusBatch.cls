/*
 * ===================================================================
 * @name        : UpdateContactStatusBatch
 * @author      : SSA
 * @date        : 30/10/2021
 * @description : Classe Batch Apex permettant de mettre à jour les 
 *                enregistrements de contact en fonction du statut 
 *                d'annulation du compte associé et de synchroniser 
 *                ces modifications avec une API externe.
 * @version     : 1.00
 * ===================================================================
*/
global class UpdateContactStatusBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private List<Account> accountsToUpdate = new List<Account>();
    public List<Contact> contactsToUpdate = new List<Contact>();
    private Set<Id> contactIdsToUpdate = new Set<Id>();

    // Constructeur qui prend un paramètre de type List<Account>
    global UpdateContactStatusBatch(List<Account> accounts) {
        this.accountsToUpdate = accounts;
    }
   

    // Méthode start pour récupérer les contacts associés aux comptes à mettre à jour
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> accountIds = new Set<Id>();

        // Récupérer les identifiants des comptes à mettre à jour
        for (Account acc : accountsToUpdate) {
            accountIds.add(acc.Id);
        }

        // Récupérer les identifiants des contacts associés aux comptes
        Set<Id> contactIds = new Set<Id>();
        for (AccountContactRelation__c acr : [SELECT Contact__c FROM AccountContactRelation__c WHERE Account__c IN :accountIds]) {
            contactIds.add(acr.Contact__c);
        }

        // Récupérer les contacts associés aux comptes
        return Database.getQueryLocator([SELECT Id, IsActive__c FROM Contact WHERE Id IN :contactIds]);
    }

    // Méthode execute pour traiter les contacts récupérés
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        try {
            for (Contact con : scope) {
                Boolean allAccountsCanceled = true;

                // Récupérer les identifiants des comptes associés au contact actuel
                Set<Id> accountIds = new Set<Id>();
                for (AccountContactRelation__c acr : [SELECT Account__c, Contact__c FROM AccountContactRelation__c WHERE Contact__c = :con.Id]) {
                    accountIds.add(acr.Account__c);
                }

                // Vérifier si toutes les entreprises liées à ce contact sont annulées
                for (Account acc : [SELECT Id, MissionStatus__c FROM Account WHERE Id IN :accountIds]) {
                    if (acc.MissionStatus__c != 'canceled') {
                        allAccountsCanceled = false;
                        break;
                    }
                }

                // Si toutes les entreprises liées à ce contact sont annulées, le rendre inactif
                if (allAccountsCanceled && con.IsActive__c) {
                    contactIdsToUpdate.add(con.Id);
                }
            }

            // Mettre à jour les contacts
            if (!contactIdsToUpdate.isEmpty()) {
                    // Mettez à jour le champ IsActive__c des contacts avec l'ID contenu dans contactIdsToUpdate en le définissant à false
                    contactsToUpdate = [SELECT Id, IsActive__c FROM Contact WHERE Id IN :contactIdsToUpdate];
                    for (Contact con : contactsToUpdate) {
                        con.IsActive__c = false;
                    }

                    // c. Préparer le payload JSON 
                    PayloadBuilder payloadBuilder=new PayloadBuilder();
                    String payloadJson = payloadBuilder.preparePayload(contactsToUpdate);

                    // Appeler l'API pour synchroniser les contacts mis à jour
                    HttpService httpService = new HttpService();
                    httpService.sendHttpRequest(payloadJson);
                    
                    //DML sur la BD 
                    update contactsToUpdate;
            }
            
        } catch (Exception e) {
            // Gérer les erreurs
            System.debug('Erreur lors de la synchronisation avec l\'API externe : ' + e.getMessage());
        }
    }

    //Fin de traitement
    global void finish(Database.BatchableContext BC) {
        System.debug('Le lot de mise à jour du statut d\'activité des contacts a été exécuté avec succès.');
    }

    public class PayloadBuilder {
        // Préparer le PAYLOAD pour l'API
        public  String preparePayload(List<Contact> contacts) {
            List<Map<String, Object>> payloadList = new List<Map<String, Object>>();
            for (Contact con : contacts) {
                Map<String, Object> contactMap = new Map<String, Object>();
                contactMap.put('id', con.Id);
                contactMap.put('is_active', con.IsActive__c);
                payloadList.add(contactMap);
            }
            return JSON.serialize(payloadList);
        }
    }
    
    public class HttpService {
        // Envoyer une requête HTTP à l'API externe
        private  void sendHttpRequest(String payloadJson) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Constants.EXTERNAL_API_ENDPOINT);
            request.setMethod('PATCH');
            request.setBody(payloadJson);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'salesforceAuthToken');
    
            Http http = new Http();
            
                HttpResponse response = http.send(request);
    
                // Gérer la réponse de l'API externe
                if (response.getStatusCode() == 200) {
                    System.debug('Synchronisation avec le serveur externe réussie.');
                } else if (response.getStatusCode() == 404) {
                    throw new CalloutException('Erreur 404 - Ressource non trouvée sur le serveur externe.');
                } else if (response.getStatusCode() == 401) {
                    throw new CalloutException('Erreur 401 - Autorisation invalide. Vérifiez le token d\'authentification.');
                } else if (response.getStatusCode() == 400) {
                    throw new CalloutException('Erreur 400 - Paramètres incorrects dans la requête. Assurez-vous d\'envoyer le bon format de données.');
                } else {
                    throw new CalloutException('Erreur lors de la synchronisation avec le serveur externe. Code de statut : ' + response.getStatusCode());
                }
         
        }
    
    }
    
}
    
