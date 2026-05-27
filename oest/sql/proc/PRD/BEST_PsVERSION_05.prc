USE BEST
Go
 /* DROP PROC dbo.PsVERSION_05
*/
IF OBJECT_ID('dbo.PsVERSION_05') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsVERSION_05
   PRINT '<<< DROPPED PROC dbo.PsVERSION_05 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsVERSION_05  ( @p_ssd_cf  USSD_CF )

as

/***************************************************

Programme: PsVERSION_05

Fichier script associé : BEST_PsVERSION_05.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME57

Date de creation: 09/09/2004

Description du programme:
   Selection d'enregistrement dans TVERSION: Permet de ramener toutes les versions (actuariat) dans PB.

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
declare @erreur int , @vrs_nf numeric , @vrs_lm   UL32


SELECT VRS_NF, SSD_CF, SEGTYP_CT, VRS_LM, VRSCLO_D, VRSACC_D, VRSSTS_CT, VRSLOC_B, CRE_D, CMT_NT
FROM BEST..TVERSION
WHERE VRSLOC_B = 0
AND SSD_CF = @p_ssd_cf
AND SEGTYP_CT = "A"





select @erreur = @@error

if @erreur != 0
begin
        return @erreur
end

return 0
go


exec sp_SCOR_INSPRC 'ESSSEC21', 'PsVERSION_05', 'BEST', 'ME57'
go

IF OBJECT_ID('dbo.PsVERSION_05') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsVERSION_05 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsVERSION_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsVERSION_05
 */
GRANT EXECUTE ON dbo.PsVERSION_05 TO GOMEGA
go

