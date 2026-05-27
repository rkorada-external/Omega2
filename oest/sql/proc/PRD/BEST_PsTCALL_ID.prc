USE BEST
go

/** Drop procedure if already exists **/
IF OBJECT_ID('dbo.PsTCALL_ID') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTCALL_ID
    IF OBJECT_ID('dbo.PsTCALL_ID') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTCALL_ID >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTCALL_ID >>>'
END
go


/** creation de la procedure **/
CREATE PROCEDURE dbo.PsTCALL_ID
AS

/***************************************************

Programme: PsTCALL_ID

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: BONNERUE Gwendal

Date de creation: 13/08/2015

Description du programme:
Récupération des champs de la table TCALL pour l'ESDJ8040


Parametres:

Conditions d'execution: Execute a chaque intraday

Commentaires:

*****************************************************/


SELECT  TCALL.SSD_CF ,
        TCALL.ESB_CF ,
        TCALL.CTR_NF ,
        TCALL.UWY_NF ,
        TCALL.SEC_NF ,
        TCALL.ACY_NF ,
        TCALL.SCOENDMTH_NF ,
        TCALL.TREATED_B ,
        TCALL.CRE_D
FROM    BEST..TCALL TCALL,
        BREF..TBATCHSSD TBATCHSSD
WHERE   TREATED_B = 1
  AND   TCALL.SSD_CF = TBATCHSSD.SSD_CF
  AND   TBATCHSSD.BATCHUSER_CF = suser_name()
go

IF OBJECT_ID('dbo.PsTCALL_ID') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTCALL_ID >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTCALL_ID >>>'
go
GRANT EXECUTE ON dbo.PsTCALL_ID TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTCALL_ID TO GDBBATCH
go
