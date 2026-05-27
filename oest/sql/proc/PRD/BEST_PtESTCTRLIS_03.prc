USE BEST
Go

/*
 * DROP PROC PtESTCTRLIS_03
 */
IF OBJECT_ID('PtESTCTRLIS_03') IS NOT NULL
BEGIN
    DROP PROC PtESTCTRLIS_03
    PRINT '<<< DROPPED PROC PtESTCTRLIS_03 >>>'
END
go


/* ------------------------------------------------------------
   Création de table temporaire nécessaire à la compilation
 -------------------------------------------------------------- */

create table #TCONVERSION1 ( 
	CTR_NF		UCTR_NF	NOT NULL, 
	UWY_NF		UUWY_NF	NOT NULL,
	UW_NT		UUW_NT		NOT NULL, 
	END_NT		UEND_NT	NOT NULL,
	SEC_NF		USEC_NF	NOT NULL,
	SSD_CF		USSD_CF	NOT NULL,
	EGPCUR_CF	UCUR_CF	NOT NULL, 
	EXCEGP_R 	ULNGDEC	NULL, 
	SBJPRMCUR_CF	UCUR_CF	NOT NULL, 
	EXCSBJ_R 	ULNGDEC	NULL )
go

/*
 * creation de la procedure 
*/

create procedure PtESTCTRLIS_03
     
with execute as caller as

/***************************************************

Programme: PtESTCTRLIS_03

Fichier script associé : ESTCTR03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 21/11/97

Description du programme: 
     - calcul de la conversion des montants ( chargement effectif,
	assiette de prime estimée, 	assiette de prime definitive 
	et assiette de prime comptable ) de devise assiette en devise aliment.
 

Parametres:
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: 
 
Date:   

Version:

Description:
__________________
Modification - Removed dbo and added ‘with execute as caller as’  
*****************************************************/


declare @erreur      int 

select @erreur = 0


/* ----------------------------------------------------------------
   Mise a jour de la liste des affaires - calcul des conversions
---------------------------------------------------------------- */

set arithabort numeric_truncation off

update	BTRAV..TESTCTRLIS
set	PRMEFFLOA_M = ( isnull( C.PRMEFFLOA_M, 0 ) * isnull( A.EXCSBJ_R, -1 ) ) / isnull( A.EXCEGP_R, -1) ,
	ESTSBJPRM_M = ( isnull( C.ESTSBJPRM_M, 0 ) * isnull( A.EXCSBJ_R, -1 ) ) / isnull( A.EXCEGP_R, -1) , 
	DEFSBJPRM_M = ( isnull( C.DEFSBJPRM_M, 0 ) * isnull( A.EXCSBJ_R, -1 ) ) / isnull( A.EXCEGP_R, -1) , 
	SBJPRMCPT_M = ( isnull( C.SBJPRMCPT_M, 0 ) * isnull( A.EXCSBJ_R, -1 ) ) / isnull( A.EXCEGP_R, -1)
from	#TCONVERSION1 A, BTRAV..TESTCTRLIS C
where	A.CTR_NF = C.CTR_NF
	and A.UWY_NF = C.UWY_NF
	and A.UW_NT = C.UW_NT
	and A.END_NT = C.END_NT
	and A.SEC_NF = C.SEC_NF
/*	and ( 
( ( isnull( C.PRMEFFLOA_M, 0 ) * isnull( A.EXCSBJ_R, -1 ) ) / isnull( A.EXCEGP_R, -1) < 999999999999999 ) or 
( ( isnull( C.ESTSBJPRM_M, 0 ) * isnull( A.EXCSBJ_R, -1 ) ) / isnull( A.EXCEGP_R, -1) < 999999999999999 ) or 
( ( isnull( C.DEFSBJPRM_M, 0 ) * isnull( A.EXCSBJ_R, -1 ) ) / isnull( A.EXCEGP_R, -1) < 999999999999999 ) or 
( ( isnull( C.SBJPRMCPT_M, 0 ) * isnull( A.EXCSBJ_R, -1 ) ) / isnull( A.EXCEGP_R, -1) < 999999999999999 )
) */

set arithabort numeric_truncation on

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

exec sp_SCOR_INSPRC 'ESTCTR03', 'PtESTCTRLIS_03', 'BEST', 'ME69'
go

IF OBJECT_ID('PtESTCTRLIS_03') IS NOT NULL
    PRINT '<<< CREATED PROC PtESTCTRLIS_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtESTCTRLIS_03 >>>'
go
/*
 * Granting/Revoking Permissions on PtESTCTRLIS_03
 */
GRANT EXECUTE ON PtESTCTRLIS_03 TO GOMEGA
go

