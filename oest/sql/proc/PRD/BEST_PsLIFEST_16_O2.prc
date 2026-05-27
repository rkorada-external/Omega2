USE BEST
go

IF OBJECT_ID('PsLIFEST_16_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PsLIFEST_16_O2
  IF OBJECT_ID('PsLIFEST_16_O2') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE PsLIFEST_16_O2 >>>'
  ELSE
		PRINT '<<< DROPPED PROCEDURE PsLIFEST_16_O2 >>>'
END
go
/*
 * creation de la procedure
 */
create procedure PsLIFEST_16_O2 (
  @p_ssd_cf       USSD_CF,
  @p_esb_cf       UESB_CF,
  @p_usr_cf       UUSR_CF,
	@p_run_mode		char(1)
)
with execute as caller as

declare @BLCSHTYEA_NF  Smallint,
@TYPPER             Char(1),    -- type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)
@DATE               Datetime,
@p_terctrB 			bit			--MODIF 4


/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : C. Cros
Creation date     : 12/12/2013

Description       :  Update ACCADMTYP and RETROB for 
_________________
MODIFICATION 1
Auteur:       Pierre Colee
Date:         1 Aug 2014
Version: 2
Description:  Syslog issue resolved by adding group by
_________________
MODIFICATION 2
Auteur:       Amit D
Date:         23 JAN 2015
Version: 3
Description:  033922 - Estimation errors list : loading after loading the errors stay in the list
_________________
MODIFICATION 2
Auteur:       Amit D
Date:         17 JUNE 2015
Version: 4
Description:  037667 - SII - possibility to enter Estimates manually on the cedent GAAP of a Model treaty
_________________
MODIFICATION 3
Auteur:       Amit D
Date:         07 JULY 2015
Version: 5
Description:  034897 - EST24BT : Not posssible to load estimates when the IO GAAP = Manual
_________________
MODIFICATION 4
Auteur:       Gaurav P
Date:         06 AUGUST 2015
Version: 6
Description:  EXT-ESTLIFE-806639 - Improvments on Retro Life Estimates ( EST 29 ) 
_________________
MODIFICATION 5
Auteur:       Sumit Gupta
Date:         20 April 2016
Version: 7
Description:  48669 - File upload : no checking of data validity ( UWY / ACY) => partial loading
_________________
MODIFICATION 6
Auteur:       Sumit Gupta
Date:         18 May 2016
Version: 8
Description:  050215 - File upload : Not possible to load estimates on UWY > last UWY of treaty not cancelled, accounting type = 2
_________________
MODIFICATION 7
Auteur:       Sumit Gupta
Date:         27 May 2016
Version: 9
Description:  49827 - Upload file won't load all lines without error message to the users 
_________________
MODIFICATION 8
Auteur:       Riyadh
Date:         1 DEC 2016
Version: 10
Description:  SPIRA 55539 - Chargement estimations : Texte du message inappropri?

_________________
MODIFICATION 9
Auteur:       Dimitry
Date:         18 APRIL 2018
Version: 11
Description:  SPIRA 62225 - Chargement estimations : Ledger diff?rent entre celui du trait? ? modifier et celui de l'?cran

_________________
MODIFICATION 10 - [MOD10]
Auteur:       L. Wernert
Date:         27 Sep 2018
Version: 12
Description: Add new controls to handle quarterly estimates (error codes: 5032, 5033, 5034, 5035)
_________________
MODIFICATION 11 - [MOD11]
Auteur:       Riyadh
Date:         26/02/2019
Version: 13
Description: APOLO/ QE : Chargement d'estimations trimestrielles sur traité provisoire quaterly 73930
_________________
MODIFICATION 12 - [MOD12]
Auteur:       Riyadh
Date:         19/07/2019
Version: 14
Description: Spira 79622
_________________
MODIFICATION 13
Auteur:       L. Wernert
Date:         20/09/2019
Version: 			14
Description: Spira 78745: File upload / Yearly : Référence des anomalies ne correspond aux lignes du fichier
_________________
MODIFICATION 14
Auteur:       S. Brethous
Date:         28/02/2020
Version: 			15
Description: EMERGENCY DELIVERY 85152
_________________
MODIFICATION 15
Auteur:       T. DEUTSCH
Date:         30/03/2020
Version: 			16
Description: EMERGENCY DELIVERY 85110
_________________
MODIFICATION 16
Auteur:       L. WERNERT
Date:         08/04/2020
Version: 			17
Description: 82192: disable [100] controls for the automatic estimate file upload
_________________
MODIFICATION 17
Auteur:       L. WERNERT
Date:         24/11/2020
Version: 			18
Description: 91873: enable [5034] controls for the automatic estimate file upload
_________________
MODIFICATION 18
Auteur:       B. LAGHA
Date:         17/12/2020
Version:      19
Description:  74857: Chargement des estimations sur exercice inexistant => blocage
_________________
MODIFICATION 19
Auteur:       S. BEHAGUE
Date:         06/1/2021
Version:      19
Description:  81643: APOLO QE : Propagation des postes de cash à partir des valeurs chargées en Cedent GAAP
_________________
MODIFICATION 20
Auteur:       L. Wernert
Date:         15/01/2021
Version:      20
Description:  92307: APOLO QE : Incohérences entre fichier de chargement/Grille et Extraction BO (Estim et accruals manquants)
_________________
MODIFICATION 21
Auteur:       B. Lagha
Date:         08/02/2021
Version:      21
Description:  67721: File upload : Avoir toutes les anomalies en 1 seul retour suite au 1er controle de chargement

*****************************************************/

/* Step 1 : Match the perimeter with the contract in Btrt with same ctr/sec/uwy */
/* Step 1.a for assumed contracts */
update BTRAV..EST_ESID0811_PERIMETER 
	SET 
    EXISTSINDB_CT = 1,
    ACCADMTYP_CT  = s.ACCADMTYP_CT, 
    RETRO_B = 0,
    SECTIONSSD_CF = s.SSD_CF,
    SECTIONESB_CF = @p_esb_cf,
    PROCE = 
    CASE WHEN  (s.ACCADMTYP_CT = 2 OR s.ACCADMTYP_CT = 3 OR s.ACCADMTYP_CT = 5) THEN 4 ELSE 3 END  
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE 	t.CTR_NF = s.CTR_NF 
	AND t.SEC_NF = s.SEC_NF 
	AND t.UWY_NF = s.UWY_NF
	AND t.SSD_CF = @p_ssd_cf
	AND t.ESB_CF = @p_esb_cf
	AND t.USR_CF = @p_usr_cf
	AND s.END_NT = 0 /* Endorsement number */
	AND s.UW_NT  = 1 /* Underwriting order */
	AND s.SEC_NF = t.SEC_NF 
	AND s.SECSTS_CT in (3,14,16,17,19) /* Section has the rights to have estimations */
	AND t.SSD_CF = @p_ssd_cf
	AND t.ESB_CF = @p_esb_cf
	AND t.USR_CF = @p_usr_cf


/* Step 1.b for retro contracts */
update BTRAV..EST_ESID0811_PERIMETER 
	SET 
    EXISTSINDB_CT = 1,
    ACCADMTYP_CT  = s.RETACCTYP_CT, 
    RETRO_B = 1,
    SECTIONSSD_CF = s.SSD_CF,
    SECTIONESB_CF = @p_esb_cf,
    PROCE = 
    CASE WHEN  (s.RETACCTYP_CT = 2 OR s.RETACCTYP_CT = 3 OR s.RETACCTYP_CT = 5) THEN 4 ELSE 3 END 
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETCTR s
WHERE 	t.CTR_NF = s.RETCTR_NF 
	AND t.UWY_NF = s.RTY_NF
	AND s.RETCTRSTS_CT in (3,19)
    AND s.CONRETCTR_B != 1
	AND t.SSD_CF = @p_ssd_cf
	AND t.ESB_CF = @p_esb_cf
	AND t.USR_CF = @p_usr_cf
	
/* Step 2 : the last UWY is useful for 2 reasons */
/* * Some contract have no uwy, or no uwy in the DB, we need to find the last UWY (max(UWY)) of the DB TRT..TSECTION for each of those contract (2.b)  */
/* * We need to test some properties on the last UWY treaty to raise some specific errors */
/* 2.a fill MAXUWY */
/* 2.b set infos when UWY do not exists */

/** [MOD21] - part 1 - START **/
/* create temporary table to anomalies */
CREATE TABLE #EST_ESID0811_PERIMETER_ANO (
  CTR_NF UCTR_NF not null,
  SEC_NF USEC_NF not null,
  UWY_NF UUWY_NF not null,
  ACM_NF UUW_NT not null,
  ACY_NF UUWY_NF not null,
  NUMLINE_NT int default 0  null,
  END_NT UEND_NT not null,
  UW_NT UUW_NT not null,
  SSD_CF USSD_CF not null,
  ESB_CF UESB_CF not null,
  USR_CF UUSR_CF not null,
  GAAP_NT tinyint not null,
  DETTRNCOD_CF char(5) default ''  not null,
  ACCADMTYP_CT UACCADMTYP_CT null,
  RETRO_B bit default 0  not null,
  PROCE smallint not null,
  MAXUWY_NF UUWY_NF null,
  EXISTSINDB_CT int null,
  SECTIONSSD_CF USSD_CF null,
  SECTIONESB_CF UESB_CF null,
  ERRORCODE_CT int null
)
/** [MOD21] - part 1 - END  **/

/* we use a temporary table to get the maxuwy for each contract*/ --2
CREATE TABLE #maxuwy
(
    CTR_NF        UCTR_NF       NOT NULL,
    SEC_NF        USEC_NF       NOT NULL,
    MAXUWY_NF     UUWY_NF       NULL,
    RETRO_B       bit           DEFAULT 0 NOT NULL,
    PROCE         smallint      DEFAULT 0 NOT NULL,
)

/* 2.a.1 fill MAXUWY from BTRT for assumed contracts */

-- MODIFICATION 14 : EMERGENCY Delivery : SPIRA 85152 Add Disctint and remove group by on ACCADMTYP
INSERT into #maxuwy  --2
SELECT  DISTINCT
    s.CTR_NF as CTR_NF, 
    s.SEC_NF as SEC_NF,
    MAXUWY_NF = MAX(s.UWY_NF), 
    RETRO_B = 0,
    PROCE = CASE WHEN (s.ACCADMTYP_CT = 2 OR s.ACCADMTYP_CT = 3 OR s.ACCADMTYP_CT = 5) THEN 4 ELSE 3 END 
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE s.SEC_NF = t.SEC_NF 
 AND  s.CTR_NF = t.CTR_NF 
-- AND  t.UWY_NF = s.UWY_NF
 AND  s.END_NT = 0 /* Endorsement number */
 AND  s.UW_NT  = 1 /* Underwriting order */
 AND  s.SECSTS_CT IN (14,16,17,19)/* Section has the rights to have estimations */
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
GROUP BY PROCE, RETRO_B, s.SEC_NF, s.CTR_NF  
HAVING s.UWY_NF = max(s.UWY_NF) -- Emergency delivery [15]
ORDER BY MAXUWY_NF desc --MODIF 5 --Mod 7

/* 2.a.2 fill MAXUWY from BRET for retro contracts */

INSERT into #maxuwy --2
SELECT DISTINCT
    t.CTR_NF  as CTR_NF, 
    0 as SEC_NF,/* 0 because check on sections is not necessary for retro contracts */
    MAXUWY_NF = MAX(s.RTY_NF),
    RETRO_B = 1,
    PROCE = CASE WHEN (s.RETACCTYP_CT = 2 OR s.RETACCTYP_CT = 3 OR s.RETACCTYP_CT = 5) THEN 4 ELSE 3 END
FROM    BTRAV..EST_ESID0811_PERIMETER t, 
        BRET..TRETCTR s
WHERE t.CTR_NF = s.RETCTR_NF 
 AND  s.RETCTRSTS_CT in (3,19)
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
GROUP BY PROCE, RETRO_B, SEC_NF, CTR_NF --MODIF 5 --Mod 7
HAVING s.RTY_NF=MAX(s.RTY_NF) -- Emergency delivery [15]

-- MODIFICATION 14 : END OF EMERGENCY FIX 

/* 2.a.3 update the perimter with the max uwy */ --2
--Declare @maxUwy smallint
--Declare @secondMaxUwy smallint
--SELECT @maxUwy=MAX(MAXUWY_NF) from #maxuwy
--SELECT @secondMaxUwy=MAXUWY_NF from #maxuwy where MAXUWY_NF<@maxUwy

UPDATE BTRAV..EST_ESID0811_PERIMETER
    SET RETRO_B = b.RETRO_B,
    MAXUWY_NF = b.MAXUWY_NF,
    PROCE = b.PROCE
FROM #maxuwy b, BTRAV..EST_ESID0811_PERIMETER a
WHERE a.CTR_NF = b.CTR_NF
 AND (a.SEC_NF = b.SEC_NF or b.SEC_NF = 0)/* 0 because check on sections is not necessary for retro contracts */
 AND  a.SSD_CF = @p_ssd_cf
 AND  a.ESB_CF = @p_esb_cf
 AND  a.USR_CF = @p_usr_cf
-- AND b.MAXUWY_NF = CASE WHEN @maxUwy<=a.UWY_NF THEN @maxUwy WHEN a.UWY_NF<@maxUwy AND a.UWY_NF>@secondMaxUwy THEN @maxUwy ELSE @secondMaxUwy END

/* 2.b.1 set infos from MAXUWY when UWY do not exists from BTRT for assumed contracts */
/* Note any change in step 1 should be changed here too */
update BTRAV..EST_ESID0811_PERIMETER 
 SET 
    EXISTSINDB_CT = 2,/* we matched the last UWY and not the UWY */
    ACCADMTYP_CT  = s.ACCADMTYP_CT, 
    RETRO_B = 0,
    SECTIONSSD_CF = s.SSD_CF,
    SECTIONESB_CF = @p_esb_cf,  
    PROCE = 
    CASE WHEN  (s.ACCADMTYP_CT = 2 OR s.ACCADMTYP_CT = 3 OR s.ACCADMTYP_CT = 5) THEN 4 ELSE 3 END 
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF 
 AND  t.SEC_NF = s.SEC_NF 
 AND  t.EXISTSINDB_CT = 0 /* has not be fullfill by Step 1 */
 AND  t.MAXUWY_NF = s.UWY_NF
 AND  s.END_NT = 0 /* Endorsement number */
 AND  s.UW_NT  = 1 /* Underwriting order */
 AND  s.SECSTS_CT in (3,14,16,17,19) /* Section has the rights to have estimations */
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf

/* For BTRT..TCONTR for contracts --MODIF 9*/
update BTRAV..EST_ESID0811_PERIMETER
SET EXISTSINDB_CT = 1,
RETRO_B = 0,
SECTIONSSD_CF = s.SSD_CF,
SECTIONESB_CF = s.ACCESB_CF
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TCONTR s
WHERE t.CTR_NF = s.CTR_NF
-- AND  t.EXISTSINDB_CT = 0
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
/* For BTRT..TCONTR for contracts --MODIF 9*/

/* 2.b.2 set infos when UWY do not exists from TRETCTR for retro contracts */
update BTRAV..EST_ESID0811_PERIMETER
	SET EXISTSINDB_CT = 2,
    ACCADMTYP_CT  = s.RETACCTYP_CT, 
    RETRO_B = 1,
    SECTIONSSD_CF = s.SSD_CF,
    SECTIONESB_CF = s.ESB_CF,  
    PROCE = 
    CASE WHEN  (s.RETACCTYP_CT = 2 OR s.RETACCTYP_CT = 3 OR s.RETACCTYP_CT = 5) THEN 4 ELSE 3 END  
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETCTR s
WHERE t.CTR_NF = s.RETCTR_NF 
 AND  t.EXISTSINDB_CT = 0 /* has not be fullfill by Step 1 *//*--MODIF 9*/
 AND  t.MAXUWY_NF = s.RTY_NF
 AND  s.RETCTRSTS_CT in (3,19)
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 
 /* Step 3 : set the error code for each row of BTRAV..EST_ESID0811_PERIMETER  */
/* * Some contract have no uwy, or no uwy in the DB, we need to find the last UWY (max(UWY)) of the DB TRT..TSECTION for each of those contract */

/** [MOD21] - part 2 - START **/
/* 100: wrong ledger */
IF @p_run_mode <> 'A'
BEGIN
	INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
	SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 100
	FROM 
		BTRAV..EST_ESID0811_PERIMETER t 
	WHERE
		t.SECTIONSSD_CF != t.SSD_CF AND
		t.SECTIONSSD_CF != 0 AND
		t.SSD_CF = @p_ssd_cf AND 
		t.ESB_CF = @p_esb_cf AND 
		t.USR_CF = @p_usr_cf
END
 
 
/* 104 : no UWY or future UWY in the DB <=> EXISTSINDB_CT = 0 */
/* The default value for column EXISTINDB_CT in table EST_ESID0811_PERIMETER should be 0 */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 104
FROM 
	BTRAV..EST_ESID0811_PERIMETER t 
WHERE
 	t.EXISTSINDB_CT = 0  AND 
	t.SSD_CF = @p_ssd_cf AND 
	t.ESB_CF = @p_esb_cf AND 
	t.USR_CF = @p_usr_cf


/* 125 : wrong ESB_CF */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 125
FROM 
	BTRAV..EST_ESID0811_PERIMETER t 
WHERE
	t.SECTIONESB_CF != t.ESB_CF AND
	t.SECTIONESB_CF != 0 AND
	t.SSD_CF = @p_ssd_cf AND 
	t.ESB_CF = @p_esb_cf AND 
	t.USR_CF = @p_usr_cf
 
 
--Commented out so as to allow retro IO contracts to be uploaded

 /* 102 : Internal retro  */
 /* update BTRAV..EST_ESID0811_PERIMETER 
 SET ERRORCODE_CT = 102
from BTRAV..EST_ESID0811_PERIMETER t, BTRT..TCONTR c, BCLI..TCLIENT n
  where c.CTR_NF=t.CTR_NF
    and t.EXISTSINDB_CT > 0 
    AND (
  (t.EXISTSINDB_CT = 2 AND t.MAXUWY_NF = c.UWY_NF) OR
  (t.EXISTSINDB_CT = 1 AND t.UWY_NF = c.UWY_NF)
    )
    and n.CLISSD_CF!=null
    and t.RETRO_B = 0
    and c.END_NT=0
    and c.UW_NT=1
    and n.CLI_NF=c.CED_NF
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf*/

/* 101 Estimate type Assume */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 101
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TCONTR c
WHERE c.CTR_NF = t.CTR_NF
 AND (
		(t.EXISTSINDB_CT = 2 AND t.MAXUWY_NF = c.UWY_NF) OR
		(t.EXISTSINDB_CT = 1 AND t.UWY_NF    = c.UWY_NF)
	 )
 AND c.END_NT = 0
 AND c.UW_NT  = 1
 AND c.ESTCRB_CT = 'N'
 AND t.RETRO_B   =  0
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
 
SELECT @DATE = getdate(), @TYPPER = 'C'
 execute BREF..PsCALEND_02 @DATE ,@TYPPER,@BLCSHTYEA_NF output
--MODIFICATION 8 Start

/* 138 : Section out of bounds -  Assumed  Contract */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 138
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s  --Error Msg : No valid section for this contract 
WHERE t.CTR_NF = s.CTR_NF 
 AND  t.SEC_NF not in (select s.SEC_NF from BTRT..TSECTION s where t.CTR_NF = s.CTR_NF  )  
 AND  t.RETRO_B = 0  
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
/* 138 : Section out of bounds -  Retro Contract*/
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 138
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETSEC s   --Error Msg : No valid section for this contract 
WHERE t.CTR_NF = s.RETCTR_NF 
 AND  t.SEC_NF not in (select s.RETSEC_NF from BRET..TRETSEC s where t.CTR_NF = s.RETCTR_NF  )  
 AND  t.RETRO_B = 0  
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf


/* 104 : UWY and section out of bounds - not Assumed or Retro Contract*/
--Error Msg : No valid exercise for this contract and this section
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 104 
FROM BTRAV..EST_ESID0811_PERIMETER t
WHERE t.EXISTSINDB_CT = 2  -- MAX_UWY != UWY
 AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF)	--Fictive UWY_NF are only possible in the future
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
/* 104 : UWY and section out of bounds - Assumed Contract*/
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 104
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF 
 AND  t.SEC_NF not in (select s.SEC_NF from BTRT..TSECTION s where t.CTR_NF = s.CTR_NF and t.UWY_NF = s.UWY_NF )  
 AND  t.RETRO_B = 0  
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF)
/* 104 : UWY and section out of bounds - Retro Contract*/
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 104
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETSEC s
WHERE t.CTR_NF = s.RETCTR_NF 
 AND  t.SEC_NF not in (select s.RETSEC_NF from BRET..TRETSEC s where t.CTR_NF = s.RETCTR_NF  )  
 AND  t.RETRO_B = 0  
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF)

/* 103 : UWY out of bounds - Assumed/retro Contrat */
--Error Msg : No valid exercise for this contract
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 103 
FROM BTRAV..EST_ESID0811_PERIMETER t
WHERE t.EXISTSINDB_CT = 2  -- MAX_UWY != UWY
 AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF)	--Fictive UWY_NF are only possible in the future
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf


/* 122 : UWY out of bounds - Retro Contrat*
update BTRAV..EST_ESID0811_PERIMETER 
SET ERRORCODE_CT = 122                                                                  --Error Msg : No valid exercise for this contract
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETCTR tr
WHERE   t.EXISTSINDB_CT = 2  -- MAX_UWY != UWY
 AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF)	--Fictive UWY_NF are only possible in the future
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
 AND t.CTR_NF = tr.RETCTR_NF*/
 --MODIFICATION 8 End
 
/* 134 : non accounting section */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 134
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETCTR r, BRET..TRETSEC s
WHERE r.RETCTR_NF = t.CTR_NF
 AND  r.RTY_NF    = t.UWY_NF
 AND  s.RETCTR_NF = t.CTR_NF
 AND  s.RTY_NF    = t.UWY_NF
 AND  s.RETSEC_NF = t.SEC_NF
 AND  r.RETCTRCAT_CF = '02' /* NProp contract */
 AND  s.PSESEC_B = 1 /* non-accounting section */
 AND  t.RETRO_B  = 1
 AND  t.SSD_CF   = @p_ssd_cf
 AND  t.ESB_CF   = @p_esb_cf
 AND  t.USR_CF   = @p_usr_cf

/* 107 : particular retro */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 107
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETCTR s
WHERE t.CTR_NF = s.RETCTR_NF 
 AND (
		(t.EXISTSINDB_CT = 2 AND t.MAXUWY_NF = s.RTY_NF) OR
		(t.EXISTSINDB_CT = 1 AND t.UWY_NF    = s.RTY_NF)
	 )
 AND s.RETCTRSTS_CT in (3,19)
 AND s.RETCTRCAT_CF = '05' 
 AND s.CONRETCTR_B  = 1 /* particular retro */
 AND t.RETRO_B = 1  
 AND t.SSD_CF  = @p_ssd_cf
 AND t.ESB_CF  = @p_esb_cf
 AND t.USR_CF  = @p_usr_cf

/* 124 : 19 - Canceled for Assume*/
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 124
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF 
 AND  t.SEC_NF = s.SEC_NF 
 AND  t.EXISTSINDB_CT = 2 /* has not be fullfill by Step 1: if it was 1,  */
 AND  t.MAXUWY_NF = s.UWY_NF
 AND  s.SECSTS_CT = 19
 AND  t.RETRO_B = 0  
 AND  t.SSD_CF  = @p_ssd_cf
 AND  t.ESB_CF  = @p_esb_cf
 AND  t.USR_CF  = @p_usr_cf

/* 124 : 19 - Canceled for Retrocession*/
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 124
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETCTR s
WHERE t.CTR_NF = s.RETCTR_NF  
 AND (
		(t.EXISTSINDB_CT = 2 AND t.MAXUWY_NF = s.RTY_NF) OR
		(t.EXISTSINDB_CT = 1 AND t.UWY_NF    = s.RTY_NF)
	 )
 AND  s.RETCTRSTS_CT in (3,19)
 AND  s.RETCTRCAT_CF = '05' 
 AND  t.RETRO_B = 1  
 AND  s.CONRETCTR_B = 1 /* particular retro */
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf

/* 135 : Closed Treaty */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF 
 AND  t.SEC_NF = s.SEC_NF 
 AND  t.UWY_NF = s.UWY_NF
 AND  t.EXISTSINDB_CT > 0 /* exists in DB */
 AND  t.MAXUWY_NF = s.UWY_NF
 AND  s.SECACCSTS_CT = 9 /* maxuwy section is closed */
 AND  t.RETRO_B = 0 
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 
/*30002 : to check if the selected contract is a model contract - ASSUME */
-- MODIF 2
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 30002
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TCONTR c
WHERE c.CTR_NF=t.CTR_NF
 AND (
		(t.EXISTSINDB_CT = 2 AND t.MAXUWY_NF = c.UWY_NF) OR
		(t.EXISTSINDB_CT = 1 AND t.UWY_NF    = c.UWY_NF)
	 )
 AND  c.ESTCRB_CT = 'D'
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf

/* 30002 : to check if the selected contract is a model contract - RETRO */
-- MODIF 2
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 30002
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETCTR s 
WHERE s.RETCTR_NF = t.CTR_NF
 AND (
		(t.EXISTSINDB_CT = 2 AND t.MAXUWY_NF = s.RTY_NF) OR
		(t.EXISTSINDB_CT = 1 AND t.UWY_NF    = s.RTY_NF)
	 )
 AND  S.ESTCRB_CT = 'D'
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf

/* 30014 : Impossible de charger des estimations sur des retrocessions terminees. */
-- MODIF 4 start
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 30014
FROM BTRAV..EST_ESID0811_PERIMETER t, BRET..TRETCTR c
WHERE t.CTR_NF = c.RETCTR_NF  
 AND (
		(t.EXISTSINDB_CT = 2 AND t.MAXUWY_NF = c.RTY_NF) OR
		(t.EXISTSINDB_CT = 1 AND t.UWY_NF    = c.RTY_NF)
	 )
 AND  t.RETRO_B  = 1  
 AND  c.TERCTR_B = 1 /* Terminated retro contract */
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 --MODIF 4 end

/* 551 : Exercice invalide. */
-- MODIF 5 START
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 551
FROM BTRAV..EST_ESID0811_PERIMETER t
WHERE t.ACCADMTYP_CT = 4 --Mod 6
 AND  t.UWY_NF > t.MAXUWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 --MODIF 5 END

-- [MOD10] - START
/* 5033 : to check if contracts with quarterly estimates have values 3, 6, 9, 12 for the month  */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 5033
FROM BTRAV..EST_ESID0811_PERIMETER t
LEFT OUTER JOIN BTRT..TCONTR tcontr ON t.CTR_NF = tcontr.CTR_NF  AND t.UWY_NF=tcontr.UWY_NF
LEFT OUTER JOIN BRET..TRETCTR tret  ON t.CTR_NF = tret.RETCTR_NF AND t.UWY_NF=tret.RTY_NF
WHERE CASE 
    WHEN tcontr.CTR_NF IS NOT NULL 
    THEN tcontr.ESTCRB_CT 
    ELSE tret.ESTCRB_CT END IN ('T','U') -- T, U = quarterly contracts
 AND t.ACM_NF NOT IN (3,6,9,12)
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
 
/* 5032 : to check if contracts with yearly estimates have the value 13 on the accounting month */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 5032
FROM BTRAV..EST_ESID0811_PERIMETER t
LEFT OUTER JOIN BTRT..TCONTR tcontr ON t.CTR_NF = tcontr.CTR_NF AND t.UWY_NF=tcontr.UWY_NF
LEFT OUTER JOIN BRET..TRETCTR tret ON t.CTR_NF = tret.RETCTR_NF AND t.UWY_NF=tret.RTY_NF
WHERE CASE 
    WHEN tcontr.CTR_NF IS NOT NULL 
    THEN tcontr.ESTCRB_CT 
    ELSE tret.ESTCRB_CT END NOT IN ('T','U') -- => yearly contracts
 AND t.ACM_NF != 13
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf


/* 5034 : to check if quarters are auto-update/complete account (update forbidden)  */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 5034
FROM BTRAV..EST_ESID0811_PERIMETER t
LEFT OUTER JOIN BTRT..TCONTR tcontr ON t.CTR_NF = tcontr.CTR_NF AND t.UWY_NF=tcontr.UWY_NF
LEFT OUTER JOIN BRET..TRETCTR tret ON t.CTR_NF = tret.RETCTR_NF AND t.UWY_NF=tret.RTY_NF
, BCTA..TCPLACC tcp
WHERE CASE 
    WHEN tcontr.CTR_NF IS NOT NULL 
    THEN tcontr.ESTCRB_CT 
    ELSE tret.ESTCRB_CT END IN ('T','U')
 AND t.CTR_NF = tcp.CTR_NF 
 AND t.ACM_NF != 13
 AND t.ACY_NF = tcp.ACY_NF
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
 
/* 5010 : to check if quarterly contracts have only gaap 1 for cash code */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 5010
FROM BTRAV..EST_ESID0811_PERIMETER t
LEFT OUTER JOIN BREF..TSUBTRS sub ON t.DETTRNCOD_CF = sub.PCPTRS_CF+sub.TRS_CF+sub.SUBTRS_CF
WHERE t.ACM_NF != 13
 AND  sub.TRSTYPE_CT = 1
 AND  t.gaap_nt <> 1
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 
/* 5035: to check if a contract is "No Estimates" (ESTCRB_CT = V) */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 5035
FROM BTRAV..EST_ESID0811_PERIMETER t
LEFT OUTER JOIN BTRT..TCONTR tcontr ON t.CTR_NF = tcontr.CTR_NF AND t.UWY_NF=tcontr.UWY_NF
LEFT OUTER JOIN BRET..TRETCTR tret ON t.CTR_NF = tret.RETCTR_NF AND t.UWY_NF=tret.RTY_NF
WHERE CASE 
    WHEN tcontr.CTR_NF IS NOT NULL 
    THEN tcontr.ESTCRB_CT 
    ELSE tret.ESTCRB_CT END = 'V'
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
-- [MOD10] - END
 
--[MOD11] START
--[MOD12] START

/* 135 : Treaty in creation process */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.UWY_NF in (select MAX(a.UWY_NF) from BTRT..TSECTION a where  T.CTR_NF=a.CTR_NF and T.SEC_NF=a.SEC_NF )
 AND  t.UWY_NF in (select MIN(a.UWY_NF) from BTRT..TSECTION a where  T.CTR_NF=a.CTR_NF and T.SEC_NF=a.SEC_NF )
 AND  s.SECSTS_CT in (3)

/* 135 : Treaty in NTU statusu */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.UWY_NF in (select distinct uwy_nf from BTRT..TSECTION a where  T.CTR_NF=a.CTR_NF and T.SEC_NF=a.SEC_NF and T.UWY_NF>=a.UWY_NF and a.SECSTS_CT  in (22))


/* 135 : ACCADMTYP_CT = 1 */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.ACCADMTYP_CT = 1 
 AND  t.CTR_NF  not in (select CTR_NF from BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19))
 AND (t.CTR_NF not in (select CTR_NF from BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (14,16))
        -- or (T.UWY_NF != T.ACY_NF) -- MOD [15]
        or (T.UWY_NF > @BLCSHTYEA_NF  + 6 )
        or (T.UWY_NF < @BLCSHTYEA_NF  - 5 ))
 AND  t.CTR_NF in  (select CTR_NF from BTRT..TCONTR c  where c.CTR_NF in 
                                              (select distinct CTR_NF from BTRAV..EST_ESID0811_PERIMETER 
                                                                            WHERE t.SSD_CF = @p_ssd_cf
                                                                                AND t.ESB_CF = @p_esb_cf
                                                                                AND t.USR_CF = @p_usr_cf  )  group by CTR_NF)    


-- BEG MOD [15]
/* 5018 : Type 1, pas d'import sur des années de comptes différentes de l'exercice. */
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 5018
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.ACCADMTYP_CT = 1 
 AND  t.CTR_NF  not in (select CTR_NF from BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19))
 AND  t.UWY_NF != t.ACY_NF
 AND  t.CTR_NF in  (select CTR_NF from BTRT..TCONTR c  where c.CTR_NF in 
                                              (select distinct CTR_NF from BTRAV..EST_ESID0811_PERIMETER 
                                                                            WHERE t.SSD_CF = @p_ssd_cf
                                                                                AND t.ESB_CF = @p_esb_cf
                                                                                AND t.USR_CF = @p_usr_cf  )  group by CTR_NF)  

-- END MOD [15]

 
--ACCADMTYP_CT = 2
--Cancelled Treaty
--When a type 2 is cancelled, it is forbidden to upload on all years after the cancellation.
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.ACCADMTYP_CT = 2
 AND  t.CTR_NF  in (select CTR_NF from BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19))
 AND T.UWY_NF > (select max(UWY_NF) from BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19))
 AND T.CTR_NF in  (select CTR_NF from BTRT..TCONTR c  where c.CTR_NF in 
                                              (select distinct CTR_NF from BTRAV..EST_ESID0811_PERIMETER 
                                                                            WHERE t.SSD_CF = @p_ssd_cf
                                                                                AND t.ESB_CF = @p_esb_cf
                                                                                AND t.USR_CF = @p_usr_cf  )  group by CTR_NF)   
                                                                                
/*
On the cancelled underwriting year and underwriting years before the cancellation 
the upload is allowed on all accounting years from balance sheet year minus 4
to balance sheet year plus 5, but only for accounting years greater or equals to  underwriting year.

*/
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.ACCADMTYP_CT = 2
 AND  t.CTR_NF  in (select CTR_NF from BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19))
 AND  t.UWY_NF <= (select MAX(UWY_NF) from BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19))
 AND ((T.ACY_NF > @BLCSHTYEA_NF  + 6 ) 
          or (T.ACY_NF < @BLCSHTYEA_NF  - 5 ) OR 
                (T.ACY_NF < T.UWY_NF )  )                                
 AND  t.CTR_NF in  (select CTR_NF from BTRT..TCONTR c  where c.CTR_NF in 
                                              (select distinct CTR_NF from BTRAV..EST_ESID0811_PERIMETER 
                                                                            WHERE t.SSD_CF = @p_ssd_cf
                                                                                AND t.ESB_CF = @p_esb_cf
                                                                                AND t.USR_CF = @p_usr_cf  )  group by CTR_NF)                                                                                 
                                                                                
                                                                                
-- Non Cancelled trety
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.ACCADMTYP_CT = 2
 AND  t.CTR_NF  not in (select CTR_NF from BTRT..TSECTION S1 where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19))
 AND  ((T.ACY_NF > @BLCSHTYEA_NF  + 6 ) or (T.ACY_NF < @BLCSHTYEA_NF  - 5 ) or (T.ACY_NF < T.UWY_NF) )
 AND  t.CTR_NF in  (select CTR_NF from BTRT..TCONTR c  where c.CTR_NF in 
                                              (select distinct CTR_NF from BTRAV..EST_ESID0811_PERIMETER 
                                                                            WHERE t.SSD_CF = @p_ssd_cf
                                                                                AND t.ESB_CF = @p_esb_cf
                                                                                AND t.USR_CF = @p_usr_cf  )  group by CTR_NF)    

--ACCADMTYP_CT = 3
--To DO

--ACCADMTYP_CT = 4
--After the cancelled underwriting year, it is forbidden
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.ACCADMTYP_CT = 4
 AND  t.UWY_NF >(select max(UWY_NF) from  BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19) )
 AND  t.CTR_NF in  (select CTR_NF from BTRT..TCONTR c  where c.CTR_NF in 
                                              (select distinct CTR_NF from BTRAV..EST_ESID0811_PERIMETER 
                                                                            WHERE t.SSD_CF = @p_ssd_cf
                                                                                AND t.ESB_CF = @p_esb_cf
                                                                                AND t.USR_CF = @p_usr_cf  )  group by CTR_NF)  

-- On the cancelled underwriting year, the upload is allowed on all accounting years corresponding to balance sheet plus 5
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	 t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.UWY_NF = s.UWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  s.SECSTS_CT in (19)
 AND  t.ACCADMTYP_CT = 4
 AND  t.UWY_NF = (select max(UWY_NF) from  BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19) )
 AND ( (T.ACY_NF < @BLCSHTYEA_NF  - 5 ) or ( T.ACY_NF > @BLCSHTYEA_NF  +6 ) or T.ACY_NF < T.UWY_NF)        
 
 AND T.CTR_NF in  (select CTR_NF from BTRT..TCONTR c  where c.CTR_NF in 
                                              (select distinct CTR_NF from BTRAV..EST_ESID0811_PERIMETER 
                                                                            WHERE t.SSD_CF = @p_ssd_cf
                                                                                AND t.ESB_CF = @p_esb_cf
                                                                                AND t.USR_CF = @p_usr_cf  )  group by CTR_NF)    
                                                                                
--before cancelled underwriting year is the same as the accounting type 1
INSERT INTO #EST_ESID0811_PERIMETER_ANO
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, 135
FROM BTRAV..EST_ESID0811_PERIMETER t, BTRT..TSECTION s
WHERE T.CTR_NF=s.CTR_NF
 AND  t.SEC_NF=s.SEC_NF
 AND  t.UWY_NF=s.UWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.ACCADMTYP_CT = 4
 AND  t.UWY_NF < (select max(UWY_NF) from  BTRT..TSECTION S1 
                                where T.CTR_NF=s1.CTR_NF and T.SEC_NF=s1.SEC_NF and s1.SECSTS_CT  in (19) )
 AND  ((T.ACY_NF != T.UWY_NF) or(T.ACY_NF > @BLCSHTYEA_NF  + 6 ) or (T.ACY_NF < @BLCSHTYEA_NF  - 5 ))
 AND  t.CTR_NF in  (select CTR_NF from BTRT..TCONTR c  where c.CTR_NF in 
                                              (select distinct CTR_NF from BTRAV..EST_ESID0811_PERIMETER 
                                                                            WHERE t.SSD_CF = @p_ssd_cf
                                                                                AND t.ESB_CF = @p_esb_cf
                                                                                AND t.USR_CF = @p_usr_cf  )  group by CTR_NF)   
--ACCADMTYP_CT = 5
--to do 
--[MOD12] end
--[MOD11] END
 
/** MODIF [18] START **/
/* 606 : UWY_NF not exists*/
/*update BTRAV..EST_ESID0811_PERIMETER 
SET ERRORCODE_CT = 606
FROM BTRAV..EST_ESID0811_PERIMETER t
WHERE t.SSD_CF = @p_ssd_cf
AND   t.ESB_CF = @p_esb_cf
AND   t.USR_CF = @p_usr_cf
AND (
    (t.UWY_NF < (select min(B.UWY_NF) from BTRT..TCONTR  B where B.CTR_NF = t.CTR_NF))
    or
    (t.UWY_NF < (select min(C.UWY_NF) from BFAC..TCONTR  C where C.CTR_NF = t.CTR_NF))
    or
    (t.UWY_NF < (select min(D.RTY_NF) from BRET..TRETCTR D where D.RETCTR_NF = t.CTR_NF))
    )*/
/** MODIF [18] END **/

/* Si une ligne est dans la table #EST_ESID0811_PERIMETER_ANO c'est que une erreur a etait trouvait sur cette ligne*/
/* donc la ligne dans avec ERRORCODE_CT=null n'a  plus lieu d'etre dans EST_ESID0811_PERIMETER */
DELETE BTRAV..EST_ESID0811_PERIMETER 
FROM BTRAV..EST_ESID0811_PERIMETER t,  #EST_ESID0811_PERIMETER_ANO a
WHERE t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.CTR_NF = a.CTR_NF
 AND  t.SEC_NF = a.SEC_NF
 AND  t.UWY_NF = a.UWY_NF
 AND  t.ACY_NF = a.ACY_NF
 AND  t.NUMLINE_NT   = a.NUMLINE_NT
 AND  t.ERRORCODE_CT = NULL

/* Copier tout les ano de la table temporaire #EST_ESID0811_PERIMETER_ANO dans EST_ESID0811_PERIMETER */ 
INSERT INTO BTRAV..EST_ESID0811_PERIMETER
	(CTR_NF, SEC_NF, UWY_NF, ACM_NF, ACY_NF, NUMLINE_NT, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF,	GAAP_NT,
	 DETTRNCOD_CF, ACCADMTYP_CT, RETRO_B, PROCE, MAXUWY_NF, EXISTSINDB_CT, SECTIONSSD_CF, SECTIONESB_CF, ERRORCODE_CT)
SELECT DISTINCT
	t.CTR_NF, t.SEC_NF, t.UWY_NF, t.ACM_NF, t.ACY_NF, t.NUMLINE_NT, t.END_NT, t.UW_NT, t.SSD_CF, t.ESB_CF, t.USR_CF, t.GAAP_NT,
	t.DETTRNCOD_CF, t.ACCADMTYP_CT, t.RETRO_B, t.PROCE, t.MAXUWY_NF, t.EXISTSINDB_CT, t.SECTIONSSD_CF, t.SECTIONESB_CF, ERRORCODE_CT
FROM #EST_ESID0811_PERIMETER_ANO t
WHERE t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.ERRORCODE_CT != NULL
/** [MOD21] - part 2 - END   **/
 -- Modif 2 - removed blocking b=1 for avoiding errors to stay in the list 
delete BTRAV..EST_ESID0811_TCTRANO from BTRAV..EST_ESID0811_TCTRANO where SSD_CF = @p_ssd_cf AND ESB_CF = @p_esb_cf AND SEG_NF = @p_usr_cf


INSERT INTO BTRAV..EST_ESID0811_TCTRANO(
 CTR_NF, 
 END_NT, 
 SEC_NF, 
 VRS_NF, 
 SSD_CF, 
 SEGTYP_CT, 
 SEG_NF, 
 ANO_CT, 
 NUMLINE_NT, 
 UWY_NF,
 ACY_NF,
 BLOCKING_B,
 ESB_CF,
 USR_CF,
 GAAP_NT,
 DETTRNCOD_CF
)
SELECT 
	t.CTR_NF,
	t.END_NT,
	t.SEC_NF,
	1,
	@p_ssd_cf,
	'L',
	@p_usr_cf,
	t.ERRORCODE_CT,
	t.NUMLINE_NT,
	t.UWY_NF,
	t.ACY_NF,
	1,
	@p_esb_cf,
	@p_usr_cf,
	t.GAAP_NT,
	t.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESID0811_PERIMETER t
WHERE 
	t.ERRORCODE_CT != NULL AND 
	t.SSD_CF = @p_ssd_cf AND 
	t.ESB_CF = @p_esb_cf AND 
	t.USR_CF = @p_usr_cf

if object_id('#EST_ESID0811_PERIMETER_ANO') is not null drop Table #EST_ESID0811_PERIMETER_ANO
if object_id('#maxuwy') is not null drop Table #maxuwy
go
EXEC sp_procxmode 'PsLIFEST_16_O2', 'unchained'
go
IF OBJECT_ID('PsLIFEST_16_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFEST_16_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFEST_16_O2 >>>'
go
GRANT EXECUTE ON PsLIFEST_16_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFEST_16_O2 TO GDBBATCH
go
