USE BEST
go
IF OBJECT_ID('dbo.PsLIFDRI_05') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFDRI_05
    IF OBJECT_ID('dbo.PsLIFDRI_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFDRI_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFDRI_05 >>>'
END

go

CREATE TABLE #TLIFDRI(
SEC_NF       USEC_NF    NOT NULL,
ACY_NF       smallint   NOT NULL,
AUTUPD_B     bit        DEFAULT 0         NOT NULL,
CRE_D        UUPD_D     DEFAULT getdate() NOT NULL
)

go
create procedure dbo.PsLIFDRI_05
(
@p_CTR_NF    			UCTR_NF,
@p_SEC_NF	  			USEC_NF
)
as

/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : AdbulWaajed SHAIKH
Creation date     : 07/05/2015
Description		  : Returns the number of occurrences of accounting years which are not set in auto-update.
					If section was filled, this is done at the contract-section level. If not, this is at contract level (all sections).
*****************************************************/

declare
		@p_Bool UBOOLEAN_B


IF (@p_SEC_NF != NULL)
	BEGIN
		INSERT INTO #TLIFDRI
		SELECT a.SEC_NF, a.ACY_NF, a.AUTUPD_B, a.CRE_D 
		FROM BEST..TLIFDRI a 
		WHERE  a.CTR_NF = @p_CTR_NF 
		AND a.SEC_NF = @p_SEC_NF
		AND a.BALSHEY_NF = ( SELECT MAX (b.BALSHEY_NF) 
							 FROM BEST..TLIFDRI b 
							 WHERE b.CTR_NF = @p_CTR_NF 
							 AND a.SEC_NF = @p_SEC_NF )
	END
ELSE 
	BEGIN
		INSERT INTO #TLIFDRI
		SELECT a.SEC_NF, a.ACY_NF, a.AUTUPD_B, a.CRE_D 
		FROM BEST..TLIFDRI a 
		WHERE  a.CTR_NF = @p_CTR_NF 
		AND a.BALSHEY_NF = ( SELECT MAX (b.BALSHEY_NF) 
							 FROM BEST..TLIFDRI b 
							 WHERE b.CTR_NF = @p_CTR_NF )
	END

IF (@@sqlstatus = 1)
	BEGIN
    PRINT "ERROR in INSERT INTO #TLIFDRI Procedure PsLIFDRI_05"
    GOTO fin
END

SELECT @p_BOOL = COUNT(1) 
FROM #TLIFDRI a 
WHERE a.AUTUPD_B = 0 
AND a.CRE_D = (SELECT MAX(b.CRE_D) 
			   FROM #TLIFDRI b 
			   WHERE b.ACY_NF = a.ACY_NF 
			   AND b.SEC_NF = a.SEC_NF)
			   
IF (@@sqlstatus = 1)
	BEGIN
    PRINT "ERROR in SELECT FROM #TLIFDRI Procedure PsLIFDRI_05"
    GOTO fin 
END

SELECT @p_BOOL


RETURN 0
fin:
RETURN 1

go
EXEC sp_procxmode 'dbo.PsLIFDRI_05', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFDRI_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFDRI_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFDRI_05 >>>'
go
GRANT EXECUTE ON dbo.PsLIFDRI_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFDRI_05 TO GDBBATCH
go
