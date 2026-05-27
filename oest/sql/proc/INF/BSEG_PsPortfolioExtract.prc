use BSEG
go

if object_id('PsPortfolioExtract') is not null
begin
  drop procedure PsPortfolioExtract
   if object_id('PsPortfolioExtract') is not null
      print '<<< FAILED DROPPING procedure PsPortfolioExtract >>>'
    else
      print '<<< DROPPED procedure PsPortfolioExtract >>>'
end
go

create procedure PsPortfolioExtract
(
	@p_ctrtyp_cf tinyint,			--1 for TRT, 2 -FAC
	@p_erreur varchar(64)=null output
)
with execute as caller as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : KBagwe
Date de creation        : 09/10/2020
Description du programme: Fetch contract details with segmentation details
Conditions d'execution  : ESEJ2071
Commentaires            :
_________________
MODIFICATIONS
MOD01 22/10/2020 - 90856 : I17: Main LOB - Feeding the Field I17 Segment / Portfolio for the group process - Copy
MOD02 28/01/2021 - BKARRI- 92826 : I17: Assumed - Add Section Status 17 for Level of Aggregation (Portfolio - Subportfolio) - Copy
MOD03 18/02/2021 - BKARRI - 92406 : I17: Management of Portoflio/subportfolio for Assumed involved in IO - Copy
MOD04 24/09/2021 - BKARRI - 98946 : Porfolio Life Batch - Exclude simulation segmentation
*****************************************************/

declare @ctrtyp_ct char(1)

if @p_ctrtyp_cf = 1
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
	SGTTYP_NT USGTTYP_NT NOT NULL,
	SGTVER_NT int NOT NULL,
    SGT_NT	USGT_NT	NOT NULL,
    END_NT UEND_NT,
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
	PARSGMT_NF USGMT_NF NULL,
	CLISSD_CF    USSD_CF       NULL		--MOD03
)




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
		@query varchar(1500),
		@addQuery varchar(150)

SELECT @todaysDate =getdate()
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
				AND SGTSIMU_B = 0		--MOD04
			ORDER BY SGTRUN_NT, LSTUPD_D DESC 
			
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
		
			IF @sgttyp_nt = 64
			BEGIN
				SELECT @addQuery = " AND ISNULL(GRPINISTS_CT,0) in (0,1)  "			--MOD03
			END
			
			IF @sgttyp_nt = 65
			BEGIN
				SELECT @addQuery = " AND ISNULL(PARINISTS_CT,0) in (0,1) "			--MOD03
			END
			
			IF @sgttyp_nt = 66
			BEGIN
				SELECT @addQuery = " AND ISNULL(LOCINISTS_CT,0) in (0,1)  "			--MOD03
			END
			
			-- For Treaty  
			--MOD03[START]
			select @query = "INSERT INTO #DATA_SEL (SGMT_NF, SGTLVL_NT, SEGCTRTYP_CT , CTR_NF , UWY_NF, UW_NT, SEC_NF, RTO_NF, SSD_CF, 
			SGTTYP_NT, SGTVER_NT, SGT_NT, END_NT,CRE_D,CTRTYP_CT,CLISSD_CF )
	  		SELECT  A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF, 
	    	A.SSD_CF, @sgttyp_nt,  @sgtver_nt, @sgt_nt ,F.END_NT, @todaysDate, 'T',ISNULL(D.CLISSD_CF,0)
	    	FROM " + @sgtrestabnme_ll + " A, BREF..TBATCHSSD E, BTRT..TCONTR C ,  BTRT..TSECTION F, BTRT..TSECIFRS B , BCLI..TCLIENT D
	            WHERE SEGCTRTYP_CT = @ctrtyp_ct AND A.SSD_CF = E.SSD_CF AND E.BATCHUSER_CF = suser_name()
				AND  C.CTR_NF = A.CTR_NF AND C.UWY_NF = A.UWY_NF AND C.UW_NT = A.UW_NT AND F.END_NT = C.END_NT  
				AND  F.CTR_NF = B.CTR_NF AND F.UWY_NF = B.UWY_NF AND F.UW_NT = B.UW_NT AND F.END_NT = B.END_NT AND F.SEC_NF = B.SEC_NF  
	            AND  F.CTR_NF = A.CTR_NF AND F.UWY_NF = A.UWY_NF AND F.UW_NT = A.UW_NT AND F.SEC_NF = A.SEC_NF AND F.LOB_CF IN ('30', '31')
				AND C.CTRSTS_CT IN (14, 16, 17, 19) AND C.CED_NF = D.CLI_NF" +@addQuery 				--MOD01, MOD02, MOD03[END]
				
			execute(@query)
			
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

SELECT * FROM #DATA_SEL

return 0

fin:
return @erreur 

go

if object_id('PsPortfolioExtract') is not null
  print '<<< CREATED PROC PsPortfolioExtract >>>'
else
  print '<<< FAILED CREATING PROC PsPortfolioExtract >>>'
go
grant execute on PsPortfolioExtract TO GOMEGA
go
grant execute on PsPortfolioExtract TO GDBBATCH
go
