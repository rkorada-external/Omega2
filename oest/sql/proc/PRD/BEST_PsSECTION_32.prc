use BEST
go

/*
 * DROP PROC dbo.PsSECTION_32
 */
USE BEST
GO
IF OBJECT_ID('dbo.PsSECTION_32') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSECTION_32
    PRINT '<<< DROPPED PROC dbo.PsSECTION_32 >>>'
END
GO

/*
 * creation de la procedure 
*/

create procedure PsSECTION_32
     (
       @p_date_maxTRT      char(8) output,
       @p_date_maxFAC      char(8) output,
       @p_seg_d            char(8)
     )
as

/***************************************************

Programme: PsSECTION_32

Fichier script associé : ESSSEC32.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
  Descente de champs des bases traites en fichier au niveau CASEX
  pour construire le perimetre
 
Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @blcshtyeaTRT 	smallint
declare @blcshtyeaFAC 	smallint
declare @date_maxTRT	datetime
declare @date_maxFAC	datetime
declare @erreur 		int
declare @CLODAT0		char(8)
declare @SPCEND_D		datetime
declare @ACCOUNT_D		datetime
declare @CLODAT_D 		datetime
declare @CLOSING_B		bit
declare @BLCSHTYEA_NF 	smallint
declare @BLCSHTMTH_NF 	tinyint 

/********************************************************************************************** 
	recherche de la période bilan par rapport à la période exceptionnelle
***********************************************************************************************/
Execute @erreur = BREF..PsCALEND_02 
			@p_seg_d , 
			'E',
			@BLCSHTYEA_NF output,
        		@BLCSHTMTH_NF output,
			@SPCEND_D output,
			@ACCOUNT_D output,
			@CLOSING_B output


if @erreur != 0 
	begin
   		raiserror 20005 "APPLICATIF;TACCSUP/TCALEND" /* erreur de lecture */
        	return @erreur
	end

SELECT @blcshtyeaTRT = @BLCSHTYEA_NF
SELECT @blcshtyeaFAC = @BLCSHTYEA_NF


-- recuperation du dernier jour du mois courant

SELECT @date_maxTRT = convert(datetime, "19001231", 112)
SELECT @date_maxFAC = convert(datetime, "19001231", 112)

SELECT @date_maxTRT = dateadd(year, @blcshtyeaTRT - 1900, @date_maxTRT)
SELECT @date_maxFAC = dateadd(year, @blcshtyeaFAC - 1900, @date_maxFAC)


-- Conversion en char(8)

SELECT @p_date_maxTRT = convert(char(8), @date_maxTRT, 112)
SELECT @p_date_maxFAC = convert(char(8), @date_maxFAC, 112)

   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go
IF OBJECT_ID('dbo.PsSECTION_32') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSECTION_32 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_32 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_32
 */
GRANT EXECUTE ON dbo.PsSECTION_32 TO GOMEGA
go
