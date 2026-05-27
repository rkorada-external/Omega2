USE BEST
go
IF OBJECT_ID('dbo.PdLIFMOD_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFMOD_01
  IF OBJECT_ID('dbo.PdLIFMOD_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFMOD_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFMOD_01 >>>'
END
go
CREATE PROCEDURE dbo.PdLIFMOD_01
(
  @p_balshtyea_nf  smallint
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain: Estimation
Database: BEST
Version: 1
Author: L. Wernert
Creation date: 28/08/2019
Description: Deletes all data in BEST..TLIFMOD with a balance sheet year lesser than @p_balshtyea_nf minus 10 (BALSHEY_NF < @p_balshtyea_nf - 10)
Called by: STAD7503.cmd
_________________
MODIFICATIONS
M       Author     Date        Description
[001]   B. LAGHA   03/03/2021  SPIRA:70816 
*****************************************************/
DECLARE
  @enr      int,
  @err      int,
  @totenr   int

SELECT @enr = 1,
	   @err = 0,
       @totenr = 0

SET ROWCOUNT 500000

WHILE @enr > 0
BEGIN
  BEGIN TRAN 
  DELETE 
    BEST..TLIFMOD
  FROM 
    BEST..TLIFMOD tlfmod,
	BTRAV..TESTSSD tssd
  WHERE
    tlfmod.BALSHEY_NF < @p_balshtyea_nf - 10 AND
	tlfmod.SSD_CF = tssd.SSD_CF

  SELECT @err = @@error,
         @enr = @@rowcount,
		 @totenr = @totenr + @@rowcount
		 
  IF @@transtate > 1 OR @err != 0
  BEGIN
    ROLLBACK TRAN
    BREAK
  END
  COMMIT TRAN
END

SET ROWCOUNT 0
print '%1! row(s) deleted in BEST..TLIFMOD', @totenr
return @err
go

EXEC sp_procxmode 'dbo.PdLIFMOD_01', 'unchained'
go
IF OBJECT_ID('dbo.PdLIFMOD_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PdLIFMOD_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFMOD_01 >>>'
go
GRANT EXECUTE ON dbo.PdLIFMOD_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdLIFMOD_01 TO GDBBATCH
go
