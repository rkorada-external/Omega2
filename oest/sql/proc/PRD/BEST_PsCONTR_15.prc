use BEST
go

/*
 * DROP PROC dbo.PsCONTR_15
 */

USE BEST
Go


IF OBJECT_ID('dbo.PsCONTR_15') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCONTR_15
    PRINT '<<< DROPPED PROC dbo.PsCONTR_15 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCONTR_15
     (
       @p_ctr_nf              UCTR_NF,
	@p_ssd_cf		  USSD_CF
     )
as

/***************************************************

Programme: PsCONTR_15

Fichier script associé : ESSCTR15.PRC

Base principale : BTRT

Version: 1

Auteur: ME01

Date de creation: 26/09/1997

Description du programme:

      Sélection d'enregistrement dans TCONTR (sert au domaine ESTIMATION)

Parametres: 
       @p_ctr_nf              UCTR_NF,
	@p_ssd_cf		  USSD_CF

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
	  			

/* ---------- Rajout du numero de filiale devant le numero de contrat  ------ */


select @ssd_cf = right(convert(char(3),@p_ssd_cf+100),2)

/*
 select @ssd_cf = ltrim(convert(char(2),@p_ssd_cf))
 If datalength(@ssd_cf)=1 select @ssd_cf="0"+@ssd_cf
*/


 Select @ctr_nf = @ssd_cf + @p_ctr_nf


/* ------------------------- Select dans la table TCONTR ---------------------------- */

 Select ctrsts_ct,
		ctr_nf
	 

 from BFAC..TCONTR

 where ctr_nf = @ctr_nf
 

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
IF OBJECT_ID('dbo.PsCONTR_15') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCONTR_15 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCONTR_15 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCONTR_15
 */
GRANT EXECUTE ON dbo.PsCONTR_15 TO GOMEGA
go

