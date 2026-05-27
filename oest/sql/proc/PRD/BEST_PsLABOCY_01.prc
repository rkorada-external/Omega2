use BEST
go


USE BEST
Go

/* DROP PROC dbo.PsLABOCY_01
*/
IF OBJECT_ID('dbo.PsLABOCY_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsLABOCY_01
   PRINT '<<< DROPPED PROC dbo.PsLABOCY_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsLABOCY_01
     (
       @p_seg_nf              USEG_NF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric,
       @p_uwy_nf              UUWY_NF
     )
as

/***************************************************

Programme: PsLABOCY_01

Fichier script associé : ESSLAB01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TLABOCY

Parametres: 
       @p_seg_nf              USEG_NF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric,
       @p_uwy_nf              UUWY_NF,
       @p_occyea_nf           smallint,
       @p_cre_d               UUPD_D

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


 Select @p_seg_nf,
        @p_segtyp_ct,
        @p_ssd_cf,
        @p_vrs_nf,
        @p_uwy_nf,
        occyea_nf,
        spirat_r*100 spirat_r, /* en % */
        cre_d
   from TLABOCY
  where seg_nf = @p_seg_nf
    and segtyp_ct = @p_segtyp_ct
    and ssd_cf = @p_ssd_cf
    and vrs_nf = @p_vrs_nf
    and uwy_nf = @p_uwy_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TLABOCY" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSLAB01', 'PsLABOCY_01', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsLABOCY_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsLABOCY_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsLABOCY_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsLABOCY_01
 */
GRANT EXECUTE ON dbo.PsLABOCY_01 TO GOMEGA
go

