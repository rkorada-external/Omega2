USE BEST
go
IF OBJECT_ID('dbo.PsTACCPAR_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTACCPAR_01
    IF OBJECT_ID('dbo.PsTACCPAR_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTACCPAR_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTACCPAR_01 >>>'
END
go
/*
 * creation de la procedure 
 */

create procedure dbo.PsTACCPAR_01
	
as

/***************************************************

Programme: PsTACCPAR_01
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
        CRE_D,	
        CREUSR_CF,	
        LSTUPD_D,	
        LSTUPDUSR_CF	
  FROM BREF..TACCPAR
 ORDER BY  PRS_CF,	
           ACMTRS_NT,	
           DETTRNCOD_CF
go
EXEC sp_procxmode 'dbo.PsTACCPAR_01', 'unchained'
go
IF OBJECT_ID('dbo.PsTACCPAR_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTACCPAR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTACCPAR_01 >>>'
go
GRANT EXECUTE ON dbo.PsTACCPAR_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTACCPAR_01 TO GDBBATCH
go
