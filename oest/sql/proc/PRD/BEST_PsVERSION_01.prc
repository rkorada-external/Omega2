use BEST
go


USE BEST
Go

/* DROP PROC dbo.PsVERSION_01
*/
IF OBJECT_ID('dbo.PsVERSION_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsVERSION_01
   PRINT '<<< DROPPED PROC dbo.PsVERSION_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsVERSION_01
     (
       @p_ssd_cf              USSD_CF,
       @p_segtyp_ct           USEGTYP_CT
     )
as

/***************************************************

Programme: PsVERSION_01

Fichier script associé : ESSVER01.PRC

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
Retourne la liste de toutes les versions
qui ne sont pas "en anomalie/comptabilisée/vérouillée"
----------------------------------------------------*/
 Select vrs_nf,
        vrs_lm       
   from TVERSION
  where ssd_cf    = @p_ssd_cf
    and segtyp_ct = @p_segtyp_ct
    and vrsloc_b  = 0           /* Vérouillé         */
    and vrssts_ct <> "CO"	 /* Comptabilisée     */
    and vrssts_ct <> "AN"       /* En anomalie       */

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TVERSION" /* erreur de sélection */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSVER01', 'PsVERSION_01', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsVERSION_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsVERSION_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsVERSION_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsVERSION_01
 */
GRANT EXECUTE ON dbo.PsVERSION_01 TO GOMEGA
go

