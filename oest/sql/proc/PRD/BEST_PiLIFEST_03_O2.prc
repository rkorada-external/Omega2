USE BEST
go
IF OBJECT_ID('PiLIFEST_03_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PiLIFEST_03_O2
    IF OBJECT_ID('PiLIFEST_03_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PiLIFEST_03_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PiLIFEST_03_O2 >>>'
END
go

CREATE PROCEDURE PiLIFEST_03_O2 
WITH EXECUTE AS CALLER AS
/****************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert
Creation date     : 05/10/2018
Description       : Apply Beginning and Ending
_________________
Modification: [MOD1] 
Author: L. Wernert
Date: 26/12/2018
Description: Spira 73959 => [Apolo - QE] TLIFESTD - Remove the Field ACCFRQ_CT 
_________________
Modification: [MOD2] 
Author: B. LAGHA
Date: 18/11/2019
Description: Spira 82272 => [Apolo - QE] TLIFESTD - Release calculation in case of UWY doesn't exist in TCONTR and TSECTION tables 

*****************************************************/
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
-- [MOD1] - END

/* On insert dans la table perimetre les positions trimestrielles des postes de Reserves TRSTYPE_CT IN (3,4,6))*/
INSERT INTO #PERIMETER
SELECT * FROM BTRAV..EST_ESID0811_TLIFESTQ 
WHERE ACM_NF <> 13 
AND DETTRNCOD_CF IN (SELECT PCPTRS_CF + TRS_CF + SUBTRS_CF 
                      FROM BREF..TSUBTRS 
                      WHERE TRSTYPE_CT IN (3,4,6))


/* Type 1 = Calcul des lib?rations sur ACY+1 / UWY+1 lorsque mois 12 */
INSERT INTO BTRAV..EST_ESID0811_TLIFESTQ 
SELECT DISTINCT p.CTR_NF, p.END_NT, p.SEC_NF,
CASE WHEN p.ACM_NF = 12 
  THEN p.UWY_NF + 1 
  ELSE p.UWY_NF END as 'UWY_NF', 
p.UW_NT, p.CRE_D,p.BALSHEY_NF, p.BALSHTMTH_NF,
CASE WHEN p.ACM_NF = 12 
  THEN p.ACY_NF + 1 
  ELSE p.ACY_NF END as 'ACY_NF', 
p.GAAP_NT, a.DETTRNCOD2_CF,
CASE WHEN p.ACM_NF = 12 
  THEN 3 
  ELSE p.ACM_NF + 3 END as 'ACM_NF',
p.PRS_CF, p.ACMTRS_NT, p.SSD_CF, p.CUR_CF, -p.ESTMNT_M as 'ESTMNT_M', 
p.INDSUP_B, p.ORICOD_LS, p.CREUSR_CF, p.LSTUPD_D, p.LSTUPDUSR_CF, p.ORICTR_NF, p.ORISEC_NF, 
p.ORIUWY_NF, p.DIFF_M, p.PROPAGATION_B, p.CALCULATED_B, p.BATCH_B -- [MOD1]
FROM 
  #PERIMETER p
LEFT OUTER JOIN 
  BTRT..TSECTION tsec ON p.CTR_NF = tsec.CTR_NF AND p.UWY_NF=tsec.UWY_NF AND p.SEC_NF=tsec.SEC_NF
LEFT OUTER JOIN 
  BRET..TRETCTR tret ON p.CTR_NF = tret.RETCTR_NF AND p.UWY_NF=tret.RTY_NF
LEFT OUTER JOIN 
  BREF..TSUBTRSASSO a ON p.DETTRNCOD_CF=a.DETTRNCOD1_CF
WHERE a.ASSOTYP_CT='1' AND a.CTX_NT=1 AND 
CASE 
WHEN tsec.CTR_NF IS NOT NULL THEN tsec.ACCADMTYP_CT 
-- [MOD2] BEGIN --
WHEN tsec.CTR_NF IS NULL AND p.CTR_NF in (select distinct T.CTR_NF from BTRT..TSECTION T) THEN
  (SELECT ACCADMTYP_CT FROM BTRT..TSECTION T1
   WHERE T1.CTR_NF =  p.CTR_NF
   AND   T1.SEC_NF =  p.SEC_NF
   AND   T1.UWY_NF = (SELECT MAX(ts.UWY_NF) FROM BTRT..TSECTION ts WHERE ts.CTR_NF = p.CTR_NF AND ts.SEC_NF =  p.SEC_NF))
-- [MOD2] END   --
ELSE tret.RETACCTYP_CT END = 1
  
/* Type <> 1 : Calcul des libérations sur ACY+1 UWY+1 lorsque mois 12 */

INSERT INTO BTRAV..EST_ESID0811_TLIFESTQ 
SELECT DISTINCT p.CTR_NF, p.END_NT, p.SEC_NF, p.UWY_NF, p.UW_NT, p.CRE_D,p.BALSHEY_NF, p.BALSHTMTH_NF,
CASE WHEN p.ACM_NF = 12 
  THEN p.ACY_NF+1
  ELSE p.ACY_NF END as 'ACY_NF',
p.GAAP_NT, a.DETTRNCOD2_CF, 
CASE WHEN p.ACM_NF = 12 
  THEN 3 
  ELSE p.ACM_NF + 3 END as 'ACM_NF',
p.PRS_CF, p.ACMTRS_NT, p.SSD_CF, p.CUR_CF, -p.ESTMNT_M as 'ESTMNT_M', 
p.INDSUP_B, p.ORICOD_LS, p.CREUSR_CF, p.LSTUPD_D, p.LSTUPDUSR_CF, p.ORICTR_NF, p.ORISEC_NF, p.ORIUWY_NF, p.DIFF_M, p.PROPAGATION_B, p.CALCULATED_B, p.BATCH_B -- [MOD1]
FROM 
  #PERIMETER p
LEFT OUTER JOIN 
  BTRT..TSECTION tsec ON p.CTR_NF = tsec.CTR_NF AND p.UWY_NF=tsec.UWY_NF AND p.SEC_NF=tsec.SEC_NF
LEFT OUTER JOIN 
  BRET..TRETCTR tret ON p.CTR_NF = tret.RETCTR_NF AND p.UWY_NF=tret.RTY_NF
LEFT OUTER JOIN 
  BREF..TSUBTRSASSO a ON p.DETTRNCOD_CF=a.DETTRNCOD1_CF
WHERE a.ASSOTYP_CT='1' AND a.CTX_NT=1 AND
CASE
WHEN tsec.CTR_NF IS NOT NULL THEN tsec.ACCADMTYP_CT 
-- [MOD2] BEGIN --
WHEN tsec.CTR_NF IS NULL AND p.CTR_NF in (select distinct T.CTR_NF from BTRT..TSECTION T) THEN
  (SELECT ACCADMTYP_CT FROM BTRT..TSECTION T1
   WHERE T1.CTR_NF =  p.CTR_NF
   AND   T1.SEC_NF =  p.SEC_NF
   AND   T1.UWY_NF = (SELECT MAX(ts.UWY_NF) FROM BTRT..TSECTION ts WHERE ts.CTR_NF = p.CTR_NF AND ts.SEC_NF =  p.SEC_NF))
-- [MOD2] END   --
ELSE tret.RETACCTYP_CT END <> 1


/*--------------------------------------------------*/
/* Destruction des tables temporaires               */
/*--------------------------------------------------*/

IF object_id('#PERIMETER') IS NOT NULL DROP TABLE #PERIMETER

return 0
go
EXEC sp_procxmode 'PiLIFEST_03_O2', 'unchained'
go
IF OBJECT_ID('PiLIFEST_03_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PiLIFEST_03_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PiLIFEST_03_O2 >>>'
go
GRANT EXECUTE ON PiLIFEST_03_O2 TO GOMEGA
go
GRANT EXECUTE ON PiLIFEST_03_O2 TO GDBBATCH
go
