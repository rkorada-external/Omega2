USE BTRT
go
if object_id('PsTRT_TREPLINK_01') is not null
begin
  drop procedure PsTRT_TREPLINK_01
  if object_id('PsTRT_TREPLINK_01') is not null
      print '<<< FAILED DROPPING procedure PsTRT_TREPLINK_01 >>>'
  else
      print '<<< DROPPED procedure PsTRT_TREPLINK_01 >>>'
end
go
create procedure PsTRT_TREPLINK_01
  (
  @cre_d datetime,
  @balshtyea varchar(4),
  @clodat datetime
  )
with execute as caller as
/*****
Programme: PsTRT_TREPLINK_01


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
-- 25-09_2024 MOD[004] - S.Behague - 112207 - NTAP - Source contract UWY management
-- 25-10_2024 MOD[004] - S.Behague - 112344 - NTAP- I17G booked and I17L only taken for NTAP
-- 12-11_2024 MOD[006] - S.Behague - 112344 - NTAP- I17G booked and I17L only taken for NTAP - Ajout correction sur traités LT
-- 21-01_2025 MOD[007] - S.Behague - 112620 - NTAP process not picking candidates Q125
******************************************************************************************************/
declare @IsSameFrom int

select @IsSameFrom = 0

SELECT TOP 1 * INTO #tmp_scope_replink FROM BTRAV..SCOPE_TREPLINK
DELETE FROM #tmp_scope_replink


-- MOD[007] Spira 112620--
UPDATE BTRAV..SCOPE_TREPLINK
SET 
ISVALIDI17G_B = 0,
ISVALIDI17P_B = 0,
ISVALIDI17L_B = 0
WHERE CLODAT_D < @clodat
AND ISTREATED_B = 0
AND ( ISVALIDI17G_B = 1 OR ISVALIDI17P_B = 1 OR ISVALIDI17L_B = 1 )


-- ETAPE INITIALE : SELECTION des dernières postions pour CTR_NF, SEC_NF, UWY_NF de la partie TO
select link.CTR_NF,
       link.SEC_NF,
       link.UWY_NF,
       link.lstupd_d
into   #tmpreplink
from btrt..TREPLINK link
group by link.CTR_NF, link.SEC_NF, link.UWY_NF
having lstupd_d = max(lstupd_d)

select CTR_NF, SEC_NF, UWY_NF, LSTUPD_D, count(*) nb_lignes
into   #tmpreplinkcount
from   #tmpreplink group by CTR_NF, SEC_NF, UWY_NF, LSTUPD_D


-- 1ERE ETAPE : SELECTION - LOB 30/31 - STATUS 14,16,17,19
INSERT INTO #tmp_scope_replink (TOCTR_NF, TOSEC_NF, TOUWY_NF, TOUW_NT, TOEND_NT, FROMCTR_NF, FROMSEC_NF, FROMUWY_NF, TOLOB_CF, TOSECSTS_CT, INPUT_D, LSTUPD_D, CLODAT_D, TOSSD_CF, TOESB_CF, ISVALIDI17G_B, ISVALIDI17P_B, ISVALIDI17L_B, ISTREATED_B, ISUPDATEFAILED_B, TMP_I17G, TMP_I17P, TMP_I17L, ACCADMTYP_CT, USGAAP_CT, FRSUWY_NF)
SELECT link.CTR_NF,
       link.SEC_NF,
       link.UWY_NF,
       contr.UW_NT,
       contr.END_NT,
       link.RPDCTR_NF,
       link.RPDSEC_NF,
       1901,
       section.LOB_CF,
       section.SECSTS_CT,
       link.LSTUPD_D,
       @cre_d,
       @clodat,
       section.SSD_CF,
       contr.ACCESB_CF,
       1,
       1,
       1,
       0,
       0,
       0,
       0,
       0,
       section.ACCADMTYP_CT,
       section.USGAAP_CT,
       section.FRSUWY_NF
FROM   BTRT..TREPLINK link,
       BTRT..TSECTION section,
       BTRT..TCONTR contr,
       #tmpreplinkcount tmp
WHERE  link.CTR_NF = section.CTR_NF AND link.SEC_NF = section.SEC_NF AND link.UWY_NF = section.UWY_NF
AND    link.CTR_NF = contr.CTR_NF AND link.UWY_NF = contr.UWY_NF
AND    tmp.ctr_nf = link.CTR_NF AND link.SEC_NF = tmp.SEC_NF AND link.UWY_NF = tmp.UWY_NF and  link.lstupd_d = tmp.lstupd_d AND tmp.nb_lignes = 1
AND    section.SECSTS_CT in (14,16,17,19)
AND    section.LOB_CF in ('30','31')
AND    (section.assfinance_ct <> 2 OR section.assfinance_ct is null )
and    section.SSD_CF <> 26
and    (contr.estcrb_ct <> 'D' and contr.estcrb_ct <> 'R' and contr.estcrb_ct <> 'S' or contr.estcrb_ct is null)
AND    exists(select 1 from BREF..TBATCHSSD c where section.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())

-- Insertion des lignes pour lesquelles le contrat cible a plusieurs sources à la même date
-- Permet de tracer le cas en erreur
INSERT INTO #tmp_scope_replink (TOCTR_NF, TOSEC_NF, TOUWY_NF, TOUW_NT, TOEND_NT, FROMCTR_NF, FROMSEC_NF, FROMUWY_NF, TOLOB_CF, TOSECSTS_CT, INPUT_D, LSTUPD_D, CLODAT_D, TOSSD_CF, TOESB_CF, ISVALIDI17G_B, ISVALIDI17P_B, ISVALIDI17L_B, ISTREATED_B, ISUPDATEFAILED_B, TMP_I17G, TMP_I17P, TMP_I17L, ACCADMTYP_CT, USGAAP_CT, FRSUWY_NF, LIBELLE_LL)
SELECT link.CTR_NF,
       link.SEC_NF,
       link.UWY_NF,
       contr.UW_NT,
       contr.END_NT,
       link.RPDCTR_NF,
       link.RPDSEC_NF,
       1901,
       section.LOB_CF,
       section.SECSTS_CT,
       link.LSTUPD_D,
       @cre_d,
       @clodat,
       section.SSD_CF,
       contr.ACCESB_CF,
       0,
       0,
       0,
       0,
       0,
       0,
       0,
       0,
       section.ACCADMTYP_CT,
       section.USGAAP_CT,
       section.FRSUWY_NF,
       'ERROR - more than 1 from contract '
FROM   BTRT..TREPLINK link,
       BTRT..TSECTION section,
       BTRT..TCONTR contr,
       #tmpreplinkcount tmp
WHERE  link.CTR_NF = section.CTR_NF AND link.SEC_NF = section.SEC_NF AND link.UWY_NF = section.UWY_NF
AND    link.CTR_NF = contr.CTR_NF AND link.UWY_NF = contr.UWY_NF
AND    tmp.ctr_nf = link.CTR_NF AND link.SEC_NF = tmp.SEC_NF AND link.UWY_NF = tmp.UWY_NF and  link.lstupd_d = tmp.lstupd_d AND tmp.nb_lignes > 1
AND    section.SECSTS_CT in (14,16,17,19)
AND    section.LOB_CF in ('30','31')
AND    (section.assfinance_ct <> 2 OR section.assfinance_ct is null )
and    section.SSD_CF <> 26
and    (contr.estcrb_ct <> 'D' and contr.estcrb_ct <> 'R' and contr.estcrb_ct <> 'S' or contr.estcrb_ct is null)
AND    exists(select 1 from BREF..TBATCHSSD c where section.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())


---------------------------------------------------------------------
-- 1ERE ETAPE A : Cas général
--                Check for the more recent valid UWY for FROM part
---------------------------------------------------------------------
SELECT secifrs.CTR_NF, secifrs.SEC_NF, secifrs.UWY_NF INTO #tmpuwyto FROM  #tmp_scope_replink link, BTRT..TSECIFRS secifrs
WHERE  link.FROMCTR_NF = secifrs.CTR_NF AND link.FROMSEC_NF = secifrs.SEC_NF 

DELETE #tmpuwyto 
FROM   #tmpuwyto uwy, BTRT..TSECTION section
WHERE uwy.CTR_NF = section.CTR_NF
AND   uwy.UWY_NF = section.UWY_NF
AND   uwy.SEC_NF = section.SEC_NF
AND   ( section.SECSTS_CT NOT IN (14,16,17,19) 
      OR section.LOB_CF NOT IN ('30','31') )

DELETE #tmpuwyto
FROM   #tmpuwyto uwy, BTRT..TSECIFRS secifrs
WHERE  uwy.CTR_NF = secifrs.CTR_NF AND uwy.SEC_NF = secifrs.SEC_NF AND uwy.UWY_NF = secifrs.UWY_NF
AND    ( secifrs.GRPINISTS_CT <> 2 OR secifrs.GRPINISTS_CT IS NULL )
--OR    secifrs.PARINISTS_CT <> 2 OR secifrs.PARINISTS_CT IS NULL
--OR    secifrs.LOCINISTS_CT <> 2 OR secifrs.LOCINISTS_CT IS NULL ) -- On teste seulement I17G, on renseignera ensuite les informations pour I17L et I17P en fonction de TI17CLOPER

SELECT CTR_NF, SEC_NF, UWY_NF INTO #tmpmaxuwy FROM #tmpuwyto
GROUP BY CTR_NF, SEC_NF
HAVING UWY_NF = max(UWY_NF)

UPDATE #tmp_scope_replink SET FROMUWY_NF = maxuwy.UWY_NF
from #tmp_scope_replink link, #tmpmaxuwy maxuwy
WHERE link.FROMCTR_NF = maxuwy.CTR_NF
AND   link.FROMSEC_NF = maxuwy.SEC_NF
AND   link.ISTREATED_B = 0

---------------------------------------------------------------------
-- 1ERE ETAPE B : Cas T2ST
--                FROMUWY est forcé avec la valeur de TOUWY
--                Ensuite on vérifiera les conditions
---------------------------------------------------------------------
UPDATE #tmp_scope_replink SET FROMUWY_NF = TOUWY_NF, LIBELLE_LL = 'T2ST-'
WHERE  ACCADMTYP_CT = 2 AND USGAAP_CT IN (2,3)
AND    ISTREATED_B = 0

---------------------------------------------------------------------
-- 1ERE ETAPE C : Cas LT I17L
--                Insertion d'une nouvelle ligne pour gérer I17L comme T2ST
--                puis on met I17L à non valide pour la ligne référence
--                Ensuite on vérifiera les conditions
---------------------------------------------------------------------
UPDATE #tmp_scope_replink SET ISVALIDI17L_B = 0, LIBELLE_LL = 'LT I17G-'
WHERE  ACCADMTYP_CT = 2 AND USGAAP_CT = 1
AND    TOSSD_CF = 20 AND TOESB_CF = 6
AND    ISTREATED_B = 0

INSERT INTO #tmp_scope_replink (TOCTR_NF, TOSEC_NF, TOUWY_NF, TOUW_NT, TOEND_NT, FROMCTR_NF, FROMSEC_NF, FROMUWY_NF, TOLOB_CF, TOSECSTS_CT, INPUT_D, LSTUPD_D, CLODAT_D, TOSSD_CF, TOESB_CF, ISVALIDI17G_B, ISVALIDI17P_B, ISVALIDI17L_B, ISTREATED_B, ISUPDATEFAILED_B, TMP_I17G, TMP_I17P, TMP_I17L, ACCADMTYP_CT, USGAAP_CT, FRSUWY_NF, LIBELLE_LL)
SELECT TOCTR_NF, TOSEC_NF, TOUWY_NF, TOUW_NT, TOEND_NT, FROMCTR_NF, FROMSEC_NF, TOUWY_NF, TOLOB_CF, TOSECSTS_CT, INPUT_D, LSTUPD_D, CLODAT_D, TOSSD_CF, TOESB_CF, 0, 0, 1, ISTREATED_B, ISUPDATEFAILED_B, TMP_I17G, TMP_I17P, TMP_I17L, ACCADMTYP_CT, USGAAP_CT, FRSUWY_NF, 'LT I17L-' FROM #tmp_scope_replink
WHERE  ACCADMTYP_CT = 2 AND USGAAP_CT = 1
AND    TOSSD_CF = 20 AND TOESB_CF = 6
AND    ISTREATED_B = 0


---------------------------------------------------------------------
-- 2EME ETAPE : Fill LOB_CF, SECSTS_CT, SSD_CF, ESB_CF for FROM part
---------------------------------------------------------------------
UPDATE #tmp_scope_replink
SET    link.FROMLOB_CF = section.LOB_CF, link.FROMSECSTS_CT = section.SECSTS_CT, link.FROMSSD_CF = section.SSD_CF, link.FROMESB_CF = contr.ACCESB_CF, link.FROMUW_NT = section.UW_NT, link.FROMEND_NT = section.END_NT
FROM   #tmp_scope_replink link, BTRT..TSECTION section, BTRT..TCONTR contr
WHERE  link.FROMCTR_NF = section.CTR_NF AND link.FROMSEC_NF = section.SEC_NF
AND    link.FROMCTR_NF = contr.CTR_NF


---------------------------------------------------------------------
-- 3EME ETAPE : Fill inception status for TO part
---------------------------------------------------------------------
UPDATE #tmp_scope_replink
SET    
       TOGRPIFRSSEG_CT   = GRPIFRSSEG_CT,
       TOGRPIFRSSEG_LL   = GRPIFRSSEG_LL,
       TOPARIFRSSEG_CT   = PARIFRSSEG_CT,
       TOPARIFRSSEG_LL   = PARIFRSSEG_LL,
       TOLOCIFRSSEG_CT   = LOCIFRSSEG_CT,
       TOLOCIFRSSEG_LL   = LOCIFRSSEG_LL,
       TOGRPIFRSSEG1_CT  = GRPIFRSSEG1_CT,
       TOGRPIFRSSEG1_LL  = GRPIFRSSEG1_LL,
       TOPARIFRSSEG1_CT  = PARIFRSSEG1_CT,
       TOPARIFRSSEG1_LL  = PARIFRSSEG1_LL,
       TOLOCIFRSSEG1_CT  = LOCIFRSSEG1_CT,
       TOLOCIFRSSEG1_LL  = LOCIFRSSEG1_LL,
       TOGRPINIPRO_CF    = GRPINIPRO_CF,
       TOPARINIPRO_CF    = PARINIPRO_CF,
       TOLOCINIPRO_CF    = LOCINIPRO_CF,
       TOGRPIFRSTRA_CT   = GRPIFRSTRA_CT,
       TOPARIFRSTRA_CT   = PARIFRSTRA_CT,
       TOLOCIFRSTRA_CT   = LOCIFRSTRA_CT,
       TOGRPINISTS_CT    = GRPINISTS_CT,
       TOPARINISTS_CT    = PARINISTS_CT,
       TOLOCINISTS_CT    = LOCINISTS_CT,
       TOGRPFIRCLO_D     = GRPFIRCLO_D,
       TOPARFIRCLO_D     = PARFIRCLO_D,
       TOLOCFIRCLO_D     = LOCFIRCLO_D,
       TOGRPRATEINDEX_CT = GRPRATEINDEX_CT,
       TOPARRATEINDEX_CT = PARRATEINDEX_CT,
       TOLOCRATEINDEX_CT = LOCRATEINDEX_CT,
       TOGRPANCO_NF      = GRPANCO_NF,
       TOPARANCO_NF      = PARANCO_NF,
       TOLOCANCO_NF      = LOCANCO_NF,
       TORECOD_D         = RECOD_D
FROM   #tmp_scope_replink link, BTRT..TSECIFRS secifrs
WHERE  link.TOCTR_NF = secifrs.CTR_NF AND link.TOSEC_NF = secifrs.SEC_NF AND link.TOUWY_NF = secifrs.UWY_NF
AND    link.ISTREATED_B = 0


---------------------------------------------------------------------
-- 4EME ETAPE : Fill inception status for FROM part
---------------------------------------------------------------------
UPDATE #tmp_scope_replink
SET    FROMGRPIFRSSEG_CT   = GRPIFRSSEG_CT,
       FROMGRPIFRSSEG_LL   = GRPIFRSSEG_LL,
       FROMPARIFRSSEG_CT   = PARIFRSSEG_CT,
       FROMPARIFRSSEG_LL   = PARIFRSSEG_LL,
       FROMLOCIFRSSEG_CT   = LOCIFRSSEG_CT,
       FROMLOCIFRSSEG_LL   = LOCIFRSSEG_LL,
       FROMGRPIFRSSEG1_CT  = GRPIFRSSEG1_CT,
       FROMGRPIFRSSEG1_LL  = GRPIFRSSEG1_LL,
       FROMPARIFRSSEG1_CT  = PARIFRSSEG1_CT,
       FROMPARIFRSSEG1_LL  = PARIFRSSEG1_LL,
       FROMLOCIFRSSEG1_CT  = LOCIFRSSEG1_CT,
       FROMLOCIFRSSEG1_LL  = LOCIFRSSEG1_LL,
       FROMGRPINIPRO_CF    = GRPINIPRO_CF,
       FROMPARINIPRO_CF    = PARINIPRO_CF,
       FROMLOCINIPRO_CF    = LOCINIPRO_CF,
       FROMGRPIFRSTRA_CT   = GRPIFRSTRA_CT,
       FROMPARIFRSTRA_CT   = PARIFRSTRA_CT,
       FROMLOCIFRSTRA_CT   = LOCIFRSTRA_CT,
       FROMGRPINISTS_CT    = GRPINISTS_CT,
       FROMPARINISTS_CT    = PARINISTS_CT,
       FROMLOCINISTS_CT    = LOCINISTS_CT,
       FROMGRPFIRCLO_D     = GRPFIRCLO_D,
       FROMPARFIRCLO_D     = PARFIRCLO_D,
       FROMLOCFIRCLO_D     = LOCFIRCLO_D,
       FROMGRPRATEINDEX_CT = GRPRATEINDEX_CT,
       FROMPARRATEINDEX_CT = PARRATEINDEX_CT,
       FROMLOCRATEINDEX_CT = LOCRATEINDEX_CT,
       FROMGRPANCO_NF      = GRPANCO_NF,
       FROMPARANCO_NF      = PARANCO_NF,
       FROMLOCANCO_NF      = LOCANCO_NF,
       FROMRECOD_D         = RECOD_D
FROM   #tmp_scope_replink link, BTRT..TSECIFRS secifrs
WHERE  link.FROMCTR_NF = secifrs.CTR_NF AND link.FROMSEC_NF = secifrs.SEC_NF AND link.FROMUWY_NF = secifrs.UWY_NF
AND    link.ISTREATED_B = 0

---------------------------------------------------------------------
-- 5EME ETAPE A : Cas général 
--                Check if Uwy founded for FROM part
---------------------------------------------------------------------
UPDATE #tmp_scope_replink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = 'FROMCTR_NF:No UWY Valid'
WHERE  FROMUWY_Nf = 1901
AND    ISTREATED_B = 0

      
---------------------------------------------------------------------
-- 5EME ETAPE B : Cas T2ST
--                Check Conditions for FROMUWY filled in ETAPE 1 B
---------------------------------------------------------------------
-- Check TSECIFRS status
UPDATE #tmp_scope_replink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' FROMUWY_NF:No valid TSECIFRS status'
WHERE  ACCADMTYP_CT = 2 AND USGAAP_CT IN (2,3)
AND    (FROMGRPINISTS_CT <> 2 OR FROMGRPINISTS_CT IS NULL )

-- Check TSECTION status
UPDATE #tmp_scope_replink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' FROMUWY_NF:No valid TSECTION status'
FROM   #tmp_scope_replink uwy, BTRT..TSECTION section
WHERE  uwy.FROMCTR_NF = section.CTR_NF
AND    uwy.FROMUWY_NF = section.UWY_NF
AND    uwy.FROMSEC_NF = section.SEC_NF
AND    ( section.SECSTS_CT NOT IN (14,16,17,19) 
       OR section.LOB_CF NOT IN ('30','31') )

---------------------------------------------------------------------
-- 5EME ETAPE C : Cas I17L LT
--                Check Conditions for FROMUWY filled in ETAPE 1 C
---------------------------------------------------------------------
-- Check TSECIFRS status pour I17G/P
UPDATE #tmp_scope_replink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
       LIBELLE_LL = LIBELLE_LL||' FROMUWY_NF:No valid TSECIFRS status'
WHERE  ACCADMTYP_CT = 2 AND USGAAP_CT = 1
AND    TOSSD_CF = 20 AND TOESB_CF = 6
AND    (FROMGRPINISTS_CT <> 2 OR FROMGRPINISTS_CT IS NULL )
AND    LIBELLE_LL like 'LT I17G%'
-- Check TSECIFRS status pour I17L
UPDATE #tmp_scope_replink
SET    ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' FROMUWY_NF:No valid TSECIFRS status'
WHERE  ACCADMTYP_CT = 2 AND USGAAP_CT = 1
AND    TOSSD_CF = 20 AND TOESB_CF = 6
AND    (FROMLOCINISTS_CT <> 2 OR FROMLOCINISTS_CT IS NULL )
AND    LIBELLE_LL like 'LT I17L%'

-- Check TSECTION status pour I17G/P
UPDATE #tmp_scope_replink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / FROMUWY_NF:No valid TSECTION status'
FROM   #tmp_scope_replink uwy, BTRT..TSECTION section
WHERE  uwy.FROMCTR_NF = section.CTR_NF
AND    uwy.FROMUWY_NF = section.UWY_NF
AND    uwy.FROMSEC_NF = section.SEC_NF
AND    ( section.SECSTS_CT NOT IN (14,16,17,19) 
       OR section.LOB_CF NOT IN ('30','31') ) 
AND    LIBELLE_LL like 'LT I17G%'
-- Check TSECTION status pour I17L
UPDATE #tmp_scope_replink
SET    ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / FROMUWY_NF:No valid TSECTION status'
FROM   #tmp_scope_replink uwy, BTRT..TSECTION section
WHERE  uwy.FROMCTR_NF = section.CTR_NF
AND    uwy.FROMUWY_NF = section.UWY_NF
AND    uwy.FROMSEC_NF = section.SEC_NF
AND    ( section.SECSTS_CT NOT IN (14,16,17,19) 
       OR section.LOB_CF NOT IN ('30','31') ) 
AND    LIBELLE_LL like 'LT I17G%'

-----------------------------------------------------------------------------------
-- 6EME ETAPE : Conditions on T2ST contracts -- spira  112017
-----------------------------------------------------------------------------------
UPDATE #tmp_scope_replink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||'T2ST Contract ERROR'
WHERE 
       ACCADMTYP_CT = 2 AND USGAAP_CT IN (2,3)
AND    (TOUWY_NF <> FROMUWY_NF)
AND    ISTREATED_B = 0

UPDATE #tmp_scope_replink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||'Long Term Contract ERROR'
WHERE 
       ACCADMTYP_CT = 2 AND USGAAP_CT = 1
AND    TOSSD_CF = 20 AND TOESB_CF = 6
AND    (TOUWY_NF <> FROMUWY_NF)
AND    ISTREATED_B = 0

UPDATE #tmp_scope_replink
SET    ISVALIDI17P_B = 0,
       LIBELLE_LL = LIBELLE_LL||'Long Term Contract Error for I17P'
WHERE 
       ACCADMTYP_CT = 2 AND USGAAP_CT = 1
AND    TOSSD_CF = 20 AND TOESB_CF = 6


---------------------------------------------------------------------
-- 7EME ETAPE : Check SSD / ESB
---------------------------------------------------------------------
UPDATE #tmp_scope_replink
SET    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / Problem SSD/ESB'
WHERE  (TOSSD_CF <> FROMSSD_CF 
OR      TOESB_CF <> FROMESB_CF)
AND    ISTREATED_B = 0

---------------------------------------------------------------------
-- 8EME ETAPE STEP 01 : Check if TO part is already existing in BTRAV..SCOPE_TREPLINK and TOGRPINISTS_CT = 2
--                      To do it, we're filling TMP_I17G/P/L status with 1 
---------------------------------------------------------------------
update #tmp_scope_replink 
set    TMP_I17G = 1 
from   #tmp_scope_replink t, BTRAV..SCOPE_TREPLINK l
where  t.toctr_nf = l.toctr_nf
and    t.tosec_nf = l.tosec_nf
and    t.touwy_nf = l.touwy_nf
and    t.touw_nt = l.touw_nt
and    t.toend_nt = l.toend_nt
and    ( t.fromend_nt <> l.fromend_nt or t.fromuw_nt <> l.fromuw_nt or t.fromuwy_nf <> l.fromuwy_nf or t.fromsec_nf <> l.fromsec_nf or t.fromctr_nf <> l.fromctr_nf )
and    l.ISTREATED_B = 1
and    t.TOGRPINISTS_CT = 2

update #tmp_scope_replink 
set    TMP_I17P = 1 
from   #tmp_scope_replink t, BTRAV..SCOPE_TREPLINK l
where  t.toctr_nf = l.toctr_nf
and    t.tosec_nf = l.tosec_nf
and    t.touwy_nf = l.touwy_nf
and    t.touw_nt = l.touw_nt
and    t.toend_nt = l.toend_nt
and    ( t.fromend_nt <> l.fromend_nt or t.fromuw_nt <> l.fromuw_nt or t.fromuwy_nf <> l.fromuwy_nf or t.fromsec_nf <> l.fromsec_nf or t.fromctr_nf <> l.fromctr_nf )
and    l.ISTREATED_B = 1
and    t.TOPARINISTS_CT = 2

update #tmp_scope_replink 
set    TMP_I17L = 1 
from   #tmp_scope_replink t, BTRAV..SCOPE_TREPLINK l
where  t.toctr_nf = l.toctr_nf
and    t.tosec_nf = l.tosec_nf
and    t.touwy_nf = l.touwy_nf
and    t.touw_nt = l.touw_nt
and    t.toend_nt = l.toend_nt
and    ( t.fromend_nt <> l.fromend_nt or t.fromuw_nt <> l.fromuw_nt or t.fromuwy_nf <> l.fromuwy_nf or t.fromsec_nf <> l.fromsec_nf or t.fromctr_nf <> l.fromctr_nf )
and    l.ISTREATED_B = 1
and    t.TOLOCINISTS_CT = 2

---------------------------------------------------------------------
-- 8EME ETAPE : Check I17G,P,L inception STATS must be NULL or 1
---------------------------------------------------------------------
UPDATE #tmp_scope_replink
SET		 ISVALIDI17G_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / TORETCTR:Incorrect I17G status'
WHERE  TOGRPINISTS_CT is not null AND TOGRPINISTS_CT <> 1 and TMP_I17G = 0
AND    ISTREATED_B = 0

UPDATE #tmp_scope_replink
SET		 ISVALIDI17P_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / TORETCTR:Incorrect I17P status'
WHERE  TOPARINISTS_CT is not null AND TOPARINISTS_CT <> 1 and TMP_I17P = 0
AND    ISTREATED_B = 0

UPDATE #tmp_scope_replink
SET		 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / TORETCTR:Incorrect I17L status'
WHERE  TOLOCINISTS_CT is not null AND TOLOCINISTS_CT <> 1 and TMP_I17L = 0
AND    ISTREATED_B = 0


---------------------------------------------------------------------
-- 9EME ETAPE : Check if SSD/ESB is permitted for I1P and I17L
---------------------------------------------------------------------
UPDATE #tmp_scope_replink
SET    ISVALIDI17P_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / No I17P'
FROM   #tmp_scope_replink link, BEST..TI17CLOPER clop
WHERE  link.FROMSSD_CF = clop.SSD_CF AND link.FROMESB_CF = clop.ESB_CF
AND    ( clop.PARM1 = '0' OR clop.PARM1 IS NULL )
AND    ISTREATED_B = 0

UPDATE #tmp_scope_replink
SET    ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / No I17L'
FROM   #tmp_scope_replink link, BEST..TI17CLOPER clop
WHERE  link.FROMSSD_CF = clop.SSD_CF AND link.FROMESB_CF = clop.ESB_CF
AND    ( clop.PARM2 = '0' OR clop.PARM2 IS NULL )
AND    ISTREATED_B = 0


------------------------------------------------------------------------------
-- 10EME ETAPE : Check if I17 "from" information has changed since last update
------------------------------------------------------------------------------
SELECT 
	TOCTR_NF,
	TOSEC_NF,
	TOUWY_NF,
  TOUW_NT,
  TOEND_NT,
	FROMCTR_NF,
	FROMSEC_NF,
	FROMUWY_NF,
  FROMUW_NT,
  FROMEND_NT,
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
	FROMGRPFIRCLO_D,
	FROMPARFIRCLO_D,
	FROMLOCFIRCLO_D,
	FROMGRPRATEINDEX_CT,
	FROMPARRATEINDEX_CT,
	FROMLOCRATEINDEX_CT,
	FROMGRPANCO_NF,
	FROMPARANCO_NF,
	FROMLOCANCO_NF,
	FROMRECOD_D
INTO #tmpfrom
FROM BTRAV..SCOPE_TREPLINK
WHERE  lstupd_d < CONVERT(VARCHAR(10), @cre_d, 112)
AND    ISTREATED_B=1
GROUP BY TOCTR_NF, TOSEC_NF, TOUWY_NF, TOUW_NT, TOEND_NT
HAVING lstupd_d = MAX(lstupd_d)

update #tmp_scope_replink
set    ISVALIDI17G_B = 0, 
			 ISVALIDI17P_B = 0,
			 ISVALIDI17L_B = 0,
       LIBELLE_LL = LIBELLE_LL||' / No change between the last update in FROM part'
FROM #tmpfrom t, #tmp_scope_replink s
WHERE 
s.lstupd_d >= CONVERT(VARCHAR(10), @cre_d, 112)
AND t.FROMCTR_NF          =  s.FROMCTR_NF
AND t.FROMSEC_NF          =  s.FROMSEC_NF
AND t.FROMUWY_NF          =  s.FROMUWY_NF
AND t.FROMUW_NT           =  s.FROMUW_NT
AND t.FROMEND_NT          =  s.FROMEND_NT
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
AND	t.FROMGRPFIRCLO_D     =  s.FROMGRPFIRCLO_D
AND	t.FROMPARFIRCLO_D     =  s.FROMPARFIRCLO_D
AND	t.FROMLOCFIRCLO_D     =  s.FROMLOCFIRCLO_D
AND	isnull(t.FROMGRPRATEINDEX_CT,'0') =  isnull(s.FROMGRPRATEINDEX_CT,'0')
AND	isnull(t.FROMPARRATEINDEX_CT,'0') =  isnull(s.FROMPARRATEINDEX_CT,'0')
AND	isnull(t.FROMLOCRATEINDEX_CT,'0') =  isnull(s.FROMLOCRATEINDEX_CT,'0')
AND	t.FROMGRPANCO_NF      =  s.FROMGRPANCO_NF
AND	t.FROMPARANCO_NF      =  s.FROMPARANCO_NF
AND	t.FROMLOCANCO_NF      =  s.FROMLOCANCO_NF
AND	t.FROMRECOD_D         =  s.FROMRECOD_D



------------------------------------------------------------------------------
-- ETAPE FINALE : SELECT FINAL
------------------------------------------------------------------------------
DELETE #tmp_scope_replink
FROM   #tmp_scope_replink tmp, BTRAV..SCOPE_TREPLINK btrav
WHERE
    tmp.TOCTR_NF                         = btrav.TOCTR_NF
AND tmp.TOSEC_NF                         = btrav.TOSEC_NF
AND tmp.TOUWY_NF                         = btrav.TOUWY_NF
AND tmp.TOUW_NT                          = btrav.TOUW_NT
AND tmp.TOEND_NT                         = btrav.TOEND_NT
AND tmp.TOSECSTS_CT                      = btrav.TOSECSTS_CT
AND tmp.TOLOB_CF                         = btrav.TOLOB_CF
AND tmp.TOSSD_CF                         = btrav.TOSSD_CF
AND tmp.TOESB_CF                         = btrav.TOESB_CF
AND isnull(tmp.TOGRPINISTS_CT,0)         = isnull(btrav.TOGRPINISTS_CT,0)
AND isnull(tmp.TOPARINISTS_CT,0)         = isnull(btrav.TOPARINISTS_CT,0)
AND isnull(tmp.TOLOCINISTS_CT,0)         = isnull(btrav.TOLOCINISTS_CT,0)
AND tmp.FROMCTR_NF                         = btrav.FROMCTR_NF
AND tmp.FROMSEC_NF                         = btrav.FROMSEC_NF
AND tmp.FROMUWY_NF                         = btrav.FROMUWY_NF
AND tmp.FROMUW_NT                          = btrav.FROMUW_NT
AND tmp.FROMEND_NT                         = btrav.FROMEND_NT
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
AND isnull(tmp.FROMGRPFIRCLO_D,'19010101') = isnull(btrav.FROMGRPFIRCLO_D,'19010101')
AND isnull(tmp.FROMPARFIRCLO_D,'19010101') = isnull(btrav.FROMPARFIRCLO_D,'19010101')
AND isnull(tmp.FROMLOCFIRCLO_D,'19010101') = isnull(btrav.FROMLOCFIRCLO_D,'19010101')
AND	isnull(tmp.FROMGRPRATEINDEX_CT,'0')    = isnull(btrav.FROMGRPRATEINDEX_CT,'0')
AND	isnull(tmp.FROMPARRATEINDEX_CT,'0')    = isnull(btrav.FROMPARRATEINDEX_CT,'0')
AND	isnull(tmp.FROMLOCRATEINDEX_CT,'0')    = isnull(btrav.FROMLOCRATEINDEX_CT,'0')
AND isnull(tmp.FROMGRPANCO_NF,0)           = isnull(btrav.FROMGRPANCO_NF,0)
AND isnull(tmp.FROMPARANCO_NF,0)           = isnull(btrav.FROMPARANCO_NF,0)
AND isnull(tmp.FROMLOCANCO_NF,0)           = isnull(btrav.FROMLOCANCO_NF,0)
AND isnull(tmp.FROMRECOD_D,'19010101')     = isnull(btrav.FROMRECOD_D,'19010101')
AND tmp.CLODAT_D = btrav.CLODAT_D


------------------------------------------------------------------------------
-- ETAPE FINALE : DELETE SPIRA 112620
------------------------------------------------------------------------------
DELETE #tmp_scope_replink
FROM   #tmp_scope_replink tmp, BTRAV..SCOPE_TREPLINK btrav
WHERE
    tmp.TOCTR_NF                         = btrav.TOCTR_NF
AND tmp.TOSEC_NF                         = btrav.TOSEC_NF
AND tmp.TOUWY_NF                         = btrav.TOUWY_NF
AND tmp.TOUW_NT                          = btrav.TOUW_NT
AND tmp.TOEND_NT                         = btrav.TOEND_NT
AND tmp.FROMCTR_NF                         = btrav.FROMCTR_NF
AND tmp.FROMSEC_NF                         = btrav.FROMSEC_NF
AND tmp.FROMUWY_NF                         = btrav.FROMUWY_NF
AND tmp.FROMUW_NT                          = btrav.FROMUW_NT
AND tmp.FROMEND_NT                         = btrav.FROMEND_NT
AND btrav.ISTREATED_B = 1
AND tmp.CLODAT_D > btrav.CLODAT_D 


INSERT INTO BTRAV..SCOPE_TREPLINK
SELECT * FROM #tmp_scope_replink

-- FIN NORMALE DE LA PROC

error:

Return 0
DROP TABLE  #tmptreplink
PRINT '-- FIN de la procedure bret..PsTRT_TREPLINK_01'
 
go
EXEC sp_procxmode 'PsTRT_TREPLINK_01', 'unchained'
go
IF OBJECT_ID('PsTRT_TREPLINK_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsTRT_TREPLINK_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsTRT_TREPLINK_01 >>>'
go
GRANT EXECUTE ON PsTRT_TREPLINK_01 TO GOMEGA
go
GRANT EXECUTE ON PsTRT_TREPLINK_01 TO GDBBATCH
go
