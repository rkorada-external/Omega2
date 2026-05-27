USE BEST
go
IF OBJECT_ID('PiTCASHFLOWADJ_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PiTCASHFLOWADJ_01_O2
    IF OBJECT_ID('PiTCASHFLOWADJ_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PiTCASHFLOWADJ_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PiTCASHFLOWADJ_01_O2 >>>'
END
go
create procedure PiTCASHFLOWADJ_01_O2 (
@p_ssd_cf USSD_CF,
@p_esb_cf UESB_CF,
@p_usr_cf UUSR_CF
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Lilian Wernert
Creation date     : 10/04/2018

Description       : Case 1: Fills BEST..TCTRANO (FROM BTRAV..EST_ESID0891_TCTRANO) with all anomalies detected during a cash flow file loading
					          Case 2: Otherwise fills BEST..TCASHFLOWADJ (FROM BTRAV..EST_ESID0891_PERIMETER)
_________________
Change history:
[001] 08/06/2018 T. DEUTSCH :spira - 69018 Vidage anciennes erreurs de tctrano dans tous les cas
[002] 08/06/2018 L. WERNERT :spira - 69187
[003] 21/12/2018 L. WERNERT :spira - 71677 => Synchronization between error lines in BTRAV table and error lines in the loaded file
[004] 08/01/2021 B. LAGHA   :spira - 69856 => Management of the last upload flag (add CLODAT_D and ADJTYP_CF to the key)
[005] 10/09/2021 B. LAGHA   :spira - 93181 => Filling of new columns added in TCASHFLOWADJ(UWYPLAN_NF and VRSPLAN_NF) from EST_ESID0891_PERIMETER
*****************************************************/
DECLARE 
	@tran_imbr bit,
	@cre_d datetime
	
SELECT @tran_imbr = 1

CREATE TABLE #duplicateTrnNt
(
	TRN_NT numeric(10,0) null
)

--[001]
-- Delete old anomalies
DELETE FROM BEST..TCTRANO 
WHERE SSD_CF= @p_ssd_cf 
AND SEGTYP_CT='F' 
AND SEG_NF = @p_usr_cf 
AND ANO_CT != 1 
AND NUMLINE_NT != 0

-- Count the number of lines (anomalies) in BTRAV..EST_ESID0891_TCTRANO 
IF EXISTS(SELECT 1 FROM BTRAV..EST_ESID0891_TCTRANO
			WHERE BLOCKING_B = 1 AND SSD_CF = @p_ssd_cf
			AND	ESB_CF = @p_esb_cf AND SEG_NF = @p_usr_cf) 
    goto FIN

IF NOT EXISTS(SELECT 1 FROM BTRAV..EST_ESID0891_TCTRANO
			WHERE BLOCKING_B = 1 AND SSD_CF = @p_ssd_cf
			AND	ESB_CF = @p_esb_cf AND SEG_NF = @p_usr_cf)
    goto FIN2

FIN2:	
SELECT @tran_imbr = 1
	IF @@trancount = 0
  	BEGIN
	   	SELECT @tran_imbr = 0
   		BEGIN TRAN
  	END

-- [002] - START
-- Set UPL_B at 0 for all lines already loaded
UPDATE BEST..TCASHFLOWADJ
SET UPL_B = 0
FROM BTRAV..EST_ESID0891_PERIMETER peri
WHERE BEST..TCASHFLOWADJ.CTR_NF = peri.CTR_NF
AND BEST..TCASHFLOWADJ.SEC_NF = peri.SEC_NF
AND BEST..TCASHFLOWADJ.UWY_NF = peri.UWY_NF
AND BEST..TCASHFLOWADJ.ACY_NF = peri.ACY_NT
AND BEST..TCASHFLOWADJ.TRNCOD_CF = peri.TRNCOD_CF
AND BEST..TCASHFLOWADJ.CFQUARTER_CF = peri.CFQUARTER_CF
AND BEST..TCASHFLOWADJ.ADJTYP_CF = peri.ADJTYP_CF   -- [004]
AND BEST..TCASHFLOWADJ.CLODAT_D  = peri.CLODAT_D    -- [004]
AND BEST..TCASHFLOWADJ.UPL_B = 1


-- ***********************************************************************
-- Insertion into the table BEST..TCASHFLOWADJ if no anomalies are found *
-- ***********************************************************************

INSERT INTO BEST..TCASHFLOWADJ
(TRN_NT, CLODAT_D, SSD_CF, ESB_CF, CTR_NF, SEC_NF, UWY_NF, ACY_NF, TRNCOD_CF, 
 CFQUARTER_CF, CUR_CF, AMT1_M, TYPO_CF, COMMENT_LL, ADJTYP_CF, CRE_D, CREUSR_CF, 
 UPL_B,UWYPLAN_NF, VRSPLAN_NF) -- [005]
SELECT 
	TRN_NT, 
	CLODAT_D, 
	SSD_CF, 
	ESB_CF, 
	CTR_NF, 
	SEC_NF, 
	UWY_NF, 
	ACY_NT, 
	TRNCOD_CF, 
	CFQUARTER_CF, 
	CUR_CF, 
	AMT1_M, 
	TYPO_CF, 
	COMMENT_LL, 
	ADJTYP_CF, 
	getdate(), 
	USR_CF,
	1, 
	UWYPLAN_NF, -- [005]
	VRSPLAN_NF  -- [005]
FROM BTRAV..EST_ESID0891_PERIMETER
WHERE SSD_CF		= @p_ssd_cf
AND ESB_CF		= @p_esb_cf
AND	USR_CF	= @p_usr_cf


-- Search lines with a duplicate key in the last upload
IF EXISTS(SELECT count(min(TRN_NT)) 
			FROM BTRAV..EST_ESID0891_PERIMETER
			GROUP BY CTR_NF, SEC_NF, UWY_NF, ACY_NT, TRNCOD_CF, CFQUARTER_CF, ADJTYP_CF, CLODAT_D  -- [004]
			HAVING count(*) > 1)
      
	-- If duplicates are found, insert their minus TRN_NT in temp table 		
	INSERT INTO #duplicateTrnNt
	SELECT min(TRN_NT)
	FROM BTRAV..EST_ESID0891_PERIMETER
	GROUP BY CTR_NF, SEC_NF, UWY_NF, ACY_NT, TRNCOD_CF, CFQUARTER_CF, ADJTYP_CF, CLODAT_D  -- [004]
	HAVING COUNT(*) > 1
	
  -- Set the UPL_B at 0 for the minus TRN_NT of duplicates
	UPDATE BEST..TCASHFLOWADJ
	SET UPL_B = 0
	FROM #duplicateTrnNt dup
	WHERE BEST..TCASHFLOWADJ.TRN_NT = dup.TRN_NT


-- Update of UPL_B for lines with the key CTR_NF/SEC_NF/ACY_NT/TRNCOD_CF/CFQUARTER_CF
/*UPDATE BEST..TCASHFLOWADJ
SET UPL_B = 1
FROM BTRAV..EST_ESID0891_PERIMETER e
WHERE e.CTR_NF = BEST..TCASHFLOWADJ.CTR_NF
AND e.SEC_NF = BEST..TCASHFLOWADJ.SEC_NF
AND e.UWY_NF = BEST..TCASHFLOWADJ.UWY_NF
AND e.ACY_NT = BEST..TCASHFLOWADJ.ACY_NF
AND e.TRNCOD_CF = BEST..TCASHFLOWADJ.TRNCOD_CF
AND e.CFQUARTER_CF = BEST..TCASHFLOWADJ.CFQUARTER_CF
AND */
-- [002] - END

if @tran_imbr = 0
	COMMIT TRAN

IF object_id('#duplicateTrnNt') is not null 
	DROP TABLE #duplicateTrnNt
	
/* Clean exit */
return


-- ******************************************************************
-- Insertion into the table BEST..TCTRANO if there are anomalies	*
-- ******************************************************************
FIN:
SELECT @tran_imbr = 1
	IF @@trancount = 0
  	BEGIN
	   	SELECT @tran_imbr = 0
   		BEGIN TRAN
  	END
/* --[001]
-- Delete old anomalies from the same user	
DELETE FROM BEST..TCTRANO 
WHERE SSD_CF= @p_ssd_cf 
AND SEGTYP_CT='F' 
AND SEG_NF = @p_usr_cf 
AND ANO_CT != 1 
AND NUMLINE_NT != 0
*/
-- Insert anomalies in BEST..TCTRANO 
INSERT BEST..TCTRANO
SELECT DISTINCT 
	CTR_NF, 
	END_NT, 
	SEC_NF, 
	VRS_NF, 
	SSD_CF,
	SEGTYP_CT,
	SEG_NF, 
	ANO_CT, 
	NUMLINE_NT + 1, --[003]
	UWY_NF, 
	ACY_NF 
FROM BTRAV..EST_ESID0891_TCTRANO
WHERE SSD_CF = @p_ssd_cf
AND	ESB_CF = @p_esb_cf
AND	SEG_NF = @p_usr_cf

if @tran_imbr = 0
	COMMIT TRAN

/* Clean exit */
return

go
EXEC sp_procxmode 'PiTCASHFLOWADJ_01_O2', 'unchained'
go

IF OBJECT_ID('PiTCASHFLOWADJ_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PiTCASHFLOWADJ_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PiTCASHFLOWADJ_01_O2 >>>'
go
GRANT EXECUTE ON PiTCASHFLOWADJ_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PiTCASHFLOWADJ_01_O2 TO GDBBATCH
go
