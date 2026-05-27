USE BEST
go
IF OBJECT_ID('dbo.PdLIFESTD_02') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFESTD_02
  IF OBJECT_ID('dbo.PdLIFESTD_02') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFESTD_02 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFESTD_02 >>>'
END
go
CREATE PROCEDURE dbo.PdLIFESTD_02 (
  @p_balshtyea_nf smallint,
  @p_balshtmth_nf smallint
)
WITH EXECUTE AS CALLER AS

/****************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : S.Behague
Creation date     : 16/02/2023
Description       : Cleans up data in BEST..TLIFESTD on a monthly basis regarding the balance sheet year, the accounting years and the creation date 
										+ positions after cancelled years
_________________
MODIFICATIONS
M       Author     Date       Description
[001]   S. Behague   16/02/2023  SPIRA:97424: Monthly historization - PURGE TLIFESTD / TLIFEST

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
    DELETE BEST..TLIFESTD 
    FROM 
      BEST..TLIFESTD tlifd, BTRAV..TESTSSD tssd
    WHERE 
      tlifd.BALSHEY_NF   = @p_balshtyea_nf AND
      tlifd.BALSHTMTH_NF <= @p_balshtmth_nf AND
      tlifd.BALSHTMTH_NF >= @p_balshtmth_nf - 2 AND
      tlifd.SSD_CF = tssd.SSD_CF 
	
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
PRINT '%1! row(s) deleted in BEST..TLIFESTD', @totenr
return @err
go

EXEC sp_procxmode 'dbo.PdLIFESTD_02', 'unchained'
go
IF OBJECT_ID('dbo.PdLIFESTD_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PdLIFESTD_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFESTD_02 >>>'
go
GRANT EXECUTE ON dbo.PdLIFESTD_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdLIFESTD_02 TO GDBBATCH
go
