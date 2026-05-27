/*
 * DROP PROC dbo.PsCONTR_18
 */

USE BEST
Go


IF OBJECT_ID('dbo.PsCONTR_18') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCONTR_18
    PRINT '<<< DROPPED PROC dbo.PsCONTR_18 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCONTR_18
     (
/*	@p_ssd_cf		  USSD_CF,*/
	 @p_ctr_nf           UCTR_NF,
	@p_uwy_nf           UUWY_NF  
     )
as

/***************************************************

Programme: PsCONTR_18

Fichier script associé : ESSCTR18.PRC

Base principale : BTRT

Version: 1

Auteur: ME01

Date de creation: 20/10/1997

Description du programme:

      Sélection d'enregistrement dans FAC / TCONTR  (sert au domaine ESTIMATION)

Parametres: 
/* 	@p_ssd_cf		  USSD_CF,*/
	 @p_ctr_nf           UCTR_NF,
	@p_uwy_nf           UUWY_NF     

Conditions d'execution: 



Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 30/03/1998

Version:

Description: la longueur de @info passe de 17c à 20 c

*****************************************************/

declare @erreur int,
	  @ced_nf 	UCLI_NF, 
	 @prd_nf  	UCLI_NF,
	 @genprmpay_nf UCLI_NF,
	 @ganpayord_nt  	UPAYORD_NT,
	  @info   char(17)
	  			

/* ------------------------- Select dans la table TCONTR ---------------------------- */


Select @ced_nf = ced_nf,
	 @prd_nf = prd_nf,
	 @genprmpay_nf = genprmpay_nf,
	 @ganpayord_nt = ganpayord_nt

 from BFAC..TCONTR

 where ctr_nf = @p_ctr_nf
    and uwy_nf = @p_uwy_nf 
    and end_nt = 0		
    and uw_nt = 1

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCONTR" /* erreur de lecture */
  return @erreur
   end

/* retour des info sous la forme d'une chaine de caractères */

select @info = convert(char(5),@ced_nf) + "/" + convert(char(5),@prd_nf) + "/" + convert(char(5),@genprmpay_nf) + "/" + @ganpayord_nt

select @info

       
return 0
/* ### DEFNCOPY: END OF DEFINITION */
/* ### DEFNCOPY: END OF DEFINITION */

go
IF OBJECT_ID('dbo.PsCONTR_18') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCONTR_18 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCONTR_18 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCONTR_18
 */
GRANT EXECUTE ON dbo.PsCONTR_18 TO GOMEGA
go

