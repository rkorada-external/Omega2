USE BRET
go
if object_id('PsRET_TRREPLINK_01') is not null
begin
  drop procedure PsRET_TRREPLINK_01
  if object_id('PsRET_TRREPLINK_01') is not null
      print '<<< FAILED DROPPING procedure PsRET_TRREPLINK_01 >>>'
  else
      print '<<< DROPPED procedure PsRET_TRREPLINK_01 >>>'
end
go
create procedure PsRET_TRREPLINK_01
  (
  @cre_d datetime,
  @balshtyea varchar(4),
  @clodat datetime
  )
with execute as caller as
/*****
Programme: PsRET_TRREPLINK_01


Domaine : (Estimation)
Base principale : BTRT
Version: 1
Auteur: S.Behague
Date de creation:11/04/2024
Description du programme:

      Proc appelee par le ESIJ0820

Parametres:
Conditions d'execution:
Commentaires:
Auteur          | Date        | Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
S.Behague   		| 11/04/2024  | Creation
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 11-04-2024 MOD[001] - S.Behague - 110557 - L&H - Automate treaty update (NTAP)
-- 24-07-2024 MOD[002] - S.Behague - 111967 - NTAP- No update when source contract is changed
-- 22-08-2024 MOD[003] - S.Behague - 112025 - Scope of NRT Automation process
-- 23-08-2024 MOD[003] - S.Behague - 112029 - NTAP rule if multiple replaced treaties exist
-- 30-08_2024 MOD[003] - S.Behague - 112017 - Renewed T2ST contracts exclusion from NTAP automation
-- 05-09_2024 MOD[004] - S.Behague - 111937 - NTAP - Retro undue update on contract not eligible for the norm
-- 25-09_2024 MOD[004] - S.Behague - 112207 - NTAP - Source contract UWY management
-- 25-10_2024 MOD[004] - S.Behague - 112344 - NTAP- I17G booked and I17L only taken for NTAP
-- 12-11_2024 MOD[006] - S.Behague - 112344 - NTAP- I17G booked and I17L only taken for NTAP - Ajout correction sur traités LT
-- 21-01_2025 MOD[007] - S.Behague - 112620 - NTAP process not picking candidates Q125
******************************************************************************************************/
declare @IsSameFrom int

select @IsSameFrom = 0

SELECT TOP 1 * INTO #tmp_scope_rreplink FROM BTRAV..SCOPE_TRREPLINK
DELETE FROM #tmp_scope_rreplink

-- MOD[007] Spira 112620--
UPDATE BTRAV..SCOPE_TRREPLINK
SET 
ISVALIDI17G_B = 0,
ISVALIDI17P_B = 0,
ISVALIDI17L_B = 0
WHERE CLODAT_D < @clodat
AND ISTREATED_B = 0
AND ( ISVALIDI17G_B = 1 OR ISVALIDI17P_B = 1 OR ISVALIDI17L_B = 1 )


-- ETAPE INITIALE : SELECTION des dernières postions pour CTR_NF, SEC_NF, UWY_NF de la partie TO
select link.RETCTR_NF,
       link.RTY_NF,
       link.cre_d
into   #tmprreplink
from   bret..TRREPLINK link
group by link.RETCTR_NF, link.RTY_NF
having cre_d = max(cre_d)

select RETCTR_NF, RTY_NF, CRE_D, count(*) nb_lignes
into   #tmprreplinkcount
from   #tmprreplink group by RETCTR_NF, RTY_NF, CRE_D


-- 1ERE ETAPE : SELECTION - LOB 30/31
INSERT INTO #tmp_scope_rreplink (TORETCTR_NF, TORTY_NF, FROMRETCTR_NF, FROMRTY_NF, TOLOB_CF, TOSECSTS_CT, INPUT_D, LSTUPD_D, CLODAT_D, TOSSD_CF, TOESB_CF, ISVALIDI17G_B, ISVALIDI17P_B, ISVALIDI17L_B, ISTREATED_B, ISUPDATEFAILED_B, TMP_I17G, TMP_I17P, TMP_I17L, RETACCTYP_CT, USGAAP_CT, FRSRTY_NF)
SELECT distinct link.RETCTR_NF,
       link.RTY_NF,
       link.REPRETCTR_NF,
       link.REPRTY_NF,
       section.LOB_CF,
       contr.RETCTRSTS_CT,
       link.CRE_D,
       @cre_d,
       @clodat,
       section.SSD_CF,
       contr.ESB_CF,
       1,
       1,
       1,
       0,
       0,
       0,
       0,
       0,
       contr.RETACCTYP_CT,
       section.USGAAP_CT,
       1901
FROM   BRET..TRREPLINK link, 
       BRET..TRETSEC section,
       BRET..TRETCTR contr,
       #tmprreplinkcount tmp
WHERE  link.RETCTR_NF = section.RETCTR_NF AND link.RTY_NF = section.RTY_NF
AND    link.RETCTR_NF = contr.RETCTR_NF  AND link.RTY_NF = contr.RTY_NF
AND    link.RETCTR_NF = tmp.RETCTR_NF AND link.RTY_NF = tmp.RTY_NF AND  link.cre_d = tmp.cre_d AND tmp.nb_lignes = 1
AND    section.LOB_CF in ('30','31')
AND    (section.assfinance_ct <> 2 OR section.assfinance_ct is null )
and    section.SSD_CF <> 26
and    (contr.estcrb_ct <> 'D' and contr.estcrb_ct <> 'R' and contr.estcrb_ct <> 'S' or contr.estcrb_ct is null)
AND    exists(select 1 from BREF..TBATCHSSD c where section.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())

-- Insertion des lignes pour lesquelles le contrat cible a plusieurs sources à la même date
-- Permet de tracer le cas en erreur
INSERT INTO #tmp_scope_rreplink (TORETCTR_NF, TORTY_NF, FROMRETCTR_NF, FROMRTY_NF, TOLOB_CF, TOSECSTS_CT, INPUT_D, LSTUPD_D, CLODAT_D, TOSSD_CF, TOESB_CF, ISVALIDI17G_B, ISVALIDI17P_B, ISVALIDI17L_B, ISTREATED_B, ISUPDATEFAILED_B, TMP_I17G, TMP_I17P, TMP_I17L, RETACCTYP_CT, USGAAP_CT, FRSRTY_NF, LIBELLE_LL)
SELECT distinct link.RETCTR_NF,
       link.RTY_NF,
       link.REPRETCTR_NF,
       link.REPRTY_NF,
       section.LOB_CF,
       contr.RETCTRSTS_CT,
       link.CRE_D,
       @cre_d,
       @clodat,
       section.SSD_CF,
       contr.ESB_CF,
       0,
       0,
       0,
       0,
       0,
       0,
       0,
       0,
       contr.RETACCTYP_CT,
       section.USGAAP_CT,
       1901,
       'ERROR - more than 1 from contract '
FROM   BRET..TRREPLINK link, 
       BRET..TRETSEC section,
       BRET..TRETCTR contr,
       #tmprreplinkcount tmp
WHERE  link.RETCTR_NF = section.RETCTR_NF AND link.RTY_NF = section.RTY_NF
AND    link.RETCTR_NF = contr.RETCTR_NF  AND link.RTY_NF = contr.RTY_NF
AND    link.RETCTR_NF = tmp.RETCTR_NF AND link.RTY_NF = tmp.RTY_NF AND  link.cre_d = tmp.cre_d AND tmp.nb_lignes > 1
AND    section.LOB_CF in ('30','31')
AND    (section.assfinance_ct <> 2 OR section.assfinance_ct is null )
and    section.SSD_CF <> 26
and    (contr.estcrb_ct <> 'D' and contr.estcrb_ct <> 'R' and contr.estcrb_ct <> 'S' or contr.estcrb_ct is null)
AND    exists(select 1 from BREF..TBATCHSSD c where section.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())


-----------------------------------------------------------------------------------
-- 1ERE ETAPE BIS : Conditions on T2ST contratsc -- spira  112017
-----------------------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||'T2ST Contract Error'
WHERE 
       RETACCTYP_CT = 2 AND USGAAP_CT IN (2,3)
AND    (TORTY_NF <> FROMRTY_NF) -- OR TORTY_NF <> FRSRTY_NF)
AND    ISTREATED_B = 0

-- Sélection first rty
select ctr.retctr_nf, min(ctr.rty_nf) frsrty_nf into #tmp_fstrty 
from   bret..tretctr ctr, #tmp_scope_rreplink tmp
where  ctr.retctr_nf = tmp.toretctr_nf
group by ctr.retctr_nf

update #tmp_scope_rreplink set FRSRTY_NF = tmp.frsrty_nf
from   #tmp_scope_rreplink ctr, #tmp_fstrty tmp
where  ctr.toretctr_nf = tmp.retctr_nf
-- Fin Sélection first rty

UPDATE #tmp_scope_rreplink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||'Long Term Contract Error'
WHERE 
       RETACCTYP_CT = 2 AND USGAAP_CT = 1
AND    TOSSD_CF = 20 AND TOESB_CF = 6
AND    (TORTY_NF <> FROMRTY_NF OR TORTY_NF <> FRSRTY_NF)
AND    ISTREATED_B = 0

UPDATE #tmp_scope_rreplink
SET    ISVALIDI17P_B = 0,
       LIBELLE_LL = LIBELLE_LL||'Long Term Contract Error for I17P'
WHERE 
       RETACCTYP_CT = 2 AND USGAAP_CT = 1
AND    TOSSD_CF = 20 AND TOESB_CF = 6

---------------------------------------------------------------------
-- 2EME ETAPE : Fill LOB_CF, SECSTS_CT, SSD_CF, ESB_CF for FROM part
---------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    FROMSECSTS_CT = retctr.RETCTRSTS_CT,
       FROMLOB_CF = section.LOB_CF,
       FROMSSD_CF = section.SSD_CF,
       FROMESB_CF = retctr.ESB_CF
FROM   #tmp_scope_rreplink link, BRET..TRETCTR retctr, BRET..TRETSEC section
WHERE  link.FROMRETCTR_NF = retctr.RETCTR_NF AND link.FROMRTY_NF = retctr.RTY_NF
AND    link.FROMRETCTR_NF = section.RETCTR_NF
AND    link.ISTREATED_B = 0


---------------------------------------------------------------------
-- 3EME ETAPE : Fill inception status for FROM part
---------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    FROMGRPIFRSSEG_CT   =  GRPIFRSSEG_CT,
       FROMGRPIFRSSEG_LL   =  GRPIFRSSEG_LL,
       FROMPARIFRSSEG_CT   =  PARIFRSSEG_CT,
       FROMPARIFRSSEG_LL   =  PARIFRSSEG_LL,
       FROMLOCIFRSSEG_CT   =  LOCIFRSSEG_CT,
       FROMLOCIFRSSEG_LL   =  LOCIFRSSEG_LL,
       FROMGRPIFRSSEG1_CT  =  GRPIFRSSEG1_CT,
       FROMGRPIFRSSEG1_LL  =  GRPIFRSSEG1_LL,
       FROMPARIFRSSEG1_CT  =  PARIFRSSEG1_CT,
       FROMPARIFRSSEG1_LL  =  PARIFRSSEG1_LL,
       FROMLOCIFRSSEG1_CT  =  LOCIFRSSEG1_CT,
       FROMLOCIFRSSEG1_LL  =  LOCIFRSSEG1_LL,
       FROMGRPINIPRO_CF    =  GRPINIPRO_CF,
       FROMPARINIPRO_CF    =  PARINIPRO_CF,
       FROMLOCINIPRO_CF    =  LOCINIPRO_CF,
       FROMGRPIFRSTRA_CT   =  GRPIFRSTRA_CT,
       FROMPARIFRSTRA_CT   =  PARIFRSTRA_CT,
       FROMLOCIFRSTRA_CT   =  LOCIFRSTRA_CT,
       FROMGRPINISTS_CT    =  GRPINISTS_CT,
       FROMPARINISTS_CT    =  PARINISTS_CT,
       FROMLOCINISTS_CT    =  LOCINISTS_CT,
       FROMGRPFSTCLO_D     =  GRPFSTCLO_D,
       FROMPARFSTCLO_D     =  PARFSTCLO_D,
       FROMLCLFSTCLO_D     =  LCLFSTCLO_D,
       FROMGRPRATEINDEX_CT =  GRPRATEINDEX_CT,
       FROMPARRATEINDEX_CT =  PARRATEINDEX_CT,
       FROMLCLRATEINDEX_CT =  LCLRATEINDEX_CT,
       FROMGRPANCO_NF      =  GRPANCO_NF,
       FROMPARANCO_NF      =  PARANCO_NF,
       FROMLOCANCO_NF      =  LOCANCO_NF,
       FROMRETRECOD_D      =  RETRECOD_D
FROM   #tmp_scope_rreplink link, BRET..TRETIFRS secifrs
WHERE  link.FROMRETCTR_NF = secifrs.RETCTR_NF AND link.FROMRTY_NF = secifrs.RTY_NF
AND    link.ISTREATED_B = 0


---------------------------------------------------------------------
-- 4EME ETAPE : Fill inception status for TO part
---------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    TOGRPIFRSSEG_CT   =  GRPIFRSSEG_CT,
       TOGRPIFRSSEG_LL   =  GRPIFRSSEG_LL,
       TOPARIFRSSEG_CT   =  PARIFRSSEG_CT,
       TOPARIFRSSEG_LL   =  PARIFRSSEG_LL,
       TOLOCIFRSSEG_CT   =  LOCIFRSSEG_CT,
       TOLOCIFRSSEG_LL   =  LOCIFRSSEG_LL,
       TOGRPIFRSSEG1_CT  =  GRPIFRSSEG1_CT,
       TOGRPIFRSSEG1_LL  =  GRPIFRSSEG1_LL,
       TOPARIFRSSEG1_CT  =  PARIFRSSEG1_CT,
       TOPARIFRSSEG1_LL  =  PARIFRSSEG1_LL,
       TOLOCIFRSSEG1_CT  =  LOCIFRSSEG1_CT,
       TOLOCIFRSSEG1_LL  =  LOCIFRSSEG1_LL,
       TOGRPINIPRO_CF    =  GRPINIPRO_CF,
       TOPARINIPRO_CF    =  PARINIPRO_CF,
       TOLOCINIPRO_CF    =  LOCINIPRO_CF,
       TOGRPIFRSTRA_CT   =  GRPIFRSTRA_CT,
       TOPARIFRSTRA_CT   =  PARIFRSTRA_CT,
       TOLOCIFRSTRA_CT   =  LOCIFRSTRA_CT,
       TOGRPINISTS_CT    =  GRPINISTS_CT,
       TOPARINISTS_CT    =  PARINISTS_CT,
       TOLOCINISTS_CT    =  LOCINISTS_CT,
       TOGRPFSTCLO_D     =  GRPFSTCLO_D,
       TOPARFSTCLO_D     =  PARFSTCLO_D,
       TOLCLFSTCLO_D     =  LCLFSTCLO_D,
       TOGRPRATEINDEX_CT =  GRPRATEINDEX_CT,
       TOPARRATEINDEX_CT =  PARRATEINDEX_CT,
       TOLCLRATEINDEX_CT =  LCLRATEINDEX_CT,
       TOGRPANCO_NF      =  GRPANCO_NF,
       TOPARANCO_NF      =  PARANCO_NF,
       TOLOCANCO_NF      =  LOCANCO_NF,
       TORETRECOD_D      =  RETRECOD_D
FROM   #tmp_scope_rreplink link, BRET..TRETIFRS secifrs
WHERE  link.TORETCTR_NF = secifrs.RETCTR_NF AND link.TORTY_NF = secifrs.RTY_NF
AND    link.ISTREATED_B = 0


---------------------------------------------------------------------
-- 5EME ETAPE : Check SSD / ESB
---------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / Problem SSD/ESB'
WHERE  (TOSSD_CF <> FROMSSD_CF 
OR      TOESB_CF <> FROMESB_CF)
AND    ISTREATED_B = 0

---------------------------------------------------------------------
-- 6EME ETAPE STEP 01 : Check if TO part is already existing in BTRAV..SCOPE_TREPLINK and TOGRPINISTS_CT = 2
--                      To do it, we're filling TMP_I17G/P/L status with 1 
---------------------------------------------------------------------
update #tmp_scope_rreplink 
set    TMP_I17G = 1 
from   #tmp_scope_rreplink t, BTRAV..SCOPE_TRREPLINK l
where  t.toretctr_nf = l.toretctr_nf
and    t.torty_nf = l.torty_nf
and    ( t.fromrty_nf <> l.fromrty_nf or t.fromretctr_nf <> l.fromretctr_nf )
and    l.ISTREATED_B = 1
and    t.TOGRPINISTS_CT = 2

update #tmp_scope_rreplink 
set    TMP_I17P = 1 
from   #tmp_scope_rreplink t, BTRAV..SCOPE_TRREPLINK l
where  t.toretctr_nf = l.toretctr_nf
and    t.torty_nf = l.torty_nf
and    ( t.fromrty_nf <> l.fromrty_nf or t.fromretctr_nf <> l.fromretctr_nf )
and    l.ISTREATED_B = 1
and    t.TOPARINISTS_CT = 2

update #tmp_scope_rreplink 
set    TMP_I17L = 1 
from   #tmp_scope_rreplink t, BTRAV..SCOPE_TRREPLINK l
where  t.toretctr_nf = l.toretctr_nf
and    t.torty_nf = l.torty_nf
and    ( t.fromrty_nf <> l.fromrty_nf or t.fromretctr_nf <> l.fromretctr_nf )
and    l.ISTREATED_B = 1
and    t.TOLOCINISTS_CT = 2

---------------------------------------------------------------------
-- 6EME ETAPE : Check for inception status for TO PART
---------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    ISVALIDI17G_B = 0, 
       LIBELLE_LL = LIBELLE_LL||' / TORETCTR:Incorrect I17G status'
WHERE  TOGRPINISTS_CT is NOT null AND TOGRPINISTS_CT <> 1 AND TOGRPINISTS_CT <> 0 and TMP_I17G = 0
AND    ISTREATED_B = 0

UPDATE #tmp_scope_rreplink
SET    ISVALIDI17P_B = 0, 
       LIBELLE_LL = LIBELLE_LL||' / TORETCTR:Incorrect I17P status'
WHERE  TOPARINISTS_CT is NOT null AND TOPARINISTS_CT <> 1 AND TOPARINISTS_CT <> 0 and TMP_I17P = 0
AND    ISTREATED_B = 0

UPDATE #tmp_scope_rreplink
SET    ISVALIDI17L_B = 0, 
       LIBELLE_LL = LIBELLE_LL||' / TORETCTR:Incorrect I17L status'
WHERE  TOLOCINISTS_CT is NOT null AND TOLOCINISTS_CT <> 1 AND TOLOCINISTS_CT <> 0 and TMP_I17L = 0
AND    ISTREATED_B = 0


---------------------------------------------------------------------
-- 7EME ETAPE : Check for TRETCTR status for TO part
---------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||'TOCTR - Incorrect SECSTS status'
WHERE  TOSECSTS_CT NOT IN (3,19)
AND    ISTREATED_B = 0


---------------------------------------------------------------------
-- 9EME ETAPE : Check for TRETCTR status for FROM part
---------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||'FROMCTR - Incorrect SECSTS status'
WHERE  FROMSECSTS_CT NOT IN (3,19)
AND    ISTREATED_B = 0

---------------------------------------------------------------------
-- 9EME ETAPE BIS : Check if SSD/ESB is permitted for I1P and I17L
---------------------------------------------------------------------
UPDATE #tmp_scope_rreplink
SET    ISVALIDI17P_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / No I17P'
FROM   #tmp_scope_rreplink link, BEST..TI17CLOPER clop
WHERE  link.FROMSSD_CF = clop.SSD_CF AND link.FROMESB_CF = clop.ESB_CF
AND    ( clop.PARM1 = '0' OR clop.PARM1 IS NULL )
AND    ISTREATED_B = 0

UPDATE #tmp_scope_rreplink
SET    ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / No I17L'
FROM   #tmp_scope_rreplink link, BEST..TI17CLOPER clop
WHERE  link.FROMSSD_CF = clop.SSD_CF AND link.FROMESB_CF = clop.ESB_CF
AND    ( clop.PARM2 = '0' OR clop.PARM2 IS NULL )
AND    ISTREATED_B = 0

------------------------------------------------------------------------------
-- 10EME ETAPE : Check if I17 "from" information has changed since last update
------------------------------------------------------------------------------
SELECT 
	TORETCTR_NF,
	TORTY_NF,
	FROMRETCTR_NF,
	FROMRTY_NF,
	FROMSECSTS_CT,
	FROMLOB_CF,
	FROMSSD_CF,
	FROMESB_CF,
	FROMGRPIFRSSEG_CT,
	FROMGRPIFRSSEG_LL,
	FROMPARIFRSSEG_CT,
	FROMPARIFRSSEG_LL,
	FROMLOCIFRSSEG_CT,
	FROMLOCIFRSSEG_LL,
	FROMGRPIFRSSEG1_CT,
	FROMGRPIFRSSEG1_LL,
	FROMPARIFRSSEG1_CT,
	FROMPARIFRSSEG1_LL,
	FROMLOCIFRSSEG1_CT,
	FROMLOCIFRSSEG1_LL,
	FROMGRPINIPRO_CF,
	FROMPARINIPRO_CF,
	FROMLOCINIPRO_CF,
	FROMGRPIFRSTRA_CT,
	FROMPARIFRSTRA_CT,
	FROMLOCIFRSTRA_CT,
	FROMGRPINISTS_CT,
	FROMPARINISTS_CT,
	FROMLOCINISTS_CT,
	FROMGRPFSTCLO_D,
	FROMPARFSTCLO_D,
	FROMLCLFSTCLO_D,
	FROMGRPRATEINDEX_CT,
	FROMPARRATEINDEX_CT,
	FROMLCLRATEINDEX_CT,
	FROMGRPANCO_NF,
	FROMPARANCO_NF,
	FROMLOCANCO_NF,
	FROMRETRECOD_D
INTO #tmpfrom
FROM BTRAV..SCOPE_TRREPLINK
WHERE  lstupd_d < CONVERT(VARCHAR(10), @cre_d, 112)
AND    ISTREATED_B=1
GROUP BY TORETCTR_NF, TORTY_NF
HAVING lstupd_d = MAX(lstupd_d)

update #tmp_scope_rreplink
set    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / No change between the last update in FROM part'
FROM #tmpfrom t, #tmp_scope_rreplink s
WHERE 
s.lstupd_d >= CONVERT(VARCHAR(10), @cre_d, 112)
AND t.FROMRETCTR_NF       =  s.FROMRETCTR_NF
AND t.FROMRTY_NF          =  s.FROMRTY_NF
AND	t.FROMSECSTS_CT       =  s.FROMSECSTS_CT
AND	t.FROMLOB_CF          =  s.FROMLOB_CF
AND	t.FROMSSD_CF          =  s.FROMSSD_CF
AND	t.FROMESB_CF          =  s.FROMESB_CF
AND	t.FROMGRPIFRSSEG_CT   =  s.FROMGRPIFRSSEG_CT
AND	t.FROMGRPIFRSSEG_LL   =  s.FROMGRPIFRSSEG_LL
AND	t.FROMPARIFRSSEG_CT   =  s.FROMPARIFRSSEG_CT
AND	t.FROMPARIFRSSEG_LL   =  s.FROMPARIFRSSEG_LL
AND	t.FROMLOCIFRSSEG_CT   =  s.FROMLOCIFRSSEG_CT
AND	t.FROMLOCIFRSSEG_LL   =  s.FROMLOCIFRSSEG_LL
AND	t.FROMGRPIFRSSEG1_CT  =  s.FROMGRPIFRSSEG1_CT
AND	t.FROMGRPIFRSSEG1_LL  =  s.FROMGRPIFRSSEG1_LL
AND	t.FROMPARIFRSSEG1_CT  =  s.FROMPARIFRSSEG1_CT
AND	t.FROMPARIFRSSEG1_LL  =  s.FROMPARIFRSSEG1_LL
AND	t.FROMLOCIFRSSEG1_CT  =  s.FROMLOCIFRSSEG1_CT
AND	t.FROMLOCIFRSSEG1_LL  =  s.FROMLOCIFRSSEG1_LL
AND	t.FROMGRPINIPRO_CF    =  s.FROMGRPINIPRO_CF
AND	t.FROMPARINIPRO_CF    =  s.FROMPARINIPRO_CF
AND	t.FROMLOCINIPRO_CF    =  s.FROMLOCINIPRO_CF
AND	t.FROMGRPIFRSTRA_CT   =  s.FROMGRPIFRSTRA_CT
AND	t.FROMPARIFRSTRA_CT   =  s.FROMPARIFRSTRA_CT
AND	t.FROMLOCIFRSTRA_CT   =  s.FROMLOCIFRSTRA_CT
AND	t.FROMGRPINISTS_CT    =  s.FROMGRPINISTS_CT
AND	t.FROMPARINISTS_CT    =  s.FROMPARINISTS_CT
AND	t.FROMLOCINISTS_CT    =  s.FROMLOCINISTS_CT
AND	t.FROMGRPFSTCLO_D     =  s.FROMGRPFSTCLO_D
AND	t.FROMPARFSTCLO_D     =  s.FROMPARFSTCLO_D
AND	t.FROMLCLFSTCLO_D     =  s.FROMLCLFSTCLO_D
AND	isnull(t.FROMGRPRATEINDEX_CT,'0') =  isnull(s.FROMGRPRATEINDEX_CT,'0')
AND	isnull(t.FROMPARRATEINDEX_CT,'0') =  isnull(s.FROMPARRATEINDEX_CT,'0')
AND	isnull(t.FROMLCLRATEINDEX_CT,'0') =  isnull(s.FROMLCLRATEINDEX_CT,'0')
AND	t.FROMGRPANCO_NF      =  s.FROMGRPANCO_NF
AND	t.FROMPARANCO_NF      =  s.FROMPARANCO_NF
AND	t.FROMLOCANCO_NF      =  s.FROMLOCANCO_NF
AND	t.FROMRETRECOD_D      =  s.FROMRETRECOD_D



------------------------------------------------------------------------------
-- ETAPE FINALE : SELECT FINAL
------------------------------------------------------------------------------
DELETE #tmp_scope_rreplink
FROM   #tmp_scope_rreplink tmp, BTRAV..SCOPE_TRREPLINK btrav
WHERE
    tmp.TORETCTR_NF                      = btrav.TORETCTR_NF
AND tmp.TORTY_NF                         = btrav.TORTY_NF
AND tmp.TOSECSTS_CT                      = btrav.TOSECSTS_CT
AND tmp.TOLOB_CF                         = btrav.TOLOB_CF
AND tmp.TOSSD_CF                         = btrav.TOSSD_CF
AND tmp.TOESB_CF                         = btrav.TOESB_CF
AND isnull(tmp.TOGRPINISTS_CT,0)         = isnull(btrav.TOGRPINISTS_CT,0)
AND isnull(tmp.TOPARINISTS_CT,0)         = isnull(btrav.TOPARINISTS_CT,0)
AND isnull(tmp.TOLOCINISTS_CT,0)         = isnull(btrav.TOLOCINISTS_CT,0)
AND tmp.FROMRETCTR_NF                      = btrav.FROMRETCTR_NF
AND tmp.FROMRTY_NF                         = btrav.FROMRTY_NF
AND tmp.FROMSECSTS_CT                      = btrav.FROMSECSTS_CT
AND tmp.FROMLOB_CF                         = btrav.FROMLOB_CF
AND tmp.FROMSSD_CF                         = btrav.FROMSSD_CF
AND tmp.FROMESB_CF                         = btrav.FROMESB_CF
AND isnull(tmp.FROMGRPIFRSSEG_CT,'0')      = isnull(btrav.FROMGRPIFRSSEG_CT,'0')
AND isnull(tmp.FROMGRPIFRSSEG_LL,'0')      = isnull(btrav.FROMGRPIFRSSEG_LL,'0')
AND isnull(tmp.FROMPARIFRSSEG_CT,'0')      = isnull(btrav.FROMPARIFRSSEG_CT,'0')
AND isnull(tmp.FROMPARIFRSSEG_LL,'0')      = isnull(btrav.FROMPARIFRSSEG_LL,'0')
AND isnull(tmp.FROMLOCIFRSSEG_CT,'0')      = isnull(btrav.FROMLOCIFRSSEG_CT,'0')
AND isnull(tmp.FROMLOCIFRSSEG_LL,'0')      = isnull(btrav.FROMLOCIFRSSEG_LL,'0')
AND isnull(tmp.FROMGRPIFRSSEG1_CT,'0')     = isnull(btrav.FROMGRPIFRSSEG1_CT,'0')
AND isnull(tmp.FROMGRPIFRSSEG1_LL,'0')     = isnull(btrav.FROMGRPIFRSSEG1_LL,'0')
AND isnull(tmp.FROMPARIFRSSEG1_CT,'0')     = isnull(btrav.FROMPARIFRSSEG1_CT,'0')
AND isnull(tmp.FROMPARIFRSSEG1_LL,'0')     = isnull(btrav.FROMPARIFRSSEG1_LL,'0')
AND isnull(tmp.FROMLOCIFRSSEG1_CT,'0')     = isnull(btrav.FROMLOCIFRSSEG1_CT,'0')
AND isnull(tmp.FROMLOCIFRSSEG1_LL,'0')     = isnull(btrav.FROMLOCIFRSSEG1_LL,'0')
AND isnull(tmp.FROMGRPINIPRO_CF,'0')       = isnull(btrav.FROMGRPINIPRO_CF,'0')
AND isnull(tmp.FROMPARINIPRO_CF,'0')       = isnull(btrav.FROMPARINIPRO_CF,'0')
AND isnull(tmp.FROMLOCINIPRO_CF,'0')       = isnull(btrav.FROMLOCINIPRO_CF,'0')
AND isnull(tmp.FROMGRPIFRSTRA_CT,'0')      = isnull(btrav.FROMGRPIFRSTRA_CT,'0')
AND isnull(tmp.FROMPARIFRSTRA_CT,'0')      = isnull(btrav.FROMPARIFRSTRA_CT,'0')
AND isnull(tmp.FROMLOCIFRSTRA_CT,'0')      = isnull(btrav.FROMLOCIFRSTRA_CT,'0')
AND isnull(tmp.FROMGRPINISTS_CT,0)         = isnull(btrav.FROMGRPINISTS_CT,0)
AND isnull(tmp.FROMPARINISTS_CT,0)         = isnull(btrav.FROMPARINISTS_CT,0)
AND isnull(tmp.FROMLOCINISTS_CT,0)         = isnull(btrav.FROMLOCINISTS_CT,0)
AND isnull(tmp.FROMGRPFSTCLO_D,'19010101') = isnull(btrav.FROMGRPFSTCLO_D,'19010101')
AND isnull(tmp.FROMGRPFSTCLO_D,'19010101') = isnull(btrav.FROMGRPFSTCLO_D,'19010101')
AND isnull(tmp.FROMLCLFSTCLO_D,'19010101') = isnull(btrav.FROMLCLFSTCLO_D,'19010101')
AND	isnull(tmp.FROMGRPRATEINDEX_CT,'0')    = isnull(btrav.FROMGRPRATEINDEX_CT,'0')
AND	isnull(tmp.FROMPARRATEINDEX_CT,'0')    = isnull(btrav.FROMPARRATEINDEX_CT,'0')
AND	isnull(tmp.FROMLCLRATEINDEX_CT,'0')    = isnull(btrav.FROMLCLRATEINDEX_CT,'0')
AND isnull(tmp.FROMGRPANCO_NF,0)           = isnull(btrav.FROMGRPANCO_NF,0)
AND isnull(tmp.FROMPARANCO_NF,0)           = isnull(btrav.FROMPARANCO_NF,0)
AND isnull(tmp.FROMLOCANCO_NF,0)           = isnull(btrav.FROMLOCANCO_NF,0)
AND isnull(tmp.FROMRETRECOD_D,'19010101')  = isnull(btrav.FROMRETRECOD_D,'19010101')
AND tmp.CLODAT_D = btrav.CLODAT_D


------------------------------------------------------------------------------
-- ETAPE FINALE : DELETE SPIRA 112620
------------------------------------------------------------------------------
DELETE #tmp_scope_rreplink
FROM   #tmp_scope_rreplink tmp, BTRAV..SCOPE_TRREPLINK btrav
WHERE
    tmp.TORETCTR_NF                      = btrav.TORETCTR_NF
AND tmp.TORTY_NF                         = btrav.TORTY_NF
AND tmp.FROMRETCTR_NF                      = btrav.FROMRETCTR_NF
AND tmp.FROMRTY_NF                         = btrav.FROMRTY_NF
AND btrav.ISTREATED_B = 1
AND tmp.CLODAT_D > btrav.CLODAT_D 


INSERT INTO BTRAV..SCOPE_TRREPLINK
SELECT * FROM #tmp_scope_rreplink
-- FIN NORMALE DE LA PROC

error:

Return 0
DROP TABLE  #tmptreplink
PRINT '-- FIN de la procedure bret..PsRET_TRREPLINK_01'
 
go
EXEC sp_procxmode 'PsRET_TRREPLINK_01', 'unchained'
go
IF OBJECT_ID('PsRET_TRREPLINK_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsRET_TRREPLINK_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsRET_TRREPLINK_01 >>>'
go
GRANT EXECUTE ON PsRET_TRREPLINK_01 TO GOMEGA
go
GRANT EXECUTE ON PsRET_TRREPLINK_01 TO GDBBATCH
go
