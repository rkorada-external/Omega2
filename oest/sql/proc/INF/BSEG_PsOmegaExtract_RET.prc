use BSEG
go

if object_id('PsOmegaExtract_RET') is not null
	begin
		drop procedure PsOmegaExtract_RET
		if object_id('PsOmegaExtract_RET') is not null
			print '<<< FAILED DROPPING procedure PsOmegaExtract_RET >>>'
		else
			print '<<< DROPPED procedure PsOmegaExtract_RET >>>'
	end
go

create procedure PsOmegaExtract_RET
  (
   @p_date     varchar(8),
   @p_erreur 		varchar(64)= null output
  )
as

/***************************************************
Domaine : (ES) Estimation
Base principale : BSEG
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation: 22/06/2020
Description du programme:
    feed #OMEGA2EXTRACT_tmp with retro omega extract. #OMEGA2EXTRACT_tmp is a temporary table generated in the calling stored procedure BEST_PsOmega2Extract.prc
Parametres:
	@p_date     varchar(8)
 @p_erreur 		 varchar(64)=null output
*****************************************************/


/********************************************************************************
*************************  RETRO PROPORTIONAL PART **************************
********************************************************************************/
/*
IF OBJECT_ID('tempdb..#RETRO_P_tmp') IS NOT NULL DROP TABLE tempdb..#RETRO_P_tmp 
CREATE TABLE #RETRO_P_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	ESB_CF		UESB_CF		NOT NULL,
	CTR_NF		UCTR_NF		NOT NULL,
	SEC_NF		USEC_NF		NOT NULL,
	UWY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT		NOT NULL,
	END_NT		UEND_NT		NOT NULL,
	RETSSD_CF USSD_CF NOT NULL,
	RETESB_CF		UESB_CF		NOT NULL,
	RETCTR_NF		UCTR_NF   	NOT NULL,
	RETSEC_NF		USEC_NF  	NOT NULL,
	RTY_NF			UUWY_NF		NOT NULL,
	RETUW_NT		UUW_NT		NOT NULL,
	RETEND_NT	UEND_NT		NOT NULL,
	CTRINCUWY_D datetime NULL
)

-- Using BRET..TCESSION retrieve the CSUOE Retro P linked to the Assum perimeter generated in BSEG_PsOmegaExtract_FAC and BSEG_PsOmegaExtract_TRT.prc ans stored in #OMEGA2EXTRACT_tmp
INSERT INTO #RETRO_P_tmp (SSD_CF, ESB_CF, CTR_NF, SEC_NF, UWY_NF, UW_NT, END_NT, RETSSD_CF, RETESB_CF, RETCTR_NF, RETSEC_NF, RTY_NF, RETUW_NT, RETEND_NT, CTRINCUWY_D)
SELECT a.SSD_CF, a.ESB_CF, a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT, a.END_NT, c.SSD_CF, c.ESB_CF, b.RETCTR_NF, b.RETSEC_NF, b.RTY_NF, 0, 1, c.CTRINCUWY_D
FROM #OMEGA2EXTRACT_tmp a
INNER JOIN BRET..TCESSION b
ON a.CTR_NF = b.CTR_NF AND a.SEC_NF = b.SEC_NF AND a.UWY_NF = b.UWY_NF AND a.UW_NT = b.UW_NT
INNER JOIN BRET..TRETCTR c ON c.RETCTR_NF = b.RETCTR_NF AND c.RTY_NF = b.RTY_NF
WHERE ((b.cesupdtyp_cf='' AND b.cessts_cf='01') OR (b.cesupdtyp_cf='S' AND b.cessts_cf='03'))
AND b.CESSIONCAT_CF= '1'
ORDER BY b.RETCTR_NF, b.RETSEC_NF, b.RTY_NF

-- Store the retro P contract in #OMEGA2EXTRACT_tmp
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
	b.SSD_CF, 
	b.ESB_CF, 
	b.CTR_NF, 
	b.SEC_NF, 
	b.UWY_NF, 
	b.UW_NT, 
	b.END_NT, 
	b.RETSSD_CF,
	b.RETESB_CF,
	b.RETCTR_NF, 
	b.RETSEC_NF, 
	b.RTY_NF, 
	b.RETUW_NT, 
	b.RETEND_NT, 
	b.CTRINCUWY_D, 
	'R', 
	'P', 
	null, 
	null, 
	null, 
	null,
 null,
	b.UWY_NF, 
	null, 
	null,
	null,
	null, 
	null, 
	null
FROM #RETRO_P_tmp b
*/
/********************************************************************************
*************************  RETRO NON PROPORTIONAL PART **************************
********************************************************************************/

IF OBJECT_ID('tempdb..#UPR_RETRIEVAL_tmp ') IS NOT NULL DROP TABLE tempdb..#UPR_RETRIEVAL_tmp 
CREATE TABLE #UPR_RETRIEVAL_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	RETCUR_CF		UCUR_CF		NOT NULL,
	RETCTR_NF		UCTR_NF		NOT NULL,
	RETSEC_NF		USEC_NF		NOT NULL,
	RTY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	UPR			UAMT_M		NOT NULL
)

IF OBJECT_ID('tempdb..#UPR_CONVERTED_tmp ') IS NOT NULL DROP TABLE tempdb..#UPR_CONVERTED_tmp 
CREATE TABLE #UPR_CONVERTED_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	RETCUR_CF		UCUR_CF		NOT NULL,
	RETCTR_NF		UCTR_NF		NOT NULL,
	RETSEC_NF		USEC_NF		NOT NULL,
	RTY_NF		UUWY_NF		NOT NULL,
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
	RETCTR_NF		UCTR_NF		NOT NULL,
	RETSEC_NF		USEC_NF		NOT NULL,
	RTY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	UPR			UAMT_M		NOT NULL
)

IF OBJECT_ID('tempdb..#FP_RETRIEVAL_tmp ') IS NOT NULL DROP TABLE tempdb..#FP_RETRIEVAL_tmp 
CREATE TABLE #FP_RETRIEVAL_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	RETCUR_CF		UCUR_CF		NOT NULL,
	RETCTR_NF		UCTR_NF		NOT NULL,
	RETSEC_NF		USEC_NF		NOT NULL,
	RTY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	FP			UAMT_M		NOT NULL
)

IF OBJECT_ID('tempdb..#FP_CONVERTED_tmp ') IS NOT NULL DROP TABLE tempdb..#FP_CONVERTED_tmp 
CREATE TABLE #FP_CONVERTED_tmp 
(
	SSD_CF		USSD_CF		NOT NULL,
	RETCUR_CF		UCUR_CF		NOT NULL,
	RETCTR_NF		UCTR_NF		NOT NULL,
	RETSEC_NF		USEC_NF		NOT NULL,
	RTY_NF		UUWY_NF		NOT NULL,
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
	RETCTR_NF		UCTR_NF		NOT NULL,
	RETSEC_NF		USEC_NF		NOT NULL,
	RTY_NF		UUWY_NF		NOT NULL,
	UW_NT		UUW_NT   	NOT NULL,
	END_NT		UEND_NT  	NOT NULL,
	FP			UAMT_M		NOT NULL
)

IF OBJECT_ID('tempdb..#UPR_FP_RETRIEVAL_tmp ') IS NOT NULL DROP TABLE tempdb..#UPR_FP_RETRIEVAL_tmp 
CREATE TABLE #UPR_FP_RETRIEVAL_tmp 
(
	RETCTR_NF			UCTR_NF		NOT NULL,
	RETSEC_NF			USEC_NF		NOT NULL,
	RTY_NF			UUWY_NF		NOT NULL,
	UW_NT			UUW_NT  NOT NULL,
	END_NT			UEND_NT  NOT NULL,
	UPR			UAMT_M	NULL,
	FP			UAMT_M	NULL
)

IF OBJECT_ID('tempdb..#UPR_FP_CU_LVL_tmp ') IS NOT NULL DROP TABLE tempdb..#UPR_FP_CU_LVL_tmp 
CREATE TABLE #UPR_FP_CU_LVL_tmp 
(
	RETCTR_NF			UCTR_NF		NOT NULL,
	RTY_NF			UUWY_NF		NOT NULL,
	UPR			UAMT_M	NULL,
	FP			UAMT_M	NULL
)

IF OBJECT_ID('tempdb..#SECTION_RETRIEVAL_tmp') IS NOT NULL DROP TABLE tempdb..#SECTION_RETRIEVAL_tmp
CREATE TABLE #SECTION_RETRIEVAL_tmp
(
	RETCTR_NF			UCTR_NF			NOT NULL,
	RETSEC_NF			USEC_NF			NULL,
	RTY_NF			UUWY_NF			NOT NULL,
	UW_NT			UUW_NT     NOT NULL,
	END_NT			UEND_NT    NOT NULL
)

DECLARE
@v_tablename char (20), -- the table name depends on the date in input parameter
@query varchar(2000) -- the query depends on the @v_tablename

-- we retrieve the TTECLADR table to use depending on the input parameter @p_date
SELECT @v_tablename = p.TABCIBLE_CF FROM BSAR..TBOPAR p WHERE p.TAB_CF = 'TTECLEDR' AND p.FIELD2_CF = @p_date


--UPR
SELECT @query = 'INSERT INTO #UPR_RETRIEVAL_tmp(SSD_CF, RETCUR_CF, RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, UPR)
SELECT a.SSD_CF, a.RETCUR_CF, a.RETCTR_NF, a.RETSEC_NF, a.RETRTY_NF, 1, 0, a.RETAMT_M
FROM BRET..TRETCTR c
INNER JOIN BSAR..' + @v_tablename + ' a ON  c.RETCTR_NF = a.RETCTR_NF AND c.RTY_NF = a.RETRTY_NF
INNER JOIN  BSAR..TBOPRSLNK t ON t.dettrs_cf = a.trncod_cf
WHERE a.NATRET_CF IN (''30'',''31'',''32'',''40'',''41'')
AND ((a.trncod_cf LIKE ''21%'') OR (a.trncod_cf LIKE ''24%''))
AND a.LOBRET_CF NOT IN (''30'',''31'')
AND t.acmtrsl3_nt = 1030
AND t.trntyp_ct < 100
AND ((a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF = ' + SUBSTRING(@p_date, 5, 2) + ' AND a.BALSHRDAY_NF <= ' + SUBSTRING(@p_date, 7, 2) + ')
OR (a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF < ' + SUBSTRING(@p_date, 5, 2) + ')
OR (a.BALSHEY_NF < ' + SUBSTRING(@p_date, 1, 4) + '))'
EXECUTE(@query) 




SELECT @query = 'INSERT INTO #UPR_CONVERTED_tmp(SSD_CF, RETCUR_CF, RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, UPR, UPR_EUR, CUR_RATE, EUR_RATE)
SELECT a.SSD_CF, a.RETCUR_CF, a.RETCTR_NF, a.RETSEC_NF, a.RTY_NF, a.UW_NT, a.END_NT, ROUND(a.UPR, 3), ROUND((ROUND(a.UPR, 3)) * (b.EXC_R/b2.EXC_R), 3), b.EXC_R, b2.EXC_R
FROM #UPR_RETRIEVAL_tmp a
INNER JOIN BREF..TCURQUOT b ON a.SSD_CF=b.SSD_CF AND a.RETCUR_CF = b.CUR_CF
INNER JOIN BREF..TCURQUOT b2 ON a.SSD_CF= b2.SSD_CF 
WHERE b.EXC_D = CONVERT(varchar(8), ' + @p_date + ')
AND b2.EXC_D = CONVERT(varchar(8), ' + @p_date + ')
AND b2.CUR_CF = ''EUR'''
EXECUTE(@query)


INSERT INTO #UPR_BY_CSUOE_tmp (RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, UPR)
SELECT RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, SUM(UPR_EUR)
FROM #UPR_CONVERTED_tmp a
GROUP BY RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT

--FP
SELECT @query = 'INSERT INTO #FP_RETRIEVAL_tmp(SSD_CF, RETCUR_CF, RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, FP)
SELECT a.SSD_CF, a.RETCUR_CF, a.RETCTR_NF, a.RETSEC_NF, a.RETRTY_NF, 1, 0, a.RETAMT_M
FROM BRET..TRETCTR c
INNER JOIN BSAR..' + @v_tablename + ' a ON  c.RETCTR_NF = a.RETCTR_NF AND c.RTY_NF = a.RETRTY_NF
INNER JOIN  BSAR..TBOPRSLNK t ON t.dettrs_cf = a.trncod_cf
WHERE a.NATRET_CF in (''30'',''31'',''32'',''40'',''41'') 
AND ((a.trncod_cf LIKE ''2A%'') OR (a.trncod_cf LIKE ''2E%''))
AND a.LOBRET_CF NOT IN (''30'',''31'')
AND t.acmtrsl3_nt = 1051
AND ((a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF = ' + SUBSTRING(@p_date, 5, 2) + ' AND a.BALSHRDAY_NF <= ' + SUBSTRING(@p_date, 7, 2) + ')
OR (a.BALSHEY_NF = ' + SUBSTRING(@p_date, 1, 4) + ' AND a.BALSHRMTH_NF < ' + SUBSTRING(@p_date, 5, 2) + ')
OR (a.BALSHEY_NF < ' + SUBSTRING(@p_date, 1, 4) + '))'
EXECUTE(@query)

SELECT @query = 'INSERT INTO #FP_CONVERTED_tmp(SSD_CF, RETCUR_CF, RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, FP, FP_EUR, CUR_RATE, EUR_RATE)
SELECT a.SSD_CF, a.RETCUR_CF, a.RETCTR_NF, a.RETSEC_NF, a.RTY_NF, a.UW_NT, a.END_NT, ROUND(a.FP, 3), ROUND((ROUND(a.FP, 3)) * (b.EXC_R/b2.EXC_R), 3), b.EXC_R, b2.EXC_R
FROM #FP_RETRIEVAL_tmp a
INNER JOIN BREF..TCURQUOT b ON a.SSD_CF=b.SSD_CF AND a.RETCUR_CF = b.CUR_CF
INNER JOIN BREF..TCURQUOT b2 ON a.SSD_CF= b2.SSD_CF 
WHERE b.EXC_D = CONVERT(varchar(8), ' + @p_date + ')
AND b2.EXC_D = CONVERT(varchar(8), ' + @p_date + ')
AND b2.CUR_CF = ''EUR'''
EXECUTE(@query)

INSERT INTO #FP_BY_CSUOE_tmp (RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, FP)
SELECT RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, SUM(FP_EUR)
FROM #FP_CONVERTED_tmp a
GROUP BY RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT

INSERT INTO #UPR_FP_RETRIEVAL_tmp (RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT, UPR, FP)
SELECT a.RETCTR_NF, a.RETSEC_NF, a.RTY_NF, a.UW_NT, a.END_NT, a.UPR, b.FP
FROM #UPR_BY_CSUOE_tmp a
LEFT JOIN #FP_BY_CSUOE_tmp b
ON a.RETCTR_NF = b.RETCTR_NF AND a.RETSEC_NF= b.RETSEC_NF AND a.RTY_NF = b.RTY_NF AND a.UW_NT = b.UW_NT AND a.END_NT = b.END_NT
UNION
SELECT b.RETCTR_NF, b.RETSEC_NF, b.RTY_NF, b.UW_NT, b.END_NT, a.UPR, b.FP
FROM #UPR_BY_CSUOE_tmp a
RIGHT JOIN #FP_BY_CSUOE_tmp b
ON a.RETCTR_NF = b.RETCTR_NF AND a.RETSEC_nF= b.RETSEC_NF AND a.RTY_NF = b.RTY_NF AND a.UW_NT = b.UW_NT AND a.END_NT = b.END_NT


INSERT INTO #UPR_FP_CU_LVL_tmp(RETCTR_NF, RTY_NF, UPR, FP)
SELECT a.RETCTR_NF, a.RTY_NF, SUM(a.UPR), SUM(a.FP)
FROM #UPR_FP_RETRIEVAL_tmp a
GROUP BY a.RETCTR_NF, a.RTY_NF
HAVING ABS(SUM(a.UPR)) >= 1 OR ABS(SUM(a.FP)) >= 1


INSERT INTO #SECTION_RETRIEVAL_tmp (RETCTR_NF, RETSEC_NF, RTY_NF, UW_NT, END_NT)
SELECT a.RETCTR_NF, c.RETSEC_NF, a.RTY_NF, a.UW_NT, a.END_NT
FROM #UPR_FP_RETRIEVAL_tmp a
INNER JOIN BRET..TRETSEC c ON a.RETCTR_NF = c.RETCTR_NF AND a.RTY_NF = c.RTY_NF
GROUP BY  a.RETCTR_NF, c.RETSEC_NF, a.RTY_NF, a.UW_NT, a.END_NT

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
	b.SSD_CF, 
	b.ESB_CF,
	a.RETCTR_NF, 
	a.RETSEC_NF, 
	a.RTY_NF, 
	a.UW_NT, 
	a.END_NT, 
	NULL, --SSD_CF
	NULL, --ESB_CF
	NULL, --CTR_NF
	NULL, --SEC_NF
	NULL, --UWY_NF
	NULL, --UW_NT
	NULL, --END_NT
	b.CTRINCUWY_D, 
	'R',
 'N', 
	NULL, 
	NULL, 
	c.PRICEDLR_R, 
	c.PRICEDCTR_B, 
	NULL, 
	a.RTY_NF, 
	NULL, 
	d.FP, 
	d.UPR, 
	e.FP, 
	e.UPR, 
	CASE 
     WHEN e.FP IS NULL THEN -e.UPR
     WHEN e.UPR IS NULL  THEN e.FP
     ELSE e.FP - e.UPR
 END
FROM #SECTION_RETRIEVAL_tmp a
INNER JOIN BRET..TRETCTR b ON b.RETCTR_NF = a.RETCTR_NF AND b.RTY_NF = a.RTY_NF
LEFT JOIN BRET..TRETIFRS c ON c.RETCTR_NF = a.RETCTR_NF AND c.RTY_NF = a.RTY_NF
INNER JOIN #UPR_FP_RETRIEVAL_tmp d ON a.RETCTR_NF = d.RETCTR_NF AND a.RETSEC_NF = d.RETSEC_NF AND a.RTY_NF = d.RTY_NF
INNER JOIN #UPR_FP_CU_LVL_tmp e ON a.RETCTR_NF = e.RETCTR_NF AND a.RTY_NF = e.RTY_NF
WHERE b.RETCTRSTS_CT IN (3, 19)


GO

if object_id('PsOmegaExtract_RET') is not null
	print '<<< CREATED PROC PsOmegaExtract_RET >>>'
else
	print '<<< FAILED CREATING PROC PsOmegaExtract_RET >>>'
go

grant execute on PsOmegaExtract_RET TO GOMEGA
go

grant execute on PsOmegaExtract_RET TO GDBBATCH
go