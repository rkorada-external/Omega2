USE BEST
Go

 /* DROP PROC dbo.PsSEGEST_20
*/
IF OBJECT_ID('dbo.PsSEGEST_20') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSEGEST_20
   PRINT '<<< DROPPED PROC dbo.PsSEGEST_20 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsSEGEST_20
     (
       @p_seg_nf              USEG_NF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric
     )
as

/***************************************************

Programme: PsSEGEST_20

Fichier script associé : ESSSEG20.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Sélection d'enregistrement dans TSEGEST

Parametres:
       @p_seg_nf              USEG_NF,	: Identifiant segment
       @p_segtyp_ct           USEGTYP_CT,	: Type segment
       @p_ssd_cf              USSD_CF, 	: Filiale
       @p_vrs_nf              numeric,	: Version


Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: L.Debever

Date:13/11/1997

Version:

Description: Lors du select de losrat : losrat_r*10000 (avant losrat_r*100)
             -> Ceci car losrat_r est désormais stocké en 10 -2

*****************************************************/

declare @erreur int


 Select uwy_nf,
        clmamt_m,
        prmamt_m,
        losrat_r*10000 losrat_r, /* S/P en % */
        cur_cf,
        @p_seg_nf,
        @p_segtyp_ct,
        @p_ssd_cf,
        @p_vrs_nf
   from TSEGEST
  where seg_nf = @p_seg_nf
    and ssd_cf = @p_ssd_cf
    and segtyp_ct = @p_segtyp_ct
    and vrs_nf = @p_vrs_nf


   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TSEGEST" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEG20', 'PsSEGEST_20', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsSEGEST_20') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSEGEST_20 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSEGEST_20 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSEGEST_20
 */
GRANT EXECUTE ON dbo.PsSEGEST_20 TO GOMEGA
go

