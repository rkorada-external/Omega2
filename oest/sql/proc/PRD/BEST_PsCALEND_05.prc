/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsCALEND_05
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsCALEND_05') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCALEND_05
   PRINT '<<< DROPPED PROC dbo.PsCALEND_05 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCALEND_05
     (
	@p_SSD_CF   USSD_CF,
	@p_ESB_CF   UESB_CF,
	@p_DIR_CF   UDIR_CF,
	@p_DMN_CF   tinyint,
	@p_typper	char(1)
     )
as

/***************************************************

Programme: PsCALEND_05

Fichier script associé : ESSCAL05.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 18 Novembre 1997

Description du programme: 

      Sélection d'enregistrement dans TCALEND (BREF) et dans TBLSHTD (BCTA)

Parametres: 

	@p_SSD_CF   USSD_CF,
	@p_ESB_CF   UESB_CF,
	@p_DIR_CF   UDIR_CF,
	@p_DMN_CF   tinyint,
 	@p_typper  char(1)  /* type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)    */ 
	

Conditions d'execution: 


Commentaires:


*****************************************************/

declare @erreur int,
	 @ligne int,


	@BLCSHTYEA_NF smallint,		
      @BLCSHTMTH_NF tinyint,	
	@BLCSHTYEAN_NF smallint,     /* Période normale - année  */		
      @BLCSHTMTHN_NF tinyint,	/* Période normale - mois */
 	@DATE		datetime,   	/* date de recherche */
      @SPCEND_D     datetime,
 	@ACCOUNT_D	datetime,  	/* date de comptabilisation ( fin service )  */
 	@CLOSING_B	bit           /* top inventaire groupe */


/**********************************************************************************************/
/* Select dans BREF..TCALEND                                                                  */ 
/* Recherche de la période 'année' et 'mois' en cours  ( execptionnelle à la date du jour )   */ 
/**********************************************************************************************/

select @DATE = getdate() 

Execute @erreur = BREF..PsCALEND_02 
			@DATE ,          
			@p_typper,
			@BLCSHTYEA_NF output,
        		@BLCSHTMTH_NF output,
			@SPCEND_D output,
			@ACCOUNT_D output,
			@CLOSING_B output


if @erreur != 0 
	begin
   		raiserror 20005 "APPLICATIF;TCALEND" /* erreur de lecture */
        	return @erreur
	end


/**********************************************************************************************/
/* Select dans BCTA..TBLCSHTD                                                                  */ 
/* Recherche du mois/année de bilan la plus ancienne comprise entre la date de début et la   */ 
/* date de fin de période normale                                                             */
/**********************************************************************************************/

Select @BLCSHTYEAN_NF = min(BLCSHTYEA_NF)
        
   	from BCTA..TBLCSHTD
		  where SSD_CF = @p_SSD_CF
			 and ESB_CF = @p_ESB_CF
			 and DIR_CF = @p_DIR_CF
			 and DMN_CF = @p_DMN_CF
			 and convert(Char(10), STR_D,112) <= convert(Char(10), getdate(),112) 
			 and convert(Char(10), END_D,112) >= convert(Char(10), getdate(),112) 

  select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TBLCSHTD" 
      return 1
   end
	

Select @BLCSHTMTHN_NF = min(BLCSHTMTH_NF)
        
   	from BCTA..TBLCSHTD
		  where SSD_CF = @p_SSD_CF
			 and ESB_CF = @p_ESB_CF
			 and DIR_CF = @p_DIR_CF
			 and DMN_CF = @p_DMN_CF
			 and convert(Char(10), STR_D,112) <= convert(Char(10), getdate(),112) 
			 and convert(Char(10), END_D,112) >= convert(Char(10), getdate(),112) 
			 and BLCSHTYEA_NF = @BLCSHTYEAN_NF

  select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TBLCSHTD" 
      return 1
   end


/********************************************************************************************/
/* Select final                                                                             */
/********************************************************************************************/

 Select 
	  @BLCSHTYEA_NF BLCSHTYEA_NF,
   	  @BLCSHTMTH_NF BLCSHTMTH_NF,
 	  @SPCEND_D SPCEND_D,
 	  @ACCOUNT_D ACCOUNT_D,
	  @BLCSHTYEAN_NF BLCSHTYEAN_NF,
   	  @BLCSHTMTHN_NF BLCSHTMTHN_NF
	
		
        

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCAL05', 'PsCALEND_05', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsCALEND_05') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCALEND_05 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCALEND_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCALEND_05
 */
GRANT EXECUTE ON dbo.PsCALEND_05 TO GOMEGA
go

