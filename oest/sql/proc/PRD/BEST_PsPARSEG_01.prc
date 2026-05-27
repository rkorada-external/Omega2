use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsPARSEG_01
*/
IF OBJECT_ID('dbo.PsPARSEG_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsPARSEG_01
   PRINT '<<< DROPPED PROC dbo.PsPARSEG_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsPARSEG_01
     (
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsPARSEG_01

Fichier script associé : ESSPAR01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TPARSEG

Parametres: 
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF

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


 Select segtyp_ct,
        ssd_cf,
        seg_d
   from TPARSEG
  where segtyp_ct = @p_segtyp_ct
    and ssd_cf = @p_ssd_cf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TPARSEG" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSPAR01', 'PsPARSEG_01', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PsPARSEG_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsPARSEG_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsPARSEG_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPARSEG_01
 */
GRANT EXECUTE ON dbo.PsPARSEG_01 TO GOMEGA
go

