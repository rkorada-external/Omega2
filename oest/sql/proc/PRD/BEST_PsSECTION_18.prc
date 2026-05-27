USE BEST
Go

IF OBJECT_ID('dbo.PsSECTION_18') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSECTION_18
    PRINT '<<< DROPPED PROC dbo.PsSECTION_18 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_18
    (    
/*	@p_ssd_cf		  USSD_CF,*/
	@p_uwy_nf     	  UUWY_NF,
	 @p_ctr_nf             UCTR_NF   )
as

/***************************************************

Programme: PsSECTION_18

Fichier script associé : ESSSEC18.PRC

Base principale : BEST

Version: 1

Auteur: ME01

Date de creation: 20/10/1997

Description du programme:

      Sélection de n° d'ordres dans TSECTION/FAC  (sert au domaine ESTIMATION)

Parametres: 
/*	@p_ssd_cf		  USSD_CF,*/
	@p_uwy_nf     	  UUWY_NF,
	 @p_ctr_nf             UCTR_NF

Conditions d'execution: 



Commentaires:

_________________
MODIFICATION 1

Auteur: M.DJELLOULI
Date:   21/12/2004
Version:
Description: Inclusion des FACs expirées. (Statut 18)

*****************************************************/

declare @erreur int,
	  @ctr_nf		UCTR_NF,
         @ssd_cf	      char(2)
	  			

/* ------------------------- Select dans la table TCONTR ---------------------------- */
/* Liste des n° d'ordre des contrat :				                       */
/*	acceptées 14			  						         */
/*	définitives 16							                */
/*    renouvelées 17										  */
/*    résiliées 19                                                                    */
--     Expirees 18              -- MOD001


 Select distinct uw_nt

 from BFAC..TSECTION

 where ctr_nf = @p_ctr_nf
    and uwy_nf = @p_uwy_nf
    and (secsts_ct = 14 or secsts_ct = 16 
           or secsts_ct = 17 or secsts_ct = 19 or (SECACCSTS_CT <> 9 and secsts_ct = 18) ) -- MOD001

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
IF OBJECT_ID('dbo.PsSECTION_18') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSECTION_18 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_18 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_18
 */
GRANT EXECUTE ON dbo.PsSECTION_18 TO GOMEGA
go

