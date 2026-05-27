USE BREF
go

/** Drop procedure if already exists **/
IF OBJECT_ID('dbo.PsTESB_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTESB_01
    IF OBJECT_ID('dbo.PsTESB_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTESB_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTESB_01 >>>'
END
go


/** creation de la procedure **/
CREATE PROCEDURE dbo.PsTESB_01
AS

/***************************************************

Programme: dbo.PsTESB_01

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ESSE Nicolas

Date de creation: 04/08/2015

Description du programme:
Extraction complete de la table TESB


Parametres:

Conditions d'execution:

Commentaires:

*****************************************************/

SELECT  SSD_CF ,
        ESB_CF ,
        ESB_LS ,
        ESB_LL ,
        FACUW4PHA_B ,
        FACMODLOC_B ,
        ACCALC_B ,
        ACCPRMDIR_B ,
        LIFE_CF ,
        NIGHT_B ,
        CONFID_B ,
        THRHLDCUR_CF
FROM    BREF.dbo.TESB
go

IF OBJECT_ID('dbo.PsTESB_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTESB_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTESB_01 >>>'
go
GRANT EXECUTE ON dbo.PsTESB_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTESB_01 TO GDBBATCH
go
