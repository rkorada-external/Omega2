use BEST
go

/*
 * DROP PROC dbo.PsCONTR_14
 */

USE BEST
Go


IF OBJECT_ID('dbo.PsCONTR_14') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCONTR_14
    PRINT '<<< DROPPED PROC dbo.PsCONTR_14 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCONTR_14
     (
/*	@p_ssd_cf		  USSD_CF,*/
	 @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsCONTR_14

Fichier script associé : ESSCTR14.PRC

Base principale : BTRT

Version: 1

Auteur: ME01

Date de creation: 25/09/1997

Description du programme:

      Sélection d'enregistrement dans TCONTR  (sert au domaine ESTIMATION)

Parametres: 
/* 	@p_ssd_cf		  USSD_CF,*/
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

declare @erreur int,
	  @ctr_nf		UCTR_NF,
         @ssd_cf	      char(2)
	  			

/* ------------------------- Select dans la table TCONTR ---------------------------- */
/* Liste des exercices des contrats présentant des sections                           */
/*	acceptées 14			  								     */
/*	définitives 16										     */
/*    renouvelées 17										     */
/*    résiliées 19                                                                    */


/* Select uwy_nf

 from BTRT..TCONTR

 where ctr_nf = @p_ctr_nf
    and end_nt = 0			
    and uw_nt = 1	*/

Select distinct C.uwy_nf

 from BTRT..TCONTR C, BTRT..TSECTION S

 where C.ctr_nf = S.ctr_nf
    and C.uwy_nf = S.uwy_nf
    and C.end_nt = S.end_nt
    and C.uw_nt = S.uw_nt	
    and C.ctr_nf = @p_ctr_nf and S.ctr_nf = @p_ctr_nf 
    and C.end_nt = 0 and S.end_nt = 0			
    and C.uw_nt = 1 and S.uw_nt = 1
    and (S.secsts_ct = 14 or S.secsts_ct = 16 or S.secsts_ct = 17 or S.secsts_ct = 19)
 
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
IF OBJECT_ID('dbo.PsCONTR_14') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCONTR_14 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCONTR_14 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCONTR_14
 */
GRANT EXECUTE ON dbo.PsCONTR_14 TO GOMEGA
go

