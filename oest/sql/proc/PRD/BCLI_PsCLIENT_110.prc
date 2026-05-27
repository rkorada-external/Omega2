use BCLI
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */

/* DROP PROC dbo.PsCLIENT_110
*/
IF OBJECT_ID('dbo.PsCLIENT_110') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCLIENT_110
   PRINT '<<< DROPPED PROC dbo.PsCLIENT_110 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCLIENT_110
     
as

/***************************************************

Programme: PsCLIENT_110

Fichier script associé : BCLI_PsCLIENT_110.PRC

Domaine : (ES) Estimation

Base principale : BCLI

Version: 1

Auteur: ME69 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans BRET..TSSDACTR

Parametres: 
       

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int


Select distinct CLI_NF, CLISSD_CF
from	BCLI..TCLIENT
where CLISSD_CF <> NULL
order	by CLI_NF, CLISSD_CF asc  


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSSD01', 'PsCLIENT_110', 'BCLI', 'ME69'
go

IF OBJECT_ID('dbo.PsCLIENT_110') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCLIENT_110 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCLIENT_110 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCLIENT_110
 */
GRANT EXECUTE ON dbo.PsCLIENT_110 TO GOMEGA
go

