/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsRETCTR_06
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsRETCTR_06') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETCTR_06
   PRINT '<<< DROPPED PROC dbo.PsRETCTR_06 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsRETCTR_06
     (
	 @p_rty_nf               UUWY_NF,
 	 @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsRETCTR_06

Fichier script associé : ESSRET06.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 20/10/1997

Description du programme: 

      Sélection d'enregistrement dans RETRO / TSECTION(sert à ESTIMATIONS)

Parametres: 

	 @p_rty_nf               UUWY_NF,
 	 @p_ctr_nf              UCTR_NF

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 22/04/1998

Version:

Description: On ne sélectionne que la section comptabilisable
	      (celle qui n'est pas une pseudo section)

*****************************************************/

declare @erreur int



 Select RETSEC_NF
	  
   	from BRET..TRETSEC
		 where RETCTR_NF = @p_ctr_nf
			and RTY_NF = @p_rty_nf 
			and PSESEC_B = 0
			
 

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TRETSEC" 
      return 1
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSRET06', 'PsRETCTR_06', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsRETCTR_06') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETCTR_06 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETCTR_06 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETCTR_06
 */
GRANT EXECUTE ON dbo.PsRETCTR_06 TO GOMEGA
go

