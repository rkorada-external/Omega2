USE BEST
go
IF OBJECT_ID('dbo.PdLIFESTD_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFESTD_01
  IF OBJECT_ID('dbo.PdLIFESTD_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFESTD_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFESTD_01 >>>'
END
go
CREATE PROCEDURE dbo.PdLIFESTD_01 (
  @p_balshtyea_nf smallint,
  @p_balshtmth_nf smallint = 0
)
WITH EXECUTE AS CALLER AS

/****************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert
Creation date     : 04/09/2019
Description       : Cleans up data in BEST..TLIFESTD on a monthly basis regarding the balance sheet year, the accounting years and the creation date
										+ positions after cancelled years
Called by: STAD7503.cmd
_________________
MODIFICATIONS
M       Author     Date       Description
[001]   B. LAGHA   02/03/2021  SPIRA:70816 - Delete all rows with BALSHEY_NF equal to @p_balshtyea_nf given as parameter.
*****************************************************/
DECLARE
  @enr      int,
  @err      int,
  @totenr   int

SELECT @enr = 1,
	   @err = 0,
       @totenr = 0

SET ROWCOUNT 500000

IF @p_balshtmth_nf = 0 
BEGIN
  WHILE @enr > 0
  BEGIN
    BEGIN TRAN
    DELETE BEST..TLIFESTD 
    FROM 
      BEST..TLIFESTD tlifd, BTRAV..TESTSSD tssd
    WHERE 
      tlifd.BALSHEY_NF = @p_balshtyea_nf AND
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
END ELSE
BEGIN
  WHILE @enr > 0
  BEGIN
    BEGIN TRAN
    DELETE BEST..TLIFESTD 
    FROM 
      BEST..TLIFESTD tlifd, BTRAV..TESTSSD tssd
    WHERE 
      tlifd.BALSHEY_NF   = @p_balshtyea_nf AND
      tlifd.BALSHTMTH_NF = @p_balshtmth_nf AND
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
END

SET ROWCOUNT 0
PRINT '%1! row(s) deleted in BEST..TLIFESTD', @totenr
return @err
go

EXEC sp_procxmode 'dbo.PdLIFESTD_01', 'unchained'
go
IF OBJECT_ID('dbo.PdLIFESTD_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PdLIFESTD_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFESTD_01 >>>'
go
GRANT EXECUTE ON dbo.PdLIFESTD_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdLIFESTD_01 TO GDBBATCH
go
