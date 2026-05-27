------------------------------------------------------------------------------
-- SPIRA : 95903
------------------------------------------------------------------------------
USE BEST
GO

SET nocount ON
DECLARE @msg VARCHAR(60)
SELECT @msg = @@servername + ' => ' + HOST_NAME() + '  Debut  '
+ CONVERT(CHAR(9), GETDATE(),6) + ' ' + CONVERT(CHAR(8), GETDATE(),8)
+ SUBSTRING(CONVERT(CHAR(27), GETDATE(), 109), 21, 4)
print @msg
--SET nocount OFF
GO

------------------------------------------------------------------------------
-- PURGE TLIFDRI
------------------------------------------------------------------------------
DECLARE	@erreur			int,
		@trans_etat		int,
		@enr			int,
		@totenr			int

SELECT	@enr    = 0,
		@totenr = 0,
		@erreur = 0
				
SELECT @totenr = count(*) FROM BEST..TLIFDRI
PRINT '%1! ROWS FROM TLIFDRI BEFORE CLEAN-UP', @totenr

PRINT 'CREATE #TLIFDRI ...'
CREATE TABLE #TLIFDRI (
  CTR_NF UCTR_NF not null,
  END_NT UEND_NT not null,
  SEC_NF USEC_NF not null,
  UWY_NF UUWY_NF not null,
  BALSHEY_NF smallint not null,
  BALSHTMTH_NF tinyint not null,
  ACY_NF smallint not null,
  LSTUPD_D UUPD_D default getdate()  not null
)

-- récuperer code retour --
---------------------------
SELECT	@erreur = @@error
IF @erreur != 0 
BEGIN
	PRINT 'CREATE #TLIFDRI - ERROR : %1!', @erreur
	GOTO fin1
END
ELSE
	PRINT '#TLIFDRI IS CREATED.'

-- Recuperate the latest update date of each line from TLIFDRI --
-----------------------------------------------------------------
SELECT @erreur = 0
PRINT 'BEGIN FILTER BEST..TLIFDRI ...'
INSERT INTO #TLIFDRI
         (CTR_NF,   END_NT,   SEC_NF,   UWY_NF,   ACY_NF,   BALSHEY_NF,   BALSHTMTH_NF,                  LSTUPD_D)
SELECT T2.CTR_NF,T2.END_NT,T2.SEC_NF,T2.UWY_NF,T2.ACY_NF,T2.BALSHEY_NF,T2.BALSHTMTH_NF, max(T2.LSTUPD_D) LSTUPD_D 
FROM BEST..TLIFDRI T2 WHERE T2.BALSHEY_NF in (2019,2020)
GROUP BY T2.CTR_NF,T2.END_NT,T2.SEC_NF,T2.UWY_NF,T2.ACY_NF,T2.BALSHEY_NF,T2.BALSHTMTH_NF

-- récuperer codes retour --
----------------------------
SELECT	@erreur = @@error
IF @erreur != 0 
BEGIN
	PRINT 'FILTER BEST..TLIFDRI - ERROR : %1!', @erreur
	GOTO fin1
END
ELSE
PRINT 'FILTER LATEST POSITION FROM BEST..TLIFDRI SUCCESS.'

-- Save only the latest update of each line from TLIFDRI --
-----------------------------------------------------------
PRINT 'BEGIN PURGE BEST..TLIFDRI ...'

SET flushmessage ON
SELECT	@enr = 1,
		@totenr = 0,
		@erreur = 0
SET rowcount 50000
WHILE @enr > 0
BEGIN
	BEGIN TRAN
	DELETE 
	FROM best..TLIFDRI
	FROM best..TLIFDRI T1, best..#TLIFDRI T2
	WHERE T1.CTR_NF       = T2.CTR_NF
	AND   T1.END_NT       = T2.END_NT 
	AND   T1.SEC_NF       = T2.SEC_NF 
	AND   T1.UWY_NF       = T2.UWY_NF 
	AND   T1.ACY_NF       = T2.ACY_NF 
	AND   T1.BALSHEY_NF   = T2.BALSHEY_NF 
	AND   T1.BALSHTMTH_NF = T2.BALSHTMTH_NF
	AND   T1.LSTUPD_D    != T2.LSTUPD_D

	-- récuperer codes retour --
	----------------------------
	SELECT	@erreur = @@error,
		 	@enr = @@rowcount,
			@totenr = @totenr + @@rowcount
	IF @@transtate > 1 OR @erreur != 0
	BEGIN
		PRINT 'PURGE BEST..TLIFDRI - ERROR : %1!', @erreur
		ROLLBACK TRAN
		GOTO fin1
	END
	COMMIT TRAN
END

PRINT 'PURGE BEST..TLIFDRI SUCCESS - %1! deleted.', @totenr 

fin1:
SET rowcount 0
DROP TABLE #TLIFDRI
GO

------------------------------------------------------------------------------
-- Purge of TLIFEST 
------------------------------------------------------------------------------
PRINT 'BEGIN PURGE BEST..TLIFEST'
SET flushmessage ON

DECLARE	@erreur			int,
		@trans_etat		int,
		@enr			int,
		@totenr			int,
		@current_blshey int

SELECT	@enr            = 1,
		@totenr         = 0,
		@erreur         = 0,
		@current_blshey = year(getdate())
SET rowcount 500000
WHILE @enr > 0
BEGIN
	BEGIN TRAN
	DELETE BEST..TLIFEST FROM BEST..TLIFEST a
	WHERE a.BALSHEY_NF in (2019,2020)

	SELECT	@erreur = @@error,
			@enr    = @@rowcount,
			@totenr = @totenr + @@rowcount
	IF @@transtate > 1 OR @erreur != 0
	BEGIN
		PRINT 'PURGE BEST..TLIFEST - ERROR : %1!', @erreur
		ROLLBACK TRAN
		GOTO fin
	END
	COMMIT TRAN
END

PRINT 'PURGE BEST..TLIFEST SUCCESS - %1! deleted.', @totenr

fin:
SET rowcount 0
GO

SET nocount ON
DECLARE @msg VARCHAR(60)
SELECT @msg=@@servername + ' => ' + HOST_NAME() + '  Fin  '
+ CONVERT(CHAR(9),GETDATE(),6) + ' ' + CONVERT(CHAR(8), GETDATE(), 8)
+ SUBSTRING(CONVERT(CHAR(27), GETDATE(), 109), 21, 4)
print @msg
SET nocount OFF
GO
