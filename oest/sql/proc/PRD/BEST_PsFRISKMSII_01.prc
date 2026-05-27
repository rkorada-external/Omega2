USE BEST
go
IF OBJECT_ID('dbo.PsFRISKMSII_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsFRISKMSII_01
  IF OBJECT_ID('dbo.PsFRISKMSII_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFRISKMSII_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsFRISKMSII_01 >>>'
END
go
create procedure dbo.PsFRISKMSII_01
(
 @p_TYPEINV   char(3)
,@p_CLOSING_D datetime
)
as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : Florent
Date de creation         : 20/07/2015
Description du programme : :spot:28941
Conditions d'execution   : ESPD0061.cmd
Commentaires : segment 113 pour le Legal Entity et 114 pour le LOB SII
_________________
MODIFICATIONS
1 Florent 27/11/2015 :spot:29778 changements Legal Entity 1244 et pour LOB SII 1285 
*****************************************************/
select LGENSGTVRS_NT
 ,LGENSGMT_LS=(select SGMT_LS from BEST..TSEGMT b where a.LGENSGMT_NF=SGMT_NF and a.LGENSGTVRS_NT=SGTVER_NT and SGT_NT=1244)
 ,LOBSIISGMTVRS_NT
 ,LOBSIISGMT_LS=(select SGMT_LS from BEST..TSEGMT b where a.LOBSIISGMT_NF=SGMT_NF and a.LOBSIISGMTVRS_NT=SGTVER_NT and SGT_NT=1285)
 ,NORME_CF
 ,PER_CF
 ,CLOSING_D
 ,AMT_M
 ,CUR_CF
 ,CREUSR_CF
 ,CRE_D
 from BEST..TRSKMRGSSD a
  where PER_CF=@p_TYPEINV
    and CLOSING_D=@p_CLOSING_D
go
IF OBJECT_ID('dbo.PsFRISKMSII_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PsFRISKMSII_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFRISKMSII_01 >>>'
go
GRANT EXECUTE ON dbo.PsFRISKMSII_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFRISKMSII_01 TO GDBBATCH
go
