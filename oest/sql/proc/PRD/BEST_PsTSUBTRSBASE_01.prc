USE BEST
go
IF OBJECT_ID ('dbo.PsSUBTRSBASE_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSUBTRSBASE_01
    IF OBJECT_ID ('dbo.PsSUBTRSBASE_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSUBTRSBASE_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSUBTRSBASE_01 >>>'
END
go
/*
 * creation de la procedure 
 */

create procedure dbo.PsSUBTRSBASE_01
	
as

/***************************************************

Programme: PsSUBTRSBASE_01
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


SELECT  PRS_CF,	
            ACMTRS_NT,	
            DETTRNCOD_CF,	
            ADJSIG_B,
            CRE_D,	
            CREUSR_CF,	
            LSTUPD_D,	
            LSTUPDUSR_CF	
  FROM BREF..TSUBTRSBASE
 ORDER BY  PRS_CF,	
                 ACMTRS_NT,	
                 DETTRNCOD_CF
go

IF OBJECT_ID('dbo.PsSUBTRSBASE_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSUBTRSBASE_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSUBTRSBASE_01 >>>'
go
GRANT EXECUTE ON dbo.PsSUBTRSBASE_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSUBTRSBASE_01 TO GDBBATCH
go
