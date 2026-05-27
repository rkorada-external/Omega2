use BEST
go

use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsFAMLIA_02
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsFAMLIA_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsFAMLIA_02
   PRINT '<<< DROPPED PROC dbo.PsFAMLIA_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsFAMLIA_02
     (

 @p_END_NT       UEND_NT,
 @p_SEC_NF       USEC_NF,
 @p_UW_NT        UUW_NT,
 @p_UWY_NF       UUWY_NF,
 @p_CTR_NF       UCTR_NF
 
     )
as

/***************************************************

Programme: PsFAMLIA_02

Fichier script associé : ESSLIA02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 03 Avril 1997

Description du programme: 

      Sélection d'enregistrement dans TRAITE et COMPTA 

Parametres: 

 @p_END_NT       UEND_NT,
 @p_SEC_NF       USEC_NF,
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
	 @ligne int,
	@UWY_NF	 UUWY_NF,
	@SCOORGEGP_M  UAMT_M,   /* zones table TFAMLIA - alim. part scor (base Traité) */
	@SCOGLOEGP_M  UAMT_M,
	@EGPXXXSCO_M  UAMT_M,
	@EGPCUR_CF    UCUR_CF
		


/********************************************************************************************/
/* Select dans TFAMLIA                                                                      */
/*    Monnaie de l'aliment à la part scor révisé ou à défaut estimé(correspondant aux       */
/*    années de souscription sélectionnées)                                                 */
/********************************************************************************************/


/*Select  @UWY_NF = UWY_NF, 
	  @SCOORGEGP_M  = SCOORGEGP_M,
	  @SCOGLOEGP_M = SCOGLOEGP_M*/

Select  UWY_NF, 
	  SCOORGEGP_M,
	  SCOGLOEGP_M,
	  EGPCUR_CF
        
   	from BTRT..TFAMLIA
  where CTR_NF = @p_CTR_NF
    and END_NT = @p_END_NT
    and SEC_NF = @p_SEC_NF
    and UW_NT = @p_UW_NT
    and UWY_NF >= @p_UWY_NF

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TFAMLIA" 
      return 1
   end


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSLIA02', 'PsFAMLIA_02', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsFAMLIA_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsFAMLIA_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsFAMLIA_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsFAMLIA_02
 */
GRANT EXECUTE ON dbo.PsFAMLIA_02 TO GOMEGA
go

