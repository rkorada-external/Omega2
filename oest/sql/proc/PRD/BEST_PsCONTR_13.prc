USE BEST
Go


IF OBJECT_ID('dbo.PsCONTR_13') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCONTR_13
    PRINT '<<< DROPPED PROC dbo.PsCONTR_13 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCONTR_13
     (
       @p_ctr_nf              UCTR_NF,
	@p_ssd_cf		  USSD_CF
     )
as

/***************************************************

Programme: PsCONTR_13

Fichier script associé : ESSCTR13.PRC

Base principale : BTRT

Version: 1

Auteur: ME01

Date de creation: 28/07/1997

Description du programme:

      Sélection d'enregistrement dans TCONTR / TRAITE (sert au domaine ESTIMATION)

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
	 

 from BTRT..TCONTR

 where ctr_nf = @ctr_nf
    and end_nt = 0			
    and uw_nt = 1	
		
 

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
IF OBJECT_ID('dbo.PsCONTR_13') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCONTR_13 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCONTR_13 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCONTR_13
 */
GRANT EXECUTE ON dbo.PsCONTR_13 TO GOMEGA
go

