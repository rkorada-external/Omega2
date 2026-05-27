USE BEST
go
IF OBJECT_ID('PiLIFEST_02_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PiLIFEST_02_O2
  IF OBJECT_ID('PiLIFEST_02_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE PiLIFEST_02_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE PiLIFEST_02_O2 >>>'
END
go

CREATE PROCEDURE PiLIFEST_02_O2 (
	@p_ssd_cf USSD_CF,
	@p_esb_cf UESB_CF,
	@p_usr_cf UUSR_CF
)
WITH EXECUTE AS CALLER AS

/****************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert
Creation date     : 05/10/2018
Description       : Apply agregation rules
_________________
Modification: [MOD1] 
Author: L. Wernert
Date: 26/12/2018
Description: Spira 73959 => [Apolo - QE] TLIFESTD - Remove the Field ACCFRQ_CT
_________________
Modification: [MOD2]
Author: T. Deutsch
Date: 
Description: Spira 73349 - Allow agregation on readable GAAP
_________________
Modification: [MOD3]
Author: L. Wernert
Date: 
Description: REQ.L.02.03 - Aggregation problem
_________________
Modification: [MOD4]
Author: L. Wernert
Date: 20/12/2019
Description: Spira 79964: Chargement de 3 trimestres ( 3,6, et 9), pas de constitution de réserves dans la grille
_________________
Modification: [MOD5]
Author: L. Wernert
Date: 08/04/2020
Description: Spira 82192: Adding criteria in the constitution of the scope (CREUSR_CF)
_________________
Modification: [MOD6]
Author: S. Behague
Date: 29/01/2021
Description: Spira 81638:APOLO QE / Estimates grid : la coche de propagation des postes de cash n'est pas cochée par défaut
_________________
Modification: [MOD7]
Author: T. DEUTSCH
Date: 27/09/2021
Description: Spira 90857:APOLO QE : Pas de maj de la grille suite à chargement et Status chargement faux
_________________
Modification: [MOD8]
Author: B. LAGHA
Date: 03/11/2021
Description: Spira 96721: Ajouter le SSD dans les resultat yearly (ACM_NF = 13)

*****************************************************/

CREATE TABLE #PERIMETER_SUBTRSESBPROP
(
  DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
  GAAP_NT       tinyint    NOT NULL,
  GAAPTRS_CT    tinyint    NOT NULL
)

-- [MOD1] - START
CREATE TABLE #PERIMETER
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

CREATE TABLE #LASTPOSITION
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

CREATE TABLE #ANALYTICS
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

-- Defined TRN COD readable perimeter according to GAAP

INSERT INTO #PERIMETER_SUBTRSESBPROP
SELECT 
  PCPTRS_CF+TRS_CF+SUBTRS_CF as 'DETTRNCOD_CF',1 as GAAP_NT, f.GAAP1TRS_CT as 'GAAPTRS_CT' 
FROM 
  BREF..TSUBTRSESBPROP f
WHERE SSD_CF=@p_ssd_cf AND ESB_CF=@p_esb_cf AND GAAP1TRS_CT=2
UNION
SELECT 
  PCPTRS_CF+TRS_CF+SUBTRS_CF as 'DETTRNCOD_CF',2 as GAAP_NT, f.GAAP2TRS_CT as 'GAAPTRS_CT' 
FROM 
  BREF..TSUBTRSESBPROP f
WHERE SSD_CF=@p_ssd_cf AND ESB_CF=@p_esb_cf AND GAAP2TRS_CT=2
UNION
SELECT 
  PCPTRS_CF+TRS_CF+SUBTRS_CF as 'DETTRNCOD_CF',3 as GAAP_NT, f.GAAP3TRS_CT as 'GAAPTRS_CT' 
FROM 
  BREF..TSUBTRSESBPROP f
WHERE SSD_CF=@p_ssd_cf AND ESB_CF=@p_esb_cf AND GAAP3TRS_CT=2
UNION
SELECT 
  PCPTRS_CF+TRS_CF+SUBTRS_CF as 'DETTRNCOD_CF',4 as GAAP_NT, f.GAAP4TRS_CT as 'GAAPTRS_CT' 
FROM 
  BREF..TSUBTRSESBPROP f
WHERE SSD_CF=@p_ssd_cf AND ESB_CF=@p_esb_cf AND GAAP4TRS_CT=2
UNION
SELECT 
  PCPTRS_CF+TRS_CF+SUBTRS_CF as 'DETTRNCOD_CF',5 as GAAP_NT, f.GAAP5TRS_CT as 'GAAPTRS_CT' 
FROM 
  BREF..TSUBTRSESBPROP f
WHERE SSD_CF=@p_ssd_cf AND ESB_CF=@p_esb_cf AND GAAP5TRS_CT=2
ORDER BY 
  DETTRNCOD_CF, GAAP_NT, GAAPTRS_CT

-- [MOD7] - START
-- Set current date of uploaded data
update BTRAV..EST_ESID0811_TLIFESTQ set CRE_D=getdate() WHERE ACM_NF <> 13 
-- [MOD7] - END

-- Extending the scope with corresponding quarters
INSERT INTO #PERIMETER
SELECT * 
FROM 
  BTRAV..EST_ESID0811_TLIFESTQ q 
WHERE 
  ACM_NF <> 13 
UNION
SELECT d.* 
FROM 
  BEST..TLIFESTD d, BTRAV..EST_ESID0811_TLIFESTQ q
WHERE 
  d.CTR_NF = q.CTR_NF AND 
  d.END_NT = q.END_NT AND 
  d.SEC_NF = q.SEC_NF AND 
  d.UWY_NF = q.UWY_NF AND 
  d.UW_NT = q.UW_NT AND 
  d.ACY_NF = q.ACY_NF AND 
  d.GAAP_NT = q.GAAP_NT AND 
  d.DETTRNCOD_CF = q.DETTRNCOD_CF AND
  d.CREUSR_CF = q.CREUSR_CF AND 
  d.SSD_CF = q.SSD_CF

-- Delete TRN COD which are read only according to GAAP in order to avoid creating Aggregated values

/* -- [MOD2] 73349 : Allow aggregation on GAAP READABLE --
DELETE #PERIMETER 
FROM #PERIMETER a, #PERIMETER_SUBTRSESBPROP b
WHERE a.DETTRNCOD_CF=B.DETTRNCOD_CF AND a.GAAP_NT=B.GAAP_NT
*/

-- Keeping most recent positions for each quarter (previously and newly loaded) in a temporary table
INSERT INTO #LASTPOSITION
SELECT * 
FROM 
  #PERIMETER 
GROUP BY 
  CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,ACY_NF,ACM_NF,GAAP_NT,DETTRNCOD_CF
HAVING CRE_D = MAX(CRE_D) 

-- [MOD1] - START
-- CASH/FLOW: Most recent positions of each quarter are summed
-- ACM_NF = 13 / ESTMNT_M: sum of all corresponding quarters 
INSERT INTO BTRAV..EST_ESID0811_TLIFESTQ
SELECT DISTINCT 
  CTR_NF, 0, SEC_NF, UWY_NF, 1, getdate(), 0, 0, ACY_NF, GAAP_NT, 
  DETTRNCOD_CF, 13 as ACM_NF, 0, 0, SSD_CF, CUR_CF, sum(ESTMNT_M) as ESTMNT_M, 
  0, '', @p_usr_cf, getdate(), @p_usr_cf, '', 0, 0, 0, PROPAGATION_B, 0, 0 -- [MOD3]
FROM 
  #LASTPOSITION
WHERE DETTRNCOD_CF IN (SELECT PCPTRS_CF + TRS_CF + SUBTRS_CF 
                       FROM BREF..TSUBTRS 
                       WHERE TRSTYPE_CT IN (1,2,5))

GROUP BY 
  CTR_NF,SEC_NF,UWY_NF,ACY_NF,GAAP_NT,DETTRNCOD_CF,CUR_CF


-- RESERVES/DEPOSIT/BALANCE: No 4th quarter (12) currently loading
-- A new line is created with an ACM_NF = 13 and an estimate amount setted at the value of the biggest quarter [MOD4]
-- ACM_NF = 13 / ESTMNT_M = ESTMNT_M of the biggest quarter 
SELECT * 
	INTO #PENULTIMATE_QUARTER
FROM 
	(SELECT 
		CTR_NF, SEC_NF, BALSHEY_NF, BALSHTMTH_NF, GAAP_NT, 
		DETTRNCOD_CF, ACY_NF, UWY_NF, ACM_NF, CUR_CF, ESTMNT_M, PROPAGATION_B
  FROM 
		#LASTPOSITION
	WHERE
		DETTRNCOD_CF IN (SELECT PCPTRS_CF + TRS_CF + SUBTRS_CF 
	                  FROM BREF..TSUBTRS 
	                  WHERE TRSTYPE_CT IN (3,4,6))
  GROUP BY 
		CTR_NF, SEC_NF, BALSHEY_NF, BALSHTMTH_NF, 
		GAAP_NT, DETTRNCOD_CF, ACY_NF, UWY_NF, CUR_CF
  /* HAVING 
		ACM_NF <> 12 */) TMP_Q
GROUP BY 
	TMP_Q.CTR_NF, TMP_Q.SEC_NF, TMP_Q.BALSHEY_NF, TMP_Q.BALSHTMTH_NF, TMP_Q.GAAP_NT, 
	TMP_Q.DETTRNCOD_CF, TMP_Q.ACY_NF, TMP_Q.UWY_NF, TMP_Q.CUR_CF
HAVING 
	TMP_Q.ACM_NF = MAX(TMP_Q.ACM_NF)

/* UPDATE 
	#LASTPOSITION
SET 
	ESTMNT_M = penQ.ESTMNT_M
FROM 
	#LASTPOSITION lastP, #PENULTIMATE_QUARTER penQ
WHERE
	lastP.CTR_NF = penQ.CTR_NF AND
	lastP.SEC_NF = penQ.SEC_NF AND
	lastP.BALSHEY_NF = penQ.BALSHEY_NF AND
	lastP.BALSHTMTH_NF = penQ.BALSHTMTH_NF AND
	lastP.GAAP_NT = penQ.GAAP_NT AND
	lastP.DETTRNCOD_CF = penQ.DETTRNCOD_CF AND
	lastP.ACY_NF = penQ.ACY_NF AND
	lastP.UWY_NF = penQ.UWY_NF AND
	lastP.CUR_CF = penQ.CUR_CF
*/
	
INSERT INTO #ANALYTICS
SELECT DISTINCT 
  lastP.CTR_NF, 0, lastP.SEC_NF, lastP.UWY_NF, 1, getdate(), 0, 0, lastP.ACY_NF, lastP.GAAP_NT, 
  lastP.DETTRNCOD_CF, 13 as ACM_NF, 0, 0, lastP.SSD_CF, lastP.CUR_CF, lastP.ESTMNT_M, 
  0, '', @p_usr_cf, getdate(), @p_usr_cf, '', 0, 0, 0, penQ.PROPAGATION_B, 0, 0 -- [MOD3]
FROM 
  #LASTPOSITION lastP, #PENULTIMATE_QUARTER penQ -- [MOD3]
WHERE 
  lastP.DETTRNCOD_CF IN (SELECT PCPTRS_CF + TRS_CF + SUBTRS_CF -- [MOD3] 
                  FROM BREF..TSUBTRS 
                  WHERE TRSTYPE_CT IN (3,4,6)) AND 
  -- ACM_NF <> 12 -- [MOD3] 
    lastP.CTR_NF = penQ.CTR_NF AND
	lastP.SEC_NF = penQ.SEC_NF AND
	lastP.BALSHEY_NF = penQ.BALSHEY_NF AND
	lastP.BALSHTMTH_NF = penQ.BALSHTMTH_NF AND
	lastP.GAAP_NT = penQ.GAAP_NT AND
	lastP.DETTRNCOD_CF = penQ.DETTRNCOD_CF AND
	lastP.ACY_NF = penQ.ACY_NF AND
	lastP.ACM_NF = penQ.ACM_NF AND -- [MOD3] 
	lastP.UWY_NF = penQ.UWY_NF AND
	lastP.CUR_CF = penQ.CUR_CF
GROUP BY 
  lastP.CTR_NF, lastP.SEC_NF, lastP.UWY_NF, lastP.ACY_NF, lastP.GAAP_NT, lastP.DETTRNCOD_CF, lastP.CUR_CF, lastP.ACM_NF

/*
-- RESERVES/DEPOSIT/BALANCE: 4th quarter (12). 
-- A new line is created with an ACM_NF = 13 and takes the estimate amount of the 4th quarter  
-- ACM_NF = 13 / ESTMNT_M = ESTMNT_M
INSERT INTO #ANALYTICS
SELECT DISTINCT 
  CTR_NF, 0, SEC_NF, UWY_NF, 1, getdate(), 0, 0, ACY_NF, GAAP_NT, 
  DETTRNCOD_CF, 13 as ACM_NF, 0, 0, 0, CUR_CF, ESTMNT_M, 
  0, '', @p_usr_cf, getdate(), @p_usr_cf, '', 0, 0, 0, 0, 0, 0 -- [MOD3]
FROM 
  #LASTPOSITION
WHERE 
  DETTRNCOD_CF IN (SELECT PCPTRS_CF + TRS_CF + SUBTRS_CF 
                  FROM BREF..TSUBTRS 
                  WHERE TRSTYPE_CT IN (3,4,6)) AND 
  ACM_NF = 12
GROUP BY 
  CTR_NF,SEC_NF,UWY_NF,ACY_NF,GAAP_NT,DETTRNCOD_CF,CUR_CF,ACM_NF
*/

/* Sur les cas des analytics on somme toutes les positions stockées sur 13 pour conserver que la valeur du mois 12 car on a mis les mois trim precdedent à 0 */
INSERT INTO BTRAV..EST_ESID0811_TLIFESTQ
SELECT DISTINCT 
  CTR_NF, 0, SEC_NF, UWY_NF, 1, getdate(), 0, 0, ACY_NF, GAAP_NT, 
  DETTRNCOD_CF, ACM_NF, 0, 0, SSD_CF, CUR_CF, sum(ESTMNT_M) as ESTMNT_M, 
  0, '', CREUSR_CF, getdate(), LSTUPDUSR_CF, '', 0, 0, 0, PROPAGATION_B, 0, 0
FROM 
  #ANALYTICS
GROUP BY 
  CTR_NF,SEC_NF,UWY_NF,ACY_NF,GAAP_NT,DETTRNCOD_CF,CUR_CF

-- [MOD1] - END

/*----------------------------------*/
/* Delete temporary tables          */
/*----------------------------------*/

IF object_id('#LASTPOSITION') IS NOT NULL DROP TABLE #LASTPOSITION
IF object_id('#PERIMETER') IS NOT NULL DROP TABLE #PERIMETER
IF object_id('#ANALYTICS') IS NOT NULL DROP TABLE #ANALYTICS
IF object_id('#PERIMETER_SUBTRSESBPROP') IS NOT NULL DROP TABLE #PERIMETER_SUBTRSESBPROP
IF object_id('#PENULTIMATE_QUARTER') IS NOT NULL DROP TABLE #PENULTIMATE_QUARTER

return 0
go
EXEC sp_procxmode 'PiLIFEST_02_O2', 'unchained'
go
IF OBJECT_ID('PiLIFEST_02_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PiLIFEST_02_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PiLIFEST_02_O2 >>>'
go
GRANT EXECUTE ON PiLIFEST_02_O2 TO GOMEGA
go
GRANT EXECUTE ON PiLIFEST_02_O2 TO GDBBATCH
go
