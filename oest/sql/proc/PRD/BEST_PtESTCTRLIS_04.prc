USE BEST
Go

/*
 * DROP PROC PtESTCTRLIS_04
 */
IF OBJECT_ID('PtESTCTRLIS_04') IS NOT NULL
BEGIN
    DROP PROC PtESTCTRLIS_04
    PRINT '<<< DROPPED PROC PtESTCTRLIS_04 >>>'
END
go


/* ------------------------------------------------------------
   Création de table temporaire nécessaire à la compilation
 -------------------------------------------------------------- */

create table #TCONVERSION2 ( 
	CTR_NF		UCTR_NF	NOT NULL, 
	UWY_NF		UUWY_NF	NOT NULL,
	UW_NT		UUW_NT		NOT NULL, 
	END_NT		UEND_NT	NOT NULL,
	SEC_NF		USEC_NF	NOT NULL,
	SSD_CF		USSD_CF	NOT NULL,
	EGPCUR_CF	UCUR_CF	NOT NULL, 
	EXCEGP_R 	ULNGDEC	NULL, 
	LIACUR_CF	UCUR_CF	NOT NULL, 
	EXCLIA_R 	ULNGDEC	NULL )
go


/*
 * creation de la procedure 
*/

create procedure PtESTCTRLIS_04
     
with execute as caller as

/***************************************************

Programme: PtESTCTRLIS_04

Fichier script associé : ESTCTR04.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 21/11/97

Description du programme: 
     - calcul de la conversion du montant de portée en devise aliment.
 

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
[001] 19/05/2014 R. Cassis   :spot:26775  - Autres modifs Omega2 - 1b gestion site
*****************************************************/


declare @erreur      int 

select @erreur = 0

--[001]
declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()

Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

/* -----------------------------------------------------------------------------------------
   Mise a jour de la liste des affaires - recherche de la dernière période compte complet 
----------------------------------------------------------------------------------------- */

set arithabort numeric_truncation off

update	BTRAV..TESTCTRLIS
set	LAYCAP_M = ( isnull( C.LAYCAP_M, 0 ) * isnull( A.EXCLIA_R, -1 ) ) / isnull( A.EXCEGP_R, -1) 
from	#TCONVERSION2 A, BTRAV..TESTCTRLIS C
where	A.CTR_NF = C.CTR_NF
	and A.UWY_NF = C.UWY_NF
	and A.UW_NT = C.UW_NT
	and A.END_NT = C.END_NT
	and A.SEC_NF = C.SEC_NF
   and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(001]
               where A.CTR_NF     = ctr.CTR_NF
               and   ctr.SSD_CF   = batchssd.SSD_CF
               and   BATCHUSER_CF = @suser_Name)
/*	and (
( isnull( C.LAYCAP_M, 0 ) * isnull( A.EXCLIA_R, -1 ) ) / isnull( A.EXCEGP_R, -1) < 999999999999999 ) */

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

exec sp_SCOR_INSPRC 'ESTCTR04', 'PtESTCTRLIS_04', 'BEST', 'ME69'
go

IF OBJECT_ID('PtESTCTRLIS_04') IS NOT NULL
    PRINT '<<< CREATED PROC PtESTCTRLIS_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtESTCTRLIS_04 >>>'
go
/*
 * Granting/Revoking Permissions on PtESTCTRLIS_04
 */
GRANT EXECUTE ON PtESTCTRLIS_04 TO GOMEGA
go
GRANT EXECUTE ON PtESTCTRLIS_04 TO GDBBATCH
go

