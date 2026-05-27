USE BEST
go
IF OBJECT_ID('dbo.PsLIFESTD_H_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsLIFESTD_H_01
  IF OBJECT_ID('dbo.PsLIFESTD_H_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFESTD_H_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsLIFESTD_H_01 >>>'
END
go
CREATE PROCEDURE dbo.PsLIFESTD_H_01
(
  @p_balshtyea_nf  smallint,
  @p_balshtmth_nf  smallint
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain: Estimation
Database: BEST
Version: 1
Author: L. Wernert
Creation date: 09/09/2019
Description: Extracting a TLIFESTD file in order to archive it in TLIFESTD_H (done on a monthly basis)
Called by: STAD7501.cmd
_________________
MODIFICATIONS
M       Author     Date         Description
[001]   B.LAGHA    01/03/2021   SPIRA-70816 : optimisation + recuperation des dernieres positions a la place des anciennes positions.
*****************************************************/

-- Getting all positions that are the latest for balshmth and balshyea from BEST..TLIFESTD
SELECT T.CTR_NF, T.END_NT, T.SEC_NF, T.UWY_NF, T.ACY_NF, T.ACM_NF, T.ACMTRS_NT, T.DETTRNCOD_CF, T.GAAP_NT, MAX(T.CRE_D) as MAXCRE_D INTO #LASTPOSLIFESTD
FROM BEST..TLIFESTD T,  BTRAV..TESTSSD T1
WHERE
  T.BALSHEY_NF = @p_balshtyea_nf AND
  T.BALSHTMTH_NF = @p_balshtmth_nf AND
  --T.ACY_NF    >= (@p_balshtyea_nf - 4) AND
  T.SSD_CF   = T1.SSD_CF 
GROUP BY T.CTR_NF, T.END_NT, T.SEC_NF, T.UWY_NF, T.ACY_NF, T.ACM_NF, T.ACMTRS_NT, T.DETTRNCOD_CF, T.GAAP_NT

SELECT
     T.CTR_NF
    ,T.END_NT
    ,T.SEC_NF
    ,T.UWY_NF
    ,T.UW_NT
    ,convert(varchar(26),T.CRE_D,109)
    ,T.BALSHEY_NF
    ,T.BALSHTMTH_NF
    ,T.ACY_NF
    ,T.GAAP_NT
    ,T.DETTRNCOD_CF
    ,T.ACM_NF
    ,T.PRS_CF
    ,T.ACMTRS_NT
    ,T.SSD_CF
    ,T.CUR_CF
    ,T.ESTMNT_M
    ,T.INDSUP_B
    ,T.ORICOD_LS
    ,T.CREUSR_CF
    ,convert(varchar(26),T.LSTUPD_D,109)
    ,T.LSTUPDUSR_CF
    ,T.ORICTR_NF
    ,T.ORISEC_NF
    ,T.ORIUWY_NF
    ,T.DIFF_M
    ,T.PROPAGATION_B
    ,T.CALCULATED_B
    ,T.BATCH_B
FROM BEST..TLIFESTD T, #LASTPOSLIFESTD T1
WHERE
  T.BALSHEY_NF = @p_balshtyea_nf AND
  T.BALSHTMTH_NF = @p_balshtmth_nf AND
  --T.ACY_NF >= (@p_balshtyea_nf - 4) AND
  T.CTR_NF = T1.CTR_NF AND 
  T.END_NT = T1.END_NT AND 
  T.SEC_NF = T1.SEC_NF AND 
  T.UWY_NF = T1.UWY_NF AND
  T.ACY_NF = T1.ACY_NF AND
  T.ACM_NF = T1.ACM_NF AND
  T.ACMTRS_NT = T1.ACMTRS_NT AND
  T.DETTRNCOD_CF = T1.DETTRNCOD_CF AND
  T.GAAP_NT = T1.GAAP_NT AND
  T.CRE_D  >= T1.MAXCRE_D

if object_id('#LASTPOSLIFESTD') is not null drop table #LASTPOSLIFESTD
return 0
go

EXEC sp_procxmode 'dbo.PsLIFESTD_H_01', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFESTD_H_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PsLIFESTD_H_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFESTD_H_01 >>>'
go
GRANT EXECUTE ON dbo.PsLIFESTD_H_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFESTD_H_01 TO GDBBATCH
go
