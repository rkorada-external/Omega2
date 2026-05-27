USE BEST
go
IF OBJECT_ID ('dbo.PsCALEND_07') IS NOT NULL
 BEGIN
  DROP PROCEDURE dbo.PsCALEND_07
	IF OBJECT_ID('dbo.PsCALEND_07') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCALEND_07 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsCALEND_07 >>>'
 END
go
CREATE PROCEDURE PsCALEND_07
(
	@p_SSD_CF   USSD_CF,
	@p_ESB_CF   UESB_CF,
	@p_DIR_CF   UDIR_CF,
	@p_DMN_CF   tinyint,
	@p_typper	char(1)
)
WITH EXECUTE AS CALLER AS
/***************************************************
Programme: PsCALEND_07
Fichier script associé : ESSCAL05.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)
Date de creation: 18 Novembre 1997
Description du programme: Sélection d'enregistrement dans TCALEND (BREF) et dans TBLSHTD (BCTA)

Parametres:
@p_SSD_CF   USSD_CF,
@p_ESB_CF   UESB_CF,
@p_DIR_CF   UDIR_CF,
@p_DMN_CF   tinyint,
@p_typper  char(1)   type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable) 

Conditions d'execution: 

Commentaires:

_________________
MODIFICATION 1
Author: Dimitry BERTÉ
Date: 2019/05/02
Description : Spira 77630 - compte complet : Pas de cochage de la grille ni de présence des lignes dans l'historique après le compte complet
_________________
MODIFICATION 2
Author: L. Wernert
Date: 18/09/2019
Description : Spira 81218 - Complete Account: impossible to perform a complete account

*****************************************************/

declare 
	@erreur 			int,
	@ligne 					int,
	@BLCSHTYEA_NF 			smallint,		
	@BLCSHTMTH_NF 			tinyint,	
	@BLCSHTYEAN_NF 		smallint,     /* Période normale - année  */		
	@BLCSHTMTHN_NF 		tinyint,	/* Période normale - mois */
	@DATE						datetime,   	/* date de recherche */
	@SPCEND_D     			datetime,
	@ACCOUNT_D				datetime,  	/* date de comptabilisation ( fin service )  */
	@CLOSING_B				bit,           /* top inventaire groupe */
	@PER_EXCEPT_B			bit,
	@END_D					datetime


/**********************************************************************************************/
/* Select dans BREF..TCALEND                                                                  */ 
/* Recherche de la période 'année' et 'mois' en cours  ( execptionnelle à la date du jour )   */ 
/**********************************************************************************************/

SELECT @DATE = getdate() 

execute @erreur = BREF..PsCALEND_02 @DATE, @p_typper,@BLCSHTYEA_NF output, @BLCSHTMTH_NF output, @SPCEND_D output, @ACCOUNT_D output, @CLOSING_B output

IF @erreur != 0 
	BEGIN
		RAISERROR 20005 "APPLICATIF;TCALEND" /* erreur de lecture */
		RETURN @erreur
	END


/**********************************************************************************************/
/* Select dans BCTA..TBLCSHTD                                                                  */ 
/* Recherche du mois/année de bilan la plus ancienne comprise entre la date de début et la   */ 
/* date de fin de période normale                                                             */
/**********************************************************************************************/

SELECT 
	@BLCSHTYEAN_NF = min(BLCSHTYEA_NF)       
FROM 
	BCTA..TBLCSHTD
WHERE 
	SSD_CF = @p_SSD_CF AND 
	ESB_CF = @p_ESB_CF AND 
	DIR_CF = @p_DIR_CF AND 
	DMN_CF = @p_DMN_CF AND 
	convert(Char(10), STR_D,112) <= convert(Char(10), getdate(),112) AND 
	convert(Char(10), END_D,112) >= convert(Char(10), getdate(),112) 

SELECT @erreur = @@error
IF @erreur != 0
BEGIN
  RAISERROR 20003 "APPLICATIF;TBLCSHTD" 
  RETURN 1
END
	

SELECT 
	@BLCSHTMTHN_NF = min(BLCSHTMTH_NF)
FROM 
	BCTA..TBLCSHTD
WHERE 
	SSD_CF = @p_SSD_CF AND 
	ESB_CF = @p_ESB_CF AND 
	DIR_CF = @p_DIR_CF AND 
	DMN_CF = @p_DMN_CF AND 
	convert(Char(10), STR_D,112) <= convert(Char(10), getdate(),112) AND 
	convert(Char(10), END_D,112) >= convert(Char(10), getdate(),112) AND 
	BLCSHTYEA_NF = @BLCSHTYEAN_NF

SELECT @erreur = @@error
IF @erreur != 0
BEGIN
  RAISERROR 20003 "APPLICATIF;TBLCSHTD" 
  RETURN 1
END


SELECT 
	@END_D = END_D        
FROM 
	BCTA..TBLCSHTD
WHERE 
	SSD_CF = @p_SSD_CF AND 
	ESB_CF = @p_ESB_CF AND 
	DIR_CF = @p_DIR_CF AND 
	DMN_CF = @p_DMN_CF AND 
	BLCSHTYEA_NF = @BLCSHTYEA_NF AND 
	BLCSHTMTH_NF = @BLCSHTMTH_NF


/********************************************************************************************/
/*  Si date du jour <= Date de fin de période normale	                              */                                                             
/*  				@bilan = 1 (normal) , sinon @bilan = 2  (exceptionnel)              */
/********************************************************************************************/
IF convert(char(10), getdate(), 112) <= convert(char(10), @END_D, 112)
BEGIN
	SELECT @PER_EXCEPT_B = 0
END
ELSE
BEGIN	
	SELECT @PER_EXCEPT_B = 1
END


/********************************************************************************************/
/* Select final                                                                             */
/********************************************************************************************/

SELECT 
	@BLCSHTYEA_NF BLCSHTYEA_NF,
	@BLCSHTMTH_NF BLCSHTMTH_NF,
	@SPCEND_D SPCEND_D,
	@ACCOUNT_D ACCOUNT_D,
	@BLCSHTYEAN_NF BLCSHTYEAN_NF,
	@BLCSHTMTHN_NF BLCSHTMTHN_NF,
	@PER_EXCEPT_B PER_EXCEPT_B
	
return 0
go

EXEC sp_procxmode 'dbo.PdLIFPEN_01', 'unchained'
go
IF OBJECT_ID('dbo.PsCALEND_07') IS NOT NULL
	PRINT '<<< CREATED PROC dbo.PsCALEND_07 >>>'
ELSE
	PRINT '<<< FAILED CREATING PROC dbo.PsCALEND_07 >>>'
go
GRANT EXECUTE ON dbo.PsCALEND_07 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCALEND_07 TO GDBBATCH
go

