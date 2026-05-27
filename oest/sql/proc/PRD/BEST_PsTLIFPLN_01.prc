USE BEST
go
IF OBJECT_ID('dbo.PsESTLIFPLN_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsESTLIFPLN_01
    IF OBJECT_ID('dbo.PsESTLIFPLN_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsESTLIFPLN_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsESTLIFPLN_01 >>>'
END
go
/*
 * creation de la procedure */
create procedure dbo.PsESTLIFPLN_01

as
/***************************************************
Programme:                  PsESTLIFPLN_01
Fichier script associé :    BEST_PsESTLIFPLN_01.prc
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     J. Ribot
Date de creation:           05/05/2004
Description du programme:   
    - sélection des écritures d'ajustement du plan
Parametres:
    - annee de la periode du plan

_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:           17/03/2010
Version:        10.1
Description:    SRVIE16960 Adaptation de TLIFSTAREP  création d'une version du plan vie à la demande + ES plan à intégrer

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 21/05/2014 M. MECHRI   :spot:26803  - Modifications pour omega2 -1b correction plan vie
[102] 21/01/2015 M.Estrade :spot28122   - Modification pour EST48, BPC versioning
[103] 18/02/2015 S.Behague :spot30223   - Modification Union en Union All pour éviter dédoublonnage
*****************************************************/
declare   @clodat_year        int,
            @clodat_month       int,
            @clodat_day         int,
            @erreur             int,
            @balshtyea_nf       smallint

select @erreur      = 0

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output
if @erreur != 0 goto fin

--


-- date de la dernière photo plan (photo plan active) par filiale

select SSD_CF, convert(int,substring(convert(char(6),VRS_NF),1,4)) PLAN_NF, convert(int,substring(convert(char(6),VRS_NF),5,2)) balshrmth_nf, CLODAT_D, launch_d 
        into #Plan_Actif
        from best..treqjob a
        where reqcod_ct="A" 
        and isnull(vrs_nf,0) > 0
        and cre_d = (select max(cre_d) 
                     from best..treqjob b
                     where a.ssd_cf   = b.ssd_cf
                     and   a.reqcod_ct= b.reqcod_ct
                     and b.launch_d is not null)


if @@error != 0 goto fin


-- selection des exe+version plan post mis à jour après la date de la derniere mise à jour de SRV par filiale

select a.SSD_CF, convert(int,substring(convert(char(6),PLAN_NF),1,4)) PLAN_NF,
        convert(int,substring(convert(char(6),PLAN_NF),5,2)) balshrmth_nf,
        max(a.cre_d) LstMVT_D,
        max(launch_d) LstCLO_D 
    into #Plan_PostBPC
    from best..tlifpln a , best..treqjob c
    where a.SSD_CF=c.SSD_CF
            and c.reqcod_ct in ("I","J","L")             -- les demandes d'inventaires ayant mis à jour SRV
            and c.BALSHEYEA_NF >= YEAR(getdate()) - 5    -- sur les 5 dernières années
            and convert(int,substring(convert(char(6),PLAN_NF),1,4)) >= YEAR(getdate()) - 5           -- sur les 5 dernières années
            and exists (select 1  from best..treqjob b
                                        where c.ssd_cf   = b.ssd_cf
                                        and   b.reqcod_ct= "A")
            and launch_d is not null
            and not exists (select 1 from #Plan_Actif d where d.ssd_cf=a.ssd_cf and d.PLAN_NF*100+d.balshrmth_nf=a.PLAN_NF)  --substring(convert(char(6),a.PLAN_NF),1,4) and d.balshrmth_nf=substring(convert(char(6),a.balshrmth_nf),5,2))
    group by a.SSD_CF, PLAN_NF, balshrmth_nf
    --having max(a.cre_d) > max(launch_d)          -- écritures passées après le dernier inventaire ayant mis à jour SRV pour cette filiale
    having max(a.cre_d) > max(DATEADD( DAY, -100, launch_d ))   
    order by a.SSD_CF, PLAN_NF, balshrmth_nf
    
if @@error != 0 goto fin

select a.SSD_CF, a.ESB_CF, isnull(substring(convert(char(6),a.PLAN_NF),1,4),convert(char(4),a.BALSHEY_NF)) BALSHEY_NF, isnull(substring(convert(char(6),a.PLAN_NF),5,2),convert(char(2),a.balshrmth_nf)) BALSHRMTH_NF, a.BALSHRDAY_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF, a.CTR_NF,
        a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF, 0 CLM_NF, a.CUR_CF, a.AMT_M, 
        a.CED_NF, a.BRK_NF, a.GEMPRMPAY_NF, a.GANPAYORD_NT, a.RETCTR_NF, a.RETEND_NT, a.RETSEC_NF, a.RETRTY_NF, a.RETUW_NT, 
        a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF, 0 RCL_NF, a.RETCUR_CF, a.RETAMT_M, a.PLC_NT, a.RTO_NF, 
        a.INT_NF, a.RETPAY_NF, a.RETKEY_CF, 0 RETINTAMT_M, 
        a.RETCUR_CF ESTCUR_CF, a.RETAMT_M ESTAMT_M, '' NAT_CF, 0 ACMTRS_NT, '' ESTCTR_NF, 1 ESTSEC_NF,0 LOB_CF,0 SCOEGP_M,
    '' ESTCRB_CT, '' LIFTRTTYP_CF,0 ACCADMTYP_CT, '' SECSTS_CT, 0 PRD_NF, '' SEG_NF,0 COMACC_B,0 ADJCOD_CT, '' ORICOD_CF,
    '' DETTRS_CF,'' ACCRET_B,'' ESTUWY_NF,'' LSTENDMTH_NF, '' PROPER_N,'' RTOCTY_CF,'' GAAP_NF,'' BRKSCOEGP_M, '' UWGRP_CF,'' PROPAGRES_B,1 POSTBPC_B,'' SPIMOD_CT, 0 RETAUTGEN_B, a.ACCTYP_NF, 0 ActivePlan_b
into #Plan_tlifpln
from best..tlifpln a , #Plan_PostBPC b, BREF..TBATCHSSD T
where a.SSD_CF       = b.SSD_CF
        and   convert(int,substring(convert(char(6),a.PLAN_NF),1,4))      = b.PLAN_NF
        and   convert(int,substring(convert(char(6),a.PLAN_NF),5,2)) = b.balshrmth_nf
        and   A.SSD_CF = T.SSD_CF
        and   T.BATCHUSER_CF = @suser_Name
union all
select a.SSD_CF, a.ESB_CF, isnull(substring(convert(char(6),a.PLAN_NF),1,4),convert(char(4),a.BALSHEY_NF)) BALSHEY_NF, isnull(substring(convert(char(6),a.PLAN_NF),5,2),convert(char(2),a.balshrmth_nf)) BALSHRMTH_NF, a.BALSHRDAY_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF, a.CTR_NF,
        a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF, 0 CLM_NF, a.CUR_CF, a.AMT_M, 
        a.CED_NF, a.BRK_NF, a.GEMPRMPAY_NF, a.GANPAYORD_NT, a.RETCTR_NF, a.RETEND_NT, a.RETSEC_NF, a.RETRTY_NF, a.RETUW_NT, 
        a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF, 0 RCL_NF, a.RETCUR_CF, a.RETAMT_M, a.PLC_NT, a.RTO_NF, 
        a.INT_NF, a.RETPAY_NF, a.RETKEY_CF, 0 RETINTAMT_M, 
        a.RETCUR_CF ESTCUR_CF, a.RETAMT_M ESTAMT_M, '' NAT_CF, 0 ACMTRS_NT, '' ESTCTR_NF, 1 ESTSEC_NF,0 LOB_CF,0 SCOEGP_M,
        '' ESTCRB_CT, '' LIFTRTTYP_CF,0 ACCADMTYP_CT, '' SECSTS_CT, 0 PRD_NF, '' SEG_NF,0 COMACC_B,0 ADJCOD_CT, '' ORICOD_CF,
        '' DETTRS_CF,'' ACCRET_B,'' ESTUWY_NF,'' LSTENDMTH_NF, '' PROPER_N,'' RTOCTY_CF,'' GAAP_NF,'' BRKSCOEGP_M, '' UWGRP_CF,'' PROPAGRES_B,POSTBPC_B,'' SPIMOD_CT, 0 RETAUTGEN_B, a.ACCTYP_NF, 1 ActivePlan_b
from best..tlifpln a , #Plan_Actif b, BREF..TBATCHSSD T
where a.SSD_CF       = b.SSD_CF
        and   convert(int,substring(convert(char(6),a.PLAN_NF),1,4))      = b.PLAN_NF
        and   convert(int,substring(convert(char(6),a.PLAN_NF),5,2)) = b.balshrmth_nf
        and   A.SSD_CF = T.SSD_CF
        and   T.BATCHUSER_CF = @suser_Name
        
if @@error != 0 goto fin
--[102]


-- Mise à jour des montants end fonction des devises
update #Plan_tlifpln set AMT_M = round((lif.AMT_M * cur.exc_r) / curctr.exc_r ,3), CUR_CF = curctr.cur_cf
from #Plan_tlifpln lif, bref..tcurquot cur, bref..tcurquot curctr, btrt..tsection sec
where lif.ctr_nf = sec.ctr_nf
and   lif.sec_nf = sec.sec_nf
and   lif.uwy_nf = sec.uwy_nf
and   lif.ssd_cf = cur.ssd_cf
and   lif.cur_cf = cur.cur_cf
and   cur.exc_d = (select max(exc_d) from bref..tcurquot c where c.cur_cf = lif.cur_cf
                                                         and   c.ssd_cf = lif.ssd_cf 
                                                         and   c.exc_d <= (select trimestre=case when convert(int,lif.balshrmth_nf) between 1 and 3 then convert(char(4),convert(int,lif.BALSHEY_NF) - 1)+'1231'
                                                                                                when convert(int,lif.balshrmth_nf) between 4 and 6 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0331'
                                                                                                when convert(int,lif.balshrmth_nf) between 7 and 9 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0630'
                                                                                                when convert(int,lif.balshrmth_nf) between 10 and 12 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0930'
                                                                                                else null 
                                                                                                end )
                  )
and   sec.ssd_cf = curctr.ssd_cf
and   sec.pcpcur_cf = curctr.cur_cf
and   curctr.exc_d = (select max(exc_d) from bref..tcurquot d where d.cur_cf = sec.pcpcur_cf
                                                         and   d.ssd_cf = sec.ssd_cf 
                                                         and   d.exc_d <= (select trimestre=case when convert(int,lif.balshrmth_nf) between 1 and 3 then convert(char(4),convert(int,lif.BALSHEY_NF) - 1)+'1231'
                                                                                                when convert(int,lif.balshrmth_nf) between 4 and 6 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0331'
                                                                                                when convert(int,lif.balshrmth_nf) between 7 and 9 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0630'
                                                                                                when convert(int,lif.balshrmth_nf) between 10 and 12 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0930'
                                                                                                else null 
                                                                                                end )
                  )
if @@error != 0 goto fin
                  
-- MONTANT RETRO --
update #Plan_tlifpln set RETAMT_M = round((lif.RETAMT_M * cur.exc_r) / curctr.exc_r ,3), RETCUR_CF = curctr.cur_cf
from #Plan_tlifpln lif, bref..tcurquot cur, bref..tcurquot curctr, bret..tretctr sec
where lif.retctr_nf = sec.retctr_nf
--and   lif.retsec_nf = sec.retsec_nf
and   lif.retrty_nf = sec.rty_nf
and   lif.ssd_cf = cur.ssd_cf
and   lif.retcur_cf = cur.cur_cf
and   cur.exc_d = (select max(exc_d) from bref..tcurquot c where c.cur_cf = lif.retcur_cf
                                                         and   c.ssd_cf = lif.ssd_cf 
                                                         and   c.exc_d <= (select trimestre=case when convert(int,lif.balshrmth_nf) between 1 and 3 then convert(char(4),convert(int,lif.BALSHEY_NF) - 1)+'1231'
                                                                                                when convert(int,lif.balshrmth_nf) between 4 and 6 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0331'
                                                                                                when convert(int,lif.balshrmth_nf) between 7 and 9 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0630'
                                                                                                when convert(int,lif.balshrmth_nf) between 10 and 12 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0930'
                                                                                                else null 
                                                                                                end )
                  )
and   sec.ssd_cf = curctr.ssd_cf
--and   sec.rpotry_cf = curctr.cur_cf
and   sec.retpcpcur_cf = curctr.cur_cf
and   curctr.exc_d = (select max(exc_d) from bref..tcurquot d where d.cur_cf = sec.retpcpcur_cf
                                                         and   d.ssd_cf = sec.ssd_cf 
                                                         and   d.exc_d <= (select trimestre=case when convert(int,lif.balshrmth_nf) between 1 and 3 then convert(char(4),convert(int,lif.BALSHEY_NF) - 1)+'1231'
                                                                                                when convert(int,lif.balshrmth_nf) between 4 and 6 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0331'
                                                                                                when convert(int,lif.balshrmth_nf) between 7 and 9 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0630'
                                                                                                when convert(int,lif.balshrmth_nf) between 10 and 12 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0930'
                                                                                                else null 
                                                                                                end )
                  )
if @@error != 0 goto fin

-- MONTANT EST --
update #Plan_tlifpln set ESTAMT_M = round((lif.ESTAMT_M * cur.exc_r) / curctr.exc_r ,3), ESTCUR_CF = curctr.cur_cf
from #Plan_tlifpln lif, bref..tcurquot cur, bref..tcurquot curctr, bret..tretctr sec
where lif.retctr_nf = sec.retctr_nf
and   lif.retrty_nf = sec.rty_nf
and   lif.ssd_cf = cur.ssd_cf
and   lif.estcur_cf = cur.cur_cf
and   cur.exc_d = (select max(exc_d) from bref..tcurquot c where c.cur_cf = lif.estcur_cf
                                                         and   c.ssd_cf = lif.ssd_cf 
                                                         and   c.exc_d <= (select trimestre=case when convert(int,lif.balshrmth_nf) between 1 and 3 then convert(char(4),convert(int,lif.BALSHEY_NF) - 1)+'1231'
                                                                                                when convert(int,lif.balshrmth_nf) between 4 and 6 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0331'
                                                                                                when convert(int,lif.balshrmth_nf) between 7 and 9 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0630'
                                                                                                when convert(int,lif.balshrmth_nf) between 10 and 12 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0930'
                                                                                                else null 
                                                                                                end )
                  )
and   sec.ssd_cf = curctr.ssd_cf
and   sec.retpcpcur_cf = curctr.cur_cf
and   curctr.exc_d = (select max(exc_d) from bref..tcurquot d where d.cur_cf = sec.retpcpcur_cf
                                                         and   d.ssd_cf = sec.ssd_cf 
                                                         and   d.exc_d <= (select trimestre=case when convert(int,lif.balshrmth_nf) between 1 and 3 then convert(char(4),convert(int,lif.BALSHEY_NF) - 1)+'1231'
                                                                                                when convert(int,lif.balshrmth_nf) between 4 and 6 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0331'
                                                                                                when convert(int,lif.balshrmth_nf) between 7 and 9 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0630'
                                                                                                when convert(int,lif.balshrmth_nf) between 10 and 12 then convert(char(4),convert(int,lif.BALSHEY_NF))+'0930'
                                                                                                else null 
                                                                                                end )
                  )

if @@error != 0 goto fin


select * from #Plan_tlifpln

return 0

fin:

return 1
go
EXEC sp_procxmode 'dbo.PsESTLIFPLN_01', 'unchained'
go
IF OBJECT_ID('dbo.PsESTLIFPLN_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsESTLIFPLN_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsESTLIFPLN_01 >>>'
go
GRANT EXECUTE ON dbo.PsESTLIFPLN_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsESTLIFPLN_01 TO GDBBATCH
go
