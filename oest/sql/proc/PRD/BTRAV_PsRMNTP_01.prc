USE BTRAV
GO

IF OBJECT_ID('PsRMNTP_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PsRMNTP_01
    IF OBJECT_ID('PsRMNTP_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsRMNTP_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsRMNTP_01 >>>'
END
GO

CREATE PROCEDURE PsRMNTP_01 (
	@quarter	tinyint,		-- Quarter of the year
	@patCategory		varchar(5)
)	
WITH EXECUTE AS CALLER AS

/*

	Author:	Parth
	Date:	19/09/2018

*/
-- MODIFICATION HISTORY


CREATE TABLE #RMNTP
(
	ROW_ID				INT				IDENTITY,
	SSD_CF				USSD_CF			NOT NULL,
	ESB_CF				UESB_CF			NOT NULL,
	BALSHEY_NF			smallint		NOT NULL,
	BALSHRMTH_NF		tinyint			NOT NULL,
	BALSHRDAY_NF		tinyint			NOT NULL,
	TRNCOD_CF			UDETTRS_CF		NOT NULL,
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
	EXT1				decimal(18, 3)	NULL,
	EXT2				varchar(25)		NULL,
	EXT3				varchar(25)		NULL,
	TOTAL       		decimal(18, 3) 	NULL
)

CREATE CLUSTERED INDEX IRMNTP_00
	ON #RMNTP(ROW_ID)

CREATE TABLE #RFRBATCH
(
	ROW_ID				INT				IDENTITY,
	SSD_CF				USSD_CF			NOT NULL,
	ESB_CF				UESB_CF			NOT NULL,
	BALSHEY_NF			smallint		NOT NULL,
	BALSHRMTH_NF		tinyint			NOT NULL,
	BALSHRDAY_NF		tinyint			NOT NULL,
	TRNCOD_CF			UDETTRS_CF		NOT NULL,
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
	EXT1				decimal(18, 3)	NULL,
	EXT2				varchar(25)		NULL,
	EXT3				varchar(25)		NULL,
	TOTAL       		decimal(18, 3) 	NULL,
	LASTYEAR			INT				DEFAULT 999				-- Default is used to check if column has been updated.
)

CREATE CLUSTERED INDEX IRFRBATCH_00
	ON #RFRBATCH(ROW_ID)

CREATE NONCLUSTERED INDEX IRFRBATCH_01			
    ON #RFRBATCH(SSD_CF, ESB_CF, PATTYP_CT, NORME_CF, ACMAMT_MC )
	
DECLARE @error 		int
DECLARE @errorMsg	varchar(255)
DECLARE @tranCount	tinyint
DECLARE @coeff1		decimal(3,2)
DECLARE @coeff2		decimal(3,2)
DECLARE @colNum		int
DECLARE @sql 		varchar(1024)
DECLARE @lstYear	int

SELECT @error = 0
SELECT @tranCount = 0

IF @@tranCount = 0
    BEGIN
        SELECT @tranCount = 1
        BEGIN TRAN
    END


IF @quarter = 4
BEGIN
	select @coeff1 = 1.0
	select @coeff2 = 0.0
END
ELSE
BEGIN
	select @coeff1 = (4 - @quarter) / 4.0
	select @coeff2 = (@quarter) / 4.0
END

IF @patCategory = 'ICR  ' OR @patCategory = 'ICR'
BEGIN
	UPDATE BTRAV..TDLCUMGTAAR_IBNR_FUTCLAIMS
	SET PATTYP_CT = 'ICACC'
	WHERE PATTYP_CT LIKE '__ACC'
	
	UPDATE BTRAV..TDLCUMGTAAR_IBNR_FUTCLAIMS
	SET PATTYP_CT = 'ICRET'
	WHERE PATTYP_CT LIKE '__RET'
END

-- Pattern matching based on NORME 
insert into #RFRBATCH ( SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF,
						ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
						RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF,
						RETKEY_CF, RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF,
						PATCAT_CT, PATTYP_CT, PATTERN_ID, AN1, AN2, AN3, AN4, AN5, AN6, AN7, AN8, AN9, AN10, AN11, AN12, AN13, AN14, AN15, AN16, AN17, AN18, AN19,
						AN20, AN21, AN22, AN23, AN24, AN25, AN26, AN27, AN28, AN29, AN30, AN31, AN32, AN33, AN34, AN35, AN36, AN37, AN38, AN39, AN40, AN41, AN42, AN43,
						AN44, AN45, AN46, AN47, AN48, AN49, AN50, AN51, AN52, AN53, AN54, AN55, AN56, AN57, AN58, AN59, AN60, AN61, AN62, AN63, AN64, AN65 ) 
select FUCLM.SSD_CF, FUCLM.ESB_CF , FUCLM.BALSHEY_NF, FUCLM.BALSHRMTH_NF, FUCLM.BALSHRDAY_NF, FUCLM.TRNCOD_CF, FUCLM.DBLTRNCOD_CF, FUCLM.CTR_NF,
		FUCLM.END_NT, FUCLM.SEC_NF, FUCLM.UWY_NF, FUCLM.UW_NT, FUCLM.OCCYEA_NF, FUCLM.ACY_NF, FUCLM.SCOSTRMTH_NF, FUCLM.SCOENDMTH_NF, FUCLM.CLM_NF, FUCLM.CUR_CF,
		FUCLM.AMT_MC, FUCLM.CED_NF, FUCLM.BRK_NF, FUCLM.PAY_NF, FUCLM.KEY_CF, FUCLM.RETCTR_NF, FUCLM.RETEND_NT, FUCLM.RETSEC_NF, FUCLM.RTY_NF,
		FUCLM.RETUW_NT, FUCLM.RETOCCYEA_NF, FUCLM.RETACY_NF, FUCLM.RETSCOSTRMTH_NF, FUCLM.RETSCOENDMTH_NF, FUCLM.RCLM_NF, FUCLM.RETCUR_CF, FUCLM.RETAMT_MC,
		FUCLM.PLC_NT, FUCLM.RTO_NF, FUCLM.INT_NF, FUCLM.RETPAY_NF, FUCLM.RETKEY_CF, FUCLM.RETINTAMT_MC, FUCLM.ACMTRS_NT, FUCLM.ACMAMT_MC, FUCLM.ACMCUR_CF, FUCLM.PRS_CF,
		FUCLM.SEG_NF, FUCLM.LOB_CF, FUCLM.NAT_CF, FUCLM.CTRTYP_CT, FUCLM.NORME_CF, PAT.RATING_CF, PAT.PATCAT_CT, PAT.PATTYP_CT, PAT.PATTERN_ID, 
		convert (decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN1 ) + ( @Coeff2 * PAT.AN2 ))) / case when (( 1 - (PAT.AN1 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN1 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN2 ) + ( @Coeff2 * PAT.AN3 ))) / case when (( 1 - (PAT.AN2 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN2 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN3 ) + ( @Coeff2 * PAT.AN4 ))) / case when (( 1 - (PAT.AN3 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN3 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN4 ) + ( @Coeff2 * PAT.AN5 ))) / case when (( 1 - (PAT.AN4 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN4 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN5 ) + ( @Coeff2 * PAT.AN6 ))) / case when (( 1 - (PAT.AN5 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN5 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN6 ) + ( @Coeff2 * PAT.AN7 ))) / case when (( 1 - (PAT.AN6 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN6 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN7 ) + ( @Coeff2 * PAT.AN8 ))) / case when (( 1 - (PAT.AN7 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN7 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN8 ) + ( @Coeff2 * PAT.AN9 ))) / case when (( 1 - (PAT.AN8 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN8 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN9 ) + ( @Coeff2 * PAT.AN10 ))) / case when (( 1 - (PAT.AN9 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN9 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN10 ) + ( @Coeff2 * PAT.AN11 ))) / case when (( 1 - (PAT.AN10 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN10 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN11 ) + ( @Coeff2 * PAT.AN12 ))) / case when (( 1 - (PAT.AN11 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN11 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN12 ) + ( @Coeff2 * PAT.AN13 ))) / case when (( 1 - (PAT.AN12 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN12 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN13 ) + ( @Coeff2 * PAT.AN14 ))) / case when (( 1 - (PAT.AN13 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN13 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN14 ) + ( @Coeff2 * PAT.AN15 ))) / case when (( 1 - (PAT.AN14 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN14 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN15 ) + ( @Coeff2 * PAT.AN16 ))) / case when (( 1 - (PAT.AN15 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN15 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN16 ) + ( @Coeff2 * PAT.AN17 ))) / case when (( 1 - (PAT.AN16 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN16 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN17 ) + ( @Coeff2 * PAT.AN18 ))) / case when (( 1 - (PAT.AN17 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN17 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN18 ) + ( @Coeff2 * PAT.AN19 ))) / case when (( 1 - (PAT.AN18 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN18 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN19 ) + ( @Coeff2 * PAT.AN20 ))) / case when (( 1 - (PAT.AN19 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN19 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN20 ) + ( @Coeff2 * PAT.AN21 ))) / case when (( 1 - (PAT.AN20 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN20 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN21 ) + ( @Coeff2 * PAT.AN22 ))) / case when (( 1 - (PAT.AN21 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN21 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN22 ) + ( @Coeff2 * PAT.AN23 ))) / case when (( 1 - (PAT.AN22 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN22 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN23 ) + ( @Coeff2 * PAT.AN24 ))) / case when (( 1 - (PAT.AN23 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN23 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN24 ) + ( @Coeff2 * PAT.AN25 ))) / case when (( 1 - (PAT.AN24 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN24 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN25 ) + ( @Coeff2 * PAT.AN26 ))) / case when (( 1 - (PAT.AN25 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN25 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN26 ) + ( @Coeff2 * PAT.AN27 ))) / case when (( 1 - (PAT.AN26 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN26 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN27 ) + ( @Coeff2 * PAT.AN28 ))) / case when (( 1 - (PAT.AN27 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN27 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN28 ) + ( @Coeff2 * PAT.AN29 ))) / case when (( 1 - (PAT.AN28 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN28 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN29 ) + ( @Coeff2 * PAT.AN30 ))) / case when (( 1 - (PAT.AN29 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN29 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN30 ) + ( @Coeff2 * PAT.AN31 ))) / case when (( 1 - (PAT.AN30 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN30 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN31 ) + ( @Coeff2 * PAT.AN32 ))) / case when (( 1 - (PAT.AN31 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN31 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN32 ) + ( @Coeff2 * PAT.AN33 ))) / case when (( 1 - (PAT.AN32 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN32 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN33 ) + ( @Coeff2 * PAT.AN34 ))) / case when (( 1 - (PAT.AN33 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN33 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN34 ) + ( @Coeff2 * PAT.AN35 ))) / case when (( 1 - (PAT.AN34 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN34 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN35 ) + ( @Coeff2 * PAT.AN36 ))) / case when (( 1 - (PAT.AN35 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN35 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN36 ) + ( @Coeff2 * PAT.AN37 ))) / case when (( 1 - (PAT.AN36 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN36 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN37 ) + ( @Coeff2 * PAT.AN38 ))) / case when (( 1 - (PAT.AN37 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN37 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN38 ) + ( @Coeff2 * PAT.AN39 ))) / case when (( 1 - (PAT.AN38 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN38 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN39 ) + ( @Coeff2 * PAT.AN40 ))) / case when (( 1 - (PAT.AN39 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN39 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN40 ) + ( @Coeff2 * PAT.AN41 ))) / case when (( 1 - (PAT.AN40 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN40 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN41 ) + ( @Coeff2 * PAT.AN42 ))) / case when (( 1 - (PAT.AN41 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN41 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN42 ) + ( @Coeff2 * PAT.AN43 ))) / case when (( 1 - (PAT.AN42 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN42 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN43 ) + ( @Coeff2 * PAT.AN44 ))) / case when (( 1 - (PAT.AN43 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN43 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN44 ) + ( @Coeff2 * PAT.AN45 ))) / case when (( 1 - (PAT.AN44 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN44 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN45 ) + ( @Coeff2 * PAT.AN46 ))) / case when (( 1 - (PAT.AN45 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN45 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN46 ) + ( @Coeff2 * PAT.AN47 ))) / case when (( 1 - (PAT.AN46 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN46 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN47 ) + ( @Coeff2 * PAT.AN48 ))) / case when (( 1 - (PAT.AN47 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN47 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN48 ) + ( @Coeff2 * PAT.AN49 ))) / case when (( 1 - (PAT.AN48 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN48 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN49 ) + ( @Coeff2 * PAT.AN50 ))) / case when (( 1 - (PAT.AN49 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN49 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN50 ) + ( @Coeff2 * PAT.AN51 ))) / case when (( 1 - (PAT.AN50 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN50 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN51 ) + ( @Coeff2 * PAT.AN52 ))) / case when (( 1 - (PAT.AN51 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN51 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN52 ) + ( @Coeff2 * PAT.AN53 ))) / case when (( 1 - (PAT.AN52 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN52 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN53 ) + ( @Coeff2 * PAT.AN54 ))) / case when (( 1 - (PAT.AN53 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN53 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN54 ) + ( @Coeff2 * PAT.AN55 ))) / case when (( 1 - (PAT.AN54 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN54 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN55 ) + ( @Coeff2 * PAT.AN56 ))) / case when (( 1 - (PAT.AN55 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN55 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN56 ) + ( @Coeff2 * PAT.AN57 ))) / case when (( 1 - (PAT.AN56 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN56 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN57 ) + ( @Coeff2 * PAT.AN58 ))) / case when (( 1 - (PAT.AN57 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN57 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN58 ) + ( @Coeff2 * PAT.AN59 ))) / case when (( 1 - (PAT.AN58 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN58 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN59 ) + ( @Coeff2 * PAT.AN60 ))) / case when (( 1 - (PAT.AN59 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN59 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN60 ) + ( @Coeff2 * PAT.AN61 ))) / case when (( 1 - (PAT.AN60 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN60 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN61 ) + ( @Coeff2 * PAT.AN62 ))) / case when (( 1 - (PAT.AN61 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN61 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN62 ) + ( @Coeff2 * PAT.AN63 ))) / case when (( 1 - (PAT.AN62 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN62 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN63 ) + ( @Coeff2 * PAT.AN64 ))) / case when (( 1 - (PAT.AN63 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN63 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * (( @Coeff1 * PAT.AN64 ) + ( @Coeff2 * PAT.AN65 ))) / case when (( 1 - (PAT.AN64 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN64 * @Coeff2  )) end),
		convert(decimal(18,3), (FUCLM.ACMAMT_MC * @Coeff1 * PAT.AN65 ) / case when (( 1 - (PAT.AN65 * @Coeff2 )) = 0) then 1 else ( 1 - (PAT.AN65 * @Coeff2  )) end)

from BTRAV..TDLCUMGTAAR_IBNR_FUTCLAIMS FUCLM JOIN BTRAV..TPATTERNS PAT
ON FUCLM.SSD_CF = PAT.SSD_CF AND FUCLM.PATTYP_CT = PAT.PATTYP_CT 
	AND (FUCLM.NORME_CF = PAT.SEGUWY_CF 
	OR (SUBSTRING(PAT.SEG_NF, 1, 1) = '*' AND PAT.UWY_NF = convert(int, substring(FUCLM.NORME_CF, char_length(FUCLM.NORME_CF)-3, 4)))
	OR FUCLM.NORME_CF = PAT.LOBUWY_CF)

IF @@error !=  0
BEGIN
		select @error  = 30001, @errorMsg = 'Error while insertion in temp table RFRBATCH'
		goto fin
END

-- Get all the records from RFRBATCH into REMAIN TO PAY in same order. Makes faster calculation of amounts.
insert into #RMNTP ( SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF,
						ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
						RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF,
						RETKEY_CF, RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF,
						PATCAT_CT, PATTYP_CT, PATTERN_ID )
select SSD_CF, ESB_CF , BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF,
		SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF,
		RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, ACMTRS_NT,
		ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF, PATCAT_CT, 'RMNTP', PATTERN_ID
from #RFRBATCH ORDER BY ROW_ID 

IF @@error !=  0
BEGIN
		select @error  = 30002, @errorMsg = 'Error while insertion in temp table RMNTP'
		goto fin
END


SELECT @colNum = 1

-- Keep track of the FIRST year number for which the amount is 0.
WHILE @colNum != 65
BEGIN
	
	select @sql = 'update #RFRBATCH set lastyear = ' + convert(varchar(2), @colNum) + ' where AN' + convert(varchar(2), @colNum) + '= 0 and lastyear = 999'
	
	exec(@sql)
	
	IF @@error !=  0
	BEGIN
		select @error  = 30003, @errorMsg = 'Error while updating lastyear ' + convert(varchar(2), @colNum)
		goto fin
	END	
	
	select @colNum = @colNum + 1

END

-- TOTAL calculation is done before update of FIRST zero amount because the formula requires TOTAL amount. 
update #RFRBATCH set TOTAL = AN1 + AN2 + AN3 + AN4 + AN5 + AN6 + AN7 + AN8 + AN9 + AN10 + AN11 + AN12 + AN13 + AN14 + AN15 + AN16 + AN17 + AN18 + AN19 + AN20 +
							AN21 + AN22 + AN23 + AN24 + AN25 + AN26 + AN27 + AN28 + AN29 + AN30 + AN31 + AN32 + AN33 + AN34 + AN35 + AN36 + AN37 + AN38 + AN39 +
							AN40 + AN41 + AN42 + AN43 + AN44 + AN45 + AN46 + AN47 + AN48 + AN49 + AN50 + AN51 + AN52 + AN53 + AN54 + AN55 + AN56 + AN57 + AN58 +
							AN59 + AN60 + AN61 + AN62 + AN63 + AN64 + AN65

IF @@error !=  0
BEGIN
	select @error  = 30004, @errorMsg = 'Error while updating total in RFRBATCH'
	goto fin
END	
							
DECLARE gtsIcr CURSOR for
select distinct lastyear from #RFRBATCH

open gtsIcr

fetch gtsIcr into @lstyear

while @@sqlstatus != 2
begin
	
	select @sql = 'update #RFRBATCH set AN' + convert(varchar(2), @lstyear) + ' = AN' + convert(varchar(2), @lstyear) + ' + ACMAMT_MC - TOTAL where lastyear = ' + convert(varchar(2), @lstyear)
	
	exec(@sql)
	
	IF @@error !=  0
	BEGIN
		select @error  = 30005, @errorMsg = 'Error while updating first zero amount in RFRBATCH'
		goto fin
	END	
	
	fetch gtsIcr into @lstyear
	
end

close gtsIcr
deallocate gtsIcr

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
from #RMNTP R, #RFRBATCH D
WHERE R.ROW_ID = D.ROW_ID	

IF @@error !=  0
BEGIN
	select @error  = 30006, @errorMsg = 'Error while updating amounts in Remain to pay'
	goto fin
END	

update #RMNTP set TOTAL = AN1 + AN2 + AN3 + AN4 + AN5 + AN6 + AN7 + AN8 + AN9 + AN10 + AN11 + AN12 + AN13 + AN14 + AN15 + AN16 + AN17 + AN18 + AN19 + AN20 +
							AN21 + AN22 + AN23 + AN24 + AN25 + AN26 + AN27 + AN28 + AN29 + AN30 + AN31 + AN32 + AN33 + AN34 + AN35 + AN36 + AN37 + AN38 + AN39 +
							AN40 + AN41 + AN42 + AN43 + AN44 + AN45 + AN46 + AN47 + AN48 + AN49 + AN50 + AN51 + AN52 + AN53 + AN54 + AN55 + AN56 + AN57 + AN58 +
							AN59 + AN60 + AN61 + AN62 + AN63 + AN64 + AN65

IF @@error !=  0
BEGIN
	select @error  = 30007, @errorMsg = 'Error while updating total in Remain to pay'
	goto fin
END	
							
-- Patterns not matched
insert into #RFRBATCH (SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF,
						ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
						RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF,
						RETKEY_CF, RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF,
						PATCAT_CT, PATTYP_CT, PATTERN_ID, EXT1, EXT2, EXT3, TOTAL)
select FUCLM.SSD_CF, FUCLM.ESB_CF , FUCLM.BALSHEY_NF, FUCLM.BALSHRMTH_NF, FUCLM.BALSHRDAY_NF, FUCLM.TRNCOD_CF, FUCLM.DBLTRNCOD_CF, FUCLM.CTR_NF,
		FUCLM.END_NT, FUCLM.SEC_NF, FUCLM.UWY_NF, FUCLM.UW_NT, FUCLM.OCCYEA_NF, FUCLM.ACY_NF, FUCLM.SCOSTRMTH_NF, FUCLM.SCOENDMTH_NF, FUCLM.CLM_NF, FUCLM.CUR_CF,
		FUCLM.AMT_MC, FUCLM.CED_NF, FUCLM.BRK_NF, FUCLM.PAY_NF, FUCLM.KEY_CF, FUCLM.RETCTR_NF, FUCLM.RETEND_NT, FUCLM.RETSEC_NF, FUCLM.RTY_NF,
		FUCLM.RETUW_NT, FUCLM.RETOCCYEA_NF, FUCLM.RETACY_NF, FUCLM.RETSCOSTRMTH_NF, FUCLM.RETSCOENDMTH_NF, FUCLM.RCLM_NF, FUCLM.RETCUR_CF, FUCLM.RETAMT_MC,
		FUCLM.PLC_NT, FUCLM.RTO_NF, FUCLM.INT_NF, FUCLM.RETPAY_NF, FUCLM.RETKEY_CF, FUCLM.RETINTAMT_MC, FUCLM.ACMTRS_NT, FUCLM.ACMAMT_MC, FUCLM.ACMCUR_CF, FUCLM.PRS_CF,
		FUCLM.SEG_NF, FUCLM.LOB_CF, FUCLM.NAT_CF, FUCLM.CTRTYP_CT, NULL, NULL, @patCategory, FUCLM.PATTYP_CT, ' ', FUCLM.ACMAMT_MC, '0', 'Pattern non trouvee', FUCLM.ACMAMT_MC
from BTRAV..TDLCUMGTAAR_IBNR_FUTCLAIMS FUCLM
where not exists (select 1 from #rfrbatch r where fuclm.ssd_Cf = r.ssd_cf and fuclm.pattyp_Ct = r.pattyp_ct and fuclm.norme_cf = r.norme_cf and 
				fuclm.esb_cf = r.esb_cf and fuclm.balshey_nf = r.balshey_nf and fuclm.balshrmth_nf = r.balshrmth_nf and fuclm.balshrday_nf = r.balshrday_nf and
					fuclm.acmamt_mc = r.acmamt_mc and fuclm.acmcur_cf = r.acmcur_cf)

IF @@error !=  0
BEGIN
	select @error  = 30008, @errorMsg = 'Error while inserting pattern NOT MATCHED data'
	goto fin
END	

select 
	SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF,
	SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
	RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,
	RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, '', RATING_CF, PATCAT_CT, PATTYP_CT,
	PATTERN_ID, AN1, AN2, AN3, AN4, AN5, AN6, AN7, AN8, AN9, AN10, AN11, AN12, AN13, AN14, AN15, AN16, AN17, AN18, AN19, AN20, AN21, AN22,
	AN23, AN24, AN25, AN26, AN27, AN28, AN29, AN30, AN31, AN32, AN33, AN34, AN35, AN36, AN37, AN38, AN39, AN40, AN41, AN42, AN43, AN44, AN45,
	AN46, AN47, AN48, AN49, AN50, AN51, AN52, AN53, AN54, AN55, AN56, AN57, AN58, AN59, AN60, AN61, AN62, AN63, AN64, AN65, EXT1, EXT2, EXT3, TOTAL
from #RFRBATCH

select 
	SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF,
	SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
	RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCLM_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,
	RETINTAMT_MC, ACMTRS_NT, ACMAMT_MC, ACMCUR_CF, PRS_CF, SEG_NF, LOB_CF, NAT_CF, CTRTYP_CT, NORME_CF, RATING_CF, PATCAT_CT, PATTYP_CT,
	PATTERN_ID, AN1, AN2, AN3, AN4, AN5, AN6, AN7, AN8, AN9, AN10, AN11, AN12, AN13, AN14, AN15, AN16, AN17, AN18, AN19, AN20, AN21, AN22,
	AN23, AN24, AN25, AN26, AN27, AN28, AN29, AN30, AN31, AN32, AN33, AN34, AN35, AN36, AN37, AN38, AN39, AN40, AN41, AN42, AN43, AN44, AN45,
	AN46, AN47, AN48, AN49, AN50, AN51, AN52, AN53, AN54, AN55, AN56, AN57, AN58, AN59, AN60, AN61, AN62, AN63, AN64, AN65, EXT1, EXT2, EXT3, TOTAL
from #RMNTP
where CTRTYP_CT = 'A' AND ACMTRS_NT in (3114, 3115)

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


EXEC sp_procxmode 'PsRMNTP_01', 'unchained'
go

IF OBJECT_ID('PsRMNTP_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsRMNTP_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsRMNTP_01 >>>'
go

GRANT EXECUTE ON PsRMNTP_01 TO GOMEGA
go
GRANT EXECUTE ON PsRMNTP_01 TO GDBBATCH
go

