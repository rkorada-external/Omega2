use BEST
go
if object_id('PsPERITRT_03') is not null
begin
  drop procedure PsPERITRT_03
  if object_id('PsPERITRT_03') is not null
    print '<<< FAILED DROPPING procedure PsPERITRT_03 >>>'
  else
    print '<<< DROPPED procedure PsPERITRT_03 >>>'
end
go
create procedure PsPERITRT_03
(
@p_segtyp_ct  char(1) --type de segmentation 'A' ou 'E'
)
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME67 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: - génération d'une table intermédiaire identique à BTRT..TFAMRSVPBIS mais où le champs
                            ERNPRMADM_B est défini en DEFAULT 1 au lieu de DEFAULT 0
                          - génération au niveau CASEX du périmètre pour les affaires TRT non comptabilisables
                           (on descend le perimetre complementaire à celui fourni par la proc PsPERITRT_02)
Conditions d'execution:
Commentaires:
________________
MODIFICATION 1
Auteur: M.Ha-Thuc
Date: 15/09/98
Description: - rajout de champs supplémentaires (non utilisés) pour conserver une structure identique à tous les périmètres.
_________________
MODIFICATION 2
Auteur: M.Ha-Thuc
Date: 08/10/1998
Description: - suppression de la jointure avec la table BCLI..TCLREPCR ( qui était fausse !! ), qui permettait de récupérer le champs ORDNBR_NT. Cette donnée n'est pas utilisée par la vie.
_________________
MODIFICATION 3
Auteur: M.Bourdaillet
Date: 05/03/1999
Description: Rajout de six champs pour la segmentation client. Mais pour ce perimetre les champs n'ontpas besoin d'etre renseignés; ils sont donc forces à null
_________________
MODIFICATION 4
Auteur: O.Arik(AURA)
Date: 30/03/2001
Description: Ajout de RECBRK_B (Indic d'existance de courtage sur REC) et de RECBRK_R (taux de court. sur reconstitution) dans le select. on renseigne le champ ORGCED_NF dans le select.
_________________
MODIFICATION 5
Auteur: M. DJELLOULI
Date: 18/05/2005
Description: Sélection des Enregistrements de TFAMCHG pour les postes à Risques
             SPOT 11772 - 11775 - Postes à Risques - SOX
             NB : Important! Concernant COMTYP_CT , la Valeur COMTYP_CT=4 ("Estimation Manuelle") n'existe plus.
                  Elle est remplacée par la Valeur ESTCOMTYP_CT=1.
                  Donc, COMTYP_CT prend toutes les Valeurs sauf 4.
                  Pour le traitement ESID2000 (ESTC1015), on simule COMTYP_CT=4 quand ESTCOMTYP_CT=1
                  IDEM pour CTBTYP_CT et ESTCTBTYP_CT
                  Valeur de ESTCTBTYP_CT & ESTCOMTYP_CT : Manuel=1, A Vérifier=2, null
_________________
MODIFICATION 6
Auteur: M. DJELLOULI
Date: 25/10/2005
Description: Inclusion ESTCOMTYP_CT, ESTCBTTYP_CT, ESTREITYP_CT, ESTPRMTYP_CT à Test null null Equivalence à Estimation Manuelle (Valeur = 1)
_________________
MODIFICATION 7
Auteur: M. DJELLOULI
Date: 26/01/2006
Description: Inclusion ESTCOMTYP_CT, ESTCBTTYP_CT, ESTREITYP_CT, ESTPRMTYP_CT à Test null null Equivalence à Estimation Manuelle (Valeur = 3)
_________________
MODIFICATION 8 (MOD08)
Auteur: Dominique OURMIAH
Date: 25/08/2008
Description: SPOT 15954 - Correction pb de lenteur à l'execution du ESID0060.cmd
_________________
MODIFICATION 9 (MOD09)
Description : Removed dbo and added ‘with execute as caller as’
_________________
10 Florent 20/11/2014 :spot:27747 Multi Currency - ajout colonnes sur le périmètre
                      :spot:27748 Loss Corridor  - ajout colonnes sur le périmètre
11 P. Menant     02/03/2015 :spot:28306 EST37
[012] D. Fillinger  03/06/2015 :spot28472 EST41 ajout USGAAP et taux manquants
[013] R. Cassis     01/09/2015 :spot:29052 On extrait pas les traites en statut invalide pour ne plus faire d'estimations
[014] -=Dch=-       10/02/2016 :spot:30167 Modification de la colonne ESTV2C_COL_17 pour les nouveaux calculs de commissions 
[015] R. Cassis     31/05/2015 :spot:30167 Re-annulation de la modif spot 29052
[027] S.Behague     16/08/2016 :spot:31066 Spira 52504 - Prise en compte poste PMD
[028] MZM           05/02/2018 :spira:42213      and CTRLCK_B <> 1 -- Traites Invalides ne sont plus estimes	
[029] MZM			13/02/2018 :spira:57585 Ajout d'une nouvelle valeur "Suivi Closing" dans la codification TRAITE / ESTCOMTYP_CT
[030] MZM     18/06/2018 :spira:57585 La nouvelle valeur "Suivi Closing" fonctionne comme la valeur "Automatic"
[031] S.Behague     20/09/2019 :spira:60627 - PPrise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro
[032] 10/09/2019 S.Behague :REQ_9.2: REQ.P.9.2 - Change in UPR calculation rules
************************************************************************************/
declare @erreur      int

select @erreur = 0

-- creation d'une table temporaire #TFAMRSVPBIS
create table #TFAMRSVPBIS(
    CTR_NF       UCTR_NF              NOT null,
    UWY_NF       UUWY_NF              NOT null,
    UW_NT        UUW_NT               DEFAULT  1,
    END_NT       UEND_NT              DEFAULT  0,
    SEC_NF       USEC_NF              NOT null,
    ERNPRMADM_B  tinyint                  null,
    POLDURMTH_NF UPERIOD              DEFAULT 12,
    INSPOL_R     USHORAT_R            DEFAULT 1,
    URRCAL_R     USHORAT_R            NULL,     --MODIF 012
    POLED_D      datetime      NULL )           -- [032]

-- Alimentation de la table #TFAMRSVPBIS
insert into #TFAMRSVPBIS
select CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, ERNPRMADM_B, POLDURMTH_NF, INSPOL_R, URRCAL_R, POLED_D   --MODIF 012
from BTRT..TFAMRSVP
select @erreur = @@error
if @erreur != 0  goto fin

/* Création d'un index sur la table temporaire #TFAMRSVPBIS */
/* -------------------------------------------------------- */
create index IFAMRSVP on #TFAMRSVPBIS( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF )

-- Périmètre pour les traités et facs multifiliale
-- Affaires non comptabilisables
-- Cas multifiliale (inventaire)
-- La liste des filiales est dans la table BTRAV..TESTSSD


create table #TCLI(
   CLI_NF        UCLI_NF   NOT NULL,
   CLIRESSSD_CF  USSD_CF   NULL,
   HORDNBR_NT    int       NULL)
select @erreur = @@error
if @erreur != 0  goto fin

insert into #TCLI
select a.CLI_NF, a.CLIRESSSD_CF, A.HORDNBR_NT
 from BCLI..TCLIENT a, BCLI..TCLINTSU b, BTRAV..TESTSSD ESTSSD
  where a.CLI_NF = b.CLI_NF
    and a.CLIRESSSD_CF = b.CLIINTSSD_CF
    and a.HORDNBR_NT != null
		and b.CLIINTSSD_CF=ESTSSD.SSD_CF
select @erreur = @@error
if @erreur != 0  goto fin

create index ICLI on #TCLI( CLI_NF ) 
select @erreur = @@error
if @erreur != 0  goto fin

-- MOD08
set forceplan on

select
  SECTION.SSD_CF,
  @p_segtyp_ct,
  SECTION.CTR_NF,
  SECTION.END_NT,
  SECTION.SEC_NF,
  SECTION.UWY_NF,
  SECTION.UW_NT,
  ACCESB_CF,
  ADMMODPRM_CT,
  ANLCTY_CF,
  convert(char(8), CAN_DT, 112),
  CED_NF,
  CLICTY_CF,
  CLINAT_CF,
  CLMACT_M,
  COMTYP_CT=(case when ESTCOMTYP_CT=3 then 4                               -- MOD007 ESTCOMTYP_CT=1 then 4
				 					when ESTCOMTYP_CT=4 then 2                               -- MOD029 ESTCOMTYP_CT=4 then 4 -- [030] le 18/06/2018 then 2 (au lieu de 4 )
                 	when ESTCOMTYP_CT=null then 4
                  else COMTYP_CT
            end),                                                         -- MOD005 - MDJ 20/05/2005 + MOD006 MDJ 20/10/2005
  CTBGENFEE_R,
  CTBTYP_CT=(case when ESTCBTTYP_CT=3 then 4                               -- MOD007 ESTCBTTYP_CT=1 then 4
                 when ESTCBTTYP_CT=null then 4
                 else CTBTYP_CT
            end),           -- MOD005 - MDJ 20/05/2005 + MOD006 MDJ 20/10/2005
  convert(char(8), CTRINC_D, 112),
  CLISSD_CF, -- Permet l'affectation de CTRRET_B
  CUTSHA_R,
  0,
  EGPCUR_CF,
  CONTR.ESTCRB_CT,
  ESTCTR_NF,
  ESTEND_B,
  null, -- ESTSEC_NF par defaut
  convert(char(8), SCOEXP_D, 112), -- EXP_D par defaut
  FIXCOM_R,
  SECTION.FRSUWY_NF,
  GANPAYORD_NT,
  GAR_CF,
  GENPRMPAY_NF,
  GENPRMSEN_NF,
  isnull(INSPOL_R,1),
  LAYCAP_M,
  LIFTRTTYP_CF,
  LOB_CF,
  LOSCOREXI_B,
  LOSCORHIG_R,
  LOSCORLOW_R,
  LOSCORRAT_R,
  LOSCTB_R,
  LOSCTBEXI_B,
  MAXCOM_R,
  MAXRATCLP_R,
  MINCOM_R,
  MINRATCLP_R,
  NAT_CF,
  null,        -- modifs du 08/10/1998, le champs ORDNBR_NT est forcé à null
  PCPCUR_CF,
  PCPRSKTRY_CF,
  isnull(POLDURMTH_NF,12),
  PRD_NF,
  PRFCOM_R,
  PRFCOMEXI_B,
  PRMEFFLOA_M,
  PRMEFFLOA_R,
  PRMFIXEFF_R,
  PRMFLCRAT_B,
  PRMMAXEFF_R,
  PRMMINEFF_R,
  PRMNETCOM_B,
  PRMPRTSCL_B,
  REIEXI_B,
  REIFRE_B,
  REINBR_N,
  REIUNL_B,
  RESTRFDUR_N,
  RESTRFTYP_CF,
  SBJCPTDEF_B,
  DEFSBJPRM_M,  --SBJPRM_M par defaut
  SCLCOMEXI_B,
  SCLCTBEXI_B,
  SCOGLOEGP_M, --SCOEGP_M par defaut
  convert(char(8), SCOINC_D, 112),
  SECACCSTS_CT,
  convert(char(8), SECINC_D, 112),
  SECSTS_CT,
  SEG_NF,
  SOB_CF,
  SUBNAT_CF,
  SUPLOATYP_CT,
  TOP_CF,
  'N',     -- CTRNAT_CT par defaut
  UWGRP_CF,
  ACCFRQ_CT,
  WRKCAT_CT,
  convert(char(8), ORGINC_D, 112),
  LIARIDSHA_B,
  FLAPRM_B,
  RIDSHA_R,
  CTBCALLVL_CF,
  0, -- CTBCOM_B par defaut
  PRMPRT_M,
  PRMPRTCUR_CF,
  ACCADMTYP_CT,
  SBJPRMCUR_CF,
  CTRSTS_CT,
  OVRCOM_R,
  OVRCOMTYP_CT,
  TAXCNDEXI_B,
  PRDBRK_R,
  ACCBRK_R,
  LIACUR_CF,
  isnull(ERNPRMADM_B, 1),
  convert(char(8), SECCAN_D, 112), -- Permet l'affectation de EXP_D
  SCOORGEGP_M,                     -- Permet l'affectation de SCOEGP_M
  ESTSBJPRM_M,                     -- Permet l'affectation de SBJPRM_M
  SBJPRMCPT_M,                     -- Permet l'affectation de SBJPRM_M
  null, -- Correspond aux champs retro non utilises en acceptation
  null, -- Correspond aux champs retro non utilises en acceptation
  null, -- Correspond aux champs retro non utilises en acceptation
  null, -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
  SECTION.USRCRTCOD_CT,   -- Champ rajouté au perimètre, modif du 12/03/98
  SECTION.USRCRTVAL_LM,   -- Champ rajouté au perimètre, modif du 12/03/98
  FAMCHG.PRDBRKTYP_CT,        -- Champ rajouté au perimètre, modif du 20/03/98
  FAMCHG.ACCBRKTYP_CT,        -- Champ rajouté au perimètre, modif du 20/03/98
  CONTR.UWORG_CF     -- Champ rajouté au perimètre, modif du 26/05/98
 ,SECTION.SECQUA_CF
 ,SECTION.SECQUA2_CF
 ,SECTION.SECQUA3_CF
 ,SECTION.SECQUA4_CF
 ,SECTION.SECQUA5_CF
 ,CONTR.ADMGRP_CF
 ,CONTR.ORGCED_NF
 ,CONTR.REITYP_CF
 ,FAMCOTP.PRMMINACT_R
 ,FAMCOTP.PRMFIXACT_R
 ,FAMCOTP.PRMMAXACT_R
 ,FAMCOTP.CLMPRMACT_R
 ,FAMCOTP.FLAPRM1_M
 ,FAMCOTP.FLAPRMCU1_CF
 ,FAMCOTP.FLAPRM2_M
 ,FAMCOTP.FLAPRMCU2_CF
 ,FAMCOTP.FLAPRM3_M
 ,FAMCOTP.FLAPRMCU3_CF
 ,FAMCOTP.MINPRVPR1_M
 ,FAMCOTP.PRVPRMCU1_CF
 ,FAMCOTP.MINPRVPR2_M
 ,FAMCOTP.PRVPRMCU2_CF
 ,FAMCOTP.MINPRVPR3_M
 ,FAMCOTP.PRVPRMCU3_CF
 ,null
 ,FAMCOTP.PRVPRM_B
 ,FAMCOTP.DEFSBJPRM_M
 ,FAMCOTP.ESTSBJPRM_M
 ,FAMCOTP.SBJPRMCPT_M
 ,CONTR.CTRACCSTS_CT
 ,datepart( yy, CONTR.CTRACC_D )
 ,FAMLIA.PMLRAT_R
 ,CLI1.HORDNBR_NT
 ,CLREPCR1.SORDNBR_NT
 ,CLI2.HORDNBR_NT
 ,CLREPCR2.SORDNBR_NT
 ,CLI3.HORDNBR_NT
 ,CLREPCR3.SORDNBR_NT
 ,CONTR.FACADMTYP_B
 ,convert(char(8), CRTVRSINC_D, 112)
 ,RECBRK_B
 ,RECBRK_R
 ,CONTR.CNATYP_CT
 ,SECTION.CLMCUTOFF_B
 ,SECTION.PRMCUTOFF_B
 ,SECTION.CLMRUNOFF_B
 ,SECTION.PRMRUNOFF_B
 ,SECTION.ASSFINANCE_CT
 ,FAMCOTP.FLAPRM4_M
 ,FAMCOTP.FLAPRMCU4_CF
 ,FAMCOTP.FLAPRM5_M
 ,FAMCOTP.FLAPRMCU5_CF
 ,FAMCOTP.MINPRVPR4_M
 ,FAMCOTP.PRVPRMCU4_CF
 ,FAMCOTP.MINPRVPR5_M
 ,FAMCOTP.PRVPRMCU5_CF
 ,FAMCHG.ESTLOSCORTYP_CT
 ,ESTV2C_COL_01=null
 ,SECTION.USGAAP_CT        --MODIF 012
 ,FAMRSVP.URRCAL_R         --MODIF 012
 ,FAMFUNW.CLMFUN_R         --MODIF 012
 ,FAMFUNW.CLMFUNCAS_R      --MODIF 012
 ,FAMFUNW.CLMFUNINT_R      --MODIF 012
 ,FAMFUNW.URRFUN_R         --MODIF 012
 ,FAMFUNW.URRFUNCAS_R      --MODIF 012
 ,FAMFUNW.URRFUNINT_R      --MODIF 012
 ,ESTV2C_COL_10=null
 ,isnull(convert(int,ACCSNDDEL_N),0)+isnull(convert(int,STLREQDEL_N),0)+isnull(convert(int,CFLDEL_N),0)                        --MODIF 11
 ,"TRT"                                                                                                                        --MODIF 11
 ,convert(char(8), CTRINC_D, 112) 
 ,ESTV2C_COL_14=null
 ,ESTV2C_COL_15=null
 ,ESTV2C_COL_16=null
 --,ESTV2C_COL_17=null
 ,ESTV2C_COL_17=FAMCHG.COMBAS_CF
 ,FAMCOTP.PAYFRQ_CT
 ,convert ( char (8), FAMCOTP.FIRPAYDUE_D, 112)
 ,null
 ,null
 ,convert(char(8), FAMRSVP.POLED_D, 112)            -- modif [031] 
 ,ESTV2C_COL_23=null
 ,ESTV2C_COL_24=null
 ,ESTV2C_COL_25=null
 ,ESTV2C_COL_26=null
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,EST2VC_COL_30=null
 from BTRT..TSECTION SECTION,
      BTRT..TCONTR CONTR,
      BTRT..TFAMLIA FAMLIA,
      BTRT..TFAMCHG FAMCHG,
      BTRT..TFAMCOTP FAMCOTP,
      BTRT..TACCSEND ACCSEND,
      BCLI..TCLIENT CLIENT,
      #TFAMRSVPBIS FAMRSVP,
      BTRAV..TESTSSD ESTSSD,
      BCLI..TCLINTSU CLREPCR1,
      BCLI..TCLINTSU CLREPCR2,
      BCLI..TCLINTSU CLREPCR3,
      #TCLI CLI1,
      #TCLI CLI2,
      #TCLI CLI3,
      BTRT..TFAMFUNW FAMFUNW   --MODIF 012
  where SECTION.SSD_CF=ESTSSD.SSD_CF
    and (
           (SECSTS_CT NOT IN(14, 16, 17, 19, 23) )
          or
           (CTRSTS_CT NOT IN(14, 16, 17, 19, 23) )
          or
           (SECSTS_CT = 23 and LOB_CF not in ('30', '31') )
          or
           (CTRSTS_CT = 23 and LOB_CF not in ('30', '31') )
         )
       -- on decend les affaires non comptabilisables
    and SECTION.CTR_NF=CONTR.CTR_NF
    and SECTION.END_NT=CONTR.END_NT
    and SECTION.UWY_NF=CONTR.UWY_NF
    and SECTION.UW_NT=CONTR.UW_NT
    and CTRLCK_B <> 1 -- [028] Traites Invalides ne sont plus estimes	
    and SECTION.CTR_NF*=FAMLIA.CTR_NF
    and SECTION.END_NT*=FAMLIA.END_NT
    and SECTION.SEC_NF*=FAMLIA.SEC_NF 
    and SECTION.UWY_NF*=FAMLIA.UWY_NF
    and SECTION.UW_NT*=FAMLIA.UW_NT

    and SECTION.CTR_NF*=FAMCHG.CTR_NF 
    and SECTION.END_NT*=FAMCHG.END_NT
    and SECTION.SEC_NF*=FAMCHG.SEC_NF 
    and SECTION.UWY_NF*=FAMCHG.UWY_NF
    and SECTION.UW_NT*=FAMCHG.UW_NT

    and SECTION.CTR_NF*=FAMCOTP.CTR_NF 
    and SECTION.END_NT*=FAMCOTP.END_NT
    and SECTION.SEC_NF*=FAMCOTP.SEC_NF 
    and SECTION.UWY_NF*=FAMCOTP.UWY_NF
    and SECTION.UW_NT*=FAMCOTP.UW_NT

    and SECTION.CTR_NF*=ACCSEND.CTR_NF
    and CONTR.CED_NF*=CLIENT.CLI_NF

    and SECTION.CTR_NF*=FAMRSVP.CTR_NF 
    and SECTION.END_NT*=FAMRSVP.END_NT
    and SECTION.SEC_NF*=FAMRSVP.SEC_NF 
    and SECTION.UWY_NF*=FAMRSVP.UWY_NF
    and SECTION.UW_NT*=FAMRSVP.UW_NT

    and SECTION.CTR_NF*=FAMFUNW.CTR_NF --MODIF 012
    and SECTION.END_NT*=FAMFUNW.END_NT --MODIF 012
    and SECTION.SEC_NF*=FAMFUNW.SEC_NF --MODIF 012
    and SECTION.UWY_NF*=FAMFUNW.UWY_NF --MODIF 012
    and SECTION.UW_NT*=FAMFUNW.UW_NT   --MODIF 012

    and CONTR.CED_NF*=CLI1.CLI_NF
    and CONTR.CED_NF*=CLREPCR1.CLI_NF
    and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF
    and CONTR.ORGCED_NF*=CLI2.CLI_NF
    and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
    and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF
    and CONTR.PRD_NF*=CLI3.CLI_NF
    and CONTR.PRD_NF*=CLREPCR3.CLI_NF
    and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF

select @erreur = @@error
if @erreur != 0  goto fin
-- MOD08
set forceplan off
return 0

fin:
return 1
go
if object_id('PsPERITRT_03') is not null
    print '<<< CREATED procedure PsPERITRT_03 >>>'
else
    print '<<< FAILED CREATING procedure PsPERITRT_03 >>>'
go
grant execute on PsPERITRT_03 TO GOMEGA, GDBBATCH
go
