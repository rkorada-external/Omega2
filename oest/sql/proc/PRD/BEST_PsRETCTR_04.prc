use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsRETCTR_04
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsRETCTR_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETCTR_04
   PRINT '<<< DROPPED PROC dbo.PsRETCTR_04 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsRETCTR_04
     (
  	 @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsRETCTR_04

Fichier script associé : ESSRET04.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 20/10/1997

Description du programme: 

      Sélection d'enregistrement dans RETRO (sert à ESTIMATIONS)

Parametres: 

 	 @p_ctr_nf              UCTR_NF

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
/* Liste des exercices des contrats présentant des sections :                         */
/*	- non historisés et comptables                                                 */
/*	- valides 16			  						         */
/*     - résiliées 19                                                                 */


 Select distinct C.RTY_NF
	  
   	from BRET..TRETCTR C, BRET..TPLACEMT P
		 where C.RETCTR_NF = P.RETCTR_NF
			and C.RTY_NF = P.RTY_NF
			and C.RETCTR_NF = @p_ctr_nf and P.RETCTR_NF = @p_ctr_nf
			and P.HIS_B = 0
			and P.ACCPLC_B = 1
			and (P.PLCSTS_CT = 16 or P.PLCSTS_CT = 19)
 

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

exec sp_SCOR_INSPRC 'ESSRET04', 'PsRETCTR_04', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsRETCTR_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETCTR_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETCTR_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETCTR_04
 */
GRANT EXECUTE ON dbo.PsRETCTR_04 TO GOMEGA
go

