use BEST
go
if object_id('dbo.PsFetchCTRRatInd') is not null
begin
  drop PROC dbo.PsFetchCTRRatInd
  print '<<< DROPPED PROC dbo.PsFetchCTRRatInd >>>'
end
go

create procedure dbo.PsFetchCTRRatInd
(
   @p_norm_cf	 varchar(5),
   @p_typeinv_cf 	char(4)
)
as 

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BTRT
Auteur                  : Charles SOCIE
Date de creation        : 13/03/2019
Description du programme: Extract pericase treaty, facultative and retro contract data with rate index
Conditions d'execution  : ESFD1131
Commentaires            :
_________________
MODIFICATIONS
[001] 16/11/2020 JYP  :SPIRA 90059 : multiyear , 6 new fields
[002] 17/12/2020 JYP  :SPIRA 90059 : bugfix FAC
[003] 09/02/2020 JYP  :SPIRA 90059 : add scope retro, rule on status
[004] 20/07/2021 CSE  :SPIRA 97316 : TSECIFRS- Missing transition approach data in ESF_FSECIFRS
[005] 03/09/2021 MiS  :SPIRA 98300 : Ajout gestion Statut 9
[006] 03/03/2022 JYP  :SPIRA 102189: extract RateIndex I17P
[007] 11/07/2023 DAD  :SPIRA 110126 : Extend scope to CSUOE moving from valid status to invalid status
[008] 26/09/2023 DAD  :SPIRA 109347 : EBS/I17 - Fac status Accepted only POS
*****************************************************/

-- [008]
declare @sts_list table (Id TINYINT)
insert into @sts_list values (16)
insert into @sts_list values (18)
insert into @sts_list values (19)
insert into @sts_list values (21)
insert into @sts_list values (22)
insert into @sts_list values (23)
insert into @sts_list values (24)

IF(@p_typeinv_cf = 'POS')
BEGIN
  insert into @sts_list values (14)
END


CREATE TABLE #DATA(
    CTR_NF           UCTR_NF    NOT NULL,
    END_NT           UEND_NT    NULL,
    SEC_NF           USEC_NF    NULL,
    UWY_NF           UUWY_NF    NULL,
    UW_NT            UUW_NT     NULL,
    GRPRATEINDEX_CT  char(32)   NULL,
	PARRATEINDEX_CT  char(32)   NULL,
	LOCRATEINDEX_CT  char(32)   NULL,
	TYPE 			 char(1)    NULL,
	SSD_CF			 USSD_CF    NOT NULL,
	ESB_CF			 UESB_CF    NOT NULL,
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

INSERT INTO #DATA (CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,GRPRATEINDEX_CT,PARRATEINDEX_CT,LOCRATEINDEX_CT,TYPE,SSD_CF,ESB_CF,
				GRPINISTS_CT,PARINISTS_CT,LOCINISTS_CT,GRPFIRCLO_D,PARFIRCLO_D,LOCFIRCLO_D,GRPIFRSTRA_CT,PARIFRSTRA_CT,LOCIFRSTRA_CT) 
select a.CTR_NF
		,a.END_NT
		,a.SEC_NF
		,a.UWY_NF
		,a.UW_NT
		,a.GRPRATEINDEX_CT
		,a.PARRATEINDEX_CT
		,a.LOCRATEINDEX_CT
		,'T'			--TREATY
		,d.SSD_CF
		,d.ACCESB_CF
		,a.GRPINISTS_CT
		,a.PARINISTS_CT
		,a.LOCINISTS_CT
		,a.GRPFIRCLO_D
		,a.PARFIRCLO_D
		,a.LOCFIRCLO_D
		,a.GRPIFRSTRA_CT
		,a.PARIFRSTRA_CT
		,a.LOCIFRSTRA_CT
FROM BTRT..TSECIFRS a , BREF..TBATCHSSD b, BTRT..TCONTR d , BTRT..tcrcontr tc , BTRT..TCR tcr
WHERE b.BATCHUSER_CF = suser_name() 
AND b.SSD_CF =  d.SSD_CF 
AND a.CTR_NF = d.CTR_NF    AND  a.UWY_NF = d.UWY_NF   AND   a.UW_NT  = d.UW_NT   AND   a.END_NT = d.END_NT
and exists (SELECT 1 from  BTRT..TSECTION c
			WHERE a.CTR_NF = c.CTR_NF    AND   a.UWY_NF = c.UWY_NF   AND   a.UW_NT  = c.UW_NT    AND  a.END_NT = c.END_NT	AND  a.SEC_NF  = C.SEC_NF 
			AND c.SECSTS_CT IN (14, 16, 17, 19, 21, 22, 23, 24) -- Finalized 	'14' - Accepted/ bound '16' - Finalized '17' - Renewed
			AND d.CTRSTS_CT IN (14, 16, 17, 19, 21, 22, 23, 24)
			AND c.LOB_CF != '30' AND c.LOB_CF != '31'
			)
AND a.CTR_NF=tc.CTR_NF
AND a.END_NT=tc.END_NT
AND a.UWY_NF=tc.UWY_NF
AND a.UW_NT =tc.UW_NT
AND tc.CR_NF      = tcr.CR_NF
AND tc.CRUWY_NF   = tcr.CRUWY_NF
and tc.CRUW_NT    = tcr.CRUW_NT	
AND ( -- inception  status 
       ( @p_norm_cf = 'I17G' and (a.GRPINISTS_CT  = 2 or a.GRPINISTS_CT  = 9 or ((a.GRPINISTS_CT is null or a.GRPINISTS_CT  = 1) and tcr.CRUWY_NF  != a.UWY_NF)  ) )
    or ( @p_norm_cf = 'I17P' and (a.PARINISTS_CT  = 2 or a.PARINISTS_CT  = 9 or ((a.PARINISTS_CT is null or a.PARINISTS_CT  = 1) and tcr.CRUWY_NF  != a.UWY_NF)  ) )
    or ( @p_norm_cf = 'I17L' and (a.LOCINISTS_CT  = 2 or a.LOCINISTS_CT  = 9 or ((a.LOCINISTS_CT is null or a.LOCINISTS_CT  = 1) and tcr.CRUWY_NF  != a.UWY_NF)  ) )
	)		
union all
select a.CTR_NF
		,a.END_NT
		,a.SEC_NF
		,a.UWY_NF
		,a.UW_NT
		,a.GRPRATEINDEX_CT
		,a.PARRATEINDEX_CT
		,a.LOCRATEINDEX_CT
		,'F'			--FAC
		,d.SSD_CF
		,d.ACCESB_CF
		,a.GRPINISTS_CT
		,a.PARINISTS_CT
		,a.LOCINISTS_CT
		,a.GRPFIRCLO_D
		,a.PARFIRCLO_D
		,a.LOCFIRCLO_D
		,a.GRPIFRSTRA_CT
		,a.PARIFRSTRA_CT
		,a.LOCIFRSTRA_CT
from BFAC..TSECIFRS a , BREF..TBATCHSSD b, BFAC..TCONTR d, BFAC..TSECTION c ,BFAC..tcrcontr tc , BFAC..TCR tcr
where b.BATCHUSER_CF = suser_name() 
AND b.SSD_CF =  d.SSD_CF
AND a.CTR_NF = d.CTR_NF    AND  a.UWY_NF = d.UWY_NF   AND   a.UW_NT  = d.UW_NT   AND   a.END_NT = d.END_NT 
AND a.CTR_NF = c.CTR_NF    AND   a.UWY_NF = c.UWY_NF   AND   a.UW_NT  = c.UW_NT  AND   a.END_NT = c.END_NT
AND a.SEC_NF  = C.SEC_NF 
AND c.SECSTS_CT IN (select Id from @sts_list)
AND d.CTRSTS_CT IN (select Id from @sts_list) 
AND c.LOB_CF != '30' AND c.LOB_CF != '31'
AND a.CTR_NF=tc.CTR_NF
AND a.END_NT=tc.END_NT
AND a.UWY_NF=tc.UWY_NF
AND a.UW_NT =tc.UW_NT
AND tc.CR_NF      = tcr.CR_NF
AND tc.CRUWY_NF   = tcr.CRUWY_NF
and tc.CRUW_NT    = tcr.CRUW_NT	
AND ( -- inception  status 
       ( @p_norm_cf = 'I17G' and (a.GRPINISTS_CT  = 2 or a.GRPINISTS_CT  = 9 or ((a.GRPINISTS_CT is null or a.GRPINISTS_CT  = 1) and tcr.CRUWY_NF  != a.UWY_NF)  ) )
    or ( @p_norm_cf = 'I17P' and (a.PARINISTS_CT  = 2 or a.PARINISTS_CT  = 9 or ((a.PARINISTS_CT is null or a.PARINISTS_CT  = 1) and tcr.CRUWY_NF  != a.UWY_NF)  ) )
    or ( @p_norm_cf = 'I17L' and (a.LOCINISTS_CT  = 2 or a.LOCINISTS_CT  = 9 or ((a.LOCINISTS_CT is null or a.LOCINISTS_CT  = 1) and tcr.CRUWY_NF  != a.UWY_NF)  ) )
	)
order by a.CTR_NF,  a.SEC_NF, a.UWY_NF, a.END_NT, a.UW_NT

INSERT INTO #DATA (CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,GRPRATEINDEX_CT,PARRATEINDEX_CT,LOCRATEINDEX_CT,TYPE,SSD_CF,ESB_CF,
				GRPINISTS_CT,PARINISTS_CT,LOCINISTS_CT,GRPFIRCLO_D,PARFIRCLO_D,LOCFIRCLO_D,GRPIFRSTRA_CT,PARIFRSTRA_CT,LOCIFRSTRA_CT) 
		select a.RETCTR_NF
		,0 AS END_NT
		,C.RETSEC_NF
		,a.RTY_NF
		,0 AS UW_NT
		,a.GRPRATEINDEX_CT
		,a.PARRATEINDEX_CT
		,a.LCLRATEINDEX_CT
		,'R'			--RETRO
		,d.SSD_CF
		,d.ESB_CF
		,a.GRPINISTS_CT 
		,a.PARINISTS_CT 
		,a.LOCINISTS_CT  
		,a.GRPFSTCLO_D
		,a.PARFSTCLO_D 
		,a.LCLFSTCLO_D
		,a.GRPIFRSTRA_CT
		,a.PARIFRSTRA_CT
		,a.LOCIFRSTRA_CT
from BRET..TRETIFRS a , BREF..TBATCHSSD b ,BRET..TRETSEC C,  BRET..TRETCTR d
where b.BATCHUSER_CF = suser_name() 
and b.SSD_CF =  d.SSD_CF AND a.RETCTR_NF = C.RETCTR_NF    AND   a.RTY_NF = C.RTY_NF
--	AND a.GRPRATEINDEX_CT IS NOT NULL AND a.LCLRATEINDEX_CT IS NOT NULL
	and a.RETCTR_NF = d.RETCTR_NF    AND   a.RTY_NF = d.RTY_NF and  d.RETCTRSTS_CT IN (3,19) -- VALIDE
AND ( -- inception  status 
       ( @p_norm_cf = 'I17G' and (a.GRPINISTS_CT  = 2 or a.GRPINISTS_CT  = 9))
    or ( @p_norm_cf = 'I17P' and (a.PARINISTS_CT  = 2 or a.PARINISTS_CT  = 9))
    or ( @p_norm_cf = 'I17L' and (a.LOCINISTS_CT  = 2 or a.LOCINISTS_CT  = 9))
	)
order by a.RETCTR_NF, a.RTY_NF

SELECT 
       CTR_NF          
      ,END_NT          
      ,SEC_NF          
      ,UWY_NF          
      ,UW_NT           
      ,GRPRATEINDEX_CT 
      ,PARRATEINDEX_CT 
      ,LOCRATEINDEX_CT 
      ,TYPE 			
      ,SSD_CF			
      ,ESB_CF			
      ,GRPINISTS_CT    
      ,PARINISTS_CT    
      ,LOCINISTS_CT    
      ,convert(char(8), GRPFIRCLO_D , 112) 
	  ,convert(char(8), PARFIRCLO_D , 112) 
	  ,convert(char(8), LOCFIRCLO_D , 112)
	  ,GRPIFRSTRA_CT
	  ,PARIFRSTRA_CT
	  ,LOCIFRSTRA_CT
FROM #DATA 
order by TYPE, SSD_CF, ESB_CF, CTR_NF,  SEC_NF, UWY_NF, END_NT, UW_NT

go

if object_id('dbo.PsFetchCTRRatInd') is not null
  print '<<< CREATED PROC dbo.PsFetchCTRRatInd >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFetchCTRRatInd >>>'
go
grant execute on dbo.PsFetchCTRRatInd TO GOMEGA
go
grant execute on dbo.PsFetchCTRRatInd TO GDBBATCH
go
