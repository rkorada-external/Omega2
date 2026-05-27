use BEST
go
if object_id('dbo.PsFetchCTRRatIndIni') is not null
begin
  drop PROC dbo.PsFetchCTRRatIndIni
  print '<<< DROPPED PROC dbo.PsFetchCTRRatIndIni >>>'
end
go

create procedure dbo.PsFetchCTRRatIndIni
(
   @p_norm_cf	 varchar(5),
   @p_CRE_D      datetime,
   @p_PATCAT_CT  varchar(5),   -- DSC 
   @p_PATTYP_CT  varchar(5),   -- LKI 
   @p_BALSHEY_NF smallInt,
   @p_per_cf     varchar(3),
   @p_iclodat_d  datetime
)
with execute as caller as 


/**************************************************************************************************
Programme                : PsFetchCTRRatIndIni
Fichier script associé   : BEST_PsFetchCTRRatIndIni.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : JYP - PERSEE 
Date de creation         : 26/09/2019
Description du programme : Extraction des paramètres RateIndex pour le closing at Inception
                      
_____________________________________________________
[001] 26/09/2019 JYP  :SPIRA 70537 : création
[002] 26/09/2019 JYP  :SPIRA 70537 : version without checking status of contract
[003] 30/10/2019 JYP  :SPIRA 81565 : new rule "closing_date - 3 months"
[004] 29/01/2020 JYP  :SPIRA 79070 : extract rate index for retro contracts
[005] 13/11/2020 JYP  :SPIRA 90059 : multiyear , 6 new fields
[006] 11/01/2020 JYP/Sylvie  :SPIRA 90059 : change status filter for FAC
[007] 12/01/2020 JYP/Sylvie/TD :SPIRA 90059 : extract retro status 0
[008] 01/09/2020 JYP  :SPIRA 97283 : illiquidity segment
[009] 18/02/2022 JYP  :SPIRA 102167 : rule on fac status
[010] 29/12/2022 MZM  :SPIRA 102482 : Onerous
[011] 11/07/2023 DAD  :SPIRA 110126 : Extend scope to CSUOE moving from valid status to invalid status
[012] 26/09/2023 DAD  :SPIRA 109347 : EBS/I17 - Fac status Accepted only POS
************************************************************************************************/


---
--- declaration part
---
declare @iclodat_prevquater varchar(15), @iclodat_year varchar(4) , @iclodat_month varchar(2)

-- [012]
declare @sts_list table (Id TINYINT)
insert into @sts_list values (16)
insert into @sts_list values (18)
insert into @sts_list values (19)
insert into @sts_list values (21)
insert into @sts_list values (22)
insert into @sts_list values (23)
insert into @sts_list values (24)

IF(@p_per_cf = 'POS')
BEGIN
  insert into @sts_list values (14)
END

CREATE TABLE #DATA_RATEINDEX_TMP(
    CTR_NF           UCTR_NF    NOT NULL,
    END_NT           UEND_NT    NULL,
    SEC_NF           USEC_NF    NULL,
    UWY_NF           UUWY_NF    NULL,
    UW_NT            UUW_NT     NULL,
    GRPRATEINDEX_CT  char(32)   NULL,
	PARRATEINDEX_CT  char(32)   NULL,
	LOCRATEINDEX_CT  char(32)   NULL,
	TYPE 			 char(1)   NULL,
	SSD_CF			 USSD_CF   NOT NULL,
	ESB_CF			 UESB_CF   NOT NULL,
	PREFIX_INDEX     varchar(6) NULL,
	GRPINISTS_CT     tinyint    NULL, 
	PARINISTS_CT     tinyint    NULL, 
	LOCINISTS_CT     tinyint    NULL, 
	GRPFIRCLO_D      datetime   NULL,
	PARFIRCLO_D      datetime   NULL, 
	LOCFIRCLO_D      datetime   NULL,
	GRPIFRSTRA_CT    UBANVAL_CT NULL,
	PARIFRSTRA_CT    UBANVAL_CT NULL,
	LOCIFRSTRA_CT    UBANVAL_CT NULL
)
   
CREATE TABLE #DATA_RATEINDEX_TMP2(
	PREFIX_INDEX  varchar(6) NULL,
    RATEINDEX_CT  char(32)   NULL,
	NORME_CF	  varchar(5) NULL
)

---
--- calculate iclodat_dt prefix YYYYQn (n in 1 2 3 4) 
---

select @iclodat_month = substring(@p_iclodat_d,5,2)
select @iclodat_year  = substring(@p_iclodat_d,1,4)

select @iclodat_prevquater = "00"
select @iclodat_prevquater =
     case when datepart(mm,@p_iclodat_d) in (01,02,03)  then convert(char(4),datepart(yy,@p_iclodat_d) -1) + 'Q4'
          when datepart(mm,@p_iclodat_d) in (04,05,06)  then convert(char(4),datepart(yy,@p_iclodat_d)) + 'Q1'
          when datepart(mm,@p_iclodat_d) in (07,08,09)  then convert(char(4),datepart(yy,@p_iclodat_d)) + 'Q2'
          when datepart(mm,@p_iclodat_d) in (10,11,12)  then convert(char(4),datepart(yy,@p_iclodat_d)) + 'Q3'
     end

---
--- load temporary table with only prefix YYYYQn for each CSUOE
---

INSERT INTO #DATA_RATEINDEX_TMP 
(CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,PREFIX_INDEX,GRPRATEINDEX_CT,PARRATEINDEX_CT,LOCRATEINDEX_CT,TYPE,SSD_CF,ESB_CF,
 GRPINISTS_CT,PARINISTS_CT,LOCINISTS_CT,GRPFIRCLO_D,PARFIRCLO_D,LOCFIRCLO_D,GRPIFRSTRA_CT,PARIFRSTRA_CT,LOCIFRSTRA_CT)
SELECT  
		a.CTR_NF
		,a.END_NT
		,a.SEC_NF
		,a.UWY_NF
		,a.UW_NT
		, @iclodat_prevquater
		,''
		,''
		,''
		,'T'			--TREATY
		,cntr.SSD_CF
		,cntr.ACCESB_CF
		,a.GRPINISTS_CT 
		,a.PARINISTS_CT 
		,a.LOCINISTS_CT
		,a.GRPFIRCLO_D
		,a.PARFIRCLO_D 
		,a.LOCFIRCLO_D
		,a.GRPIFRSTRA_CT
		,a.PARIFRSTRA_CT
		,a.LOCIFRSTRA_CT
FROM BTRT..TSECIFRS a , BREF..TBATCHSSD b, BTRT..TSECTION c,BTRT..TCONTR cntr , BTRT..tcrcontr tc , BTRT..TCR tcr
where b.BATCHUSER_CF = suser_name()
AND b.SSD_CF = cntr.SSD_CF
AND a.CTR_NF = cntr.CTR_NF   
AND a.UWY_NF = cntr.UWY_NF   
AND a.UW_NT  = cntr.UW_NT  
AND a.END_NT = cntr.END_NT
AND ( -- inception pending status
       ( @p_norm_cf = 'I17G' and (a.GRPINISTS_CT is null or a.GRPINISTS_CT  = 1) )
    or ( @p_norm_cf = 'I17P' and (a.PARINISTS_CT is null or a.PARINISTS_CT  = 1) )
    or ( @p_norm_cf = 'I17L' and (a.LOCINISTS_CT is null or a.LOCINISTS_CT  = 1) )
	)
AND  a.CTR_NF = c.CTR_NF    AND   a.UWY_NF = c.UWY_NF   AND   a.UW_NT  = c.UW_NT    AND  a.END_NT = c.END_NT
AND  a.SEC_NF  = C.SEC_NF
AND c.LOB_CF != '30' AND c.LOB_CF != '31' 
--AND c.SECSTS_CT IN (14, 16, 17, 19) -- Finalized 	'14' - Accepted/ bound '16' - Finalized '17' - Renewed	
AND (c.SECSTS_CT IN (14, 16, 17, 19, 21, 22, 23, 24)  OR  a.FRCIFRSBTCH_NT = 1)
AND a.CTR_NF=tc.CTR_NF
AND a.END_NT=tc.END_NT
AND a.UWY_NF=tc.UWY_NF
AND a.UW_NT =tc.UW_NT
AND tc.CR_NF      = tcr.CR_NF
AND tc.CRUWY_NF   = tcr.CRUWY_NF
and tc.CRUW_NT    = tcr.CRUW_NT
and tcr.CRUWY_NF  = a.UWY_NF
UNION ALL
SELECT  
		a.CTR_NF
		,a.END_NT
		,a.SEC_NF
		,a.UWY_NF
		,a.UW_NT
		,@iclodat_prevquater
		,''
		,''
		, ''
		,'F'			--FAC
		,cntr.SSD_CF
		,cntr.ACCESB_CF
		,a.GRPINISTS_CT 
		,a.PARINISTS_CT 
		,a.LOCINISTS_CT
		,a.GRPFIRCLO_D
		,a.PARFIRCLO_D 
		,a.LOCFIRCLO_D
		,a.GRPIFRSTRA_CT
		,a.PARIFRSTRA_CT
		,a.LOCIFRSTRA_CT
FROM BFAC..TSECIFRS a , BREF..TBATCHSSD b, BFAC..TSECTION c, BFAC..TCONTR cntr ,BFAC..tcrcontr tc, BFAC..TCR tcr
where b.BATCHUSER_CF = suser_name()
AND b.SSD_CF = cntr.SSD_CF
AND a.CTR_NF = cntr.CTR_NF   
AND a.UWY_NF = cntr.UWY_NF   
AND a.UW_NT  = cntr.UW_NT  
AND a.END_NT = cntr.END_NT
AND ( -- inception pending status 
       ( @p_norm_cf = 'I17G' and (a.GRPINISTS_CT is null or a.GRPINISTS_CT  = 1) )
    or ( @p_norm_cf = 'I17P' and (a.PARINISTS_CT is null or a.PARINISTS_CT  = 1) )
    or ( @p_norm_cf = 'I17L' and (a.LOCINISTS_CT is null or a.LOCINISTS_CT  = 1) )
	)
AND  a.CTR_NF = c.CTR_NF    AND   a.UWY_NF = c.UWY_NF   AND   a.UW_NT  = c.UW_NT    AND  a.END_NT = c.END_NT
AND  a.SEC_NF  = C.SEC_NF
AND c.LOB_CF != '30' AND c.LOB_CF != '31' 
--AND c.SECSTS_CT IN (16, 18, 19) -- Finalized 	'14' - Accepted/ bound '16' - Finalized '17' - Renewed		
AND (c.SECSTS_CT IN (select Id from @sts_list) OR a.FRCIFRSBTCH_NT = 1)
AND a.CTR_NF=tc.CTR_NF
AND a.END_NT=tc.END_NT
AND a.UWY_NF=tc.UWY_NF
AND a.UW_NT =tc.UW_NT
AND tc.CR_NF     = tcr.CR_NF
AND tc.CRUWY_NF  = tcr.CRUWY_NF
AND tc.CRUW_NT   = tcr.CRUW_NT
AND tcr.CRUWY_NF = a.UWY_NF
UNION ALL
SELECT a.RETCTR_NF
	,0 AS END_NT
    ,C.RETSEC_NF
    ,a.RTY_NF
	,0 AS UW_NT
	, @iclodat_prevquater
    ,''
    ,''
    ,''
    ,'R'			--RETRO
	,d.SSD_CF
    ,d.ESB_CF
	,case when a.GRPINISTS_CT = 0 then null else a.GRPINISTS_CT end
	,case when a.PARINISTS_CT = 0 then null else a.PARINISTS_CT end
	,case when a.LOCINISTS_CT = 0 then null else a.LOCINISTS_CT end
	,a.GRPFSTCLO_D
	,a.PARFSTCLO_D 
	,a.LCLFSTCLO_D
	,a.GRPIFRSTRA_CT
	,a.PARIFRSTRA_CT
	,a.LOCIFRSTRA_CT
FROM BRET..TRETIFRS a , BREF..TBATCHSSD b ,BRET..TRETSEC C,  BRET..TRETCTR d
WHERE b.BATCHUSER_CF = suser_name() 
and b.SSD_CF =  d.SSD_CF AND a.RETCTR_NF = C.RETCTR_NF    AND   a.RTY_NF = C.RTY_NF
and a.RETCTR_NF = d.RETCTR_NF  AND   a.RTY_NF = d.RTY_NF  
and  d.RETCTRSTS_CT IN (3,19) --valide
AND ( -- inception pending status 
       ( @p_norm_cf = 'I17G' and (a.GRPINISTS_CT is null or a.GRPINISTS_CT  = 1 or a.GRPINISTS_CT  = 0) )
    or ( @p_norm_cf = 'I17P' and (a.PARINISTS_CT is null or a.PARINISTS_CT  = 1 or a.PARINISTS_CT  = 0) )
    or ( @p_norm_cf = 'I17L' and (a.LOCINISTS_CT is null or a.LOCINISTS_CT  = 1 or a.LOCINISTS_CT  = 0) )
	)
		
---
--- save distinct keys YYYYQn 
---
INSERT INTO #DATA_RATEINDEX_TMP2(PREFIX_INDEX , RATEINDEX_CT )
select distinct PREFIX_INDEX,null from #DATA_RATEINDEX_TMP

---
--- save distinct couple YYYYQn/RATEINDEX_CT for norm
---

INSERT INTO #DATA_RATEINDEX_TMP2(PREFIX_INDEX , RATEINDEX_CT, NORME_CF )
SELECT distinct
      PREFIX_INDEX,
	  t.PREFIX_INDEX + 'ILL', -- + substring(pseg.RATEINDEX_CT,10,3) ,
	  @p_norm_cf
FROM #DATA_RATEINDEX_TMP2 t, BEST..TPATTERNSII ptern, BEST..TPATSEGSII pseg, BEST..TCURSII cur
WHERE ptern.PATTERN_ID = pseg.PATTERN_ID
AND  ptern.PATCAT_CT = @p_PATCAT_CT 
AND  ptern.PATTYP_CT = @p_PATTYP_CT
AND ptern.CUR_CF = pseg.CUR_CF
--and isnull(ptern.LOB_CF,'')=isnull(pseg.LOB_CF,'')
and isnull(ptern.SEGNAT_CT,'')=isnull(pseg.SEGNAT_CT,'')
and isnull(ptern.SSD_CF,0)=isnull(pseg.SSD_CF,0)
and isnull(ptern.NORME_CF,'')=isnull(pseg.NORME_CF,'')
AND cur.GRPCUR_CF = pseg.CUR_CF
AND cur.CRE_D <=  @p_CRE_D
AND ptern.NORME_CF =  @p_norm_cf
AND pseg.PER_CF = @p_per_cf
AND pseg.RATEINDEX_CT is not null
AND substring(pseg.RATEINDEX_CT ,1,9) = t.PREFIX_INDEX + 'ILL'
--AND len(pseg.RATEINDEX_CT) = 12


---
--- extract file with all CSUOE + 3 RatesIndex
---
SELECT 
      t.CTR_NF
	  ,t.END_NT
	  ,t.SEC_NF
	  ,t.UWY_NF
	  ,t.UW_NT
	  ,case when @p_norm_cf = 'I17G' then t2.RATEINDEX_CT else null end --GRPRATEINDEX_CT
	  ,case when @p_norm_cf = 'I17P' then t2.RATEINDEX_CT else null end --PARRATEINDEX_CT
	  ,case when @p_norm_cf = 'I17L' then t2.RATEINDEX_CT else null end --LOCRATEINDEX_CT
	  ,t.TYPE
	  ,t.SSD_CF
	  ,t.ESB_CF
	  ,t.GRPINISTS_CT
	  ,t.PARINISTS_CT
	  ,t.LOCINISTS_CT
	  ,convert(char(8), t.GRPFIRCLO_D , 112)
	  ,convert(char(8), t.PARFIRCLO_D , 112)
	  ,convert(char(8), t.LOCFIRCLO_D  , 112)
	  ,t.GRPIFRSTRA_CT
	  ,t.PARIFRSTRA_CT
	  ,t.LOCIFRSTRA_CT
FROM #DATA_RATEINDEX_TMP t,#DATA_RATEINDEX_TMP2 t2
WHERE t.PREFIX_INDEX = t2.PREFIX_INDEX 
AND t2.RATEINDEX_CT is not null
AND t2.NORME_CF = @p_norm_cf
ORDER by t.TYPE, t.SSD_CF, t.ESB_CF, t.CTR_NF,  t.SEC_NF, t.UWY_NF, t.END_NT, t.UW_NT

GO

if object_id('dbo.PsFetchCTRRatIndIni') is not null
  print '<<< CREATED PROC dbo.PsFetchCTRRatIndIni >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFetchCTRRatIndIni >>>'
go
grant execute on dbo.PsFetchCTRRatIndIni TO GOMEGA
go
grant execute on dbo.PsFetchCTRRatIndIni TO GDBBATCH
go

-- TESTING examples 
-- declare @p_norm_cf	 varchar(5), @p_CRE_D datetime, @p_PATCAT_CT  varchar(5), @p_PATTYP_CT  varchar(5), @p_BALSHEY_NF smallInt,@p_per_cf varchar(3), @p_iclodat_d  datetime   
-- select @p_iclodat_d='20140930' , @p_norm_cf = 'I17G', @p_per_cf = 'POS', @p_CRE_D='20190926' ,@p_PATCAT_CT = 'DSC',@p_PATTYP_CT = 'LKI'
-- execute PsFetchCTRRatIndIni 'I17G', '20190926' , 'DSC' , 'LKI' , 2019 ,'POS', '20190930' 

   

	 