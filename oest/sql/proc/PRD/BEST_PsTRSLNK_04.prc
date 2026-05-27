USE BEST
go
IF OBJECT_ID('dbo.PsTRSLNK_04') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTRSLNK_04
    IF OBJECT_ID('dbo.PsTRSLNK_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTRSLNK_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTRSLNK_04 >>>'
END
go
/*
 * creation de la procedure
 */

create procedure dbo.PsTRSLNK_04

as

/***************************************************

Programme: PsTRSLNK_04

Fichier script associé : BEST_PsTRSLNK_04.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: R. BEN EZZINE

Date de creation: 22/09/2015

Description du programme: 

      Sélection d'enregistrement dans TTRSLNK (Bases de calculs)

Parametres: 
       

Conditions d'execution: 


Commentaires:


*****************************************************/


select PRS_CF, 
       ACMTRS_NT,
       substring(DETTRS_CF,3,5) DETTRNCOD_CF
  from BREF..TTRSLNK
 where PRS_CF = 50
     and ACMTRS_NT < 100
 group by PRS_CF, ACMTRS_NT, substring(DETTRS_CF,3,5) 
 order by DETTRNCOD_CF asc
go

EXEC sp_procxmode 'dbo.PsTRSLNK_04', 'unchained'
go
IF OBJECT_ID('dbo.PsTRSLNK_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTRSLNK_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTRSLNK_04 >>>'
go
GRANT EXECUTE ON dbo.PsTRSLNK_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTRSLNK_04 TO GDBBATCH
go
