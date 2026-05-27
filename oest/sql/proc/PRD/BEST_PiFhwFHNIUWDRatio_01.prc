use BEST
go

if object_id('PiFhwFHNIUWDRatio_01') is not null
begin
  drop procedure PiFhwFHNIUWDRatio_01
   if object_id('PiFhwFHNIUWDRatio_01') is not null
      print '<<< FAILED DROPPING procedure PiFhwFHNIUWDRatio_01 >>>'
    else
      print '<<< DROPPED procedure PiFhwFHNIUWDRatio_01 >>>'
end
go


create procedure PiFhwFHNIUWDRatio_01
  (
  @p_ssd_cf USSD_CF,
  @p_closingd datetime,
  @p_per_cf CHAR(4),
  @p_usr_cf UUSR_CF,
  @p_datatype char(4),
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
	@p_datatype  PATTYP_CT  : pattern type 
    @p_erreur       varchar(64)=null output
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
MOD01 KBagwe	89097,89102
MOD02 BhimasenK Spira#108975 Discount FWD - same pattern id for different curves (ssd/esb/rate index)
MOD03 BhimasenK Spira#107581 Q2 FWD/FHNI curves disappeared in patterns table (OMEGA EST)
MOD04 DaD Spira#110598 FWD I17L/P curves - same pattern id on different ssd esb
*****************************************************/
 create table #tempdata
(
SSD_CF	   USSD_CF	 null  ,
ESB_CF	   UESB_CF	 null,
RATEINDEX_CT     varchar(32)   null  ,
CUR_CF     UCUR_CF     null  
)
declare @erreur int,
        @tran_imbr	bit,
		@rateindex varchar(32),
		@cur_cf UCUR_CF,
		@ssdcf USSD_CF,
		@esbcf UESB_CF,
		@datacount int,
		@p_patcat char(3),
		@patternid varchar(21),
		@balshey int 

if  @p_datatype = 'FHNI'
	select @p_patcat = 'CSF'
else
	select @p_patcat = 'DSC'
	

	
select @erreur = 0
select @tran_imbr = 1
select @datacount = 1
select @balshey = datepart(YEAR,@p_closingd)

Declare cur_data Cursor For
		select distinct SSD_CF, ESB_CF, RATEINDEX_CT, CUR_CF  from #tempdata
		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 	


/* -------------------------------------------------------------------
    Select data from BTRAV..ESID0901_TFHWRATIO based on USR_CF
---------------------------------------------------------------------*/
 
	DELETE BEST..TPATTERNSII
	FROM BEST..TPATTERNSII A, BTRAV..ESID0901_TFHWRATIO B
	WHERE 	A.PATTYP_CT = B.PATTYP_CT AND isnull(A.SSD_CF, 0 ) = isnull(B.SSD_CF, 0 ) 
			AND ((@p_datatype != 'FHNI' AND isnull(A.ESB_CF, 0 ) = isnull(B.ESB_CF, 0)) OR (@p_datatype = 'FHNI'))  --MOD01
			AND B.USR_CF = @p_usr_cf  AND ISNULL(A.CUR_CF,"") = ISNULL(B.CUR_CF,"") AND ISNULL(A.NORME_CF,"") = ISNULL(b.NORME_CF,"")	
			AND A.PATCAT_CT = @p_patcat AND A.RATEINDEX_CT = B.LOB_CF							--MOD03
            AND NOT EXISTS ( SELECT 1 FROM BEST..TPATSEGSII C WHERE A.RATEINDEX_CT= C.RATEINDEX_CT AND A.PATTERN_ID = C.PATTERN_ID AND A.PATCAT_CT = C.PATCAT_CT 
			AND ISNULL(A.NORME_CF,"") = ISNULL(C.NORME_CF,"") AND isnull(A.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 ) AND isnull(A.ESB_CF, 0 ) = isnull(C.ESB_CF, 0)				--MOD03
     		AND A.PATCAT_CT = @p_patcat  AND A.PATTYP_CT =C.PATTYP_CT  AND ISNULL(A.CUR_CF,"") = ISNULL(C.CUR_CF,"") AND (CLODAT_D != @p_closingd OR PER_CF != @p_per_cf))	--MOD03
	
	select @erreur = @@error	
	if @erreur != 0 
	  begin 
		   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
		   goto fin
	end	 


	DELETE BEST..TPATSEGSII
 	FROM BTRAV..ESID0901_TFHWRATIO B , BEST..TPATSEGSII C 
	WHERE
	B.LOB_CF= C.RATEINDEX_CT  AND C.PATCAT_CT = @p_patcat 
	AND  	CLODAT_D = @p_closingd AND PER_CF = @p_per_cf AND ISNULL(B.CUR_CF,"") = ISNULL(C.CUR_CF,"")
	AND B.PATTYP_CT = C.PATTYP_CT AND ISNULL(B.NORME_CF,"") = ISNULL(C.NORME_CF,"")	AND B.USR_CF = @p_usr_cf
	AND isnull(B.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 ) --MOD01
			AND ((@p_datatype != 'FHNI' AND isnull(B.ESB_CF, 0 ) = isnull(C.ESB_CF, 0)) OR (@p_datatype = 'FHNI'))

	
	
	select @erreur = @@error	
	if @erreur != 0 
	  begin 
		   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
		   goto fin
	end	 
	
	
	
	insert into #tempdata select distinct SSD_CF, ESB_CF, LOB_CF, CUR_CF				--LOB_CF is rateindex
		   	FROM BTRAV..ESID0901_TFHWRATIO A where  A.USR_CF = @p_usr_cf


	
--MOD01	
	OPEN cur_data
	Fetch cur_data Into  @ssdcf, @esbcf, @rateindex, @cur_cf

		While (@@sqlstatus = 0)
		Begin
 		--SELECT @ssdcf, @esbcf, @rateindex, @cur_cf
		select @patternid = convert(char(8),getdate(),112) + substring(convert(varchar,getdate(),108),1,2) + substring(convert(varchar,getdate(),108),4,2) + substring(convert(varchar,getdate(),108),7,2) + case when @datacount between 1 and 9 then '0' + convert(char(1),@datacount) else convert(char(10),@datacount) end + +'W'		--MOD02		
		INSERT INTO BEST..TPATTERNSII
			(SSD_CF,PATCAT_CT,PATTYP_CT,CUR_CF,PATTERN_ID, CREUSR_CF ,CRE_D,NORME_CF,TOTAUX
			,AN1,AN2,AN3,AN4,AN5,AN6,AN7,AN8,AN9,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20
			,AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39
			,AN40,AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58
			,AN59,AN60,AN61,AN62,AN63,AN64,AN65, RATEINDEX_CT, ESB_CF)
		SELECT A.SSD_CF, @p_patcat, A.PATTYP_CT, @cur_cf, @patternid ,@p_usr_cf, getdate (), A.NORME_CF,
		(A.AN1  + A.AN2  + A.AN3  + A.AN4  + A.AN5  + A.AN6  + A.AN7  + A.AN8  + A.AN9  + A.AN10 + A.AN11 + A.AN12 + A.AN13 + A.AN14 + A.AN15 + A.AN16 + A.AN17 + A.AN18 + A.AN19 + A.AN20
		              + A.AN21 + A.AN22 + A.AN23 + A.AN24 + A.AN25 + A.AN26 + A.AN27 + A.AN28 + A.AN29 + A.AN30 + A.AN31 + A.AN32 + A.AN33 + A.AN34 + A.AN35 + A.AN36 + A.AN37 + A.AN38 + A.AN39 + A.AN40
		              + A.AN41 + A.AN42 + A.AN43 + A.AN44 + A.AN45 + A.AN46 + A.AN47 + A.AN48 + A.AN49 + A.AN50 + A.AN51 + A.AN52 + A.AN53 + A.AN54 + A.AN55 + A.AN56 + A.AN57 + A.AN58 + A.AN59 + A.AN60
		              + A.AN61 + A.AN62 + A.AN63 + A.AN64 + A.AN65)
			,A.AN1,A.AN2,A.AN3,A.AN4,A.AN5,A.AN6,A.AN7,A.AN8,A.AN9,A.AN10,A.AN11,A.AN12,A.AN13,A.AN14,A.AN15,A.AN16,A.AN17,A.AN18,A.AN19,A.AN20
			,A.AN21,A.AN22,A.AN23,A.AN24,A.AN25,A.AN26,A.AN27,A.AN28,A.AN29,A.AN30,A.AN31,A.AN32,A.AN33,A.AN34,A.AN35,A.AN36,A.AN37,A.AN38,A.AN39
			,A.AN40,A.AN41,A.AN42,A.AN43,A.AN44,A.AN45,A.AN46,A.AN47,A.AN48,A.AN49,A.AN50,A.AN51,A.AN52,A.AN53,A.AN54,A.AN55,A.AN56,A.AN57,A.AN58
			,A.AN59,A.AN60,A.AN61,A.AN62,A.AN63,A.AN64,A.AN65, @rateindex, ESB_CF
			FROM BTRAV..ESID0901_TFHWRATIO A WHERE NOT EXISTS (SELECT 1 FROM BEST..TPATTERNSII B
								WHERE  B.PATCAT_CT = @p_patcat  AND ISNULL(A.CUR_CF,"") = ISNULL(B.CUR_CF,"")  
										AND A.PATTYP_CT = B.PATTYP_CT  AND ISNULL(A.NORME_CF,"") = ISNULL(B.NORME_CF,"") AND B.PATTERN_ID = @patternid
										AND isnull(A.SSD_CF, 0 ) = isnull(B.SSD_CF, 0 ) 
			AND ((@p_datatype != 'FHNI' AND isnull(A.ESB_CF, 0 ) = isnull(B.ESB_CF, 0)) OR (@p_datatype = 'FHNI')) )
		AND A.USR_CF = @p_usr_cf and A.LOB_CF = @rateindex AND ISNULL(A.CUR_CF,"") = ISNULL(@cur_cf,"") AND isnull(A.ESB_CF, 0 ) = isnull(@esbcf, 0)
		
		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
			   goto fin
		end				


		INSERT INTO BEST..TPATSEGSII ( CLODAT_D, PER_CF, SSD_CF,  RATEINDEX_CT, CUR_CF, PATCAT_CT, PATTYP_CT, NORME_CF,
									PATTERN_ID, ORIPATCAT_CT, ORIPATTYP_CT, ORIPATTERN_ID, CREUSR_CF, CRE_D, ESB_CF ) 
		SELECT @p_closingd, @p_per_cf,  A.SSD_CF, A.LOB_CF, @cur_cf, @p_patcat, A.PATTYP_CT, A.NORME_CF, @patternid , @p_patcat, A.PATTYP_CT,
		 @patternid, @p_usr_cf, getdate (), a.ESB_CF
		FROM BTRAV..ESID0901_TFHWRATIO A WHERE NOT EXISTS (SELECT 1 FROM BEST..TPATSEGSII C 
								WHERE A.LOB_CF= C.RATEINDEX_CT AND @patternid = C.PATTERN_ID AND C.PATCAT_CT = @p_patcat  
										AND	CLODAT_D = @p_closingd AND PER_CF = @p_per_cf AND ISNULL(A.CUR_CF,"") = ISNULL(C.CUR_CF,"")
										AND A.PATTYP_CT = C.PATTYP_CT AND ISNULL(A.NORME_CF,"") = ISNULL(C.NORME_CF,"")
										AND isnull(A.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 ) 
			AND ((@p_datatype != 'FHNI' AND isnull(A.ESB_CF, 0 ) = isnull(C.ESB_CF, 0)) OR (@p_datatype = 'FHNI')))      --MOD01
										AND A.USR_CF = @p_usr_cf  AND ISNULL(A.CUR_CF,"") = ISNULL(@cur_cf,"") and A.LOB_CF = @rateindex  AND isnull(A.ESB_CF, 0 ) = isnull(@esbcf, 0)
		select @erreur = @@error	
		if @erreur != 0 
		  begin 
			   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
			   goto fin
		end		
			 
		select @datacount = @datacount + 1
		Fetch cur_data Into @ssdcf, @esbcf, @rateindex, @cur_cf
		End
	Close cur_data
	Deallocate Cursor cur_data	
 
	
	
	select @erreur = @@error	
	if @erreur != 0 
	  begin 
		   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
		   goto fin
	end	 


COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur 

go

if object_id('PiFhwFHNIUWDRatio_01') is not null
  print '<<< CREATED PROC PiFhwFHNIUWDRatio_01 >>>'
else
  print '<<< FAILED CREATING PROC PiFhwFHNIUWDRatio_01 >>>'
go
grant execute on PiFhwFHNIUWDRatio_01 TO GOMEGA
go
grant execute on PiFhwFHNIUWDRatio_01 TO GDBBATCH
go