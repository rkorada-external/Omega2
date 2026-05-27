/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/* DROP PROC dbo.PsSOBBLOB_01
 */
IF OBJECT_ID('dbo.PsSOBBLOB_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSOBBLOB_01
   PRINT '<<< DROPPED PROC dbo.PsSOBBLOB_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSOBBLOB_01
	
as

/***************************************************
Programme: PsSOBBLOB_01
Fichier script associé : ESSSSOB01.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME27 avec Infotool version 2.0 (AUTO)
Date de creation: 
Description du programme: 

      Sélection de toutes les lignes de TSOBBLOB pour génération d'un fichier binaire

Parametres: 
Conditions d'execution: 
Commentaires:
_________________
MODIFICATION 1
[001] 27/12/2013 R. cassis :spot:25427 Centralization - ajout Grant
*****************************************************/


select LOB_CF, SOB_CF, PRDCOD_CT
from 	BREF..TSOBBLOB


return 0
go

/*
 * fin de la procedure 
 */

IF OBJECT_ID('dbo.PsSOBBLOB_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSOBBLOB_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSOBBLOB_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSOBBLOB_01
 */
GRANT EXECUTE ON dbo.PsSOBBLOB_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSOBBLOB_01 TO GDBBATCH
go

