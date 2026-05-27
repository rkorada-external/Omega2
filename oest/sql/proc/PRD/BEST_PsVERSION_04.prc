USE BEST
Go
 /* DROP PROC dbo.PsVERSION_04
*/
IF OBJECT_ID('dbo.PsVERSION_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsVERSION_04
   PRINT '<<< DROPPED PROC dbo.PsVERSION_04 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsVERSION_04  ( @p_ssd_cf  USSD_CF,
                                                        @p_vrs_nf    numeric ,
                                                        @p_selection  integer )

as

/***************************************************

Programme: PsVERSION_04

Fichier script associé : BEST_PsVERSION_04.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME57

Date de creation: 28/07/2004

Description du programme:
   Selection d'enregistrement dans TVERSION: Permet de ramener max(vrs_nf ) en fontion de la case cochée dans PB.

Parametres:

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:  Marc.SPAGNOLI

Date:28/07/2004

Version:

Description: Le @p_vrs_nf  ne sert plus mais on ne sait jamais !

*****************************************************/
declare @erreur int , @vrs_nf numeric , @vrs_lm   UL32

IF @p_selection = 1
BEGIN

         SELECT 	@vrs_nf = Max(VRS_NF)
        FROM   BEST..TVERSION
        WHERE     SSD_CF = @p_ssd_cf
        AND      VRSSTS_CT = "CO"
        AND      VRSACC_D <> NULL

           select @erreur = @@error

           if @erreur != 0
           begin
              return @erreur
           end
END


IF @p_selection = 2
BEGIN
         SELECT @vrs_nf = max(VRS_NF)
        FROM   BEST..TVERSION
        WHERE     SSD_CF = @p_ssd_cf
        AND      VRSSTS_CT = ""
        AND      VRSACC_D = NULL

           select @erreur = @@error

           if @erreur != 0
           begin
              return @erreur
           end

END

--Le @p_vrs_nf nous sert à ramener le libbellé
SELECT @vrs_lm = vrs_lm
        FROM   BEST..TVERSION
        WHERE     SSD_CF = @p_ssd_cf
         AND         vrs_nf = @vrs_nf

SELECT  @vrs_lm     , @vrs_nf

return 0
go


exec sp_SCOR_INSPRC 'ESSSEC21', 'PsVERSION_04', 'BEST', 'ME57'
go

IF OBJECT_ID('dbo.PsVERSION_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsVERSION_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsVERSION_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsVERSION_04
 */
GRANT EXECUTE ON dbo.PsVERSION_04 TO GOMEGA
go

