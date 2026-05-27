USE BEST
go
IF OBJECT_ID('PuLIFEST_02_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PuLIFEST_02_O2
  IF OBJECT_ID('PuLIFEST_02_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE PuLIFEST_02_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE PuLIFEST_02_O2 >>>'
END
go
CREATE PROCEDURE PuLIFEST_02_O2(
	@p_mode char(1) = null
)
WITH EXECUTE AS CALLER AS

/****************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert
Creation date     : 08/10/2018
Description       : Completes the quarterly scope with additional data
_________________
Modification: [MOD1] 
Author: L. Wernert
Date: 26/12/2018
Description: Spira 73959 => [Apolo - QE] TLIFESTD - Remove the Field ACCFRQ_CT
_________________
Modification: [MOD2] 
Author: L. Wernert
Date: 18/02/2019
Description: Spira 73349 => PRS_CF & ACMTRS_CF not filled
_________________
Modification: [MOD3] 
Author: L. Wernert
Date: 27/12/2019
Description: Spira 80275 => Field PRS_CF and ACMTRS_NT empty after uploading ending (VOBA/DAC)
_________________
Modification: [MOD4] 
Author: L. Wernert
Date: 15/07/2020
Description: Spira 87874 => TLIFESTD: Management of create date and last update date
_________________
Modification: [MOD5] 
Author: L. Wernert
Date: 15/07/2020
Description: Spira 87213 => Update ORICOD_LS in case of automatic estimates upload
_________________
[MOD6]  S.Behague :spira:81638 APOLO QE / Estimates grid : la coche de propagation des postes de cash n'est pas cochée par défaut
[MOD7]  B. LAGHA  :spira:98426 fixe ACMTRS value case assumed or retro 
*****************************************************/

declare 
  @erreur             int,
	@current_balshtyear datetime,
	@TYPPER             char(1),
	@BLCSHTYEA_NF       smallint,
  @BLCSHTMTH_NF       tinyint,
	@prs_cf             int

-- [MOD1] - START
CREATE TABLE #EST_ESID0811_TLIFESTQ
(
  CTR_NF        UCTR_NF    NOT NULL,
  END_NT        UEND_NT    NOT NULL,
  SEC_NF        USEC_NF    NOT NULL,
  UWY_NF        UUWY_NF    NOT NULL,
  UW_NT         UUW_NT     NOT NULL,
  CRE_D         UUPD_D     NOT NULL,
  BALSHEY_NF    smallint   NOT NULL,
  BALSHTMTH_NF  tinyint    NOT NULL,
  ACY_NF        smallint   NOT NULL,
  GAAP_NT       tinyint    NOT NULL,
  DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
  ACM_NF        tinyint    DEFAULT 13 NOT NULL,
  PRS_CF        smallint   NOT NULL,
  ACMTRS_NT     smallint   NOT NULL,
  SSD_CF        USSD_CF    NOT NULL,
  CUR_CF        UCUR_CF    NOT NULL,
  ESTMNT_M      UAMT_M     NOT NULL,
  INDSUP_B      bit        DEFAULT 0  NOT NULL,
  ORICOD_LS     UL16       NULL,
  CREUSR_CF     UUPDUSR_CF NOT NULL,
  LSTUPD_D      UUPD_D     NOT NULL,
  LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
  ORICTR_NF     UCTR_NF    NULL,
  ORISEC_NF     USEC_NF    NULL,
  ORIUWY_NF     UUWY_NF    NULL,
  DIFF_M        UAMT_M     NULL,
  PROPAGATION_B bit        DEFAULT 0  NOT NULL,
  CALCULATED_B  bit        DEFAULT 0  NOT NULL,
  BATCH_B       bit        DEFAULT 0  NOT NULL,
  RETRO_B       bit        DEFAULT 0  NOT NULL,
  LOB_CF        ULOB_CF    DEFAULT '' NOT NULL,
  MAXUWY_NF	    UUWY_NF    NULL
)

CREATE TABLE #EST_ESID0811_TLIFESTY
(
  CTR_NF        UCTR_NF    NOT NULL,
  END_NT        UEND_NT    NOT NULL,
  SEC_NF        USEC_NF    NOT NULL,
  UWY_NF        UUWY_NF    NOT NULL,
  UW_NT         UUW_NT     NOT NULL,
  CRE_D         UUPD_D     NOT NULL,
  BALSHEY_NF    smallint   NOT NULL,
  BALSHTMTH_NF  tinyint    NOT NULL,
  ACY_NF        smallint   NOT NULL,
  GAAP_NT       tinyint    NOT NULL,
  DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
  ACM_NF        tinyint    DEFAULT 13 NOT NULL,
  PRS_CF        smallint   NOT NULL,
  ACMTRS_NT     smallint   NOT NULL,
  SSD_CF        USSD_CF    NOT NULL,
  CUR_CF        UCUR_CF    NOT NULL,
  ESTMNT_M      UAMT_M     NOT NULL,
  INDSUP_B      bit        DEFAULT 0  NOT NULL,
  ORICOD_LS     UL16       NULL,
  CREUSR_CF     UUPDUSR_CF NOT NULL,
  LSTUPD_D      UUPD_D     NOT NULL,
  LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
  ORICTR_NF     UCTR_NF    NULL,
  ORISEC_NF     USEC_NF    NULL,
  ORIUWY_NF     UUWY_NF    NULL,
  DIFF_M        UAMT_M     NULL,
  PROPAGATION_B bit        DEFAULT 0  NOT NULL,
  CALCULATED_B  bit        DEFAULT 0  NOT NULL,
  BATCH_B       bit        DEFAULT 0  NOT NULL
)
-- [MOD1] - END
-- [MOD7]
CREATE TABLE #MAXUWY
(
	CTR_NF		UCTR_NF				NOT NULL,
	SEC_NF		USEC_NF				NOT NULL,
	MAXUWY_NF	UUWY_NF				NULL,
	RETRO_B		bit		        DEFAULT 0	NOT NULL
)


SELECT @current_balshtyear = getdate(), @TYPPER = 'C'
EXECUTE @erreur = BREF..PsCALEND_02 @current_balshtyear, @TYPPER, @BLCSHTYEA_NF output, @BLCSHTMTH_NF output

INSERT INTO #EST_ESID0811_TLIFESTQ
SELECT 
  q.CTR_NF, q.END_NT, q.SEC_NF, q.UWY_NF, q.UW_NT, getdate() as CRE_D, @BLCSHTYEA_NF as BALSHEY_NF, @BLCSHTMTH_NF as BALSHTMTH_NF, 
  q.ACY_NF, q.GAAP_NT, q.DETTRNCOD_CF, q.ACM_NF, q.PRS_CF, q.ACMTRS_NT, q.SSD_CF, q.CUR_CF, q.ESTMNT_M, q.INDSUP_B, 
	CASE 
		WHEN @p_mode = 'A' THEN 'AutoLoadESIJ0810' 
		ELSE 'TP' 
	END AS ORICOD_LS, 
  q.CREUSR_CF, getdate() as LSTUPD_D, q.LSTUPDUSR_CF, q.ORICTR_NF, q.ORISEC_NF, q.ORIUWY_NF, q.DIFF_M, q.PROPAGATION_B, q.CALCULATED_B, q.BATCH_B,-- [MOD1]
   0, '', NULL -- [MOD7]
FROM 
  BTRAV..EST_ESID0811_TLIFESTQ Q
WHERE q.ACM_NF != 13

-- [MOD1] - START  
INSERT INTO 
  #EST_ESID0811_TLIFESTY
SELECT 
  d.*
FROM 
  BEST..TLIFEST d, #EST_ESID0811_TLIFESTQ q
WHERE 
  d.CTR_NF = q.CTR_NF AND d.END_NT = q.END_NT AND -- [MOD2] - START
  d.SEC_NF = q.SEC_NF AND d.UW_NT = q.UW_NT AND 
  d.BALSHEY_NF = q.BALSHEY_NF AND d.DETTRNCOD_CF = q.DETTRNCOD_CF -- [MOD2] - END
GROUP BY 
  d.CTR_NF,d.END_NT,d.SEC_NF,d.UWY_NF,d.UW_NT,d.BALSHEY_NF,d.ACY_NF,d.GAAP_NT,d.DETTRNCOD_CF
HAVING 
  d.CRE_D = MAX(d.CRE_D) 


UPDATE #EST_ESID0811_TLIFESTQ
SET  
  Q.SSD_CF = Y.SSD_CF,
  Q.INDSUP_B = Y.INDSUP_B,   
  Q.DIFF_M = Y.DIFF_M     
  --Q.PROPAGATION_B = Y.PROPAGATION_B
FROM 
  #EST_ESID0811_TLIFESTY Y, #EST_ESID0811_TLIFESTQ Q
WHERE 
  y.CTR_NF = q.CTR_NF AND y.END_NT = q.END_NT AND -- [MOD2] - START
  y.SEC_NF = q.SEC_NF  AND y.UW_NT = q.UW_NT AND 
  y.DETTRNCOD_CF = q.DETTRNCOD_CF -- [MOD2] - END
-- [MOD1] - END

SELECT @prs_cf = 500
-- [MOD7] -- START
-- Check for max uwy_nf Assumed
INSERT into #MAXUWY
SELECT
  SEC.CTR_NF as CTR_NF, 
  SEC.SEC_NF as SEC_NF,
  MAXUWY_NF = MAX(SEC.UWY_NF), 
  RETRO_B = 0
FROM #EST_ESID0811_TLIFESTQ LIFESTQ, BTRT..TSECTION SEC
WHERE SEC.CTR_NF	= LIFESTQ.CTR_NF 
  AND SEC.SEC_NF	= LIFESTQ.SEC_NF 

-- Check for max uwy_nf Retro
INSERT into #MAXUWY
SELECT
  RETSEC.RETCTR_NF as CTR_NF, 
  RETSEC.RETSEC_NF as SEC_NF,
  MAXUWY_NF = MAX(RETSEC.RTY_NF), 
  RETRO_B = 1
FROM #EST_ESID0811_TLIFESTQ LIFESTQ, BRET..TRETSEC RETSEC
WHERE RETSEC.RETCTR_NF	= LIFESTQ.CTR_NF 
  AND RETSEC.RETSEC_NF	= LIFESTQ.SEC_NF 

-- Fill RETRO_B and MAXUWY 
UPDATE #EST_ESID0811_TLIFESTQ
  SET RETRO_B = MAXUWY.RETRO_B,
      MAXUWY_NF = MAXUWY.MAXUWY_NF
FROM #EST_ESID0811_TLIFESTQ LIFESTQ, #MAXUWY MAXUWY
WHERE MAXUWY.CTR_NF = LIFESTQ.CTR_NF
  AND MAXUWY.SEC_NF = LIFESTQ.SEC_NF

-- Check for LOB_CF Assumed
UPDATE #EST_ESID0811_TLIFESTQ
  SET LOB_CF = SEC.LOB_CF
FROM #EST_ESID0811_TLIFESTQ LIFESTQ inner join BTRT..TSECTION SEC
  ON  SEC.CTR_NF = LIFESTQ.CTR_NF
  AND SEC.SEC_NF = LIFESTQ.SEC_NF 
  AND SEC.UWY_NF = (case when LIFESTQ.UWY_NF < LIFESTQ.MAXUWY_NF then LIFESTQ.UWY_NF else LIFESTQ.MAXUWY_NF end )
WHERE RETRO_B = 0

-- Check for LOB_CF Retro
UPDATE #EST_ESID0811_TLIFESTQ
  SET LOB_CF = RETSEC.LOB_CF
FROM #EST_ESID0811_TLIFESTQ LIFESTQ inner join BRET..TRETSEC RETSEC
  ON  RETSEC.RETCTR_NF = LIFESTQ.CTR_NF 
  AND RETSEC.RETSEC_NF = LIFESTQ.SEC_NF 
  AND RETSEC.RTY_NF = (case when LIFESTQ.UWY_NF < LIFESTQ.MAXUWY_NF then LIFESTQ.UWY_NF else LIFESTQ.MAXUWY_NF end )
WHERE RETRO_B = 1

-- Fill ACMTRS_CF Assumed 
UPDATE #EST_ESID0811_TLIFESTQ
SET
  Q.PRS_CF = ttr.PRS_CF,
  Q.ACMTRS_NT = ttr.ACMTRS_NT
FROM 
  #EST_ESID0811_TLIFESTQ Q, BREF..TTRSLNK ttr
WHERE
  Q.DETTRNCOD_CF = SUBSTRING(ttr.DETTRS_CF, 3, 5) 
  AND ttr.PRS_CF =  @prs_cf
  AND Q.RETRO_B = 0
  AND SUBSTRING(ttr.DETTRS_CF, 1, 1) = (case Q.LOB_CF when '30' then '3' when '31' then '1' end)
	
-- Fill ACMTRS_CF Retro 
UPDATE #EST_ESID0811_TLIFESTQ
SET
  Q.PRS_CF = ttr.PRS_CF,
  Q.ACMTRS_NT = ttr.ACMTRS_NT
FROM 
  #EST_ESID0811_TLIFESTQ Q, BREF..TTRSLNK ttr
WHERE
  Q.DETTRNCOD_CF = SUBSTRING(ttr.DETTRS_CF, 3, 5) 
  AND ttr.PRS_CF =  @prs_cf
  AND Q.RETRO_B = 1
  AND SUBSTRING(ttr.DETTRS_CF, 1, 1) = (case Q.LOB_CF when '30' then '4' when '31' then '2' end)
-- [MOD7] -- END

/* On supprime les positions d�j� existante dans la TLIFESTD pour �viter de les ins�rer une 2eme fois */	
DELETE 
  #EST_ESID0811_TLIFESTQ 
FROM 
  BEST..TLIFESTD d, #EST_ESID0811_TLIFESTQ q 
WHERE 
  d.CTR_NF=q.CTR_NF AND d.END_NT=q.END_NT AND 
  d.SEC_NF=q.SEC_NF AND d.UWY_NF=q.UWY_NF AND 
  d.UW_NT=q.UW_NT AND d.BALSHEY_NF=q.BALSHEY_NF AND 
  d.BALSHTMTH_NF=q.BALSHTMTH_NF AND d.ACY_NF=q.ACY_NF AND 
  d.GAAP_NT=q.GAAP_NT AND d.DETTRNCOD_CF=q.DETTRNCOD_CF AND 
  d.ACM_NF=q.ACM_NF AND d.SSD_CF=q.SSD_CF AND 
  d.CUR_CF=q.CUR_CF AND d.ESTMNT_M=q.ESTMNT_M
	
	
INSERT INTO BEST..TLIFESTD
SELECT 
	CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, GAAP_NT, DETTRNCOD_CF,
	ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF,
	ORICTR_NF, ORISEC_NF, ORIUWY_NF, DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B
FROM 
  #EST_ESID0811_TLIFESTQ
WHERE 
  ACM_NF != 13

if object_id('#EST_ESID0811_TLIFESTQ')     is not null drop table #EST_ESID0811_TLIFESTQ
if object_id('#EST_ESID0811_TLIFESTY')     is not null drop table #EST_ESID0811_TLIFESTY


return 0
go
EXEC sp_procxmode 'PuLIFEST_02_O2', 'unchained'
go
IF OBJECT_ID('PuLIFEST_02_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PuLIFEST_02_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PuLIFEST_02_O2 >>>'
go
GRANT EXECUTE ON PuLIFEST_02_O2 TO GOMEGA
go
GRANT EXECUTE ON PuLIFEST_02_O2 TO GDBBATCH
go
