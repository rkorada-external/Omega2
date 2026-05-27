USE BEST
go
IF OBJECT_ID('dbo.PdLIFPEN_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFPEN_01
  IF OBJECT_ID('dbo.PdLIFPEN_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFPEN_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFPEN_01 >>>'
END
go
CREATE PROCEDURE dbo.PdLIFPEN_01
WITH EXECUTE AS CALLER AS
/***************************************************
Domain: Estimation
Database: BEST
Version: 1
Author: L. Wernert
Creation date: 28/08/2019
Description: Deletes all data except the most recent ones by contract, section, balance sheet year
Called by: STAD7503.cmd
_________________
MODIFICATIONS
M  Author          Date       Description
*****************************************************/
declare
  @erreur int
 ,@tran_imbr bit

select @erreur = 0, @tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

SELECT 
  USR_CF, CTR_NF, SEC_NF, 
  CRE_D, BALSHEY_NF, BALSHTMTH_NF, 
  PENSTS_CT, UWGRP_CF, CREUSR_CF, 
  LSTUPD_D, LSTUPDUSR_CF INTO #tlifpen_tmp
FROM 
  BEST..TLIFPEN tlfpn
GROUP BY 
  CTR_NF, SEC_NF, BALSHEY_NF
HAVING (LSTUPD_D) < MAX(LSTUPD_D)


DELETE FROM 
  BEST..TLIFPEN
FROM 
  #tlifpen_tmp tlfp_tmp,
  BEST..TLIFPEN tlfpn
WHERE
  tlfp_tmp.USR_CF = tlfpn.USR_CF AND
  tlfp_tmp.CTR_NF = tlfpn.CTR_NF AND
  tlfp_tmp.SEC_NF = tlfpn.SEC_NF AND
  tlfp_tmp.CRE_D = tlfpn.CRE_D AND
  tlfp_tmp.BALSHEY_NF = tlfpn.BALSHEY_NF AND
  tlfp_tmp.BALSHTMTH_NF = tlfpn.BALSHTMTH_NF AND
  tlfp_tmp.PENSTS_CT = tlfpn.PENSTS_CT AND
  tlfp_tmp.UWGRP_CF = tlfpn.UWGRP_CF AND
  tlfp_tmp.CREUSR_CF = tlfpn.CREUSR_CF AND
  tlfp_tmp.LSTUPD_D = tlfpn.LSTUPD_D AND
  tlfp_tmp.LSTUPDUSR_CF = tlfpn.LSTUPDUSR_CF

print '%1! row(s) deleted in BEST..TLIFPEN', @@rowcount

select @erreur=@@error
if @erreur!=0
begin
  goto fin
end

DROP TABLE #tlifpen_tmp

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go

EXEC sp_procxmode 'dbo.PdLIFPEN_01', 'unchained'
go
IF OBJECT_ID('dbo.PdLIFPEN_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PdLIFPEN_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFPEN_01 >>>'
go
GRANT EXECUTE ON dbo.PdLIFPEN_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdLIFPEN_01 TO GDBBATCH
go
