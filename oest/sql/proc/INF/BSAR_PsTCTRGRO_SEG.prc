USE BSAR
go
IF OBJECT_ID('dbo.PsTCTRGRO_SEG') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTCTRGRO_SEG
    IF OBJECT_ID('dbo.PsTCTRGRO_SEG') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTCTRGRO_SEG >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTCTRGRO_SEG >>>'
END
go
CREATE OR REPLACE PROCEDURE dbo.PsTCTRGRO_SEG
  (
  @P_SSD_CF    varchar(2)
 ,@P_SEGTYP_CT USEGTYP_CT
 ,@P_SGT_NT    varchar(10)
 ,@P_VRS_NF    varchar(10)
 ,@P_TYPEINV_CF char(4)
  )
as
/***************************************************
Domaine : Estimations
Base principale : BSAR
Auteur: Florent
Date de creation: 01/06/2015
Description du programme: :spot:28694 Segmentation VIE
Conditions d'execution: par les batch asynchrones de la segmentation
Commentaires: les param�tres sont pass� en mode caract�re pour �viter les convertions dans la commande exec
_________________
MODIFICATIONS
1 11/05/2017 Florent :spira:58025 ajout de la version de la segmentation et format complet comme BEST..TCTRGRO
[002] 21/08/2017	R. Cassis :spira:63608 Correction de la taille du champ du SEG_NF a 10 au lieu de 8.
[002] 06/09/2018 add UWY spira 57605
[003] 07/02/2019  spira 57605 prendre le UWY @SGTRESTABNME_LL et non de TCONTR afin d'avoir q'une seule ligne quand @SGTRESTABNME_LL.uwy_nf = 0
[004] 07/02/2019  spira 57605 ajout de la jointure sur UW_NT
[005] 09/01/2023  spira 102482 force onerous
[006] 24/08/2023  spira 110431 : JYP+Florian: add case UWY_NF = 0
[007] 10/10/2023 DAD spira 109347 EBS/I17 - Fac status Accepted only POS
[008] 26/04/2024  DaD spira 111368  replace the NOT IN by IN with theses statuses and reduced to 12 and 14 for fac, 12 for trt

BSAR..PsTCTRGRO_SEG '01','A','1441','121'
*****************************************************/
declare
 @SGTVER_NT varchar(10)
,@SGTRESTABNME_LL varchar(64)
,@DOMAGE_B bit
,@BASEREF  char(4)
,@SQL_REF_SELECT  varchar(3000)
,@SQL_REF_SELECT_tt varchar(3000)
,@SQL_STS_LIST        varchar(254)

----------------------------------------------------------------------------------
--Version creation case:
--The segmentation number does not yet exists
--The last created segmentation is taken for the given subsidiary
----------------------------------------------------------------------------------
if @P_SGT_NT = 'null' 
begin
SELECT @P_SGT_NT = convert(varchar(10), MAX(TSEGMENTATION.SGT_NT))
  FROM BEST..TSEGMENTATION TSEGMENTATION, BEST..TSEGTYPE TSEGTYPE
WHERE     TSEGMENTATION.SGTTYP_NT = TSEGTYPE.SGTTYP_NT
       AND TSEGMENTATION.SGTGRAN_CT in ('2','3','4')
       AND TSEGTYPE.SGTSCOPE_CT = '1'
       AND TSEGTYPE.SGTMGTLVL_CT = '3'
       AND TSEGMENTATION.BALAI_B = 1
       AND TSEGMENTATION.SGTSTS_CF = '3'
       AND TSEGMENTATION.SSD_CF = convert(tinyint,@P_SSD_CF)
end
----------------------------------------------------------------------------------



SELECT @SGTVER_NT=convert(varchar(10),SGTVER_NT), @SGTRESTABNME_LL=SGTRESTABNME_LL
 from BSEG..TSEGRUN
  where SGTRUN_NT=(select max(SGTRUN_NT) from BSEG..TSEGRUN where SGT_NT=convert(int,@P_SGT_NT) and SGTRUNSTS_CT='5' and SGTEVAL_B=1 and SGTSIMU_B=0)
print '@SGTVER_NT %1!, @SGTRESTABNME_LL %2!',@SGTVER_NT,@SGTRESTABNME_LL

if exists (select 1 from BREF..TESB where LIFE_CF=2 and SSD_CF=convert(tinyint,@P_SSD_CF))
	select @DOMAGE_B=1, @BASEREF='BMIS', @SQL_REF_SELECT="case when c.CTRTYP_CT=2 then 'F' when c.CTRTYP_CT=1 and p.NAT_CF < '30' then 'P' else 'N' end"
else
	select @DOMAGE_B=0, @BASEREF='BTRT', @SQL_REF_SELECT="case when p.NAT_CF < '30' then 'P' else 'N' end"

select @SQL_REF_SELECT_tt="
  s.CTR_NF
  ,p.END_NT
  ,s.SEC_NF
  ,VRS_NF="+@P_VRS_NF+"
  ,p.SSD_CF
  ,SEGTYP_CT='"+@P_SEGTYP_CT+"'
  ,s.UWY_NF
  ,c.CTRTYP_CT
  ,p.LOB_CF
  ,c.CTRSTS_CT 
  ,p.SECSTS_CT 
  ,p.SECACCSTS_CT 
  ,c.ESTCRB_CT
  ,DIV_NT=p.DIV_NT
  ,CED_NF=c.CED_NF
  ,UWGRP_CF=c.UWGRP_CF
  ,SOB_CF=p.SOB_CF
  ,TOP_CF=p.TOP_CF
  ,NAT_CF=p.NAT_CF
  ,SUBNAT_CF=p.SUBNAT_CF
  ,PCPRSKTRY_CF=p.PCPRSKTRY_CF
  ,SECINC_D=p.SECINC_D
  ,SECCAN_D=p.SECCAN_D
  ,CTRRET_B=isnull((select case when i.CLISSD_CF=null then 0 else 1 end from BCLI..TCLIENT i where i.CLI_NF=(select max(y.CED_NF) from BMIS..TCONTR y where y.CTR_NF=c.CTR_NF
                  and y.UWY_NF=(select max(z.UWY_NF) from BMIS..TCONTR z where c.CTR_NF=z.CTR_NF
                                and (   (z.CTRTYP_CT=1 and z.CTRSTS_CT IN(14,16,17,19,23))
                                      or (z.CTRTYP_CT=2 and z.CTRSTS_CT IN(16,18,19))
                                    )) )),0)"

exec ("-- [008]
create table #STS_LIST (Id TINYINT)

insert into #STS_LIST values (16)
insert into #STS_LIST values (18)
insert into #STS_LIST values (19)
IF('"+ @P_TYPEINV_CF +"' = 'POS')
BEGIN
    insert into #STS_LIST values (14)
END

create table #TCTRGRO_EST
(
  CTR_NF       UCTR_NF       NOT NULL,
  END_NT       UEND_NT       NOT NULL,
  SEC_NF       USEC_NF       NOT NULL,
  VRS_NF       numeric(10,0) NOT NULL,
  SSD_CF       USSD_CF       NOT NULL,
  SEGTYP_CT    USEGTYP_CT    DEFAULT ''        NOT NULL,
  SEG_NF       varchar(10)    DEFAULT ''        NOT NULL,
  DIV_NT       UDIV_NT       NULL,
  CED_NF       UCLI_NF       NULL,
  UWGRP_CF     UGRP_CF       NULL,
  LOB_CF       ULOB_CF       NULL,
  SOB_CF       USOB_CF       NULL,
  TOP_CF       UTOP_CF       NULL,
  NAT_CF       UCTRNAT_CF    NULL,
  SUBNAT_CF    UCTRSUBNAT_CF NULL,
  PCPRSKTRY_CF UCTY_CF       NULL,
  SECINC_D     datetime      NULL,
  SECCAN_D     datetime      NULL,
  CTRRET_B     tinyint       DEFAULT 0         NOT NULL,
  CRE_D        UUPD_D        DEFAULT getdate() NOT NULL,
  CTRNAT_CF    char(1)       NULL,
  UWY_NF    smallint null
)


----------------PREPARE TCTRGRO DATA (in tmp table #tt)----------------
--SEGMENTS BALAI:
  SELECT distinct 
    "+@SQL_REF_SELECT_tt+"
    ,CTRNAT_CF="+@SQL_REF_SELECT+"
    ,SEG_NF = left(t.COLVAL_LS, 10)
    ,CTR_NF_fs=fs.CTR_NF    --[005]
    ,CTR_NF_ts=ts.CTR_NF    --[005]
  into #tt
  FROM "+@SGTRESTABNME_LL+" s
  JOIN BREF..TBANTECL t  on s.SGMT_NF = convert(int, t.COLVAL_CT) 
    and t.COL_LS = 'SGTBALAITYP_CF' 
    and t.LAG_CF = 'E'
    and s.SGMT_NF < 0
  LEFT OUTER JOIN  "+@BASEREF+"..TSECTION p on s.SSD_CF = p.SSD_CF 
    AND s.CTR_NF = p.CTR_NF        
    AND s.SEC_NF = p.SEC_NF 
    AND (s.UWY_NF = p.UWY_NF OR s.UWY_NF = 0 )     
    AND (s.UW_NT = p.UW_NT OR s.UW_NT = 0) 
    AND p.SSD_CF="+@P_SSD_CF+"     
  LEFT OUTER JOIN "+@BASEREF+"..TCONTR c on  c.CTR_NF = p.CTR_NF  
    AND c.UWY_NF = p.UWY_NF   
    AND c.UW_NT = p.UW_NT   
    AND c.END_NT = p.END_NT   
    AND c.SSD_CF = p.SSD_CF
  LEFT OUTER JOIN BFAC..TSECIFRS fs on fs.FRCIFRSBTCH_NT = 1    --[005]
    AND fs.UWY_NF = p.UWY_NF 
    AND fs.UW_NT = p.UW_NT 
    AND fs.CTR_NF = p.CTR_NF 
    AND fs.end_nt = p.end_nt 
    AND fs.sec_nf = p.sec_nf
  LEFT OUTER JOIN BTRT..TSECIFRS ts on  ts.FRCIFRSBTCH_NT = 1     --[005]
    AND ts.UWY_NF = p.UWY_NF  
    AND ts.UW_NT = p.UW_NT  
    AND ts.CTR_NF = p.CTR_NF 
    AND ts.end_nt = p.end_nt 
    AND ts.sec_nf = p.sec_nf
  union all
  --SEGMENTS ACTUARIEL:
  SELECT distinct 
    "+@SQL_REF_SELECT_tt+"
    ,CTRNAT_CF="+@SQL_REF_SELECT+"
    ,SEG_NF = left(t.SGMT_LS, 10)
    ,CTR_NF_fs=fs.CTR_NF      --[005]
    ,CTR_NF_ts=ts.CTR_NF      --[005]
  FROM "+@SGTRESTABNME_LL+" s
  JOIN BEST..TSEGMT t  on s.SGMT_NF=t.SGMT_NF 
    and t.SGT_NT="+@P_SGT_NT+" 
    and t.SGTVER_NT="+@SGTVER_NT+"
    and s.SGMT_NF > 0
  LEFT OUTER JOIN  "+@BASEREF+"..TSECTION p on s.SSD_CF = p.SSD_CF 
    AND s.CTR_NF = p.CTR_NF 
    AND s.SEC_NF = p.SEC_NF 
    AND (s.UWY_NF = p.UWY_NF OR s.UWY_NF = 0)
    AND (s.UW_NT = p.UW_NT OR s.UW_NT = 0) 
    AND p.SSD_CF="+@P_SSD_CF+"     
  LEFT OUTER JOIN "+@BASEREF+"..TCONTR c on c.CTR_NF = p.CTR_NF  
    AND c.UWY_NF = p.UWY_NF 
    AND c.UW_NT = p.UW_NT 
    AND c.END_NT = p.END_NT 
    AND c.SSD_CF = p.SSD_CF 
  LEFT OUTER JOIN BFAC..TSECIFRS fs on fs.FRCIFRSBTCH_NT = 1    --[005]
    AND fs.UWY_NF = p.UWY_NF 
    AND fs.UW_NT = p.UW_NT 
    AND fs.CTR_NF = p.CTR_NF 
    AND fs.end_nt = p.end_nt 
    AND fs.sec_nf = p.sec_nf
  LEFT OUTER JOIN BTRT..TSECIFRS ts on  ts.FRCIFRSBTCH_NT = 1     --[005]
    AND ts.UWY_NF = p.UWY_NF  
    AND ts.UW_NT = p.UW_NT  
    AND ts.CTR_NF = p.CTR_NF 
    AND ts.end_nt = p.end_nt 
    AND ts.sec_nf = p.sec_nf


--insert in tmp table #TCTRGRO_EST to avoid line duplication
if exists(select 1 from BREF..TESB where LIFE_CF=2 and SSD_CF="+@P_SSD_CF+")
begin
----------------PREPARE TCTRGRO DATA (in tmp table #TCTRGRO_EST) P&C----------------
  ----------------FILL IN TCTRGRO FOR P&C----------------
  insert #TCTRGRO_EST (CTR_NF ,END_NT ,SEC_NF ,VRS_NF ,SSD_CF ,SEGTYP_CT ,SEG_NF ,UWY_NF)
  select distinct CTR_NF ,END_NT ,SEC_NF ,VRS_NF ,SSD_CF ,SEGTYP_CT ,SEG_NF ,UWY_NF
  from #tt
  where (   (   CTRTYP_CT = 1
          AND LOB_CF NOT IN ('30', '31')
          AND SECSTS_CT IN (14, 16, 17, 19, 23)
          AND CTRSTS_CT IN (14, 16, 17, 19, 23)   )
      OR 
      (   CTRTYP_CT = 2
          AND SECSTS_CT IN (select Id from #STS_LIST)
          AND CTRSTS_CT IN (select Id from #STS_LIST)   )
      OR --[005] Includes forced FAC onerous contract  
      (   SECSTS_CT IN (12, 14)
          AND CTRSTS_CT IN (12, 14)
          AND CTR_NF_fs != null   )
      OR --[005] Includes forced TRT onerous contract
      (   SECSTS_CT IN (12)
          AND CTRSTS_CT IN (12, 14)
          AND CTR_NF_ts != null   )   )            
    AND SECACCSTS_CT != 9
     
end       
else 
begin
----------------PREPARE TCTRGRO DATA (in tmp table #TCTRGRO_EST) FOR LIFE----------------
  ----------------FILL IN TCTRGRO FOR LIFE----------------
  insert #TCTRGRO_EST (CTR_NF ,END_NT ,SEC_NF ,VRS_NF ,SSD_CF ,SEGTYP_CT ,SEG_NF ,UWY_NF)
  select distinct CTR_NF ,END_NT ,SEC_NF ,VRS_NF ,SSD_CF ,SEGTYP_CT ,SEG_NF ,UWY_NF
  from #tt
  where LOB_CF in('30','31') 
    and SECSTS_CT IN(14,16,17,19,23) 
    and CTRSTS_CT IN(14,16,17,19,23) 
    and SECACCSTS_CT!=9 and ESTCRB_CT='E'

end

create unique clustered index iCTRGRO_EST on #TCTRGRO_EST(CTR_NF,END_NT,SEC_NF,UWY_NF)


----------------Add missing DATA (in tmp table #TCTRGRO_EST)----------------
update #TCTRGRO_EST
set DIV_NT=tt.DIV_NT
  ,CED_NF=tt.CED_NF
  ,UWGRP_CF=tt.UWGRP_CF
  ,LOB_CF=tt.LOB_CF
  ,SOB_CF=tt.SOB_CF
  ,TOP_CF=tt.TOP_CF
  ,NAT_CF=tt.NAT_CF
  ,SUBNAT_CF=tt.SUBNAT_CF
  ,PCPRSKTRY_CF=tt.PCPRSKTRY_CF
  ,SECINC_D=tt.SECINC_D
  ,SECCAN_D=tt.SECCAN_D
  ,CTRRET_B=tt.CTRRET_B
  ,CTRNAT_CF=tt.CTRNAT_CF
from #TCTRGRO_EST a, #tt tt
where a.CTR_NF=tt.CTR_NF
and a.END_NT=tt.END_NT
and a.SEC_NF=tt.SEC_NF
and a.VRS_NF=tt.VRS_NF
and a.SSD_CF=tt.SSD_CF
and a.SEGTYP_CT=tt.SEGTYP_CT
and a.UWY_NF=tt.UWY_NF


----------------FINAL TCTRGRO OUTPUT----------------
select * from #TCTRGRO_EST
order by CTR_NF,END_NT,SEC_NF,VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF,UWY_NF
")

go
EXEC sp_procxmode 'dbo.PsTCTRGRO_SEG', 'unchained'
go
IF OBJECT_ID('dbo.PsTCTRGRO_SEG') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTCTRGRO_SEG >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTCTRGRO_SEG >>>'
go
GRANT EXECUTE ON dbo.PsTCTRGRO_SEG TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTCTRGRO_SEG TO GDBBATCH
go


