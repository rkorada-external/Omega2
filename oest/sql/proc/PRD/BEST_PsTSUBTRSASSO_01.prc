USE BEST
go
IF OBJECT_ID ('dbo.PsSUBTRSASSO_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSUBTRSASSO_01
    IF OBJECT_ID ('dbo.PsSUBTRSASSO_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSUBTRSASSO_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSUBTRSASSO_01 >>>'
END
go
/*
 * creation de la procedure 
 */

create procedure dbo.PsSUBTRSASSO_01
	
as

/***************************************************

Programme: PsSUBTRSASSO_01
Fichier script associé : 
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: R. BEN EZZINE
Date de creation: 07/01/2014
Description du programme: 
 
      

Parametres: aucun
Conditions d'execution: 
Commentaires: servira en estimation pour la fonction 
_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
*****************************************************/


SELECT  ASSOTYP_CT,	
        CTX_NT,	
        CTX_LL,	
        DETTRNCOD1_CF,	
        DETTRNCOD2_CF,	
        DETTRNCOD3_CF,	
        GUI_B,	
        ACMTRS_NT,	
        CRE_D,	
        CREUSR_CF,	
        LSTUPD_D,	
        LSTUPDUSR_CF	
  FROM BREF..TSUBTRSASSO
 ORDER BY  ASSOTYP_CT,	
           CTX_NT
go

IF OBJECT_ID('dbo.PsSUBTRSASSO_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSUBTRSASSO_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSUBTRSASSO_01 >>>'
go
GRANT EXECUTE ON dbo.PsSUBTRSASSO_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSUBTRSASSO_01 TO GDBBATCH
go
