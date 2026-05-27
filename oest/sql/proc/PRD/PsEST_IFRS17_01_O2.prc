USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_01_O2
    IF OBJECT_ID('PsEST_IFRS17_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_01_O2 >>>'
END
go
create procedure PsEST_IFRS17_01_O2 (
@ano int output
)
AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Riyadh
Creation date     : 09/07/2018

Description       : 
_________________
Modification: MOD1 
Author: Riyadh  
Date: 07/03/2019 
Description: Spira 75669 update estcrb_cf for all uwy in TCONTR and TSECTION
*************************

Modification: MOD2 
Author: Riyadh  
Date: 27/03/2019 
Description: Spira 76819 

*************************

Modification: MOD3
Author: Riyadh  
Date: 27/03/2019 
Description: Spira 77000 

*************************

Modification: MOD4
Author: Michael  
Date: 09/05/2019 
Description: Spira 77000 
_________________
*/

DECLARE
  @nbSite int,
  @nbligne_TANO INT,
  @nbligne_STEP3 INT,
  @nbligne_PERIMETER INT,
  @nbligne_STEP1a INT,
  @nbligne_STEP1b INT,
  @nbligne_STEP7 INT,
  @nbligne_STEP8 INT,
  @error_type INT,
  @MsgAnomalie varchar(128),
  @MsgAnomalie1 varchar(128),
  @AnomalieCode varchar(32),
  @blcshtyea_nf smallint,
  @blcshtmth_nf tinyint,
  @erreur      int,
  @tran_imbr   bit,
  @p_erreur       varchar(64),
  @TcontrCount int,
  @TretctrCount int,
  @TlifestCount bigint,
  @TlifdriCount bigint,
  @TliflodCount int,
  @Tlifmod2Count int,
  @p_msg      varchar(64),
  @CountPeri int
  
CREATE TABLE #TANO_TMP
(
    CTR_NF       UCTR_NF        NULL,
    UWY_NF	     UUWY_NF        NULL,
    ANO_CT       int            NULL,
    ANOCODE_LL   varchar(32)    NULL,
    ANO_LL       varchar(128)   NULL
)  

CREATE TABLE #TLOADING_STEP3
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL
)
CREATE TABLE #TLOADING_STEP9
(
  CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
  MAXUWY_NF	UUWY_NF				NULL
)

CREATE TABLE #TRETRO
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	OLD_ESTCRB_CT char    NULL,
  NEW_ESTCRB_CT char    NOT NULL
)
CREATE TABLE #TRETCTR
(
    RETCTR_NF     URETCTR_NF    NOT NULL,
    RTY_NF        UUWY_NF       NOT NULL,
    RETCTRCAT_CF  char(2)       DEFAULT ''        NOT NULL,
    SSD_CF        USSD_CF       NOT NULL,
    CTRORI_CF     char(2)       DEFAULT ''        NOT NULL,
    CTRPCPNAM_LL  UL64          NOT NULL,
    FLABRK_NF     UCLI_NF       NULL,
    EXCTYP_CF     int           NULL,
    PROTRTPRO_B   bit           DEFAULT 0         NOT NULL,
    NPRTRTPRO_B   bit           DEFAULT 0         NOT NULL,
    PROFACPRO_B   bit           DEFAULT 0         NOT NULL,
    NPRFACPRO_B   bit           DEFAULT 0         NOT NULL,
    USGVTVAL_B    bit           DEFAULT 0         NOT NULL,
    SSDRTO_B      bit           DEFAULT 0         NOT NULL,
    CLECUTPER_NB  int           NULL,
    QSLIA_B       bit           DEFAULT 0         NOT NULL,
    LSTREI_NB     int           DEFAULT 0         NOT NULL,
    MULCURCTR_B   bit           DEFAULT 0         NOT NULL,
    RAICOM_B      bit           DEFAULT 1         NOT NULL,
    RETPCPCUR_CF  UCUR_CF       DEFAULT ''        NOT NULL,
    ORICUR_B      bit           DEFAULT 0         NOT NULL,
    CTRINC_D      datetime      NULL,
    CTREXP_D      datetime      NULL,
    CAN_DT        datetime      NULL,
    RETCTRSTS_CT  URETCTRSTS_CT NOT NULL,
    CTRSTS_D      datetime      NOT NULL,
    PRG_NF        UCTRGRP_NF    DEFAULT ''        NOT NULL,
    INTCASBAL_R   USHORAT_R     NULL,
    INTTECBAL_R   USHORAT_R     NULL,
    ESB_CF        UESB_CF       NOT NULL,
    PNO_D         datetime      NULL,
    PNORMD_D      datetime      NULL,
    PNOPRE_N      int           NULL,
    RETROJCTR_B   bit           DEFAULT 0         NOT NULL,
    PRORETCTR_B   bit           DEFAULT 0         NOT NULL,
    REISSD_LS     UL16          NULL,
    RETCTRCMU_D   datetime      NULL,
    REPRETCTR_NF  URETCTR_NF    DEFAULT ''        NOT NULL,
    REIRETCTR_NF  URETCTR_NF    DEFAULT ''        NOT NULL,
    RETCANMOD_CT  URETCANMOD_CT NULL,
    LEARTO_NF     UCLI_NF       NULL,
    RETACCADM_B   bit           DEFAULT 0         NOT NULL,
    PROPER_N      int           NULL,
    EXCCMT_NT     UCMT_NT       NULL,
    CLACMT_NT     UCMT_NT       NULL,
    DEPCON_B      bit           DEFAULT 0         NOT NULL,
    ADMUSR_CF     UUPDUSR_CF    DEFAULT user      NOT NULL,
    ACCUSR_CF     UUPDUSR_CF    DEFAULT user      NOT NULL,
    CONRETCTR_B   bit           DEFAULT 0         NOT NULL,
    CLECUTPER_B   bit           DEFAULT 0         NOT NULL,
    TERCTR_B      bit           DEFAULT 0         NOT NULL,
    RETACCTYP_CT  tinyint       NULL,
    CRE_D         UUPD_D        DEFAULT getdate() NOT NULL,
    CREUSR_CF     UUPDUSR_CF    DEFAULT user      NOT NULL,
    LSTUPD_D      UUPD_D        DEFAULT getdate() NOT NULL,
    LSTUPDUSR_CF  UUPDUSR_CF    DEFAULT user      NOT NULL,
    [Timestamp]   timestamp     NULL,
    CTRINCUWY_D   datetime      NULL,
    LIFTRTTYP_CF  char(2)       DEFAULT ''        NOT NULL,
    SUPPRG_NF     UCTRGRP_NF    DEFAULT ""        NULL,
    ESTCRB_CT     char(1)       DEFAULT "0"       NULL,
    FINTYP_CF     UBANVAL_CT    NULL,
    RECAPINFO_CF  UBANVAL_CT    NULL,
    POSSRECAP_CF  UBANVAL_CT    NULL,
    POSSRECAP_NT  int           NULL,
    AUTOCALC_B    bit           DEFAULT 0         NOT NULL,
    EVENT_B       bit           DEFAULT 0         NOT NULL,
    RISK_B        bit           DEFAULT 0         NOT NULL,
    AUTORENEW_B   bit           DEFAULT 0         NOT NULL,
    DELAYRENEW_NF int           NULL,
    CLOFAM_CT     UBANVAL_CT    NULL,
    ACCFAM_CT     UBANVAL_CT    NULL,
    FACPRG_B      bit           DEFAULT 0         NOT NULL,
    FACIND_B      bit           DEFAULT 0         NOT NULL)
    
    
    
    
CREATE TABLE #TASSUMED
(
  CTR_NF UCTR_NF			  NULL,
  UWY_NF	UUWY_NF				NULL,
	OLD_ESTCRB_CT char    NULL,
  NEW_ESTCRB_CT char    NOT NULL
)


CREATE TABLE #TCONTR
(
    CTR_NF              UCTR_NF    NOT NULL,
    UWY_NF              UUWY_NF    NOT NULL,
    UW_NT               UUW_NT     DEFAULT 1         NOT NULL,
    END_NT              UEND_NT    DEFAULT 0         NOT NULL,
    SSD_CF              USSD_CF    NOT NULL,
    CTRTYP_CT           UCTRTYP_CT NOT NULL,
    CTRINC_D            datetime   NULL,
    SCOINC_D            datetime   NULL,
    ORGINC_D            datetime   NULL,
    CTREXP_D            datetime   NULL,
    ORGEXP_D            datetime   NULL,
    SCOEXP_D            datetime   NULL,
    CED_NF              UCLI_NF    NULL,
    CEDOFF_NF           UCLI_NF    NULL,
    CNC_B               bit        DEFAULT 0         NOT NULL,
    DIRUW_B             bit        DEFAULT 0         NOT NULL,
    PRD_NF              UCLI_NF    NULL,
    PRDOFF_NF           UCLI_NF    NULL,
    GENPRMPAY_NF        UCLI_NF    NULL,
    GANPAYORD_NT        UPAYORD_NT DEFAULT 'A'       NOT NULL,
    CLMPAY_NF           UCLI_NF    NULL,
    CLMPAYORD_NT        UPAYORD_NT DEFAULT 'A'       NOT NULL,
    GENPRMSEN_NF        UCLI_NF    NULL,
    ORGCED_NF           UCLI_NF    NULL,
    ORGBRK_NF           UCLI_NF    NULL,
    ORGLDI_NF           UCLI_NF    NULL,
    CTRPCPNAM_LL        UL64       NULL,
    ACCESB_CF           UESB_CF    NOT NULL,
    UWGRP_CF            UGRP_CF    NOT NULL,
    UWRSPUSR_CF         UUSR_CF    DEFAULT ''        NOT NULL,
    ADMGRP_CF           UGRP_CF    NOT NULL,
    ADMUSR_CF           UUPDUSR_CF DEFAULT user      NOT NULL,
    ACCGRP_CF           UGRP_CF    NULL,
    CTRSTS_CT           UCTRSTS_CT DEFAULT 3         NOT NULL,
    CTRSTS_D            datetime   NULL,
    CTRLCK_B            bit        DEFAULT 0         NOT NULL,
    EVA_CT              bit        DEFAULT 0         NOT NULL,
    OFF_D               datetime   NULL,
    PRVSTS_CT           UCTRSTS_CT NULL,
    PRVSTS_D            datetime   NULL,
    RENTYP_CT           URENTYP_CT NULL,
    REN_B               bit        DEFAULT 0         NOT NULL,
    RENWAIPER_N         UPERIOD    NULL,
    RENMONDAY_B         bit        DEFAULT 0         NOT NULL,
    CANCTR_D            datetime   NULL,
    CAN_DT              datetime   NULL,
    CANREA_CF           UUWREA_CF  DEFAULT ''        NOT NULL,
    CANSCO_B            bit        DEFAULT 0         NOT NULL,
    CANCED_B            bit        DEFAULT 0         NOT NULL,
    PNOEXTPER_N         UPERIOD    NULL,
    PNOEXTMON_B         bit        DEFAULT 0         NOT NULL,
    PNOEXTREA_CF        UUWREA_CF  DEFAULT ''        NOT NULL,
    PNOEXTSCO_B         bit        DEFAULT 0         NOT NULL,
    PNOEXTCED_B         bit        DEFAULT 0         NOT NULL,
    PNOPLC_D            datetime   NULL,
    PNOSCO_B            bit        DEFAULT 0         NOT NULL,
    PNOCED_B            bit        DEFAULT 0         NOT NULL,
    COVCNT_B            bit        DEFAULT 0         NOT NULL,
    COVCNTEXP_D         datetime   NULL,
    CTRRCP_DT           datetime   NULL,
    BINDUR_N            UPERIOD    NULL,
    VRSCRE_D            datetime   NULL,
    VRSINC_D            datetime   NULL,
    ENDINC_D            datetime   NULL,
    ENDEXP_D            datetime   NULL,
    LSTEND_B            bit        DEFAULT 0         NOT NULL,
    FRSUWY_NF           UUWY_NF    NOT NULL,
    FRSINC_D            datetime   NULL,
    LSTUWY_B            bit        DEFAULT 0         NOT NULL,
    LSTUWYRSK_B         bit        DEFAULT 0         NOT NULL,
    FACADMTYP_B         bit        DEFAULT 0         NOT NULL,
    COMTEC_B            bit        DEFAULT 0         NOT NULL,
    CTRACCSTS_CT        UACCSTS_CT DEFAULT 0         NOT NULL,
    CTRACC_D            datetime   NULL,
    PRG_NF              UCTRGRP_NF DEFAULT ''        NOT NULL,
    BOQ_NF              UCTRGRP_NF DEFAULT ''        NOT NULL,
    MAS_NF              UCTRGRP_NF DEFAULT ''        NOT NULL,
    CTRGRP_NF           UCTRGRP_NF DEFAULT ''        NOT NULL,
    LNKDIVSEC_N         tinyint    NULL,
    PCPLOB_CF           ULOB_CF    DEFAULT ''        NOT NULL,
    PCPSOB_CF           USOB_CF    DEFAULT ''        NOT NULL,
    PCPTOP_CF           UTOP_CF    DEFAULT ''        NOT NULL,
    PCPOCC_CF           URSKNAT_CF DEFAULT ''        NOT NULL,
    PCPGAR_CF           UGAR_CF    DEFAULT ''        NOT NULL,
    PCPNAT_CF           UCTRNAT_CF DEFAULT ''        NOT NULL,
    PCPDIV_NF           UDIV_NT    NULL,
    PCPIND_NF           UIND_NF    NULL,
    PRDROJCTR_NF        UCTR_NF    NULL,
    CTRQUA_CF           smallint   NULL,
    CTRQUA2_CF          smallint   NULL,
    CTRQUA3_CF          smallint   NULL,
    CTRQUA4_CF          smallint   NULL,
    CTRQUA5_CF          smallint   NULL,
    NAH_B               bit        DEFAULT 0         NOT NULL,
    TECADV_B            bit        DEFAULT 0         NOT NULL,
    FRT_B               bit        DEFAULT 0         NOT NULL,
    CAT_B               bit        DEFAULT 0         NOT NULL,
    TOBREN_B            bit        DEFAULT 0         NOT NULL,
    REFTOBREE_B         bit        DEFAULT 0         NOT NULL,
    LONDURCTR_B         bit        DEFAULT 0         NOT NULL,
    CPTNAM_B            bit        DEFAULT 0         NOT NULL,
    CMPREF_B            bit        DEFAULT 0         NOT NULL,
    LDISCO_B            tinyint    DEFAULT 0         NULL,
    PRCRSK_NF           URSK_NF    NULL,
    REITYP_CF           tinyint    NULL,
    PCPEXTREF_LL        UL64       NULL,
    UWORG_CF            smallint   NULL,
    ENDISS_N            UINTORD_NT NULL,
    RSKCOMPRM_B         bit        DEFAULT 0         NOT NULL,
    LIFTRTTYP_CF        char(2)    DEFAULT ''        NOT NULL,
    ROJCTR_B            bit        DEFAULT 0         NOT NULL,
    OBGPRT_B            bit        DEFAULT 0         NOT NULL,
    SAMCTREXI_B         bit        DEFAULT 0         NOT NULL,
    BNF_LM              UL32       NULL,
    CTLOFF_LM           UL32       NULL,
    INTCASBAL_B         bit        DEFAULT 0         NOT NULL,
    FIXINTCAS_B         bit        DEFAULT 0         NOT NULL,
    INTCASBAL_R         USHORAT_R  NULL,
    INTTECBAL_R         USHORAT_R  NULL,
    CTROLDNBR_LM        UL32       NULL,
    UMRACCADM_CT        tinyint    NOT NULL,
    UMRCTR_LM           UL32       NULL,
    MNGUWSRC_NF         UCLI_NF    NULL,
    CTRSLPREC_D         datetime   NULL,
    CTRSLPSND_D         datetime   NULL,
    WRDREC_D            datetime   NULL,
    WRDSND_D            datetime   NULL,
    PNOPER_CT           UPAYFRQ_CT NULL,
    TRTVERNBR_NT        UEND_NT    DEFAULT 0         NOT NULL,
    COTDEP_D            datetime   NULL,
    COTRET_D            datetime   NULL,
    INTRET_B            bit        DEFAULT 0         NOT NULL,
    MANRET_B            bit        DEFAULT 0         NOT NULL,
    ALLTRT_B            bit        DEFAULT 0         NOT NULL,
    CRE_D               UUPD_D     DEFAULT getdate() NOT NULL,
    CREUSR_CF           UUPDUSR_CF DEFAULT user      NOT NULL,
    LSTUPD_D            UUPD_D     DEFAULT getdate() NOT NULL,
    LSTUPDUSR_CF        UUPDUSR_CF DEFAULT user      NOT NULL,
    LSTUPD_LS           UL16       NULL,
    [timestamp]         timestamp  NULL,
    ESTCRB_CT           char(1)    NULL,
    RETCTR_NF           UCTR_NF    DEFAULT ''        NOT NULL,
    CTRORG_NF           UCTR_NF    DEFAULT ''        NOT NULL,
    MULTUWY_NF          smallint   NULL,
    FACACTSCT_CT        int        NULL,
    CTRACCSTS2_CT       UACCSTS_CT NULL,
    PNOPLCSCO_D         datetime   NULL,
    CNATYP_CT           char(1)    NULL,
    ENDMULTUWY_NF       smallint   NULL,
    UWRSPUSR2_CF        UUSR_CF    NULL,
    ESTCRB_D            datetime   NULL,
    ADMDOC_CT           tinyint    NULL,
    NAHNUWY_NF          UUWY_NF    NULL,
    PROVEQU_B           char(1)    NULL,
    FDSADMUSR_CF        UUPDUSR_CF NULL,
    FDSCTRVALG_D        datetime   NULL,
    FDSUWRSPUSR_CF      UUSR_CF    NULL,
    FDSCTRVALS_D        datetime   NULL,
    FDSMODIFTYP_CT      tinyint    NULL,
    CTRQUA6_CF          smallint   NULL,
    CTRQUA7_CF          smallint   NULL,
    CTRQUA8_CF          smallint   NULL,
    CTRQUA9_CF          smallint   NULL,
    CTRQUA10_CF         smallint   NULL,
    CTRNEW_CT           tinyint    NULL,
    INTCASBALVAR_R      USHORAT_R  NULL,
    INTTECBALVAR_R      USHORAT_R  NULL,
    INTTECBALVAR_B      UBOOLEAN_B NULL,
    INTCASBALVARBASE_CT UBANVAL_CT NULL,
    INTTECBALVARBASE_CT UBANVAL_CT NULL,
    CTRATT_NF           UCTR_NF    NULL,
    ACCUSR_CF           UUPDUSR_CF NULL,
    COMMSTS_CT          UBANVAL_CT NULL,
    CTRVISSTS_CT        char(5)    NULL,
    FINTYP_CF           UBANVAL_CT NULL,
    AUTORENEW_CF        UBANVAL_CT NULL,
    MAITPA_NF           UCLI_NF    NULL,
    WRDSIGN_D           datetime   NULL
)


CREATE TABLE #TLOADING_STEP11
(
  CTR_NF		UCTR_NF			NULL,
	SEC_NF	  UUWY_NF				NULL,
  MAXACY_NF	smallint				NULL
)


CREATE TABLE #TLIFEST
(
    CTR_NF        UCTR_NF    NOT NULL,
    END_NT        UEND_NT    NOT NULL,
    SEC_NF        USEC_NF    NOT NULL,
    UWY_NF        UUWY_NF    NOT NULL,
    UW_NT         UUW_NT     NOT NULL,
    CRE_D         UUPD_D     NOT NULL,
    BALSHEY_NF    smallint   NOT NULL,
    BALSHTMTH_NF  tinyint    NOT NULL,
    ACY_NF        smallint   NOT NULL,
    GAAP_NT       tinyint    NOT NULL,
    DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
    ACM_NF        tinyint    DEFAULT 13 NOT NULL,
    PRS_CF        smallint   NOT NULL,
    ACMTRS_NT     smallint   NOT NULL,
    SSD_CF        USSD_CF    NOT NULL,
    CUR_CF        UCUR_CF    NOT NULL,
    ESTMNT_M      UAMT_M     NOT NULL,
    INDSUP_B      bit        DEFAULT 0  NOT NULL,
    ORICOD_LS     UL16       NULL,
    CREUSR_CF     UUPDUSR_CF NOT NULL,
    LSTUPD_D      UUPD_D     NOT NULL,
    LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
    ORICTR_NF     UCTR_NF    NULL,
    ORISEC_NF     USEC_NF    NULL,
    ORIUWY_NF     UUWY_NF    NULL,
    DIFF_M        UAMT_M     NULL,
    PROPAGATION_B bit        DEFAULT 0  NOT NULL,
    CALCULATED_B  bit        DEFAULT 0  NOT NULL,
    BATCH_B       bit        DEFAULT 0  NOT NULL
)

    Create table #TLIFESTD (													
    CTR_NF        UCTR_NF    NOT NULL,
    END_NT        UEND_NT    NOT NULL,
    SEC_NF        USEC_NF    NOT NULL,
    UWY_NF        UUWY_NF    NOT NULL,
    UW_NT         UUW_NT     NOT NULL,
    CRE_D         UUPD_D     NOT NULL,
    BALSHEY_NF    smallint   NOT NULL,
    BALSHTMTH_NF  tinyint    NOT NULL,
    ACY_NF        smallint   NOT NULL,
    GAAP_NT       tinyint    NOT NULL,
    DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
    ACM_NF        tinyint    DEFAULT 13 NOT NULL,
    PRS_CF        smallint   NOT NULL,
    ACMTRS_NT     smallint   NOT NULL,
    SSD_CF        USSD_CF    NOT NULL,
    CUR_CF        UCUR_CF    NOT NULL,
    ESTMNT_M      UAMT_M     NOT NULL,
    INDSUP_B      bit        DEFAULT 0  NOT NULL,
    ORICOD_LS     UL16       NULL,
    CREUSR_CF     UUPDUSR_CF NOT NULL,
    LSTUPD_D      UUPD_D     NOT NULL,
    LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
    ORICTR_NF     UCTR_NF    NULL,
    ORISEC_NF     USEC_NF    NULL,
    ORIUWY_NF     UUWY_NF    NULL,
    DIFF_M        UAMT_M     NULL,
    PROPAGATION_B bit        DEFAULT 0  NOT NULL,
    CALCULATED_B  bit        DEFAULT 0  NOT NULL,
    BATCH_B       bit        DEFAULT 0  NOT NULL)
    
    
    CREATE TABLE #TLIFDRID
(
    CTR_NF       UCTR_NF    NOT NULL,
    END_NT       UEND_NT    NOT NULL,
    SEC_NF       USEC_NF    NOT NULL,
    UWY_NF       UUWY_NF    NOT NULL,
    UW_NT        UUW_NT     NOT NULL,
    CRE_D        UUPD_D      NOT NULL,
    BALSHEY_NF   smallint   NOT NULL,
    BALSHTMTH_NF tinyint    NOT NULL,
    ACY_NF       smallint   NOT NULL,
    ACM_NF      tinyint NOT NULL,
    SSD_CF       USSD_CF    NOT NULL,
    AUTUPD_B     bit        DEFAULT 0         NOT NULL,
    COMACC_B     bit        DEFAULT 0         NOT NULL,
    CMT_NT       UCMT_NT    NULL,
    CREUSR_CF    UUPDUSR_CF     NOT NULL,
    LSTUPD_D     UUPD_D      NOT NULL,
    LSTUPDUSR_CF UUPDUSR_CF      NOT NULL,
    RESPROPAG_B  bit        DEFAULT 0         NOT NULL,
    SEGUPD_B     bit        DEFAULT 0         NOT NULL
)

create table #TLIFMOD (
  CTR_NF UCTR_NF not null,
  SEC_NF USEC_NF not null,
  CRE_D datetime not null,
  BALSHEY_NF smallint not null,
  BALSHTMTH_NF tinyint not null,
  SSD_CF USSD_CF not null,
  TYPMOD1_CT tinyint not null,
  TYPMOD2_CT tinyint null,
  CUR_CF UCUR_CF null,
  CMT_NT UCMT_NT null,
  SENMAI_D datetime null,
  ORICOD_LS UL16 not null,
  CREUSR_CF UUSR_CF not null,
  LSTUPD_D datetime not null,
  LSTUPDUSR_CF UUSR_CF not null,
  [Timestamp] timestamp null,
  DISPLAY_B UBOOLEAN_B default 1  not null
)
create table #TLIFMOD2 (
  CTR_NF UCTR_NF not null,
  SEC_NF USEC_NF not null,
  CRE_D datetime not null,
  BALSHEY_NF smallint not null,
  BALSHTMTH_NF tinyint not null,
  ACY_NF UACCYER_NF not null,
  COMACC_B bit not null,
  PRIPRMAMT_M UAMT_M not null,
  AFTPRMAMT_M UAMT_M not null,
  PRIRESTECAMT_M UAMT_M not null,
  AFTRESTECAMT_M UAMT_M not null,
  PRIRESDACAMT_M UAMT_M not null,
  AFTRESDACAMT_M UAMT_M not null,
  PRIRESFINAMT_M UAMT_M not null,
  AFTRESFINAMT_M UAMT_M not null,
  CREUSR_CF UUSR_CF null,
  LSTUPD_D datetime null,
  LSTUPDUSR_CF UUSR_CF null,
  [Timestamp] timestamp null,
  GAAP_NT tinyint not null
)
    
SELECT  @blcshtyea_nf  = MIN(BLCSHTYEA_NF ) FROM BREF..TCALEND Where END_D > GETDATE()
SELECT  @blcshtmth_nf  = MIN(BLCSHTMTH_NF ) FROM BREF..TCALEND Where END_D > GETDATE() AND BLCSHTYEA_NF  = @blcshtyea_nf
    
    
/*******************
STEP 0 : Check closing process
********************/
Print 'STEP 0 : START'
select @nbSite = count(*) FROM BREF..TSITE WHERE NIGHT_B !=0

IF @nbSite !=0
    GOTO BATCHERROR
ELSE
  PRINT 'NO NIGHT BATCH RUNNING'
  PRINT 'STEP 0 : COMPLETED'
  PRINT ''

/*******************/

/*******************
STEP 1 : 	Checking Mandatory fields
********************/
Print 'STEP 1 : START'
Select @nbligne_STEP1a = count(*) from BTRAV..EST_IFRS17_PERIMETER 
WHERE (RETCTR_NF IS NOT NULL AND RTY_NF is NULL)
OR (CTR_NF is not NULL AND UWY_NF is NULL)


IF (@nbligne_STEP1a!=0)
Begin
    INSERT into #TANO_TMP
    SELECT 
    RETCTR_NF,
    RTY_NF,
    1,
    'Check mandatory data UWY',
    'Forbidden to change Estimate type because the Underwriting year is missing' 
    FROM BTRAV..EST_IFRS17_PERIMETER 
    WHERE RETCTR_NF IS NOT NULL AND RTY_NF is NULL
    
    INSERT into #TANO_TMP
    SELECT 
    CTR_NF,
    UWY_NF,
    1,
    'Check mandatory data UWY',
    'Forbidden to change Estimate type because the Underwriting year is missing ' 
    FROM BTRAV..EST_IFRS17_PERIMETER 
    WHERE CTR_NF IS NOT NULL AND UWY_NF is NULL
END

Select @nbligne_STEP1b =  count(*) from BTRAV..EST_IFRS17_PERIMETER 
WHERE (ESTTYPE_LL is null or ESTTYPE_LL = ''
    OR ESTCRB_CT is null or ESTCRB_CT = '')
  
  
  IF (@nbligne_STEP1b!=0)
Begin
    INSERT into #TANO_TMP
    SELECT 
    RETCTR_NF ,
    RTY_NF,
    1,
    'Check mandatory data estimate type',
    'Forbidden to change Estimate type because the estimate type is missing for the contract  ' + RETCTR_NF
    FROM BTRAV..EST_IFRS17_PERIMETER 
    WHERE (ESTTYPE_LL is null or ESTTYPE_LL = ''
    OR ESTCRB_CT is null or ESTCRB_CT = '')
    AND CTR_NF is  null
    UNION
    SELECT 
    CTR_NF ,
    UWY_NF,
    1,
    'Check mandatory data estimate type',
    'Forbidden to change Estimate type because the estimate type is missing for the contract ' + CTR_NF
    FROM BTRAV..EST_IFRS17_PERIMETER 
    WHERE (ESTTYPE_LL is null or ESTTYPE_LL = ''
          OR ESTCRB_CT is null or ESTCRB_CT = '')
          AND RETCTR_NF is  null
    UNION
    SELECT 
    CTR_NF ,
    UWY_NF,
    1,
    'Check mandatory data estimate type',
    'Forbidden to change Estimate type because the estimate type is missing for the contract  ' + CTR_NF
    FROM BTRAV..EST_IFRS17_PERIMETER 
    WHERE (ESTTYPE_LL is null or ESTTYPE_LL = ''
          OR ESTCRB_CT is null or ESTCRB_CT = '')
          AND RETCTR_NF is NOT null   
          AND CTR_NF is NOT null
       
END

IF (@nbligne_STEP1a !=0 OR @nbligne_STEP1b !=0 )
BEGIN
  PRINT 'ANOMALIES FOUND'
  PRINT 'STEP 1 COMPLETED'
  PRINT ''
  GOTO ENDPROCESS
  END
ELSE
BEGIN
  PRINT 'NO ANOMALIE FOUND'
END  
  Print 'STEP 1 COMPLETED'
  PRINT ''

/********************/


/*******************
STEP 2 : 	Checking the presence of the data
********************/
Print 'STEP 2   START'
DELETE FROM  #TANO_TMP

EXECUTE Best..PsEST_IFRS17_02_O2
select @erreur=@@error
    if @erreur!=0
      begin
          PRINT 'ERROR EXECUTING PsEST_IFRS17_02_O2'
        goto ENDPROCESS
      end

select @nbligne_TANO = count(*) FROM #TANO_TMP
IF @nbligne_TANO !=0
  BEGIN
    PRINT 'ANOMALIES FOUND'
  GOTO ENDPROCESS
  END
ELSE
BEGIN
  PRINT 'NO ANOMALIE FOUND'
END  
  Print 'STEP 3 COMPLETED'
  PRINT ''
/*******************/

/*******************
STEP 3 : 	Search assumed (in case of retrocession chain)
********************/
Print 'STEP 3   START'
EXECUTE Best..PsEST_IFRS17_03_O2
PRINT 'SEARCHING ASSUMED TREATY LINKED TO RETRO CONTRACT'
Print 'STEP 3 COMPLETED'
PRINT ''

/*******************/


/*******************
STEP 4 : 	Compare the result of research with input file (case of assumed linked to retro, or retro without assumed or assumed)
********************/
Print 'STEP 4   START'

EXECUTE Best..PsEST_IFRS17_04_O2
select @erreur=@@error
    if @erreur!=0
      begin
          PRINT 'ERROR EXECUTING PsEST_IFRS17_04_O2'
        goto ENDPROCESS
      end

IF ((SELECT COUNT(*) FROM #TANO_TMP) > 0)
          Begin
          
            GOTO ENDPROCESS
          END
  
  PRINT 'STEP 4 : COMPLETE'
  PRINT ''
/*******************/



/*******************
STEP 5 : 	Update retro Estimates type
********************/
PRINT 'STEP 5 : RETRO CONTRACT START'

EXECUTE Best..PsEST_IFRS17_05_O2
select @erreur=@@error
    if @erreur!=0
      begin
          PRINT 'ERROR EXECUTING PsEST_IFRS17_05_O2'
        goto ENDPROCESS
      end
PRINT 'Preparing data for updating RETRO CONTRACT (BRET..TRETCTR)'

  
Print 'STEP 5 COMPLETED'
PRINT ''
/*******************/



/*******************
STEP 6 : 	Update assumed Estimates type
********************/

PRINT 'STEP 6 : ASSUMED CONTRACT START'

EXECUTE Best..PsEST_IFRS17_06_O2
select @erreur=@@error
    if @erreur!=0
      begin
          PRINT 'ERROR EXECUTING PsEST_IFRS17_06_O2'
        goto ENDPROCESS
      end
PRINT 'Preparing data for updating Assumed CONTRACT (BTRT..TCONTR)'
Print 'STEP 6 COMPLETED'
PRINT ''
/*******************/


/*******************
STEP 7 : 	Test Estimates type life plan quarterly 
********************/
PRINT 'STEP 7   START'
SELECT @nbligne_STEP7 = count (*) FROM #TRETRO WHERE OLD_ESTCRB_CT = 'S' AND NEW_ESTCRB_CT = 'U'
IF  (@nbligne_STEP7 !=0)
  BEGIN
    PRINT 'ESTIMATION TYPE CHANGE S to U : RETRO CONTRACT EXIST'
  END
SELECT @nbligne_STEP7 = count (*) FROM #TASSUMED WHERE OLD_ESTCRB_CT = 'S' AND NEW_ESTCRB_CT = 'U'
IF  (@nbligne_STEP7 !=0)
  BEGIN
     PRINT 'ESTIMATION TYPE CHANGE S to U : ASSUMED CONTRACT EXIST'
    
  END
Print 'STEP 7 COMPLETED'
PRINT ''
/*******************/

/*******************
STEP 8 : 	Test Estimates type yearly to quarterly
********************/
PRINT 'STEP 8   START'

-- TEST CASE 1 : O/V to T
SELECT @nbligne_STEP8 = count (*) FROM #TRETRO WHERE OLD_ESTCRB_CT in( 'O','V') AND NEW_ESTCRB_CT = 'T'
IF  (@nbligne_STEP8 !=0)
  BEGIN
    PRINT 'ESTIMATION TYPE CHANGE O/E to T : RETRO CONTRACT EXIST'
  END
SELECT @nbligne_STEP8 = count (*) FROM #TASSUMED WHERE OLD_ESTCRB_CT in( 'O','V') AND NEW_ESTCRB_CT = 'T'
IF  (@nbligne_STEP8 !=0)
  BEGIN
    PRINT 'ESTIMATION TYPE CHANGE O/E to T : ASSUME CONTRACT EXIST'
  END  
  
-- TEST CASE 2 : T to O / U to S 
SELECT @nbligne_STEP8 = count (*) FROM #TRETRO WHERE OLD_ESTCRB_CT in( 'T') AND NEW_ESTCRB_CT = 'O'
IF  (@nbligne_STEP8 !=0)
  BEGIN
    PRINT 'ESTIMATION TYPE CHANGE T to O : RETRO CONTRACT EXIST'
  END
SELECT @nbligne_STEP8 = count (*) FROM #TASSUMED WHERE OLD_ESTCRB_CT in( 'T') AND NEW_ESTCRB_CT = 'O'
IF  (@nbligne_STEP8 !=0)
  BEGIN
    PRINT 'ESTIMATION TYPE CHANGE T to O : ASSUME CONTRACT EXIST'
  END 
SELECT @nbligne_STEP8 = count (*) FROM #TRETRO WHERE OLD_ESTCRB_CT in( 'U') AND NEW_ESTCRB_CT = 'S'
IF  (@nbligne_STEP8 !=0)
  BEGIN
    PRINT 'ESTIMATION TYPE CHANGE U to S : RETRO CONTRACT EXIST'
  END
SELECT @nbligne_STEP8 = count (*) FROM #TASSUMED WHERE OLD_ESTCRB_CT in( 'U') AND NEW_ESTCRB_CT = 'S'
IF  (@nbligne_STEP8 !=0)
  BEGIN
    PRINT 'ESTIMATION TYPE CHANGE U to S : ASSUME CONTRACT EXIST'
  END 
  

Print 'STEP 8 COMPLETED'
PRINT ''
/*******************/

/*******************
STEP 9 : 	Quarterly estimates propagation (for quarterly only)
********************/
PRINT 'STEP 9   START'
--FROM STEP 8 CASE 1 : propagate the reserves from last complete account on the future accounting years according to the accounting type (O/V To T)

INSERT INTO #TLOADING_STEP9

SELECT R.RETCTR_NF,R.RTY_NF,0 FROM #TRETRO R ,TLIFDRI L WHERE L.CTR_NF = R.RETCTR_nf and  OLD_ESTCRB_CT in( 'O','V') AND NEW_ESTCRB_CT = 'T' AND COMACC_B = 1
UNION
SELECT A.CTR_NF, A.UWY_NF,0 FROM #TASSUMED A, TLIFDRI L WHERE  OLD_ESTCRB_CT in( 'O','V') AND NEW_ESTCRB_CT = 'T'AND  L.CTR_NF = A.CTR_nf  AND COMACC_B = 1
UNION
SELECT P.CTR_NF, P.UWY_NF,0 FROM  BTRAV..EST_IFRS17_PERIMETER P LEFT join  BEST..TLIFDRI D on P.CTR_NF = D.CTR_NF WHERE D.CTR_NF is null
UNION
SELECT P.RETCTR_NF,P.RTY_NF,0 FROM  BTRAV..EST_IFRS17_PERIMETER P LEFT join  BEST..TLIFDRI D on P.RETCTR_NF = D.CTR_NF WHERE D.CTR_NF is null


UPDATE #TLOADING_STEP9 SET MAXUWY_NF = (SELECT MAX(UWY_NF) FROM TLIFDRI L WHERE L.CTR_NF=#TLOADING_STEP9.CTR_NF AND COMACC_B = 1 )

PRINT 'EXECUTE Best..PsEST_IFRS17_09_O2 '
IF (SELECT count (*)from #TLOADING_STEP9)!=0
BEGIN
     EXECUTE Best..PsEST_IFRS17_09_O2 
     select @erreur=@@error
    if @erreur!=0
      begin
          PRINT 'ERROR EXECUTING PsEST_IFRS17_09_O2'
        goto ENDPROCESS
      end
END
PRINT 'EXECUTE COMPLETED'
Print 'STEP 9 COMPLETED'
PRINT ''
/*******************/

/*******************
STEP 10 : Remove all estimations (for quarterly and life Plan quarterly)	
********************/
PRINT 'STEP 10   START'
--FROM STEP 7 : REMOVE ALL ESTIMATION (SET ESTIMATION TO 0) ESTIMATION CHANGE FROM S TO U
PRINT 'EXECUTE Best..PsEST_IFRS17_10_O2 '
EXECUTE Best..PsEST_IFRS17_10_O2
select @erreur=@@error
    if @erreur!=0
      begin
          PRINT 'ERROR EXECUTING PsEST_IFRS17_10_O2'
        goto ENDPROCESS
      end
PRINT 'EXECUTE COMPLETED'
Print 'STEP 10 COMPLETED'
PRINT ''
/*******************/

/*******************
STEP 11 : Quarterly complete account (for quarterly)	
********************/
PRINT 'STEP 11   START'
--FROM STEP 8 CASE1 : set the quarterly complete account -  ESTIMATION CHANGE FROM O/V TO T


PRINT 'EXECUTE Best..PsEST_IFRS17_11_O2 '
EXECUTE Best..PsEST_IFRS17_11_O2 
select @erreur=@@error
    if @erreur!=0
      begin
          PRINT 'ERROR EXECUTING PsEST_IFRS17_11_O2'
        goto ENDPROCESS
      end
PRINT 'EXECUTE COMPLETED'
Print 'STEP 11 COMPLETED'
PRINT ''
/*******************/

/*******************
STEP 12 : yearly estimates propagation (for yearly)	
********************/
PRINT 'STEP 12   START'

--FROM STEP 8 CASE 2 :   ESTIMATION CHANGE FROM T to O / U to S  - propagate the yearly estimate
--for By section and Life Plan:
--Keep the annual aggregation of quarterly estimates for the retro contract and the treaties on all GAAP
--PRINT 'EXECUTE Best..PsEST_IFRS17_12_O2 '
--EXECUTE Best..PsEST_IFRS17_12_O2
--PRINT 'EXECUTE COMPLETED'


--For By section only:
--Propagate on all GAAP the aggregated accounting if the four quarter are completed.
--Propagate the last reserves of complete account on future accounting years for retro contract and the assumed contracts whatever the accounting type.

Print 'STEP 12 COMPLETED'
PRINT ''
/*******************/

/*******************
STEP 13 : Update Movement File (for each change)	
********************/
PRINT 'STEP 13   START'
PRINT 'EXECUTE Best..PsEST_IFRS17_13_O2 '
EXECUTE Best..PsEST_IFRS17_13_O2
select @erreur=@@error
    if @erreur!=0
      begin
          PRINT 'ERROR EXECUTING PsEST_IFRS17_13_O2'
        goto ENDPROCESS
      end
Print 'STEP 13 COMPLETED'
PRINT ''
/*******************/

/*******************
STEP 14 : Insert temporary tables in quarterly tables	
********************/
PRINT 'STEP 14   START'
BEGIN TRAN
    --MOD1 START
    PRINT 'TCONTR UPDATE'
   
    UPDATE BTRT..TCONTR SET ESTCRB_CT = (SELECT ESTCRB_CT FROM #TCONTR  T WHERE T.CTR_NF= BTRT..TCONTR.CTR_NF   ) , LSTUPD_D = GETDATE(), LSTUPDUSR_CF = USER  WHERE BTRT..TCONTR.CTR_NF in (SELECT CTR_NF FROM #TCONTR  T WHERE T.CTR_NF= BTRT..TCONTR.CTR_NF  ) 
   
    select @erreur=@@error
    if @erreur!=0
      begin
          select @p_erreur = "APPLICATIF;TCONTR " + convert(varchar(10),@erreur) + ";"
        goto fin
      end
    SELECT * from BTRT..TCONTR WHERE BTRT..TCONTR.CTR_NF in (SELECT CTR_NF FROM #TCONTR  T WHERE T.CTR_NF= BTRT..TCONTR.CTR_NF  ) 
    
    PRINT 'TSECTION UPDATE'

    UPDATE BTRT..TSECTION SET ESTCRB_CT = (SELECT ESTCRB_CT FROM #TCONTR  T WHERE T.CTR_NF= BTRT..TSECTION.CTR_NF   ) , LSTUPD_D = GETDATE(), LSTUPDUSR_CF = USER  WHERE BTRT..TSECTION.CTR_NF in (SELECT CTR_NF FROM #TCONTR  T WHERE T.CTR_NF= BTRT..TSECTION.CTR_NF  ) 
   
    select @erreur=@@error
    if @erreur!=0
      begin
          select @p_erreur = "APPLICATIF;TSECTION " + convert(varchar(10),@erreur) + ";"
        goto fin
      end
    SELECT * from BTRT..TSECTION WHERE BTRT..TSECTION.CTR_NF in (SELECT CTR_NF FROM #TCONTR  T WHERE T.CTR_NF= BTRT..TSECTION.CTR_NF  ) 

    PRINT 'TRETCTR UPDATE'   
    UPDATE BRET..TRETCTR SET ESTCRB_CT = (SELECT ESTCRB_CT FROM #TRETCTR  T WHERE T.RETCTR_NF= BRET..TRETCTR.RETCTR_NF   ) , LSTUPD_D = GETDATE() , LSTUPDUSR_CF = USER  WHERE BRET..TRETCTR.RETCTR_NF in (SELECT RETCTR_NF FROM #TRETCTR  T WHERE T.RETCTR_NF= BRET..TRETCTR.RETCTR_NF  ) 
    set @erreur = @@error
    if @erreur!=0
      begin
          select @p_erreur = "APPLICATIF;TRETCTR " + convert(varchar(10),@erreur) + ";"
        goto fin
      end
    SELECT * from BRET..TRETCTR WHERE BRET..TRETCTR.RETCTR_NF in (SELECT RETCTR_NF FROM #TRETCTR  T WHERE T.RETCTR_NF= BRET..TRETCTR.RETCTR_NF  ) 
    
    


    --MOD1 START
      
      
    PRINT 'TLIFEST UPDATE'
    INSERT INTO TLIFEST
    SELECT #TLIFEST.CTR_NF, #TLIFEST.END_NT, #TLIFEST.SEC_NF, #TLIFEST.UWY_NF, #TLIFEST.UW_NT, #TLIFEST.CRE_D, #TLIFEST.BALSHEY_NF, #TLIFEST.BALSHTMTH_NF, #TLIFEST.ACY_NF, #TLIFEST.GAAP_NT, #TLIFEST.DETTRNCOD_CF, #TLIFEST.ACM_NF, #TLIFEST.PRS_CF, #TLIFEST.ACMTRS_NT, #TLIFEST.SSD_CF, #TLIFEST.CUR_CF, #TLIFEST.ESTMNT_M, #TLIFEST.INDSUP_B, #TLIFEST.ORICOD_LS, #TLIFEST.CREUSR_CF, #TLIFEST.LSTUPD_D, #TLIFEST.LSTUPDUSR_CF, #TLIFEST.ORICTR_NF, #TLIFEST.ORISEC_NF, #TLIFEST.ORIUWY_NF, #TLIFEST.DIFF_M, #TLIFEST.PROPAGATION_B, #TLIFEST.CALCULATED_B, #TLIFEST.BATCH_B                                                                                                                                      FROM #TLIFEST
   set @erreur = @@error
    if @erreur!=0
      begin
          select @p_erreur = "APPLICATIF;TLIFEST " + convert(varchar(10),@erreur) + ";"
        goto fin
      end
    SELECT #TLIFEST.CTR_NF, #TLIFEST.END_NT, #TLIFEST.SEC_NF, #TLIFEST.UWY_NF, #TLIFEST.UW_NT, #TLIFEST.CRE_D, #TLIFEST.BALSHEY_NF, #TLIFEST.BALSHTMTH_NF, #TLIFEST.ACY_NF, #TLIFEST.GAAP_NT, #TLIFEST.DETTRNCOD_CF, #TLIFEST.ACM_NF, #TLIFEST.PRS_CF, #TLIFEST.ACMTRS_NT, #TLIFEST.SSD_CF, #TLIFEST.CUR_CF, #TLIFEST.ESTMNT_M, #TLIFEST.INDSUP_B, #TLIFEST.ORICOD_LS, #TLIFEST.CREUSR_CF, #TLIFEST.LSTUPD_D, #TLIFEST.LSTUPDUSR_CF, #TLIFEST.ORICTR_NF, #TLIFEST.ORISEC_NF, #TLIFEST.ORIUWY_NF, #TLIFEST.DIFF_M, #TLIFEST.PROPAGATION_B, #TLIFEST.CALCULATED_B, #TLIFEST.BATCH_B                                                                                                            FROM #TLIFEST 
    
    
    PRINT 'TLIFESTD UPDATE'
    INSERT INTO TLIFESTD
    SELECT distinct #TLIFESTD.CTR_NF, #TLIFESTD.END_NT, #TLIFESTD.SEC_NF, #TLIFESTD.UWY_NF, #TLIFESTD.UW_NT, #TLIFESTD.CRE_D, #TLIFESTD.BALSHEY_NF, #TLIFESTD.BALSHTMTH_NF, #TLIFESTD.ACY_NF, #TLIFESTD.GAAP_NT, #TLIFESTD.DETTRNCOD_CF, #TLIFESTD.ACM_NF, #TLIFESTD.PRS_CF, #TLIFESTD.ACMTRS_NT, #TLIFESTD.SSD_CF, #TLIFESTD.CUR_CF, #TLIFESTD.ESTMNT_M, #TLIFESTD.INDSUP_B, #TLIFESTD.ORICOD_LS, #TLIFESTD.CREUSR_CF, #TLIFESTD.LSTUPD_D, #TLIFESTD.LSTUPDUSR_CF, #TLIFESTD.ORICTR_NF, #TLIFESTD.ORISEC_NF, #TLIFESTD.ORIUWY_NF, #TLIFESTD.DIFF_M, #TLIFESTD.PROPAGATION_B, #TLIFESTD.CALCULATED_B, #TLIFESTD.BATCH_B                                                                                            FROM #TLIFESTD GROUP BY CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,PRS_CF,ACMTRS_NT,GAAP_NT,DETTRNCOD_CF,CRE_D, SSD_CF,ACM_NF
    set @erreur = @@error
    if @erreur!=0
      begin
          select @p_erreur = "APPLICATIF;TLIFESTD " + convert(varchar(10),@erreur) + ";"
        goto fin
      end
    SELECT #TLIFESTD.CTR_NF, #TLIFESTD.END_NT, #TLIFESTD.SEC_NF, #TLIFESTD.UWY_NF, #TLIFESTD.UW_NT, #TLIFESTD.CRE_D, #TLIFESTD.BALSHEY_NF, #TLIFESTD.BALSHTMTH_NF, #TLIFESTD.ACY_NF, #TLIFESTD.GAAP_NT, #TLIFESTD.DETTRNCOD_CF, #TLIFESTD.ACM_NF, #TLIFESTD.PRS_CF, #TLIFESTD.ACMTRS_NT, #TLIFESTD.SSD_CF, #TLIFESTD.CUR_CF, #TLIFESTD.ESTMNT_M, #TLIFESTD.INDSUP_B, #TLIFESTD.ORICOD_LS, #TLIFESTD.CREUSR_CF, #TLIFESTD.LSTUPD_D, #TLIFESTD.LSTUPDUSR_CF, #TLIFESTD.ORICTR_NF, #TLIFESTD.ORISEC_NF, #TLIFESTD.ORIUWY_NF, #TLIFESTD.DIFF_M, #TLIFESTD.PROPAGATION_B, #TLIFESTD.CALCULATED_B, #TLIFESTD.BATCH_B                                                                                                                                                                          FROM #TLIFESTD 
   
    
    
    PRINT 'TLIFDRID UPDATE'
    SELECT #TLIFDRID.CTR_NF, #TLIFDRID.END_NT, #TLIFDRID.SEC_NF, #TLIFDRID.UWY_NF, #TLIFDRID.UW_NT, #TLIFDRID.CRE_D, #TLIFDRID.BALSHEY_NF, #TLIFDRID.BALSHTMTH_NF, #TLIFDRID.ACY_NF, #TLIFDRID.ACM_NF, #TLIFDRID.SSD_CF, #TLIFDRID.AUTUPD_B, #TLIFDRID.COMACC_B, #TLIFDRID.CMT_NT, #TLIFDRID.CREUSR_CF, #TLIFDRID.LSTUPD_D, #TLIFDRID.LSTUPDUSR_CF, #TLIFDRID.RESPROPAG_B, #TLIFDRID.SEGUPD_B                                                        FROM #TLIFDRID 
    INSERT into TLIFDRID 
    SELECT #TLIFDRID.CTR_NF, #TLIFDRID.END_NT, #TLIFDRID.SEC_NF, #TLIFDRID.UWY_NF, #TLIFDRID.UW_NT, #TLIFDRID.CRE_D, #TLIFDRID.BALSHEY_NF, #TLIFDRID.BALSHTMTH_NF, #TLIFDRID.ACY_NF, #TLIFDRID.ACM_NF, #TLIFDRID.SSD_CF, #TLIFDRID.AUTUPD_B, #TLIFDRID.COMACC_B, #TLIFDRID.CMT_NT, #TLIFDRID.CREUSR_CF, #TLIFDRID.LSTUPD_D, #TLIFDRID.LSTUPDUSR_CF, #TLIFDRID.RESPROPAG_B, #TLIFDRID.SEGUPD_B                                                                                  FROM #TLIFDRID 
    set @erreur = @@error
    if @erreur!=0
      begin
          select @p_erreur = "APPLICATIF;TLIFDRID " + convert(varchar(10),@erreur) + ";"
        goto fin
      end
    SELECT #TLIFDRID.CTR_NF, #TLIFDRID.END_NT, #TLIFDRID.SEC_NF, #TLIFDRID.UWY_NF, #TLIFDRID.UW_NT, #TLIFDRID.CRE_D, #TLIFDRID.BALSHEY_NF, #TLIFDRID.BALSHTMTH_NF, #TLIFDRID.ACY_NF, #TLIFDRID.ACM_NF, #TLIFDRID.SSD_CF, #TLIFDRID.AUTUPD_B, #TLIFDRID.COMACC_B, #TLIFDRID.CMT_NT, #TLIFDRID.CREUSR_CF, #TLIFDRID.LSTUPD_D, #TLIFDRID.LSTUPDUSR_CF, #TLIFDRID.RESPROPAG_B, #TLIFDRID.SEGUPD_B                                                        FROM #TLIFDRID 
    
    PRINT 'TLIFMOD UPDATE'
    SELECT * FROM #TLIFMOD
    INSERT into TLIFMOD 
    SELECT * FROM #TLIFMOD T 
    set @erreur = @@error
    if @erreur!=0
      begin
          select @p_erreur = "APPLICATIF;TLIFMOD " + convert(varchar(10),@erreur) + ";"
        goto fin
      end
     SELECT * FROM #TLIFMOD T 
    
    PRINT 'TLIFMOD2 UPDATE'
    INSERT into TLIFMOD2 
    SELECT #TLIFMOD2.CTR_NF, #TLIFMOD2.SEC_NF, #TLIFMOD2.CRE_D, #TLIFMOD2.BALSHEY_NF, #TLIFMOD2.BALSHTMTH_NF, #TLIFMOD2.ACY_NF, #TLIFMOD2.COMACC_B, #TLIFMOD2.PRIPRMAMT_M, #TLIFMOD2.AFTPRMAMT_M, #TLIFMOD2.PRIRESTECAMT_M, #TLIFMOD2.AFTRESTECAMT_M, #TLIFMOD2.PRIRESDACAMT_M, #TLIFMOD2.AFTRESDACAMT_M, #TLIFMOD2.PRIRESFINAMT_M, #TLIFMOD2.AFTRESFINAMT_M, #TLIFMOD2.CREUSR_CF, #TLIFMOD2.LSTUPD_D, #TLIFMOD2.LSTUPDUSR_CF, #TLIFMOD2.Timestamp, #TLIFMOD2.GAAP_NT                                                                                                                                                 FROM #TLIFMOD2 
    if @erreur!=0
      begin
          select @p_erreur = "APPLICATIF;TLIFMOD2 " + convert(varchar(10),@erreur) + ";"
        goto fin
      end
    SELECT #TLIFMOD2.CTR_NF, #TLIFMOD2.SEC_NF, #TLIFMOD2.CRE_D, #TLIFMOD2.BALSHEY_NF, #TLIFMOD2.BALSHTMTH_NF, #TLIFMOD2.ACY_NF, #TLIFMOD2.COMACC_B, #TLIFMOD2.PRIPRMAMT_M, #TLIFMOD2.AFTPRMAMT_M, #TLIFMOD2.PRIRESTECAMT_M, #TLIFMOD2.AFTRESTECAMT_M, #TLIFMOD2.PRIRESDACAMT_M, #TLIFMOD2.AFTRESDACAMT_M, #TLIFMOD2.PRIRESFINAMT_M, #TLIFMOD2.AFTRESFINAMT_M, #TLIFMOD2.CREUSR_CF, #TLIFMOD2.LSTUPD_D, #TLIFMOD2.LSTUPDUSR_CF, #TLIFMOD2.Timestamp, #TLIFMOD2.GAAP_NT                                                                                   FROM #TLIFMOD2
    


if @tran_imbr=0 commit tran
Print 'STEP 14 COMPLETED'
PRINT ''
  GOTO PROCESSCOMPLETE 
  
fin:
if @tran_imbr=0 rollback tran
PRINT 'PROCESS STOPPED'
GOTO ENDERROR

Print 'STEP 14 COMPLETED'
PRINT ''
/*******************/ 
GOTO PROCESSCOMPLETE
BATCHERROR:
      PRINT 'NIGHT BATCH IS RUNNING'
      GOTO ENDPROCESS 
      RETURN
ENDPROCESS:

select @ano =count(*)from #TANO_TMP
if(@ano > 0) Begin
PRINT ''
PRINT 'ERRORS'
SELECT * from #TANO_TMP
END
      PRINT 'PROCESS STOPPED'
      RETURN
      
PROCESSCOMPLETE:

        Select @CountPeri = count(*) FROM BTRAV..EST_IFRS17_PERIMETER
      PRINT 'UPDATE COMPLETED'
      SELECT @p_msg = 'Update have been done successfully. '  + convert(varchar(10),@CountPeri)  +'line(s) have been updated.'
        PRINT @p_msg
      RETURN
ENDERROR:
    RETURN
GO
EXEC sp_procxmode 'PsEST_IFRS17_01_O2', 'unchained'
go


/*
DELETE  FROM #TANO_TMP  
DELETE  FROM #TLOADING_STEP3
DELETE  FROM #TLOADING_STEP9
DELETE  FROM #TRETRO
DELETE  FROM #TASSUMED
DELETE  FROM #TLIFEST 
*/
if object_id('#TANO_TMP') is not null drop Table #TANO_TMP 
if object_id('#TLOADING_STEP3') is not null drop Table #TLOADING_STEP3
if object_id('#TLOADING_STEP9') is not null drop Table #TLOADING_STEP9
if object_id('#TRETRO') is not null drop Table #TRETRO
if object_id('#TASSUMED') is not null drop Table #TASSUMED
if object_id('#TLIFEST') is not null drop Table #TLIFEST
if object_id('#TLIFESTD') is not null drop Table #TLIFESTD 

IF OBJECT_ID('PsEST_IFRS17_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_01_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_01_O2 TO GDBBATCH
go 
