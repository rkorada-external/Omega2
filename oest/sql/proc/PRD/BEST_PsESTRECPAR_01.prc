USE BEST
Go

/*
 * DROP PROC PsESTRECPAR_01
 */
IF OBJECT_ID('PsESTRECPAR_01') IS NOT NULL
BEGIN
    DROP PROC PsESTRECPAR_01
    PRINT '<<< DROPPED PROC PsESTRECPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsESTRECPAR_01
     
with execute as caller as

/***************************************************

Programme: PsESTRECPAR_01

Fichier script associé : ESSREC01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 24/06/97

Description du programme: 
     - Séléction de toutes les lignes de la table TESTRECPAR.
 

Parametres:
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description: Removed dbo and added ‘with execute as caller as’

*****************************************************/


declare @erreur      int,
        @tran_imbr	  bit
        

select @erreur = 0
select @tran_imbr = 1


/* ------------------------------------------------------------
   Sélction des lignes
 -------------------------------------------------------------- */

select CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, REILIN_NT, REIRNK_NT, REIPRMBAS_R,
    	REIPRM_M, REIPRM_R, REIPROTMP_B 
from BTRAV..TESTRECPAR


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

exec sp_SCOR_INSPRC 'ESSREC01', 'PsESTRECPAR_01', 'BEST', 'ME69'
go


IF OBJECT_ID('PsESTRECPAR_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsESTRECPAR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsESTRECPAR_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsESTRECPAR_01
 */
GRANT EXECUTE ON PsESTRECPAR_01 TO GOMEGA
go

