use BEST
go

use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/* DROP PROC dbo.PsTRSLNK_01
 */
IF OBJECT_ID('dbo.PsTRSLNK_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsTRSLNK_01
   PRINT '<<< DROPPED PROC dbo.PsTRSLNK_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsTRSLNK_01
as

/***************************************************

Programme: PsTRSLNK_01

Fichier script associé : ESSTRS01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME27 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TTRSLNK

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


SELECT distinct ACMTRS_NT,DETTRS_CF
FROM BREF..TTRSLNK
where PRS_CF=500
order by DETTRS_CF


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSTRS01', 'PsTRSLNK_01', 'BREF', 'ME27'
go

IF OBJECT_ID('dbo.PsTRSLNK_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsTRSLNK_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsTRSLNK_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsTRSLNK_01
 */
GRANT EXECUTE ON dbo.PsTRSLNK_01 TO GOMEGA
go

