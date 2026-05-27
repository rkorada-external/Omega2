use BEST
go

use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/* DROP PROC dbo.PsSEGMENT_01
*/
IF OBJECT_ID('dbo.PsSEGMENT_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSEGMENT_01
   PRINT '<<< DROPPED PROC dbo.PsSEGMENT_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSEGMENT_01
     (
/*       @p_seg_nf              USEG_NF */
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric
     )
as

/***************************************************

Programme: PsSEGMENT_01

Fichier script associé : ESSSGM01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TSEGMENT

Parametres: 
/*       @p_seg_nf              USEG_NF, */
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric

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


 Select seg_nf
   from TSEGMENT
  where segtyp_ct = @p_segtyp_ct
    and ssd_cf = @p_ssd_cf
    and vrs_nf = @p_vrs_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TSEGMENT" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSGM01', 'PsSEGMENT_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsSEGMENT_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSEGMENT_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSEGMENT_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSEGMENT_01
 */
GRANT EXECUTE ON dbo.PsSEGMENT_01 TO GOMEGA
go

