/*
 * ===================================================================
 * @name		: AnnulerMissionTrigger
 * @author		: SSA
 * @date		: 30/10/2021
 * @Modif 		: 
 * @description	: Déclencheur pour l'objet Account qui gère les missions annulées
 * @version 	: 1.00
 * ===================================================================
*/
trigger AnnulerMissionTrigger on Account (after update) {
    // Assurez-vous que le déclencheur ne se déclenche que après une mise à jour des comptes et après l'opération.
    if (Trigger.isUpdate && Trigger.isAfter) {
        // Appel de la méthode handleCancelledMissions du gestionnaire pour traiter les missions annulées
        AnnulerMissionHandler.handleCancelledMissions(Trigger.new, Trigger.oldMap);
    }
}


//test sanaa
