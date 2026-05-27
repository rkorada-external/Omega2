use BCTA
go

IF OBJECT_ID('dbo.PtCPTCOMMUT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtCPTCOMMUT_01
    IF OBJECT_ID('dbo.PtCPTCOMMUT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtCPTCOMMUT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtCPTCOMMUT_01 >>>'
END
go

-- creation de la procedure

create procedure PtCPTCOMMUT_01
(
  @blcsht_d  char(8),
  @acy_nf    smallint,
  @uworg_cf  smallint           --[002] vdv le 19/07/07
)
as

/***************************************************

Programme: PtCPTCOMMUT_01


Fichier script associe : BCTA_PtCPTCOMMUT_01.prc

Base principale : BCTA

Version: 1

Auteur: JFVDE

Date de creation: 04/10/2006

Description du programme:

      Contrepassation comptables des précédentes positions SAP et
      insertion des nouvelles positions à zéro dans TACCTRN

Parametres:
Conditions d'execution:
Commentaires:

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif [001]     |             |
van de velde    | 06/03/2007  | prise en compte des tables btrt & bfac TRFCROSSREF pour la sélection des contrats commutés.
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif [002]     |             |
van de velde    | 19/07/2007  | prise en compte du paramètre UWORG_CF
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 17/09/2009  |[18053] Pour les fac xxLyyyyy, remplacement du test sur les lettres par un interval qui couvre l'ensemble du domaine des FACs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
*********************************************************************************************/
PRINT '************* BCTA_PtCPTCOMMUT_01.prc *****************'
PRINT '@@@@@@@@@@@@                             @@@@@@@@@'
PRINT '@@@@@@@@@@@@  C O M M U T A T I O N      @@@@@@@@@'
PRINT '@@@@@@@@@@@@                             @@@@@@@@@'
PRINT ' '

PRINT ' Creation des tables temporaires'
PRINT ''

if object_id('#TCONTR') is not null
	drop table #TCONTR

create table #TCONTR (
    ctr_nf      char(9),
    uwy_nf      smallint)

if object_id('#TDETTRS') is not null
	drop table #TDETTRS

create table #TDETTRS ( dettrs_cf    UDETTRS_CF)

if object_id('#TACCTRN') is not null
	drop table #TACCTRN

CREATE TABLE #TACCTRN (
    SSD_CF       USSD_CF              NOT NULL,
    ESB_CF       UESB_CF              NOT NULL,
    TRNALN_NT    numeric(10,0)            NULL,
    CTR_NF       UCTR_NF              NOT NULL,
    UWY_NF       UUWY_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT 1,
    END_NT       UEND_NT              DEFAULT 0,
    SEC_NF       USEC_NF                  NULL,
    ALN_NF       tinyint                  NULL,
    REB_NF       int                      NULL,
    ACCTYP_CF    tinyint                  NULL,
    APR_NT       tinyint                  NULL,
    PRG_NT       int                      NULL,
    PRGORD_NT    tinyint                  NULL,
    CLI_NF       UCLI_NF                  NULL,
    GRP_CF       UGRP_CF                  NULL,
    SNTACC_NT    int                      NULL,
    SCOSTRMTH_NF tinyint              NOT NULL,
    SCOENDMTH_NF tinyint              NOT NULL,
    ACY_NF       smallint             NOT NULL,
    BLCSHT_D     datetime                 NULL,
    TRNSTS_CT    tinyint                  NULL,
    TRNCOD_CF    UDETTRS_CF           DEFAULT '',
    CTRNCOD_CF   UDETTRS_CF           DEFAULT '',
    DER_SAP  	 UAMT_M               NOT NULL,
    CURAMT100_M  UAMT_M                   NULL,
    CUR_CF       UCUR_CF              DEFAULT '',
    SHA_R        USHA_R                   NULL,
    CNVCUR_CF    UCUR_CF              DEFAULT '',
    CNVAMT_M     UAMT_M                   NULL,
    MTH_B        bit                  DEFAULT 0,
    MTH_D        datetime                 NULL,
    VLD_D        datetime                 NULL,
    GENLDGTRF_D  datetime                 NULL,
    STL_D        datetime                 NULL,
    OCCYEA_NF    smallint                 NULL,
    INCFMT_CT    tinyint                  NULL,
    LSTUPD_D     UUPD_D               DEFAULT getdate(),
    LSTUPDUSR_CF UUPDUSR_CF               NULL,
    LOB_CF       ULOB_CF              DEFAULT '',
    SOB_CF       USOB_CF              DEFAULT '',
    TOP_CF       UTOP_CF              DEFAULT '',
    NAT_CF       UCTRNAT_CF           DEFAULT '',
    SUBNAT_CF    UCTRSUBNAT_CF        DEFAULT '',
    GAR_CF       UGAR_CF              DEFAULT '',
    USRCRTCOD_CT UUSRCRTCOD_CT            NULL,
    USRCRTVAL_LM UL32                     NULL,
    PRMLIN_NT    smallint                 NULL,
    CED_NF       UCLI_NF              NOT NULL,
    LSTTRN_B     bit                  DEFAULT 1,
    RSVRLSFLG_B  bit                  DEFAULT 0,
    CLM_NF       int                      NULL,
    RETFLG_CT    tinyint              DEFAULT 0,
    PAYNBR_NF    int                      NULL,
    PAYTYP_CT    char(1)                  NULL)


if object_id('#TACCTRN2') is not null
	drop table #TACCTRN2

CREATE TABLE #TACCTRN2 (
    TRN_NT       numeric(10,0)        NOT NULL,
    SSD_CF       USSD_CF              NOT NULL,
    ESB_CF       UESB_CF              NOT NULL,
    TRNALN_NT    numeric(10,0)            NULL,
    CTR_NF       UCTR_NF              NOT NULL,
    UWY_NF       UUWY_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT 1,
    END_NT       UEND_NT              DEFAULT 0,
    SEC_NF       USEC_NF                  NULL,
    ALN_NF       tinyint                  NULL,
    REB_NF       int                      NULL,
    ACCTYP_CF    tinyint                  NULL,
    APR_NT       tinyint                  NULL,
    PRG_NT       int                      NULL,
    PRGORD_NT    tinyint                  NULL,
    CLI_NF       UCLI_NF                  NULL,
    GRP_CF       UGRP_CF                  NULL,
    SNTACC_NT    int                      NULL,
    SCOSTRMTH_NF tinyint              NOT NULL,
    SCOENDMTH_NF tinyint              NOT NULL,
    ACY_NF       smallint             NOT NULL,
    BLCSHT_D     datetime                 NULL,
    TRNSTS_CT    tinyint                  NULL,
    TRNCOD_CF    UDETTRS_CF           DEFAULT '',
    CTRNCOD_CF   UDETTRS_CF           DEFAULT '',
    ORICURAMT_M  UAMT_M               NOT NULL,
    CURAMT100_M  UAMT_M                   NULL,
    CUR_CF       UCUR_CF              DEFAULT '',
    SHA_R        USHA_R                   NULL,
    CNVCUR_CF    UCUR_CF              DEFAULT '',
    CNVAMT_M     UAMT_M                   NULL,
    MTH_B        bit                  DEFAULT 0,
    MTH_D        datetime                 NULL,
    VLD_D        datetime                 NULL,
    GENLDGTRF_D  datetime                 NULL,
    STL_D        datetime                 NULL,
    OCCYEA_NF    smallint                 NULL,
    INCFMT_CT    tinyint                  NULL,
    LSTUPD_D     UUPD_D               DEFAULT getdate(),
    LSTUPDUSR_CF UUPDUSR_CF               NULL,
    LOB_CF       ULOB_CF              DEFAULT '',
    SOB_CF       USOB_CF              DEFAULT '',
    TOP_CF       UTOP_CF              DEFAULT '',
    NAT_CF       UCTRNAT_CF           DEFAULT '',
    SUBNAT_CF    UCTRSUBNAT_CF        DEFAULT '',
    GAR_CF       UGAR_CF              DEFAULT '',
    USRCRTCOD_CT UUSRCRTCOD_CT            NULL,
    USRCRTVAL_LM UL32                     NULL,
    PRMLIN_NT    smallint                 NULL,
    CED_NF       UCLI_NF              NOT NULL,
    LSTTRN_B     bit                  DEFAULT 1,
    RSVRLSFLG_B  bit                  DEFAULT 0,
    CLM_NF       int                      NULL,
    RETFLG_CT    tinyint              DEFAULT 0,
    PAYNBR_NF    int                      NULL,
    PAYTYP_CT    char(1)                  NULL)

if object_id('#SAP_TACCTRN') is not null
	drop table #SAP_TACCTRN

CREATE TABLE #SAP_TACCTRN (
    TRN_NT       numeric(10,0)        NOT NULL,
    SSD_CF       USSD_CF              NOT NULL,
    ESB_CF       UESB_CF              NOT NULL,
    TRNALN_NT    numeric(10,0)            NULL,
    CTR_NF       UCTR_NF              NOT NULL,
    UWY_NF       UUWY_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT 1,
    END_NT       UEND_NT              DEFAULT 0,
    SEC_NF       USEC_NF                  NULL,
    ALN_NF       tinyint                  NULL,
    REB_NF       int                      NULL,
    ACCTYP_CF    tinyint                  NULL,
    APR_NT       tinyint                  NULL,
    PRG_NT       int                      NULL,
    PRGORD_NT    tinyint                  NULL,
    CLI_NF       UCLI_NF                  NULL,
    GRP_CF       UGRP_CF                  NULL,
    SNTACC_NT    int                      NULL,
    SCOSTRMTH_NF tinyint              NOT NULL,
    SCOENDMTH_NF tinyint              NOT NULL,
    ACY_NF       smallint             NOT NULL,
    BLCSHT_D     datetime                 NULL,
    TRNSTS_CT    tinyint                  NULL,
    TRNCOD_CF    UDETTRS_CF           DEFAULT '',
    CTRNCOD_CF   UDETTRS_CF           DEFAULT '',
    ORICURAMT_M  UAMT_M               NOT NULL,
    CURAMT100_M  UAMT_M                   NULL,
    CUR_CF       UCUR_CF              DEFAULT '',
    SHA_R        USHA_R                   NULL,
    CNVCUR_CF    UCUR_CF              DEFAULT '',
    CNVAMT_M     UAMT_M                   NULL,
    MTH_B        bit                  DEFAULT 0,
    MTH_D        datetime                 NULL,
    VLD_D        datetime                 NULL,
    GENLDGTRF_D  datetime                 NULL,
    STL_D        datetime                 NULL,
    OCCYEA_NF    smallint                 NULL,
    INCFMT_CT    tinyint                  NULL,
    LSTUPD_D     UUPD_D               DEFAULT getdate(),
    LSTUPDUSR_CF UUPDUSR_CF               NULL,
    LOB_CF       ULOB_CF              DEFAULT '',
    SOB_CF       USOB_CF              DEFAULT '',
    TOP_CF       UTOP_CF              DEFAULT '',
    NAT_CF       UCTRNAT_CF           DEFAULT '',
    SUBNAT_CF    UCTRSUBNAT_CF        DEFAULT '',
    GAR_CF       UGAR_CF              DEFAULT '',
    USRCRTCOD_CT UUSRCRTCOD_CT            NULL,
    USRCRTVAL_LM UL32                     NULL,
    PRMLIN_NT    smallint                 NULL,
    CED_NF       UCLI_NF              NOT NULL,
    LSTTRN_B     bit                  DEFAULT 1,
    RSVRLSFLG_B  bit                  DEFAULT 0,
    CLM_NF       int                      NULL,
    RETFLG_CT    tinyint              DEFAULT 0,
    PAYNBR_NF    int                      NULL,
    PAYTYP_CT    char(1)                  NULL)

if object_id('#PROV_PNA_FAR') is not null
	drop table #PROV_PNA_FAR

CREATE TABLE #PROV_PNA_FAR (
    TRN_NT       numeric(10,0)        NOT NULL,
    SSD_CF       USSD_CF              NOT NULL,
    ESB_CF       UESB_CF              NOT NULL,
    TRNALN_NT    numeric(10,0)            NULL,
    CTR_NF       UCTR_NF              NOT NULL,
    UWY_NF       UUWY_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT 1,
    END_NT       UEND_NT              DEFAULT 0,
    SEC_NF       USEC_NF                  NULL,
    ALN_NF       tinyint                  NULL,
    REB_NF       int                      NULL,
    ACCTYP_CF    tinyint                  NULL,
    APR_NT       tinyint                  NULL,
    PRG_NT       int                      NULL,
    PRGORD_NT    tinyint                  NULL,
    CLI_NF       UCLI_NF                  NULL,
    GRP_CF       UGRP_CF                  NULL,
    SNTACC_NT    int                      NULL,
    SCOSTRMTH_NF tinyint              NOT NULL,
    SCOENDMTH_NF tinyint              NOT NULL,
    ACY_NF       smallint             NOT NULL,
    BLCSHT_D     datetime                 NULL,
    TRNSTS_CT    tinyint                  NULL,
    TRNCOD_CF    UDETTRS_CF           DEFAULT '',
    CTRNCOD_CF   UDETTRS_CF           DEFAULT '',
    ORICURAMT_M  UAMT_M               NOT NULL,
    CURAMT100_M  UAMT_M                   NULL,
    CUR_CF       UCUR_CF              DEFAULT '',
    SHA_R        USHA_R                   NULL,
    CNVCUR_CF    UCUR_CF              DEFAULT '',
    CNVAMT_M     UAMT_M                   NULL,
    MTH_B        bit                  DEFAULT 0,
    MTH_D        datetime                 NULL,
    VLD_D        datetime                 NULL,
    GENLDGTRF_D  datetime                 NULL,
    STL_D        datetime                 NULL,
    OCCYEA_NF    smallint                 NULL,
    INCFMT_CT    tinyint                  NULL,
    LSTUPD_D     UUPD_D               DEFAULT getdate(),
    LSTUPDUSR_CF UUPDUSR_CF               NULL,
    LOB_CF       ULOB_CF              DEFAULT '',
    SOB_CF       USOB_CF              DEFAULT '',
    TOP_CF       UTOP_CF              DEFAULT '',
    NAT_CF       UCTRNAT_CF           DEFAULT '',
    SUBNAT_CF    UCTRSUBNAT_CF        DEFAULT '',
    GAR_CF       UGAR_CF              DEFAULT '',
    USRCRTCOD_CT UUSRCRTCOD_CT            NULL,
    USRCRTVAL_LM UL32                     NULL,
    PRMLIN_NT    smallint                 NULL,
    CED_NF       UCLI_NF              NOT NULL,
    LSTTRN_B     bit                  DEFAULT 1,
    RSVRLSFLG_B  bit                  DEFAULT 0,
    CLM_NF       int                      NULL,
    RETFLG_CT    tinyint              DEFAULT 0,
    PAYNBR_NF    int                      NULL,
    PAYTYP_CT    char(1)                  NULL)

if object_id('#TACCTRN3') is not null
	drop table #TACCTRN3

CREATE TABLE #TACCTRN3 (
    TRN_NT       numeric(10,0)        NOT NULL,
    SSD_CF       USSD_CF              NOT NULL,
    ESB_CF       UESB_CF              NOT NULL,
    TRNALN_NT    numeric(10,0)            NULL,
    CTR_NF       UCTR_NF              NOT NULL,
    UWY_NF       UUWY_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT 1,
    END_NT       UEND_NT              DEFAULT 0,
    SEC_NF       USEC_NF                  NULL,
    ALN_NF       tinyint                  NULL,
    REB_NF       int                      NULL,
    ACCTYP_CF    tinyint                  NULL,
    APR_NT       tinyint                  NULL,
    PRG_NT       int                      NULL,
    PRGORD_NT    tinyint                  NULL,
    CLI_NF       UCLI_NF                  NULL,
    GRP_CF       UGRP_CF                  NULL,
    SNTACC_NT    int                      NULL,
    SCOSTRMTH_NF tinyint              NOT NULL,
    SCOENDMTH_NF tinyint              NOT NULL,
    ACY_NF       smallint             NOT NULL,
    BLCSHT_D     datetime                 NULL,
    TRNSTS_CT    tinyint                  NULL,
    TRNCOD_CF    UDETTRS_CF           DEFAULT '',
    CTRNCOD_CF   UDETTRS_CF           DEFAULT '',
    ORICURAMT_M  UAMT_M               NOT NULL,
    CURAMT100_M  UAMT_M                   NULL,
    CUR_CF       UCUR_CF              DEFAULT '',
    SHA_R        USHA_R                   NULL,
    CNVCUR_CF    UCUR_CF              DEFAULT '',
    CNVAMT_M     UAMT_M                   NULL,
    MTH_B        bit                  DEFAULT 0,
    MTH_D        datetime                 NULL,
    VLD_D        datetime                 NULL,
    GENLDGTRF_D  datetime                 NULL,
    STL_D        datetime                 NULL,
    OCCYEA_NF    smallint                 NULL,
    INCFMT_CT    tinyint                  NULL,
    LSTUPD_D     UUPD_D               DEFAULT getdate(),
    LSTUPDUSR_CF UUPDUSR_CF               NULL,
    LOB_CF       ULOB_CF              DEFAULT '',
    SOB_CF       USOB_CF              DEFAULT '',
    TOP_CF       UTOP_CF              DEFAULT '',
    NAT_CF       UCTRNAT_CF           DEFAULT '',
    SUBNAT_CF    UCTRSUBNAT_CF        DEFAULT '',
    GAR_CF       UGAR_CF              DEFAULT '',
    USRCRTCOD_CT UUSRCRTCOD_CT            NULL,
    USRCRTVAL_LM UL32                     NULL,
    PRMLIN_NT    smallint                 NULL,
    CED_NF       UCLI_NF              NOT NULL,
    LSTTRN_B     bit                  DEFAULT 1,
    RSVRLSFLG_B  bit                  DEFAULT 0,
    CLM_NF       int                      NULL,
    RETFLG_CT    tinyint              DEFAULT 0,
    PAYNBR_NF    int                      NULL,
    PAYTYP_CT    char(1)                  NULL)

/****
declare @p_top_comut bit
-- si le top commutation = 1, le traitement est déjà passé; arrêt du traitement
select @p_top_comut= (select distinct top_comut from BTRAV..CNC_CNCD2000_COMMUTCTRUWY)
if @p_top_comut= 1
    begin
    print '***** le traitement pour la commutation est déjà passé *****'
    print '****** A vérifier ******************************************'
    goto FIN
    end
**/

-- -----------------------------------------------
PRINT '--Déclaration et chargement des variables'
-- -----------------------------------------------

declare
		@erreur		int,
		@errno		int,
		@errmsg		varchar(255)

declare 	@msg1		char(20),
		@msg2		char(7),
		@msg3		varchar(60),
		@msg_erreur	varchar(60),
		@lignes		int

declare     @p_blcsht_d  datetime,
            @p_date_acy  datetime,
            @p_acy_nf    smallint,
            @cpt_edit    int

select @p_blcsht_d = @blcsht_d
select @p_acy_nf   = @acy_nf
select '@p_blcsht_d = ', @p_blcsht_d
select '@p_acy_nf   = ', @p_acy_nf

select @p_date_acy = convert (datetime, convert(char(8), ( (@p_acy_nf * 10000) +
                                        (datepart(mm, @p_blcsht_d) * 100) +
                                         01 ) ) )
select '@p_date_acy = ', @p_date_acy

-- ----------------------------------------------------------------------------------------------------------------------
PRINT ''
PRINT '-- Chargement des contrat/exercice en table temporaire'
PRINT '-- Récupération de tous les exercices des contrats dont l''ensemble sinistralité & comptabilité doit être commutés'
-- ----------------------------------------------------------------------------------------------------------------------

---  ********************************  modif 001
-- insert into #TCONTR
-- select distinct ctr_nf, uwy_nf
-- from BTRAV..CNC_CNCD2000_COMMUTCTRUWY

PRINT ' '
PRINT 'TRAITES - récupération contrat/exercice commutés'
insert into #TCONTR
select distinct tcontr.ctr_nf, tcontr.uwy_nf
FROM btrt..TRFCROSSREF crossref,
     btrt..TCONTR tcontr
WHERE   tcontr.ctr_nf     = crossref.ctr_nf
AND     crossref.uworg_cf = @uworg_cf    -- origine du portefeuille en commutation   [002] vdv le 19/07/07
AND     tcontr.ssd_cf     = crossref.ssd_cf

PRINT ' '
PRINT 'FACULTATIVES - récupération contrat/exercice commutés'
insert into #TCONTR
select distinct tcontr.ctr_nf, tcontr.uwy_nf
FROM bfac..TRFCROSSREF crossref,
     bfac..TCONTR tcontr
WHERE   tcontr.ctr_nf     = crossref.ctr_nf
AND     crossref.uworg_cf = @uworg_cf    -- origine du portefeuille en commutation     [002] vdv le 19/07/07
AND     tcontr.ssd_cf     = crossref.ssd_cf

insert into #TDETTRS
select distinct dettrs_cf
from   bref..tdettrs
where  trstyp_ct = 3
and    dettrs_cf like '[13][0-3]_____[01]'

-- -------------------------------------------------------------------------------------------------------
PRINT '-- Recherche derniére position sap par contrat,ex,no ordre,avenant,section,devise,période,ac,poste'
-- -------------------------------------------------------------------------------------------------------
print ' '
print 'insert into #TACCTRN2'
insert into #TACCTRN2 (
		TRN_NT,
		SSD_CF,
		ESB_CF,
		CTR_NF,
		UWY_NF,
		UW_NT,
		END_NT,
		SEC_NF,
		CUR_CF,
		SCOSTRMTH_NF,
		SCOENDMTH_NF,
		OCCYEA_NF,
		ACY_NF,
		TRNCOD_CF,
		CTRNCOD_CF,
		ORICURAMT_M,
		LOB_CF,
		SOB_CF,
		TOP_CF,
		NAT_CF,
		SUBNAT_CF,
		GAR_CF,
		CED_NF)
select distinct
    b.TRN_NT,
		b.SSD_CF,
		b.ESB_CF,
		b.CTR_NF,
		b.UWY_NF,
		b.UW_NT,
		b.END_NT,
		b.SEC_NF,
		b.CUR_CF,
		b.SCOSTRMTH_NF,
		b.SCOENDMTH_NF,
		b.OCCYEA_NF,
		b.ACY_NF,
		b.TRNCOD_CF,
		b.CTRNCOD_CF,
		b.ORICURAMT_M,		--der_sap=sum(b.ORICURAMT_M),
		b.LOB_CF,
		b.SOB_CF,
		b.TOP_CF,
		b.NAT_CF,
		b.SUBNAT_CF,
		b.GAR_CF,
		b.CED_NF
from  #TCONTR a,
      bcta..TACCTRN b
where	a.ctr_nf     = b.ctr_nf
and	  a.uwy_nf     = b.uwy_nf
and	  (b.nat_cf    >= '30' and b.nat_cf not in ('40','41') -- NP
            or (substring (a.ctr_nf,3,1) between 'A' and 'M' and  b.nat_cf   < '29')) -- FAC
and 	b.trncod_cf in (select dettrs_cf from #TDETTRS)
and	  datepart(yy, b.blcsht_D) = datepart(yy,@p_blcsht_d)


select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. Insert into #TACCTRN2'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print " "

----------------------------------------------------------------------------
PRINT '-- Delete les postes L0 / rejet'
----------------------------------------------------------------------------
print ' '
print 'Delete from #TACCTRN2 where substring(TRNCOD_CF, 7, 1) = 1'
print '                         or substring(TRNCOD_CF, 8, 1) = 1'

Delete from #TACCTRN2
 where substring(TRNCOD_CF, 7, 1) = '1'
    or substring(TRNCOD_CF, 8, 1) = '1'

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. Delete from #TACCTRN2'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '
-- select distinct trncod_cf from #TACCTRN2

----------------------------------------------------------------------------
PRINT '-- Transformer tous les postes cpta. de Lib en Cst.  --'
----------------------------------------------------------------------------

print 'Update #TACCTRN2 set TRNCOD_CF = DETTRS_CF'

Update #TACCTRN2
set TRNCOD_CF = a.DETTRS_CF
From BREF..TDETTRS a
Where #TACCTRN2.TRNCOD_CF = a.FINRLSTRS_CF
and   substring(a.DETTRS_CF,7,2) not in ('10','01') -- car 1 poste finrlstrs_cf peut ramener plus d'1 poste dettrs

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. Update #TACCTRN2 set TRNCOD_CF = DETTRS_CF'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print " "

-- -------------------------------------
PRINT '-- sélection des postes de SAP '
-- -------------------------------------
insert into #SAP_TACCTRN
SELECT * from #TACCTRN2
where TRNCOD_CF in
('11420000','11420500','11420600','11420400','11427000','11480000','11480200','11480100','11487000',
'11420900','11420800','11427900')

-- -----------------------------------------------
PRINT '-- sélection des postes différents de SAP '
-- -----------------------------------------------
insert into #PROV_PNA_FAR
SELECT * from #TACCTRN2
where TRNCOD_CF not in
('11420000','11420500','11420600','11420400','11427000','11480000','11480200','11480100','11487000',
'11420900','11420800','11427900')

----------------------------------------------------------------------------
PRINT '-- duplication de la table #SAP_tacctrn (postes SAP)'
----------------------------------------------------------------------------
print ' '
print 'select * into #TACCTRN3 from #SAP_TACCTRN'

insert into #TACCTRN3
select #TACCTRN2.TRN_NT, #TACCTRN2.SSD_CF, #TACCTRN2.ESB_CF, #TACCTRN2.TRNALN_NT, #TACCTRN2.CTR_NF, #TACCTRN2.UWY_NF, #TACCTRN2.UW_NT, #TACCTRN2.END_NT, #TACCTRN2.SEC_NF, #TACCTRN2.ALN_NF, #TACCTRN2.REB_NF, #TACCTRN2.ACCTYP_CF, #TACCTRN2.APR_NT, #TACCTRN2.PRG_NT, #TACCTRN2.PRGORD_NT, #TACCTRN2.CLI_NF, #TACCTRN2.GRP_CF, #TACCTRN2.SNTACC_NT, #TACCTRN2.SCOSTRMTH_NF, #TACCTRN2.SCOENDMTH_NF, #TACCTRN2.ACY_NF, #TACCTRN2.BLCSHT_D, #TACCTRN2.TRNSTS_CT, #TACCTRN2.TRNCOD_CF, #TACCTRN2.CTRNCOD_CF, #TACCTRN2.ORICURAMT_M, #TACCTRN2.CURAMT100_M, #TACCTRN2.CUR_CF, #TACCTRN2.SHA_R, #TACCTRN2.CNVCUR_CF, #TACCTRN2.CNVAMT_M, #TACCTRN2.MTH_B, #TACCTRN2.MTH_D, #TACCTRN2.VLD_D, #TACCTRN2.GENLDGTRF_D, #TACCTRN2.STL_D, #TACCTRN2.OCCYEA_NF, #TACCTRN2.INCFMT_CT, #TACCTRN2.LSTUPD_D, #TACCTRN2.LSTUPDUSR_CF, #TACCTRN2.LOB_CF, #TACCTRN2.SOB_CF, #TACCTRN2.TOP_CF, #TACCTRN2.NAT_CF, #TACCTRN2.SUBNAT_CF, #TACCTRN2.GAR_CF, #TACCTRN2.USRCRTCOD_CT, #TACCTRN2.USRCRTVAL_LM, #TACCTRN2.PRMLIN_NT, #TACCTRN2.CED_NF, #TACCTRN2.LSTTRN_B, #TACCTRN2.RSVRLSFLG_B, #TACCTRN2.CLM_NF, #TACCTRN2.RETFLG_CT, #TACCTRN2.PAYNBR_NF, #TACCTRN2.PAYTYP_CT
from #SAP_TACCTRN #TACCTRN2

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. select * into #TACCTRN3 from #SAP_TACCTRN'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '


----------------------------------------------------------------------------
PRINT '-- cumul des montants des mvts comptables'
----------------------------------------------------------------------------
print ' '
print 'Update #SAP_TACCTRN set oricuramt_m = sum(oricuramt_m)'
Update #SAP_TACCTRN
set oricuramt_m = ( select isnull(sum(b.oricuramt_m), 0)
                      from #TACCTRN3 b
                     where b.ctr_nf    = #SAP_TACCTRN.ctr_nf
                       and b.uwy_nf    = #SAP_TACCTRN.uwy_nf
                       and b.uw_nt     = #SAP_TACCTRN.uw_nt
                       and b.end_nt    = #SAP_TACCTRN.end_nt
                       and b.sec_nf    = #SAP_TACCTRN.sec_nf
                       and b.trncod_cf = #SAP_TACCTRN.trncod_cf
                       and b.cur_cf    = #SAP_TACCTRN.cur_cf
                       and b.occyea_nf = #SAP_TACCTRN.occyea_nf
                  )

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. Update #SAP_TACCTRN set oricuramt_m = sum(oricuramt_m)'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print " "

----------------------------------------------------------------------------
PRINT '-- Recherche max ACY_NF :'
----------------------------------------------------------------------------

print ' '
print 'update #SAP_TACCTRN set acy_nf = max(acy_nf)'

update #SAP_TACCTRN
set ACY_NF = ( select isnull(max(b.ACY_NF), @p_acy_nf)
                    from #TACCTRN3 b
                   where b.CTR_NF    = #SAP_TACCTRN.CTR_NF
                     and b.uwy_nf    = #SAP_TACCTRN.uwy_nf
                     and b.uw_nt     = #SAP_TACCTRN.uw_nt
                     and b.end_nt    = #SAP_TACCTRN.end_nt
                     and b.sec_nf    = #SAP_TACCTRN.sec_nf
                     and b.trncod_cf = #SAP_TACCTRN.trncod_cf
                     and b.cur_cf    = #SAP_TACCTRN.cur_cf
                     and b.occyea_nf = #SAP_TACCTRN.occyea_nf
	        )

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. update #SAP_TACCTRN set acy_nf = max(acy_nf)'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '

----------------------------------------------------------------------------
PRINT '-- Recherche max SCOSTRMTH_NF'
----------------------------------------------------------------------------
print  ' '
print 'update #SAP_TACCTRN max(SCOENDMTH_NF)'
update #SAP_TACCTRN
set SCOENDMTH_NF = ( select isnull(max(b.SCOENDMTH_NF), 1)
                       from #TACCTRN3 b
                      where b.ctr_nf    = #SAP_TACCTRN.ctr_nf
                        and b.uwy_nf    = #SAP_TACCTRN.uwy_nf
                        and b.uw_nt     = #SAP_TACCTRN.uw_nt
                        and b.end_nt    = #SAP_TACCTRN.end_nt
                        and b.sec_nf    = #SAP_TACCTRN.sec_nf
                        and b.trncod_cf = #SAP_TACCTRN.trncod_cf
                        and b.cur_cf    = #SAP_TACCTRN.cur_cf
                        and b.acy_nf    = #SAP_TACCTRN.acy_nf
                        and b.occyea_nf = #SAP_TACCTRN.occyea_nf
                    )
    ,SCOSTRMTH_NF = ( select isnull(max(c.SCOENDMTH_NF), 1)
                       from #TACCTRN3 c
                      where c.ctr_nf    = #SAP_TACCTRN.ctr_nf
                        and c.uwy_nf    = #SAP_TACCTRN.uwy_nf
                        and c.uw_nt     = #SAP_TACCTRN.uw_nt
                        and c.end_nt    = #SAP_TACCTRN.end_nt
                        and c.sec_nf    = #SAP_TACCTRN.sec_nf
                        and c.trncod_cf = #SAP_TACCTRN.trncod_cf
                        and c.cur_cf    = #SAP_TACCTRN.cur_cf
                        and c.acy_nf    = #SAP_TACCTRN.acy_nf
                        and c.occyea_nf = #SAP_TACCTRN.occyea_nf
                    )

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. update #SAP_TACCTRN max(SCOENDMTH_NF)'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '

----------------------------------------------------------------------------
PRINT '-- rechargement de la table #tacctrn à partir de #SAP_TACCTRN'
----------------------------------------------------------------------------
print ' '
print 'insert into #TACCTRN'
insert into #TACCTRN  (
		       SSD_CF,
		       ESB_CF,
      	   CTR_NF,
		       UWY_NF,
		       UW_NT,
		       END_NT,
		       SEC_NF,
		       CUR_CF,
		       SCOSTRMTH_NF,
		       SCOENDMTH_NF,
		       OCCYEA_NF,
		       ACY_NF,
		       TRNCOD_CF,
		       CTRNCOD_CF,
		       der_sap,			--ORICURAMT_M,
		       LOB_CF,
		       SOB_CF,
		       TOP_CF,
		       NAT_CF,
		       SUBNAT_CF,
		       GAR_CF,
		       CED_NF)
select distinct
       	   SSD_CF,
		       ESB_CF,
		       CTR_NF,
		       UWY_NF,
		       UW_NT,
		       END_NT,
		       SEC_NF,
		       CUR_CF,
		       SCOSTRMTH_NF,
		       SCOENDMTH_NF,
		       OCCYEA_NF,
		       ACY_NF,
		       TRNCOD_CF,
		       CTRNCOD_CF,
		       ORICURAMT_M,
		       LOB_CF,
		       SOB_CF,
		       TOP_CF,
		       NAT_CF,
		       SUBNAT_CF,
		       GAR_CF,
		       CED_NF
  from    #SAP_TACCTRN

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. Insert into #TACCTRN'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '

--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

PRINT 'traitement des postes de PNA & FAR (11410000 / 11430000)'
PRINT '  '

----------------------------------------------------------------------------
-- duplication de la table #PROV_PNA_FAR
----------------------------------------------------------------------------
print ' '
print 'select * into #TACCTRN3 from #PROV_PNA_FAR'

insert into #TACCTRN3
select #TACCTRN2.TRN_NT, #TACCTRN2.SSD_CF, #TACCTRN2.ESB_CF, #TACCTRN2.TRNALN_NT, #TACCTRN2.CTR_NF, #TACCTRN2.UWY_NF, #TACCTRN2.UW_NT, #TACCTRN2.END_NT, #TACCTRN2.SEC_NF, #TACCTRN2.ALN_NF, #TACCTRN2.REB_NF, #TACCTRN2.ACCTYP_CF, #TACCTRN2.APR_NT, #TACCTRN2.PRG_NT, #TACCTRN2.PRGORD_NT, #TACCTRN2.CLI_NF, #TACCTRN2.GRP_CF, #TACCTRN2.SNTACC_NT, #TACCTRN2.SCOSTRMTH_NF, #TACCTRN2.SCOENDMTH_NF, #TACCTRN2.ACY_NF, #TACCTRN2.BLCSHT_D, #TACCTRN2.TRNSTS_CT, #TACCTRN2.TRNCOD_CF, #TACCTRN2.CTRNCOD_CF, #TACCTRN2.ORICURAMT_M, #TACCTRN2.CURAMT100_M, #TACCTRN2.CUR_CF, #TACCTRN2.SHA_R, #TACCTRN2.CNVCUR_CF, #TACCTRN2.CNVAMT_M, #TACCTRN2.MTH_B, #TACCTRN2.MTH_D, #TACCTRN2.VLD_D, #TACCTRN2.GENLDGTRF_D, #TACCTRN2.STL_D, #TACCTRN2.OCCYEA_NF, #TACCTRN2.INCFMT_CT, #TACCTRN2.LSTUPD_D, #TACCTRN2.LSTUPDUSR_CF, #TACCTRN2.LOB_CF, #TACCTRN2.SOB_CF, #TACCTRN2.TOP_CF, #TACCTRN2.NAT_CF, #TACCTRN2.SUBNAT_CF, #TACCTRN2.GAR_CF, #TACCTRN2.USRCRTCOD_CT, #TACCTRN2.USRCRTVAL_LM, #TACCTRN2.PRMLIN_NT, #TACCTRN2.CED_NF, #TACCTRN2.LSTTRN_B, #TACCTRN2.RSVRLSFLG_B, #TACCTRN2.CLM_NF, #TACCTRN2.RETFLG_CT, #TACCTRN2.PAYNBR_NF, #TACCTRN2.PAYTYP_CT
from #PROV_PNA_FAR #TACCTRN2

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'pb. select * into #TACCTRN3 from #SAP_TACCTRN'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '

----------------------------------------------------------------------------
-- cumul des montants des mvts comptables
----------------------------------------------------------------------------
print ' '
print 'Update #PROV_PNA_FAR set oricuramt_m = sum(oricuramt_m)'
Update #PROV_PNA_FAR
set oricuramt_m = ( select isnull(sum(b.oricuramt_m), 0)
                      from #TACCTRN3 b
                     where b.ctr_nf    = #PROV_PNA_FAR.ctr_nf
                       and b.uwy_nf    = #PROV_PNA_FAR.uwy_nf
                       and b.uw_nt     = #PROV_PNA_FAR.uw_nt
                       and b.end_nt    = #PROV_PNA_FAR.end_nt
                       and b.sec_nf    = #PROV_PNA_FAR.sec_nf
                       and b.trncod_cf = #PROV_PNA_FAR.trncod_cf
                       and b.cur_cf    = #PROV_PNA_FAR.cur_cf
                       and b.occyea_nf = #PROV_PNA_FAR.occyea_nf
                  )

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. Update #PROV_PNA_FAR set oricuramt_m = sum(oricuramt_m)'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '

----------------------------------------------------------------------------
-- Recherche max ACY_NF :
----------------------------------------------------------------------------
print ' '
print 'update #PROV_PNA_FAR set acy_nf = max(acy_nf)'

update #PROV_PNA_FAR
SET ACY_NF = ( select isnull(max(b.ACY_NF),@p_acy_nf)
                    from #TACCTRN3 b
                   where b.CTR_NF    = #PROV_PNA_FAR.CTR_NF
                     and b.uwy_nf    = #PROV_PNA_FAR.uwy_nf
                     and b.uw_nt     = #PROV_PNA_FAR.uw_nt
                     and b.end_nt    = #PROV_PNA_FAR.end_nt
                     and b.sec_nf    = #PROV_PNA_FAR.sec_nf
                     and b.trncod_cf = #PROV_PNA_FAR.trncod_cf
                     and b.cur_cf    = #PROV_PNA_FAR.cur_cf
                     and b.occyea_nf = #PROV_PNA_FAR.occyea_nf
    	        )

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. update #PROV_PNA_FAR set acy_nf = max(acy_nf)'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '

----------------------------------------------------------------------------
-- Recherche max SCOSTRMTH_NF
----------------------------------------------------------------------------
print ' '
print 'update #PROV_PNA_FAR max(SCOENDMTH_NF)'
update #PROV_PNA_FAR
set SCOENDMTH_NF = ( select isnull(max(b.SCOENDMTH_NF), 1)
                       from #TACCTRN3 b
                      where b.ctr_nf    = #PROV_PNA_FAR.ctr_nf
                        and b.uwy_nf    = #PROV_PNA_FAR.uwy_nf
                        and b.uw_nt     = #PROV_PNA_FAR.uw_nt
                        and b.end_nt    = #PROV_PNA_FAR.end_nt
                        and b.sec_nf    = #PROV_PNA_FAR.sec_nf
                        and b.trncod_cf = #PROV_PNA_FAR.trncod_cf
                        and b.cur_cf    = #PROV_PNA_FAR.cur_cf
                        and b.acy_nf    = #PROV_PNA_FAR.acy_nf
                        and b.occyea_nf = #PROV_PNA_FAR.occyea_nf
                    )
    ,SCOSTRMTH_NF = ( select isnull(max(c.SCOENDMTH_NF), 1)
                       from #TACCTRN3 c
                      where c.ctr_nf    = #PROV_PNA_FAR.ctr_nf
                        and c.uwy_nf    = #PROV_PNA_FAR.uwy_nf
                        and c.uw_nt     = #PROV_PNA_FAR.uw_nt
                        and c.end_nt    = #PROV_PNA_FAR.end_nt
                        and c.sec_nf    = #PROV_PNA_FAR.sec_nf
                        and c.trncod_cf = #PROV_PNA_FAR.trncod_cf
                        and c.cur_cf    = #PROV_PNA_FAR.cur_cf
                        and c.acy_nf    = #PROV_PNA_FAR.acy_nf
                        and c.occyea_nf = #PROV_PNA_FAR.occyea_nf
                    )

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. update #PROV_PNA_FAR max(SCOENDMTH_NF)'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '

----------------------------------------------------------------------------
-- rechargement de la table #tacctrn à partir de #PROV_PNA_FAR
----------------------------------------------------------------------------
print ' '
print 'insert into #TACCTRN'
insert into #TACCTRN  (
		       SSD_CF,
		       ESB_CF,
      	   CTR_NF,
		       UWY_NF,
		       UW_NT,
		       END_NT,
		       SEC_NF,
		       CUR_CF,
		       SCOSTRMTH_NF,
		       SCOENDMTH_NF,
		       OCCYEA_NF,
		       ACY_NF,
		       TRNCOD_CF,
		       CTRNCOD_CF,
		       der_sap,			--ORICURAMT_M,
		       LOB_CF,
		       SOB_CF,
		       TOP_CF,
		       NAT_CF,
		       SUBNAT_CF,
		       GAR_CF,
		       CED_NF)
select distinct
       	   SSD_CF,
		       ESB_CF,
		       CTR_NF,
		       UWY_NF,
		       UW_NT,
		       END_NT,
		       SEC_NF,
		       CUR_CF,
		       SCOSTRMTH_NF,
		       SCOENDMTH_NF,
		       OCCYEA_NF,
		       ACY_NF,
		       TRNCOD_CF,
		       CTRNCOD_CF,
		       ORICURAMT_M,
		       LOB_CF,
		       SOB_CF,
		       TOP_CF,
		       NAT_CF,
		       SUBNAT_CF,
		       GAR_CF,
		       CED_NF
from    #PROV_PNA_FAR

select @msg1 = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8),
       @msg2 = convert(char(7), @@rowcount), @erreur=@@error,
       @lignes=@@rowcount

if @erreur != 0
   begin
    print 'Pb. Insert into #TACCTRN'
    goto erreur
   end

Select @msg3=' --> Lignes resultantes: ' + convert(char(10),@lignes)
print '%1! %2!' , @msg1, @msg3
print ' '

BEGIN TRAN
PRINT ' '
PRINT 'Begin Tran'

select '-- Compteur avant insert tacctrn (*-1): ' Libelle, max (trn_nt) MAX_TRN
from bcta..TACCTRN

-- -------------------------------------------
PRINT ''
PRINT '-- Re-création des positions (*-1) '
-- -------------------------------------------

insert bcta..TACCTRN (
			ssd_cf,
			esb_cf,
			ctr_nf,
			uwy_nf,
			uw_nt,
			end_nt,
			sec_nf,
			acctyp_cf,
			scostrmth_nf,
			scoendmth_nf,
			acy_nf,
			blcsht_d,
			trnsts_ct,
			trncod_cf,
			ctrncod_cf,
			oricuramt_m,
			cur_cf,
			vld_d,
			occyea_nf,
			lstupdusr_cf,
			lob_cf,
			sob_cf,
			top_cf,
			nat_cf,
			subnat_cf,
			gar_cf,
			ced_nf)
select
			ssd_cf,
			esb_cf,
			ctr_nf,
			uwy_nf,
			uw_nt,
			end_nt,
			sec_nf,
			3,              --acctyp_cf,
			scostrmth_nf,
			scoendmth_nf,
			acy_nf,
			@p_blcsht_d,
			1,               --trnsts_ct,
			trncod_cf,
			ctrncod_cf,
			der_sap * -1,    --oricuramt_m,
			cur_cf,
			getdate(),       --vld_d,
			occyea_nf,  --uwy_nf,          -- pour US on garde occyea
			'DBC',          --lstupdusr_cf,
			lob_cf,
			sob_cf,
			top_cf,
			nat_cf,
			subnat_cf,
			gar_cf,
			ced_nf
from  #TACCTRN
where der_sap != 0

select @erreur = @@error

if @erreur != 0
	begin
		select @errno  = 20100
		select @errmsg = 'Erreur insertion contrepassation '
		goto ERREUR
	end

select '-- Compteur avant insert tacctrn (position a zero): ' Libelle, max (trn_nt) MAX_TRN
from bcta..TACCTRN

-- -------------------------------------------
PRINT ''
PRINT '-- Création des positions à zéro'
-- -------------------------------------------
insert bcta..TACCTRN (
			ssd_cf,
			esb_cf,
			ctr_nf,
			uwy_nf,
			uw_nt,
			end_nt,
			sec_nf,
			acctyp_cf,
			scostrmth_nf,
			scoendmth_nf,
			acy_nf,
			blcsht_d,
			trnsts_ct,
			trncod_cf,
			ctrncod_cf,
			oricuramt_m,
			cur_cf,
			vld_d,
			occyea_nf,
			lstupdusr_cf,
			lob_cf,
			sob_cf,
			top_cf,
			nat_cf,
			subnat_cf,
			gar_cf,
			ced_nf)
select
			ssd_cf,
			esb_cf,
			ctr_nf,
			uwy_nf,
			uw_nt,
			end_nt,
			sec_nf,
			3,               --acctyp_cf,
			scostrmth_nf,
			scoendmth_nf,
			acy_nf,
			@p_blcsht_d,	   --blcsht_d,
			1,               --trnsts_ct,
			trncod_cf,
			ctrncod_cf,
			0,              --oricuramt_m
			cur_cf,
			getdate(),      --vld_d,
			occyea_nf,      --uwy_nf,          -- pour US on garde occyea
			'DBC',          --lstupdusr_cf,
			lob_cf,
			sob_cf,
			top_cf,
			nat_cf,
			subnat_cf,
			gar_cf,
			ced_nf
from  #TACCTRN
where der_sap != 0
--and trncod_cf not in('11410000','11430000') -- à utiliser si pas besoin posit 0 pour PNA & FAR

select @erreur = @@error

if @erreur != 0
	begin
		select @errno  = 20101
		select @errmsg = 'Erreur insertion position a zéro '
		goto ERREUR
	end

select '-- Compteur apres insert tacctrn (position à zéro): ' Libelle, max (trn_nt) MAX_TRN
from bcta..TACCTRN

PRINT 'Commit'
COMMIT TRANSACTION

goto fin

ERREUR:
     begin
     	raiserror @errno @errmsg
     	rollback transaction
     end
FIN:
PRINT '*** FIN éxecution de la procédure PtCPTCOMMUT_01.prc ***'
PRINT '*** ================================================ ***'
go

GRANT EXECUTE ON dbo.PtCPTCOMMUT_01 TO GOMEGA
go
IF OBJECT_ID('dbo.PtCPTCOMMUT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtCPTCOMMUT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtCPTCOMMUT_01 >>>'
go
EXEC sp_procxmode 'dbo.PtCPTCOMMUT_01','unchained'
