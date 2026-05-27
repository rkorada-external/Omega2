use BSEG
go

if object_id('PsPortfolioExtractRet') is not null
begin
  drop procedure PsPortfolioExtractRet
   if object_id('PsPortfolioExtractRet') is not null
      print '<<< FAILED DROPPING procedure PsPortfolioExtractRet >>>'
    else
      print '<<< DROPPED procedure PsPortfolioExtractRet >>>'
end
go

create procedure PsPortfolioExtractRet
(
	@p_erreur varchar(64)=null output
)
with execute as caller as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : Bhimasen Karri
Date de creation        : 06/04/2021
Description du programme: Fetch contract details with segmentation details
Conditions d'execution  : ESEJ2071
Commentaires            :
_________________
MODIFICATIONS
MOD01 24/09/2021 - KBhimasen - 98946 : Porfolio Life Batch - Exclude simulation segmentation
MOD02 21/03/2022 - K Bhimasen - Spira#102714 - IFRS17 Retro Life Portfolio - New rules + Fix Parent & Local Norms
MOD03 02/09/2022 - Amit Bansal - Spira#104213 - IFRS17 Retro Life Portfolio - Don't take in account canceled placement
MOD04 20/09/2022 - Amit Bansal - Spira#102712 - IFRS17 Retro Life Portfolio - Inception status at Pending and first closing date (Retro)
MOD05 - 03/03/2023 - K Bhimasen - Spira#108480 - IFRS17 - Omega Evolutions - Specific Segmentation for Local Korea and Parent Ireland Retro portfolio Sub-Portfolio
*****************************************************/

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
	SGMT_NF USGMT_NF  NULL,
	SGTLVL_NT int  NULL, 
	SEGCTRTYP_CT UBANVAL_CT NULL, 
	RETCTR_NF URETCTR_NF NOT NULL, 
	RTY_NF UUWY_NF NOT NULL,
	RTO_NF UCLI_NF NOT NULL,
	SSD_CF USSD_CF NOT NULL,
	SGTTYP_NT USGTTYP_NT  NULL,
	SGTVER_NT int  NULL,
    SGT_NT	USGT_NT	 NULL,
    
	CRE_D datetime NOT NULL,
	CTRTYP_CT CHAR(1) NOT NULL,
	GRPIFRSSEG_CT   USEG_NF    NULL,
    GRPIFRSSEG_LL   UL64       NULL,
	GRPIFRSSEG1_CT  USEG_NF    NULL,
    GRPIFRSSEG1_LL  UL64       NULL,
    
	PARIFRSSEG_CT   USEG_NF    NULL,
    PARIFRSSEG_LL   UL64       NULL,	
	PARIFRSSEG1_CT  USEG_NF    NULL,
    PARIFRSSEG1_LL  UL64       NULL,

    LOCIFRSSEG_CT   USEG_NF    NULL,
    LOCIFRSSEG_LL   UL64       NULL,
    LOCIFRSSEG1_CT  USEG_NF    NULL,
    LOCIFRSSEG1_LL  UL64       NULL,
	PARSGMT_NF 		USGMT_NF 	NULL,
	GRPINISTS_CT	tinyint	   NULL,		--MOD02
	PARINISTS_CT	tinyint	   NULL,		--MOD02
	LOCINISTS_CT	tinyint	   NULL,		--MOD02
	
	CLISSD_CF    	USSD_CF    NULL,
	GRPMANSEG_B  	bit   	   NOT NULL	,
	GRPFSTCLO_D    datetime   NULL,   --MOD04
    PARFSTCLO_D    datetime   NULL,   --MOD04 
    LCLFSTCLO_D    datetime   NULL     --MOD04
)

INSERT INTO #DATA (SGT_NT,SGTVER_NT, SGTTYP_NT) 
SELECT SGT_NT, SGTVER_NT, SGTTYP_NT from best..tsegmentation  where SGTTYP_NT in (75,76,77) and SGTSTS_CF = '3'

declare @erreur int,
		@datacount int,
		@sgt_nt USGT_NT,
		@sgtver_nt USGTVER_NT,
		@sgtrun_nt USGTRUN_NT, 
		@sgtrestabnme_ll UL64,
		@sgttyp_nt USGTTYP_NT,
		@tran_imbr	bit,
		@todaysDate datetime,
		@query varchar(1500),
		@addQuery varchar(150)

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
				AND SGTSIMU_B = 0		--MOD01				
			ORDER BY SGTRUN_NT, LSTUPD_D DESC 
			
		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
			   goto fin
		end	
		
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
		
			IF @sgttyp_nt = 75
			BEGIN
				SELECT @addQuery = " AND ISNULL(GRPINISTS_CT,0) in (0,1)  "			
			END
			
			IF @sgttyp_nt = 76
			BEGIN
				SELECT @addQuery = " AND ISNULL(PARINISTS_CT,0) in (0,1) "			
			END
			
			IF @sgttyp_nt = 77
			BEGIN
				SELECT @addQuery = " AND ISNULL(LOCINISTS_CT,0) in (0,1)  "			
			END
			
			-- For Retro
           select @query = "INSERT INTO #DATA_SEL (SGMT_NF, SGTLVL_NT, SEGCTRTYP_CT , RETCTR_NF , RTY_NF, RTO_NF, SSD_CF, 
            SGTTYP_NT, SGTVER_NT, SGT_NT, CRE_D,CTRTYP_CT, GRPINISTS_CT, PARINISTS_CT, LOCINISTS_CT, CLISSD_CF, GRPMANSEG_B )
              SELECT  A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.RTO_NF, 
            A.SSD_CF, @sgttyp_nt,  @sgtver_nt, @sgt_nt ,  @todaysDate, 'R', B.GRPINISTS_CT, B.PARINISTS_CT, B.LOCINISTS_CT, ISNULL(D.CLISSD_CF,0), B.GRPMANSEG_B
            FROM " + @sgtrestabnme_ll + " A, BREF..TBATCHSSD E, BRET..TRETCTR C ,  BRET..TRETIFRS B, BCLI..TCLIENT D, BREF..TESB F, BRET..TRETSEC G, BRET..TPLACEMT H
                WHERE ISNULL(SEGCTRTYP_CT,'') NOT IN ('1','2') AND A.SSD_CF = E.SSD_CF AND E.BATCHUSER_CF = suser_name()
                AND  C.RETCTR_NF = A.CTR_NF AND C.RTY_NF = A.UWY_NF 
                AND  C.RETCTR_NF  = B.RETCTR_NF AND C.RTY_NF = B.RTY_NF AND G.RETCTR_NF = A.CTR_NF AND G.RTY_NF = A.UWY_NF 
				AND  G.RETCTR_NF  = B.RETCTR_NF AND G.RTY_NF = B.RTY_NF AND F.LIFE_CF = 1 AND C.ESB_CF = F.ESB_CF 
				AND C.SSD_CF = F.SSD_CF AND A.SSD_CF = F.SSD_CF AND C.RETCTRSTS_CT  IN (3, 19)  AND H.RTO_NF = D.CLI_NF AND C.RETCTR_NF = H.RETCTR_NF 
				AND C.RTY_NF = H.RTY_NF AND H.HIS_B = 0 AND H.PLCSTS_CT IN (16, 19) AND H.ACCPLC_B=1" +@addQuery  

			execute(@query)
			
			select @query = "INSERT INTO #DATA_SEL ( RETCTR_NF , RTY_NF, RTO_NF, SSD_CF, CRE_D, CTRTYP_CT, GRPINISTS_CT, PARINISTS_CT, LOCINISTS_CT, CLISSD_CF, GRPMANSEG_B )
            SELECT   B.RETCTR_NF, B.RTY_NF, H.RTO_NF, C.SSD_CF, @todaysDate, 'R', B.GRPINISTS_CT, B.PARINISTS_CT, B.LOCINISTS_CT, ISNULL(D.CLISSD_CF,0), B.GRPMANSEG_B
			FROM  BREF..TBATCHSSD E, BRET..TRETCTR C ,  BRET..TRETIFRS B, BCLI..TCLIENT D, BREF..TESB F, BRET..TRETSEC G, BRET..TPLACEMT H
            WHERE C.RETCTR_NF  = B.RETCTR_NF AND C.RTY_NF = B.RTY_NF AND  G.RETCTR_NF  = B.RETCTR_NF AND G.RTY_NF = B.RTY_NF 
			AND F.LIFE_CF = 1 AND C.ESB_CF = F.ESB_CF AND C.SSD_CF = F.SSD_CF AND E.SSD_CF = F.SSD_CF AND E.BATCHUSER_CF = suser_name() 
			AND C.RETCTRSTS_CT  IN (3, 19)  AND H.RTO_NF = D.CLI_NF AND C.RETCTR_NF = H.RETCTR_NF AND C.RTY_NF = H.RTY_NF AND H.HIS_B = 0 
			AND H.PLCSTS_CT IN (16, 19) 
			AND H.ACCPLC_B=1" +@addQuery
			
			execute(@query)
			
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


SELECT * FROM #DATA_SEL

return 0

fin:
return @erreur 

go

if object_id('PsPortfolioExtractRet') is not null
  print '<<< CREATED PROC PsPortfolioExtractRet >>>'
else
  print '<<< FAILED CREATING PROC PsPortfolioExtractRet >>>'
go
grant execute on PsPortfolioExtractRet TO GOMEGA
go
grant execute on PsPortfolioExtractRet TO GDBBATCH
go
