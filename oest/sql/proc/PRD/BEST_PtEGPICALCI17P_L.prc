use BEST
go
if object_id('PtEGPICALCI17P_L') is not null
begin
  drop PROC PtEGPICALCI17P_L
  print '<<< DROPPED PROC PtEGPICALCI17P_L >>>'
end
go

create procedure PtEGPICALCI17P_L
(
	@p_Norme     char(5),
	@p_sgttyp_nt int,
	@p_segtyp_ct char(1),
	@p_erreur varchar(64)=null output
)
with execute as caller as

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BTRT
Auteur                  : Charles SOCIE
Date de creation        : 13/03/2019
Description du programme: Calculation of EGPI
Conditions d'execution  : ESEJ2051
Commentaires            :
_________________
MODIFICATIONS
MOD01:14/1/2020: Arnaud R: spira 83926
MOD02:12/03/2020:KBagwe: Spira#84246
MOD03:20/07/2020:KBagwe: Spira#87460
MOD04:02/12/2020:KBagwe:91591: Main lob batch update
MOD05:08/03/2021:K Bhimasen:92910:IFRS 17 - Errors in the determination of I17 segment
MOD06:28/04/2021:K Bhimasen: Spira#95981
MOD07:08/10/2021:K Bhimasen: 99582: UAT contrats avec main lob vide
MOD08:22/12/2021:K Bhimasen: 101019: Main LOB - EGPI nil
MOD09:24/02/2021:K Bhimasen: 101140: IFRS17 - Main lob batch force segment to 1 for I17L ans I17P by error
MOD010:04/03/2024:FCI: spira#109951 I17 Local - Missing local I17 intialization
*****************************************************/

declare @err int, @rowcnt int, @labl char(40)
declare @temp char(4), @curdate char(10)
                 
SELECT @temp=convert(char(4),YEAR(getdate())-1 )
SELECT @curdate = @temp+"1231"

--select @labl = "Multi LoB + IT Server of contract " + substring(suser_name(), 3, 2)
select @labl = "Multi LoB"

--MOD05[START]
DECLARE @p_proc_return INT, @dec_clodat_d DATETIME, @dec_per_cf CHAR (3), @dec_ret VARCHAR (64)

DECLARE @dec_ifrs17 CHAR (6), @p_date DATETIME 

select @p_date = getdate()

SELECT @dec_ifrs17 = ''
--MOD05[END]

CREATE TABLE #CTR(
	SSD_CF 			 USSD_CF  	NULL,
    CTR_NF           UCTR_NF    NOT NULL,
    END_NT           UEND_NT    NULL,
    SEC_NF           USEC_NF    NULL,
    UWY_NF           UUWY_NF    NULL,
    UW_NT            UUW_NT     NULL,
    NORME_CF 		 char(5) 	NULL,
	SGTTYP_NT 		 USGTTYP_NT NOT NULL,	
	SGMT_NF 		 USGMT_NF   NOT NULL,
	SCOGLOEGP_M 	 UAMT_M 	NULL,
	CONVEGPI_M 	 	 UAMT_M 	NULL,
	ESB_CF			 UESB_CF 	NULL, 
	LIACUR_CF		 UCUR_CF	NULL,
	LOBTHRHLD_R 	USHORAT_R NULL, 
	EGPITHRHLD_M 	UAMT_M NULL, 
	CUR_CF 			UCUR_CF		NULL,
	CONVERAMOUNT_B  BIT 		DEFAULT 0,
	SRCRATE	 		ULNGDEC 	NULL,
	DSTRATE			ULNGDEC 	NULL,
	UWORG_CF		smallint    NULL,
	CLIENTNUMBER    UCLI_NF     NULL,
	CR_NF CHAR(10) NOT NULL,
	DIV_NT UDIV_NT NOT NULL,
	CTRTYP_CT CHAR(1) NOT NULL,
	CLISSD_CF USSD_CF NULL,
	SGTVER_NT int NOT NULL,
	SGT_NT    int NOT NULL,
	SGTLVL_NT int NOT NULL,
	CRUWY_NF UUWY_NF NOT NULL,
    CRUW_NT         UUW_NT NOT NULL,
	STATUWY_NF 		char(8) 	NOT NULL		--MOD05
)

CREATE TABLE #CTRNEWEGPI(
	SGMT_NF 		 	 USGMT_NF      NOT NULL,
	TOTALEGPICR_M 	 	 UAMT_M NULL,				--Total EGPI CR
	TOTALEGPICRLOB_M	 UAMT_M NULL,				--Total EGPI CR/LOB
	POURCENTAGEEGPI_R    USHORAT_R  NULL,
	LOBTHRHLD_R    USHORAT_R  NULL,
	TOTALEGPITHRHD_M	 UAMT_M NULL,
	MAINLOB 			 CHAR(10)	   NULL,
	MAINLOBORG			 CHAR(10)	   NULL,
	IFRS17SEGMENT		 varchar(64)   NULL,
	IFRS17SEGMENTORG	 varchar(64)   NULL,
	CR_NF 				 CHAR(10) NOT NULL,
	MAXTOTALEGPICRLOB_M	 UAMT_M NULL	,			--MAX EGPI CR/LOB
	ROWSEL_B		     BIT DEFAULT 0,
	SGTVER_NT INT NOT NULL,
	SGMT_LS	UL16 NULL,
	SGMT_LL	UL64 NULL,
	SGT_NT    INT NOT NULL,
	SGTLVL_NT INT NOT NULL,
	CRUWY_NF UUWY_NF NOT NULL,
   	CRUW_NT         UUW_NT NOT NULL
)
	 
	 
--MOD08[START]	
UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET SCOGLOEGP_M = 1
	WHERE SGTTYP_NT = @p_sgttyp_nt AND CTRTYP_CT = @p_segtyp_ct
	AND (isnull(SCOGLOEGP_M,0) =0  or SIGN(SCOGLOEGP_M) = -1)
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  raiserror 20020 "20020 : Error on Update ESEJ2050_TSEGRUNRES"
	  return 1
	end	
	print 'Update ESEJ2050_TSEGRUNRES for SCOGLOEGP_M is null / negative / zero : %1!' , @rowcnt	
--MOD08[END] 



--MOD05[START]
EXECUTE
    @p_proc_return =
    BREF..PsCALEND_EBS
        @p_date,
        @p_batch = 1,
        @p_clodat_d = @dec_clodat_d OUTPUT,
        @p_per_cf = @dec_per_cf OUTPUT,
        @p_ret = @dec_ret OUTPUT,
        @p_ifrs17 = @dec_ifrs17 OUTPUT
		
	
	
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : Execution error #BREF..PsCALEND_EBS "
	  return 1
	end	
	
	print 'closingtype; : %1!' , @dec_per_cf
	print 'closingdate; : %1!' , @dec_clodat_d	
	
--MOD05[END]	 
	 
--Retrieve Scor EGPI for each CSUOE (assumed treaty only): Revised Scor share EGPI (BTRT..TFAMLIA.SCOGLOEGP_M) else Estimate Scor share EGPI (BTRT..TFAMLIA.SCOORGEGP_M)

	INSERT INTO #CTR (SSD_CF,END_NT, CTR_NF ,SEC_NF,UWY_NF,UW_NT,NORME_CF,
	SGTTYP_NT,SGMT_NF,SCOGLOEGP_M,CONVEGPI_M,ESB_CF,LIACUR_CF,CUR_CF, CR_NF,
	DIV_NT,CTRTYP_CT,SGTVER_NT,SGT_NT,SGTLVL_NT, UWORG_CF, CLIENTNUMBER,CLISSD_CF,
	CRUWY_NF, CRUW_NT,STATUWY_NF) 		--MOD05
	SELECT  c.SSD_CF 
		,C.END_NT
	    ,c.CTR_NF
		,c.SEC_NF
		,c.UWY_NF
		,c.UW_NT
		,@p_Norme
		,c.SGTTYP_NT
		,c.SGMT_NF
		,SCOGLOEGP_M
		,SCOGLOEGP_M
		,c.ESB_CF
		,C.LIACUR_CF
		,""
		,c.CR_NF
		,c.DIV_NT
		,c.CTRTYP_CT
		,C.SGTVER_NT
		,c.SGT_NT
		,c.SGTLVL_NT
		,UWORG_CF
		,ced_nf
		,CLISSD_CF
		,CRUWY_NF
		,CRUW_NT
		,convert(char(4),(UWY_NF)-1)+'1231'		--MOD05
	FROM BTRAV..ESEJ2050_TSEGRUNRES c 
	WHERE SGTTYP_NT = @p_sgttyp_nt AND c.CTRTYP_CT = @p_segtyp_ct AND @p_segtyp_ct = 'T' 

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : insert error #CTR-T"
	  return 1
	end	
	
	INSERT INTO #CTR (SSD_CF,END_NT, CTR_NF ,SEC_NF,UWY_NF,UW_NT,NORME_CF,SGTTYP_NT,
	SGMT_NF,SCOGLOEGP_M,CONVEGPI_M,ESB_CF,LIACUR_CF,CUR_CF, CR_NF,DIV_NT,CTRTYP_CT,SGTVER_NT,SGT_NT,SGTLVL_NT,UWORG_CF, CLIENTNUMBER,CLISSD_CF,
	CRUWY_NF, CRUW_NT,STATUWY_NF)  		--MOD05
	SELECT c.SSD_CF 
		,C.END_NT
	    ,c.CTR_NF
		,c.SEC_NF
		,c.UWY_NF
		,c.UW_NT
		,@p_Norme
		,c.SGTTYP_NT
		,c.SGMT_NF
		,SCOGLOEGP_M
		,SCOGLOEGP_M
		,c.ESB_CF
		,c.LIACUR_CF
		,""  -- for P/L select cur from table g where a.ssd = g.SSD_CF AND a.esb =G.ESB 
		,c.CR_NF
		,c.DIV_NT
		,c.CTRTYP_CT
		,C.SGTVER_NT
		,c.SGT_NT
		,c.SGTLVL_NT
		,UWORG_CF
		,ced_nf
		,CLISSD_CF
		,CRUWY_NF
		,CRUW_NT
		,convert(char(8),(UWY_NF)-1)+'1231' 	--MOD05
	FROM BTRAV..ESEJ2050_TSEGRUNRES c  
	WHERE 	  SGTTYP_NT = @p_sgttyp_nt AND c.CTRTYP_CT = @p_segtyp_ct AND @p_segtyp_ct = 'F' 

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : insert error #CTR-F"
	  return 1
	end
	
	-- for P/L select cur from table g where a.ssd = g.SSD_CF AND a.esb =G.ESB 
	UPDATE #CTR 
	SET  CUR_CF = a.SSDCUR_CF
	FROM Bref..Tsubsid a, #CTR b
	WHERE a.ssd_cf  = b.SSD_CF
	
	CREATE NONCLUSTERED INDEX AK_ESEJ2050_CTR ON #CTR(CTR_NF,UWY_NF,UW_NT,END_NT,DIV_NT, SGTTYP_NT,SGMT_NF,SGTLVL_NT,SGT_NT)
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : INDEX error AK_ESEJ2050_CTR"
	  return 1
	end
	--MOD07[START]
	CREATE  NONCLUSTERED INDEX AK_ESEJ2050_CTR_01 ON #CTR(CR_NF)
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : INDEX error AK_ESEJ2050_CTR_01"
	  return 1
	end
	--MOD07[END]
	
	--Delete all rows SCOGLOEGP_M = null or currency not found for given SSD
	delete #CTR where CTRTYP_CT='T' and (isnull(SCOGLOEGP_M,0) =0  or SIGN(SCOGLOEGP_M) = -1 or ISNULL(CUR_CF, "") = "")


-- Determine if the currency is not the same
	UPDATE #CTR 
	SET CONVERAMOUNT_B = 1 from #CTR where LIACUR_CF != CUR_CF
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 004"
	  return 1
	end
	
 --Find Threshold EGPI and LOB (%):For each Commercial relationship and norm, EGPI threshold (BEST..TTHRHLDLOB.EGPITHRHLD_M) and LOB threshold (BEST..TTHRHLDLOB.LOBTHRHLD_R) to retrieve is the one with:
--•Same ledger as the Commercial relationship. For Group norm, if no threshold is found, the one with no ledger is retrieved
--•Last threshold : First closing date (BEST..TTHRHLDLOB.FCLODAT_D) empty, else more recent first closing date
	--Case 1 : Apply threshold globally if we have ssd =0, esb = 0 for given norm and FCLODAT_D is NULL
	UPDATE #CTR
	SET LOBTHRHLD_R = a.LOBTHRHLD_R, EGPITHRHLD_M = a.EGPITHRHLD_M
	FROM BEST..TTHRHLDLOB a,  #CTR b
	WHERE FCLODAT_D is NULL  AND isnull(a.SSD_CF,0) = 0 AND isnull(a.ESB_CF,0) = 0 and b.NORME_CF = a.NORME_CF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 005"
	  return 1
	end

	--Case 2 : Apply threshold globally if we have ssd =0, esb = 0 for given norm and no row for FCLODAT_D is NULL then fetch max(FCLODAT_D) for given norm
	UPDATE #CTR
	SET LOBTHRHLD_R = a.LOBTHRHLD_R, EGPITHRHLD_M = a.EGPITHRHLD_M
	FROM BEST..TTHRHLDLOB a,  #CTR b
	WHERE  isnull(a.SSD_CF,0) = 0 AND isnull(a.ESB_CF,0) = 0  AND b.LOBTHRHLD_R = NULL AND b.EGPITHRHLD_M = NULL and b.NORME_CF = a.NORME_CF 
	AND FCLODAT_D = (SELECT MAX(FCLODAT_D) FROM BEST..TTHRHLDLOB  c WHERE  a.SSD_CF = c.SSD_CF AND a.ESB_CF = c.ESB_CF AND
	 c.NORME_CF = a.NORME_CF  ) 

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 006"
	  return 1
	end

	--Case 3 : Apply threshold per ssd and esb for given norm and no row for FCLODAT_D is NULL then fetch max(FCLODAT_D) for given norm
	UPDATE #CTR
	SET LOBTHRHLD_R = a.LOBTHRHLD_R, EGPITHRHLD_M = a.EGPITHRHLD_M
	FROM BEST..TTHRHLDLOB a,  #CTR b
	WHERE FCLODAT_D is NULL  AND a.SSD_CF = b.SSD_CF AND a.ESB_CF = b.ESB_CF AND b.NORME_CF = a.NORME_CF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 007"
	  return 1
	end
	
	--Case 4 : Apply threshold per ssd and esb for given norm and FCLODAT_D is NULL
	UPDATE #CTR
	SET LOBTHRHLD_R = a.LOBTHRHLD_R, EGPITHRHLD_M = a.EGPITHRHLD_M
	FROM BEST..TTHRHLDLOB a,  #CTR b
	WHERE a.SSD_CF = b.SSD_CF AND a.ESB_CF = b.ESB_CF AND b.LOBTHRHLD_R = NULL AND b.EGPITHRHLD_M = NULL AND b.NORME_CF = a.NORME_CF 
	AND FCLODAT_D = (SELECT MAX(FCLODAT_D) FROM BEST..TTHRHLDLOB c WHERE  a.SSD_CF = c.SSD_CF AND a.ESB_CF = c.ESB_CF AND a.NORME_CF = c.NORME_CF) 

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 008"
	  return 1
	end
	 
	DELETE BTRAV..ESEJ2050_TSEGRUNRES
	from  BTRAV..ESEJ2050_TSEGRUNRES b,#CTR a 
	WHERE b.SGTTYP_NT = @p_sgttyp_nt AND b.CTRTYP_CT = @p_segtyp_ct  
	 AND( a.LOBTHRHLD_R = NULL OR a.EGPITHRHLD_M = NULL) and
	  b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF 
	
	
-- Conversion of EGPI (R01-04) into following currencies using statistical rate (31/12/uwy-1):
--•EUR for Group norm
--•Legder currency for Parent/Local norm
	
	UPDATE #CTR
	SET SRCRATE = EXC_R  --ORDER BY EXC_D DESC
	FROM  #CTR b ,  BREF..TCURQUOT a
	WHERE CONVERAMOUNT_B = 1 and a.SSD_CF = b.SSD_CF 
					AND a.CUR_CF = b.LIACUR_CF  AND 
					EXC_D = STATUWY_NF 		--MOD05
	
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 009"
	  return 1
	end		

	--MOD05[START]		
	
	UPDATE #CTR
	SET SRCRATE = EXC_R  --ORDER BY EXC_D DESC
	FROM  #CTR b ,  BREF..TCURQUOT a
	WHERE CONVERAMOUNT_B = 1 and a.SSD_CF = b.SSD_CF 
					AND a.CUR_CF = b.LIACUR_CF  AND 
					EXC_D = (select max(EXC_D) from BREF..TCURQUOT c where a.SSD_CF = c.SSD_CF 
					AND a.CUR_CF = c.CUR_CF AND EXC_D <= @dec_clodat_d) AND SRCRATE = null		
	
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 029"
	  return 1
	end		
	--MOD05[END]

	UPDATE #CTR
	SET DSTRATE = EXC_R --ORDER BY EXC_D DESC 
	FROM  #CTR b ,  BREF..TCURQUOT a
	WHERE CONVERAMOUNT_B = 1 and a.SSD_CF = b.SSD_CF 
					AND a.CUR_CF = b.CUR_CF  AND 
					EXC_D = STATUWY_NF  	--MOD05
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 010"
	  return 1
	end	
	
	--MOD05[START]
 
	UPDATE #CTR
	SET DSTRATE = EXC_R --ORDER BY EXC_D DESC 
	FROM  #CTR b ,  BREF..TCURQUOT a
	WHERE CONVERAMOUNT_B = 1 and a.SSD_CF = b.SSD_CF 
					AND a.CUR_CF = b.CUR_CF  AND 
					EXC_D = (select max(EXC_D) from BREF..TCURQUOT c where a.SSD_CF = c.SSD_CF 
					AND a.CUR_CF = c.CUR_CF AND EXC_D <= @dec_clodat_d) AND DSTRATE = null 		
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 030"
	  return 1
	end	
	--MOD05[END]
	

	UPDATE #CTR
	SET CONVEGPI_M = convert(decimal (18,3), (SCOGLOEGP_M  * (SRCRATE / DSTRATE )))  
	FROM #CTR 	
	WHERE CONVERAMOUNT_B = 1 and (SRCRATE !=null and DSTRATE != null)

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 011"
	  return 1
	end

-- Aggregate EGPI (R01-05) per Commercial relationship / norm (Total EGPI CR)
-- retrieve IFRS 17 segment linked of max Total EGPI LOB

	INSERT INTO #CTRNEWEGPI (CR_NF,SGMT_NF,TOTALEGPICRLOB_M, TOTALEGPITHRHD_M, LOBTHRHLD_R,SGTVER_NT,SGTLVL_NT,SGT_NT,CRUWY_NF, CRUW_NT) 
	SELECT distinct CR_NF, SGMT_NF,SUM(CONVEGPI_M), MAX(EGPITHRHLD_M), LOBTHRHLD_R,SGTVER_NT,SGTLVL_NT,SGT_NT, CRUWY_NF, CRUW_NT
	FROM #CTR
	GROUP BY CR_NF, SGMT_NF, CRUWY_NF, CRUW_NT
	ORDER BY CR_NF, SGMT_NF, CRUWY_NF, CRUW_NT

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 012"
	  return 1
	end
	
	CREATE  CLUSTERED INDEX AK_ESEJ2050_CTRNEWEGPI ON #CTRNEWEGPI(CR_NF, SGMT_NF, CRUWY_NF, CRUW_NT)
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : INDEX error AK_ESEJ2050_CTRNEWEGPI"
	  return 1
	end

	update #CTRNEWEGPI
		set SGMT_LS = TS1.SGMT_LS, SGMT_LL = TS1.SGMT_LL
	FROM  BEST..TSEGMT TS1,#CTRNEWEGPI b
	WHERE TS1.SGT_NT = b.SGT_NT AND
    TS1.SGTVER_NT = b.SGTVER_NT AND
    TS1.SGTLVL_NT = b.SGTLVL_NT AND TS1.SGMT_NF = B.SGMT_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 013"
	  return 1
	end

--Aggregate EGPI (R01-05) per Commercial relationship / IFRS 17 segment / norm (Total EGPI LOB)
    
    SELECT CR_NF, SGMT_NF, SUM(TOTALEGPICRLOB_M) AS TOTALEGPICRLOB_M, CRUWY_NF, CRUW_NT
		INTO #TMPDATA
    FROM #CTRNEWEGPI
    GROUP BY CR_NF, SGMT_NF, CRUWY_NF, CRUW_NT
	ORDER BY CR_NF, SGMT_NF, CRUWY_NF, CRUW_NT

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : insert #TMPDATA 014"
	  return 1
	end

	UPDATE #CTRNEWEGPI
	SET TOTALEGPICRLOB_M = b.TOTALEGPICRLOB_M
	FROM #CTRNEWEGPI A ,#TMPDATA B
    WHERE A.CR_NF = B.CR_NF AND A.SGMT_NF = B.SGMT_NF AND A.CRUWY_NF = B.CRUWY_NF AND A.CRUW_NT = B.CRUW_NT 
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 015"
	  return 1
	end 
 
	select a.CR_NF,  MAX(b.TOTALEGPICRLOB_M) AS TOTALEGPICRLOB_M, A.CRUWY_NF, A.CRUW_NT
            INTO #MAXSEGEGPI
	FROM #CTRNEWEGPI A ,#TMPDATA B
    WHERE A.CR_NF = B.CR_NF AND A.SGMT_NF = B.SGMT_NF 
        AND A.CRUWY_NF = B.CRUWY_NF AND A.CRUW_NT = B.CRUW_NT 
	GROUP BY a.CR_NF, A.CRUWY_NF, A.CRUW_NT
	ORDER BY a.CR_NF, A.CRUWY_NF, A.CRUW_NT

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 016"
	  return 1
	end

	UPDATE #CTRNEWEGPI
	SET MAXTOTALEGPICRLOB_M = b.TOTALEGPICRLOB_M
	FROM #CTRNEWEGPI A ,#MAXSEGEGPI B
    WHERE A.CR_NF = B.CR_NF AND A.CRUWY_NF = B.CRUWY_NF AND A.CRUW_NT = B.CRUW_NT 

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 017"
	  return 1
	end

	SELECT distinct CR_NF,SUM(CONVEGPI_M) AS TOTALPERCR, UWY_NF,CRUWY_NF, CRUW_NT
		into #TOTTMPDATA
	FROM #CTR
	GROUP BY CR_NF, CRUWY_NF, CRUW_NT
	ORDER BY CR_NF   , CRUWY_NF, CRUW_NT

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 018"
	  return 1
	end
    
	UPDATE #CTRNEWEGPI
	SET TOTALEGPICR_M = TOTALPERCR
	FROM #CTRNEWEGPI A ,#TOTTMPDATA B
    WHERE A.CR_NF = B.CR_NF 
    	AND A.CRUWY_NF = B.CRUWY_NF AND A.CRUW_NT = B.CRUW_NT
 
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 019"
	  return 1
	end
	
 --Calculate highest EGPI% per norm
 
--MOD02
	update #CTRNEWEGPI
	SET a.POURCENTAGEEGPI_R = convert(decimal(9,8),  (a.TOTALEGPICRLOB_M/A.TOTALEGPICR_M))
	from #CTRNEWEGPI a where ISNULL(A.TOTALEGPICR_M,0) !=0 

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 020"
	  return 1
	end

--R01-08	
	UPDATE #CTRNEWEGPI
	SET ROWSEL_B = 1
	WHERE TOTALEGPICRLOB_M = MAXTOTALEGPICRLOB_M

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 021"
	  return 1
	end
	
--Identification of Main LOB IFRS17 per norm of the Commercial Relationship linked to assumed treaties
	UPDATE #CTRNEWEGPI
	SET MAINLOB = 
		(case when POURCENTAGEEGPI_R = 1 then '1'
			  when POURCENTAGEEGPI_R < 1 and TOTALEGPICR_M > TOTALEGPITHRHD_M  then '2' 		--MOD03
			  when POURCENTAGEEGPI_R > LOBTHRHLD_R then '3' 
					   else '4' 
			end),
	MAINLOBORG = 
		(case when POURCENTAGEEGPI_R = 1 then '1'
			  when POURCENTAGEEGPI_R < 1 and TOTALEGPICR_M > TOTALEGPITHRHD_M  then '2' 		--MOD03
			  when POURCENTAGEEGPI_R > LOBTHRHLD_R then '3'
					   else '4' 
			end)

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 022"
	  return 1
	end
	
	UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENTORG =
		(case when MAINLOBORG = '1' then "Unique IFRS 17 LoB"
			  when MAINLOBORG = '2'  then "Individual" 
			  when MAINLOBORG = '3' then "Main IFRS 17 LoB"
					   else "Multi LoB"
			end)

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 023"
	  return 1
	end
			
--Allocate main IFRS17 segment per norm to each assumed treaty belonging to the Commercial relationship
	---(select IFRS17SEGMENT from #CTRNEWEGPI where TOTALEGPICR_M = (select MAX(TOTALEGPICR_M) from #CTRNEWEGPI)
--MOD09[START]
	UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENT = 
		(case when a.UWORG_CF = 248 then 'Retro Dummy'
			end),
	
	MAINLOB = (case when a.UWORG_CF = 248 then '2' 
			end)
	from #CTR A, #CTRNEWEGPI B 
	WHERE a.SGMT_NF = b.SGMT_NF AND B.CR_NF = A.CR_NF and A.CTRTYP_CT = 'T'
     AND A.CRUW_NT = B.CRUW_NT AND A.CRUWY_NF=B.CRUWY_NF
--MOD09[END]
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 024"
	  return 1
	end

	UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENT = CR_LM ,
		MAINLOB = B.CR_NF
	from #CTR A, #CTRNEWEGPI B ,BTRT..TCR C
	WHERE A.CTRTYP_CT = 'T' AND
    A.CR_NF = B.CR_NF AND B.CR_NF = C.CR_NF
	and MAINLOBORG = '2' AND ROWSEL_B = 1 and IFRS17SEGMENT = null
    AND A.CRUW_NT = B.CRUW_NT AND A.CRUWY_NF=B.CRUWY_NF	
    AND A.CRUW_NT = C.CRUW_NT AND A.CRUWY_NF=C.CRUWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 025"
	  return 1
	end


	UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENT = B.SGMT_LL,
		MAINLOB = convert(char(10), B.SGMT_LS)
	from #CTR A, #CTRNEWEGPI B 
	WHERE  A.CTRTYP_CT = 'T' AND   A.CR_NF = B.CR_NF 
	and (MAINLOBORG = '1' OR MAINLOBORG = '3')  AND ROWSEL_B = 1 and IFRS17SEGMENT = null
    AND A.CRUW_NT = B.CRUW_NT AND A.CRUWY_NF= B.CRUWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 026"
	  return 1
	end
	

	UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENT =	@labl,
		MAINLOB = '6'										--MOD06
	from #CTR A, #CTRNEWEGPI B 
	WHERE  A.CTRTYP_CT = 'T' AND   A.CR_NF = B.CR_NF 
	and MAINLOBORG = '4'   AND ROWSEL_B = 1 and IFRS17SEGMENT = null
    AND A.CRUW_NT = B.CRUW_NT AND A.CRUWY_NF= B.CRUWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 0227"
	  return 1
	end	
	
	UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENT = 
		(case 
			 when a.UWORG_CF = 248 then 'Retro Dummy' 
			end)
	from #CTR A, #CTRNEWEGPI B 
	WHERE a.SGMT_NF = b.SGMT_NF and A.CTRTYP_CT = 'F' AND   A.CR_NF = B.CR_NF 
	AND A.CRUW_NT = B.CRUW_NT AND A.CRUWY_NF= B.CRUWY_NF
	
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 027"
	  return 1
	end

    UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENT = B.SGMT_LL,
		MAINLOB = convert(char(10), B.SGMT_LS)
	from #CTR A, #CTRNEWEGPI B 
	WHERE a.SGMT_NF = b.SGMT_NF and A.CTRTYP_CT = 'F' AND   A.CR_NF = B.CR_NF and IFRS17SEGMENT = NULL
        AND A.CRUW_NT = B.CRUW_NT AND A.CRUWY_NF= B.CRUWY_NF
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 028"
	  return 1
	end
	
--BEGIN TRAN

if (@p_sgttyp_nt = 65)		--Parent
BEGIN
	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET PARIFRSLOB_CF = MAINLOBORG,
		PARIFRSLOBEGP_R = POURCENTAGEEGPI_R,
		PARIFRSLOB_LL = IFRS17SEGMENTORG
	FROM  #CTRNEWEGPI B , BTRAV..ESEJ2050_TSEGRUNRES C  
	WHERE ROWSEL_B=1   AND B.CR_NF = C.CR_NF
	AND EXISTS (SELECT 1 FROM #CTR A WHERE A.CTRTYP_CT = 'T' AND B.CR_NF = A.CR_NF)
	AND B.CRUW_NT = C.CRUW_NT AND B.CRUWY_NF= C.CRUWY_NF AND C.SGTTYP_NT = @p_sgttyp_nt AND c.CTRTYP_CT = 'T'
	
    select @err = @@error, @rowcnt = @@rowcount	
	if @err != 0
	begin
	  rollback TRAN
	  raiserror 20020 "20020 : Error on Update BTRT..TCR"
	  return 1
	end
	print 'Update ESEJ2050_TSEGRUNRES for BTRT..TCR : %1!' , @rowcnt

	
	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET  PARIFRSSEG_CT = C.MAINLOB, 
		 PARIFRSSEG_LL = C.IFRS17SEGMENT
	FROM #CTR A, BTRAV..ESEJ2050_TSEGRUNRES B, #CTRNEWEGPI C
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF AND A.CTRTYP_CT = 'T'
	 	 AND A.CR_NF = C.CR_NF AND A.CR_NF = B.CR_NF AND ROWSEL_B = 1
		 AND A.CRUW_NT = C.CRUW_NT AND A.CRUWY_NF= C.CRUWY_NF
		 AND B.CRUW_NT = C.CRUW_NT AND B.CRUWY_NF= C.CRUWY_NF AND B.SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = 'T'	
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TSECIFRS"
	  return 1
	end	
	print 'Update ESEJ2050_TSEGRUNRES for BTRT..TSECIFRS : %1!' , @rowcnt
	
	
	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET  PARIFRSSEG_CT = C.MAINLOB, 
		 PARIFRSSEG_LL = IFRS17SEGMENT
	FROM #CTR A, BTRAV..ESEJ2050_TSEGRUNRES B, #CTRNEWEGPI C
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.UWY_NF = a.UWY_NF AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF AND A.CTRTYP_CT = 'F'
	  AND A.CR_NF = C.CR_NF AND A.CR_NF = B.CR_NF AND A.SGMT_NF = C.SGMT_NF 
		AND B.CRUW_NT = C.CRUW_NT AND B.CRUWY_NF= C.CRUWY_NF AND B.SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = 'F'
		AND A.CRUW_NT = C.CRUW_NT AND A.CRUWY_NF= C.CRUWY_NF
		
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BFAC..TSECIFRS"
	  return 1
	end	
	print 'Update ESEJ2050_TSEGRUNRES for BFAC..TSECIFRS : %1!' , @rowcnt


end --Parent block

if (@p_sgttyp_nt = 66)		--Local
BEGIN
	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET LOCIFRSLOB_CF = MAINLOBORG,
		LOCIFRSLOBEGP_R = POURCENTAGEEGPI_R,
		LOCIFRSLOB_LL = IFRS17SEGMENTORG
	FROM  #CTRNEWEGPI B , BTRAV..ESEJ2050_TSEGRUNRES C  
	WHERE ROWSEL_B=1   AND B.CR_NF = C.CR_NF
	AND EXISTS (SELECT 1 FROM #CTR A WHERE A.CTRTYP_CT = 'T' AND B.CR_NF = A.CR_NF)
		AND B.CRUW_NT = C.CRUW_NT AND B.CRUWY_NF= C.CRUWY_NF AND C.SGTTYP_NT = @p_sgttyp_nt AND C.CTRTYP_CT = 'T'
		
    select @err = @@error, @rowcnt = @@rowcount	
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TCR"
	  return 1
	end
	print 'Update ESEJ2050_TSEGRUNRES for BTRT..TCR : %1!' , @rowcnt

	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET  LOCIFRSSEG_CT = C.MAINLOB, 
		 LOCIFRSSEG_LL = C.IFRS17SEGMENT
	FROM #CTR A, BTRAV..ESEJ2050_TSEGRUNRES B, #CTRNEWEGPI C
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF AND A.CTRTYP_CT = 'T'
	 	 AND A.CR_NF = C.CR_NF AND ROWSEL_B = 1
		 AND B.CRUW_NT = C.CRUW_NT AND B.CRUWY_NF= C.CRUWY_NF AND  B.SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = 'T'
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TSECIFRS"
	  return 1
	end	
	print 'Update ESEJ2050_TSEGRUNRES for BTRT..TSECIFRS : %1!' , @rowcnt
	
		
	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET  LOCIFRSSEG_CT = C.MAINLOB, 
		 LOCIFRSSEG_LL = IFRS17SEGMENT
	FROM #CTR A, BTRAV..ESEJ2050_TSEGRUNRES B, #CTRNEWEGPI C
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF AND A.CTRTYP_CT = 'F'
	 	 AND A.CR_NF = C.CR_NF AND A.SGMT_NF = C.SGMT_NF 
		 AND B.CRUW_NT = C.CRUW_NT AND B.CRUWY_NF= C.CRUWY_NF AND  B.SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = 'F'
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BFAC..TSECIFRS"
	  return 1
	end	
	print 'Update ESEJ2050_TSEGRUNRES for BFAC..TSECIFRS : %1!' , @rowcnt


end --Local block

--COMMIT TRAN
--print "commit done"

return 0

go

if object_id('PtEGPICALCI17P_L') is not null
  print '<<< CREATED PROC PtEGPICALCI17P_L >>>'
else
  print '<<< FAILED CREATING PROC PtEGPICALCI17P_L >>>'
go
grant execute on PtEGPICALCI17P_L TO GOMEGA
go
grant execute on PtEGPICALCI17P_L TO GDBBATCH
go
