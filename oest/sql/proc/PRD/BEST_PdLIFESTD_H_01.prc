USE BEST
go
IF OBJECT_ID('dbo.PdLIFESTD_H_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFESTD_H_01
  IF OBJECT_ID('dbo.PdLIFESTD_H_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFESTD_H_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFESTD_H_01 >>>'
END
go
CREATE PROCEDURE dbo.PdLIFESTD_H_01
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
Creation date: 06/09/2019
Description: Cleans up data in BEST..TLIFESTD_H regarding the balance sheet year and SSDs in BREF..TBATCHSSD
Called by: STAD7503.cmd
_________________
MODIFICATIONS
M       Author     Date       Description
[001]   B.LAGHA    02/03/2021   SPIRA:70816
*****************************************************/
DECLARE
  @enr      int,
  @err      int,
  @totenr   int
  
SELECT
  @enr = 1,
  @err = 0,
  @totenr = 0
  
SET ROWCOUNT 500000

WHILE @enr > 0
BEGIN
  BEGIN TRAN
  DELETE
    BEST..TLIFESTD_H
  FROM
    BEST..TLIFESTD_H a, BTRAV..TESTSSD T
  WHERE a.BALSHEY_NF = @p_balshtyea_nf
    AND a.BALSHTMTH_NF = @p_balshtmth_nf
    AND a.SSD_CF = T.SSD_CF

  SELECT @enr = @@rowcount, 
         @err = @@error,
		 @totenr = @totenr + @@rowcount
	   
  IF @@transtate > 1 OR @err != 0
  BEGIN
    ROLLBACK TRAN
    BREAK
  END
  COMMIT TRAN
END

SET ROWCOUNT 0
PRINT '%1! row(s) deleted in BEST..TLIFESTD_H', @totenr
return @err
go

EXEC sp_procxmode 'dbo.PdLIFESTD_H_01', 'unchained'
go
IF OBJECT_ID('dbo.PdLIFESTD_H_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PdLIFESTD_H_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFESTD_H_01 >>>'
go
GRANT EXECUTE ON dbo.PdLIFESTD_H_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdLIFESTD_H_01 TO GDBBATCH
go
