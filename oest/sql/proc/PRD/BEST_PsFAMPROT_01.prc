use BEST
go

/* DROP PROC dbo.PsFAMPROT_01
*/
IF OBJECT_ID('dbo.PsFAMPROT_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsFAMPROT_01
   PRINT '<<< DROPPED PROC dbo.PsFAMPROT_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsFAMPROT_01
     
as

/***************************************************

Programme: PsFAMPROT_01

Fichier script associé : ESSPRO01.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME69

Date de creation: 

Description du programme: 
	Descente de la table BFAC..TFAMPROT 

Parametres: 

Conditions d'execution: 

Commentaires:

_________________
MODIFICATION 1

Auteur : MONTAGNAC

Date:	23-08-99

Version:

Description: Ajout de la filiale (jointure sur TSECTION) dans le select
________________________


[002] -=Dch=- 07/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD

*****************************************************/


declare @erreur int

select @erreur = 0

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr



/***************************************/
/* Descente de la table BFAC..TFAMPROT */
/***************************************/

select S.SSD_CF, F.CTR_NF, F.END_NT , F.SEC_NF, F.UWY_NF, F.UW_NT, LAYTYP_CT, LAYCOS_M, LAYPLCSHA_R
from   BFAC..TFAMPROT F, BFAC..TSECTION S , #ssds BS
where F.CTR_NF=S.CTR_NF and F.END_NT=S.END_NT and F.SEC_NF=S.SEC_NF and F.UWY_NF=S.UWY_NF and F.UW_NT=S.UW_NT
and S.SSD_CF = BS.SSD_CF
order by CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT

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


IF OBJECT_ID('dbo.PsFAMPROT_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsFAMPROT_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsFAMPROT_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsFAMPROT_01
 */
GRANT EXECUTE ON dbo.PsFAMPROT_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFAMPROT_01 TO GDBBATCH
go

