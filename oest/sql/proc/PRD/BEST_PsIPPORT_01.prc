use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsIPPORT_01
*/
IF OBJECT_ID('dbo.PsIPPORT_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsIPPORT_01
   PRINT '<<< DROPPED PROC dbo.PsIPPORT_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsIPPORT_01
     (
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsIPPORT_01

Fichier script associé : ESSIPP01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TIPPORT

Parametres: 
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_ctr_nf              UCTR_NF

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: G.DIMCEA

Date:	  12/06/97

Version:

Description: Ajout de la colonne SIGNED_R
*****************************************************/

declare @erreur int


 Select ctr_nf,
        end_nt,
        sec_nf,
        uw_nt,
        uwy_nf,
        cur_cf,
        estipp_m,
        recipp_m,
	  signed_r * 100
   from TIPPORT
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TIPPORT" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSIPP01', 'PsIPPORT_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsIPPORT_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsIPPORT_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsIPPORT_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsIPPORT_01
 */
GRANT EXECUTE ON dbo.PsIPPORT_01 TO GOMEGA
go

