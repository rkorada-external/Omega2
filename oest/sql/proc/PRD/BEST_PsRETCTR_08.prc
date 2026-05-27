use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsRETCTR_08
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsRETCTR_08') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETCTR_08
   PRINT '<<< DROPPED PROC dbo.PsRETCTR_08 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsRETCTR_08
     (
	 @p_rty_nf               UUWY_NF,
 	 @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsRETCTR_08

Fichier script associé : ESSRET08.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 21/10/1997

Description du programme: 

      Sélection d'enregistrement dans RETRO (sert à ESTIMATIONS)

Parametres: 

 	 @p_rty_nf               UUWY_NF,
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


/* ------------------------- Select dans la table TRETCTR ---------------------------- */
/* Devise de représentation                                                            */


 Select  RETPCPCUR_CF

   from BRET..TRETCTR
  	where RETCTR_NF = @p_ctr_nf
    	and RTY_NF = @p_rty_nf

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

exec sp_SCOR_INSPRC 'ESSRET08', 'PsRETCTR_08', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsRETCTR_08') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETCTR_08 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETCTR_08 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETCTR_08
 */
GRANT EXECUTE ON dbo.PsRETCTR_08 TO GOMEGA
go

