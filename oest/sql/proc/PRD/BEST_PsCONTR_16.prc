USE BEST
Go

IF OBJECT_ID('dbo.PsCONTR_16') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCONTR_16
    PRINT '<<< DROPPED PROC dbo.PsCONTR_16 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCONTR_16
     (
/*	@p_ssd_cf		  USSD_CF,
	@p_end_nt		  UEND_NT,
	@p_uw_nt		   UUW_NT,*/
	 @p_ctr_nf              UCTR_NF

     )
as

/***************************************************

Programme: PsCONTR_16

Fichier script associé : ESSCTR16.PRC

Base principale : BTRT

Version: 1

Auteur: ME01 (L.DEBEVER)

Date de creation: 26/09/1997

Description du programme:

      Sélection d'enregistrement dans TCONTR  (sert au domaine ESTIMATION)

Parametres: 
 	@p_ssd_cf		  USSD_CF,
	@p_end_nt		  UEND_NT,
	@p_uw_nt		   UUW_NT,
    @p_ctr_nf              UCTR_NF

Conditions d'execution: 



Commentaires:

_________________
MODIFICATION 1

Auteur: M.DJELLOULI
Date:   20/12/2004
Version:
Description: Inclusion des FACs expirées. (Statut 18)

*****************************************************/

declare @erreur int,
	  @ctr_nf		UCTR_NF,
         @ssd_cf	      char(2)
	  			

/* ------------------------- Select dans la table TCONTR ---------------------------- */
/* Liste des exercices des contrats présentant des sections                           */
/*	acceptées 14			  								     */
/*	définitives 16										     */
/*    renouvelées 17										     */
/*    résiliées 19                                                                    */
--     Expirees 18              -- MOD001


Select distinct C.uwy_nf

 from BFAC..TCONTR C, BFAC..TSECTION S

 where C.ctr_nf = S.ctr_nf
    and C.uwy_nf = S.uwy_nf
 /*   and C.end_nt = S.end_nt
    and C.uw_nt = S.uw_nt */	
    and C.ctr_nf = @p_ctr_nf and S.ctr_nf = @p_ctr_nf 
/*    and C.end_nt = @p_end_nt and S.end_nt = @p_end_nt			
    and C.uw_nt = @p_uw_nt and S.uw_nt = @p_uw_nt */
    and (S.secsts_ct = 14 or S.secsts_ct = 16 
         or S.secsts_ct = 17 or S.secsts_ct = 19 or (S.SECACCSTS_CT <> 9 and S.secsts_ct = 18) ) -- MOD001
 
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
IF OBJECT_ID('dbo.PsCONTR_16') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCONTR_16 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCONTR_16 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCONTR_16
 */
GRANT EXECUTE ON dbo.PsCONTR_16 TO GOMEGA
go

