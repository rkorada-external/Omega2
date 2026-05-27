#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - REPORTING
# nom du script SHELL		: ESRD0001.cmd
# revision			: $Revision: 1.2 $
# date de creation		: 23/11/2000
# auteur			: HAMAÏMI J
# references des specifications	:
#-----------------------------------------------------------------------------
# description
# Generation of the TBOIBNR table
#
#
# job launched by ESRD0000.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#
#[001] 13/03/2008 J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
#[002] 21/04/2008 J. Ribot SPOT15217 ajout TEST earprmt4cns4_m != 0  (suite a plantage a New York division par zero)
#[003] 13/09/2013 Florent  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3
#---------------------------------------------------------------------------

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Determination of the TCTRSTAT TN table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TCTRSTAT', '${CLODAT_D}',
                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TCTRSTAT results is
TCTRSTAT_TN=T`cat ${ISQL_FRES} | sed -e s/\ //g`

#Variables BALSHTYEA_NF and CLODAT_D for T4
BALSHTYEAT4_NF=`expr ${BALSHTYEA_NF} - 1`
CLODATT4_D=${BALSHTYEAT4_NF}1231

#---------------------------------------------------------------------------
NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the TCTRSTAT T4 table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TCTRSTAT', '${CLODATT4_D}',
                              ${BALSHTYEAT4_NF}, 12"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TCTRSTAT results is
TCTRSTAT_T4=T`cat ${ISQL_FRES} | sed -e s/\ //g`

#---------------------------------------------------------------------------
NSTEP=${NJOB}_15
# Begin isql
#Creation de la procedure
#------------------------------------------------------------------------------
LIBEL="Creation of the procedure"
ISQL_BASE="${BASE}"
ISQL_QRY=`CFTMP`
cat > ${ISQL_QRY} << EOF

IF OBJECT_ID('PiBOIBNR_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PiBOIBNR_01
    IF OBJECT_ID('PiBOIBNR_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PiBOIBNR_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PiBOIBNR_01 >>>'
END
go

create procedure PiBOIBNR_01
	(
		@p_DerCoursExMoins1	datetime
	)
as
create table #TBOIBNR
(
    SSD_CF         USSD_CF       NOT NULL,
    SEG_NF         USEG_NF       DEFAULT '' NOT NULL,
    UWY_NF         UUWY_NF       NOT NULL,
    SSDCUR_CF      UCUR_CF       DEFAULT '' NOT NULL,
    EXCT4_D        datetime      NULL,
    EXCTN_D        datetime      NULL,
    SEGGRPL1_CT    tinyint       NULL,
    SEGGRPL1_LL    UL32          NULL,
    SEGGRPL2_CT    tinyint       NULL,
    SEGGRPL2_LL    UL32          NULL,
    UWYGRP_CT      UL16          NULL,
    IBNRT4C4S4_M   UAMT_M        DEFAULT 0 NOT NULL,
    IBNRT4CNS4_M   UAMT_M        DEFAULT 0 NOT NULL,
    IBNRTNCNS4_M   UAMT_M        DEFAULT 0 NOT NULL,
    REPCLMT4C4S4_M UAMT_M        DEFAULT 0 NOT NULL,
    REPCLMT4CNS4_M UAMT_M        DEFAULT 0 NOT NULL,
    REPCLMTNCNS4_M UAMT_M        DEFAULT 0 NOT NULL,
    LOSRATT4C4S4_R decimal(18,8) DEFAULT 0 NOT NULL,
    LOSRATT4CNS4_R decimal(18,8) DEFAULT 0 NOT NULL,
    LOSRATTNCNS4_R decimal(18,8) DEFAULT 0 NOT NULL,
    EARPRMT4C4S4_M UAMT_M        DEFAULT 0 NOT NULL,
    EARPRMT4CNS4_M UAMT_M        DEFAULT 0 NOT NULL,
    EARPRMTNCNS4_M UAMT_M        DEFAULT 0 NOT NULL
)

create table #TREGROUPT4
(
    SSD_CF          USSD_CF                not null,
    SEG_NF          USEG_NF                default '' not null,
    UWY_NF          UUWY_NF                not null,
    EGPCUR_CF       UCUR_CF                default '' not null,
    IBNR_M          UAMT_M                 default 0 not null,
    REPCLM_M        UAMT_M                 default 0 not null,
    EARPRM_M        UAMT_M                 default 0 not null
)

create table #TCTRSTAT
(
    SSD_CF           USSD_CF       NOT NULL,
    SEG_NF           USEG_NF       default '' not null,
    UWY_NF           UUWY_NF       not null,
    EGPCUR_CF        UCUR_CF       default '' not null,
    CACCPRM_M        UAMT_M        NULL,
    CACCEPP_M        UAMT_M        NULL,
    CACCRPP_M        UAMT_M        NULL,
    CACCPNA_M        UAMT_M        NULL,
    CACCSP_M         UAMT_M        NULL,
    CACCEPS_M        UAMT_M        NULL,
    CACCRPS_M        UAMT_M        NULL,
    CACCSAP_M        UAMT_M        NULL,
    CACCACR_M        UAMT_M        NULL,
    IACCPRM_M        UAMT_M        NULL,
    IACCEPP_M        UAMT_M        NULL,
    IACCRPP_M        UAMT_M        NULL,
    IACCPNA_M        UAMT_M        NULL,
    ESTPRM_M         UAMT_M        NULL,
    ESTEPP_M         UAMT_M        NULL,
    ESTRPP_M         UAMT_M        NULL,
    ESTPNA_M         UAMT_M        NULL,
    ESTIBNR2_M       UAMT_M        NULL)

create table #TREGROUPTN
(
    SSD_CF          USSD_CF                not null,
    SEG_NF          USEG_NF                default '' not null,
    UWY_NF          UUWY_NF                not null,
    EGPCUR_CF       UCUR_CF                default '' not null,
    IBNR_M          UAMT_M                 default 0 not null,
    REPCLM_M        UAMT_M                 default 0 not null,
    EARPRM_M        UAMT_M                 default 0 not null
)

create table #TBOIBNRTNCNS4
(
    SSD_CF          USSD_CF                not null,
    SEG_NF          USEG_NF                default '' not null,
    UWY_NF          UUWY_NF                not null,
    IBNRTNCNS4_M    UAMT_M                 default 0 not null,
    REPCLMTNCNS4_M  UAMT_M                 default 0 not null,
    EARPRMTNCNS4_M  UAMT_M                 default 0 not null
)

--------------------------------------------
-- Déclaration des variables
--------------------------------------------

declare @DerCoursEx datetime

select @DerCoursEx = (select max(exc_d) from bref..tcurquot)

--------------------------------------------
-- Traitement table tctrstat 4T ex - 1
--------------------------------------------

---------------------------------------------------------
-- Calcul des Ibnr, des Sinistres et des Primes acquises
---------------------------------------------------------

insert #TREGROUPT4
select  a.ssd_cf,
        actseg_nf,
        uwy_nf,
        egpcur_cf,
        sum(estibnr2_m),
        sum(caccsp_m + cacceps_m + caccrps_m + caccsap_m + caccacr_m),
        sum(caccprm_m + caccepp_m + caccrpp_m + caccpna_m + iaccprm_m + iaccepp_m +
            iaccrpp_m + iaccpna_m + estprm_m + estepp_m + estrpp_m + estpna_m)
from ${TCTRSTAT_T4} a, BREF..TBATCHSSD b
where ctrret_b != 1
 and a.SSD_CF=b.SSD_CF
 and b.BATCHUSER_CF=suser_name()
group by    a.ssd_cf,
            actseg_nf,
            uwy_nf,
            egpcur_cf
order by    a.ssd_cf,
            actseg_nf,
            uwy_nf,
            egpcur_cf

if @@error != 0
	begin
		raiserror 20001, 'Erreur insert dans #TREGROUPT4'
		goto fin
	end

------------------------------------------------
-- Conversion au dernier cours connu ex - 1
------------------------------------------------

set arithabort numeric_truncation off

insert #TBOIBNR
    (   SSD_CF,
        SEG_NF,
        UWY_NF,
        IBNRT4C4S4_M,
        REPCLMT4C4S4_M,
        EARPRMT4C4S4_M,
        IBNRT4CNS4_M,
        REPCLMT4CNS4_M,
        EARPRMT4CNS4_M)
select  a.ssd_cf,
        a.seg_nf,
        a.uwy_nf,
        sum(ibnr_m * exmoins1.exc_r),
        sum(repclm_m * exmoins1.exc_r),
        sum(earprm_m * exmoins1.exc_r),
        sum(ibnr_m * ex.exc_r),
        sum(repclm_m * ex.exc_r),
        sum(earprm_m * ex.exc_r)
from #tregroupt4 a, bref..tcurquot exmoins1, bref..tcurquot ex
where a.ssd_cf = exmoins1.ssd_cf
and a.egpcur_cf = exmoins1.cur_cf
and exmoins1.exc_d = @p_DerCoursExMoins1
and a.ssd_cf = ex.ssd_cf
and a.egpcur_cf = ex.cur_cf
and ex.exc_d = @DerCoursEx
group by    a.ssd_cf,
            a.seg_nf,
            a.uwy_nf
order by    a.ssd_cf,
            a.seg_nf,
            a.uwy_nf

if @@error != 0
	begin
		raiserror 20005, 'Erreur insert dans #TBOIBNR'
		goto fin
	end

--------------------------------------------------------------------
-- Calcul des Loss ratio S/P = (Sinistres + Ibnr)/Primes acquises
--------------------------------------------------------------------

update #tboibnr
set losratt4c4s4_r = (repclmt4c4s4_m + ibnrt4c4s4_m) / earprmt4c4s4_m,
    losratt4cns4_r = (repclmt4cns4_m + ibnrt4cns4_m) / earprmt4cns4_m
from #tboibnr
where earprmt4c4s4_m != 0 AND earprmt4cns4_m != 0

if @@error != 0
	begin
		raiserror 20010, 'Erreur update dans #TBOIBNR'
		goto fin
	end

-- SPOT  15217 JR 21 04 2008 --
-- where earprmt4c4s4_m != 0 --

set arithabort numeric_truncation on

----------------------------------------------------
-- Traitement table tctrstat T courant ex en cours
----------------------------------------------------

----------------------------------------------
-- Recherche par contrat du segment précédent
-- et des nouveaux segments de la table
-- tctrstat T courant ex en cours
-- par rapport à la table tctrstat 4T ex - 1
----------------------------------------------

insert into #tctrstat
select  TN.SSD_CF,
        case
            when T4.ACTSEG_NF is not null
                then T4.ACTSEG_NF
                else 'NEW'
            end,
        TN.UWY_NF,
        TN.EGPCUR_CF,
        TN.CACCPRM_M,
        TN.CACCEPP_M,
        TN.CACCRPP_M,
        TN.CACCPNA_M,
        TN.CACCSP_M,
        TN.CACCEPS_M,
        TN.CACCRPS_M,
        TN.CACCSAP_M,
        TN.CACCACR_M,
        TN.IACCPRM_M,
        TN.IACCEPP_M,
        TN.IACCRPP_M,
        TN.IACCPNA_M,
        TN.ESTPRM_M,
        TN.ESTEPP_M,
        TN.ESTRPP_M,
        TN.ESTPNA_M,
        TN.ESTIBNR2_M
from ${TCTRSTAT_TN} TN, ${TCTRSTAT_T4} T4, BREF..TBATCHSSD b
where TN.SSD_CF=b.SSD_CF
and b.BATCHUSER_CF=suser_name()
and TN.ctr_nf *= T4.ctr_nf
and TN.end_nt *= T4.end_nt
and TN.sec_nf *= T4.sec_nf
and TN.uwy_nf *= T4.uwy_nf
and TN.uw_nt *= T4.uw_nt
and TN.ctrret_b != 1

if @@error != 0
	begin
		raiserror 20015, 'Erreur insert dans #TCTRSTAT'
		goto fin
	end

---------------------------------------------------------
-- Calcul des Ibnr, des Sinistres et des Primes acquises
---------------------------------------------------------

insert #TREGROUPTN
select  ssd_cf,
        seg_nf,
        uwy_nf,
        egpcur_cf,
        sum(estibnr2_m),
        sum(caccsp_m + cacceps_m + caccrps_m + caccsap_m + caccacr_m),
        sum(caccprm_m + caccepp_m + caccrpp_m + caccpna_m + iaccprm_m + iaccepp_m +
            iaccrpp_m + iaccpna_m + estprm_m + estepp_m + estrpp_m + estpna_m)
from #tctrstat
group by    ssd_cf,
            seg_nf,
            uwy_nf,
            egpcur_cf
order by    ssd_cf,
            seg_nf,
            uwy_nf,
            egpcur_cf

if @@error != 0
	begin
		raiserror 20020, 'Erreur insert dans #TREGROUPTN'
		goto fin
	end

------------------------------------------------
-- Conversion au dernier cours connu ex
-- et maj tboibnr des montants correspondants
------------------------------------------------

set arithabort numeric_truncation off

insert #TBOIBNRTNCNS4
select  a.ssd_cf,
        a.seg_nf,
        a.uwy_nf,
        sum(ibnr_m * exc_r),
        sum(repclm_m * exc_r),
        sum(earprm_m * exc_r)
from #tregrouptn a, bref..tcurquot b
where a.ssd_cf = b.ssd_cf
and a.egpcur_cf = b.cur_cf
and b.exc_d = @DerCoursEx
group by    a.ssd_cf,
            a.seg_nf,
            a.uwy_nf
order by    a.ssd_cf,
            a.seg_nf,
            a.uwy_nf

if @@error != 0
	begin
		raiserror 20025, 'Erreur insert dans #TBOIBNRTNCNS4'
		goto fin
	end

update #tboibnr
    set a.IBNRTNCNS4_M = b.IBNRTNCNS4_M,
        a.REPCLMTNCNS4_M = b.REPCLMTNCNS4_M,
        a.EARPRMTNCNS4_M = b.EARPRMTNCNS4_M
from #TBOIBNR a, #TBOIBNRTNCNS4 b
where   a.ssd_cf = b.ssd_cf
and     a.seg_nf = b.seg_nf
and     a.uwy_nf = b.uwy_nf

if @@error != 0
	begin
		raiserror 20030, 'Erreur update dans #TBOIBNR'
		goto fin
	end

------------------------------------------------
-- Insertion des nouveaux segments dans tboibnr
------------------------------------------------

insert #tboibnr
(       SSD_CF,
        SEG_NF,
        UWY_NF,
        IBNRTNCNS4_M,
        REPCLMTNCNS4_M,
        EARPRMTNCNS4_M)
select  ssd_cf,
        seg_nf,
        uwy_nf,
        ibnrtncns4_m,
        repclmtncns4_m,
        earprmtncns4_m
from #TBOIBNRTNCNS4
where seg_nf = 'NEW'

if @@error != 0
	begin
		raiserror 20035, 'Erreur insert dans #TBOIBNR'
		goto fin
	end

--------------------------------------------------------------------
-- Calcul des Loss ratio S/P = (Sinistres + Ibnr)/Primes acquises
--------------------------------------------------------------------

update #tboibnr
set losrattncns4_r = (repclmtncns4_m + ibnrtncns4_m) / earprmtncns4_m
from #tboibnr
where earprmtncns4_m != 0

if @@error != 0
	begin
		raiserror 20040, 'Erreur update dans #TBOIBNR'
		goto fin
	end

set arithabort numeric_truncation on

------------------------------------------------
-- Maj Devise filiale, Dates de cours de change
------------------------------------------------

update #tboibnr
set a.ssdcur_cf = b.ssdcur_cf,
    a.exct4_d  = @p_DerCoursExMoins1,
    a.exctn_d   = @DerCoursEx
from #tboibnr a, bref..tsubsid b
where a.ssd_cf = b.ssd_cf

if @@error != 0
	begin
		raiserror 20045, 'Erreur update dans #TBOIBNR'
		goto fin
	end

---------------------------------------------
-- Maj Regroupement de segments (niveau 1)
---------------------------------------------

update #tboibnr
set seggrpl1_ct = 1,
    seggrpl1_ll = 'Main Prop'
from #tboibnr
where seg_nf like 'MP%'

if @@error != 0
	begin
		raiserror 20050, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl1_ct = 2,
    seggrpl1_ll = 'Main Non Prop'
from #tboibnr
where seg_nf like 'MN%'

if @@error != 0
	begin
		raiserror 20055, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl1_ct = 3,
    seggrpl1_ll = 'Main Fac'
from #tboibnr
where seg_nf like 'MF%'

if @@error != 0
	begin
		raiserror 20060, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl1_ct = 4,
    seggrpl1_ll = 'Non Main'
from #tboibnr
where seg_nf not like 'M%'

if @@error != 0
	begin
		raiserror 20065, 'Erreur update dans #TBOIBNR'
		goto fin
	end

---------------------------------------------
-- Maj Regroupement de segments (niveau 2)
---------------------------------------------

update #tboibnr
set seggrpl2_ct = 1,
    seggrpl2_ll = 'Auto'
from #tboibnr
where seg_nf like 'M_A%'

if @@error != 0
	begin
		raiserror 20070, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 2,
    seggrpl2_ll = 'Casualty'
from #tboibnr
where seg_nf like 'M_C%'

if @@error != 0
	begin
		raiserror 20075, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 3,
    seggrpl2_ll = 'Personal insurance'
from #tboibnr
where seg_nf like 'M_I%'

if @@error != 0
	begin
		raiserror 20080, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 4,
    seggrpl2_ll = 'Marine'
from #tboibnr
where seg_nf like 'M_M%'

if @@error != 0
	begin
		raiserror 20085, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 5,
    seggrpl2_ll = 'Surety'
from #tboibnr
where seg_nf like 'M_S%'

if @@error != 0
	begin
		raiserror 20090, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 6,
    seggrpl2_ll = 'Property engineering'
from #tboibnr
where seg_nf like 'M_PE%'

if @@error != 0
	begin
		raiserror 20095, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 7,
    seggrpl2_ll = 'Property nuclear risks'
from #tboibnr
where seg_nf like 'M_PN%'

if @@error != 0
	begin
		raiserror 20100, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 8,
    seggrpl2_ll = 'Property decennial'
from #tboibnr
where seg_nf like 'M_PD%'

if @@error != 0
	begin
		raiserror 20105, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 9,
    seggrpl2_ll = 'Property'
from #tboibnr
where seg_nf like 'M_P%'
and seggrpl2_ct = null

if @@error != 0
	begin
		raiserror 20110, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 10,
    seggrpl2_ll = 'Main other'
from #tboibnr
where seg_nf like 'M%'
and seggrpl2_ct = null

if @@error != 0
	begin
		raiserror 20115, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 11,
    seggrpl2_ll = 'Transfert'
from #tboibnr
where seg_nf like 'I%'
or seg_nf like 'O%'

if @@error != 0
	begin
		raiserror 20120, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 12,
    seggrpl2_ll = 'Run off'
from #tboibnr
where seg_nf like 'R%'

if @@error != 0
	begin
		raiserror 20125, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 13,
    seggrpl2_ll = 'Direct'
from #tboibnr
where seg_nf like 'D%'

if @@error != 0
	begin
		raiserror 20130, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 14,
    seggrpl2_ll = 'Balai'
from #tboibnr
where seg_nf like 'SBALAI%'

if @@error != 0
	begin
		raiserror 20135, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 15,
    seggrpl2_ll = 'Special'
from #tboibnr
where seg_nf like 'S%'
and seg_nf not like 'SBALAI%'

if @@error != 0
	begin
		raiserror 20140, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set seggrpl2_ct = 16,
    seggrpl2_ll = 'Other'
from #tboibnr
where seggrpl2_ct = null

if @@error != 0
	begin
		raiserror 20145, 'Erreur update dans #TBOIBNR'
		goto fin
	end

---------------------------------------------
-- Maj Regroupement Ex
---------------------------------------------

update #tboibnr
set uwygrp_ct = '(' + convert(char(4),uwy_nf) + ')'
from #tboibnr
where uwy_nf = datepart(year,getdate())

if @@error != 0
	begin
		raiserror 20150, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set uwygrp_ct = '(' + convert(char(4),(datepart(year,getdate()) - 1)) + '-' +
                    convert(char(4),(datepart(year,getdate()) - 5)) + ')'
from #tboibnr
where uwy_nf between (datepart(year,getdate()) - 5) and (datepart(year,getdate()) - 1)

if @@error != 0
	begin
		raiserror 20155, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set uwygrp_ct = '(' + convert(char(4),(datepart(year,getdate()) - 6)) + '-' +
                    convert(char(4),(datepart(year,getdate()) - 15)) + ')'
from #tboibnr
where uwy_nf between (datepart(year,getdate()) - 15) and (datepart(year,getdate()) - 6)

if @@error != 0
	begin
		raiserror 20160, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set uwygrp_ct = '(' + convert(char(4),(datepart(year,getdate()) - 16)) + '-' +
                    convert(char(4),(datepart(year,getdate()) - 25)) + ')'
from #tboibnr
where uwy_nf between (datepart(year,getdate()) - 25) and (datepart(year,getdate()) - 16)

if @@error != 0
	begin
		raiserror 20165, 'Erreur update dans #TBOIBNR'
		goto fin
	end

update #tboibnr
set uwygrp_ct = '(' + convert(char(4),(datepart(year,getdate()) - 26)) + ' et ante)'
from #tboibnr
where uwy_nf <= (datepart(year,getdate()) - 26)

if @@error != 0
	begin
		raiserror 20170, 'Erreur update dans #TBOIBNR'
		goto fin
	end

---------------------------------------------
-- Alimentation TBOIBNR
---------------------------------------------

begin tran

insert TBOIBNR
select  SSD_CF,
        SEG_NF,
        UWY_NF,
        SSDCUR_CF,
        EXCT4_D,
        EXCTN_D,
        SEGGRPL1_CT,
        SEGGRPL1_LL,
        SEGGRPL2_CT,
        SEGGRPL2_LL,
        UWYGRP_CT,
        IBNRT4C4S4_M,
        IBNRT4CNS4_M,
        IBNRTNCNS4_M,
        REPCLMT4C4S4_M,
        REPCLMT4CNS4_M,
        REPCLMTNCNS4_M,
        LOSRATT4C4S4_R,
        LOSRATT4CNS4_R,
        LOSRATTNCNS4_R,
        EARPRMT4C4S4_M,
        EARPRMT4CNS4_M,
        EARPRMTNCNS4_M
from #tboibnr

declare @nblignes	int,
	@erreur		int

select @erreur = @@error, @nblignes = @@rowcount

if @erreur != 0
	begin
		raiserror 20175, 'Erreur insert dans TBOIBNR'
		goto fin
	end

print "Nb de lignes inserees dans tboibnr %1!",@nblignes

commit tran

return 0
fin:
    return 1
go

GRANT EXECUTE ON PiBOIBNR_01 TO GOMEGA
go
IF OBJECT_ID('PiBOIBNR_01') IS NOT NULL
    PRINT '<<< CREATED PROC PiBOIBNR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PiBOIBNR_01 >>>'
go

exit
EOF

ISQL

#---------------------------------------------------------------------------
NSTEP=${NJOB}_20
# Begin isql
#---------------------------------------------------------------------------
LIBEL="Truncate table TBOIBNR"
ISQL_BASE="${BASE}"
ISQL_QRY="delete TBOIBNR from TBOIBNR a, BREF..TBATCHSSD b where a.SSD_CF=b.SSD_CF and b.BATCHUSER_CF=suser_name()"
ISQL

#---------------------------------------------------------------------------
NSTEP=${NJOB}_25
# Begin isql
#---------------------------------------------------------------------------
LIBEL="Insert in the TBOIBNR table"
ISQL_BASE="${BASE}"
ISQL_QRY="execute PiBOIBNR_01 '${CLODATT4_D}'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL
APPEND_LOG ${DFILT}/${NJOB}_25_${IB}_ISQL_O.dat


#---------------------------------------------------------------------------
NSTEP=${NJOB}_30
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Drop de la procedure"
ISQL_BASE="${BASE}"
ISQL_QRY=`CFTMP`
INPUT_TEXT ${ISQL_QRY} << EOF

IF OBJECT_ID('PiBOIBNR_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PiBOIBNR_01
    IF OBJECT_ID('PiBOIBNR_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PiBOIBNR_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PiBOIBNR_01 >>>'
END
go
exit
EOF
ISQL

#---------------------------------------------------------------------------
NSTEP=${NJOB}_35
# Begin rm
#---------------------------------------------------------------------------
LIBEL="Remove the temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


# End of the Job
JOBEND
