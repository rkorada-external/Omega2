USE BEST
go
IF OBJECT_ID('dbo.PsTRSLNK_05') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTRSLNK_05
    IF OBJECT_ID('dbo.PsTRSLNK_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTRSLNK_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTRSLNK_05 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure dbo.PsTRSLNK_05 

as

/***************************************************

Programme: PsTRSLNK_05

Fichier script associé : BEST_PsTRSLNK_05.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: MZM
Date de creation: 13/04/2018

Description du programme: 

      Sélection d'enregistrement dans TTRSLNK - Poste Comptable 720, pour Allocation NP EBS
      Pour l'allocation EBS, seules les postes comptables de clotures sont pris en compte.
      Duplication de la proc Ps_TRSLNK03 pour ne pas Gêner au niveau des autres Traitements
      Ajout du critère ((SUBSTRING(DETTRS_CF,2,1) = 'A' AND SUBSTRING(DETTRS_CF,8,1) ='2') OR (SUBSTRING(DETTRS_CF,2,1) = 'E'))  -- Prise en compte des postes de cloture comptables EBS 
       
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
and   (((SUBSTRING(DETTRS_CF,2,1) = 'A') AND (SUBSTRING(DETTRS_CF,8,1) ='2')) OR (SUBSTRING(DETTRS_CF,2,1) = 'E'))
order 	by DETTRS_CF asc
go
EXEC sp_procxmode 'dbo.PsTRSLNK_05', 'unchained'
go
IF OBJECT_ID('dbo.PsTRSLNK_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTRSLNK_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTRSLNK_05 >>>'
go
GRANT EXECUTE ON dbo.PsTRSLNK_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTRSLNK_05 TO GDBBATCH
go
