use BEST
go

/* DROP PROC dbo.PsUNDSTA_01
*/
IF OBJECT_ID('dbo.PsUNDSTA_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsUNDSTA_01
   PRINT '<<< DROPPED PROC dbo.PsUNDSTA_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsUNDSTA_01
     
as

/***************************************************

Programme: PsUNDSTA_01

Fichier script associé : ESSUND01.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME69

Date de creation: 

Description du programme: 
	Descente de la table BEST..TUNDSTA 

Parametres: 

Conditions d'execution: 

Commentaires:

_________________
MODIFICATION 1

Auteur : P. Coppin
Date:	   21/10/2013
Version:
Description: :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
*****************************************************/

declare @erreur int

select @erreur = 0


/**************************************/
/* Descente de la table BEST..TUNDSTA */
/**************************************/

select a.CTR_NF, a.END_NT , a.SEC_NF, a.UWY_NF, a.UW_NT, a.CUR_CF, a.CACCPRM_M, a.CACCUPR_M, a.CACCCLM_M,
    	a.CACCACR_M, a.CACCLOA_M, a.CACCRESPRM_M, a.ACCPRM_M, a.ACCUPR_M, a.ACCCLM_M, a.ACCACR_M,
	   a.ACCLOA_M, a.ACY_NF, a.SCOENDMTH_NF, a.LSTUPD_D
from   BEST..TUNDSTA a,
       BTRT..TCONTR  b,
       BREF..TBATCHSSD T
 
 Where a.CTR_NF  = b.CTR_NF
 and   a.UWY_NF  = b.UWY_NF
 and   a.UW_NT   = b.UW_NT 
 and   a.END_NT  = b.END_NT
 
 and   b.SSD_CF  = T.SSD_CF
 and   T.BATCHUSER_CF = suser_name()

order by a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT

                   
select @erreur = @@error

if @erreur != 0
   begin
      return @erreur
   end

return 0
go

/*
 * fin de la procedure 
 */


IF OBJECT_ID('dbo.PsUNDSTA_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsUNDSTA_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsUNDSTA_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsUNDSTA_01
 */
GRANT EXECUTE ON dbo.PsUNDSTA_01 TO GOMEGA
go

