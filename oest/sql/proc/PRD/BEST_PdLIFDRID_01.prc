USE BEST
go
IF OBJECT_ID('dbo.PdLIFDRID_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFDRID_01
  IF OBJECT_ID('dbo.PdLIFDRID_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFDRID_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFDRID_01 >>>'
END
go
create procedure dbo.PdLIFDRID_01
(
  @p_balshtyea_nf  smallint
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domaine : Estimation
Database : BEST
Version: 1
Author: L .Wernert
Creation date: 28/08/2019
Description: Deletes all data in BEST..TLIFDRID with an underwriting year lesser than the balance sheet year minus 3 (ACY_NF < BALSHEY_NF - 3)
Called by: STAD7503.cmd
_________________
MODIFICATIONS
M       Author     Date       Description
[001]   B. LAGHA   02/03/2021  SPIRA:70816
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
    BEST..TLIFDRID
  FROM 
    BEST..TLIFDRID tlfd, 
    BTRAV..TESTSSD tssd
  WHERE 
    tlfd.BALSHEY_NF = @p_balshtyea_nf AND
    tlfd.SSD_CF = tssd.SSD_CF AND
    tlfd.ACY_NF < @p_balshtyea_nf - 3
	
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
print '%1! row(s) deleted in BEST..TLIFDRID', @totenr
return @err
go

EXEC sp_procxmode 'dbo.PdLIFDRID_01', 'unchained'
go
IF OBJECT_ID('dbo.PdLIFDRID_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PdLIFDRID_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFDRID_01 >>>'
go
GRANT EXECUTE ON dbo.PdLIFDRID_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdLIFDRID_01 TO GDBBATCH
go
