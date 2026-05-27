USE BEST
GO

IF OBJECT_ID('PdTLIFEST_H_B_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PdTLIFEST_H_B_O2
  IF OBJECT_ID('PdTLIFEST_H_B_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE PdTLIFEST_H_B_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE PdTLIFEST_H_B_O2 >>>'
END
go
create procedure PdTLIFEST_H_B_O2(
  @p_balshey int,
  @p_max2delete int = 5000000,
  @p_remaining int = null output
)
WITH EXECUTE AS CALLER AS
/******************************************************************************
Domain       : Estimation
Database     : BEST
Version      : 1.0
Author       : B. LAGHA
Creation date: 04/06/2021
Description  : Delete BALSHEY_NF=@p_balshey from BEST..TLIFEST_H
Called by    : *
_________________
MODIFICATIONS
MODIF   Author     Date         Description
[001]   
*******************************************************************************/

DECLARE 
  @ERR int,
  @ENR int,
  @TOTAL_DELETED_LINE int,
  @MAX_AUTHORIZED int,
  @MAX_TO_DELETE int
  
SELECT
  @ERR = 0,
  @ENR = 1,
  @TOTAL_DELETED_LINE = 0,
  @MAX_AUTHORIZED = 20000000, -- set the max to 20M 
  @MAX_TO_DELETE = @p_max2delete 
  
IF @MAX_TO_DELETE > @MAX_AUTHORIZED
	SELECT @MAX_TO_DELETE = @MAX_AUTHORIZED

IF @MAX_TO_DELETE < 500000 BEGIN
	PRINT '<<< FAILED : PARAM 2 -> THIS PROCEDURE DELETE BY BLOCK OF 0.5M RECORDS >>>'
	RETURN 0
END

WHILE @ENR > 0 AND @TOTAL_DELETED_LINE < @MAX_TO_DELETE
BEGIN
  BEGIN TRAN
  DELETE TOP 500000 FROM BEST..TLIFEST_H
  WHERE BALSHEY_NF = @p_balshey
  
  SELECT 
    @ERR = @@error,
    @ENR = @@rowcount,
    @TOTAL_DELETED_LINE = @TOTAL_DELETED_LINE + @@rowcount
  -- STOP IF ERROR
  IF @ERR != 0 BEGIN
    ROLLBACK TRAN
    PRINT '<<< FAILED DELETING %1! FROM BEST..TLIFEST_H >>>', @p_balshey
    BREAK
  END
  
  COMMIT TRAN
END


SELECT @p_remaining = COUNT(*) FROM BEST..TLIFEST_H WHERE BALSHEY_NF = @p_balshey

PRINT '<<< %1! ROW(S) DELETED FROM "BEST..TLIFEST_H" >>>', @TOTAL_DELETED_LINE
IF @p_remaining = 0 
  PRINT '<<< SUCCESSFUL : EMPTY TABLE >>>'
ELSE
  PRINT '<<< %1! ROW(S) REMAINING ON TLIFEST_H FOR BALSHEY %2! >>>', @p_remaining, @p_balshey
  

RETURN 0
GO
EXEC sp_procxmode 'PdTLIFEST_H_B_O2', 'unchained'
go
IF OBJECT_ID('PdTLIFEST_H_B_O2') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE PdTLIFEST_H_B_O2 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE PdTLIFEST_H_B_O2 >>>'
GO
GRANT EXECUTE ON PdTLIFEST_H_B_O2 TO GOMEGA
GO
GRANT EXECUTE ON PdTLIFEST_H_B_O2 TO GDBBATCH
GO
