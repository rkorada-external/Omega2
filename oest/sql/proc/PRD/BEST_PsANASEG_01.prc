use BEST
go

USE BEST
Go

DROP PROC dbo.PsANASEG_01
go

IF OBJECT_ID('dbo.PsANASEG_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsANASEG_01
   PRINT '<<< DROPPED PROC dbo.PsANASEG_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsANASEG_01
     (@p_ssd_cf              USSD_CF)
as

/***************************************************

Programme: PsANASEG_01

Fichier script associé : ESSANA01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0 

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TANASEG

Parametres: 
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


 Select seg_nf,
        ssd_cf,
        cre_d,
        creusr_cf,
        lstupd_d,
        lstupdusr_cf,
        seg_ls,
        seg_lm
   from TANASEG
  where ssd_cf = @p_ssd_cf
  order by seg_nf

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

exec sp_SCOR_INSPRC 'ESSANA01', 'PsANASEG_01', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PsANASEG_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsANASEG_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsANASEG_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsANASEG_01
 */
GRANT EXECUTE ON dbo.PsANASEG_01 TO GOMEGA
go

