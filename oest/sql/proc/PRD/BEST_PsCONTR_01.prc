use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsCONTR_01
*/
IF OBJECT_ID('dbo.PsCONTR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCONTR_01
   PRINT '<<< DROPPED PROC dbo.PsCONTR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCONTR_01
     (
 @p_END_NT       UEND_NT,
 @p_UW_NT        UUW_NT,
 @p_UWY_NF       UUWY_NF,
 @p_CTR_NF       UCTR_NF
 
     )
as

/***************************************************

Programme: PsCONTR_01

Fichier script associé : ESSCON02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 09/07/1997

Description du programme: 

      Sélection d'enregistrement dans TRAITE

Parametres: 

 @p_END_NT       UEND_NT,
 @p_UW_NT        UUW_NT,
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
/* Select dans TCONTR : recherche existence contrat dont l'état est :                       */    
/*         - Accepté (code 14)                                                              */
/*         - Définitif (code 16)                                                            */
/*         - Renouvelé (code 17)                                                            */
/*         - Résilié (code 19)                                                              */
/********************************************************************************************/


 Select CTR_NF 
        
   	from BTRT..TCONTR
  where CTR_NF = @p_CTR_NF
    and END_NT = @p_END_NT
    and UW_NT = @p_UW_NT
    and UWY_NF = @p_UWY_NF
    and (CTRSTS_CT = 14 or CTRSTS_CT = 16 or CTRSTS_CT = 17  or CTRSTS_CT = 19)

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TCONTR" 
      return 1
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCON02', 'PsCONTR_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsCONTR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCONTR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCONTR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCONTR_01
 */
GRANT EXECUTE ON dbo.PsCONTR_01 TO GOMEGA
go

