use BSEG
go

if object_id('PsSEGCM') is not null
begin
  drop procedure PsSEGCM
   if object_id('PsSEGCM') is not null
      print '<<< FAILED DROPPING procedure PsSEGCM >>>'
    else
      print '<<< DROPPED procedure PsSEGCM >>>'
end
go

create procedure PsSEGCM
(
	@Ctyp_cf tinyint,			--1 for TRT, 2 -FAC
	@p_erreur varchar(64)=null output
)
with execute as caller as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BTRT
Auteur                  : Charles SOCIE
Date de creation        : 13/03/2019
Description du programme: Fetch contract details with segmentation details
Conditions d'execution  : ESEJ2051
Commentaires            :
_________________
MODIFICATIONS
MOD01:12/03/2020:KBagwe: Spira#84246
MOD02:01/12/2020:KBagwe:91591: Main lob batch update
MOD03:19/05/2021:KBhimasen: Spira#95981
MOD04:07/06/2021:KBhimasen: 96758: Batch Main LoB - Only consider SEG production results
MOD05:09/06/2021:KBhimasen: 96757: Local closing -Batch main lob should consider CR closing date per norm
MOD06:30/09/2022:KBhimasen:106885: Main lob batch : include Onerous Q+1
*****************************************************/

declare @ctrtyp_ct char(1)

if @Ctyp_cf = 1
	select @ctrtyp_ct = '1'			-- Treaty
else
	select @ctrtyp_ct = '2'			-- FAC 


CREATE TABLE #DATA(
    SGT_NT	USGT_NT	NOT NULL,
    SGTVER_NT	USGTVER_NT	NULL,
	SGTTYP_NT USGTTYP_NT NOT NULL
)

CREATE TABLE #SGT(
    SGTRUN_NT	USGTRUN_NT NOT NULL,
    SGTRESTABNME_LL	UL64 NOT NULL,
	SGTTYP_NT USGTTYP_NT NOT NULL,
	SGTVER_NT int NOT NULL,
    SGT_NT	USGT_NT	NOT NULL
)



CREATE TABLE #DATA_SEL(
	SGMT_NF USGMT_NF NOT NULL,
	SGTLVL_NT int NOT NULL, 
	SEGCTRTYP_CT UBANVAL_CT, 
	CTR_NF UCTR_NF NOT NULL, 
	UWY_NF UUWY_NF NOT NULL,
	UW_NT UUW_NT NOT NULL,
	SEC_NF USEC_NF NOT NULL,
	RTO_NF UCLI_NF NOT NULL,
	SSD_CF USSD_CF NOT NULL,
	CR_NF CHAR(10)  NOT NULL,
	TGRPFIRCLO_D DATETIME NULL,
	TPARFIRCLO_D DATETIME NULL,
	TLOCFIRCLO_D DATETIME NULL,
	FGRPFIRCLO_D DATETIME NULL,
	FPARFIRCLO_D DATETIME NULL,
	FLOCFIRCLO_D DATETIME NULL,
	SGTTYP_NT USGTTYP_NT NOT NULL,
	SGTVER_NT int NOT NULL,
    SGT_NT	USGT_NT	NOT NULL,
    END_NT UEND_NT,
    CRUWY_NF UUWY_NF NOT NULL,
    CRUW_NT         UUW_NT NOT NULL
)

--MOD06[START]

declare @year_sel int,
		@month_sel int,
		@startdate datetime,
		@enddate datetime
		
SELECT @year_sel= YEAR(CLODAT_D), @month_sel = MONTH(CLODAT_D) FROM  BEST..TI17REQJOBPLAN WHERE DBCLO_D = dateadd(day,0,convert(char(10), getdate(), 23)) AND NORME_CF IN ('I17G','I17P','I17L')

IF (@month_sel = 3)
BEGIN 
	SELECT @startdate = cast(@year_sel*10000+(@month_sel+1)*100+01  as char(8))
	SELECT @enddate = cast(@year_sel*10000+(@month_sel+3)*100+30  as char(8)) 
END

IF (@month_sel = 6)
BEGIN 
	SELECT @startdate = cast(@year_sel*10000+(@month_sel+1)*100+01  as char(8))
	SELECT @enddate = cast(@year_sel*10000+(@month_sel+3)*100+30  as char(8)) 
END

IF (@month_sel = 9)
BEGIN 
	SELECT @startdate = cast(@year_sel*10000+(@month_sel+1)*100+01  as char(8))
	SELECT @enddate = cast(@year_sel*10000+(@month_sel+3)*100+31  as char(8)) 
END


IF (@month_sel = 12)
BEGIN 
	SELECT @startdate = cast((@year_sel+1)*10000+01*100+01  as char(8))
	SELECT @enddate =cast((@year_sel+1)*10000+03*100+31  as char(8)) 
END

--MOD06[END]

INSERT INTO #DATA (SGT_NT,SGTVER_NT, SGTTYP_NT) 
SELECT SGT_NT, SGTVER_NT, SGTTYP_NT from best..tsegmentation  where SGTTYP_NT in (64,65,66) and SGTSTS_CF = '3'  

declare @erreur int,
		@datacount int,
		@sgt_nt USGT_NT,
		@sgtver_nt USGTVER_NT,
		@sgtrun_nt USGTRUN_NT, 
		@sgtrestabnme_ll UL64,
		@sgttyp_nt USGTTYP_NT,
		@tran_imbr	bit,
		@todaysDate datetime,
		@query varchar(2000),
		@addQuery varchar(200)

SELECT @todaysDate = getdate()
Declare cur_data Cursor For
		select SGT_NT , SGTVER_NT,SGTTYP_NT  from #DATA

		 		

OPEN cur_data
	Fetch cur_data Into  @sgt_nt, @sgtver_nt ,@sgttyp_nt

		While (@@sqlstatus = 0)
		Begin
 		--SELECT @sgt_nt, @sgtver_nt,@sgttyp_nt
		
		INSERT INTO #SGT (SGTRUN_NT,SGTRESTABNME_LL,SGTTYP_NT, SGTVER_NT,SGT_NT)	
		SELECT TOP 1 SGTRUN_NT, SGTRESTABNME_LL, @sgttyp_nt, @sgtver_nt,@sgt_nt FROM BSEG..TSEGRUN
			WHERE SGT_NT = @sgt_nt 		
				AND SGTVER_NT = @sgtver_nt 		
				AND SGTOBSOLETE_B = 0  
				AND SGTRUNSTS_CT = '5'  	
				AND SGTSIMU_B = 0						--MOD04		
			ORDER BY SGTRUN_NT DESC, LSTUPD_D DESC 		--MOD03
			
		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
			   goto fin
		end		
		
		--select @datacount = @datacount + 1
		Fetch cur_data Into @sgt_nt, @sgtver_nt,@sgttyp_nt
		End
	Close cur_data
	Deallocate Cursor cur_data	

Declare cur_seg Cursor For
		select distinct SGTRUN_NT , SGTRESTABNME_LL,SGTTYP_NT, SGTVER_NT, SGT_NT from #SGT

OPEN cur_seg
	Fetch cur_seg Into  @sgtrun_nt, @sgtrestabnme_ll, @sgttyp_nt, @sgtver_nt, @sgt_nt 

		While (@@sqlstatus = 0)
		Begin
		
		--MOD05[START]
		IF @sgttyp_nt = 64
			BEGIN
				SELECT @addQuery = " AND ISNULL(GRPFIRCLO_D,'') = ''  "			
			END
			
			IF @sgttyp_nt = 65
			BEGIN
				SELECT @addQuery = " AND ISNULL(PARFIRCLO_D,'') = '' "			
			END
			
			IF @sgttyp_nt = 66
			BEGIN
				SELECT @addQuery = " AND ISNULL(LOCFIRCLO_D,'') = ''  "			
			END
		--MOD05[END]
		
		if (@ctrtyp_ct = '1')
		BEGIN
			-- For Treaty  
			select @query = "INSERT INTO #DATA_SEL (SGMT_NF, SGTLVL_NT, SEGCTRTYP_CT , CTR_NF , UWY_NF, UW_NT, SEC_NF, RTO_NF, SSD_CF, CR_NF, TGRPFIRCLO_D,TPARFIRCLO_D,TLOCFIRCLO_D,SGTTYP_NT, SGTVER_NT, SGT_NT,END_NT,CRUWY_NF, CRUW_NT )
	  		SELECT  A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF, 
	    	A.SSD_CF, C.CR_NF, C.GRPFIRCLO_D,C.PARFIRCLO_D,C.LOCFIRCLO_D, @sgttyp_nt,  @sgtver_nt, @sgt_nt ,f.END_NT, C.CRUWY_NF, C.CRUW_NT 
	    	FROM " + @sgtrestabnme_ll + " A, BREF..TBATCHSSD E, BTRT..TCR C ,  BTRT..TCRCONTR F
	            WHERE SEGCTRTYP_CT = @ctrtyp_ct AND A.SSD_CF = E.SSD_CF AND E.BATCHUSER_CF = suser_name()
	            AND  F.CTR_NF = A.CTR_NF AND F.UWY_NF = A.UWY_NF AND F.UW_NT = A.UW_NT 
	            AND C.CR_NF = F.CR_NF  AND C.CRUWY_NF = F.CRUWY_NF AND C.CRUW_NT = F.CRUW_NT" + @addQuery		--MOD05
	            --ORDER BY A.SEGCTRTYP_CT ASC"
			
			execute(@query)
		END
		
		if (@ctrtyp_ct = '2')
		BEGIN
		select @query = ""
			-- For Facultative
			select @query = "INSERT INTO #DATA_SEL (SGMT_NF, SGTLVL_NT, SEGCTRTYP_CT , CTR_NF , UWY_NF, UW_NT, SEC_NF, RTO_NF, SSD_CF, CR_NF, FGRPFIRCLO_D,FPARFIRCLO_D,FLOCFIRCLO_D,SGTTYP_NT, SGTVER_NT, SGT_NT,END_NT,CRUWY_NF, CRUW_NT)
		    SELECT  A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF, 
		    A.SSD_CF, C.CR_NF, C.GRPFIRCLO_D, C.PARFIRCLO_D, C.LOCFIRCLO_D, @sgttyp_nt,  @sgtver_nt, @sgt_nt ,f.END_NT, C.CRUWY_NF, C.CRUW_NT 
		    FROM " + @sgtrestabnme_ll + " A, BREF..TBATCHSSD E, BFAC..TCR C ,  BFAC..TCRCONTR F
            WHERE SEGCTRTYP_CT = @ctrtyp_ct AND A.SSD_CF = E.SSD_CF AND E.BATCHUSER_CF = suser_name()
            AND  F.CTR_NF = A.CTR_NF AND F.UWY_NF = A.UWY_NF AND F.UW_NT = A.UW_NT  
            AND C.CR_NF = F.CR_NF  AND C.CRUWY_NF = F.CRUWY_NF AND C.CRUW_NT = F.CRUW_NT" + @addQuery		--MOD05
           -- ORDER BY A.SEGCTRTYP_CT ASC"
			
			execute(@query)
		END 			
		--select @datacount = @datacount + 1
		Fetch cur_seg Into @sgtrun_nt, @sgtrestabnme_ll,@sgttyp_nt, @sgtver_nt, @sgt_nt
		End
	Close cur_seg
	Deallocate Cursor cur_seg	

	select @erreur = @@error	
	if @erreur != 0 
	  begin 
		   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
		   goto fin
	end	 


CREATE  NONCLUSTERED INDEX AK_DATA_CTR ON #DATA_SEL(CTR_NF,UWY_NF,UW_NT,SEC_NF, SSD_CF,END_NT)


SELECT DISTINCT A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF , 'T', B.SSD_CF,B.ACCESB_CF , A.SGTTYP_NT, A.CR_NF, B.END_NT, 
	    0, A.SGTVER_NT, A.SGT_NT ,A.TGRPFIRCLO_D,A.TPARFIRCLO_D,A.TLOCFIRCLO_D,A.FGRPFIRCLO_D,A.FPARFIRCLO_D,A.FLOCFIRCLO_D ,
	(case when SCOGLOEGP_M != NULL then SCOGLOEGP_M else SCOORGEGP_M END) as SCOGLOEGP_M,
	B.UWORG_CF , B.CED_NF , ISNULL(C.CLISSD_CF,0) as CLISSD_CF, f.EGPCUR_CF,A.CRUWY_NF, A.CRUW_NT, NULL AS	GRPIFRSLOB_CF ,NULL AS	GRPIFRSLOBEGP_R ,NULL AS	GRPIFRSLOB_LL  ,NULL AS	GRPIFRSSEG_CT  ,NULL AS	GRPIFRSSEG_LL  ,
	NULL AS	PARIFRSLOB_CF ,NULL AS	PARIFRSLOBEGP_R,NULL AS	PARIFRSLOB_LL,NULL AS	PARIFRSSEG_CT,NULL AS	PARIFRSSEG_LL,	NULL AS	LOCIFRSLOB_CF,NULL AS	LOCIFRSLOBEGP_R,NULL AS	LOCIFRSLOB_LL,NULL AS	LOCIFRSSEG_CT,NULL AS	LOCIFRSSEG_LL,
		@todaysDate 
			FROM #DATA_SEL  A, BTRT..TCONTR B ,  BTRT..TSECTION D , BTRT..TFAMLIA f, BCLI..TCLIENT c
			WHERE  A.SSD_CF =  B.SSD_CF AND A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT  
			AND A.CTR_NF = D.CTR_NF AND A.UWY_NF = D.UWY_NF AND A.UW_NT = D.UW_NT AND A.SEC_NF = D.SEC_NF AND a.END_NT = B.END_NT AND D.END_NT = B.END_NT 
		 AND f.CTR_NF = D.CTR_NF AND f.UWY_NF = D.UWY_NF AND f.UW_NT = D.UW_NT AND f.SEC_NF = D.SEC_NF AND f.END_NT = D.END_NT
			AND D.SECSTS_CT IN (16, 14, 19,18,17  )  AND B.CED_NF = C.CLI_NF AND SEGCTRTYP_CT = @ctrtyp_ct and D.LOB_CF NOT IN ('30','31')
UNION ALL
SELECT DISTINCT A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF , 'F', B.SSD_CF,B.ACCESB_CF ,A.SGTTYP_NT, A.CR_NF, B.END_NT, 
		G.DIV_NT, A.SGTVER_NT, A.SGT_NT ,A.TGRPFIRCLO_D,A.TPARFIRCLO_D,A.TLOCFIRCLO_D,A.FGRPFIRCLO_D,A.FPARFIRCLO_D,A.FLOCFIRCLO_D ,
(case when F.SCOGLOEGP_M != NULL then F.SCOGLOEGP_M else F.SCOORGEGP_M END) as SCOGLOEGP_M,
B.UWORG_CF , B.CED_NF , ISNULL(C.CLISSD_CF,0) as CLISSD_CF, f.EGPCUR_CF,A.CRUWY_NF, A.CRUW_NT,NULL AS	GRPIFRSLOB_CF ,NULL AS	GRPIFRSLOBEGP_R ,NULL AS	GRPIFRSLOB_LL  ,NULL AS	GRPIFRSSEG_CT  ,NULL AS	GRPIFRSSEG_LL  ,	NULL AS	PARIFRSLOB_CF ,
NULL AS	PARIFRSLOBEGP_R,NULL AS	PARIFRSLOB_LL,NULL AS	PARIFRSSEG_CT,NULL AS	PARIFRSSEG_LL,	NULL AS	LOCIFRSLOB_CF,NULL AS	LOCIFRSLOBEGP_R,NULL AS	LOCIFRSLOB_LL,NULL AS	LOCIFRSSEG_CT,NULL AS	LOCIFRSSEG_LL,
@todaysDate 
FROM #DATA_SEL  A, BFAC..TCONTR B ,  BFAC..TSECTION D , BFAC..TFAMLIA f,BCLI..TCLIENT c,  BFAC..TDIVISIO G 
		WHERE  A.SSD_CF =  B.SSD_CF AND A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT  
		AND A.CTR_NF = D.CTR_NF AND A.UWY_NF = D.UWY_NF AND A.UW_NT = D.UW_NT AND A.SEC_NF = D.SEC_NF AND a.END_NT = B.END_NT AND D.END_NT = B.END_NT 
	    AND f.CTR_NF = D.CTR_NF AND f.UWY_NF = D.UWY_NF AND f.UW_NT = D.UW_NT AND f.SEC_NF = D.SEC_NF AND f.END_NT = D.END_NT
	 	AND B.CTR_NF = G.CTR_NF AND B.UWY_NF = G.UWY_NF AND B.UW_NT = G.UW_NT AND B.END_NT = G.END_NT AND G.DIV_NT = D.DIV_NT
		AND D.SECSTS_CT IN (16, 14, 19,18,17  )  AND B.CED_NF = C.CLI_NF AND SEGCTRTYP_CT = @ctrtyp_ct and D.LOB_CF NOT IN ('30','31')
--MOD06[START]
UNION ALL
SELECT DISTINCT A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF , 'T', B.SSD_CF,B.ACCESB_CF , A.SGTTYP_NT, A.CR_NF, B.END_NT, 
	    0, A.SGTVER_NT, A.SGT_NT ,A.TGRPFIRCLO_D,A.TPARFIRCLO_D,A.TLOCFIRCLO_D,A.FGRPFIRCLO_D,A.FPARFIRCLO_D,A.FLOCFIRCLO_D ,
	(case when SCOGLOEGP_M != NULL then SCOGLOEGP_M else SCOORGEGP_M END) as SCOGLOEGP_M,
	B.UWORG_CF , B.CED_NF , ISNULL(C.CLISSD_CF,0) as CLISSD_CF, f.EGPCUR_CF,A.CRUWY_NF, A.CRUW_NT, NULL AS	GRPIFRSLOB_CF ,NULL AS	GRPIFRSLOBEGP_R ,NULL AS	GRPIFRSLOB_LL  ,NULL AS	GRPIFRSSEG_CT  ,NULL AS	GRPIFRSSEG_LL  ,
	NULL AS	PARIFRSLOB_CF ,NULL AS	PARIFRSLOBEGP_R,NULL AS	PARIFRSLOB_LL,NULL AS	PARIFRSSEG_CT,NULL AS	PARIFRSSEG_LL,	NULL AS	LOCIFRSLOB_CF,NULL AS	LOCIFRSLOBEGP_R,NULL AS	LOCIFRSLOB_LL,NULL AS	LOCIFRSSEG_CT,NULL AS	LOCIFRSSEG_LL,
		@todaysDate 
			FROM #DATA_SEL  A, BTRT..TCONTR B ,  BTRT..TSECTION D , BTRT..TFAMLIA f, BCLI..TCLIENT c, BTRT..TSECIFRS E
			WHERE  A.SSD_CF =  B.SSD_CF AND A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT  
			AND A.CTR_NF = D.CTR_NF AND A.UWY_NF = D.UWY_NF AND A.UW_NT = D.UW_NT AND A.SEC_NF = D.SEC_NF AND a.END_NT = B.END_NT AND D.END_NT = B.END_NT 
			AND f.CTR_NF = D.CTR_NF AND f.UWY_NF = D.UWY_NF AND f.UW_NT = D.UW_NT AND f.SEC_NF = D.SEC_NF AND f.END_NT = D.END_NT
			AND D.CTR_NF = E.CTR_NF AND D.UWY_NF = E.UWY_NF AND D.UW_NT = E.UW_NT AND D.SEC_NF = E.SEC_NF AND D.END_NT = E.END_NT
			AND E.FRCIFRSBTCH_NT = 1 AND B.CTRINC_D >= @startdate AND B.CTRINC_D <= @enddate
			AND B.CED_NF = C.CLI_NF AND SEGCTRTYP_CT = @ctrtyp_ct and D.LOB_CF NOT IN ('30','31')
UNION ALL
SELECT DISTINCT A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF , 'F', B.SSD_CF,B.ACCESB_CF ,A.SGTTYP_NT, A.CR_NF, B.END_NT, 
		G.DIV_NT, A.SGTVER_NT, A.SGT_NT ,A.TGRPFIRCLO_D,A.TPARFIRCLO_D,A.TLOCFIRCLO_D,A.FGRPFIRCLO_D,A.FPARFIRCLO_D,A.FLOCFIRCLO_D ,
(case when F.SCOGLOEGP_M != NULL then F.SCOGLOEGP_M else F.SCOORGEGP_M END) as SCOGLOEGP_M,
B.UWORG_CF , B.CED_NF , ISNULL(C.CLISSD_CF,0) as CLISSD_CF, f.EGPCUR_CF,A.CRUWY_NF, A.CRUW_NT,NULL AS	GRPIFRSLOB_CF ,NULL AS	GRPIFRSLOBEGP_R ,NULL AS	GRPIFRSLOB_LL  ,NULL AS	GRPIFRSSEG_CT  ,NULL AS	GRPIFRSSEG_LL  ,	NULL AS	PARIFRSLOB_CF ,
NULL AS	PARIFRSLOBEGP_R,NULL AS	PARIFRSLOB_LL,NULL AS	PARIFRSSEG_CT,NULL AS	PARIFRSSEG_LL,	NULL AS	LOCIFRSLOB_CF,NULL AS	LOCIFRSLOBEGP_R,NULL AS	LOCIFRSLOB_LL,NULL AS	LOCIFRSSEG_CT,NULL AS	LOCIFRSSEG_LL,
@todaysDate 
FROM #DATA_SEL  A, BFAC..TCONTR B ,  BFAC..TSECTION D , BFAC..TFAMLIA f,BCLI..TCLIENT c,  BFAC..TDIVISIO G, BFAC..TSECIFRS E 
		WHERE  A.SSD_CF =  B.SSD_CF AND A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT  
		AND A.CTR_NF = D.CTR_NF AND A.UWY_NF = D.UWY_NF AND A.UW_NT = D.UW_NT AND A.SEC_NF = D.SEC_NF AND a.END_NT = B.END_NT AND D.END_NT = B.END_NT 
	    AND f.CTR_NF = D.CTR_NF AND f.UWY_NF = D.UWY_NF AND f.UW_NT = D.UW_NT AND f.SEC_NF = D.SEC_NF AND f.END_NT = D.END_NT
	 	AND B.CTR_NF = G.CTR_NF AND B.UWY_NF = G.UWY_NF AND B.UW_NT = G.UW_NT AND B.END_NT = G.END_NT AND G.DIV_NT = D.DIV_NT
		AND D.CTR_NF = E.CTR_NF AND D.UWY_NF = E.UWY_NF AND D.UW_NT = E.UW_NT AND D.SEC_NF = E.SEC_NF AND D.END_NT = E.END_NT
		AND E.FRCIFRSBTCH_NT = 1 AND B.CTRINC_D >= @startdate AND B.CTRINC_D <= @enddate
		AND B.CED_NF = C.CLI_NF AND SEGCTRTYP_CT = @ctrtyp_ct and D.LOB_CF NOT IN ('30','31')

--MOD06[END]

return 0

fin:
return @erreur 

go

if object_id('PsSEGCM') is not null
  print '<<< CREATED PROC PsSEGCM >>>'
else
  print '<<< FAILED CREATING PROC PsSEGCM >>>'
go
grant execute on PsSEGCM TO GOMEGA
go
grant execute on PsSEGCM TO GDBBATCH
go
