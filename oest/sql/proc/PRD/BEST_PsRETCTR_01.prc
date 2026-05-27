use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsRETCTR_01
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsRETCTR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETCTR_01
   PRINT '<<< DROPPED PROC dbo.PsRETCTR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsRETCTR_01
     (
 @p_UWY_NF       UUWY_NF,
 @p_CTR_NF       UCTR_NF
 
     )
as

/***************************************************

Programme: PsRETCTR_01

Fichier script associé : ESSRET02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 09/09/1997

Description du programme: 

      Sélection d'enregistrement dans RETRO

Parametres: 

 @p_UWY_NF       UUWY_NF
 @p_CTR_NF       UCTR_NF
 
	

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int,
	 @ligne int
	

/********************************************************************************************/
/* Select dans TRETCTR : recherche existence contrat dont l'état est :                       */    
/*         - Accepté (code 03)                                                              */
/*         - Résilié (code 19)                                                              */
/********************************************************************************************/


 Select RETCTR_NF 
        
   	from BRET..TRETCTR
  where RETCTR_NF = @p_CTR_NF
    and RTY_NF = @p_UWY_NF
    and (RETCTRSTS_CT = 3 or RETCTRSTS_CT = 19) 

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

exec sp_SCOR_INSPRC 'ESSRET02', 'PsRETCTR_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsRETCTR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETCTR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETCTR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETCTR_01
 */
GRANT EXECUTE ON dbo.PsRETCTR_01 TO GOMEGA
go

