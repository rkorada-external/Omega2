use BEST
go
if object_id('PsPortfolioCalc') is not null
begin
  drop PROC PsPortfolioCalc
  print '<<< DROPPED PROC PsPortfolioCalc >>>'
end
go

create procedure PsPortfolioCalc
(
	@p_sgttyp_nt int,
	@p_erreur varchar(64)=null output
)
with execute as caller as

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : KBagwe
Date de creation        : 13/03/2019
Description du programme: Fetching portfolio/sub portfolio details
Conditions d'execution  : ESEJ2061
Commentaires            :
_________________
MODIFICATIONS
*****************************************************/

declare @err int, @rowcnt int, @labl char(40)
declare @temp char(4), @curdate char(10)



UPDATE BTRAV..ESEJ2060_TRESULT
SET PARSGMT_NF = A.PARSGMT_NF
	GRPIFRSSEG_CT=
FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT
 


--Retrieve Scor EGPI for each CSUOE (assumed treaty only): Revised Scor share EGPI (BTRT..TFAMLIA.SCOGLOEGP_M) else Estimate Scor share EGPI (BTRT..TFAMLIA.SCOORGEGP_M)

	INSERT INTO #CTR (SSD_CF,END_NT, CTR_NF ,SEC_NF,UWY_NF,UW_NT,NORME_CF,
	SGTTYP_NT,SGMT_NF,SCOGLOEGP_M,CONVEGPI_M,ESB_CF,LIACUR_CF,CUR_CF, CR_NF,
	DIV_NT,CTRTYP_CT,SGTVER_NT,SGT_NT,SGTLVL_NT, UWORG_CF, CLIENTNUMBER,CLISSD_CF) 
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
		,'EUR'  -- for P/L select cur from table g where a.ssd = g.SSD_CF AND a.esb =G.ESB 
		,c.CR_NF
		,c.DIV_NT
		,c.CTRTYP_CT
		,C.SGTVER_NT
		,c.SGT_NT
		,c.SGTLVL_NT
		,UWORG_CF
		,ced_nf
		,CLISSD_CF
	FROM BTRAV..ESEJ2050_TSEGRUNRES c 
	WHERE SGTTYP_NT = @p_sgttyp_nt AND c.CTRTYP_CT = @p_segtyp_ct AND @p_segtyp_ct = 'T' AND c.TGRPFIRCLO_D = NULL

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : insert error #CTR-T"
	  return 1
	end	
	
	INSERT INTO #CTR (SSD_CF,END_NT, CTR_NF ,SEC_NF,UWY_NF,UW_NT,NORME_CF,SGTTYP_NT,
	SGMT_NF,SCOGLOEGP_M,CONVEGPI_M,ESB_CF,LIACUR_CF,CUR_CF, CR_NF,DIV_NT,CTRTYP_CT,SGTVER_NT,SGT_NT,SGTLVL_NT,UWORG_CF, CLIENTNUMBER,CLISSD_CF ) 
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
		,'EUR'  
		,c.CR_NF
		,c.DIV_NT
		,c.CTRTYP_CT
		,C.SGTVER_NT
		,c.SGT_NT
		,c.SGTLVL_NT
		,UWORG_CF
		,ced_nf
		,CLISSD_CF
	FROM BTRAV..ESEJ2050_TSEGRUNRES c  
	WHERE 	  SGTTYP_NT = @p_sgttyp_nt AND c.CTRTYP_CT = @p_segtyp_ct AND @p_segtyp_ct = 'F' AND c.FGRPFIRCLO_D = NULL

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : insert error #CTR-F"
	  return 1
	end
	
	
	CREATE NONCLUSTERED INDEX AK_ESEJ2050_CTR ON #CTR(CTR_NF,UWY_NF,UW_NT,END_NT,DIV_NT, SGTTYP_NT,SGMT_NF,SGTLVL_NT,SGT_NT)
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : INDEX error AK_ESEJ2050_CTR"
	  return 1
	end
	
	
	--Delete all rows SCOGLOEGP_M = null
	delete #CTR where CTRTYP_CT='T' and (isnull(SCOGLOEGP_M,0) =0  or SIGN(SCOGLOEGP_M) = -1)


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
	WHERE a.SSD_CF = b.SSD_CF AND a.ESB_CF = b.ESB_CF AND b.LOBTHRHLD_R = NULL AND b.EGPITHRHLD_M = NULL AND b.NORME_CF = a.NORME_CF AND FCLODAT_D = (SELECT MAX(FCLODAT_D) FROM BEST..TTHRHLDLOB c WHERE  a.SSD_CF = c.SSD_CF AND a.ESB_CF = c.ESB_CF ) 

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 008"
	  return 1
	end
	 
	DELETE #CTR WHERE LOBTHRHLD_R = NULL OR EGPITHRHLD_M = NULL
	
	
-- Conversion of EGPI (R01-04) into following currencies using statistical rate (31/12/uwy-1):
--•EUR for Group norm
--•Legder currency for Parent/Local norm
	
	UPDATE #CTR
	SET SRCRATE = EXC_R  --ORDER BY EXC_D DESC
	FROM  #CTR b ,  BREF..TCURQUOT a
	WHERE CONVERAMOUNT_B = 1 and a.SSD_CF = b.SSD_CF 
					AND a.CUR_CF = b.LIACUR_CF  AND 
					EXC_D = @curdate  
	
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 009"
	  return 1
	end					

	UPDATE #CTR
	SET DSTRATE = EXC_R --ORDER BY EXC_D DESC 
	FROM  #CTR b ,  BREF..TCURQUOT a
	WHERE CONVERAMOUNT_B = 1 and a.SSD_CF = b.SSD_CF 
					AND a.CUR_CF = b.CUR_CF  AND 
					EXC_D = @curdate  
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 010"
	  return 1
	end	
 
	

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

	INSERT INTO #CTRNEWEGPI (CR_NF,SGMT_NF,TOTALEGPICRLOB_M, TOTALEGPITHRHD_M, LOBTHRHLD_R,SGTVER_NT,SGTLVL_NT,SGT_NT,UWY_NF) 
	SELECT distinct CR_NF, SGMT_NF,SUM(CONVEGPI_M), MAX(EGPITHRHLD_M), LOBTHRHLD_R,SGTVER_NT,SGTLVL_NT,SGT_NT, UWY_NF
	FROM #CTR
	GROUP BY CR_NF, SGMT_NF, UWY_NF
	ORDER BY CR_NF, SGMT_NF, UWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 012"
	  return 1
	end
	
	CREATE  CLUSTERED INDEX AK_ESEJ2050_CTRNEWEGPI ON #CTRNEWEGPI(SGMT_NF,CR_NF,SGT_NT)
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
    
    SELECT CR_NF, SGMT_NF, SUM(TOTALEGPICRLOB_M) AS TOTALEGPICRLOB_M, UWY_NF
		INTO #TMPDATA
    FROM #CTRNEWEGPI
    GROUP BY CR_NF, SGMT_NF, UWY_NF
	ORDER BY CR_NF, SGMT_NF, UWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : insert #TMPDATA 014"
	  return 1
	end

	UPDATE #CTRNEWEGPI
	SET TOTALEGPICRLOB_M = b.TOTALEGPICRLOB_M
	FROM #CTRNEWEGPI A ,#TMPDATA B
    WHERE A.CR_NF = B.CR_NF AND A.SGMT_NF = B.SGMT_NF AND A.UWY_NF = B.UWY_NF
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 015"
	  return 1
	end 
 
	select a.CR_NF,  MAX(b.TOTALEGPICRLOB_M) AS TOTALEGPICRLOB_M, A.UWY_NF
            INTO #MAXSEGEGPI
	FROM #CTRNEWEGPI A ,#TMPDATA B
    WHERE A.CR_NF = B.CR_NF AND A.SGMT_NF = B.SGMT_NF AND A.UWY_NF = B.UWY_NF
	GROUP BY a.CR_NF, A.UWY_NF
	ORDER BY a.CR_NF,A.UWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 016"
	  return 1
	end

	UPDATE #CTRNEWEGPI
	SET MAXTOTALEGPICRLOB_M = b.TOTALEGPICRLOB_M
	FROM #CTRNEWEGPI A ,#MAXSEGEGPI B
    WHERE A.CR_NF = B.CR_NF AND A.UWY_NF = B.UWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 017"
	  return 1
	end

	SELECT distinct CR_NF,SUM(CONVEGPI_M) AS TOTALPERCR, UWY_NF
		into #TOTTMPDATA
	FROM #CTR
	GROUP BY CR_NF, UWY_NF
	ORDER BY CR_NF   , UWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 018"
	  return 1
	end
    
	UPDATE #CTRNEWEGPI
	SET TOTALEGPICR_M = TOTALPERCR
	FROM #CTRNEWEGPI A ,#TOTTMPDATA B
    WHERE A.CR_NF = B.CR_NF AND A.UWY_NF = B.UWY_NF
 
 
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
	UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENT = 
		(case when a.CLISSD_CF <> 0 then 'Internal assumed'
			 when a.UWORG_CF = 248 then 'Retro Dummy'
			ELSE NULL
			end),
	
	MAINLOB = (case when a.CLISSD_CF <> 0 then '1'
			 when a.UWORG_CF = 248 then '2' 
			 ELSE NULL
			end)
	from #CTR A, #CTRNEWEGPI B 
	WHERE a.SGMT_NF = b.SGMT_NF AND B.CR_NF = A.CR_NF and A.CTRTYP_CT = 'T'
    AND A.UWY_NF = B.UWY_NF

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
    AND A.UWY_NF = B.UWY_NF AND A.UWY_NF = C.CRUWY_NF

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
    AND A.UWY_NF = B.UWY_NF

	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 026"
	  return 1
	end
	

	UPDATE #CTRNEWEGPI
	SET IFRS17SEGMENT =	@labl ,
	
	MAINLOB = (case when (substring(suser_name(), 3, 2) = "EU") then '3'
					when (substring(suser_name(), 3, 2) =  "AM") then '4'
					else '5'
			end)

	from #CTR A, #CTRNEWEGPI B 
	WHERE  A.CTRTYP_CT = 'T' AND   A.CR_NF = B.CR_NF 
	and MAINLOBORG = '4'   AND ROWSEL_B = 1 and IFRS17SEGMENT = null
	AND A.UWY_NF = B.UWY_NF

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
	AND A.UWY_NF = B.UWY_NF
	
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
        AND A.UWY_NF = B.UWY_NF
 
	select @err = @@error		
	if @err != 0
	begin
	  raiserror 20020 "20020 : error 028"
	  return 1
	end
	
--BEGIN TRAN

	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET GRPIFRSLOB_CF = MAINLOBORG,
		GRPIFRSLOBEGP_R = POURCENTAGEEGPI_R,
		GRPIFRSLOB_LL = IFRS17SEGMENTORG
	FROM  #CTRNEWEGPI B , BTRAV..ESEJ2050_TSEGRUNRES C  
	WHERE ROWSEL_B=1   AND B.CR_NF = C.CR_NF
	AND EXISTS (SELECT 1 FROM #CTR A WHERE A.CTRTYP_CT = 'T' AND B.CR_NF = A.CR_NF)
	--AND (isnull(GRPIFRSLOB_CF,"") <> isnull(MAINLOBORG,"") OR isnull(GRPIFRSLOBEGP_R ,0) <> isnull(POURCENTAGEEGPI_R,0) OR isnull(GRPIFRSLOB_LL ,"") <> isnull(IFRS17SEGMENTORG,""))
	AND B.UWY_NF = C.CRUWY_NF AND C.SGTTYP_NT = @p_sgttyp_nt AND c.CTRTYP_CT = 'T'
	
    select @err = @@error, @rowcnt = @@rowcount	
	if @err != 0
	begin
	  raiserror 20020 "20020 : Error on Update BTRT..TCR"
	  return 1
	end
	print 'Update ESEJ2050_TSEGRUNRES for BTRT..TCR : %1!' , @rowcnt

	-- MOD01
	/* UPDATE BFAC..TCR
	SET GRPIFRSLOB_CF = MAINLOBORG,
		GRPIFRSLOBEGP_R = POURCENTAGEEGPI_R,
		GRPIFRSLOB_LL = IFRS17SEGMENTORG,
		LSTUPD_D = getdate(),
		LSTUPDUSR_CF =  suser_name()
 	FROM  #CTRNEWEGPI B , BFAC..TCR C  
	WHERE ROWSEL_B=1   AND B.CR_NF = C.CR_NF 
    AND EXISTS (SELECT 1 FROM #CTR A WHERE A.CTRTYP_CT = 'F' AND B.CR_NF = A.CR_NF)
	AND (isnull(GRPIFRSLOB_CF,"") <> isnull(MAINLOBORG,"") OR isnull(GRPIFRSLOBEGP_R ,0) <> isnull(POURCENTAGEEGPI_R,0) OR isnull(GRPIFRSLOB_LL ,"") <> isnull(IFRS17SEGMENTORG,""))
	AND B.UWY_NF = C.CRUWY_NF
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  raiserror 20020 "20020 : Error on Update BFAC..TCR"
	  return 1
	end	
	print 'Update ESEJ2050_TSEGRUNRES for BFAC..TCR : %1!' , @rowcnt */
	
	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET  GRPIFRSSEG_CT = C.MAINLOB, 
		 GRPIFRSSEG_LL = C.IFRS17SEGMENT
	FROM #CTR A, BTRAV..ESEJ2050_TSEGRUNRES B, #CTRNEWEGPI C
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF AND A.CTRTYP_CT = 'T'
	 	 AND A.CR_NF = C.CR_NF AND ROWSEL_B = 1
		--AND (isnull(GRPIFRSSEG_CT,"") <> isnull(C.MAINLOB,"") OR isnull(GRPIFRSSEG_LL ,"") <> isnull(C.IFRS17SEGMENT,"") )
		AND B.UWY_NF = C.UWY_NF	AND B.SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = 'T'
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  raiserror 20020 "20020 : Error on Update BTRT..TSECIFRS"
	  return 1
	end	
	print 'Update ESEJ2050_TSEGRUNRES for ESEJ2050_TSEGRUNRES for BTRT..TSECIFRS : %1!' , @rowcnt
	
	
	
	
	UPDATE BTRAV..ESEJ2050_TSEGRUNRES
	SET  GRPIFRSSEG_CT = C.MAINLOB, 
		 GRPIFRSSEG_LL = IFRS17SEGMENT 
	
	FROM #CTR A, BTRAV..ESEJ2050_TSEGRUNRES B, #CTRNEWEGPI C
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.UWY_NF = a.UWY_NF AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF AND A.CTRTYP_CT = 'F'
	 	 AND A.CR_NF = C.CR_NF AND A.SGMT_NF = C.SGMT_NF 
	--	AND (isnull(GRPIFRSSEG_CT,"") <> isnull(C.MAINLOB,"") OR isnull(GRPIFRSSEG_LL ,"") <> isnull(C.IFRS17SEGMENT,"") )
		AND B.UWY_NF = C.UWY_NF AND B.SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = 'F'
			
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  raiserror 20020 "20020 : Error on Update BFAC..TSECIFRS"
	  return 1
	end	
	print 'Update ESEJ2050_TSEGRUNRES for BFAC..TSECIFRS : %1!' , @rowcnt
	
	

--COMMIT TRAN
--print "commit done"

return 0

go

if object_id('PsPortfolioCalc') is not null
  print '<<< CREATED PROC PsPortfolioCalc >>>'
else
  print '<<< FAILED CREATING PROC PsPortfolioCalc >>>'
go
grant execute on PsPortfolioCalc TO GOMEGA
go
grant execute on PsPortfolioCalc TO GDBBATCH
go
