use BEST
go


USE BEST
Go

/* DROP PROC dbo.PsCALPRE_02
*/
IF OBJECT_ID('dbo.PsCALPRE_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCALPRE_02
   PRINT '<<< DROPPED PROC dbo.PsCALPRE_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCALPRE_02
     (
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              numeric,
       @p_uwy_nf              UUWY_NF,
       @p_uw_nt               UUW_NT
      )
as

/***************************************************

Programme: PsCALPRE_02

Fichier script associé : ESSCAL02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME08 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TCALPRE

Parametres: 
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              numeric,
       @p_uwy_nf              UUWY_NF,
       @p_uw_nt               UUW_NT

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


 Select acy_nf,
        scostrmth_nf,
        scoendmth_nf,
        isNull(recprm_m,0),
        isNull(brrecprm_m,0),
        isNull(estprm_m,0),
        isNull(brestprm_m,0),
        isNull(urnrecprm_m,0),
        isNull(urnestprm_m,0),
        cur_cf,
        ssd_cf
   from TCALPRE
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uwy_nf = @p_uwy_nf
    and uw_nt = @p_uw_nt

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCALPRE" /* erreur de selection */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCAL02', 'PsCALPRE_02', 'BEST', 'ME08'
go

IF OBJECT_ID('dbo.PsCALPRE_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCALPRE_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCALPRE_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCALPRE_02
 */
GRANT EXECUTE ON dbo.PsCALPRE_02 TO GOMEGA
go

