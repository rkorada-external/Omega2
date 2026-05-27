use BEST
go

use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsFAMLIA_01
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsFAMLIA_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsFAMLIA_01
   PRINT '<<< DROPPED PROC dbo.PsFAMLIA_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsFAMLIA_01
     (

 @p_END_NT       UEND_NT,
 @p_SEC_NF       USEC_NF,
 @p_UW_NT        UUW_NT,
 @p_UWY_NF       UUWY_NF,
 @p_CTR_NF       UCTR_NF
 
     )
as

/***************************************************

Programme: PsFAMLIA_01

Fichier script associé : ESSLIA01.PRC

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
	@SCOORGEGP_M  UAMT_M,   /* zones table TFAMLIA - alim. part scor (base Traité) */
	@SCOGLOEGP_M  UAMT_M,
	@EGPXXXSCO_M  UAMT_M,
	@EGPCUR_CF    UCUR_CF

/********************************************************************************************/
/* Select dans TFAMLIA                                                                      */
/*    Montant et Monnaie de l'aliment à la part scor révisé ou à défaut estimé              */
/*     (correspondant audernier ex de souscription)                                         */
/********************************************************************************************/


 Select @SCOORGEGP_M  = SCOORGEGP_M,
	  @SCOGLOEGP_M = SCOGLOEGP_M,
	  @EGPCUR_CF = EGPCUR_CF
        
   	from BTRT..TFAMLIA
  where CTR_NF = @p_CTR_NF
    and END_NT = @p_END_NT
    and SEC_NF = @p_SEC_NF
    and UW_NT = @p_UW_NT
    and UWY_NF = @p_UWY_NF

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TFAMLIA" 
      return 1
   end

If  @SCOGLOEGP_M is null
  begin
	select @EGPXXXSCO_M = @SCOORGEGP_M
  end
else
  begin
	select @EGPXXXSCO_M = @SCOGLOEGP_M
  end


/********************************************************************************************/
/* Select final :                                                                           */
/* retour des info sous la forme d'une chaine de caractères                                 */      
/********************************************************************************************/

Select @EGPXXXSCO_M EGPXXXSCO_M,
	 @EGPCUR_CF   EGPCUR_CF



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSLIA01', 'PsFAMLIA_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsFAMLIA_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsFAMLIA_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsFAMLIA_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsFAMLIA_01
 */
GRANT EXECUTE ON dbo.PsFAMLIA_01 TO GOMEGA
go

