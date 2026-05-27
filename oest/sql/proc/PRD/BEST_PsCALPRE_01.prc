USE BEST
Go

/* DROP PROC dbo.PsCALPRE_01
*/
IF OBJECT_ID('dbo.PsCALPRE_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCALPRE_01
   PRINT '<<< DROPPED PROC dbo.PsCALPRE_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsCALPRE_01
     (
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              numeric,
       @p_uwy_nf              UUWY_NF,
       @p_uw_nt               UUW_NT
      )
as

/***************************************************

Programme: PsCALPRE_01

Fichier script associé : ESSCAL01.PRC

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

Auteur: L.DEBEVER

Date: 23/02/1997

Version:

Description: On ramène la somme des montants par
	      contrat/section/exercice/ordre/avenant

_________________
MODIFICATION 2
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs

*****************************************************/

declare @erreur int

/*
 Select cur_cf,
        isNull(recprm_m,0),
        isNull(estprm_m,0),
        isNull(urnrecprm_m,0),
        isNull(urnestprm_m,0),
        ssd_cf
  from TCALPRE
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uwy_nf = @p_uwy_nf
    and uw_nt = @p_uw_nt
*/


 Select  cur_cf,
        Sum(isNull(recprm_m,0)),
         Sum(isNull(estprm_m,0)),
         Sum(isNull(urnrecprm_m,0)),
         Sum(isNull(urnestprm_m,0)),
        ssd_cf
  from TCALPRE
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uwy_nf = @p_uwy_nf
    and uw_nt = @p_uw_nt
  group by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt, ssd_cf, cur_cf
  order by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt, ssd_cf, cur_cf


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

exec sp_SCOR_INSPRC 'ESSCAL01', 'PsCALPRE_01', 'BEST', 'ME08'
go

IF OBJECT_ID('dbo.PsCALPRE_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCALPRE_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCALPRE_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCALPRE_01
 */
GRANT EXECUTE ON dbo.PsCALPRE_01 TO GOMEGA
go

