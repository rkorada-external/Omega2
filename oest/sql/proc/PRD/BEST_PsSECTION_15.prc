use BEST
go

/*
 * DROP PROC dbo.PsSECTION_15
 */

USE BEST
Go


IF OBJECT_ID('dbo.PsSECTION_15') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSECTION_15
    PRINT '<<< DROPPED PROC dbo.PsSECTION_15 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_15
     (    
/*	@p_ssd_cf		  USSD_CF,*/
	@p_uwy_nf     	  UUWY_NF,
	@p_end_nt      	  UEND_NT,
 	@p_uw_nt        	  UUW_NT, 
	 @p_ctr_nf             UCTR_NF   )
as

/***************************************************

Programme: PsSECTION_15

Fichier script associé : ESSSEC15.PRC

Base principale : BEST

Version: 1

Auteur: ME01

Date de creation: 25/09/1997

Description du programme:

      Sélection de sections dans TSECTION / TRAITE (sert au domaine ESTIMATION)

Parametres: 
/* 	@p_ssd_cf		  USSD_CF,*/
	@p_uwy_nf     	  UUWY_NF,
	@p_end_nt      	  UEND_NT,
 	@p_uw_nt        	  UUW_NT, 
	 @p_ctr_nf             UCTR_NF
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
	  @ctr_nf		UCTR_NF,
         @ssd_cf	      char(2)
	  			

/* ------------------------- Select dans la table TCONTR ---------------------------- */
/* Liste des sections des contrat :				                              */
/*	acceptées 14			  								     */
/*	définitives 16										     */
/*    renouvelées 17										     */
/*    résiliées 19                                                                    */


 Select sec_nf,
	  secsts_ct

 from BTRT..TSECTION

 where ctr_nf = @p_ctr_nf
    and uwy_nf = @p_uwy_nf
    and end_nt = @p_end_nt
    and uw_nt = @p_uw_nt 
    and (secsts_ct = 14 or secsts_ct = 16 or secsts_ct = 17 or secsts_ct = 19)

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCONTR" /* erreur de modification */
  return @erreur
   end

       
return 0
/* ### DEFNCOPY: END OF DEFINITION */
/* ### DEFNCOPY: END OF DEFINITION */

go
IF OBJECT_ID('dbo.PsSECTION_15') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSECTION_15 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_15 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_15
 */
GRANT EXECUTE ON dbo.PsSECTION_15 TO GOMEGA
go

