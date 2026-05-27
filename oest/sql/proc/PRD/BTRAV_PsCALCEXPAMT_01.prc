USE BTRAV
GO

IF OBJECT_ID('PsCalcExpAmt_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PsCalcExpAmt_01
    IF OBJECT_ID('PsCalcExpAmt_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsCalcExpAmt_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsCalcExpAmt_01 >>>'
END
GO

CREATE PROCEDURE PsCalcExpAmt_01
WITH EXECUTE AS CALLER AS

/*

	Author:	Parth
	Date:	24/09/2018

*/
-- MODIFICATION HISTORY

CREATE TABLE #DISCOUNT
(
	ROW_ID				INT				IDENTITY,
	CROW_NO				INT				NOT NULL,
	SSD_CF				USSD_CF			NULL,
	ESB_CF				UESB_CF			NULL,
	BALSHEY_NF			smallint		NULL,
	BALSHRMTH_NF		tinyint			NULL,
	BALSHRDAY_NF		tinyint			NULL,
	TRNCOD_CF			UDETTRS_CF		NULL,
	DBLTRNCOD_CF		UDETTRS_CF		NULL,
	CTR_NF				UCTR_NF			NULL,
	END_NT				UEND_NT			NULL,
	SEC_NF				USEC_NF			NULL,
	UWY_NF				UUWY_NF			NULL,
	UW_NT				UUW_NT			NULL,
	OCCYEA_NF			smallint		NULL,
	ACY_NF				smallint		NULL,
	SCOSTRMTH_NF		tinyint			NULL,
	SCOENDMTH_NF		tinyint			NULL,
	CLM_NF				int				NULL,
	CUR_CF				UCUR_CF			NULL,
	AMT_MC				decimal(18, 3)	NULL,
	CED_NF				UCLI_NF			NULL,
	BRK_NF				UCLI_NF			NULL,
	PAY_NF				UCLI_NF			NULL,
	KEY_CF				varchar(2)		NULL,
	RETCTR_NF			URETCTR_NF		NULL,
	RETEND_NT			tinyint			NULL,
	RETSEC_NF			URETSEC_NF		NULL,
	RTY_NF				UUWY_NF			NULL,
	RETUW_NT			tinyint			NULL,
	RETOCCYEA_NF		smallint		NULL,
	RETACY_NF			smallint		NULL,
	RETSCOSTRMTH_NF		tinyint			NULL,
	RETSCOENDMTH_NF		tinyint			NULL,
	RCLM_NF				int				NULL,
	RETCUR_CF			UCUR_CF			NULL,
	RETAMT_MC			decimal(18, 3)	NULL,
	PLC_NT				UPLC_NT			NULL,
	RTO_NF				UCLI_NF			NULL,
	INT_NF				UCLI_NF			NULL,
	RETPAY_NF			UCLI_NF			NULL,
	RETKEY_CF			varchar(2)		NULL,
	RETINTAMT_MC		decimal(18, 3)	NULL,
	ACMTRS_NT			smallint		NULL,
	ACMAMT_MC			decimal(18, 3)	NULL,
	ACMCUR_CF			UCUR_CF			NULL,
	PRS_CF				smallint		NULL,
	SEG_NF				USEG_NF			NULL,
	LOB_CF				ULOB_CF			NULL,
	NAT_CF				UCTRNAT_CF		NULL,
	CTRTYP_CT			UCTRNAT_CF		NULL,
	NORME_CF			varchar(14)		NULL,
	PNAT_CF 			UCTRNAT_CF		NULL,
	PNORME_CF			varchar(14)		NULL,
	RATING_CF  			char(5)       	NULL,
    PATCAT_CT  			char(5)       	NULL,
	PATTYP_CT			varchar(5)		NULL,
    PATTERN_ID			varchar(21)   	NULL,
	AN1        			decimal(18, 3) 	NULL,
    AN2        			decimal(18, 3) 	NULL,
    AN3        			decimal(18, 3) 	NULL,
    AN4        			decimal(18, 3) 	NULL,
    AN5        			decimal(18, 3) 	NULL,
    AN6        			decimal(18, 3) 	NULL,
    AN7        			decimal(18, 3) 	NULL,
    AN8        			decimal(18, 3) 	NULL,
    AN9        			decimal(18, 3) 	NULL,
    AN10       			decimal(18, 3) 	NULL,
    AN11       			decimal(18, 3) 	NULL,
    AN12       			decimal(18, 3) 	NULL,
    AN13       			decimal(18, 3) 	NULL,
    AN14       			decimal(18, 3) 	NULL,
    AN15       			decimal(18, 3) 	NULL,
    AN16       			decimal(18, 3) 	NULL,
    AN17       			decimal(18, 3) 	NULL,
    AN18       			decimal(18, 3) 	NULL,
    AN19       			decimal(18, 3) 	NULL,
    AN20       			decimal(18, 3) 	NULL,
    AN21       			decimal(18, 3) 	NULL,
    AN22       			decimal(18, 3) 	NULL,
    AN23       			decimal(18, 3) 	NULL,
    AN24       			decimal(18, 3) 	NULL,
    AN25       			decimal(18, 3) 	NULL,
    AN26       			decimal(18, 3) 	NULL,
    AN27       			decimal(18, 3) 	NULL,
    AN28       			decimal(18, 3) 	NULL,
    AN29       			decimal(18, 3) 	NULL,
    AN30       			decimal(18, 3) 	NULL,
    AN31       			decimal(18, 3) 	NULL,
    AN32       			decimal(18, 3) 	NULL,
    AN33       			decimal(18, 3) 	NULL,
    AN34       			decimal(18, 3) 	NULL,
    AN35       			decimal(18, 3) 	NULL,
    AN36       			decimal(18, 3) 	NULL,
    AN37       			decimal(18, 3) 	NULL,
    AN38       			decimal(18, 3) 	NULL,
    AN39       			decimal(18, 3) 	NULL,
    AN40       			decimal(18, 3) 	NULL,
    AN41       			decimal(18, 3) 	NULL,
    AN42       			decimal(18, 3) 	NULL,
    AN43       			decimal(18, 3) 	NULL,
    AN44       			decimal(18, 3) 	NULL,
    AN45       			decimal(18, 3) 	NULL,
    AN46       			decimal(18, 3) 	NULL,
    AN47       			decimal(18, 3) 	NULL,
    AN48       			decimal(18, 3) 	NULL,
    AN49       			decimal(18, 3) 	NULL,
    AN50       			decimal(18, 3) 	NULL,
    AN51       			decimal(18, 3) 	NULL,
    AN52       			decimal(18, 3) 	NULL,
    AN53       			decimal(18, 3) 	NULL,
    AN54       			decimal(18, 3) 	NULL,
    AN55       			decimal(18, 3) 	NULL,
    AN56       			decimal(18, 3) 	NULL,
    AN57       			decimal(18, 3) 	NULL,
    AN58       			decimal(18, 3) 	NULL,
    AN59       			decimal(18, 3) 	NULL,
    AN60       			decimal(18, 3) 	NULL,
    AN61       			decimal(18, 3) 	NULL,
    AN62       			decimal(18, 3) 	NULL,
    AN63       			decimal(18, 3) 	NULL,
    AN64       			decimal(18, 3) 	NULL,
    AN65       			decimal(18, 3) 	NULL,
	EXT1				varchar(25)		NULL,
	EXT2				varchar(25)		NULL,
	EXT3				varchar(25)		NULL,
	TOTAL       		decimal(18, 3) 	NULL	
)


CREATE CLUSTERED INDEX IDISCOUNT_00
	ON #DISCOUNT(ROW_ID)

CREATE NONCLUSTERED INDEX IDISCOUNT_01
	ON #DISCOUNT(NORME_CF, PNORME_CF)
	
CREATE NONCLUSTERED INDEX IDISCOUNT_02
	ON #DISCOUNT(NAT_CF, PNAT_CF)
	
CREATE TABLE #RMNTP
(
	ROW_ID				INT				IDENTITY,
	SSD_CF				USSD_CF			NULL,
	ESB_CF				UESB_CF			NULL,
	BALSHEY_NF			smallint		NULL,
	BALSHRMTH_NF		tinyint			NULL,
	BALSHRDAY_NF		tinyint			NULL,
	TRNCOD_CF			UDETTRS_CF		NULL,
	DBLTRNCOD_CF		UDETTRS_CF		NULL,
	CTR_NF				UCTR_NF			NULL,
	END_NT				UEND_NT			NULL,
	SEC_NF				USEC_NF			NULL,
	UWY_NF				UUWY_NF			NULL,
	UW_NT				UUW_NT			NULL,
	OCCYEA_NF			smallint		NULL,
	ACY_NF				smallint		NULL,
	SCOSTRMTH_NF		tinyint			NULL,
	SCOENDMTH_NF		tinyint			NULL,
	CLM_NF				int				NULL,
	CUR_CF				UCUR_CF			NULL,
	AMT_MC				decimal(18, 3)	NULL,
	CED_NF				UCLI_NF			NULL,
	BRK_NF				UCLI_NF			NULL,
	PAY_NF				UCLI_NF			NULL,
	KEY_CF				varchar(2)		NULL,
	RETCTR_NF			URETCTR_NF		NULL,
	RETEND_NT			tinyint			NULL,
	RETSEC_NF			URETSEC_NF		NULL,
	RTY_NF				UUWY_NF			NULL,
	RETUW_NT			tinyint			NULL,
	RETOCCYEA_NF		smallint		NULL,
	RETACY_NF			smallint		NULL,
	RETSCOSTRMTH_NF		tinyint			NULL,
	RETSCOENDMTH_NF		tinyint			NULL,
	RCLM_NF				int				NULL,
	RETCUR_CF			UCUR_CF			NULL,
	RETAMT_MC			decimal(18, 3)	NULL,
	PLC_NT				UPLC_NT			NULL,
	RTO_NF				UCLI_NF			NULL,
	INT_NF				UCLI_NF			NULL,
	RETPAY_NF			UCLI_NF			NULL,
	RETKEY_CF			varchar(2)		NULL,
	RETINTAMT_MC		decimal(18, 3)	NULL,
	ACMTRS_NT			smallint		NULL,
	ACMAMT_MC			decimal(18, 3)	NULL,
	ACMCUR_CF			UCUR_CF			NULL,
	PRS_CF				smallint		NULL,
	SEG_NF				USEG_NF			NULL,
	LOB_CF				ULOB_CF			NULL,
	NAT_CF				UCTRNAT_CF		NULL,
	CTRTYP_CT			UCTRNAT_CF		NULL,
	NORME_CF			varchar(14)		NULL,
	RATING_CF  			char(5)       	NULL,
    PATCAT_CT  			char(5)       	NULL,
	PATTYP_CT			varchar(5)		NULL,
    PATTERN_ID			varchar(21)   	NULL,
	AN1        			decimal(18, 3) 	NULL,
    AN2        			decimal(18, 3) 	NULL,
    AN3        			decimal(18, 3) 	NULL,
    AN4        			decimal(18, 3) 	NULL,
    AN5        			decimal(18, 3) 	NULL,
    AN6        			decimal(18, 3) 	NULL,
    AN7        			decimal(18, 3) 	NULL,
    AN8        			decimal(18, 3) 	NULL,
    AN9        			decimal(18, 3) 	NULL,
    AN10       			decimal(18, 3) 	NULL,
    AN11       			decimal(18, 3) 	NULL,
    AN12       			decimal(18, 3) 	NULL,
    AN13       			decimal(18, 3) 	NULL,
    AN14       			decimal(18, 3) 	NULL,
    AN15       			decimal(18, 3) 	NULL,
    AN16       			decimal(18, 3) 	NULL,
    AN17       			decimal(18, 3) 	NULL,
    AN18       			decimal(18, 3) 	NULL,
    AN19       			decimal(18, 3) 	NULL,
    AN20       			decimal(18, 3) 	NULL,
    AN21       			decimal(18, 3) 	NULL,
    AN22       			decimal(18, 3) 	NULL,
    AN23       			decimal(18, 3) 	NULL,
    AN24       			decimal(18, 3) 	NULL,
    AN25       			decimal(18, 3) 	NULL,
    AN26       			decimal(18, 3) 	NULL,
    AN27       			decimal(18, 3) 	NULL,
    AN28       			decimal(18, 3) 	NULL,
    AN29       			decimal(18, 3) 	NULL,
    AN30       			decimal(18, 3) 	NULL,
    AN31       			decimal(18, 3) 	NULL,
    AN32       			decimal(18, 3) 	NULL,
    AN33       			decimal(18, 3) 	NULL,
    AN34       			decimal(18, 3) 	NULL,
    AN35       			decimal(18, 3) 	NULL,
    AN36       			decimal(18, 3) 	NULL,
    AN37       			decimal(18, 3) 	NULL,
    AN38       			decimal(18, 3) 	NULL,
    AN39       			decimal(18, 3) 	NULL,
    AN40       			decimal(18, 3) 	NULL,
    AN41       			decimal(18, 3) 	NULL,
    AN42       			decimal(18, 3) 	NULL,
    AN43       			decimal(18, 3) 	NULL,
    AN44       			decimal(18, 3) 	NULL,
    AN45       			decimal(18, 3) 	NULL,
    AN46       			decimal(18, 3) 	NULL,
    AN47       			decimal(18, 3) 	NULL,
    AN48       			decimal(18, 3) 	NULL,
    AN49       			decimal(18, 3) 	NULL,
    AN50       			decimal(18, 3) 	NULL,
    AN51       			decimal(18, 3) 	NULL,
    AN52       			decimal(18, 3) 	NULL,
    AN53       			decimal(18, 3) 	NULL,
    AN54       			decimal(18, 3) 	NULL,
    AN55       			decimal(18, 3) 	NULL,
    AN56       			decimal(18, 3) 	NULL,
    AN57       			decimal(18, 3) 	NULL,
    AN58       			decimal(18, 3) 	NULL,
    AN59       			decimal(18, 3) 	NULL,
    AN60       			decimal(18, 3) 	NULL,
    AN61       			decimal(18, 3) 	NULL,
    AN62       			decimal(18, 3) 	NULL,
    AN63       			decimal(18, 3) 	NULL,
    AN64       			decimal(18, 3) 	NULL,
    AN65       			decimal(18, 3) 	NULL,
	EXT1				varchar(25)		NULL,
	EXT2				varchar(25)		NULL,
	EXT3				varchar(25)		NULL,
	TOTAL       		decimal(18, 3) 	NULL
)

CREATE CLUSTERED INDEX IRMNTP_00
	ON #RMNTP(ROW_ID)

CREATE TABLE #STATS
(
	SSD_CF				USSD_CF			NULL,
	ESB_CF				UESB_CF			NULL,
	CTR_NF				UCTR_NF			NULL,
	END_NT				UEND_NT			NULL,
	SEC_NF				USEC_NF			NULL,
	UWY_NF				UUWY_NF			NULL,
	UW_NT				UUW_NT			NULL,
	CUR_CF				UCUR_CF			NULL,
	CED_NF				UCLI_NF			NULL,
	BRK_NF				UCLI_NF			NULL,
	PAY_NF				UCLI_NF			NULL,
	KEY_CF				varchar(2)		NULL,
	RETCTR_NF			URETCTR_NF		NULL,
	RETEND_NT			tinyint			NULL,
	RETSEC_NF			URETSEC_NF		NULL,
	RTY_NF				UUWY_NF			NULL,
	RETUW_NT			tinyint			NULL,
	RETCUR_CF			UCUR_CF			NULL,
	PLC_NT				UPLC_NT			NULL,
	RTO_NF				UCLI_NF			NULL,
	SEG_NF				USEG_NF			NULL,
	ULR_NF				tinyint			NULL,
	WPREMIUM_NF			tinyint			NULL,
	WCHARGES_NF			tinyint			NULL,
	WCLAIM_NF			tinyint			NULL,
	UPR_NF				tinyint			NULL,
	SCOEGP_NF			tinyint			NULL,
	FPREMIUM_NF			tinyint			NULL,
	UCR_NF				tinyint			NULL,
	PRCO_NF				tinyint			NULL,
	PRCI_NF				tinyint			NULL,
	EXT1				tinyint			NULL,
	NORME_CF			varchar(14)		NULL,
	PRMDSC_NF			decimal(18, 3) 	NULL,
	CLMDSC_NF			decimal(18, 3) 	NULL,
	BDTRAT_NF			tinyint			NULL,
	PRMRESD_NF			tinyint			NULL,
	PRMRESB_NF			tinyint			NULL
)


create table #reference
(
	row_no 	int,
	norme_flag	bit,
	nat_flag bit
)

CREATE CLUSTERED INDEX IREF_00
	ON #reference(ROW_NO)

-- Get all data into a temporary table. Inserting identity in BTRAV table would have required a change in structure of input file.
select ROW_NO = identity(8), * into #cumulative
from BTRAV..TGTSII_CUMUL

DECLARE @error 		int
DECLARE @errorMsg	varchar(255)
DECLARE @tranCount	tinyint

IF @@tranCount = 0
    BEGIN
        SELECT @tranCount = 1
        BEGIN TRAN
    END

-- Update currencies in work table as per input from currency file.
update #cumulative
set ACMCUR_CF = ISNULL(CUR.CUR_CF, 'EUR')
FROM #cumulative CUM, BTRAV..TCURSII CUR
WHERE CUM.ACMCUR_CF = CUR.CTY_CF

IF @@error !=  0
BEGIN
		select @error  = 20001, @errorMsg = 'Error in updating currency.'
		goto fin
END

-- Pattern matching based on CURRENCY AND LOB
INSERT INTO #DISCOUNT ( 
						CROW_NO, SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF,
						ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
						RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF,
						RETKEY_CF, RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, PNAT_CF, PNORME_CF, RATING_CF, PATCAT_CT,
						PATTYP_CT, PATTERN_ID, AN1, AN2, AN3, AN4, AN5, AN6, AN7, AN8, AN9, AN10, AN11, AN12, AN13, AN14, AN15, AN16, AN17, AN18, AN19, AN20,
						AN21, AN22, AN23, AN24, AN25, AN26, AN27, AN28, AN29, AN30, AN31, AN32, AN33, AN34, AN35, AN36, AN37, AN38, AN39, AN40, AN41, AN42,
						AN43, AN44, AN45, AN46, AN47, AN48, AN49, AN50, AN51, AN52, AN53, AN54, AN55, AN56, AN57, AN58, AN59, AN60, AN61, AN62, AN63, AN64,
						AN65, EXT1, EXT2, EXT3
					  )
SELECT 	D.ROW_NO, D.SSD_CF, D.ESB_CF, D.BALSHEY_NF, D.BALSHRMTH_NF, D.BALSHRDAY_NF, NULL, D.DBLTRNCOD_CF, D.CTR_NF, D.END_NT, D.SEC_NF, D.UWY_NF, D.UW_NT, D.OCCYEA_NF,
		D.ACY_NF, D.SCOSTRMTH_NF, D.SCOENDMTH_NF, D.CLM_NF, D.CUR_CF, D.AMT_MC, D.CED_NF, D.BRK_NF, D.PAY_NF, D.KEY_CF, D.RETCTR_NF, D.RETEND_NT, D.RETSEC_NF, D.RTY_NF,
		D.RETUW_NT, D.RETOCCYEA_NF, D.RETACY_NF, D.RETSCOSTRMTH_NF, D.RETSCOENDMTH_NF, D.RCLM_NF, D.RETCUR_CF, D.RETAMT_MC, D.PLC_NT, D.RTO_NF, D.INT_NF, D.RETPAY_NF,
		D.RETKEY_CF, D.RETINTAMT_MC, D.ACMTRS_NT, D.ACMAMT_MC, D.ACMCUR_CF, D.PRS_CF, D.SEG_NF, D.LOB_CF, D.NAT_CF, D.CTRTYP_CT, D.NORME_CF, P.SEGNAT_CT, P.NORME_CF, P.RATING_CF,
		P.PATCAT_CT, P.PATTYP_CT, P.PATTERN_ID,
		convert(decimal(18, 3), D.AN1 * P.AN1), convert(decimal(18, 3), D.AN2 * P.AN2), convert(decimal(18, 3), D.AN3 * P.AN3), convert(decimal(18, 3), D.AN4 * P.AN4),
		convert(decimal(18, 3), D.AN5 * P.AN5), convert(decimal(18, 3), D.AN6 * P.AN6), convert(decimal(18, 3), D.AN7 * P.AN7), convert(decimal(18, 3), D.AN8 * P.AN8),
		convert(decimal(18, 3), D.AN9 * P.AN9), convert(decimal(18, 3), D.AN10 * P.AN10), convert(decimal(18, 3), D.AN11 * P.AN11), convert(decimal(18, 3), D.AN12 * P.AN12),
		convert(decimal(18, 3), D.AN13 * P.AN13), convert(decimal(18, 3), D.AN14 * P.AN14), convert(decimal(18, 3), D.AN15 * P.AN15), convert(decimal(18, 3), D.AN16 * P.AN16),
		convert(decimal(18, 3), D.AN17 * P.AN17), convert(decimal(18, 3), D.AN18 * P.AN18), convert(decimal(18, 3), D.AN19 * P.AN19), convert(decimal(18, 3), D.AN20 * P.AN20),
		convert(decimal(18, 3), D.AN21 * P.AN21), convert(decimal(18, 3), D.AN22 * P.AN22), convert(decimal(18, 3), D.AN23 * P.AN23), convert(decimal(18, 3), D.AN24 * P.AN24),
		convert(decimal(18, 3), D.AN25 * P.AN25), convert(decimal(18, 3), D.AN26 * P.AN26), convert(decimal(18, 3), D.AN27 * P.AN27), convert(decimal(18, 3), D.AN28 * P.AN28),
		convert(decimal(18, 3), D.AN29 * P.AN29), convert(decimal(18, 3), D.AN30 * P.AN30), convert(decimal(18, 3), D.AN31 * P.AN31), convert(decimal(18, 3), D.AN32 * P.AN32),
		convert(decimal(18, 3), D.AN33 * P.AN33), convert(decimal(18, 3), D.AN34 * P.AN34), convert(decimal(18, 3), D.AN35 * P.AN35), convert(decimal(18, 3), D.AN36 * P.AN36),
		convert(decimal(18, 3), D.AN37 * P.AN37), convert(decimal(18, 3), D.AN38 * P.AN38), convert(decimal(18, 3), D.AN39 * P.AN39), convert(decimal(18, 3), D.AN40 * P.AN40),
		convert(decimal(18, 3), D.AN41 * P.AN41), convert(decimal(18, 3), D.AN42 * P.AN42), convert(decimal(18, 3), D.AN43 * P.AN43), convert(decimal(18, 3), D.AN44 * P.AN44),
		convert(decimal(18, 3), D.AN45 * P.AN45), convert(decimal(18, 3), D.AN46 * P.AN46), convert(decimal(18, 3), D.AN47 * P.AN47), convert(decimal(18, 3), D.AN48 * P.AN48),
		convert(decimal(18, 3), D.AN49 * P.AN49), convert(decimal(18, 3), D.AN50 * P.AN50), convert(decimal(18, 3), D.AN51 * P.AN51), convert(decimal(18, 3), D.AN52 * P.AN52),
		convert(decimal(18, 3), D.AN53 * P.AN53), convert(decimal(18, 3), D.AN54 * P.AN54), convert(decimal(18, 3), D.AN55 * P.AN55), convert(decimal(18, 3), D.AN56 * P.AN56),
		convert(decimal(18, 3), D.AN57 * P.AN57), convert(decimal(18, 3), D.AN58 * P.AN58), convert(decimal(18, 3), D.AN59 * P.AN59), convert(decimal(18, 3), D.AN60 * P.AN60),
		convert(decimal(18, 3), D.AN61 * P.AN61), convert(decimal(18, 3), D.AN62 * P.AN62), convert(decimal(18, 3), D.AN63 * P.AN63), convert(decimal(18, 3), D.AN64 * P.AN64),
		convert(decimal(18, 3), D.AN65 * P.AN65), CASE WHEN ( CHAR_LENGTH(D.LOB_CF) > 0 ) THEN D.LOB_CF ELSE NULL END, D.ACMCUR_CF, NULL
FROM 	#cumulative D, BTRAV..TPATTERNS P
WHERE D.ACMCUR_CF = P.CUR_CF AND D.LOB_CF = P.LOB_CF

IF @@error !=  0
BEGIN
		select @error  = 20002, @errorMsg = 'Error while inserting in discount table'
		goto fin
END


-- Mark the records with matching NORME and NATURE.
insert into #reference (row_no, norme_flag, nat_flag)
select crow_no, max(case when norme_cf = pnorme_cf then 1 else 0 end), max(case when nat_cf = pnat_cf then 1 else 0 end)
from #discount group by crow_no

IF @@error !=  0
BEGIN
		select @error  = 20003, @errorMsg = 'Error while inserting in reference table'
		goto fin
END

-- Delete other records of matching patterns if NORME and NATURE are also matching.
delete #discount
from #discount a, #reference b
where a.crow_no = b.row_no
and ( (norme_cf != pnorme_cf and norme_flag = 1) or (nat_cf != pnat_Cf and nat_flag = 1) )

IF @@error !=  0
BEGIN
		select @error  = 20004, @errorMsg = 'Error while deleting from discount table'
		goto fin
END
 
update #DISCOUNT set TOTAL = AN1 + AN2 + AN3 + AN4 + AN5 + AN6 + AN7 + AN8 + AN9 + AN10 + AN11 + AN12 + AN13 + AN14 + AN15 + AN16 + AN17 + AN18 + AN19 + AN20 +
							AN21 + AN22 + AN23 + AN24 + AN25 + AN26 + AN27 + AN28 + AN29 + AN30 + AN31 + AN32 + AN33 + AN34 + AN35 + AN36 + AN37 + AN38 + AN39 +
							AN40 + AN41 + AN42 + AN43 + AN44 + AN45 + AN46 + AN47 + AN48 + AN49 + AN50 + AN51 + AN52 + AN53 + AN54 + AN55 + AN56 + AN57 + AN58 +
							AN59 + AN60 + AN61 + AN62 + AN63 + AN64 + AN65

IF @@error !=  0
BEGIN
		select @error  = 20005, @errorMsg = 'Error while updating total of discount table'
		goto fin
END

-- Get all the records from DISCOUNT into REMAIN TO PAY in same order. Makes easy and fast for calculation of amounts in next step.
insert into #RMNTP ( SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF,
						ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
						RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF,
						RETKEY_CF, RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF,
						PATCAT_CT, PATTYP_CT, PATTERN_ID, EXT1, EXT2, EXT3 )
select SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF,
		SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF,
		RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, CASE WHEN ((ACMTRS_NT/100 > 1) AND (ACMTRS_NT/1000 < 1) AND ((ACMTRS_NT/10 = 31) OR (ACMTRS_NT/10 = 30))) THEN 301 ELSE ACMTRS_NT END,
		ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF, PATCAT_CT, PATTYP_CT, PATTERN_ID, EXT1, EXT2, EXT3
from #DISCOUNT ORDER BY ROW_ID ASC

IF @@error !=  0
BEGIN
		select @error  = 20006, @errorMsg = 'Error while inserting data in Remain to Pay table'
		goto fin
END

update #rmntp set AN1 = D.AN1 + D.AN2 + D.AN3 + D.AN4 + D.AN5 + D.AN6 + D.AN7 + D.AN8 + D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN2 = D.AN2 + D.AN3 + D.AN4 + D.AN5 + D.AN6 + D.AN7 + D.AN8 + D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN3 = D.AN3 + D.AN4 + D.AN5 + D.AN6 + D.AN7 + D.AN8 + D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN4 = D.AN4 + D.AN5 + D.AN6 + D.AN7 + D.AN8 + D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN5 = D.AN5 + D.AN6 + D.AN7 + D.AN8 + D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN6 = D.AN6 + D.AN7 + D.AN8 + D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN7 = D.AN7 + D.AN8 + D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN8 = D.AN8 + D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN9 = D.AN9 + D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN10 = D.AN10 + D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN11 = D.AN11 + D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN12 = D.AN12 + D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN13 = D.AN13 + D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN14 = D.AN14 + D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN15 = D.AN15 + D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN16 = D.AN16 + D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN17 = D.AN17 + D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN18 = D.AN18 + D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN19 = D.AN19 + D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN20 = D.AN20 +
							D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN21 = D.AN21 + D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN22 = D.AN22 + D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN23 = D.AN23 + D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN24 = D.AN24 + D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN25 = D.AN25 + D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN26 = D.AN26 + D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN27 = D.AN27 + D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN28 = D.AN28 + D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN29 = D.AN29 + D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN30 = D.AN30 + D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN31 = D.AN31 + D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN32 = D.AN32 + D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN33 = D.AN33 + D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN34 = D.AN34 + D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN35 = D.AN35 + D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN36 = D.AN36 + D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN37 = D.AN37 + D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN38 = D.AN38 + D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN39 = D.AN39 +
							D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN40 = D.AN40 + D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN41 = D.AN41 + D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN42 = D.AN42 + D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN43 = D.AN43 + D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN44 = D.AN44 + D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN45 = D.AN45 + D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN46 = D.AN46 + D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN47 = D.AN47 + D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN48 = D.AN48 + D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN49 = D.AN49 + D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN50 = D.AN50 + D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN51 = D.AN51 + D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN52 = D.AN52 + D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN53 = D.AN53 + D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN54 = D.AN54 + D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN55 = D.AN55 + D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN56 = D.AN56 + D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN57 = D.AN57 + D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN58 = D.AN58 +
							D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN59 = D.AN59 + D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN60 = D.AN60 + D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN61 = D.AN61 + D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN62 = D.AN62 + D.AN63 + D.AN64 + D.AN65,
				  AN63 = D.AN63 + D.AN64 + D.AN65,
				  AN64 = D.AN64 + D.AN65,
				  AN65 = D.AN65
from #RMNTP R, #DISCOUNT D
WHERE R.ROW_ID = D.ROW_ID		

IF @@error !=  0
BEGIN
		select @error = 20007, @errorMsg = 'Error while updating amounts in Remain to Pay table'
		goto fin
END

update #RMNTP set TOTAL = AN1 + AN2 + AN3 + AN4 + AN5 + AN6 + AN7 + AN8 + AN9 + AN10 + AN11 + AN12 + AN13 + AN14 + AN15 + AN16 + AN17 + AN18 + AN19 + AN20 +
							AN21 + AN22 + AN23 + AN24 + AN25 + AN26 + AN27 + AN28 + AN29 + AN30 + AN31 + AN32 + AN33 + AN34 + AN35 + AN36 + AN37 + AN38 + AN39 +
							AN40 + AN41 + AN42 + AN43 + AN44 + AN45 + AN46 + AN47 + AN48 + AN49 + AN50 + AN51 + AN52 + AN53 + AN54 + AN55 + AN56 + AN57 + AN58 +
							AN59 + AN60 + AN61 + AN62 + AN63 + AN64 + AN65
							
IF @@error !=  0
BEGIN
		select @error = 20008, @errorMsg = 'Error while updating total in Remain to Pay table'
		goto fin
END

-- Just keep the select. No need to insert and then again select?
-- Temp table might be required for future use. Keeping it.
INSERT INTO #STATS ( SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CUR_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
			RETCUR_CF, PLC_NT, RTO_NF, SEG_NF, ULR_NF, WPREMIUM_NF, WCHARGES_NF, WCLAIM_NF, UPR_NF, SCOEGP_NF, FPREMIUM_NF, UCR_NF, PRCO_NF, PRCI_NF, EXT1, NORME_CF, PRMDSC_NF,
			CLMDSC_NF, BDTRAT_NF, PRMRESD_NF, PRMRESB_NF )
SELECT 	
		SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CUR_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETCUR_CF,
		PLC_NT, RTO_NF, CASE WHEN ( CHAR_LENGTH(SEG_NF) != 0 ) THEN SEG_NF ELSE ( CASE WHEN ( CHAR_LENGTH(LOB_CF) > 0 ) THEN LOB_CF ELSE NULL END) END, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NORME_CF,
		CASE when (substring(PATTYP_CT, 1, 2) = 'PR' AND (ACMAMT_MC != 0 or ACMAMT_MC IS NOT NULL)) then TOTAL/ACMAMT_MC ELSE 0.0 END, 
		CASE when (substring(PATTYP_CT, 1, 2) = 'CL' AND (ACMAMT_MC != 0 or ACMAMT_MC IS NOT NULL)) then TOTAL/ACMAMT_MC ELSE 0.0 END, 0, 0, 0
FROM #DISCOUNT
WHERE TOTAL != 0

IF @@error !=  0
BEGIN
		select @error = 20009, @errorMsg = 'Error while inserting in STATS table'
		goto fin
END

SELECT
	SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF,
	SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
	RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,
	RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF, PATCAT_CT, PATTYP_CT,
	PATTERN_ID, AN1, AN2, AN3, AN4, AN5, AN6, AN7, AN8, AN9, AN10, AN11, AN12, AN13, AN14, AN15, AN16, AN17, AN18, AN19, AN20, AN21, AN22,
	AN23, AN24, AN25, AN26, AN27, AN28, AN29, AN30, AN31, AN32, AN33, AN34, AN35, AN36, AN37, AN38, AN39, AN40, AN41, AN42, AN43, AN44, AN45,
	AN46, AN47, AN48, AN49, AN50, AN51, AN52, AN53, AN54, AN55, AN56, AN57, AN58, AN59, AN60, AN61, AN62, AN63, AN64, AN65, EXT1, EXT2, EXT3, TOTAL
FROM #DISCOUNT

SELECT 
	SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF,
	SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
	RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,
	RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF, 'BDT', 'RMNTP',
	PATTERN_ID, AN1, AN2, AN3, AN4, AN5, AN6, AN7, AN8, AN9, AN10, AN11, AN12, AN13, AN14, AN15, AN16, AN17, AN18, AN19, AN20, AN21, AN22,
	AN23, AN24, AN25, AN26, AN27, AN28, AN29, AN30, AN31, AN32, AN33, AN34, AN35, AN36, AN37, AN38, AN39, AN40, AN41, AN42, AN43, AN44, AN45,
	AN46, AN47, AN48, AN49, AN50, AN51, AN52, AN53, AN54, AN55, AN56, AN57, AN58, AN59, AN60, AN61, AN62, AN63, AN64, AN65, EXT1, EXT2, EXT3, TOTAL
FROM #RMNTP WHERE CTRTYP_CT = 'R'


SELECT 
	SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CUR_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
	RETCUR_CF, PLC_NT, RTO_NF, SEG_NF, ULR_NF, WPREMIUM_NF, WCHARGES_NF, WCLAIM_NF, UPR_NF, SCOEGP_NF, FPREMIUM_NF, UCR_NF, PRCO_NF, PRCI_NF, EXT1,
	NORME_CF, PRMDSC_NF, CLMDSC_NF, BDTRAT_NF, PRMRESD_NF, PRMRESB_NF
FROM #STATS

if @tranCount = 1
    COMMIT TRAN

return 0


fin:
IF @tranCount = 1
  BEGIN
    ROLLBACK TRAN
	PRINT 'Rolling back data'
  END
RAISERROR @error @errorMsg

return @error
go

EXEC sp_procxmode 'PsCalcExpAmt_01', 'unchained'
go

IF OBJECT_ID('PsCalcExpAmt_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsCalcExpAmt_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsCalcExpAmt_01 >>>'
go

GRANT EXECUTE ON PsCalcExpAmt_01 TO GOMEGA
go
GRANT EXECUTE ON PsCalcExpAmt_01 TO GDBBATCH
go

