use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 *USE BEST
 * Go
 * DROP PROC dbo.PsEARIPP_03
*/
IF OBJECT_ID('dbo.PsEARIPP_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsEARIPP_03
   PRINT '<<< DROPPED PROC dbo.PsEARIPP_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsEARIPP_03
     (
/*       @p_acy_nf              smallint, */
       @p_end_nt              UEND_NT,
/*       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint, */
       @p_sec_nf              USEC_NF, 
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsEARIPP_03

Fichier script associé : ESSEAR03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER - OME01)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TEARIPP

Parametres: 
      /*       @p_acy_nf              smallint, */
       @p_end_nt              UEND_NT,
/*       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint, */
       @p_sec_nf              USEC_NF,
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
        cur_cf,
        refprm_m,
        wpport_m,
        periode =  substring(convert(char(3), 100 + scostrmth_nf),2,2) + 
        	   "-" + 
        	   substring(convert(char(3), 100 + scoendmth_nf),2,2)
   from TEARIPP
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TEARIPP" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSEAR03', 'PsEARIPP_03', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsEARIPP_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsEARIPP_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsEARIPP_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsEARIPP_03
 */
GRANT EXECUTE ON dbo.PsEARIPP_03 TO GOMEGA
go

