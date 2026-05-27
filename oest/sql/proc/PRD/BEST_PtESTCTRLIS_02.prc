USE BEST
Go

/*
 * DROP PROC PtESTCTRLIS_02
 */
IF OBJECT_ID('PtESTCTRLIS_02') IS NOT NULL
BEGIN
    DROP PROC PtESTCTRLIS_02
    PRINT '<<< DROPPED PROC PtESTCTRLIS_02 >>>'
END
go


/* ------------------------------------------------------------
   Création de table temporaire nécessaire à la compilation
 -------------------------------------------------------------- */

create table #TCPLACC1 (
	CTR_NF		UCTR_NF	NOT NULL,
	ACY_NF		smallint	NULL,
	SCOENDMTH_NF	tinyint	NULL )
go

/*
 * creation de la procedure 
*/

create procedure PtESTCTRLIS_02
     
with execute as caller as

/***************************************************

Programme: PtESTCTRLIS_02

Fichier script associé : ESTCTR02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 21/11/97

Description du programme: 
     - mise a jour de table BTRAV..TESTCTRLIS après recherche des comptes complets.
 

Parametres:
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: 
 
Date:   

Version:

Description:
_________________
Modification - Removed dbo and added ‘with execute as caller as’    
*****************************************************/


declare @erreur      int 

select @erreur = 0


/* -----------------------------------------------------------------------------------------
   Mise a jour de la liste des affaires - recherche de la dernière période compte complet 
----------------------------------------------------------------------------------------- */

update BTRAV..TESTCTRLIS 
set	A.CPLACCY_NF = B.ACY_NF,
	A.SCOLSTMTH_NF = B.SCOENDMTH_NF
from	BTRAV..TESTCTRLIS A, #TCPLACC1 B
where	A.CTR_NF = B.CTR_NF

select @erreur = @@error

if @erreur != 0  goto fin

               
/**********************************************************************************/


return 0

fin:
return 1
go

/*
 * fin de la procedure 
 */

/*   Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTCTR02', 'PtESTCTRLIS_02', 'BEST', 'ME69'
go

IF OBJECT_ID('PtESTCTRLIS_02') IS NOT NULL
    PRINT '<<< CREATED PROC PtESTCTRLIS_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtESTCTRLIS_02 >>>'
go
/*
 * Granting/Revoking Permissions on PtESTCTRLIS_02
 */
GRANT EXECUTE ON PtESTCTRLIS_02 TO GOMEGA
go

