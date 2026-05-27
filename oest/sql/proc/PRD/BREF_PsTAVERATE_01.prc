USE BREF
go

/** Drop procedure if already exists **/
IF OBJECT_ID('dbo.PsTAVERATE_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTAVERATE_01
    IF OBJECT_ID('dbo.PsTAVERATE_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTAVERATE_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTAVERATE_01 >>>'
END
go


/** creation de la procedure **/
CREATE PROCEDURE dbo.PsTAVERATE_01
(
  @p_date		        char(8)
)
AS

/***************************************************

Programme: PsTAVERATE_01

Fichier script associe :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ESSE Nicolas

Date de creation: 04/08/2015

Description du programme:
Chargement de la table TAVERATE


Parametres: date saisie - code langue - code filiale


Conditions d'execution:

Commentaires:

*****************************************************/


SELECT  SSD_CF
      , CUR_CF
      , Convert(char(8), EXC_D, 112)
      , EXC_R
FROM    BREF..TAVERATE
WHERE   EXC_D = ( SELECT MAX(EXC_D)
                  FROM   BREF..TAVERATE
                  WHERE  Convert(char(8), EXC_D, 112) <= @p_date)
ORDER BY SSD_CF
go

  IF OBJECT_ID('dbo.PsTAVERATE_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTAVERATE_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTAVERATE_01 >>>'
go
GRANT EXECUTE ON dbo.PsTAVERATE_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTAVERATE_01 TO GDBBATCH
go
