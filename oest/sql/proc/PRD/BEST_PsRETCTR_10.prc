/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsRETCTR_10
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsRETCTR_10') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETCTR_10
   PRINT '<<< DROPPED PROC dbo.PsRETCTR_10 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsRETCTR_10
as

/***************************************************

Programme: PsRETCTR_10

Fichier script associé : ESSRET10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 20/10/1997

Description du programme: 

      Sélection d'enregistrement dans RETRO (sert à ESTIMATIONS)

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

/* ------------------------- Select dans la table TCONTR ---------------------------- */
/* Liste des exercices des contrats de catégorie non proportionnelle,                 */
/* présentant des sections :                                                          */
/*	- non historisés et comptables                                                 */
/*	- valides 16			  						         */
/*     - résiliées 19                                                                 */

	select
		SSD_CF ,
		RETCTR_NF    ,
		0 RETEND_NT  ,
		RETSEC_NF,
		RTY_NF,
		0 RETUW_NT
	from	BRET..TRETSEC
	WHERE LOB_CF in ("30","31")
	order by SSD_CF, RTY_NF


   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TRETCTR" 
      return 1
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSRET10', 'PsRETCTR_10', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsRETCTR_10') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETCTR_10 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETCTR_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETCTR_10
 */
GRANT EXECUTE ON dbo.PsRETCTR_10 TO GOMEGA
go

