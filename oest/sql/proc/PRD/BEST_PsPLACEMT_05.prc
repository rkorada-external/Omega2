use BEST
go


/*
 * DROP PROC dbo.PsPLACEMT_05 */
IF OBJECT_ID('dbo.PsPLACEMT_05') IS NOT NULL
BEGIN
    DROP PROC dbo.PsPLACEMT_05
    PRINT '<<< DROPPED PROC dbo.PsPLACEMT_05 >>>'
END
go

/*
 * creation de la procedure */
create procedure PsPLACEMT_05

as
/***************************************************
Programme:                  PsPLACEMT_05
Domaine :                   Estimation
Base principale :           BEST
Version:                    11.1
Auteur:                     D.GATIBELZA
Date de creation:           03/05/2011
Description du programme:   ESTDOM21408 OneLedger
[001]  23/05/2011  Rogae Cassis  :spot:21408 - Ajout filtre sur his_b = 0 et his_b = 1
[002]  04/06/2012  Paul  Coppin  :spot:23839 - correction sql sur la proc permettant d'alimenter l'indicateur retro interne dans TTECLEDR
[003]  13/11/2013  P. COPPIN     :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
*****************************************************/

/*
select RETCTR_NF, RTY_NF, PLC_NT, RTO_NF, SSDRTO_B
into #temp
from BRET..TPLACEMT
group by RETCTR_NF, RTY_NF, PLC_NT
having his_b = 0
UNION
select RETCTR_NF, RTY_NF, PLC_NT, RTO_NF, SSDRTO_B
from BRET..TPLACEMT a
where not exists (select 1 from bret..tplacemt b
                  where a.retctr_nf = b.retctr_nf
                  and   a.rty_nf    = b.rty_nf
                  and   a.plc_nt    = b.plc_nt
                  and   b.his_b     = 0)                   
and  plcver_nt = (select max(plcver_nt) from bret..tplacemt b
                  where a.retctr_nf = b.retctr_nf
                  and   a.rty_nf    = b.rty_nf
                  and   a.plc_nt    = b.plc_nt
                  and   b.his_b     = 1)                   
group by RETCTR_NF, RTY_NF, PLC_NT
having his_b = 1
*/

select p.RETCTR_NF, p.RTY_NF, p.PLC_NT, p.RTO_NF, p.SSDRTO_B   -- nouveau sql [002]
into #temp
from BRET..TPLACEMT p, BREF..TBATCHSSD T1
where p.his_b = 0
and   p.ssd_cf = T1.SSD_CF
and   T1.BATCHUSER_CF = suser_name()

UNION

select a.RETCTR_NF, a.RTY_NF, a.PLC_NT, a.RTO_NF, a.SSDRTO_B
from BRET..TPLACEMT a, BREF..TBATCHSSD T2

where a.ssd_cf = T2.SSD_CF
and   T2.BATCHUSER_CF = suser_name()

and  not exists (select 1 from bret..tplacemt b, BREF..TBATCHSSD T3
                 where a.retctr_nf = b.retctr_nf
                  and   a.rty_nf    = b.rty_nf
                  and   a.plc_nt    = b.plc_nt
                  and   b.his_b     = 0
                  and   b.ssd_cf = T3.SSD_CF
                  and   T3.BATCHUSER_CF = suser_name())
                                     
and  a.plcver_nt = (select max(b.plcver_nt) from bret..tplacemt b, BREF..TBATCHSSD T4
                  where a.retctr_nf = b.retctr_nf
                  and   a.rty_nf    = b.rty_nf
                  and   a.plc_nt    = b.plc_nt
                  and   b.his_b     = 1
                  and   b.ssd_cf = T4.SSD_CF
                  and   T4.BATCHUSER_CF = suser_name())                   
and a.his_b = 1



select * from #temp
order by RETCTR_NF, RTY_NF, PLC_NT


return 0
go

IF OBJECT_ID('dbo.PsPLACEMT_05') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsPLACEMT_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsPLACEMT_05 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsPLACEMT_05 */
GRANT EXECUTE ON dbo.PsPLACEMT_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPLACEMT_05 TO GDBBATCH
go

