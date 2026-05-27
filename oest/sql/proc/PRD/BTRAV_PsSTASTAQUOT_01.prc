use BTRAV
go
/* DROP PROC dbo.PsSTASTAQUOT_01
*/
IF OBJECT_ID('dbo.PsSTASTAQUOT_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSTASTAQUOT_01
   PRINT '<<< DROPPED PROC dbo.PsSTASTAQUOT_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSTASTAQUOT_01
     
     
as

/***************************************************

Programme: PsSTASTAQUOT_01

Fichier script associé : RFSSTA01.PRC

Domaine : (RF) Références

Base principale : BTRAV

Version: 1

Auteur: ME28 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TSTASTAQUOT

Parametres: 

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


 Select ssd_cf,cur_cf,exc_y,exc_d,exc_r from BTRAV..TSTASTAQUOT
 WHERE ssd_CF = 2  and cur_cf = 'ALL' and exc_y > 1992

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TSTASTAQUOT" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'RFSSTA01', 'PsSTASTAQUOT_01', 'BTRAV', 'ME28'
go

IF OBJECT_ID('dbo.PsSTASTAQUOT_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSTASTAQUOT_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSTASTAQUOT_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSTASTAQUOT_01
 */
GRANT EXECUTE ON dbo.PsSTASTAQUOT_01 TO GOMEGA
go

