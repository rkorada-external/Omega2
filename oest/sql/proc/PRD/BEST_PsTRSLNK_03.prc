USE BEST
go
IF OBJECT_ID('dbo.PsTRSLNK_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTRSLNK_03
    IF OBJECT_ID('dbo.PsTRSLNK_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTRSLNK_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTRSLNK_03 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure dbo.PsTRSLNK_03 

as

/***************************************************

Programme: PsTRSLNK_03

Fichier script associé : BEST_PsTRSLNK_03.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: MZM
Date de modification: 13/04/2018

Description du programme: 

      Sélection d'enregistrement dans TTRSLNK - Poste Comptable 720, pour Allocation NP IFRS
      Ajout du critère SUBSTRING(DETTRS_CF,2,1) NOT IN ('A', 'E', 'J')  /* EXCLUSION des postes EBS */
       
Parametres: 
Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 

Auteur: 
Date: 
Version:
Description: 

*****************************************************/


select PRS_CF, ACMTRS_NT,DETTRS_CF
from	BREF..TTRSLNK
where	PRS_CF = 720
and   SUBSTRING(DETTRS_CF,2,1) NOT IN ('A', 'E', 'J')
order 	by DETTRS_CF asc
go
EXEC sp_procxmode 'dbo.PsTRSLNK_03', 'unchained'
go
IF OBJECT_ID('dbo.PsTRSLNK_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTRSLNK_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTRSLNK_03 >>>'
go
GRANT EXECUTE ON dbo.PsTRSLNK_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTRSLNK_03 TO GDBBATCH
go
