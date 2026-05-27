USE BEST
go
IF OBJECT_ID('dbo.PuLIFMOD2_02_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PuLIFMOD2_02_O2
  IF OBJECT_ID('dbo.PuLIFMOD2_02_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuLIFMOD2_02_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PuLIFMOD2_02_O2 >>>'
END
go
create procedure dbo.PuLIFMOD2_02_O2(
  @p_ssd_cf     USSD_CF,
  @p_esb_cf     UESB_CF,
  @p_usr_cf 		UUSR_CF,
	@p_mode				char(1)
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Amit D
Creation date     : 12/03/2014
Description       :  This procedure updates TLIFMOD2 with the data from BTRAV...EST_ESID0811_TLIFMOD2 
_________________________________
Domain            : Estimate
Base              : BEST
Version           : 2
Author            : Manoja Swaro
Creation date     : 19/08/2014
Description       :  This procedure inserts and updates TLIFMOD2 with the data from BTRAV...EST_ESID0811_TLIFMOD2 for all uwy_nf
_________________________________
Domain            : Estimate
Base              : BEST
Version           : 3
Author            : Manoja Swaro
Creation date     : 21/08/2014
Description       :  This procedure inserts and updates TLIFMOD with the data from BTRAV...EST_ESID0811_TLIFMOD
_________________________________
Domain            : Estimate
Base              : BEST
Version           : 4
Author            : Pierre Colle
Creation date     : 10/09/2014
Description       :  Code check, for duplicate key issue
_________________________________
Domain            : Estimate
Base              : BEST
Version           : 5
Author            : Manoja Swaro
Creation date     : 10/09/2014
Description       :  TLIFPEN insert, for duplicate key issue
_________________________________
Domain            : Estimate
Base              : BEST
Version           : 6
Author            : Kirtishekhar Bagwe
Creation date     : 30/10/2014
Description       : Fix for 31269 - Calculation of differences are false after file upload
_________________________________
Domain            : Estimate
Base              : BEST
Version           : 7
Author            : Gaurav Pujari
Creation date     : 27/10/2015
Description       : EST 23a added column for insert into the TLIFMOD insert 
_________________________________
Domain            : Estimate
Base              : BEST
Version           : 8
Author            : L. Wernert
Creation date     : 18/11/2020
Description       : [88779] - IFRS17: REQ.LIF.EST02 - Automatic upload of estimates - lot3
_________________________________
Domain            : Estimate
Base              : BEST
Version           : 9
Author            : L. Wernert
Creation date     : 11/12/2020
Description       : [92289] - IFRS17: REQ.LIF.EST02 - Automatic upload of estimates - Notifications file movement
*****************************************************/

DECLARE 
	@erreur int

-------------------- start -------------------
CREATE TABLE #ESID0811_TLIFMOD2(
	CTR_NF UCTR_NF,
	SEC_NF USEC_NF,
	CRE_D datetime,
	BALSHEY_NF smallint,
	BALSHTMTH_NF tinyint,
	ACY_NF UACCYER_NF,
	COMACC_B bit,
	PRIPRMAMT_M  UAMT_M,
	PRIRESTECAMT_M  UAMT_M,
	PRIRESDACAMT_M  UAMT_M,
	PRIRESFINAMT_M  UAMT_M,
	DELTAPRMAMT_M  UAMT_M, 
	DELTARESTECAMT_M  UAMT_M, 
	DELTARESDACAMT_M  UAMT_M,
	DELTARESFINAMT_M  UAMT_M,
	CREUSR_CF 	  UUSR_CF,
	LSTUPD_D 		  datetime,
	LSTUPDUSR_CF 	  UUSR_CF,
	GAAP_NT tinyint,
	MODE_B bit,
	DBAPRMAMT_M  UAMT_M, 				--mod6
	DBARESTECAMT_M  UAMT_M, 			--mod6
	DBARESDACAMT_M  UAMT_M,			--mod6
	DBARESFINAMT_M  UAMT_M,			--mod6
	FINALAPRMAMT_M  UAMT_M, 			--mod6
	FINALARESTECAMT_M  UAMT_M, 		--mod6
	FINALARESDACAMT_M  UAMT_M,		--mod6	
	FINALARESFINAMT_M  UAMT_M,		--mod6
) 


/* procedure to insert TLIFPEN with the data from BTRAV...EST_ESID0811_TLIFPEN start*/ --5
-- Automatic upload
IF @p_mode = 'A'
BEGIN
	DECLARE 
		@admusr_cf UUPDUSR_CF,
		@CTR_NF VARCHAR(50)
	
  DECLARE curs_CTR_NF CURSOR FOR
		SELECT 
			DISTINCT CTR_NF
		FROM 
			BTRAV..EST_ESID0811_TLIFPEN
		WHERE
			SSD_CF = @p_ssd_cf AND 
			ESB_CF = @p_esb_cf
			
  OPEN curs_CTR_NF
  FETCH curs_CTR_NF INTO @CTR_NF
	SELECT @erreur = @@error
  IF @erreur != 0
	BEGIN
		PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
		ROLLBACK TRAN
		GOTO fin
	END
		
	-- Loop Fetch/insert
	WHILE (@@sqlstatus != 2)
	BEGIN
		-- Get the tech. assistant
		SELECT 
			@admusr_cf = 
				CASE 
					WHEN tc.ADMUSR_CF IS NULL THEN tr.ADMUSR_CF 
					ELSE tc.ADMUSR_CF 
				END
		FROM 
			BTRAV..EST_ESID0811_TLIFPEN tl 
		LEFT JOIN 
			BTRT..TCONTR tc ON 
				tl.CTR_NF = tc.CTR_NF AND 
				tc.UWY_NF = (SELECT MAX(UWY_NF) FROM BTRT..TCONTR WHERE CTR_NF = tl.CTR_NF)
		LEFT JOIN 
			BRET..TRETCTR tr ON 
				tl.CTR_NF = tr.RETCTR_NF AND 
				tr.RTY_NF = (SELECT MAX(RTY_NF) FROM BRET..TRETCTR WHERE RETCTR_NF = tl.CTR_NF)
		WHERE 
			tl.CTR_NF = @CTR_NF AND
			tl.SSD_CF = @p_ssd_cf AND 
			tl.ESB_CF = @p_esb_cf
			
			
		-- Update BTRAV..EST_ESID0811_TLIFPEN
		UPDATE 
			BTRAV..EST_ESID0811_TLIFPEN
		SET 
			CREUSR_CF = @admusr_cf
		WHERE
			SSD_CF = @p_ssd_cf AND 
			ESB_CF = @p_esb_cf AND
			CTR_NF = @CTR_NF
		
		FETCH curs_CTR_NF INTO @CTR_NF
		IF @erreur != 0
		BEGIN
			PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
			ROLLBACK TRAN
			GOTO fin
		END
	END
	-- Close cursor
	CLOSE curs_CTR_NF
	DEALLOCATE CURSOR curs_CTR_NF	
END

	
INSERT INTO BEST..TLIFPEN 
SELECT DISTINCT
	USR_CF,
  CTR_NF, 
  SEC_NF,
  CRE_D, 
  BALSHEY_NF, 
  BALSHTMTH_NF,
  PENSTS_CT,
  UWGRP_CF,
	CREUSR_CF,
  LSTUPD_D,
  LSTUPDUSR_CF,
  null -- mod4 do not write anything into TIMESTAMP column, automatically 
FROM 
	BTRAV..EST_ESID0811_TLIFPEN
WHERE 
  SSD_CF = @p_ssd_cf AND 
	ESB_CF = @p_esb_cf AND 
	USR_CF = @p_usr_cf
GROUP BY -- mod 4 GROUP BY with having avoid to get duplicated keys in case of 2 CRE_D different values
	USR_CF,
  CTR_NF, 
  SEC_NF,
  BALSHEY_NF, 
  BALSHTMTH_NF
HAVING 
	CRE_D = MAX(CRE_D) AND 
	LSTUPD_D = MAX(LSTUPD_D)
/* procedure to insert TLIFPEN with the data from BTRAV...EST_ESID0811_TLIFPEN end*/ --5

/* procedure to insert and updates TLIFMOD with the data from BTRAV...EST_ESID0811_TLIFMOD start */
/* procedure to insert TLIFMOD with the data from BTRAV...EST_ESID0811_TLIFMOD */

IF @p_mode = 'A'
BEGIN
	INSERT INTO BEST..TLIFMOD 
	SELECT DISTINCT
	  CTR_NF, 
	  SEC_NF,
	  CRE_D, 
	  BALSHEY_NF, 
	  BALSHTMTH_NF,
	  SSD_CF,
	  15 AS TYPMOD1_CT,
		null AS TYPMOD2_CT,
	  CUR_CF,
	  CMT_NT,
	  SENMAI_D,
	  ORICOD_LS,
	  CREUSR_CF,
	  LSTUPD_D,
		(SELECT DISTINCT CASE WHEN tc.ADMUSR_CF IS NULL THEN tr.ADMUSR_CF ELSE tc.ADMUSR_CF END
		FROM BTRAV..EST_ESID0811_TLIFMOD tl 
		LEFT JOIN BTRT..TCONTR tc ON 
			tl.CTR_NF = tc.CTR_NF AND 
			tc.UWY_NF = (SELECT MAX(UWY_NF) FROM BTRT..TCONTR WHERE CTR_NF = tl.CTR_NF)
		LEFT JOIN BRET..TRETCTR tr ON 
			tl.CTR_NF = tr.RETCTR_NF AND 
			tr.RTY_NF = (SELECT MAX(RTY_NF) FROM BRET..TRETCTR WHERE RETCTR_NF = tl.CTR_NF)
		WHERE tl.CTR_NF = a.CTR_NF AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf) AS LSTUPDUSR_CF,
	  null, -- mod4 do not write anything into TIMESTAMP column, automatically 
		1		--mod 7
	FROM BTRAV..EST_ESID0811_TLIFMOD a
	WHERE 
	  SSD_CF = @p_ssd_cf AND 
		ESB_CF = @p_esb_cf AND 
		USR_CF = @p_usr_cf AND 
		MODE_B = 0
	GROUP BY -- mod 4 GROUP BY with having avoid to get duplicated keys in case of 2 CRE_D different values
	  CTR_NF, 
	  SEC_NF,
	  BALSHEY_NF, 
	  BALSHTMTH_NF
	HAVING 
		CRE_D = MAX(CRE_D) AND 
		LSTUPD_D = MAX(LSTUPD_D)
		
	/* procedure to update TLIFMOD with the data from BTRAV...EST_ESID0811_TLIFMOD */
	UPDATE BEST..TLIFMOD 
	SET
	  CMT_NT = b.CMT_NT,
	  LSTUPD_D = b.LSTUPD_D,
		DISPLAY_B = 1  --mod 7
	FROM 
		BEST..TLIFMOD a, BTRAV..EST_ESID0811_TLIFMOD b
	WHERE 
		a.CTR_NF = b.CTR_NF AND 
		a.SEC_NF = b.SEC_NF AND 
		a.BALSHEY_NF = b.BALSHEY_NF AND 
		a.BALSHTMTH_NF = b.BALSHTMTH_NF AND 
		cast(a.CRE_D as date) = cast(b.CRE_D as date) AND 
		b.SSD_CF = @p_ssd_cf AND -- mod4 join on SSD,ESB and USR to be sure to not compute out of scope data
		b.ESB_CF = @p_esb_cf AND 
		b.USR_CF = @p_usr_cf AND 
		b.MODE_B = 1
	/* procedure inserts and updates TLIFMOD with the data from BTRAV...EST_ESID0811_TLIFMOD --3 end */

END
ELSE
BEGIN
	INSERT INTO BEST..TLIFMOD 
	SELECT DISTINCT
	  CTR_NF, 
	  SEC_NF,
	  CRE_D, 
	  BALSHEY_NF, 
	  BALSHTMTH_NF,
	  SSD_CF,
	  TYPMOD1_CT,
		TYPMOD2_CT,
	  CUR_CF,
	  CMT_NT,
	  SENMAI_D,
	  ORICOD_LS,
	  CREUSR_CF,
	  LSTUPD_D,
		LSTUPDUSR_CF,
	  null, -- mod4 do not write anything into TIMESTAMP column, automatically 
		1		--mod 7
	FROM BTRAV..EST_ESID0811_TLIFMOD a
	WHERE 
	  SSD_CF = @p_ssd_cf AND 
		ESB_CF = @p_esb_cf AND 
		USR_CF = @p_usr_cf AND 
		MODE_B = 0
	GROUP BY -- mod 4 GROUP BY with having avoid to get duplicated keys in case of 2 CRE_D different values
	  CTR_NF, 
	  SEC_NF,
	  BALSHEY_NF, 
	  BALSHTMTH_NF
	HAVING 
		CRE_D = MAX(CRE_D) AND 
		LSTUPD_D = MAX(LSTUPD_D)
		
	
	/* procedure to update TLIFMOD with the data from BTRAV...EST_ESID0811_TLIFMOD */
	UPDATE BEST..TLIFMOD 
	SET 
		TYPMOD1_CT = b.TYPMOD1_CT,
	  CMT_NT = b.CMT_NT,
	  ORICOD_LS = b.ORICOD_LS,
	  LSTUPD_D = b.LSTUPD_D,
	  LSTUPDUSR_CF = b.LSTUPDUSR_CF,
		DISPLAY_B = 1  --mod 7
	FROM 
		BEST..TLIFMOD a, BTRAV..EST_ESID0811_TLIFMOD b
	WHERE 
		a.CTR_NF = b.CTR_NF AND 
		a.SEC_NF = b.SEC_NF AND 
		a.BALSHEY_NF = b.BALSHEY_NF AND 
		a.BALSHTMTH_NF = b.BALSHTMTH_NF AND 
		cast(a.CRE_D as date) = cast(b.CRE_D as date) AND 
		b.SSD_CF = @p_ssd_cf AND -- mod4 join on SSD,ESB and USR to be sure to not compute out of scope data
		b.ESB_CF = @p_esb_cf AND 
		b.USR_CF = @p_usr_cf AND 
		b.MODE_B = 1
	/* procedure inserts and updates TLIFMOD with the data from BTRAV...EST_ESID0811_TLIFMOD --3 end */
	
END



INSERT INTO #ESID0811_TLIFMOD2
SELECT DISTINCT
  CTR_NF, 
  SEC_NF,
  CRE_D,
  BALSHEY_NF, 
  BALSHTMTH_NF, 
  ACY_NF, 
  COMACC_B, 
  PRIPRMAMT_M, 
  PRIRESTECAMT_M, 
  PRIRESDACAMT_M, 
  PRIRESFINAMT_M, 
  DELTAPRMAMT_M 	 = SUM(AFTPRMAMT_M - DBAPRMAMT_M),			--mod6
  DELTARESTECAMT_M = SUM(AFTRESTECAMT_M - DBARESTECAMT_M),	--mod6
  DELTARESDACAMT_M = SUM(AFTRESDACAMT_M - DBARESDACAMT_M),	--mod6	
  DELTARESFINAMT_M = SUM(AFTRESFINAMT_M - DBARESFINAMT_M),	--mod6
  CREUSR_CF, 
  LSTUPD_D,
  LSTUPDUSR_CF,
  GAAP_NT,
  MODE_B,
  DBAPRMAMT_M, 												--mod6
	DBARESTECAMT_M, 											--mod6
	DBARESDACAMT_M,												--mod6		
	DBARESFINAMT_M,												--mod6
	0, 															--mod6
	0, 															--mod6
	0,															--mod6
	0															--mod6
FROM BTRAV..EST_ESID0811_TLIFMOD2 
WHERE 
  SSD_CF = @p_ssd_cf AND 
	ESB_CF = @p_esb_cf AND 
	USR_CF = @p_usr_cf
GROUP BY 
  CTR_NF, 
  SEC_NF,
  BALSHEY_NF, 
  BALSHTMTH_NF, 
  ACY_NF,
  GAAP_NT
HAVING 
	CRE_D = MAX(CRE_D) AND 
	LSTUPD_D = MAX(LSTUPD_D) -- mod4 avoid to get duplicated lines


UPDATE #ESID0811_TLIFMOD2
SET
  FINALAPRMAMT_M  = DBAPRMAMT_M + DELTAPRMAMT_M,
  FINALARESTECAMT_M = DBARESTECAMT_M + DELTARESTECAMT_M,
  FINALARESDACAMT_M = DBARESDACAMT_M + DELTARESDACAMT_M,
  FINALARESFINAMT_M = DBARESFINAMT_M + DELTARESFINAMT_M
FROM #ESID0811_TLIFMOD2 


INSERT INTO TLIFMOD2 
SELECT
  CTR_NF, 
  SEC_NF,
  CRE_D, 
  BALSHEY_NF, 
  BALSHTMTH_NF, 
  ACY_NF,
  COMACC_B, 
  PRIPRMAMT_M, 
  FINALAPRMAMT_M,					--mod6							
  PRIRESTECAMT_M, 			
  FINALARESTECAMT_M,				--mod6
  PRIRESDACAMT_M, 
  FINALARESDACAMT_M,				--mod6
  PRIRESFINAMT_M, 
  FINALARESFINAMT_M,				--mod6
  CREUSR_CF, 
  LSTUPD_D,
  LSTUPDUSR_CF,
  CRE_D,
  GAAP_NT
FROM #ESID0811_TLIFMOD2
WHERE MODE_B = 0

------------------ end -----------------
UPDATE TLIFMOD2
SET 
	AFTPRMAMT_M = esid.FINALAPRMAMT_M,				--mod6
	AFTRESTECAMT_M = esid.FINALARESTECAMT_M,		--mod6
	AFTRESDACAMT_M = esid.FINALARESDACAMT_M,		--mod6	
	AFTRESFINAMT_M = esid.FINALARESFINAMT_M,		--mod6
	LSTUPD_D = esid.LSTUPD_D,
	LSTUPDUSR_CF = esid.LSTUPDUSR_CF
FROM TLIFMOD2 a, #ESID0811_TLIFMOD2 esid	--2
WHERE   
	a.CTR_NF = esid.CTR_NF AND 
	a.SEC_NF = esid.SEC_NF AND 
	a.BALSHEY_NF = esid.BALSHEY_NF AND 
	a.BALSHTMTH_NF = esid.BALSHTMTH_NF AND 
	a.CRE_D = esid.CRE_D AND 
	a.ACY_NF = esid.ACY_NF AND 
	esid.MODE_B = 1

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20001 "APPLICATIF;#ESID0811_TLIFMOD2_Final" --2
	return @erreur
	goto fin
end

fin:
if object_id('#ESID0811_TLIFMOD2') is not null drop table #ESID0811_TLIFMOD2 --2 --mod4 adding if object_id
	
return 0
go
EXEC sp_procxmode 'dbo.PuLIFMOD2_02_O2', 'unchained'
go
IF OBJECT_ID('dbo.PuLIFMOD2_02_O2') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PuLIFMOD2_02_O2 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PuLIFMOD2_02_O2 >>>'
go
GRANT EXECUTE ON dbo.PuLIFMOD2_02_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuLIFMOD2_02_O2 TO GDBBATCH
go
