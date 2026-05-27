-- --------------------------------------------------------------------------------------------- --
-- Script           : RET97909_INSERT_TRETIFRS_P&C.sql
-- Domaine          : RETROCESSION
-- Auteur           : ThD / BeL
-- Date de création : 24/08/2021
-- Description      : Init P&C Data into TRETIFRS
-- --------------------------------------------------------------------------------------------- --
USE BRET
GO

-- --------------------- --
-- INIT TEMP TABLE       --
-- --------------------- --

DELETE FROM BRET..TRETIFRS WHERE LSTUPDUSR_CF = '979P'
GO
if object_id('#TRETIFRS_TMP') is not null drop Table #TRETIFRS_TMP
GO
SELECT TOP 1 * INTO #TRETIFRS_TMP FROM BRET..TRETIFRS
GO
DELETE FROM #TRETIFRS_TMP
GO

-- --------------------- --
-- Début des traitements --    
-- --------------------- --

INSERT INTO #TRETIFRS_TMP
(	RETCTR_NF,
	RTY_NF,
	CRE_D,
	CREUSR_CF,
	LSTUPD_D,
	LSTUPDUSR_CF,
	RETRECOD_D,
  PRICEDCTR_B,
  FOREWRITERLCK_B,
  GRPINISTS_CT,
  PARINISTS_CT,
  LOCINISTS_CT,
  GRPMANSEG_B,
  PARMANSEG_B,
  LOCMANSEG_B
)
SELECT DISTINCT
	T1.RETCTR_NF,
	T1.RTY_NF,
	getdate(),
	'979P',
	getdate(),
	'979P',
	T2.FSTVISA_D,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0
	FROM BRET..TRETCTR T1 , bret..TRETCTRVISA T2, bref..TESB T3
    WHERE T1.RETCTRSTS_CT in (3,19,18,23)
     -- AND T1.RETCTRCAT_CF != '02'
     -- AND T1.RTY_NF >= 2018
     -- AND T1.SSD_CF IN (10,11,13,14,25,26,27,1,2,3,4,5,6,7,12,15,16,17,18,19,23) -- AM + EU
      AND NOT EXISTS (select * from bret..TRETIFRS T3 where T1.RETCTR_NF = T3.RETCTR_NF and T1.RTY_NF = T3.RTY_NF)
      AND T1.RETCTR_NF = T2.RETCTR_NF
      AND T1.RTY_NF = T2.RTY_NF
      AND T2.VISA_NT = 1
      AND ((T2.FSTVISA_D != T2.SNDVISA_D) OR (T2.FSTVISA_D != null AND  T2.SNDVISA_D in (null,'')) or (T2.SNDVISA_D != null AND  T2.FSTVISA_D in (null,'')))
	    AND T3.SSD_CF = T1.SSD_CF
	    AND T3.SSD_CF = T1.SSD_CF
	    AND T3.LIFE_CF = 2
GO


INSERT INTO #TRETIFRS_TMP
(	RETCTR_NF,
	RTY_NF,
	CRE_D,
	CREUSR_CF,
	LSTUPD_D,
	LSTUPDUSR_CF,
	RETRECOD_D,
  PRICEDCTR_B,
  FOREWRITERLCK_B,
  GRPINISTS_CT,
  PARINISTS_CT,
  LOCINISTS_CT,
  GRPMANSEG_B,
  PARMANSEG_B,
  LOCMANSEG_B
)
SELECT DISTINCT
	T1.RETCTR_NF,
	T1.RTY_NF,
	getdate(),
	'979P',
	getdate(),
	'979P',
	T1.CTRINCUWY_D,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0
	 FROM BRET..TRETCTR T1 , bret..TRETCTRVISA T2, bref..TESB T3
    WHERE T1.RETCTRSTS_CT in (3,19,18,23)
      -- AND T1.RETCTRCAT_CF != '02'
	    -- AND T1.RTY_NF >= 2018
      -- AND T1.SSD_CF IN (10,11,13,14,25,26,27,1,2,3,4,5,6,7,12,15,16,17,18,19,23) -- AM + EU
      AND NOT EXISTS (select * from bret..TRETIFRS T3 where T1.RETCTR_NF = T3.RETCTR_NF and T1.RTY_NF = T3.RTY_NF)
      AND NOT EXISTS (select * from #TRETIFRS_TMP T3 where T1.RETCTR_NF = T3.RETCTR_NF and T1.RTY_NF = T3.RTY_NF)
      AND T1.RETCTR_NF = T2.RETCTR_NF
      AND T1.RTY_NF = T2.RTY_NF
      AND T2.VISA_NT = 1
      AND T2.FSTVISA_D = T2.SNDVISA_D
	  	AND T3.SSD_CF = T1.SSD_CF
	    AND T3.SSD_CF = T1.SSD_CF
	    AND T3.LIFE_CF = 2
GO

UPDATE #TRETIFRS_TMP
     SET GRPINIPRO_CF   = '4'
        ,PARINIPRO_CF   = '4'
        ,LOCINIPRO_CF   = '4'
        ,GRPIFRSSEG_CT = b.RETCTR_NF    -- numero contrat
        ,PARIFRSSEG_CT = b.RETCTR_NF
        ,LOCIFRSSEG_CT = b.RETCTR_NF
        ,GRPIFRSSEG_LL = b.CTRPCPNAM_LL -- libelle contrat
        ,PARIFRSSEG_LL = b.CTRPCPNAM_LL
        ,LOCIFRSSEG_LL = b.CTRPCPNAM_LL
     FROM #TRETIFRS_TMP a, BRET..TRETCTR b, BREF..TESB c
        where a.RETCTR_NF = b.RETCTR_NF
        and a.RTY_NF = b.RTY_NF
        and b.SSD_CF = c.SSD_CF
        and b.ESB_CF = c.ESB_CF
        and c.LIFE_CF = 2 -- P&C
        and a.GRPINIPRO_CF   is null
        and a.PARINIPRO_CF   is null
        and a.LOCINIPRO_CF   is null
        and a.GRPIFRSSEG_CT is null
        and a.PARIFRSSEG_CT is null
        and a.LOCIFRSSEG_CT is null
        and a.GRPIFRSSEG_LL is null
        and a.PARIFRSSEG_LL is null
        and a.LOCIFRSSEG_LL is null
GO                

    update #TRETIFRS_TMP
     set GRPIFRSTRA_CT   = '1' -- FRA
     from #TRETIFRS_TMP a, BRET..TRETCTR b, BREF..TESB c
        where a.RETCTR_NF = b.RETCTR_NF
        and a.RTY_NF = b.RTY_NF
        and b.SSD_CF = c.SSD_CF
        and b.ESB_CF = c.ESB_CF
        and c.LIFE_CF = 2 -- P&C
GO


INSERT INTO BRET..TRETIFRS
(	RETCTR_NF,
	RTY_NF,
	CRE_D,
	CREUSR_CF,
	LSTUPD_D,
	LSTUPDUSR_CF,
	RETRECOD_D,
  PRICEDCTR_B,
  FOREWRITERLCK_B,
  GRPINISTS_CT,
  PARINISTS_CT,
  LOCINISTS_CT,
  GRPMANSEG_B,
  PARMANSEG_B,
  LOCMANSEG_B,
  GRPINIPRO_CF,
  PARINIPRO_CF,
  LOCINIPRO_CF,
  GRPIFRSSEG_CT,
  PARIFRSSEG_CT,
  LOCIFRSSEG_CT,
  GRPIFRSSEG_LL,
  PARIFRSSEG_LL,
  LOCIFRSSEG_LL,
  GRPIFRSTRA_CT
) 
SELECT a.RETCTR_NF,
a.RTY_NF,
a.CRE_D,
a.CREUSR_CF,
a.LSTUPD_D,
a.LSTUPDUSR_CF,
a.RETRECOD_D,
a.PRICEDCTR_B,
a.FOREWRITERLCK_B,
a.GRPINISTS_CT,
a.PARINISTS_CT,
a.LOCINISTS_CT,
a.GRPMANSEG_B,
a.PARMANSEG_B,
a.LOCMANSEG_B,
a.GRPINIPRO_CF,
a.PARINIPRO_CF,
a.LOCINIPRO_CF,
a.GRPIFRSSEG_CT,
a.PARIFRSSEG_CT,
a.LOCIFRSSEG_CT,
a.GRPIFRSSEG_LL,
a.PARIFRSSEG_LL,
a.LOCIFRSSEG_LL,
a.GRPIFRSTRA_CT
FROM #TRETIFRS_TMP a
GO

SELECT * FROM BRET..TRETIFRS WHERE LSTUPDUSR_CF = '979P'
GO
