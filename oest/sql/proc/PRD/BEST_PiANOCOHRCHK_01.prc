USE BEST
go
IF OBJECT_ID('PiANOCOHRCHK_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PiANOCOHRCHK_01
    IF OBJECT_ID('PiANOCOHRCHK_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PiANOCOHRCHK_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PiANOCOHRCHK_01 >>>'
END
go
/*
* creation de la procedure
*/

CREATE PROCEDURE PiANOCOHRCHK_01(
        @p_ssd_cf       USSD_CF,
        @p_usr_cf       UUSR_CF,
		@p_mess_n   int=0,					 
		@p_data_tpye   char(6),
		@p_closingd	datetime,
		@p_per_cf CHAR(4)
                )

with execute as caller as
       
  /***************************************************

Programme: BEST_PiANOCOHRCHK_01.prc

Domaine : Estimation

Base principale : BEST
Version: 1
Auteur: KBagwe
Date de creation: 06/12/2018

Description du programme:
Control of consistency for Expense ratio, Risk Adjustment, Fund with held 

MODIFICATION 
MOD01:11/09/2019:81060#REQ 04.01 - RA factor loaded but not stored
MOD02:10/10/2019:79785#REQ 04.01 change name of BTRAV..TRARAT to BTRAV..ESID0901_TRARAT
MOD03: 13/10/2022:105375#I17S discount pattern load
MOD04: 24/01/2023:104623#REQ 03.03.01 - I17P/I17L Error in the loading of LKR/FWD curves with multiple subledgers
MOD05: 17/08/2023: #110088 DIP/Omega interface activation - FCI - updates have to be done all at once so because Non DIP0 cant update DIP0 record, it will end all the process if encountered
MOD06: 18/03/2024 FCI: Spira#110445 - Interface DIP - manual upload should not overwrite DIP data_____________________________________________________________________________________________________________  _____________________________________________________________________________________________________________  
*****************************************************************************************************************************************************/

CREATE TABLE #TCTRANO
(
    CTR_NF     UCTR_NF       NOT NULL,
    END_NT     UEND_NT       NOT NULL,
    SEC_NF     USEC_NF       NOT NULL,
    VRS_NF     numeric(10,0) NOT NULL,
    SSD_CF     USSD_CF       NOT NULL,
    SEGTYP_CT  USEGTYP_CT    DEFAULT '' NOT NULL,
    SEG_NF     USEG_NF       DEFAULT '' NOT NULL,
    ANO_CT     int           NOT NULL,
    NUMLINE_NT int           DEFAULT 0  NOT NULL,
    UWY_NF     UUWY_NF       NULL,
    ACY_NF     smallint      NULL
)

CREATE TABLE #NormRef
(
    NORM_NF     varchar(6)       NOT NULL,
)

insert into #NormRef (NORM_NF)
values ('I17G')
insert into #NormRef (NORM_NF)
values ('I17P')
insert into #NormRef (NORM_NF)
values ('I17L')
insert into #NormRef (NORM_NF)		--MOD03
values ('I17S')						--MOD03

DECLARE @erreur      int,
        @tran_imbr   bit,
        @line_num    int,
        @tempo decimal(18,9),
		@NBANO_NT	int, 
	    @NBLNKO_NT	int,
	    @currentdate datetime,
		@p_patcat char(3)

if  @p_data_tpye = 'FHNI'
	select @p_patcat = 'CSF'
else
	select @p_patcat = 'DSC'
        
select @erreur = 0
select @tran_imbr = 1

select @currentdate = getdate()

delete BEST..TCTRANO
where   SSD_CF = @p_ssd_cf
AND     SEG_NF = @p_usr_cf
AND 	SEGTYP_CT = 'S'

 
--MOD[001] Start   
if @p_mess_n > 0
begin
		
	INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF ) 
    VALUES ( convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  @p_mess_n, 0, NULL, NULL )
 
    select @erreur = @@error
    if @erreur != 0  goto fin2
 
    goto fin
end   


IF (@p_data_tpye = 'RA')
BEGIN
/*------------------------------------------------------------------------------*/
/*        Check Duplicate Rows                */
/*                         =>   ANO_CT= 21014                                      */
/*------------------------------------------------------------------------------*/
INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF ) 
	select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  21014, LINE_NF, NULL, NULL  FROM BTRAV..ESID0901_TRARAT
	WHERE USR_CF = @p_usr_cf
	group by SSD_CF, ESB_CF ,SEG_NF ,NORME_CF ,CTRNAT_CT, DOMAIN_CF,USR_CF    --MOD01
	having count(*) > 1            
               
SELECT @erreur = @@error
IF @erreur != 0  GOTO fin2


/*------------------------------------------------------------------------------*/
/*   MOD05               Control on DIP files      SPIRA#110088                 */
/*                       PiRaRatio_01											*/
/*                         =>   ANO_CT= 811                                   */
/*------------------------------------------------------------------------------*/

	INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF )
	select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  811, A.LINE_NF, NULL, NULL  FROM BTRAV..ESID0901_TRARAT A, BEST..TRARAT B 
	WHERE
	A.SSD_CF = B.SSD_CF AND
	A.ESB_CF = B.ESB_CF AND			
	A.SEG_NF = B.SEG_NF  AND
	A.NORME_CF  = B.NORME_CF AND
	A.CTRNAT_CT = B.CTRNAT_CT AND
	B.CLODAT_D = @p_closingd AND
	B.PER_CF = @p_per_cf AND
	B.LSTUPDUSR_CF = 'DIP0' AND A.USR_CF != 'DIP0'
	

END
 
IF (@p_data_tpye = 'RATIO')
BEGIN
/*------------------------------------------------------------------------------*/
/*        Check Duplicate Rows                */
/*                         =>   ANO_CT= 21014                                      */
/*------------------------------------------------------------------------------*/
INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF ) 
	select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  21014, LINE_NF, UWY_NF, NULL  FROM BTRAV..TEXPRAT
	WHERE USR_CF = @p_usr_cf
	group by SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, USR_CF, UWY_NF  --MOD01
	having count(*) > 1
                
               
SELECT @erreur = @@error
IF @erreur != 0  GOTO fin2

/*------------------------------------------------------------------------------*/
/*   MOD05               Control on DIP files      SPIRA#110088                 */
/*                       PiExpratio_01											*/
/*                         =>   ANO_CT= 811                                   */
/*------------------------------------------------------------------------------*/
	INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF )
	select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  811, A.LINE_NF, A.UWY_NF, NULL  FROM BTRAV..TEXPRAT A, BEST..TEXPRAT B  
	WHERE
	A.SSD_CF = B.SSD_CF AND
	A.ESB_CF = B.ESB_CF AND			
	A.SEG_NF = B.SEG_NF  AND
	A.NORME_CF  = B.NORME_CF AND
	A.CTRNAT_CT = B.CTRNAT_CT AND
	A.UWY_NF = B.UWY_NF AND
	B.CLODAT_D = @p_closingd AND
	B.PER_CF = @p_per_cf AND
	B.LSTUPDUSR_CF = 'DIP0' AND 
	A.USR_CF != 'DIP0'
	

END

IF (@p_data_tpye = 'FHNI')
BEGIN
/*------------------------------------------------------------------------------*/
/*        Check Duplicate Rows                */
/*                         =>   ANO_CT= 21014                                      */
/*------------------------------------------------------------------------------*/
INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF ) 
	select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  21014, LINE_NF, NULL, NULL  FROM BTRAV..ESID0901_TFHWRATIO
	WHERE USR_CF = @p_usr_cf
	group by SSD_CF, SEG_NF, LOB_CF, NORME_CF, PATTYP_CT, CUR_CF ,USR_CF	--MOD01
	having count(*) > 1
                
               
SELECT @erreur = @@error
IF @erreur != 0  GOTO fin2

END

--MOD004[START]
IF (@p_data_tpye = 'LKR' OR @p_data_tpye = 'FWD')
BEGIN
/*------------------------------------------------------------------------------*/
/*        Check Duplicate Rows                */
/*                         =>   ANO_CT= 21014                                      */
/*------------------------------------------------------------------------------*/
INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF ) 
	select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  21014, LINE_NF, NULL, NULL  FROM BTRAV..ESID0901_TFHWRATIO
	WHERE USR_CF = @p_usr_cf
	group by SSD_CF, SEG_NF, ESB_CF, LOB_CF, NORME_CF, PATTYP_CT, CUR_CF ,USR_CF
	having count(*) > 1
                
               
SELECT @erreur = @@error
IF @erreur != 0  GOTO fin2

END
--MOD004[END]

IF (@p_data_tpye = 'FHNI' OR @p_data_tpye = 'LKR' OR @p_data_tpye = 'FWD')
BEGIN

/*------------------------------------------------------------------------------*/
/*        Check No-valide NORME                */
/*                         =>   ANO_CT= 20030                                     */
/*------------------------------------------------------------------------------*/
INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF ) 
	select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  20030, LINE_NF, NULL, NULL  FROM BTRAV..ESID0901_TFHWRATIO a
	WHERE USR_CF = @p_usr_cf and a.NORME_CF not in (select b.NORM_NF from #NormRef b )
	group by SSD_CF, SEG_NF, LOB_CF, NORME_CF, PATTYP_CT, CUR_CF ,USR_CF		--MOD01

                
               
SELECT @erreur = @@error
IF @erreur != 0  GOTO fin2

/*------------------------------------------------------------------------------*/
/*   MOD05               Control on DIP files      SPIRA#110088                 */
/*                       PiFhwLKIRatio_01 (LKR)									*/
/*                       PiFhwFHNIUWDRatio_01 (FHNI/FWD)						*/
/*                         =>   ANO_CT= 811                                   */
/*------------------------------------------------------------------------------*/
	IF (@p_data_tpye = 'LKR')
		INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF )
		select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  811, B.LINE_NF, NULL, NULL  FROM BEST..TPATTERNSII A , BTRAV..ESID0901_TFHWRATIO B
		WHERE
		isnull(A.SSD_CF, 0 ) = isnull(B.SSD_CF, 0 ) AND
		isnull(A.ESB_CF, 0 ) = isnull(B.ESB_CF, 0) AND			
		isnull(A.CUR_CF, '' ) = isnull(B.CUR_CF, '') AND
		isnull(A.NORME_CF, '' ) = isnull(B.NORME_CF, '') AND
		A.PATTYP_CT = B.PATTYP_CT AND
		A.RATEINDEX_CT = B.LOB_CF AND
		A.CREUSR_CF = 'DIP0' AND B.USR_CF != 'DIP0' AND
		EXISTS 
		( SELECT 1 FROM BEST..TPATTERNSII A , BEST..TPATSEGSII C 
		  WHERE A.RATEINDEX_CT= C.RATEINDEX_CT AND A.PATTERN_ID = C.PATTERN_ID AND A.PATCAT_CT = C.PATCAT_CT  AND A.PATTYP_CT =C.PATTYP_CT
				AND isnull(A.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 ) AND isnull(A.ESB_CF, 0 ) = isnull(C.ESB_CF, 0) 
				AND isnull(A.CUR_CF, '' ) = isnull(C.CUR_CF, '') AND isnull(A.NORME_CF, '' ) = isnull(C.NORME_CF, '')			
				AND C.CLODAT_D = @p_closingd AND C.PER_CF = @p_per_cf
				AND C.CREUSR_CF = 'DIP0'
		) 	


	ELSE	
		INSERT INTO #tctrano ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF )
		select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_ssd_cf, 'S', @p_usr_cf,  811, B.LINE_NF, NULL, NULL  FROM BEST..TPATTERNSII A , BTRAV..ESID0901_TFHWRATIO B
		WHERE
		isnull(A.SSD_CF, 0 ) = isnull(B.SSD_CF, 0 ) AND
		isnull(A.ESB_CF, 0 ) = isnull(B.ESB_CF, 0) AND			
		isnull(A.CUR_CF, '' ) = isnull(B.CUR_CF, '') AND
		isnull(A.NORME_CF, '' ) = isnull(B.NORME_CF, '') AND
		A.PATTYP_CT = B.PATTYP_CT AND
		A.RATEINDEX_CT = B.LOB_CF AND
		A.CREUSR_CF = 'DIP0' AND B.USR_CF != 'DIP0' AND
		EXISTS 
		( SELECT 1 FROM BEST..TPATTERNSII A , BEST..TPATSEGSII C 
		  WHERE A.RATEINDEX_CT= C.RATEINDEX_CT AND A.PATTERN_ID = C.PATTERN_ID AND A.PATCAT_CT = C.PATCAT_CT  AND A.PATTYP_CT =C.PATTYP_CT
				AND isnull(A.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 ) AND isnull(A.ESB_CF, 0 ) = isnull(C.ESB_CF, 0)
				AND isnull(A.CUR_CF, '' ) = isnull(C.CUR_CF, '') AND isnull(A.NORME_CF, '' ) = isnull(C.NORME_CF, '')				
				AND C.CLODAT_D = @p_closingd AND C.PER_CF = @p_per_cf
				AND C.CREUSR_CF = 'DIP0'
				AND A.PATCAT_CT = @p_patcat 
		) 
	
END

IF EXISTS( SELECT NULL FROM #tctrano ) GOTO fin


/********************************************************************************/
/*                                                                              */
/*                  Fin normale de la proc                                      */
/*                                                                              */
/********************************************************************************/
SELECT 0
RETURN 0

fin2:
select 1
return 1

fin:
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


--
 
INSERT BEST..TCTRANO
(
  CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF
)
SELECT CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, UWY_NF, ACY_NF
FROM #tctrano
 
IF @tran_imbr = 0
         COMMIT TRAN


SELECT 1
RETURN 1
go
EXEC sp_procxmode 'PiANOCOHRCHK_01', 'unchained'
go
IF OBJECT_ID('PiANOCOHRCHK_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PiANOCOHRCHK_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PiANOCOHRCHK_01 >>>'
go
GRANT EXECUTE ON PiANOCOHRCHK_01 TO GOMEGA
go
GRANT EXECUTE ON PiANOCOHRCHK_01 TO GDBBATCH
go
