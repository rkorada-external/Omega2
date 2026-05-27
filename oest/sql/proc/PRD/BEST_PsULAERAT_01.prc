USE BEST
go
IF OBJECT_ID('dbo.PsULAERAT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsULAERAT_01
    IF OBJECT_ID('dbo.PsULAERAT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsULAERAT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsULAERAT_01 >>>'
END
go
/* Adaptive Server has expanded all '*' elements in the following statement */ 
create procedure dbo.PsULAERAT_01
  (
@p_TYPEINV char(3)
,@p_CLOSING_D     datetime
  )
as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : Florent
Date de creation         : 20/07/2015
Description du programme : :spot:  extraction de la table TULAERAT
Conditions d'execution :
Commentaires :
_________________
MODIFICATIONS
20/03/2024 - DAD - spira:110913 - new column CTRNAT_CT, UWY_NF, LOBN2_NF added
*****************************************************/
declare
  @erreur    int

Select BEST..TULAERAT.SSD_CF, BEST..TULAERAT.ESB_CF, BEST..TULAERAT.PER_CF, BEST..TULAERAT.CLOSING_D, BEST..TULAERAT.RATIO_NF, BEST..TULAERAT.CREUSR_CF, BEST..TULAERAT.CRE_D, BEST..TULAERAT.CTRNAT_CT, BEST..TULAERAT.UWY_NF, BEST..TULAERAT.LOBN2_NF
from BEST.. TULAERAT where PER_CF=@p_TYPEINV AND convert(char,CLOSING_D,112)=convert(char ,@p_CLOSING_D,112)

go
EXEC sp_procxmode 'dbo.PsULAERAT_01', 'unchained'
go
IF OBJECT_ID('dbo.PsULAERAT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsULAERAT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsULAERAT_01 >>>'
go
GRANT EXECUTE ON dbo.PsULAERAT_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsULAERAT_01 TO GDBBATCH
go
