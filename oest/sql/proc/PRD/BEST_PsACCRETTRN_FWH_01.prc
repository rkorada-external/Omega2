use BEST
go
if object_id('dbo.PsACCRETTRN_FWH_01') is not null
begin
  drop PROC dbo.PsACCRETTRN_FWH_01
  print '<<< DROPPED PROC dbo.PsACCRETTRN_FWH_01 >>>'
end
go

create procedure dbo.PsACCRETTRN_FWH_01

as

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BTRT
Auteur                  : Quentin Desmettre
Date de creation        : 17/09/2018
Description du programme: Creation of the list of contract with signed fund held
Conditions d'execution  : chaine ESID0060
Commentaires            :
_________________
MODIFICATIONS
1 03/04/2019 Quentin Desmettre :spira:74585 REQ10.9 - Simulated fund held on retro contracts
2 24/10/2019 Charles SOCIE : Spira 76676 removing the status condition 
3 22/11/2019 Kbagwe	: Spira 74585 - REQ10.9 - Simulated fund held on retro contracts
4 12/10/2020 Charles SOCIE : Spira 90297 FHNI - OLR Percent use
*****************************************************/



CREATE TABLE #DATA(
    CTR_NF           UCTR_NF    NOT NULL,
    SSD_CF           USSD_CF    NOT NULL,
    SEC_NF           USEC_NF    NOT NULL,
    UWY_NF           UUWY_NF    NOT NULL,
    UW_NT            UUW_NT     DEFAULT 1         NOT NULL,
    END_NT           UEND_NT    DEFAULT 0         NOT NULL,
	CLMFUN_R         USHORAT_R  NULL,
	CLMFUNINT_R      USHORAT_R  NULL,
	CLMFUNVARINT_R   USHORAT_R  NULL,
	CLMFUNVARINT_B   UBOOLEAN_B NULL,
	CLMFUNVARBASE_CT UBANVAL_CT NULL,
	TYPE_CT			 CHAR(1),
	CLMFUNCAS_R      USHORAT_R  NULL,
    PLC_NT         UPLC_NT      NOT NULL,
	PLCVER_NT      int          DEFAULT 0         NOT NULL,
    RTO_NF         UCLI_NF      NOT NULL,
	ESB_CF          UESB_CF    NOT NULL
)

 INSERT INTO #DATA  (CTR_NF,SSD_CF,SEC_NF,UWY_NF,UW_NT ,END_NT,CLMFUN_R , CLMFUNINT_R   ,CLMFUNVARINT_R ,CLMFUNVARINT_B ,CLMFUNVARBASE_CT,TYPE_CT, CLMFUNCAS_R, PLC_NT,PLCVER_NT, RTO_NF  ,ESB_CF       ) 

select a.CTR_NF 
      ,a.SSD_CF
      ,a.SEC_NF
      ,a.UWY_NF
	,a.UW_NT
      ,a.END_NT
	,isnull(a.CLMFUN_R,0) as CLMFUN_R
	,isnull(a.CLMFUNINT_R,0) as CLMFUNINT_R
	,isnull(a.CLMFUNVARINT_R,0) as CLMFUNVARINT_R
      ,isnull(a.CLMFUNVARINT_B,0) as CLMFUNVARINT_B
      ,a.CLMFUNVARBASE_CT as CLMFUNVARBASE_CT
	,'A' as TYPE
	,a.CLMFUNCAS_R as CLMFUNCAS_R
	, 0   as PLC_NT
	, 0  as PLCVER_NT
	, 0 as RTO_NF
	,d.ACCESB_CF AS ESB_CF
from BTRT..TFAMFUNW a , BREF..TBATCHSSD b , BTRT..TCONTR d, BTRT..TSECTION c where  A.CLMFUNWIT_B= 1 and a.SSD_CF = b.SSD_CF and b.BATCHUSER_CF = suser_name() 
		and a.CTR_NF = c.CTR_NF    AND   a.UWY_NF = c.UWY_NF   AND   a.UW_NT  = c.UW_NT   AND   a.END_NT = c.END_NT and a.SEC_NF  = C.SEC_NF 
		AND  C.LOB_CF NOT IN ('30','31') -- AND C.SECSTS_CT IN (14,16,17) Modif2
		AND isnull(a.CLMFUNCAS_R, 0) > 0 -- AND isnull(a.CLMFUN_R, 0) > 0
            AND   a.CTR_NF = d.CTR_NF    AND  a.UWY_NF = d.UWY_NF   AND   a.UW_NT  = d.UW_NT   AND   a.END_NT = d.END_NT 
            AND  D.CTRLCK_B <>1 -- AND C.SECACCSTS_CT <> 9  
           --AND	  D. CTRSTS_CT  IN (14,16,17) -- Finalized 	'14' - Accepted/ bound '16' - Finalized '17' - Renewed
order by a.SSD_CF, d.ACCESB_CF, a.END_NT, a.CTR_NF, a.SEC_NF, a.UWY_NF, a.UW_NT


INSERT INTO #DATA  (CTR_NF,SSD_CF,SEC_NF,UWY_NF,UW_NT ,END_NT,CLMFUN_R , CLMFUNINT_R   ,CLMFUNVARINT_R ,CLMFUNVARINT_B ,CLMFUNVARBASE_CT,TYPE_CT, CLMFUNCAS_R, PLC_NT,PLCVER_NT, RTO_NF,ESB_CF        ) 

--MOD03
--Contract’s Fund Condition to apply if ((BRET..TPLACEMT. CTRFUNCON_B) = ‘1’
--take Fund held condition at contract level = table  BRET..TDEPOSIT if DEPADM_CT in (1,2) and CLMFUNMOD_CT = 1 and (CLMFUN_R <> 0 or not null)
select distinct dep.RETCTR_NF
      ,ctr.SSD_CF
      ,sec.RETSEC_NF
      ,ctr.RTY_NF
	  ,1 AS UW_NT
      ,0 AS END_NT
	  , isnull(dep.CLMFUN_R,0) 
	  ,0
	  ,0
      ,0
      ,null
	  ,'R' 
	  ,1
  	  ,tplc.PLC_NT
  	  ,tplc.PLCVER_NT
	  ,tplc.RTO_NF
	  ,ctr.ESB_CF  
	FROM BRET..TDEPOSIT dep,  BREF..TBATCHSSD ssd , BRET..TRETCTR ctr, BRET..TRETSEC sec,  BRET..TPLACEMT tplc 
	WHERE ctr.RETCTR_NF = dep.RETCTR_NF and ctr.RTY_NF = dep.RTY_NF and ctr.RETCTR_NF = sec.RETCTR_NF and ctr.RTY_NF = sec.RTY_NF
    and ctr.RETCTR_NF = tplc.RETCTR_NF and ctr.RTY_NF = tplc.RTY_NF and dep.SSD_CF = ctr.SSD_CF AND  ctr.SSD_CF = ssd.SSD_CF and ssd.BATCHUSER_CF =  suser_name()
    and ctr.RETCTRSTS_CT = 3 -- Valid 
	and ctr.RETCTRCAT_CF in ('01') and dep.DEPADM_CT in ( 1, 2) and PLCSTS_CT IN (16, 19) and HIS_B = 0 
	and  tplc.ctrfuncon_b = 1   AND dep.CLMFUNMOD_CT = 1 and isnull(dep.CLMFUN_R,0) > 0   --MOD03
    
	--order by ctr.SSD_CF, ctr.ESB_CF, ctr.RETCTR_NF, sec.RETSEC_NF, ctr.RTY_NF, tplc.PLC_NT, tplc.RTO_NF

   
    union 
--MOD03
--Placement funds condition to apply if ((BRET..TPLACEMT. CTRFUNCON_B) = ‘0’ 
--take Fund held condition at placement level = table  BRET..TPFUNWIT for the given placement if CLMFUNMOD_CT = 1 and (CLMFUN_R <> 0 or not null)

    select distinct ctr.RETCTR_NF
      ,ctr.SSD_CF
      ,sec.RETSEC_NF
      ,ctr.RTY_NF
	  ,1 AS UW_NT
      ,0 AS END_NT
	  , isnull(fun.CLMFUN_R,0) 
	  ,0
	  ,0
      ,0
      ,null
	  ,'R' 
	  ,1
  	  ,tplc.PLC_NT
  	  ,tplc.PLCVER_NT
	  ,tplc.RTO_NF
	  ,ctr.ESB_CF  
	FROM   BREF..TBATCHSSD ssd , BRET..TRETCTR ctr, BRET..TRETSEC sec,  BRET..TPLACEMT tplc,  BRET..TPFUNWIT fun
	WHERE   ctr.RETCTR_NF = sec.RETCTR_NF and ctr.RTY_NF = sec.RTY_NF
    and ctr.RETCTR_NF = tplc.RETCTR_NF and ctr.RTY_NF = tplc.RTY_NF and ctr.RETCTR_NF = fun.RETCTR_NF and ctr.RTY_NF = fun.RTY_NF
	and tplc.PLC_NT = fun.PLC_NT and tplc.PLCVER_NT = fun.PLCVER_NT  and  ctr.SSD_CF = ssd.SSD_CF and ssd.BATCHUSER_CF =  suser_name()
    and ctr.RETCTRSTS_CT = 3 -- Valid 
	and ctr.RETCTRCAT_CF in ('01')   and PLCSTS_CT IN (16, 19) and HIS_B = 0 
	and  tplc.ctrfuncon_b = 0  and fun.CLMFUNMOD_CT = 1 AND isnull(fun.CLMFUN_R,0) > 0   --MOD03
--	order by ctr.SSD_CF, ctr.ESB_CF, ctr.RETCTR_NF, sec.RETSEC_NF, ctr.RTY_NF, tplc.PLC_NT, tplc.RTO_NF
    

   

UPDATE #DATA
SET 	CLMFUNINT_R = isnull(tin.CLMFUNINT_R,0)    , 
	CLMFUNVARINT_R  = isnull(tin.CLMFUNVARINT_R,0)     ,
	CLMFUNVARINT_B   = isnull(tin.CLMFUNVARINT_B,0)  ,
	CLMFUNVARBASE_CT = tin.CLMFUNVARINTBASE_CT
	FROM #DATA A ,  BRET..TINTWIT tin 
	where   a.CTR_NF = tin.RETCTR_NF and a.UWY_NF = tin.RTY_NF AND TYPE_CT = 'R' AND
	isnull(tin.CLMFUNVARINT_B,0) =  1  AND tin.RETTRTCUR_CF = (SELECT  MAX( ti.RETTRTCUR_CF) FROM BRET..TINTWIT ti WHERE 
                                                                              ti.RETCTR_NF = tin.RETCTR_NF and ti.RTY_NF =  tin.RTY_NF    )  

 SELECT * FROM #DATA order by TYPE_CT, SSD_CF,ESB_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT, PLC_NT, RTO_NF

 
go

if object_id('dbo.PsACCRETTRN_FWH_01') is not null
  print '<<< CREATED PROC dbo.PsACCRETTRN_FWH_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsACCRETTRN_FWH_01 >>>'
go
grant execute on dbo.PsACCRETTRN_FWH_01 TO GOMEGA
go
grant execute on dbo.PsACCRETTRN_FWH_01 TO GDBBATCH
go
