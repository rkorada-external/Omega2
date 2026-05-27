use BSEG
go

if object_id('PsOmegaExtract_FAC') is not null
	begin
		drop procedure PsOmegaExtract_FAC
		if object_id('PsOmegaExtract_FAC') is not null
			print '<<< FAILED DROPPING procedure PsOmegaExtract_FAC >>>'
		else
			print '<<< DROPPED procedure PsOmegaExtract_FAC >>>'
	end
go

create procedure PsOmegaExtract_FAC
  (
   @p_date     varchar(8),
			@norme_cf  char(4), --[001]
   @p_erreur 		varchar(64)= null output
  )
as

/***************************************************
Domaine : (ES) Estimation
Base principale : BSEG
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation: 18/06/2020
Description du programme:
    feed #OMEGA2EXTRACT_tmp with facultative omega extract. #OMEGA2EXTRACT_tmp is a temporary table generated in the calling stored procedure BEST_PsOmega2Extract.prc
Parametres:
	@p_date     varchar(8)
 @p_erreur 		 varchar(64)=null output
	modifications:
	[001] Spira 93011:  IFRS 17 Transition - Limit Group Run perimeter to Assumed external and retro NP (internal + external)
	[002] Spira 92573:  Transition: Gaps between expected and observed amounts FP-UPR
*****************************************************/

IF OBJECT_ID('tempdb..#UPR_RETRIEVAL_tmp ') IS NOT NULL DROP TABLE tempdb..#UPR_RETRIEVAL_tmp 
CREATE TABLE #UPR_RETRIEVAL_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	CUR_CF		UCUR_CF		NOT NULL,
	CTR_NF		UCTR_NF		NOT NULL,
	SEC_NF		USEC_NF		NOT NULL,
	UWY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	UPR			UAMT_M		NOT NULL
)


IF OBJECT_ID('tempdb..#UPR_CONVERTED_tmp ') IS NOT NULL DROP TABLE tempdb..#UPR_CONVERTED_tmp 
CREATE TABLE #UPR_CONVERTED_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	CUR_CF		UCUR_CF		NOT NULL,
	CTR_NF		UCTR_NF		NOT NULL,
	SEC_NF		USEC_NF		NOT NULL,
	UWY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	UPR			UAMT_M		NOT NULL,
	UPR_EUR		UAMT_M		NOT NULL,
	CUR_RATE	ULNGDEC		NOT NULL,
	EUR_RATE	ULNGDEC		NOT NULL
)


IF OBJECT_ID('tempdb..#UPR_BY_CSUOE_tmp ') IS NOT NULL DROP TABLE tempdb..#UPR_BY_CSUOE_tmp 
CREATE TABLE #UPR_BY_CSUOE_tmp 
(
	CTR_NF		UCTR_NF		NOT NULL,
	SEC_NF		USEC_NF		NOT NULL,
	UWY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	UPR			UAMT_M		NOT NULL
)


IF OBJECT_ID('tempdb..#FP_RETRIEVAL_tmp ') IS NOT NULL DROP TABLE tempdb..#FP_RETRIEVAL_tmp 
CREATE TABLE #FP_RETRIEVAL_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	CUR_CF		UCUR_CF		NOT NULL,
	CTR_NF		UCTR_NF		NOT NULL,
	SEC_NF		USEC_NF		NOT NULL,
	UWY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	FP			UAMT_M		NOT NULL
)

IF OBJECT_ID('tempdb..#FP_CONVERTED_tmp ') IS NOT NULL DROP TABLE tempdb..#FP_CONVERTED_tmp 
CREATE TABLE #FP_CONVERTED_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	CUR_CF		UCUR_CF		NOT NULL,
	CTR_NF		UCTR_NF		NOT NULL,
	SEC_NF		USEC_NF		NOT NULL,
	UWY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	FP			UAMT_M		NOT NULL,
	FP_EUR		UAMT_M		NOT NULL,
	CUR_RATE	ULNGDEC		NOT NULL,
	EUR_RATE	ULNGDEC		NOT NULL
)

IF OBJECT_ID('tempdb..#FP_BY_CSUOE_tmp ') IS NOT NULL DROP TABLE tempdb..#FP_BY_CSUOE_tmp 
CREATE TABLE #FP_BY_CSUOE_tmp 
(
	CTR_NF		UCTR_NF		NOT NULL,
	SEC_NF		USEC_NF		NOT NULL,
	UWY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	FP			UAMT_M		NOT NULL
)

IF OBJECT_ID('tempdb..#UPR_FP_RETRIEVAL_tmp ') IS NOT NULL DROP TABLE tempdb..#UPR_FP_RETRIEVAL_tmp 
CREATE TABLE #UPR_FP_RETRIEVAL_tmp 
(
	CTR_NF			UCTR_NF		NOT NULL,
	SEC_NF			USEC_NF		NOT NULL,
	UWY_NF			UUWY_NF		NOT NULL,
	UW_NT			UUW_NT  NOT NULL,
	END_NT			UEND_NT  NOT NULL,
	UPR			UAMT_M	NULL,
	FP			UAMT_M	NULL,
)

--Temporary table which retrieves the extended CUOE by the commercial relationship
IF OBJECT_ID('tempdb..#CR_RETRIEVAL_tmp') IS NOT NULL DROP TABLE tempdb..#CR_RETRIEVAL_tmp
CREATE TABLE #CR_RETRIEVAL_tmp
(

	CTR_NF			UCTR_NF		NOT NULL,
	UWY_NF			UUWY_NF		NOT NULL,
	UW_NT			UUW_NT      NOT NULL,
	END_NT			UEND_NT		NOT NULL,
	CR_NF		    char(10)	NULL,
	CR_UWY_NF	    UUWY_NF	    NULL,
	CR_UW_NT	    UUW_NT		NULL
)

--Temporary table which retrieves the extended CUOE by the commercial relationship
IF OBJECT_ID('tempdb..#CR_UPR_FP_tmp') IS NOT NULL DROP TABLE tempdb..#CR_UPR_FP_tmp
CREATE TABLE #CR_UPR_FP_tmp
(
	CR_NF		    char(10)	NOT NULL,
	CR_UWY_NF	    UUWY_NF	    NOT NULL,
	CR_UW_NT	    UUW_NT		NOT NULL,
	SUM_UPR			UAMT_M		NULL,
	SUM_FP			UAMT_M		NULL
)

--Temporary table which retrieves the extended CSUOE by section

IF OBJECT_ID('tempdb..#SECTION_RETRIEVAL_tmp') IS NOT NULL DROP TABLE tempdb..#SECTION_RETRIEVAL_tmp
CREATE TABLE #SECTION_RETRIEVAL_tmp
(
	CTR_NF			UCTR_NF			NOT NULL,
	SEC_NF			USEC_NF			NULL,
	UWY_NF			UUWY_NF			NOT NULL,
	UW_NT			UUW_NT     NOT NULL,
	END_NT			UEND_NT    NOT NULL,
	PRILR_T			USHORAT_R		NULL,
	CTRPRI_B		UBOOLEAN_B	NULL,
	CR_NF    		char(10)   NOT NULL,
	CR_UWY_NF		UUWY_NF NOT NULL,
	CR_UW_NT		UUW_NT	NOT NULL
)

DECLARE
@v_tablename varchar (20), -- the table name depends on the date in input parameter
@query varchar(2000) -- the query depends on the @v_tablename



-- we retrieve the TTECLADA table to use depending on the input parameter @p_date
SELECT @v_tablename = p.TABCIBLE_CF FROM BSAR..TBOPAR p WHERE p.TAB_CF = 'TTECLEDA' AND p.FIELD2_CF = @p_date

--[001] Check into BCLI..TCLIENT if cl.CLISSD_CF IS NULL
--[002] a.trncod_cf starts with 11 or 14 and t.acmtrsl3_nt = 1030
IF(@norme_cf = 'I17G') 
BEGIN
	-- Get CSUOE UPR AMOUNT and save them in #UPR_RETRIEVAL_tmp
	SELECT @query = 'INSERT INTO #UPR_RETRIEVAL_tmp(SSD_CF, CUR_CF, CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, UPR)
	SELECT a.SSD_CF, a.CUR_CF, a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.amt_m
	FROM BFAC..TCONTR c
	INNER JOIN BSAR..' + @v_tablename + ' a ON  c.CTR_NF = a.CTR_NF AND c.UWY_NF = a.UWY_NF AND c.UW_NT = a.UW_NT AND c.END_NT = a.END_NT
	INNER JOIN  BSAR..TBOPRSLNK t ON t.dettrs_cf = a.trncod_cf
	INNER JOIN BCLI..TCLIENT cl  ON cl.CLI_NF = c.CED_NF
	WHERE c.MULTUWY_NF IS NULL 
	AND ((a.trncod_cf LIKE ''11%'') OR (a.trncod_cf LIKE ''14%''))
	AND t.acmtrsl3_nt = 1030
	AND t.trntyp_ct < 100
	AND a.lobacc_cf NOT IN (''30'',''31'')
	AND cl.CLISSD_CF IS NULL
	AND ((a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF = ' + SUBSTRING(@p_date, 5, 2) + ' AND a.BALSHRDAY_NF <= ' + SUBSTRING(@p_date, 7, 2) + ')
	OR (a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF < ' + SUBSTRING(@p_date, 5, 2) + ')
	OR (a.BALSHEY_NF < ' + SUBSTRING(@p_date, 1, 4) + '))'
END

--[002] a.trncod_cf starts with 11 or 14 and t.acmtrsl3_nt = 1030
IF(@norme_cf != 'I17G')
BEGIN
	-- Get CSUOE UPR AMOUNT and save them in #UPR_RETRIEVAL_tmp
	SELECT @query = 'INSERT INTO #UPR_RETRIEVAL_tmp(SSD_CF, CUR_CF, CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, UPR)
	SELECT a.SSD_CF, a.CUR_CF, a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.amt_m
	FROM BFAC..TCONTR c
	INNER JOIN BSAR..' + @v_tablename + ' a ON  c.CTR_NF = a.CTR_NF AND c.UWY_NF = a.UWY_NF AND c.UW_NT = a.UW_NT AND c.END_NT = a.END_NT
	INNER JOIN  BSAR..TBOPRSLNK t ON t.dettrs_cf = a.trncod_cf
	WHERE c.MULTUWY_NF IS NULL 
	AND ((a.trncod_cf LIKE ''11%'') OR (a.trncod_cf LIKE ''14%''))
	AND t.acmtrsl3_nt = 1030
	AND t.trntyp_ct < 100
	AND a.lobacc_cf NOT IN (''30'',''31'')
	AND ((a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF = ' + SUBSTRING(@p_date, 5, 2) + ' AND a.BALSHRDAY_NF <= ' + SUBSTRING(@p_date, 7, 2) + ')
	OR (a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF < ' + SUBSTRING(@p_date, 5, 2) + ')
	OR (a.BALSHEY_NF < ' + SUBSTRING(@p_date, 1, 4) + '))'
END


EXECUTE(@query)

-- Convert the UPR amount in euro
SELECT @query = 'INSERT INTO #UPR_CONVERTED_tmp(SSD_CF, CUR_CF, CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, UPR, UPR_EUR, CUR_RATE, EUR_RATE)
SELECT a.SSD_CF, a.CUR_CF, a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, ROUND(a.UPR, 3), ROUND((ROUND(a.UPR, 3)) * (b.EXC_R/b2.EXC_R), 3), b.EXC_R, b2.EXC_R
FROM #UPR_RETRIEVAL_tmp a
INNER JOIN BREF..TCURQUOT b ON a.SSD_CF=b.SSD_CF AND a.CUR_CF = b.CUR_CF
INNER JOIN BREF..TCURQUOT b2 ON a.SSD_CF= b2.SSD_CF 
WHERE b.EXC_D = CONVERT(varchar(8), ' + @p_date + ')
AND b2.EXC_D = CONVERT(varchar(8), ' + @p_date + ')
AND b2.CUR_CF = ''EUR'''
EXECUTE(@query)


--Aggregate the UPR amount converted by CSUOE
INSERT INTO #UPR_BY_CSUOE_tmp (CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, UPR)
SELECT CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, SUM(UPR_EUR)
FROM #UPR_CONVERTED_tmp a
GROUP BY CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT

--[001] Check into BCLI..TCLIENT if cl.CLISSD_CF IS NULL
--[002] a.trncod_cf starts with 1A or 1E and t.acmtrsl3_nt = 1051
IF(@norme_cf = 'I17G')
BEGIN
	-- Get CSUOE FP AMOUNT and save them in #FP_RETRIEVAL_tmp
 SELECT @query = 'INSERT INTO #FP_RETRIEVAL_tmp(SSD_CF, CUR_CF, CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, FP)
 SELECT a.SSD_CF, a.CUR_CF, a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.amt_m
 FROM BFAC..TCONTR c
 INNER JOIN BSAR..' + @v_tablename +' a ON  c.CTR_NF = a.CTR_NF AND c.UWY_NF = a.UWY_NF AND c.UW_NT = a.UW_NT AND c.END_NT = a.END_NT
 INNER JOIN  BSAR..TBOPRSLNK t ON t.dettrs_cf = a.trncod_cf
 INNER JOIN BCLI..TCLIENT cl  ON cl.CLI_NF = c.CED_NF
 WHERE c.MULTUWY_NF IS NULL 
 AND t.acmtrsl3_nt = 1051
 AND ((a.trncod_cf LIKE ''1A%'') OR (a.trncod_cf LIKE ''1E%''))
 AND a.lobacc_cf NOT IN (''30'',''31'')
 AND cl.CLISSD_CF IS NULL
 AND ((a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF = ' + SUBSTRING(@p_date, 5, 2) + ' AND a.BALSHRDAY_NF <= ' + SUBSTRING(@p_date, 7, 2) + ')
 OR (a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF < ' + SUBSTRING(@p_date, 5, 2) + ')
 OR (a.BALSHEY_NF < ' + SUBSTRING(@p_date, 1, 4) + '))'
END

--[002] a.trncod_cf starts with 1A or 1E and t.acmtrsl3_nt = 1051
IF(@norme_cf != 'I17G')
BEGIN
	-- Get CSUOE FP AMOUNT and save them in #FP_RETRIEVAL_tmp
 SELECT @query = 'INSERT INTO #FP_RETRIEVAL_tmp(SSD_CF, CUR_CF, CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, FP)
 SELECT a.SSD_CF, a.CUR_CF, a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.amt_m
 FROM BFAC..TCONTR c
 INNER JOIN BSAR..' + @v_tablename +' a ON  c.CTR_NF = a.CTR_NF AND c.UWY_NF = a.UWY_NF AND c.UW_NT = a.UW_NT AND c.END_NT = a.END_NT
 INNER JOIN  BSAR..TBOPRSLNK t ON t.dettrs_cf = a.trncod_cf
 WHERE c.MULTUWY_NF IS NULL 
 AND t.acmtrsl3_nt = 1051
 AND ((a.trncod_cf LIKE ''1A%'') OR (a.trncod_cf LIKE ''1E%''))
 AND a.lobacc_cf NOT IN (''30'',''31'')
 AND ((a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF = ' + SUBSTRING(@p_date, 5, 2) + ' AND a.BALSHRDAY_NF <= ' + SUBSTRING(@p_date, 7, 2) + ')
 OR (a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF < ' + SUBSTRING(@p_date, 5, 2) + ')
 OR (a.BALSHEY_NF < ' + SUBSTRING(@p_date, 1, 4) + '))'
END

EXECUTE(@query)

-- Convert the FP amount in euro
SELECT @query = 'INSERT INTO #FP_CONVERTED_tmp(SSD_CF, CUR_CF, CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, FP, FP_EUR, CUR_RATE, EUR_RATE)
SELECT a.SSD_CF, a.CUR_CF, a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, ROUND(a.FP, 3), ROUND((ROUND(a.FP, 3)) * (b.EXC_R/b2.EXC_R), 3), b.EXC_R, b2.EXC_R
FROM #FP_RETRIEVAL_tmp a
INNER JOIN BREF..TCURQUOT b ON a.SSD_CF=b.SSD_CF AND a.CUR_CF = b.CUR_CF
INNER JOIN BREF..TCURQUOT b2 ON a.SSD_CF= b2.SSD_CF 
WHERE b.EXC_D = CONVERT(varchar(8), ' + @p_date + ')
AND b2.EXC_D = CONVERT(varchar(8), ' + @p_date + ')
AND b2.CUR_CF = ''EUR'''
EXECUTE(@query)


--Aggregate the FP amount converted by CSUOE
INSERT INTO #FP_BY_CSUOE_tmp (CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, FP)
SELECT CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, SUM(FP_EUR)
FROM #FP_CONVERTED_tmp a
GROUP BY CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT


--FULL JOIN LIKE between #FP_BY_CSUOE_tmp and #UPR_BY_CSUOE_tmp
INSERT INTO #UPR_FP_RETRIEVAL_tmp (CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, UPR, FP)
SELECT a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.UPR, b.FP
FROM #UPR_BY_CSUOE_tmp a
LEFT JOIN #FP_BY_CSUOE_tmp b
ON a.CTR_NF = b.CTR_NF AND a.SEC_NF = b.SEC_NF AND a.UWY_NF = b.UWY_NF AND a.UW_NT = b.UW_NT AND a.END_NT = b.END_NT
UNION
SELECT b.CTR_NF, b.SEC_NF, b.UWY_NF, b.UW_NT, b.END_NT, a.UPR, b.FP
FROM #UPR_BY_CSUOE_tmp a
RIGHT JOIN #FP_BY_CSUOE_tmp b
ON a.CTR_NF = b.CTR_NF AND a.SEC_nF= b.SEC_NF AND a.UWY_NF = b.UWY_NF AND a.UW_NT = b.UW_NT AND a.END_NT = b.END_NT


--Extend the perimeter by the commercial relationship
INSERT INTO #CR_RETRIEVAL_tmp
SELECT DISTINCT b.CTR_NF, b.UWY_NF, b.UW_NT, b.END_NT, b.CR_NF, c.CRUWY_NF, c.CRUW_NT
FROM BFAC..TCRCONTR b
INNER JOIN (
	SELECT a.CTR_NF, a.UWY_NF, a.UW_NT, a.END_NT, cr.CR_NF, cr.CRUWY_NF, cr.CRUW_NT
	FROM BFAC..TCRCONTR cr 
	INNER JOIN  #UPR_FP_RETRIEVAL_tmp a
	ON a.CTR_NF = cr.CTR_NF AND a.UWY_NF = cr.UWY_NF AND a.UW_NT = cr.UW_NT AND a.END_NT = cr.END_NT) c
ON b.CR_NF = c.CR_NF AND b.CRUWY_NF = c.CRUWY_NF AND b.CRUW_NT = c.CRUW_NT

-- Sum the UPR and FP amount at Commercial relationship level and keep only CR with ABS(SUM(a.UPR)) >= 1 OR ABS(SUM(a.FP)) >= 1
INSERT INTO #CR_UPR_FP_tmp(CR_NF, CR_UWY_NF, CR_UW_NT, SUM_UPR, SUM_FP)
SELECT b.CR_NF, b.CR_UWY_NF, b.CR_UW_NT, SUM(a.UPR), SUM(a.FP)
FROM #UPR_FP_RETRIEVAL_tmp a
INNER JOIN #CR_RETRIEVAL_tmp b ON a.CTR_NF = b.CTR_NF AND a.UWY_NF = b.UWY_NF AND a.UW_NT = b.UW_NT AND a.END_NT = b.END_NT
GROUP BY b.CR_NF, b.CR_UWY_NF, b.CR_UW_NT
HAVING ABS(SUM(a.UPR)) >= 1 OR ABS(SUM(a.FP)) >= 1

-- Extends the perimeter with the section
INSERT INTO #SECTION_RETRIEVAL_tmp (CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, PRILR_T, CTRPRI_B, CR_NF, CR_UWY_NF, CR_UW_NT)
SELECT a.CTR_NF, b.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, b.PRILR_R, b.CTRPRI_B, a.CR_NF, a.CR_UWY_NF, a.CR_UW_NT
FROM #CR_RETRIEVAL_tmp a
INNER JOIN BFAC..TSECIFRS b ON a.CTR_NF = b.CTR_NF AND a.UWY_NF = b.UWY_NF AND a.UW_NT = b.UW_NT AND a.END_NT = b.END_NT



--insert the omega 2 extract in #OMEGA2EXTRACT_tmp
INSERT INTO #OMEGA2EXTRACT_tmp (
SSD_CF, 
ESB_CF, 
CTR_NF, 
SEC_NF, 
UWY_NF, 
UW_NT, 
END_NT,
RETSSD_CF, 
RETESB_CF, 
RETCTR_NF, 
RETSEC_NF, 
RTY_NF, 
RETUW_NT, 
RETEND_NT,
CTRINC_D, 
CTR_FLAG,
CTR_PROP, 
CLIENT_NF, 
MULTI_YEAR_TO_NF, 
PRILR_T, 
CTRPRI_B, 
CR_NF, 
CR_UWY_NF, 
CR_UW_NT, 
FP, 
UPR, 
FP_CR_LVL, 
UPR_CR_LVL, 
FP_MINUS_UPR)
SELECT 
 c.SSD_CF, 
	c.ACCESB_CF, 
	a.CTR_NF, 
	a.SEC_NF, 
	a.UWY_NF, 
	a.UW_NT, 
	a.END_NT,
	null, --RETSSD_CF for retro P
	null,--RETESB_CF for retro P
 null,--RETCTR_NF for retro P
 null,--RETSEC_NF for retro P
	null,--RTY_NF for retro P
	null,--RETUW_NT for retro P
	null,--RETEND_NT for retro P
	c.CTRINC_D,
	'A',
	null,  -- CTR_PROP for Retro P/NP
	c.ced_nf, 
	c.endmultuwy_nf, 
	a.PRILR_T, 
	a.CTRPRI_B, 
	a.CR_NF, 
	a.CR_UWY_NF, 
	a.CR_UW_NT,
	f.FP, 
	f.UPR,  
	e.SUM_FP, 
	e.SUM_UPR,
 CASE 
     WHEN e.SUM_FP IS NULL THEN -e.SUM_UPR
     WHEN e.SUM_UPR IS NULL  THEN e.SUM_FP
     ELSE e.SUM_FP - e.SUM_UPR
  END 
FROM #SECTION_RETRIEVAL_tmp a
INNER JOIN BFAC..TCONTR c ON a.CTR_NF = c.CTR_NF AND a.uwy_nf = c.uwy_nf AND a.uw_nt = c.uw_nt AND a.END_NT = c.END_NT
INNER JOIN BFAC..TSECTION b ON a.CTR_NF = b.CTR_NF AND a.SEC_NF = b.SEC_NF AND a.UWY_NF = b.UWY_NF AND a.UW_NT = b.UW_NT AND a.END_NT = b.END_NT
INNER JOIN #CR_RETRIEVAL_tmp d ON a.CTR_NF = d.CTR_NF AND a.UWY_NF = d.UWY_NF AND a.UW_NT = d.UW_NT AND a.END_NT = d.END_NT
INNER JOIN #CR_UPR_FP_tmp e ON a.CR_NF = e.CR_NF AND a.CR_UWY_NF = e.CR_UWY_NF AND a.CR_UW_NT = e.CR_UW_NT
LEFT JOIN #UPR_FP_RETRIEVAL_tmp f ON a.CTR_NF = f.CTR_NF AND a.SEC_NF = f.SEC_NF AND a.UWY_NF = f.UWY_NF AND a.UW_NT = f.UW_NT AND a.END_NT = f.END_NT
WHERE  c.multuwy_nf IS NULL
AND b.SECSTS_CT IN (14, 16, 17, 18, 19)
AND c.CTRSTS_CT  IN (14, 16, 17, 18, 19)
ORDER BY a.CR_NF, a.CR_UWY_NF, a.UW_NT, c.ctr_nf, a.sec_nf, c.uwy_nf, c.uw_nt, c.end_nt 



GO

if object_id('PsOmegaExtract_FAC') is not null
	print '<<< CREATED PROC PsOmegaExtract_FAC >>>'
else
	print '<<< FAILED CREATING PROC PsOmegaExtract_FAC >>>'
go

grant execute on PsOmegaExtract_FAC TO GOMEGA
go

grant execute on PsOmegaExtract_FAC TO GDBBATCH
go