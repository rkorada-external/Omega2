use BEST
go
if object_id('PsPERIFAC_03') is not null
begin
  drop PROC PsPERIFAC_03
  print '<<< DROPPED PROC PsPERIFAC_03 >>>'
end
go
create procedure PsPERIFAC_03
(
@p_segtyp_ct char(1) --type de segmentation ( 'A' ou 'E' )
)
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME67 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    - génération d'une table intermédiaire regroupant la dernière ligne de BEST..TCTRULT
( CRE_D maxi ) pour un CASEX donné afin de récupérer le champs ADMMODPRM_CT
    - génération du périmètre pour les affaires FAC non comptalisables au niveau
(descente du perimetre complementaire à celui descendu par la proc PsPERIFAC_02
    - le filtre sur la date d effet est fait ulterieurement par un programme C
Conditions d'execution:
Commentaires:
________________
MODIFICATION 1
Auteur: M.Ha-Thuc
Date: 15/09/98
Description: - rajout de champs supplémentaires (non utilisés) pour conserver une
structure identique à tous les périmètres.
_________________
MODIFICATION 2
Auteur: M.Ha-Thuc
Date: 08/10/1998
Description: - suppression de la jointure avec la table BCLI..TCLREPCR ( qui était fausse !! ),
qui permettait de récupérer le champs ORDNBR_NT. Cette donnée n'est pas utilisée par la vie.
_________________
MODIFICATION 3
Auteur: M.Bourdaillet
Date: 05/03/1999
Description: Rajout de six champs pour la segmentation client. Mais pour ce perimetre les champs n'ontpas besoin d'etre renseignés; ils sont donc forces à null
_________________
MODIFICATION 4
Auteur: MONTAGNAC(ASCOTT)
Date: 25/08/1999
Description: Ajout du bit FACADMTYP_B dans le select.
_________________
MODIFICATION 5
Auteur: FCharles
Date: 06/05/2000
Description: Ajout de la date CRTVRSINC_D dans le select.
_________________
MODIFICATION 6
Auteur: O.Arik(AURA)
Date: 30/03/2001
Description: Ajout de RECBRK_B (Indic d'existance de courtage sur REC) et de RECBRK_R (taux de court. sur reconstitution) dans le select. on renseigne le champ ORGCED_NF dans le select.
________________
MODIFICATION 7
Description : Removed and added ‘with execute as caller as’
________________
8 Florent       20/11/2014 :spot:27747 Multi Currency - ajout colonnes sur le périmètre
                           :spot:27748 Loss Corridor  - ajout colonnes sur le périmètre
9 P. Menant     02/03/2015 :spot:28306 EST37

[10] -=Dch=-       10/02/2016 :spot:30167 Modification de la colonne ESTV2C_COL_17 pour les nouveaux calculs de commissions 
[11]  05/02/2018 MZM : spira 42213 Arret des estimations pour Traites invalides CTRLCK_B = 1 et Fac Dont Avenant invalides CTRLCK_B =0 
************************************************************************************/
declare @erreur      int

select @erreur = 0

/* creation d'une table temporaire #TCTRULTBIS */
/* ------------------------------------------- */
create table #TCTRULTBIS(
    CTR_NF      UCTR_NF     not null,
    END_NT      UEND_NT     not null,
    SEC_NF      USEC_NF     not null,
    UWY_NF      UUWY_NF     not null,
    UW_NT       UUW_NT          not null,
    ADMMODPRM_CT    char(1)     DEFAULT 'M',
    CRE_D       datetime        null )


/* Recherche de la dernière ligne de TCTRULTBIS pour un CASEX donné */
/* ------------------------------------------------------------- */

-- Cas multifiliale (inventaire)
-- La liste des filiales est dans la table BTRAV..TESTSSD

    insert into #TCTRULTBIS
    select T1.CTR_NF, T1.END_NT, T1.SEC_NF, T1.UWY_NF, T1.UW_NT, T1.ADMMODPRM_CT, T1.CRE_D
    from BEST..TCTRULT T1, BTRAV..TESTSSD T2
    where T1.SSD_CF = T2.SSD_CF
    and T1.CRE_D = ( select max( T3.CRE_D )
        from BEST..TCTRULT T3
        where   T1.CTR_NF = T3.CTR_NF and
                     T1.END_NT = T3.END_NT and
                     T1.SEC_NF = T3.SEC_NF and
                     T1.UWY_NF= T3.UWY_NF  and
                     T1.UW_NT = T3.UW_NT )

select @erreur = @@error

if @erreur != 0  goto fin


/* Création d'un index sur la table temporaire #TCTRULTBIS */
/* ------------------------------------------------------- */

create index ICTRULT on #TCTRULTBIS ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT )


-- Périmètre pour les facs multifiliale
-- Affaires non comptabilisables

select   SECTION.SSD_CF,
       @p_segtyp_ct,
     SECTION.CTR_NF,
     SECTION.END_NT,
     SECTION.SEC_NF,
     SECTION.UWY_NF,
     SECTION.UW_NT,
     ACCESB_CF,
       isnull( CTRULT.ADMMODPRM_CT, 'M' ),
     ANLCTY_CF,
     convert(char(8), CAN_DT, 112),
     CED_NF,
       CLICTY_CF,
       CLINAT_CF,
       null,
       1,           -- En Facs, il s agit toujours de commissions fixes
       CTBGENFEE_R,
       CTBTYP_CT,
     convert(char(8), CTRINC_D, 112),
       CLISSD_CF, -- Permet l'affectation de CTRRET_B
       CUTSHA_R,
     DIV_NT,
       EGPCUR_CF,
       CONTR.ESTCRB_CT,
       ESTCTR_NF,
       ESTEND_B,
       null, -- ESTSEC_NF par defaut
       convert(char(8), CTREXP_D, 112),
       FIXCOM_R,
     SECTION.FRSUWY_NF,
     GANPAYORD_NT,
     GAR_CF,
     GENPRMPAY_NF,
     GENPRMSEN_NF,
       null, -- Non renseigne pour les facs
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
       null,            -- modifs du 08/10/1998, le champs ORDNBR_NT est forcé à null
     PCPCUR_CF,
     PCPRSKTRY_CF,
       null,  -- Non renseigne pour les facs
     PRD_NF,
       PRFCOM_R,
       PRFCOMEXI_B,
       null,
       null,
       null,
       null,
       null,
       null,
       PRMNETCOM_B,
       null, -- Non renseigne pour les facs
       REIEXI_B,
       REIFRE_B,
       REINBR_N,
       REIUNL_B,
       RESTRFDUR_N,
       RESTRFTYP_CF,
       null,
       null,
       SCLCOMEXI_B,
       SCLCTBEXI_B,
       SCOADDEGP_M, -- SCOEGP_M par defaut anciennement scogloegp (23/04/99)
    convert(char(8), SCOINC_D, 112),
     SECACCSTS_CT,
         convert(char(8), CTRINC_D, 112),  -- Affectation de SECINC_D
     SECSTS_CT,
       SEG_NF,
     SOB_CF,
     SUBNAT_CF,
       null,
     TOP_CF,
       'F',     -- CTRNAT_CT
     UWGRP_CF,
       null,
       null,     -- Non renseigne pour les facs
       convert(char(8), ORGINC_D, 112),
       LIARIDSHA_B,
       null,
       RIDSHA_R,
       CTBCALLVL_CF,
       null, -- Non renseigne pour les facs
       null,
       null,
       ACCADMTYP_CT,
       null,
       CTRSTS_CT,
       OVRCOM_R,
       OVRCOMTYP_CT,
       TAXCNDEXI_B,
       PRDBRK_R,
       ACCBRK_R,
       null, -- LIACUR_CF : non utilisé pour les facs
       null, -- ERNPRMADM_B : non utilisé pour les facs

       convert(char(8), SECCAN_D, 112), -- Permet l'affectation de EXP_D
       SCOORGEGP_M,                     -- Permet l'affectation de SCOEGP_M

       null, -- Correspond aux champs retro non utilises en acceptation
     null, -- Correspond aux champs retro non utilises en acceptation
       null, -- Correspond aux champs retro non utilises en acceptation
       null, -- Correspond aux champs retro non utilises en acceptation
       null, -- Correspond aux champs retro non utilises en acceptation
       null, -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire

    SECTION.USRCRTCOD_CT,   -- Champ rajouté au perimètre, modif du 12/03/98
    SECTION.USRCRTVAL_LM,   -- Champ rajouté au perimètre, modif du 12/03/98

    FAMCHG.PRDBRKTYP_CT,        -- Champ rajouté au perimètre, modif du 20/03/98
    FAMCHG.ACCBRKTYP_CT,        -- Champ rajouté au perimètre, modif du 20/03/98

    CONTR.UWORG_CF,     -- Champ rajouté au perimètre, modif du 26/05/98

    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    CONTR.ORGCED_NF,   -- ce champs est renseigné à partir de la modif(006) 30/03/2001
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98
    null,   -- Champ non utilisé, modif du 15/09/98

    null,   -- Champ non utilisé (segmentation client), modif 003
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,    -- Champ non utilisé (segmentation client), modif 003
    FACADMTYP_B, --modif 4
    convert(char(8), CRTVRSINC_D, 112)  --MODIF 005
    ,RECBRK_B=null -- Champ non utilisé, modif 006
    ,RECBRK_R=null -- Champ non utilisé, modif 006
 ,CNATYP_CT=null
 ,CLMCUTOFF_B=null
 ,PRMCUTOFF_B=null
 ,CLMRUNOFF_B=null
 ,PRMRUNOFF_B=null
 ,ASSFINANCE_CT=null
 ,FLAPRM4_M=null
 ,FLAPRMCU4_CF=null
 ,FLAPRM5_M=null
 ,FLAPRMCU5_CF=null
 ,MINPRVPR4_M=null
 ,PRVPRMCU4_CF=null
 ,MINPRVPR5_M=null
 ,PRVPRMCU5_CF=null
 ,ESTLOSCORTYP_CT=null
 ,ESTV2C_COL_01=null
 ,ESTV2C_COL_02=null
 ,ESTV2C_COL_03=null
 ,ESTV2C_COL_04=null
 ,ESTV2C_COL_05=null
 ,ESTV2C_COL_06=null
 ,ESTV2C_COL_07=null
 ,ESTV2C_COL_08=null
 ,ESTV2C_COL_09=null
 ,ESTV2C_COL_10=null
 ,0                                                                                    --MODIF 9
 ,"FAC"                                                                                --MODIF 9
 ,convert(char(8), CTRINC_D, 112)                                                      --MODIF 9
 ,ESTV2C_COL_14=null
 ,ESTV2C_COL_15=null
 ,ESTV2C_COL_16=null
 --,ESTV2C_COL_17=null
 ,ESTV2C_COL_17=FAMCHG.COMBAS_CF
 ,ESTV2C_COL_18=null
 ,ESTV2C_COL_19=null
 ,ESTV2C_COL_20=null
 ,ESTV2C_COL_21=null
 ,ESTV2C_COL_22=null
 ,ESTV2C_COL_23=null
 ,ESTV2C_COL_24=null
 ,ESTV2C_COL_25=null
 ,ESTV2C_COL_26=null
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,EST2VC_COL_30=null
 from     BFAC..TSECTION SECTION,
     BFAC..TCONTR CONTR,
     BFAC..TFAMLIA FAMLIA,
     BFAC..TFAMCHG FAMCHG,
     BCLI..TCLIENT CLIENT,
--   BCLI..TCLREPCR CLREPCR,    - modifs du 08/10/1998
       BTRAV..TESTSSD ESTSSD,
    #TCTRULTBIS CTRULT

where  SECTION.SSD_CF=ESTSSD.SSD_CF
  and CTRLCK_B <> 0 -- modif 11 Arret EStimations Avenant FAC invalides
  and ( SECSTS_CT NOT IN(16, 18, 19) or CTRSTS_CT  NOT IN(16, 18, 19) )
  -- affaires non comptabilisables
  and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT
  and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
  
  and SECTION.CTR_NF*=FAMLIA.CTR_NF and SECTION.END_NT*=FAMLIA.END_NT
  and SECTION.SEC_NF*=FAMLIA.SEC_NF and SECTION.UWY_NF*=FAMLIA.UWY_NF
  and SECTION.UW_NT*=FAMLIA.UW_NT
  
  and SECTION.CTR_NF*=FAMCHG.CTR_NF and SECTION.END_NT*=FAMCHG.END_NT
  and SECTION.SEC_NF*=FAMCHG.SEC_NF and SECTION.UWY_NF*=FAMCHG.UWY_NF
  and SECTION.UW_NT*=FAMCHG.UW_NT
  
  and SECTION.CTR_NF*=CTRULT.CTR_NF and SECTION.END_NT*=CTRULT.END_NT
  and SECTION.SEC_NF*=CTRULT.SEC_NF and SECTION.UWY_NF*=CTRULT.UWY_NF
  and SECTION.UW_NT*=CTRULT.UW_NT
  
  and CONTR.CED_NF*=CLIENT.CLI_NF
  --   and CONTR.CED_NF*=CLREPCR.CLI_NF and CONTR.SSD_CF*=CLREPCR.SSD_CF  - modifs du 08/10/1998

select @erreur = @@error
if @erreur != 0  goto fin
/***********************************************************************************/
return 0

fin:
return 1
go
if object_id('PsPERIFAC_03') is not null
  print '<<< CREATED PROC PsPERIFAC_03 >>>'
else
  print '<<< FAILED CREATING PROC PsPERIFAC_03 >>>'
go
grant execute on PsPERIFAC_03 TO GOMEGA, GDBBATCH
go
