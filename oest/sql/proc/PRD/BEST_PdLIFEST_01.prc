USE BEST
go
IF OBJECT_ID('dbo.PdLIFEST_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFEST_01
  IF OBJECT_ID('dbo.PdLIFEST_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFEST_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFEST_01 >>>'
END
go
CREATE PROCEDURE dbo.PdLIFEST_01 (
  @p_balshtyea_nf smallint,
  @p_balshtmth_nf smallint = 0
)
WITH EXECUTE AS CALLER AS

/****************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert
Creation date     : 28/08/2019
Description       : Cleans up data in BEST..TLIFEST on a monthly basis regarding the balance sheet year, the accounting years and the creation date 
										+ positions after cancelled years
Called by: STAD7503.cmd
_________________
MODIFICATIONS
M       Author     Date       Description
[001]   B. LAGHA   02/03/2021  SPIRA:70816 - Delete all rows with BALSHEY_NF equal to @p_balshtyea_nf given as parameter.
[002]   B. LAGHA   06/12/2021  SPIRA:70816 - Change the max of block size (locks) to 100K.
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

IF @p_balshtmth_nf = 0 
BEGIN
  WHILE @enr > 0
  BEGIN
    BEGIN TRAN
    -- Delete by group of 100K rows each time
    DELETE TOP 100000 BEST..TLIFEST 
    FROM 
      BEST..TLIFEST tlif, BTRAV..TESTSSD tssd
    WHERE 
      tlif.BALSHEY_NF = @p_balshtyea_nf AND
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
END ELSE
BEGIN
  WHILE @enr > 0
  BEGIN
    BEGIN TRAN
    -- Delete by group of 100K rows each time
    DELETE TOP 100000 BEST..TLIFEST 
    FROM 
      BEST..TLIFEST tlif, BTRAV..TESTSSD tssd
    WHERE 
      tlif.BALSHEY_NF   = @p_balshtyea_nf AND
      tlif.BALSHTMTH_NF = @p_balshtmth_nf AND
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
END

PRINT '%1! row(s) deleted in BEST..TLIFEST', @totenr
return @err
go

EXEC sp_procxmode 'dbo.PdLIFEST_01', 'unchained'
go
IF OBJECT_ID('dbo.PdLIFEST_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PdLIFEST_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFEST_01 >>>'
go
GRANT EXECUTE ON dbo.PdLIFEST_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdLIFEST_01 TO GDBBATCH
go
