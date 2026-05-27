use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/* DROP PROC dbo.PsGRP_03
 */
IF OBJECT_ID('dbo.PsGRP_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsGRP_03
   PRINT '<<< DROPPED PROC dbo.PsGRP_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsGRP_03
as

/***************************************************

Programme: PsGRP_03

Fichier script associé : ESSGRP03.PRC

Domaine : (ES) Estimation

Base principale : BREF

Version: 1

Auteur: ME27 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TGRP

Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:kbagwe

Date:4/12/2013

Version:

Description:Replacement of obsolete table

*****************************************************/

declare @erreur int


 Select grp_cf,ssd_cf, grp_ls
   from BREF..TGRP2

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TGRP" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSGRP03', 'PsGRP_03', 'BREF', 'ME27'
go

IF OBJECT_ID('dbo.PsGRP_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsGRP_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsGRP_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsGRP_03
 */
GRANT EXECUTE ON dbo.PsGRP_03 TO GOMEGA
go

