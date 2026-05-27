use BEST
go


USE BEST
Go

/* DROP PROC dbo.PsVERSION_02
*/
IF OBJECT_ID('dbo.PsVERSION_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsVERSION_02
   PRINT '<<< DROPPED PROC dbo.PsVERSION_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsVERSION_02
     (
       @p_vrs_nf              numeric,
       @p_ssd_cf              USSD_CF,
       @p_segtyp_ct           USEGTYP_CT
     )
as

/***************************************************

Programme: PsVERSION_02

Fichier script associé : ESSVER02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TVERSION

Parametres: 
       @p_ssd_cf              USSD_CF,     : Filiale
       @p_segtyp_ct           USEGTYP_CT,  : Type segment
       @p_vrs_nf              numeric      : N° de version


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

/*----------------------------------------------------
Contrôle si la version (vrs_nf) existe, et qu'elle 
ne soit pas "en anomalie/comptabilisée/vérouillée"
----------------------------------------------------*/

 Select vrs_lm
   from TVERSION
  where ssd_cf    = @p_ssd_cf
    and segtyp_ct = @p_segtyp_ct
    and vrs_nf    = @p_vrs_nf
    and vrsloc_b  = 0           /* Vérouillé         */
    and vrssts_ct <> "CO"	 /* Comptabilisée     */
    and vrssts_ct <> "AN"       /* En anomalie       */

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TVERSION (2)" /* erreur de sélection */
      return @erreur
   end


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSVER02', 'PsVERSION_02', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsVERSION_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsVERSION_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsVERSION_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsVERSION_02
 */
GRANT EXECUTE ON dbo.PsVERSION_02 TO GOMEGA
go

