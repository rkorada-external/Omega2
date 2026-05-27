use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/* DROP PROC dbo.PsACMTRSH_02
 */
IF OBJECT_ID('dbo.PsACMTRSH_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsACMTRSH_02
   PRINT '<<< DROPPED PROC dbo.PsACMTRSH_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsACMTRSH_02
as

/***************************************************

Programme: PsACMTRSH_02

Fichier script associé : ESSACM02.PRC

Domaine : (ES) Estimation

Base principale : BREF

Version: 1

Auteur: ME27 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TACMTRSH

Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: Kbagwe

Date: 05/06/2013

Version:

Description: Modification for BREF..TACMTRSH -> BREF..TACMTRSL obsolete table

*****************************************************/

	declare @erreur int


	Select ssd_cf ,
		acmtrs_nt,
		Acmtrs_Gs										--MODI 01
	from BREF..TACMTRSL, BREF..TSUBSID 					--MODI 01
	where 	prs_cf = 500  AND LAG_CF = SSDOMGLAG_CF		--MODI 01
	order by acmtrs_nt

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TACMTRSH" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSACM02', 'PsACMTRSH_02', 'BREF', 'ME27'
go

IF OBJECT_ID('dbo.PsACMTRSH_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsACMTRSH_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsACMTRSH_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsACMTRSH_02
 */
GRANT EXECUTE ON dbo.PsACMTRSH_02 TO GOMEGA
go

