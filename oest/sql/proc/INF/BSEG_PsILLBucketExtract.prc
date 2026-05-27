use BSEG
go

if object_id('dbo.PsILLBucketExtract') is not null
begin
  drop procedure dbo.PsILLBucketExtract
   if object_id('dbo.PsILLBucketExtract') is not null
      print '<<< FAILED DROPPING procedure dbo.PsILLBucketExtract >>>'
    else
      print '<<< DROPPED procedure dbo.PsILLBucketExtract >>>'
end
go

create procedure dbo.PsILLBucketExtract	
(	
    --@p_clo_date   datetime,
    --@p_next_clo_date   datetime,
	@p_typeinv_cf 	char(4),
	@p_user char(4) = null
)
with execute as caller as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : JYP
Date de creation        : 15/09/2021
Description du programme: Fetch contract details with segmentation details
Conditions d'execution  : ESFD2051
Commentaires            :
_________________
MODIFICATIONS
MOD01 15/09/2021 :SPIRA 97283:JYP  : extract file CSUOE + Illiquidity 
MOD02 18/02/2022 :SPIRA 101705/102167 :JYP : extract retro, review status 
MOD03 21/02/2022 :SPIRA 101705/102167 :JYP : new rules to select accept/retro 
MOD03 18/10/2022 :SPIRA 102482 :MZM : IFRS17 Onerous Q+1 - additional scope / accept 
MOD05 29/09/2025 :US6929  par défaut le user = le user du site ubam, ubas ou ubeu
*****************************************************/
declare @p_erreur varchar(64)

--MOD05 
if @p_user = NULL 
	select @p_user = suser_name()
	


CREATE TABLE #DATA(
    SGT_NT	USGT_NT	NOT NULL,
    SGTVER_NT	USGTVER_NT	NULL,
	SGTTYP_NT USGTTYP_NT NOT NULL
)

CREATE TABLE #SGT(
    SGTSCOPE_CT  UBANVAL_CT NOT NULL,
    SGTRUN_NT	 USGTRUN_NT NOT NULL,
    SGTRESTABNME_LL	UL64 NOT NULL,
	SGTTYP_NT USGTTYP_NT NOT NULL,
	SGTVER_NT int NOT NULL,
    SGT_NT	USGT_NT	NOT NULL
)


CREATE TABLE #DATA_SEL(
	NORME_CF CHAR(4) NOT NULL,
	CTR_NF UCTR_NF NOT NULL, 
    END_NT UEND_NT,
	SEC_NF USEC_NF NOT NULL,
	UWY_NF UUWY_NF NOT NULL,
	UW_NT UUW_NT NOT NULL,
	CTRTYP_CT CHAR(1) NOT NULL,
	--INISTS_CT int ,
	SGMT_NF USGMT_NF NOT NULL,
	SGTLVL_NT int NOT NULL,  
	SGTTYP_NT USGTTYP_NT NOT NULL,
	SEGCTRTYP_CT CHAR(1) ,
	SGTVER_NT int NOT NULL,
    SGT_NT	USGT_NT	NOT NULL,
	SGMT_LS UL16  NOT NULL ,
	SGMT_LL UL64 ,
	GRPINISTS_CT int NULL ,
	PARINISTS_CT int NULL,
	LOCINISTS_CT int NULL
)



INSERT INTO #DATA (SGT_NT,SGTVER_NT, SGTTYP_NT) 
SELECT SGT_NT, SGTVER_NT, SGTTYP_NT from best..tsegmentation  where SGTTYP_NT in (78,79,80,84,85,86) and SGTSTS_CF = '3'  

declare @erreur int,
		@datacount int,
		@sgt_nt USGT_NT,
		@sgtscope_ct UBANVAL_CT, 
		@sgtver_nt USGTVER_NT,
		@sgtrun_nt USGTRUN_NT, 
		@sgtrestabnme_ll UL64,
		@sgttyp_nt USGTTYP_NT,
		@tran_imbr	bit,
		@todaysDate datetime,
		@query varchar(1500),
		@addQuery varchar(150),
		@norme_cf varchar(4)
	
SELECT @todaysDate =getdate()
Declare cur_data Cursor For
		select SGT_NT , SGTVER_NT,SGTTYP_NT  from #DATA

		 		

OPEN cur_data
	Fetch cur_data Into  @sgt_nt, @sgtver_nt ,@sgttyp_nt


		While (@@sqlstatus = 0)
		Begin
 		--SELECT @sgt_nt, @sgtver_nt,@sgttyp_nt
		

		-------- accept data
		INSERT INTO #SGT (SGTSCOPE_CT,SGTRUN_NT,SGTRESTABNME_LL,SGTTYP_NT, SGTVER_NT,SGT_NT)	
		SELECT TOP 1 SGTSCOPE_CT,SGTRUN_NT, SGTRESTABNME_LL, @sgttyp_nt, @sgtver_nt,@sgt_nt FROM BSEG..TSEGRUN
			WHERE SGT_NT = @sgt_nt 		
				AND SGTVER_NT = @sgtver_nt 		
				AND SGTOBSOLETE_B = 0  
				AND SGTRUNSTS_CT = '5'  
				AND SGTSCOPE_CT = '1'
				AND SGTSIMU_B = 0
			ORDER BY SGTRUN_NT DESC, LSTUPD_D DESC 
			
		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 TSEGRUN_ACCEPT;" + convert(varchar(10),@erreur) + ";"
			   goto fin
		end		

		-------- retro data
		INSERT INTO #SGT (SGTSCOPE_CT,SGTRUN_NT,SGTRESTABNME_LL,SGTTYP_NT, SGTVER_NT,SGT_NT)	
		SELECT TOP 1 SGTSCOPE_CT,SGTRUN_NT, SGTRESTABNME_LL, @sgttyp_nt, @sgtver_nt,@sgt_nt FROM BSEG..TSEGRUN
			WHERE SGT_NT = @sgt_nt 		
				AND SGTVER_NT = @sgtver_nt 		
				AND SGTOBSOLETE_B = 0  
				AND SGTRUNSTS_CT = '5'  
				AND SGTSCOPE_CT = '2'
				AND SGTSIMU_B = 0
			ORDER BY SGTRUN_NT DESC, LSTUPD_D DESC 
			
		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 TSEGRUN_RETRO;" + convert(varchar(10),@erreur) + ";"
			   goto fin
		end		


		
		--select @datacount = @datacount + 1
		Fetch cur_data Into @sgt_nt, @sgtver_nt,@sgttyp_nt
		End
	Close cur_data
	Deallocate Cursor cur_data	

Declare cur_seg Cursor For
		select distinct SGTSCOPE_CT, SGTRUN_NT , SGTRESTABNME_LL,SGTTYP_NT, SGTVER_NT, SGT_NT from #SGT


OPEN cur_seg
	Fetch cur_seg Into  @sgtscope_ct, @sgtrun_nt, @sgtrestabnme_ll, @sgttyp_nt, @sgtver_nt, @sgt_nt 

		While (@@sqlstatus = 0)
		Begin
			-- MOD04
			declare @sts_list varchar(100)

		    IF(@p_typeinv_cf = 'POS')
			BEGIN
				select @sts_list = "(14,18,16,19)"
			END
			ELSE
			BEGIN
				select @sts_list = "(18,16,19)"
			END
			
			IF @sgttyp_nt = 78 OR @sgttyp_nt = 84
			BEGIN		 
				SELECT @norme_cf = "I17G"
			END
			
			IF @sgttyp_nt = 79 OR @sgttyp_nt = 85
			BEGIN
				SELECT @norme_cf = "I17P"
			END
			
			IF @sgttyp_nt = 80 OR @sgttyp_nt = 86
			BEGIN
				SELECT @norme_cf = "I17L"
			END

			
			IF ( @sgtscope_ct = "1" )
			BEGIN
			
				-- For Treaty  
	
				select @query = "INSERT INTO #DATA_SEL (NORME_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT ,CTRTYP_CT ,
								SGMT_NF ,SGTLVL_NT ,SGTTYP_NT,SEGCTRTYP_CT ,SGTVER_NT,SGT_NT,SGMT_LS,SGMT_LL, GRPINISTS_CT ,PARINISTS_CT , LOCINISTS_CT )
				SELECT  @norme_cf, A.CTR_NF,F.END_NT,A.SEC_NF, A.UWY_NF,A.UW_NT,'T',A.SGMT_NF, A.SGTLVL_NT, @sgttyp_nt, 
						A.SEGCTRTYP_CT, @sgtver_nt, @sgt_nt ,S.SGMT_LS,S.SGMT_LL, B.GRPINISTS_CT ,B.PARINISTS_CT , B.LOCINISTS_CT
				FROM " + @sgtrestabnme_ll + " A, BREF..TBATCHSSD E, BTRT..TCONTR C ,  BTRT..TSECTION F, BTRT..TSECIFRS B ,best..TSEGMT S
					WHERE SEGCTRTYP_CT = '1' AND A.SSD_CF = E.SSD_CF AND E.BATCHUSER_CF like @p_user -- suser_name()
					AND  C.CTR_NF = A.CTR_NF AND C.UWY_NF = A.UWY_NF AND C.UW_NT = A.UW_NT AND F.END_NT = C.END_NT  
					AND  F.CTR_NF = B.CTR_NF AND F.UWY_NF = B.UWY_NF AND F.UW_NT = B.UW_NT AND F.END_NT = B.END_NT AND F.SEC_NF = B.SEC_NF  
					AND  F.CTR_NF = A.CTR_NF AND F.UWY_NF = A.UWY_NF AND F.UW_NT = A.UW_NT AND F.SEC_NF = A.SEC_NF 
					AND (C.CTRSTS_CT IN (14, 16, 17, 19)  OR  (B.FRCIFRSBTCH_NT  = 1))
					AND S.SGMT_NF = A.SGMT_NF AND S.SGT_NT = " +  convert(char(10),@sgt_nt) + " 
					AND S.SGTVER_NT = " + convert(char(10),@sgtver_nt) 			
				
				execute(@query)
			
				-- For FAC  
				select @query = "INSERT INTO #DATA_SEL (NORME_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT ,CTRTYP_CT ,
								SGMT_NF ,SGTLVL_NT ,SGTTYP_NT,SEGCTRTYP_CT ,SGTVER_NT,SGT_NT,SGMT_LS,SGMT_LL , GRPINISTS_CT ,PARINISTS_CT , LOCINISTS_CT )			
				SELECT  @norme_cf, A.CTR_NF,F.END_NT,A.SEC_NF, A.UWY_NF,A.UW_NT,'F',A.SGMT_NF, A.SGTLVL_NT, @sgttyp_nt, 
						A.SEGCTRTYP_CT, @sgtver_nt, @sgt_nt ,S.SGMT_LS,S.SGMT_LL , B.GRPINISTS_CT ,B.PARINISTS_CT , B.LOCINISTS_CT
				FROM " + @sgtrestabnme_ll + "  A, BREF..TBATCHSSD E, BFAC..TCONTR C ,  BFAC..TSECTION F, BFAC..TSECIFRS B ,best..TSEGMT S
					WHERE SEGCTRTYP_CT = '2'  AND A.SSD_CF = E.SSD_CF AND E.BATCHUSER_CF like  @p_user --  suser_name()
					AND  C.CTR_NF = A.CTR_NF AND C.UWY_NF = A.UWY_NF AND C.UW_NT = A.UW_NT AND F.END_NT = C.END_NT  
					AND  F.CTR_NF = B.CTR_NF AND F.UWY_NF = B.UWY_NF AND F.UW_NT = B.UW_NT AND F.END_NT = B.END_NT AND F.SEC_NF = B.SEC_NF  
					AND  F.CTR_NF = A.CTR_NF AND F.UWY_NF = A.UWY_NF AND F.UW_NT = A.UW_NT AND F.SEC_NF = A.SEC_NF 
					AND ( C.CTRSTS_CT IN " + @sts_list  + " OR (B.FRCIFRSBTCH_NT  = 1)) 
					AND S.SGMT_NF = A.SGMT_NF AND S.SGT_NT = " +  convert(char(10),@sgt_nt) + " 
					AND S.SGTVER_NT = " + convert(char(10),@sgtver_nt)
	
				execute(@query)			

            END 
				
			
			IF ( @sgtscope_ct = "2" )
			BEGIN
			
				-- For RETRO  
				select @query = "INSERT INTO #DATA_SEL (NORME_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT ,CTRTYP_CT ,
								SGMT_NF ,SGTLVL_NT ,SGTTYP_NT,SEGCTRTYP_CT ,SGTVER_NT,SGT_NT,SGMT_LS,SGMT_LL, GRPINISTS_CT ,PARINISTS_CT , LOCINISTS_CT )			
				SELECT  @norme_cf, A.CTR_NF,0,G.RETSEC_NF, A.UWY_NF,0,'R',A.SGMT_NF, A.SGTLVL_NT, @sgttyp_nt, 
						ISNULL(A.SEGCTRTYP_CT,''), @sgtver_nt, @sgt_nt ,S.SGMT_LS,S.SGMT_LL , B.GRPINISTS_CT ,B.PARINISTS_CT , B.LOCINISTS_CT
				FROM " + @sgtrestabnme_ll + " A, BREF..TBATCHSSD E, BRET..TRETCTR C ,  BRET..TRETIFRS B, BRET..TRETSEC G,best..TSEGMT S
					WHERE ISNULL(SEGCTRTYP_CT,'') NOT IN ('1','2') AND A.SSD_CF = E.SSD_CF AND E.BATCHUSER_CF like @p_user -- suser_name()
					AND  C.RETCTR_NF = A.CTR_NF AND C.RTY_NF = A.UWY_NF 
					AND  C.RETCTR_NF  = B.RETCTR_NF AND C.RTY_NF = B.RTY_NF AND G.RETCTR_NF = A.CTR_NF AND G.RTY_NF = A.UWY_NF 
					AND  G.RETCTR_NF  = B.RETCTR_NF AND G.RTY_NF = B.RTY_NF AND G.RETSEC_NF = A.SEC_NF 
					AND  C.RETCTRSTS_CT  IN (3, 19)  AND S.SGMT_NF = A.SGMT_NF AND S.SGT_NT = " +  convert(char(10),@sgt_nt)+ " 
					AND S.SGTVER_NT = " + convert(char(10),@sgtver_nt ) 
					
				execute(@query)		

			END 
			
		--select @datacount = @datacount + 1
		Fetch cur_seg Into @sgtscope_ct, @sgtrun_nt, @sgtrestabnme_ll,@sgttyp_nt, @sgtver_nt, @sgt_nt
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

if object_id('dbo.PsILLBucketExtract') is not null
  print '<<< CREATED PROC dbo.PsILLBucketExtract >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsILLBucketExtract >>>'
go
grant execute on dbo.PsILLBucketExtract TO GOMEGA
go
grant execute on dbo.PsILLBucketExtract TO GDBBATCH
go




-- TESTING 
-- declare @p_error	varchar(64)
-- execute BSEG..PsILLBucketExtract 
-- select 'p_error=' + @p_error


