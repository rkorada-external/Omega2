USE BEST
go
IF OBJECT_ID('PsTUPLDEST_01_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PsTUPLDEST_01_O2
  IF OBJECT_ID('PsTUPLDEST_01_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE PsTUPLDEST_01_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE PsTUPLDEST_01_O2 >>>'
END
go

CREATE PROCEDURE PsTUPLDEST_01_O2 (
	@p_upldno_nt int,
	@p_file VARCHAR(3)
)
WITH EXECUTE AS CALLER AS

/******************************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert
Creation date     : 24/08/2020
Description       : Generate files for the acknowledge process
Called by:
- ESIJ0813.cmd
_________________

********************************************************************/
DECLARE
	@trans_etat	int,
	@erreur int,
	@retour int,
	@p_erreur varchar(50),
	@tran_imbr bit,
	@V_SSD_CF USSD_CF,
	@V_ESB_CF UESB_CF,
	@V_FILENO_NT int,
	@V_MESSTHM_C UMESSTHM_C
	
	
/* Variables for balance sheet date */
DECLARE
	@datebilan datetime,
	@mois smallint,
	@annee smallint,
	@premierjour smallint,
	@dernierjour smallint,
	@ret_code smallint
	
select @erreur = 0, @tran_imbr = 1, @V_MESSTHM_C = 'ESTIMATION'

-- General table
IF (@p_file = 'GE')
BEGIN
	-- 1. Insert data in temp table without balance sheet date
	SELECT 
		@V_MESSTHM_C as MESSTHM_C, @p_upldno_nt as UPLDNO_NT, 
		FILENO_NT, PROVIDER_CF, SSD_CF, ESB_CF, CREUSR_CF, 
		FILE_LL, FILEUNIXNAME_LL, CRE_D as INTEG_D, STATUS_CF, 
		NBLINES_NT, NBLINESKO_NT, NBANO_NT, CREUSR_CF as LSTUPDUSR_CF,
		CRE_D as LSTUPD_D, getdate() as BLCSHT_D
	INTO 
		#TUPLDESTGE01
	FROM 
		TLOADAUTOEST
	WHERE 
		UPLDNO_NT = @p_upldno_nt

	-- 2. Get distinct SSD, ESB to retrieve the balance sheet date
	SELECT DISTINCT 
		SSD_CF, ESB_CF 
	INTO 
		#TSSDESB_GE
	FROM
		TLOADAUTOEST
	WHERE
		UPLDNO_NT = @p_upldno_nt
		
	-- 3. Declare TSSDESB cursor
	DECLARE curs_TSSDESB CURSOR FOR
	SELECT
		SSD_CF, ESB_CF
	FROM 
		#TSSDESB_GE                

	-- 4. Open cursor and fetch first result
	OPEN curs_TSSDESB
	FETCH curs_TSSDESB INTO @V_SSD_CF, @V_ESB_CF
	SELECT @erreur = @@error, @trans_etat = @@transtate
	IF @erreur != 0 OR @trans_etat > 1
	BEGIN
		PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
		GOTO fin
	END
	
	-- 5. Get balance sheet date
	EXEC @retour = BCTA..PsBLCSHTD_05 @V_SSD_CF, @V_ESB_CF, 0, 1, null, null, @mois OUTPUT, @annee OUTPUT, @premierjour OUTPUT, @dernierjour OUTPUT, @datebilan OUTPUT, @ret_code OUTPUT
	SELECT @erreur = @@error
	IF @erreur! = 0
	BEGIN
		SELECT @p_erreur = 'Appel BCTA..PsBLCSHTD_05 - Codes retour: ' + convert(char(6),@retour) + '-' + convert(char(6),@erreur)
		GOTO fin
	END
	
	-- 6. Update temp table with the balance sheet date 
	UPDATE
		#TUPLDESTGE01
	SET 
		BLCSHT_D = @datebilan
	WHERE 
		SSD_CF = @V_SSD_CF AND
		ESB_CF = @V_ESB_CF
	
	-- 7. Fetch again to see if there is still data
	FETCH curs_TSSDESB INTO @V_SSD_CF, @V_ESB_CF
	SELECT @erreur = @@error, @trans_etat = @@transtate
	IF @erreur != 0 OR @trans_etat > 1
	BEGIN
		PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
		GOTO fin
	END
	
	-- 8. Keep fetching data
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		-- 9. Get balance sheet date
		EXEC @retour = BCTA..PsBLCSHTD_05 @V_SSD_CF, @V_ESB_CF, 0, 1, null, null, @mois OUTPUT, @annee OUTPUT, @premierjour OUTPUT, @dernierjour OUTPUT, @datebilan OUTPUT, @ret_code OUTPUT
		SELECT @erreur = @@error
		IF @erreur! = 0
		BEGIN
			select @p_erreur = 'Appel BCTA..PsBLCSHTD_05 - Codes retour: ' + convert(char(6),@retour) + '-' + convert(char(6),@erreur)
			GOTO fin
		END
		
		-- 10. Update temp table with the balance sheet date 
		UPDATE
			#TUPLDESTGE01
		SET 
			BLCSHT_D = @datebilan
		WHERE 
			SSD_CF = @V_SSD_CF AND
			ESB_CF = @V_ESB_CF
			
		-- 11. Fetch again to see if there is still data
		FETCH curs_TSSDESB INTO @V_SSD_CF, @V_ESB_CF
		SELECT @erreur = @@error, @trans_etat = @@transtate
		IF @erreur != 0 OR @trans_etat > 1
		BEGIN
			PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
			GOTO fin
		END
	END
	
	-- 12. Close cursor
	CLOSE curs_TSSDESB  
	DEALLOCATE curs_TSSDESB
	
	-- 13. Select
	SELECT * FROM #TUPLDESTGE01
	
	-- 14. Drop table
	DROP TABLE #TUPLDESTGE01
	DROP TABLE #TSSDESB_GE
END
ELSE
-- Detailed table
BEGIN
	-- 1. Insert data in temp table without balance sheet date	
	SELECT 
		@V_MESSTHM_C as MESSTHM_C, @p_upldno_nt as UPLDNO_NT, T1.FILENO_NT, 
		T1.PROVIDER_CF, T1.SSD_CF, T1.ESB_CF, T2.NUMLINE_NT, T2.ERRORCODE_CT, 
		(SELECT MESS_L FROM BREF..TMESSAGE WHERE MESS_N = T2.ERRORCODE_CT AND LANG_C = 'E' AND MESSTHM_C = @V_MESSTHM_C) AS MESS_L,
		T2.CTR_NF, T2.SEC_NF, T2.UWY_NF, T2.ACY_NF, T3.CUR_CF, 
		T2.DETTRNCOD_CF, T3.ESTMNT_M, T1.CREUSR_CF, T1.FILE_LL, 
		T1.FILEUNIXNAME_LL, T1.CRE_D as INTEG_D, T1.STATUS_CF, 
		T1.NBLINES_NT, T1.NBLINESKO_NT, T1.NBANO_NT, 
		T1.CREUSR_CF as LSTUPDUSR_CF, T1.CRE_D as LSTUPD_D, 
		getdate() as BLCSHT_D
	INTO 
		#TUPLDESTDET02
	FROM 
		TLOADAUTOEST T1, TANOUPLD T2, BTRAV..EST_ESIJ0810_FILECONTENT T3 
	WHERE 
		T1.UPLDNO_NT = @p_upldno_nt AND
		T1.FILENO_NT = T2.FILEID_CF AND 
		T2.FILEID_CF = T3.FILENO_NT AND
		T2.NUMLINE_NT = T3.NUMLINE_NT
		
	--- 2. Get distinct SSD, ESB to retrieve the balance sheet date
	SELECT DISTINCT 
		SSD_CF, ESB_CF 
	INTO 
		#TSSDESB_DET
	FROM
		TLOADAUTOEST
	WHERE
		UPLDNO_NT = @p_upldno_nt                

	-- 3. Declare TSSDESB cursor
	DECLARE curs_TSSDESB CURSOR FOR
	SELECT
		SSD_CF, ESB_CF
	FROM 
		#TSSDESB_DET
		
	-- 4. Open cursor and fetch first result
	OPEN curs_TSSDESB
	FETCH curs_TSSDESB INTO @V_SSD_CF, @V_ESB_CF
	SELECT @erreur = @@error, @trans_etat = @@transtate
	IF @erreur != 0 OR @trans_etat > 1
	BEGIN
		PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
		GOTO fin
	END
	
	-- 5. Get balance sheet date
	EXEC @retour = BCTA..PsBLCSHTD_05 @V_SSD_CF, @V_ESB_CF, 0, 1, null, null, @mois OUTPUT, @annee OUTPUT, @premierjour OUTPUT, @dernierjour OUTPUT, @datebilan OUTPUT, @ret_code OUTPUT
	SELECT @erreur = @@error
	IF @erreur! = 0
	BEGIN
		SELECT @p_erreur = 'Appel BCTA..PsBLCSHTD_05 - Codes retour: ' + convert(char(6),@retour) + '-' + convert(char(6),@erreur)
		GOTO fin
	END
	
	-- 6. Update temp table with the balance sheet date
	UPDATE
		#TUPLDESTDET02
	SET 
		BLCSHT_D = @datebilan
	WHERE 
		SSD_CF = @V_SSD_CF AND
		ESB_CF = @V_ESB_CF
	
	-- 7. Fetch again to see if there is still data
	FETCH curs_TSSDESB INTO @V_SSD_CF, @V_ESB_CF
	SELECT @erreur = @@error, @trans_etat = @@transtate
	IF @erreur != 0 OR @trans_etat > 1
	BEGIN
		PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
		GOTO fin
	END
	
	-- 8. Keep fetching cursor
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		-- 9. Get balance sheet date
		EXEC @retour = BCTA..PsBLCSHTD_05 @V_SSD_CF, @V_ESB_CF, 0, 1, null, null, @mois OUTPUT, @annee OUTPUT, @premierjour OUTPUT, @dernierjour OUTPUT, @datebilan OUTPUT, @ret_code OUTPUT
		SELECT @erreur=@@error
		IF @erreur != 0
		BEGIN
			SELECT @p_erreur = ' Appel BCTA..PsBLCSHTD_05 - Codes retour: ' + convert(char(6),@retour) + '-' + convert(char(6),@erreur)
			GOTO fin
		END
		
		-- 10. Update temp table with the balance sheet date
		UPDATE
			#TUPLDESTDET02
		SET 
			BLCSHT_D = @datebilan
		WHERE 
			SSD_CF = @V_SSD_CF AND
			ESB_CF = @V_ESB_CF
		
		-- 11. Fetch again to see if there is still data
		FETCH curs_TSSDESB INTO @V_SSD_CF, @V_ESB_CF
		SELECT @erreur = @@error, @trans_etat = @@transtate
		IF @erreur != 0 OR @trans_etat > 1
		BEGIN
			PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
			GOTO fin
		END
	END
	
	-- 12. Close cursor
	CLOSE curs_TSSDESB  
	DEALLOCATE curs_TSSDESB
	
	-- 13. Select	
	SELECT * FROM #TUPLDESTDET02
	
	-- 14. Drop table
	DROP TABLE #TUPLDESTDET02
	DROP TABLE #TSSDESB_DET
END


-- Commit tran
if @tran_imbr = 0
	BEGIN
	COMMIT TRAN
END
return 0
   
-- Rollback
fin:
if @tran_imbr = 0
	BEGIN
	ROLLBACK TRAN
END

select @p_erreur = 'Error PsTUPLDEST_01_O2 - error: ' + convert(char(5),@erreur)
PRINT @p_erreur
return -1

go
EXEC sp_procxmode 'PsTUPLDEST_01_O2', 'unchained'
go
IF OBJECT_ID('PsTUPLDEST_01_O2') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE PsTUPLDEST_01_O2 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE PsTUPLDEST_01_O2 >>>'
go
GRANT EXECUTE ON PsTUPLDEST_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PsTUPLDEST_01_O2 TO GDBBATCH
go