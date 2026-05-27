-----------------------------------------
-- dataChange 91860
-----------------------------------------
USE BEST
SET NOCOUNT OFF
GO

begin TRAN
declare @erreur int,  @nbRow int, @totalRow int
select  @erreur = 0 , @nbRow = 1, @totalRow = 0

SET rowcount 500000
WHILE @nbRow > 0 
BEGIN 
	DELETE best..taccexcpro where ACY_NF <= 2018
	SELECT @erreur = @@error , @nbRow = @@rowcount, @totalRow = @totalRow + @@rowcount
		
	IF @@transtate > 1 OR @erreur != 0 
	BEGIN
		SELECT @nbRow = -1
		BREAK
	END
	COMMIT TRAN
END

IF @@transtate > 1 OR @erreur != 0 
BEGIN
	PRINT '>>> PURGE BEST..TLIFEST_H - ERROR : %1!', @erreur
	ROLLBACK TRAN
END

PRINT '>>> total deleted row(s) : %1!', @totalRow

SET rowcount 0
GO