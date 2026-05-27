USE BEST
go
IF OBJECT_ID('PiLIFEST_05_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PiLIFEST_05_O2
  IF OBJECT_ID('PiLIFEST_05_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE PiLIFEST_05_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE PiLIFEST_05_O2 >>>'
END
go

CREATE PROCEDURE PiLIFEST_05_O2 (
	@p_ssd_cf USSD_CF,
	@p_esb_cf UESB_CF,
	@p_usr_cf UUSR_CF
)
WITH EXECUTE AS CALLER AS

/****************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : S.Behague
Creation date     : 19/11/2020
Description       : Apply gaap propagation on cash code
_________________
[001] - 17/12/2020 S.Behague:spira 81643: APOLO QE : Propagation des postes de cash à partir des valeurs chargées en Cedent GAAP
        11/01/2021 S.Behague:spira 81638: APOLO QE / Estimates grid : la coche de propagation des postes de cash n'est pas cochée par défaut

[002] - 12/10/2021 B.Lagha  :spira 98280: propagation des postes analytics à partir des valeurs chargees en gaap cedent.
*****************************************************/

CREATE TABLE #PERIMETER_SUBTRSCASH
(
  DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
  TRSTYPE_CT    tinyint    NOT NULL
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



-- Recuperation des postes cash

INSERT INTO #PERIMETER_SUBTRSCASH
SELECT 
  PCPTRS_CF+TRS_CF+SUBTRS_CF as 'DETTRNCOD_CF', TRSTYPE_CT 
FROM
  BREF..TSUBTRS
WHERE TRSTYPE_CT = 1

-- [002] - START 
-- Recuperation des postes Analytics (FLOW / BALANCE)
INSERT INTO #PERIMETER_SUBTRSCASH
SELECT 
  PCPTRS_CF+TRS_CF+SUBTRS_CF as 'DETTRNCOD_CF', TRSTYPE_CT 
FROM
  BREF..TSUBTRS
WHERE TRSTYPE_CT IN (5,6)
-- [002] - END 


-- Multiplication des gaap des postes cash / analytics
INSERT INTO #PERIMETER
select CTR_NF,	END_NT,	SEC_NF,	UWY_NF, UW_NT, CRE_D,	BALSHEY_NF,	BALSHTMTH_NF,	ACY_NF,	2 as gaap_nt, lif.DETTRNCOD_CF, ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ORICTR_NF, ORISEC_NF, ORIUWY_NF, DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B
from btrav..EST_ESID0811_TLIFESTQ lif, #PERIMETER_SUBTRSCASH trs
where trs.dettrncod_cf=lif.DETTRNCOD_CF
and gaap_nt = 1
and ACM_NF <> 13
INSERT INTO #PERIMETER
select CTR_NF,	END_NT,	SEC_NF,	UWY_NF, UW_NT, CRE_D,	BALSHEY_NF,	BALSHTMTH_NF,	ACY_NF,	3 as gaap_nt, lif.DETTRNCOD_CF, ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ORICTR_NF, ORISEC_NF, ORIUWY_NF, DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B
from btrav..EST_ESID0811_TLIFESTQ lif, #PERIMETER_SUBTRSCASH trs
where trs.dettrncod_cf=lif.DETTRNCOD_CF
and gaap_nt = 1 
and ACM_NF <> 13
INSERT INTO #PERIMETER
select CTR_NF,	END_NT,	SEC_NF,	UWY_NF, UW_NT, CRE_D,	BALSHEY_NF,	BALSHTMTH_NF,	ACY_NF,	4 as gaap_nt, lif.DETTRNCOD_CF, ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ORICTR_NF, ORISEC_NF, ORIUWY_NF, DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B
from btrav..EST_ESID0811_TLIFESTQ lif, #PERIMETER_SUBTRSCASH trs
where trs.dettrncod_cf=lif.DETTRNCOD_CF
and gaap_nt = 1
and ACM_NF <> 13
INSERT INTO #PERIMETER
select CTR_NF,	END_NT,	SEC_NF,	UWY_NF, UW_NT, CRE_D,	BALSHEY_NF,	BALSHTMTH_NF,	ACY_NF,	5 as gaap_nt, lif.DETTRNCOD_CF, ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ORICTR_NF, ORISEC_NF, ORIUWY_NF, DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B
from btrav..EST_ESID0811_TLIFESTQ lif, #PERIMETER_SUBTRSCASH trs
where trs.dettrncod_cf=lif.DETTRNCOD_CF
and gaap_nt = 1
and ACM_NF <> 13

-- insertion de tous les gaap des postes cash
INSERT INTO btrav..EST_ESID0811_TLIFESTQ
select * from #PERIMETER

-- Mise à 1 du flag PROPAGATION_B pour les postes cash
UPDATE btrav..EST_ESID0811_TLIFESTQ 
SET PROPAGATION_B = 1
FROM btrav..EST_ESID0811_TLIFESTQ lif, #PERIMETER_SUBTRSCASH trs
WHERE trs.dettrncod_cf=lif.DETTRNCOD_CF
AND ACM_NF <> 13


/*----------------------------------*/
/* Delete temporary tables          */
/*----------------------------------*/

IF object_id('#PERIMETER_SUBTRSCASH') IS NOT NULL DROP TABLE #PERIMETER_SUBTRSCASH
IF object_id('#PERIMETER') IS NOT NULL DROP TABLE #PERIMETER


return 0
go
EXEC sp_procxmode 'PiLIFEST_05_O2', 'unchained'
go
IF OBJECT_ID('PiLIFEST_05_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PiLIFEST_05_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PiLIFEST_05_O2 >>>'
go
GRANT EXECUTE ON PiLIFEST_05_O2 TO GOMEGA
go
GRANT EXECUTE ON PiLIFEST_05_O2 TO GDBBATCH
go
