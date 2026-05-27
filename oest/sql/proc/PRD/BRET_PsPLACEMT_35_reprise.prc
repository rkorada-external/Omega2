USE BRET
go

IF OBJECT_ID('dbo.PsPLACEMT_35_reprise') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPLACEMT_35_reprise
    IF OBJECT_ID('dbo.PsPLACEMT_35_reprise') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPLACEMT_35_reprise >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPLACEMT_35_reprise >>>'
END
go

/*
 * creation de la procedure */
create procedure PsPLACEMT_35_reprise
as

/***************************************************
Programme:                  PsPLACEMT_35_reprise
Fichier script associé :    BRET_PsPLACEMT_35_reprise.prc
Domaine :                   Retro et Estimation
Base principale :           BRET
Version:                    1
Auteur:                     J.Ribot
Date de creation:           21 / 01 / 03
Description du programme:   ATTENTION, Proc utilisée par ESID2561 et ds RTCJ0501 pour extraire les placements
                            pour les affaires du perimetre retrocession.
                            On restreint la selection aux placements valides ou resilies, comptables,
                            et non historises, et non rachetes.
                            on cumule les taux sur la selection + les taux retro interne
Parametres:                 aucun
_________________
MODIFICATION :  1 --> MOD01
Auteur:         Dominique OURMIAH
Date:           20/03/2008
Version:
Description:    TRV15180  Modif group by
_________________
MODIFICATION :  [002]
Auteur:         D.GATIBELZA
Date:           28/12/2010
Version:        10.2
Description:    ESTDOM13711 Avoir dans le GLT les montants rétro interne par filiale
[003] 30/06/2011 Roger Cassis  :spot:21408  - Ajout placements historisés
*****************************************************/
declare @erreur int

CREATE TABLE #TPLACEMT (
    RETCTR_NF   URETCTR_NF  NOT NULL,
    RETSEC_NF   URETSEC_NF  NOT NULL,	-- provient de tcession
    RTY_NF      UUWY_NF     NOT NULL,
    PLC_NT      UPLC_NT         NULL,
    RTO_NF      UCLI_NF         NULL,   --[002]
    NB_LIGNE    int             NULL,   --[002]
    SSDRTO_B    bit,
    RETSIGSHA_R USHA_R          NULL,
    LOB_CF		char(2)                 -- provient de tcession
)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20001 "Erreur create table #TPLACEMT"
    return 1
end


CREATE TABLE #TPLACEMT2 (
    RETCTR_NF       URETCTR_NF  NOT NULL,
    RETSEC_NF       URETSEC_NF  NOT NULL,	-- provient de tcession
    RTY_NF          UUWY_NF     NOT NULL,
    PLC_NT          UPLC_NT         NULL,
    RTO_NF          UCLI_NF         NULL,   --[002]
    NB_LIGNE        int             NULL,   --[002]
    RETSIGSHA1_R    USHA_R          NULL,
    RETSIGSHA2_R    USHA_R          NULL,
    RETSIGSHA3_R    USHA_R          NULL
)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20003 "Erreur create table #TPLACEMT2"
    return 1
end


CREATE TABLE #TPLACEMT3 (
    RETCTR_NF       URETCTR_NF  NOT NULL,
    RETSEC_NF       URETSEC_NF  NOT NULL,	-- provient de tcession
    RTY_NF          UUWY_NF     NOT NULL,
    PLC_NT          UPLC_NT         NULL,
    RTO_NF          UCLI_NF         NULL,   --[002]
    NB_LIGNE        int             NULL,   --[002]
    RETSIGSHA1_R    USHA_R          NULL,
    RETSIGSHA2_R    USHA_R          NULL,
    RETSIGSHA3_R    USHA_R          NULL
)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20004 "Erreur create table #TPLACEMT3"
    return 1
end


create table #ListLob (
    RETCTR_NF   URETCTR_NF  NOT NULL,
    RTY_NF      UUWY_NF     NOT NULL,
    RETSEC_NF   USEC_NF     NOT NULL,
    LOB_CF      ULOB_CF     NOT NULL
)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20005 "Erreur create table #LISTLOB"
    return 1
end


-- Récup des contrats, exercices, sections et LOB
insert into #ListLob
select distinct RETCTR_NF, RTY_NF, RETSEC_NF, LOB_CF
from BRET..TRETSEC

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20007 "Erreur insert #LISTLOB"
    return 1
end

create index iListLob on #ListLob (RETCTR_NF,  RTY_NF,  RETSEC_NF, LOB_CF)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20009 "Erreur CREATE INDEX ILISTLOB"
    return 1
end


--  Recup des placements valides ou resilies et maj section et LOB
--[002] Ajout RTO_NF, NB_LIGNE
insert into #tplacemt ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, SSDRTO_B, RETSIGSHA_R, LOB_CF )
select a.RETCTR_NF,
       b.RETSEC_NF,
       a.RTY_NF,
       a.PLC_NT,
       a.RTO_NF,        --[002]
       1 "NB_LIGNE",    --[002]
       a.SSDRTO_B,
       a.RETSIGSHA_R,
       b.LOB_CF
from bret..tplacemt a, #ListLob b
where ( a.plcsts_ct=16 or a.plcsts_ct=19 )
  and a.accplc_b=1
  and a.his_b=0
  and a.retctr_nf=b.retctr_nf
  and a.rty_nf=b.rty_nf

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20011 "Erreur insert #tplacemt - 1"
    return 1
end

--[003]
insert into #TPLACEMT ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, SSDRTO_B, RETSIGSHA_R, LOB_CF )
select a.RETCTR_NF,
       b.RETSEC_NF,
       a.RTY_NF,
       a.PLC_NT,
       a.RTO_NF,        --[002]
       1 "NB_LIGNE",    --[002]
       a.SSDRTO_B,
       a.RETSIGSHA_R,
       b.LOB_CF
from bret..tplacemt a, #ListLob b
where a.his_b=0
  and a.retctr_nf=b.retctr_nf
  and a.rty_nf=b.rty_nf
  and NOT exists (select 1 from #tplacemt c
                  where a.retctr_nf = c.retctr_nf
                    and b.retsec_nf = c.retsec_nf
                    and a.rty_nf    = c.rty_nf)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20011 "Erreur insert #tplacemt - 2"
    return 1
end

-- On met à jour RETSIGSHA1_R avec le taux global placé sur plc valides ou résiliés
-- On met à jour RETSIGSHA2_R avec le taux global placé en rétro interne sur plc valides ou resiliés
--[002] Ajout RTO_NF, NB_LIGNE
insert #TPLACEMT2 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R )
select a.RETCTR_NF,
       a.RETSEC_NF,
       a.RTY_NF,
       NULL     "PLC_NT",       ----       jr 10/04/03   0,  ---PLC_NT,
       NULL     "RTO_NF",       --[002]
       NULL     "NB_LIGNE",     --[002]
       SUM(a.RETSIGSHA_R),
       SUM(case when a.SSDRTO_B = 1
                then a.RETSIGSHA_R
                else 0
           end)
from #tplacemt a
Where not exists ( select 1 from BRET..tcurcvsn b
                   where a.retctr_nf = b.retctr_nf
                     and a.rty_nf = b.rty_nf
                     and a.plc_nt = b.plc_nt )
group by RETCTR_NF, RTY_NF, RETSEC_NF
order by RETCTR_NF, RTY_NF, RETSEC_NF       

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20014 "Erreur insert #tplacemt2"
    return 1
end

-- On ajoute des lignes contenant les placements internes avec leur taux de placement
-- sur un seul placement avec des devises specifiques
--[002] Ajout RTO_NF, NB_LIGNE
insert #TPLACEMT3 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R )
select a.RETCTR_NF,
       a.RETSEC_NF,
       a.RTY_NF,
       NULL,                    ----       jr 07/05/03   0,  ---PLC_NT,
       NULL,                    --[002]
       SUM(a.NB_LIGNE),         --[002]
       SUM(a.RETSIGSHA_R),
       SUM(case when a.SSDRTO_B = 1
                then a.RETSIGSHA_R
                else 0
           end)
from #tplacemt a
Where a.SSDRTO_B = 1 and not exists ( select 1 from #tplacemt2 b
                                      where a.retctr_nf = b.retctr_nf
                                        and a.retsec_nf = b.retsec_nf
                                        and a.rty_nf    = b.rty_nf )
group by RETCTR_NF, RTY_NF, RETSEC_NF
order by RETCTR_NF, RTY_NF, RETSEC_NF

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20015 "Erreur insert2 #tplacemt2"
    return 1
end

--[002] Ajout RTO_NF
insert #TPLACEMT2 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R )
select RETCTR_NF,
       RETSEC_NF,
       RTY_NF,
       PLC_NT,
       RTO_NF,          --[002]
       NB_LIGNE,        --[002]
       RETSIGSHA1_R,
       RETSIGSHA2_R
from #TPLACEMT3

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20016 "Erreur insert #tplacemt2"
    return 1
end

-- On ajoute des lignes contenant les placements internes avec leur taux de placement
--[002]
insert #TPLACEMT2 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R )
select a.RETCTR_NF,
       a.RETSEC_NF,
       a.RTY_NF,
       a.PLC_NT,
       a.RTO_NF,        --[002]
       a.NB_LIGNE,      --[002]
       a.RETSIGSHA_R,
       a.RETSIGSHA_R
from #tplacemt a
where SSDRTO_B = 1
  and not exists ( select 1
                   from bret..tcmuplct cmu, bret..tcommut com
                   where a.retctr_nf = cmu.retctr_nf
                     and a.rty_nf    = cmu.rty_nf
                     and a.plc_nt    = cmu.plc_nt
                     and a.lob_cf    = cmu.lob_cf
                     and cmu.retctr_nf    = com.retctr_nf
                     and cmu.cmu_nt  = com.cmu_nt
                     and cmu.inicmuver_ct = 0
                     and com.cmucalsts_cf = "05"
                     and a.retctr_nf not in ('06P000101','02F000062','06P000094','06P000095','18P000033','18P000069','17T700033','17T700035','17P000119'))  -- [003]

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20017 "Erreur insert #tplacemt2"
    return 1
end

update #TPLACEMT2
   set a.RETSIGSHA1_R = b.RETSIGSHA1_R
from #TPLACEMT2 a, #TPLACEMT2 b
where a.retctr_nf = b.retctr_nf
  and a.retsec_nf = b.retsec_nf
  and a.rty_nf    = b.rty_nf
  and a.PLC_NT is not null
  and b.PLC_NT is null

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20018 "Erreur update #tplacemt2"
    return 1
end

select retctr_nf 'tmp_retctr_nf',
       retsec_nf 'tmp_retsec_nf',
       rty_nf    'tmp_rty_nf',
       count(*)  'tmp_nb_ligne'
into #tmp_TPLACEMT2
from #TPLACEMT2
group by retctr_nf, retsec_nf, rty_nf

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20018 "Erreur select into #tplacemt2"
    return 1
end

--[002]
update #TPLACEMT2
   set NB_LIGNE = b.tmp_nb_ligne
from #TPLACEMT2 a, #tmp_TPLACEMT2 b
where a.retctr_nf = b.tmp_retctr_nf
  and a.retsec_nf = b.tmp_retsec_nf
  and a.rty_nf    = b.tmp_rty_nf

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20019 "Erreur update #tplacemt2"
    return 1
end

-- Le taux RETSIGSHA3 contient la part de placements internes / part de placement total
set arithabort numeric_truncation off

update #TPLACEMT2
   set RETSIGSHA3_R = (case when RETSIGSHA2_R NOT in (0,null)
                            then convert( decimal(9,8),RETSIGSHA2_R / RETSIGSHA1_R )
                            else 0
                       end)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20020 "Erreur update #Tplacemt2"
    return 1
end

select RETCTR_NF,
       RETSEC_NF,
       RTY_NF,
       PLC_NT,
       RETSIGSHA1_R,
       RETSIGSHA2_R,
       RETSIGSHA3_R,
       RTO_NF,          --[002]
       NB_LIGNE         --[002]
from #TPLACEMT2 where ( RETSIGSHA3_R NOT in (0,null) )
order by RETCTR_NF, RTY_NF, RETSEC_NF, PLC_NT

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20022 "APPLICATIF;TPLACEMT" /* erreur de lecture */
    return @erreur
end

return 0
go

IF OBJECT_ID('dbo.PsPLACEMT_35_reprise') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPLACEMT_35_reprise >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPLACEMT_35_reprise >>>'
go

--EXEC sp_procxmode 'dbo.PsPLACEMT_35_reprise','unchained'
--gio

GRANT EXECUTE ON dbo.PsPLACEMT_35_reprise TO GOMEGA
go

