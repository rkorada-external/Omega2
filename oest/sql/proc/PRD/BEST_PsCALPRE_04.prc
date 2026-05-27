use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsCALPRE_04
*/
IF OBJECT_ID('dbo.PsCALPRE_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCALPRE_04
   PRINT '<<< DROPPED PROC dbo.PsCALPRE_04 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCALPRE_04
     (
/*       @p_acy_nf              smallint, */
       @p_end_nt              UEND_NT,
/*       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint, */
       @p_sec_nf              numeric,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsCALPRE_04

Fichier script associé : ESSCAL04.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER - OME01)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TCALPRE

Parametres: 
      /*       @p_acy_nf              smallint, */
       @p_end_nt              UEND_NT,
/*       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint, */
       @p_sec_nf              numeric,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_ctr_nf              UCTR_NF
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
        ctr_nf,
        end_nt,
        scoendmth_nf,
        scostrmth_nf,
        sec_nf,
        uw_nt,
        uwy_nf,
        brestprm_m,
        brrecprm_m,
        cur_cf,
        estprm_m,
        recprm_m,
        ssd_cf,
        urnestprm_m,
        urnrecprm_m,
        periode =  substring(convert(char(3), 100 + scostrmth_nf),2,2) + 
        	   "-" + 
        	   substring(convert(char(3), 100 + scoendmth_nf),2,2),
	  urnestprm_m + urnrecprm_m
   from TCALPRE
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCALPRE" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCAL04', 'PsCALPRE_04', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsCALPRE_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCALPRE_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCALPRE_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCALPRE_04
 */
GRANT EXECUTE ON dbo.PsCALPRE_04 TO GOMEGA
go

