use BEST
go

use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/* DROP PROC dbo.PsRETPAR_01
*/
IF OBJECT_ID('dbo.PsRETPAR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETPAR_01
   PRINT '<<< DROPPED PROC dbo.PsRETPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsRETPAR_01
     
as

/***************************************************

Programme: PsRETPAR_01

Fichier script associé : ESSRET01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME69 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TRETPAR

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


Select PRS_CF, TRNCOD_CF, DETTRS_CF
from	BEST..TRETPAR
order	by TRNCOD_CF asc



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSRET01', 'PsRETPAR_01', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PsRETPAR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETPAR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETPAR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETPAR_01
 */
GRANT EXECUTE ON dbo.PsRETPAR_01 TO GOMEGA
go

