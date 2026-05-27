use BEST
go

USE BEST
Go
DROP PROC dbo.PsANASEG_03
IF OBJECT_ID('dbo.PsANASEG_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsANASEG_03
   PRINT '<<< DROPPED PROC dbo.PsANASEG_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsANASEG_03
     (
       @p_seg_nf              USEG_NF,
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsANASEG_03

Fichier script associé : ESSANA03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0  
Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TANASEG

Parametres: 
       @p_seg_nf              USEG_NF,
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


 Select seg_ls
   from TANASEG
  where seg_nf = @p_seg_nf
    and ssd_cf = @p_ssd_cf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TANASEG" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSANA03', 'PsANASEG_03', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PsANASEG_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsANASEG_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsANASEG_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsANASEG_03
 */
GRANT EXECUTE ON dbo.PsANASEG_03 TO GOMEGA
go

