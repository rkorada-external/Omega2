use BEST
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

CREATE TABLE #DATATABLE(
	SGMT_NF USGMT_NF NOT NULL, 
	SGTLVL_NT int NOT NULL, 
	SEGCTRTYP_CT UBANVAL_CT, 
	CTR_NF UCTR_NF NOT NULL, 
	UWY_NF UUWY_NF NOT NULL,
	UW_NT UUW_NT NOT NULL,
	SEC_NF USEC_NF NOT NULL,
	RTO_NF UCLI_NF NOT NULL,
	CTRTYP_CT CHAR(1) NOT NULL,
	SSD_CF USSD_CF NOT NULL,
	ESB_CF UESB_CF NOT NULL,
	SGTTYP_NT USGTTYP_NT NOT NULL,
	CR_NF CHAR(10) NOT NULL,
	END_NT UEND_NT NOT NULL,
	DIV_NT UDIV_NT NOT NULL,
	SGTVER_NT int NOT NULL,
    SGT_NT	USGT_NT	NOT NULL
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
		@query char(2000)


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
		
		-- For Treaty
		select @query = "INSERT INTO #DATATABLE (SGMT_NF,SGTLVL_NT,SEGCTRTYP_CT,CTR_NF,UWY_NF,UW_NT,SEC_NF,RTO_NF,CTRTYP_CT,SSD_CF ,ESB_CF,SGTTYP_NT, CR_NF, B.END_NT,DIV_NT,SGTVER_NT,SGT_NT )
		SELECT A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF , 'T', B.SSD_CF,B.ACCESB_CF , @sgttyp_nt, C.CR_NF, B.END_NT, 0, @sgtver_nt, @sgt_nt 
		FROM " + @sgtrestabnme_ll + " A, BTRT..TCONTR B , BTRT..TCR C , BTRT..TSECTION D,  BREF..TBATCHSSD E, BTRT..TCRCONTR F
		WHERE E.BATCHUSER_CF = suser_name() AND E.SSD_CF =  B.SSD_CF AND A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT  
		AND A.CTR_NF = D.CTR_NF AND A.UWY_NF = D.UWY_NF AND A.UW_NT = D.UW_NT AND A.SEC_NF = D.SEC_NF AND D.END_NT = B.END_NT 
		AND F.CTR_NF = B.CTR_NF AND F.UWY_NF = B.UWY_NF AND F.UW_NT = B.UW_NT AND F.END_NT = B.END_NT 
		AND D.SECSTS_CT IN (16, 14) 
		AND C.CR_NF = F.CR_NF AND C.GRPFIRCLO_D is NULL
		ORDER BY A.SEGCTRTYP_CT ASC"
		execute(@query)
		
		select @query = ""
		-- For Facultative
		select @query = "INSERT INTO #DATATABLE (SGMT_NF,SGTLVL_NT,SEGCTRTYP_CT,CTR_NF,UWY_NF,UW_NT,SEC_NF,RTO_NF,CTRTYP_CT,SSD_CF ,ESB_CF,SGTTYP_NT, CR_NF, B.END_NT,
		DIV_NT,SGTVER_NT,SGT_NT)
		SELECT A.SGMT_NF, A.SGTLVL_NT, A.SEGCTRTYP_CT, A.CTR_NF, A.UWY_NF, A.UW_NT, A.SEC_NF, A.RTO_NF , 'F', B.SSD_CF,B.ACCESB_CF ,@sgttyp_nt, C.CR_NF, B.END_NT, 
		G.DIV_NT, @sgtver_nt, @sgt_nt 
		FROM " + @sgtrestabnme_ll + " A, BFAC..TCONTR B , BFAC..TCR C , BFAC..TSECTION D,  BREF..TBATCHSSD E, BFAC..TCRCONTR F, BFAC..TDIVISIO G 
		WHERE  E.BATCHUSER_CF = suser_name()  AND E.SSD_CF =  B.SSD_CF AND A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT 
		AND A.CTR_NF = D.CTR_NF AND A.UWY_NF = D.UWY_NF AND A.UW_NT = D.UW_NT AND A.SEC_NF = D.SEC_NF AND D.END_NT = B.END_NT 
		AND F.CTR_NF = B.CTR_NF AND F.UWY_NF = B.UWY_NF AND F.UW_NT = B.UW_NT  AND F.END_NT = B.END_NT 
		AND B.CTR_NF = G.CTR_NF AND B.UWY_NF = G.UWY_NF AND B.UW_NT = G.UW_NT AND B.END_NT = G.END_NT AND G.DIV_NT = D.DIV_NT
		AND D.SECSTS_CT IN (16, 14) 
		AND C.CR_NF = F.CR_NF AND C.GRPFIRCLO_D is NULL
		ORDER BY A.SEGCTRTYP_CT ASC"
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


SELECT * FROM #DATATABLE



return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

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
