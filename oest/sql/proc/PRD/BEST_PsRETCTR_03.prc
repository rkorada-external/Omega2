USE BEST
Go

IF OBJECT_ID('dbo.PsRETCTR_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETCTR_03
   PRINT '<<< DROPPED PROC dbo.PsRETCTR_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsRETCTR_03
     (
       @p_ctr_nf              UCTR_NF,
	@p_ssd_cf		  USSD_CF
 
     )
as

/***************************************************

Programme: PsRETCTR_03

Fichier script associé : ESSRET03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 20/10/1997

Description du programme: 

      Sélection d'enregistrement dans RETRO (sert à ESTIMATIONS)

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


 Select @ctr_nf = @ssd_cf + @p_ctr_nf


/* ------------------------- Select dans la table TCONTR ---------------------------- */



 Select RETCTR_NF,
	 RETCTRSTS_CT
	  
   	from BRET..TRETCTR
		 where RETCTR_NF = @ctr_nf
 

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TRETCTR" 
      return 1
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSRET03', 'PsRETCTR_03', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsRETCTR_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETCTR_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETCTR_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETCTR_03
 */
GRANT EXECUTE ON dbo.PsRETCTR_03 TO GOMEGA
go

