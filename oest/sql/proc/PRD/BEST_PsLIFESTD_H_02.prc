USE BEST
go
IF OBJECT_ID('dbo.PsLIFESTD_H_02') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsLIFESTD_H_02
  IF OBJECT_ID('dbo.PsLIFESTD_H_02') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFESTD_H_02 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsLIFESTD_H_02 >>>'
END
go
CREATE PROCEDURE dbo.PsLIFESTD_H_02
(
  @p_balshtyea_nf  smallint,
  @p_balshtmth_nf  smallint
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain: Estimation
Database: BEST
Version: 1
Author: S.Behague
Creation date: 21/02/2023
Description: Extracting a TLIFESTD_H file with last position for BALSHEY_NF / BALSHTMTH_NF
Copying from PsLIFESTD_H_01 
Called by: STAD7504.cmd
_________________
MODIFICATIONS
M       Author     Date         Description
[001]   S.Behague  21/02/2023   spira:97424:Monthly historization - PURGE TLIFESTD / TLIFEST
*****************************************************/


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
FROM BEST..TLIFESTD_H T, BTRAV..TESTSSD tssd
WHERE
  T.BALSHEY_NF = @p_balshtyea_nf AND
  T.BALSHTMTH_NF <= @p_balshtmth_nf AND
  T.BALSHTMTH_NF >= @p_balshtmth_nf -2 AND
  T.SSD_CF = tssd.SSD_CF 

go

EXEC sp_procxmode 'dbo.PsLIFESTD_H_02', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFESTD_H_02') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PsLIFESTD_H_02 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFESTD_H_02 >>>'
go
GRANT EXECUTE ON dbo.PsLIFESTD_H_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFESTD_H_02 TO GDBBATCH
go
