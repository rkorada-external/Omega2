USE BEST
go
IF OBJECT_ID('dbo.PsTRANSTCODE_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTRANSTCODE_02
    IF OBJECT_ID('dbo.PsTRANSTCODE_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTRANSTCODE_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTRANSTCODE_02 >>>'
END
go
/***** create procedure dbo.PsTRANSTCODE_02 *****/
/*
 * creation de la procedure 
*/
CREATE PROCEDURE dbo.PsTRANSTCODE_02
AS

/***************************************************

Programme: PsTRANSTCODE_02

Fichier script associé : 

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: Radhouane BEN EZZINE

Date de creation: 29/09/2015

Description du programme: 
Extraction de la table BRET..TRTRANSCODE

Parametres:

Conditions d'execution:


Commentaires:

*****************************************************/
 

 select TRANSTYP_CF,
          FAMTRAN_CF,
          CTRNAT_CT,
          ACCADMTYP_CT,
          substring(ORIDETTRS_CF,3,5) ORIDETTRNCOD_CF,
          substring(TRADETTRS_CF,3,5) TRADETTRNCOD_CF
 FROM BRET..TRTRANSTCODE
 group by TRANSTYP_CF, 
              FAMTRAN_CF, 
              CTRNAT_CT, 
              ACCADMTYP_CT,
              substring(ORIDETTRS_CF,3,5),
              substring(TRADETTRS_CF,3,5)
go
EXEC sp_procxmode 'dbo.PsTRANSTCODE_02', 'unchained'
go
IF OBJECT_ID('dbo.PsTRANSTCODE_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTRANSTCODE_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTRANSTCODE_02 >>>'
go
GRANT EXECUTE ON dbo.PsTRANSTCODE_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTRANSTCODE_02 TO GDBBATCH
go
