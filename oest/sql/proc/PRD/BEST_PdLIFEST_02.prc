USE BEST
go
IF OBJECT_ID('dbo.PdLIFEST_02') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFEST_02
  IF OBJECT_ID('dbo.PdLIFEST_02') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFEST_02 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFEST_02 >>>'
END
go
CREATE PROCEDURE dbo.PdLIFEST_02 (
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
Description       : Cleans up data in BEST..TLIFEST on a monthly basis regarding the balance sheet year, the accounting years and the creation date 
										+ positions after cancelled years
_________________
MODIFICATIONS
M       Author     Date       Description
[001]   S. Behague   16/02/2023  SPIRA:97424: Monthly historization - PURGE TLIFESTD / TLIFEST

*****************************************************/
DECLARE
  @enr        int,
  @err        int,
  @totenr     int,
  @trans_etat int

SELECT 
  @enr    = 1,
  @err    = 0,
  @totenr = 0

WHILE @enr > 0
BEGIN
    BEGIN TRAN
    -- Delete by group of 100K rows each time
    DELETE TOP 100000 BEST..TLIFEST 
    FROM 
      BEST..TLIFEST tlif, BTRAV..TESTSSD tssd
    WHERE 
      tlif.BALSHEY_NF   = @p_balshtyea_nf AND
      tlif.BALSHTMTH_NF <= @p_balshtmth_nf AND
      tlif.BALSHTMTH_NF >= @p_balshtmth_nf - 2 AND
      tlif.SSD_CF = tssd.SSD_CF 
	
    SELECT @err = @@error,
           @enr = @@rowcount,
		   @trans_etat = @@transtate,
           @totenr = @totenr + @@rowcount

    IF @trans_etat > 1 OR @err != 0
    BEGIN
      ROLLBACK TRAN
      BREAK
    END
    COMMIT TRAN
END


PRINT '%1! row(s) deleted in BEST..TLIFEST', @totenr
return @err
go

EXEC sp_procxmode 'dbo.PdLIFEST_02', 'unchained'
go
IF OBJECT_ID('dbo.PdLIFEST_02') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PdLIFEST_02 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFEST_02 >>>'
go
GRANT EXECUTE ON dbo.PdLIFEST_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdLIFEST_02 TO GDBBATCH
go
