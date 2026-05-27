use BEST
go

if object_id('PiFhwLKIRatio_01') is not null
begin
  drop procedure PiFhwLKIRatio_01
   if object_id('PiFhwLKIRatio_01') is not null
      print '<<< FAILED DROPPING procedure PiFhwLKIRatio_01 >>>'
    else
      print '<<< DROPPED procedure PiFhwLKIRatio_01 >>>'
end
go


create procedure PiFhwLKIRatio_01
  (
  @p_ssd_cf USSD_CF,
  @p_closingd datetime,
  @p_per_cf CHAR(4),
  @p_usr_cf UUSR_CF,
  @p_erreur varchar(64)=null output
  )
with execute as caller as 
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME34 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    Select data from BEST..TPATTERNSII based on SSD_CF, ESB_CF
	Check existence of data in BTRAV..ESID0901_TFHWRATIO based on condition SSD_CF , PATCAT_CT , PATTYP_CT, CUR_CF
	-  If row found then update the new ratio in table.
	-  If no row found then insert into BTRAV..ESID0901_TFHWRATIO table
Parametres:

 	@p_ssd_cf	 SSD_CF         : Filiale
    @p_esb_cf	 ESB_CF			: 
    @p_closingd	 CLOSINGD		: closing date
	@p_per_cf  CLOSINGP		: closing period
    @p_erreur       varchar(64)=null output
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
MOD01 KBAGWE	Spira 89097,89102
MOD02 CSOCIE	SPIRA 97223 remove link to TLOBSII table
MOD03 BhimasenK Spira#108975 Discount FWD - same pattern id for different curves (ssd/esb/rate index)
MOD04 BhimasenK Spira#107581 Q2 FWD/FHNI curves disappeared in patterns table (OMEGA EST)
MOD05 DaD Spira#110598 LKI I17L/P curves - same pattern id on different ssd esb
*****************************************************/
 
 create table #tempdata
(
ID numeric(12,0) identity,
SSD_CF	   USSD_CF	 null  ,
ESB_CF     UESB_CF     null,
CUR_CF     UCUR_CF     null, 
RATEINDEX_CT  varchar(32) NULL
)

create table #btrav(
  ID numeric(12,0) identity
 ,LINE_NF    INT         not null
 ,USR_CF     UUSR_CF     not null 
 ,SSD_CF     USSD_CF     null
 ,ESB_CF     UESB_CF     null	--MOD01
 ,SEG_NF     USEG_NF     null
 ,LOB_CF     varchar(32)     null
 ,CUR_CF     UCUR_CF     not null 
 ,NORME_CF   char(5)     null
 ,PATTYP_CT  char(5)     not null 
 ,AN1        decimal(11,8) NULL
 ,AN2        decimal(11,8) NULL
 ,AN3        decimal(11,8) NULL
 ,AN4        decimal(11,8) NULL
 ,AN5        decimal(11,8) NULL
 ,AN6        decimal(11,8) NULL
 ,AN7        decimal(11,8) NULL
 ,AN8        decimal(11,8) NULL
 ,AN9        decimal(11,8) NULL
 ,AN10       decimal(11,8) NULL
 ,AN11       decimal(11,8) NULL
 ,AN12       decimal(11,8) NULL
 ,AN13       decimal(11,8) NULL
 ,AN14       decimal(11,8) NULL
 ,AN15       decimal(11,8) NULL
 ,AN16       decimal(11,8) NULL
 ,AN17       decimal(11,8) NULL
 ,AN18       decimal(11,8) NULL
 ,AN19       decimal(11,8) NULL
 ,AN20       decimal(11,8) NULL
 ,AN21       decimal(11,8) NULL
 ,AN22       decimal(11,8) NULL
 ,AN23       decimal(11,8) NULL
 ,AN24       decimal(11,8) NULL
 ,AN25       decimal(11,8) NULL
 ,AN26       decimal(11,8) NULL
 ,AN27       decimal(11,8) NULL
 ,AN28       decimal(11,8) NULL
 ,AN29       decimal(11,8) NULL
 ,AN30       decimal(11,8) NULL
 ,AN31       decimal(11,8) NULL
 ,AN32       decimal(11,8) NULL
 ,AN33       decimal(11,8) NULL
 ,AN34       decimal(11,8) NULL
 ,AN35       decimal(11,8) NULL
 ,AN36       decimal(11,8) NULL
 ,AN37       decimal(11,8) NULL
 ,AN38       decimal(11,8) NULL
 ,AN39       decimal(11,8) NULL
 ,AN40       decimal(11,8) NULL
 ,AN41       decimal(11,8) NULL
 ,AN42       decimal(11,8) NULL
 ,AN43       decimal(11,8) NULL
 ,AN44       decimal(11,8) NULL
 ,AN45       decimal(11,8) NULL
 ,AN46       decimal(11,8) NULL
 ,AN47       decimal(11,8) NULL
 ,AN48       decimal(11,8) NULL
 ,AN49       decimal(11,8) NULL
 ,AN50       decimal(11,8) NULL
 ,AN51       decimal(11,8) NULL
 ,AN52       decimal(11,8) NULL
 ,AN53       decimal(11,8) NULL
 ,AN54       decimal(11,8) NULL
 ,AN55       decimal(11,8) NULL
 ,AN56       decimal(11,8) NULL
 ,AN57       decimal(11,8) NULL
 ,AN58       decimal(11,8) NULL
 ,AN59       decimal(11,8) NULL
 ,AN60       decimal(11,8) NULL
 ,AN61       decimal(11,8) NULL
 ,AN62       decimal(11,8) NULL
 ,AN63       decimal(11,8) NULL
 ,AN64       decimal(11,8) NULL
 ,AN65       decimal(11,8) NULL
 ,COEF       USHORAT_R NULL
 ,RATEINDEX_CT varchar(32) NULL
 ,NEWPATTERN_ID    varchar(21)  NULL
)



declare @erreur int,
        @tran_imbr	bit,
		@lob_cf ULOB_CF,
		@ssdcf USSD_CF,
		@esbcf UESB_CF,
		@cur_cf UCUR_CF,
		@datacount int,
		@patternid varchar(21),
		@rateindexCt varchar(32)
		
select @erreur = 0
select @tran_imbr = 1
select @datacount = 1


/* -------------------------------------------------------------------
		create temporary table to handle multi lob in TLOBSII MOD 2
---------------------------------------------------------------------*/

/*select LOB_CF,SEGNAT_CT,NORME_CF,COEF_R,CLOSING_D
into #TLOBSII
 from BEST..TLOBSII
  where CLOSING_D >= @p_closingd
group by LOB_CF,SEGNAT_CT,NORME_CF
order by LOB_CF,SEGNAT_CT,NORME_CF

insert into #TLOBSII
select LOB_CF,SEGNAT_CT,NORME_CF,COEF_R,CLOSING_D
 from BEST..TLOBSII a
  where a.CLOSING_D is null 
   and not exists(select 1 from #TLOBSII b where b.LOB_CF=a.LOB_CF)
order by LOB_CF,SEGNAT_CT,NORME_CF

insert into #TLOBSII
select LOB_CF,SEGNAT_CT,NORME_CF,COEF_R,CLOSING_D
 from BEST..TLOBSII a
  where a.CLOSING_D = (select max(CLOSING_D) from BEST..TLOBSII c where c.LOB_CF=a.LOB_CF)
   and not exists(select 1 from #TLOBSII b where b.LOB_CF=a.LOB_CF)
order by LOB_CF,SEGNAT_CT,NORME_CF*/

/* -------------------------------------------------------------------
		Apply new formula on btrav table ESID0901_TFHWRATIO
---------------------------------------------------------------------*/

		 		
--MOD01
insert into #BTRAV
(LINE_NF ,USR_CF ,SSD_CF,ESB_CF ,SEG_NF ,LOB_CF ,CUR_CF ,NORME_CF ,PATTYP_CT 
,AN1 ,AN2 ,AN3 ,AN4 ,AN5 ,AN6 ,AN7 ,AN8 ,AN9 ,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20,
AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39,AN40,
AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58,AN59,AN60,AN61,
AN62,AN63,AN64,AN65,COEF,RATEINDEX_CT)
SELECT a.LINE_NF, a.USR_CF, a.SSD_CF,a.ESB_CF, a.SEG_NF, NULL, a.CUR_CF, a.NORME_CF, "LKI",
a.AN1, a.AN2, a.AN3, a.AN4, a.AN5, a.AN6, a.AN7, a.AN8, a.AN9, a.AN10, a.AN11, a.AN12, a.AN13, a.AN14, a.AN15,
a.AN16, a.AN17, a.AN18, a.AN19, a.AN20, a.AN21, a.AN22, a.AN23, a.AN24, a.AN25, a.AN26, a.AN27, a.AN28, a.AN29, a.AN30,
a.AN31, a.AN32, a.AN33, a.AN34, a.AN35, a.AN36, a.AN37, a.AN38, a.AN39, a.AN40, a.AN41, a.AN42, a.AN43, a.AN44, a.AN45,
a.AN46, a.AN47, a.AN48, a.AN49, a.AN50, a.AN51, a.AN52, a.AN53, a.AN54, a.AN55, a.AN56, a.AN57, a.AN58, a.AN59, a.AN60,
a.AN61, a.AN62, a.AN63, a.AN64, a.AN65, NULL, a.LOB_CF
from BTRAV..ESID0901_TFHWRATIO a where USR_CF = @p_usr_cf

		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + " INSERT #BTRAV =1;"
			   goto fin
		end		
--MOD01
insert into #BTRAV
(LINE_NF ,USR_CF ,SSD_CF ,ESB_CF,SEG_NF ,LOB_CF ,CUR_CF ,NORME_CF ,PATTYP_CT 
,AN1 ,AN2 ,AN3 ,AN4 ,AN5 ,AN6 ,AN7 ,AN8 ,AN9 ,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20,
AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39,AN40,
AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58,AN59,AN60,AN61,
AN62,AN63,AN64,AN65,COEF,RATEINDEX_CT)
SELECT distinct a.LINE_NF, a.USR_CF, a.SSD_CF ,a.ESB_CF, a.SEG_NF, NULL, a.CUR_CF, a.NORME_CF, "LKR",
a.AN1, a.AN2, a.AN3, a.AN4, a.AN5, a.AN6, a.AN7, a.AN8, a.AN9, a.AN10, a.AN11, a.AN12, a.AN13, a.AN14, a.AN15,
a.AN16, a.AN17, a.AN18, a.AN19, a.AN20, a.AN21, a.AN22, a.AN23, a.AN24, a.AN25, a.AN26, a.AN27, a.AN28, a.AN29, a.AN30,
a.AN31, a.AN32, a.AN33, a.AN34, a.AN35, a.AN36, a.AN37, a.AN38, a.AN39, a.AN40, a.AN41, a.AN42, a.AN43, a.AN44, a.AN45,
a.AN46, a.AN47, a.AN48, a.AN49, a.AN50, a.AN51, a.AN52, a.AN53, a.AN54, a.AN55, a.AN56, a.AN57, a.AN58, a.AN59, a.AN60,
a.AN61, a.AN62, a.AN63, a.AN64, a.AN65, NULL, a.LOB_CF
from BTRAV..ESID0901_TFHWRATIO a where USR_CF = @p_usr_cf

		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + " INSERT #BTRAV =2;"
			   goto fin
		end		


CREATE  CLUSTERED INDEX AK_BTRAV ON #BTRAV(SSD_CF , LOB_CF, CUR_CF, RATEINDEX_CT)

declare @bufSSD USSD_CF
declare @bufCUR UCUR_CF
declare @bufRAT varchar(32)
declare @bufESB UESB_CF

select @bufSSD = NULL
select @bufCUR = NULL
select @bufRAT = NULL
select @bufESB = NULL


declare @yearscount int
declare @rowscount int
declare @countingrow int
declare @calc float
declare @varcharcal varchar
declare @calcule varchar(11)
declare @query char(200)
declare @col char(4)
select @yearscount = 1
select @rowscount = (select count(*) from #BTRAV)
select @countingrow = 1

select distinct ID 
into #IDDATA from #BTRAV where PATTYP_CT = "LKI"

 
update #BTRAV set AN1  = convert(decimal(11,8),(1 / POWER( 1+AN1 , 1	- 0.5))),
				  AN2  = convert(decimal(11,8),(1 / POWER( 1+AN2 ,	2	- 0.5))),
				  AN3  = convert(decimal(11,8),(1 / POWER( 1+AN3 ,	3	- 0.5))),
				  AN4  = convert(decimal(11,8),(1 / POWER( 1+AN4 ,	4	- 0.5))),
				  AN5  = convert(decimal(11,8),(1 / POWER( 1+AN5 ,	5	- 0.5))),
				  AN6  = convert(decimal(11,8),(1 / POWER( 1+AN6 ,	6	- 0.5))),
				  AN7  = convert(decimal(11,8),(1 / POWER( 1+AN7 ,	7	- 0.5))),
				  AN8  = convert(decimal(11,8),(1 / POWER( 1+AN8 ,	8	- 0.5))),
				  AN9  = convert(decimal(11,8),(1 / POWER( 1+AN9 ,	9	- 0.5))),
				  AN10 = convert(decimal(11,8),(1 / POWER( 1+AN10,	10	- 0.5))),
				  AN11 = convert(decimal(11,8),(1 / POWER( 1+AN11,	11	- 0.5))),
				  AN12 = convert(decimal(11,8),(1 / POWER( 1+AN12,	12	- 0.5))),
				  AN13 = convert(decimal(11,8),(1 / POWER( 1+AN13,	13	- 0.5))),
				  AN14 = convert(decimal(11,8),(1 / POWER( 1+AN14,	14	- 0.5))),
				  AN15 = convert(decimal(11,8),(1 / POWER( 1+AN15,	15	- 0.5))),
				  AN16 = convert(decimal(11,8),(1 / POWER( 1+AN16,	16	- 0.5))),
				  AN17 = convert(decimal(11,8),(1 / POWER( 1+AN17,	17	- 0.5))),
				  AN18 = convert(decimal(11,8),(1 / POWER( 1+AN18,	18	- 0.5))),
				  AN19 = convert(decimal(11,8),(1 / POWER( 1+AN19,	19	- 0.5))),
				  AN20 = convert(decimal(11,8),(1 / POWER( 1+AN20,	20	- 0.5))),
				  AN21 = convert(decimal(11,8),(1 / POWER( 1+AN21,	21	- 0.5))),
				  AN22 = convert(decimal(11,8),(1 / POWER( 1+AN22,	22	- 0.5))),
				  AN23 = convert(decimal(11,8),(1 / POWER( 1+AN23,	23	- 0.5))),
				  AN24 = convert(decimal(11,8),(1 / POWER( 1+AN24,	24	- 0.5))),
				  AN25 = convert(decimal(11,8),(1 / POWER( 1+AN25,	25	- 0.5))),
				  AN26 = convert(decimal(11,8),(1 / POWER( 1+AN26,	26	- 0.5))),
				  AN27 = convert(decimal(11,8),(1 / POWER( 1+AN27,	27	- 0.5))),
				  AN28 = convert(decimal(11,8),(1 / POWER( 1+AN28,	28	- 0.5))),
				  AN29 = convert(decimal(11,8),(1 / POWER( 1+AN29,	29	- 0.5))),
				  AN30 = convert(decimal(11,8),(1 / POWER( 1+AN30,	30	- 0.5))),
				  AN31 = convert(decimal(11,8),(1 / POWER( 1+AN31,	31	- 0.5))),
				  AN32 = convert(decimal(11,8),(1 / POWER( 1+AN32,	32	- 0.5))),
				  AN33 = convert(decimal(11,8),(1 / POWER( 1+AN33,	33	- 0.5))),
				  AN34 = convert(decimal(11,8),(1 / POWER( 1+AN34,	34	- 0.5))),
				  AN35 = convert(decimal(11,8),(1 / POWER( 1+AN35,	35	- 0.5))),
				  AN36 = convert(decimal(11,8),(1 / POWER( 1+AN36,	36	- 0.5))),
				  AN37 = convert(decimal(11,8),(1 / POWER( 1+AN37,	37	- 0.5))),
				  AN38 = convert(decimal(11,8),(1 / POWER( 1+AN38,	38	- 0.5))),
				  AN39 = convert(decimal(11,8),(1 / POWER( 1+AN39,	39	- 0.5))),
				  AN40 = convert(decimal(11,8),(1 / POWER( 1+AN40,	40	- 0.5))),
				  AN41 = convert(decimal(11,8),(1 / POWER( 1+AN41,	41	- 0.5))),
				  AN42 = convert(decimal(11,8),(1 / POWER( 1+AN42,	42	- 0.5))),
				  AN43 = convert(decimal(11,8),(1 / POWER( 1+AN43,	43	- 0.5))),
				  AN44 = convert(decimal(11,8),(1 / POWER( 1+AN44,	44	- 0.5))),
				  AN45 = convert(decimal(11,8),(1 / POWER( 1+AN45,	45	- 0.5))),
				  AN46 = convert(decimal(11,8),(1 / POWER( 1+AN46,	46	- 0.5))),
				  AN47 = convert(decimal(11,8),(1 / POWER( 1+AN47,	47	- 0.5))),
				  AN48 = convert(decimal(11,8),(1 / POWER( 1+AN48,	48	- 0.5))),
				  AN49 = convert(decimal(11,8),(1 / POWER( 1+AN49,	49	- 0.5))),
				  AN50 = convert(decimal(11,8),(1 / POWER( 1+AN50,	50	- 0.5))),
				  AN51 = convert(decimal(11,8),(1 / POWER( 1+AN51,	51	- 0.5))),
				  AN52 = convert(decimal(11,8),(1 / POWER( 1+AN52,	52	- 0.5))),
				  AN53 = convert(decimal(11,8),(1 / POWER( 1+AN53,	53	- 0.5))),
				  AN54 = convert(decimal(11,8),(1 / POWER( 1+AN54,	54	- 0.5))),
				  AN55 = convert(decimal(11,8),(1 / POWER( 1+AN55,	55	- 0.5))),
				  AN56 = convert(decimal(11,8),(1 / POWER( 1+AN56,	56	- 0.5))),
				  AN57 = convert(decimal(11,8),(1 / POWER( 1+AN57,	57	- 0.5))),
				  AN58 = convert(decimal(11,8),(1 / POWER( 1+AN58,	58	- 0.5))),
				  AN59 = convert(decimal(11,8),(1 / POWER( 1+AN59,	59	- 0.5))),
				  AN60 = convert(decimal(11,8),(1 / POWER( 1+AN60,	60	- 0.5))),
				  AN61 = convert(decimal(11,8),(1 / POWER( 1+AN61,	61	- 0.5))),
				  AN62 = convert(decimal(11,8),(1 / POWER( 1+AN62,	62	- 0.5))),
				  AN63 = convert(decimal(11,8),(1 / POWER( 1+AN63,	63	- 0.5))),
				  AN64 = convert(decimal(11,8),(1 / POWER( 1+AN64,	64	- 0.5))),
				  AN65 = convert(decimal(11,8),(1 / POWER( 1+AN65,	65	- 0.5)))
from #BTRAV  A, #IDDATA B 
where  A.ID = B.ID	AND A.PATTYP_CT != "LKR"																	


insert into #tempdata select SSD_CF, ESB_CF, CUR_CF, RATEINDEX_CT
		   	FROM #BTRAV A 

select @countingrow = 1

 
While (@countingrow  <= @rowscount)
		Begin

		SELECT @ssdcf = ssd_cf, @esbcf = esb_cf, @cur_cf=cur_cf, @rateindexCt=rateindex_Ct from #tempdata where id = @countingrow
		if (@bufSSD = NULL and @bufCUR = NULL and @bufRAT = NULL and @bufESB = NULL) OR (@bufSSD != @ssdcf or @bufCUR != @cur_cf or @bufRAT != @rateindexCt or @bufESB != @esbcf)	
		begin
			select @patternid = convert(char(8),getdate(),112) + substring(convert(varchar,getdate(),108),1,2) + substring(convert(varchar,getdate(),108),4,2) + substring(convert(varchar,getdate(),108),7,2)  + case when @datacount between 1 and 9 then '0' + convert(char(1),@datacount) else convert(char(10),@datacount) end + +'W'			--MOD03	
			select @bufSSD = @ssdcf
			select @bufCUR = @cur_cf
			select @bufRAT = @rateindexCt
			select @bufESB = @esbcf
			select @datacount = @datacount + 1
		end
		
		update #BTRAV
		SET NEWPATTERN_ID = @patternid
		FROM #BTRAV 
		WHERE @ssdcf = ssd_cf AND @cur_cf=cur_cf AND @rateindexCt=rateindex_Ct AND @esbcf = esb_cf
		
		--SELECT @ssdcf, @lob_cf, @cur_cf, @rateindexCt, @patternid, @bufSSD,@bufCUR, @bufRAT


		select @countingrow = @countingrow+1
End
	 
 
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 
  
  
DELETE FROM BEST..TPATTERNSII from BEST..TPATTERNSII A, #btrav B
	WHERE 	A.PATTYP_CT = B.PATTYP_CT AND B.PATTYP_CT = "LKR" AND isnull(A.SSD_CF, 0 ) = isnull(B.SSD_CF, 0 ) 
			AND isnull(A.ESB_CF, 0 ) = isnull(B.ESB_CF, 0 )  AND A.RATEINDEX_CT = B.RATEINDEX_CT						--MOD04
			AND B.USR_CF = @p_usr_cf  AND A.CUR_CF = B.CUR_CF AND isnull(A.SEG_NF, '0' ) = isnull(B.SEG_NF, '0' )  
            AND  isnull(A.LOB_CF, '0' ) = isnull(B.LOB_CF, '0' ) AND A.NORME_CF = B.NORME_CF AND A.PATCAT_CT = 'DSC'
			AND NOT EXISTS (SELECT 1 FROM BEST..TPATSEGSII C 															--MOD04
            WHERE A.PATTERN_ID = C.PATTERN_ID AND A.PATCAT_CT = C.PATCAT_CT 
			    AND isnull(A.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 ) 
			    AND isnull(A.ESB_CF, 0 ) = isnull(C.ESB_CF, 0 )  
                AND A.CUR_CF = C.CUR_CF AND A.CUR_CF = B.CUR_CF AND C.NORME_CF = A.NORME_CF 
                AND B.RATEINDEX_CT = C.RATEINDEX_CT AND (CLODAT_D != @p_closingd OR PER_CF != @p_per_cf))				--MOD04


		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + " DELETE TPATTERNSII;"
			   goto fin
		end		
--MOD01
DELETE FROM BEST..TPATTERNSII from BEST..TPATTERNSII A, #btrav B
	WHERE 	A.PATTYP_CT = B.PATTYP_CT AND isnull(A.SSD_CF, 0 ) = isnull(B.SSD_CF, 0 )
			AND isnull(A.ESB_CF, 0 ) = isnull(B.ESB_CF, 0 ) AND A.RATEINDEX_CT = B.RATEINDEX_CT						--MOD04
			AND B.USR_CF = @p_usr_cf  AND A.CUR_CF = B.CUR_CF AND isnull(A.SEG_NF, '0' ) = isnull(B.SEG_NF, '0' )  
            AND  isnull(A.LOB_CF, '0' ) = isnull(B.LOB_CF, '0' ) AND A.NORME_CF = B.NORME_CF AND A.PATCAT_CT = 'DSC' 
			AND NOT EXISTS (SELECT 1 FROM BEST..TPATSEGSII C 														--MOD04
            WHERE ISNULL(B.LOB_CF, '0') = ISNULL(C.LOB_CF,'0') AND A.PATTERN_ID = C.PATTERN_ID AND A.PATCAT_CT = C.PATCAT_CT 	--MOD04
				AND A.PATTYP_CT =B.PATTYP_CT AND isnull(A.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 )  AND isnull(A.ESB_CF, 0 ) = isnull(C.ESB_CF, 0 ) 
                AND A.CUR_CF = C.CUR_CF AND A.CUR_CF = B.CUR_CF AND C.NORME_CF = A.NORME_CF AND B.RATEINDEX_CT = C.RATEINDEX_CT
                AND (CLODAT_D != @p_closingd OR PER_CF != @p_per_cf))														--MOD04


		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + " DELETE TPATTERNSII;"
			   goto fin
		end		

DELETE FROM BEST..TPATSEGSII from BEST..TPATSEGSII C, #btrav A 
								WHERE C.PATCAT_CT = 'DSC' AND A.USR_CF= @p_usr_cf
										AND isnull(C.SSD_CF, 0 ) = isnull(A.SSD_CF, 0 ) AND isnull(C.ESB_CF, 0 ) = isnull(A.ESB_CF, 0 )		--MOD01
										AND	C.CLODAT_D =  @p_closingd AND C.PER_CF = @p_per_cf AND C.CUR_CF = A.CUR_CF 
										AND C.PATTYP_CT = A.PATTYP_CT AND C.NORME_CF = A.NORME_CF AND A.RATEINDEX_CT = C.RATEINDEX_CT 
	
		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + " DELETE TPATSEGSII;"
			   goto fin
		end		

--MOD01
		INSERT INTO BEST..TPATTERNSII
			(SSD_CF,PATCAT_CT,PATTYP_CT,CUR_CF,PATTERN_ID, CREUSR_CF ,CRE_D,LOB_CF, NORME_CF,TOTAUX
			,AN1,AN2,AN3,AN4,AN5,AN6,AN7,AN8,AN9,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20
			,AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39
			,AN40,AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58
			,AN59,AN60,AN61,AN62,AN63,AN64,AN65, RATEINDEX_CT,ESB_CF)
		SELECT A.SSD_CF,"DSC", A.PATTYP_CT, A.CUR_CF, NEWPATTERN_ID ,@p_usr_cf, getdate () ,A.LOB_CF , A.NORME_CF,
		(A.AN1  + A.AN2  + A.AN3  + A.AN4  + A.AN5  + A.AN6  + A.AN7  + A.AN8  + A.AN9  + A.AN10 + A.AN11 + A.AN12 + A.AN13 + A.AN14 + A.AN15 + A.AN16 + A.AN17 + A.AN18 + A.AN19 + A.AN20
		              + A.AN21 + A.AN22 + A.AN23 + A.AN24 + A.AN25 + A.AN26 + A.AN27 + A.AN28 + A.AN29 + A.AN30 + A.AN31 + A.AN32 + A.AN33 + A.AN34 + A.AN35 + A.AN36 + A.AN37 + A.AN38 + A.AN39 + A.AN40
		              + A.AN41 + A.AN42 + A.AN43 + A.AN44 + A.AN45 + A.AN46 + A.AN47 + A.AN48 + A.AN49 + A.AN50 + A.AN51 + A.AN52 + A.AN53 + A.AN54 + A.AN55 + A.AN56 + A.AN57 + A.AN58 + A.AN59 + A.AN60
		              + A.AN61 + A.AN62 + A.AN63 + A.AN64 + A.AN65)
			,A.AN1,A.AN2,A.AN3,A.AN4,A.AN5,A.AN6,A.AN7,A.AN8,A.AN9,A.AN10,A.AN11,A.AN12,A.AN13,A.AN14,A.AN15,A.AN16,A.AN17,A.AN18,A.AN19,A.AN20
			,A.AN21,A.AN22,A.AN23,A.AN24,A.AN25,A.AN26,A.AN27,A.AN28,A.AN29,A.AN30,A.AN31,A.AN32,A.AN33,A.AN34,A.AN35,A.AN36,A.AN37,A.AN38,A.AN39
			,A.AN40,A.AN41,A.AN42,A.AN43,A.AN44,A.AN45,A.AN46,A.AN47,A.AN48,A.AN49,A.AN50,A.AN51,A.AN52,A.AN53,A.AN54,A.AN55,A.AN56,A.AN57,A.AN58
			,A.AN59,A.AN60,A.AN61,A.AN62,A.AN63,A.AN64,A.AN65, RATEINDEX_CT,ESB_CF
			FROM #BTRAV A WHERE   A.USR_CF = @p_usr_cf  


		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + " INSERT TPATTERNSII;"
			   goto fin
		end				

		INSERT INTO BEST..TPATSEGSII ( CLODAT_D, PER_CF, SSD_CF, LOB_CF, CUR_CF, PATCAT_CT, PATTYP_CT, NORME_CF, 
									PATTERN_ID, ORIPATCAT_CT, ORIPATTYP_CT, ORIPATTERN_ID, CREUSR_CF, CRE_D, RATEINDEX_CT,ESB_CF ) 	--MOD01
		SELECT @p_closingd, @p_per_cf,  A.SSD_CF, A.LOB_CF, A.CUR_CF, "DSC", A.PATTYP_CT, A.NORME_CF, NEWPATTERN_ID , "DSC", "LKR", NEWPATTERN_ID,
		 @p_usr_cf, getdate (),  A.RATEINDEX_CT,ESB_CF
		FROM #BTRAV A WHERE  A.USR_CF = @p_usr_cf AND A.PATTYP_CT != 'LKR'
		
		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + " INSERT TPATSEGSII;"
			   goto fin
		end		

 

COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
   select @p_erreur	
   ROLLBACK TRAN

return @erreur 

go

if object_id('PiFhwLKIRatio_01') is not null
  print '<<< CREATED PROC PiFhwLKIRatio_01 >>>'
else
  print '<<< FAILED CREATING PROC PiFhwLKIRatio_01 >>>'
go
grant execute on PiFhwLKIRatio_01 TO GOMEGA
go
grant execute on PiFhwLKIRatio_01 TO GDBBATCH
go
