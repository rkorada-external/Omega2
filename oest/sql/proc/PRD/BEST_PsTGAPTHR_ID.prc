USE BEST
go

/** Drop procedure if already exists **/
IF OBJECT_ID('dbo.PsTGAPTHR_ID') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTGAPTHR_ID
    IF OBJECT_ID('dbo.PsTGAPTHR_ID') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTGAPTHR_ID >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTGAPTHR_ID >>>'
END
go


/** creation de la procedure **/
CREATE PROCEDURE dbo.PsTGAPTHR_ID
AS

/***************************************************

Programme: PsTGAPTHR_ID

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: BONNERUE Gwendal

Date de creation: 13/08/2015

Description du programme:
Récupération des champs de la table TGAPTHR pour l'ESDJ8040


Parametres:

Conditions d'execution: Execute a chaque intraday

Commentaires:

*****************************************************/


SELECT  SSD_CF ,
        ESB_CF ,
        CUR_CF ,
        AMT_M ,
        AMT2_M ,
        CREUSR_CF ,
        CRE_D ,
        LSTUPDUSR_CF ,
        LSTUPD_D
FROM    BEST..TGAPTHR
go

IF OBJECT_ID('dbo.PsTGAPTHR_ID') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTGAPTHR_ID >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTGAPTHR_ID >>>'
go
GRANT EXECUTE ON dbo.PsTGAPTHR_ID TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTGAPTHR_ID TO GDBBATCH
go
