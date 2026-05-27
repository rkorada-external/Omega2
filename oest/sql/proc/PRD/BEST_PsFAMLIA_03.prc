/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsFAMLIA_03
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsFAMLIA_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsFAMLIA_03
   PRINT '<<< DROPPED PROC dbo.PsFAMLIA_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsFAMLIA_03
     (

 @p_END_NT       UEND_NT,
 @p_SEC_NF       USEC_NF,
 @p_UW_NT        UUW_NT,
 @p_UWY_NF       UUWY_NF,
 @p_CTR_NF       UCTR_NF,
 @p_BASE         Char(3) 
     )
as

/***************************************************

Programme: PsFAMLIA_03

Fichier script associé : ESSLIA03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 15 Octobre 1997

Description du programme: 

      Sélection d'enregistrement dans TRAITE ou FAC

Parametres: 

 @p_END_NT       UEND_NT,
 @p_SEC_NF       USEC_NF,
 @p_UW_NT        UUW_NT,
 @p_UWY_NF       UUWY_NF,
 @p_CTR_NF       UCTR_NF,
 @p_BASE         Char(3) 	

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

/********************************************************************************************/
/* Select dans TFAMLIA                                                                      */
/*    Monnaie de l'aliment      		                                                  */
/********************************************************************************************/

If @p_base = 'TRT'

BEGIN

 Select EGPCUR_CF
        
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

END

If @p_base = 'FAC'

BEGIN

 Select EGPCUR_CF
        
   	from BFAC..TFAMLIA
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

END

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSLIA03', 'PsFAMLIA_03', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsFAMLIA_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsFAMLIA_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsFAMLIA_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsFAMLIA_03
 */
GRANT EXECUTE ON dbo.PsFAMLIA_03 TO GOMEGA
go

