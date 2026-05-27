use BEST
go
if object_id('dbo.PuUNDSTA_01') is not null
begin
  drop PROC dbo.PuUNDSTA_01
  print '<<< DROPPED PROC dbo.PuUNDSTA_01 >>>'
end
go
create procedure PuUNDSTA_01 (
    @p_typetraitement  char(1)
)
with execute as caller
as
/***************************************************
Programme:                  PuUNDSTA_01
Fichier script associé :    ESUUND01.PRC
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     ME69 avec Infotool version 2.0 (AUTO)

Description du programme:
	- Mise a jour des tables    TUNDSTA (montants stats par exercice),
	                            TCTREST (Primes et sinistres ultimes),
	                            TCTRACC (contrats avec mouvements comptables),
	                            TSBJPRM (révisions des assiettes comptables) de la base BEST
	- Mise a jour de la table   TSECTION de la base TRAITE
	- Mise a jour de la table   TSECTION de la base FACULTATIVES
	- Mise a jour des tables    TREFCMT (commentaires références),
	                            TREMINDER (relances) et
	                            TREMINDUSR (lien relance/utilisateur)
	- cette procédure stockée est utilisée sans que les triggers de BTRT..TSECTION et BTRT..TFAMLIA soient actifs.
	  Les tables BTRT..TFAMLIA_V et BTRT..TSECTION_V sont mises à jour afin de remplacer l'action des triggers

Parametres:
       - @p_typetraitement: le type de traitement est quotidien "Q" ou reprise "R"

_________________
MODIFICATION 1
Auteur:	HA-THUC
Date:		17/10/97
Version:	2
Description:	Modification de la structure de TUNDSTA et TESTCPLAMT
_________________
MODIFICATION 2
Auteur:	HA-THUC
Date:		26/05/98
Version:	3
Description:	Insertion dans BREF..TREMINUSR à l'aide d'un curseur
_________________
MODIFICATION 3
Auteur:	Bruno Montagnac
Date:		12/01/99
Version:	4
Description:	Ajout du critere "date d'insertion" dans le champs CMT_T de BREF..TREFCMT
_________________
MODIFICATION 4
Auteur:	M. DJELLOULI        - MOD004
Date:		21/04/2004
Version:	4
Description:	SPOT 10093 - Passage en Automatique sur toutes sections pour les traités Alloués
- recherche des traités alloués (BTRAV.TESTCTRULT) et BTRT..TCONTR
- Recherche des derniers enregistrements liés dans BEST..TCTRULT
- Calcul
- Enregistrement dans BEST..TCTRULT
- Enregistrement dans BTRAV..TESTUW
- Enregistrement dans BEST..TCTRACC

Cette modification utilise les tables temporaires suivantes :
    #MOD004TESTCTRULT       Sélection (BTRAV.TESTCTRULT) et BTRT..TCONTR (ALLTRT_B =1)
    #MOD004TEMP             Sélection derniers enregistrements créés BEST..TCTRULT liés
    #MOD004select           Sélection des enregistrements Section Mode Automatique Primes ou Sinitres

_________________
MODIFICATION 5
Auteur:	M. DJELLOULI
Date:		10/08/2005
Version:
Description:	Correction Insertion BEST..TCTRACC apres Plantage NY
_________________
MODIFICATION 6
Auteur:	M. DJELLOULI
Date:		22/08/2005
Version:
Description:	Gestion Renvoie des Erreur par @errno et @errmsg

                20010   'Erreur update BEST..TUNDSTA par BTRAV..TESTCPLAMT '
                20020   'Erreur update BEST..TCTRULT par BTRAV..TESTCTRULT (ULTUPDTYP_CF=U)'
                20030   'Erreur insert BEST..TCTRULT par BTRAV..TESTCTRULT (ULTUPDTYP_CF=I)'
                20040   'Erreur insert #MOD004TESTCTRULT par BTRAV..TESTCTRULT'
                20050   'Erreur insert #MOD004TEMP par #MOD004TESTCTRULT'
                20060   'Erreur insert #MOD004select par #MOD004TEMP'
                20070   'Erreur insert #MOD004IDENT par #MOD004select'
                20080   'Erreur insert BEST..TCTRULT par #MOD004select, #MOD004IDENT'
                20090   'Erreur update BTRAV..TESTUW par #MOD004TESTCTRULT'
                20100   'Erreur update BTRT..TSECTION par BTRAV..TESTUW'
                20110   'Erreur update BTRT..TSECTION par BTRAV..TESTUW'
                20120   'Erreur update BTRT..TFAMLIA par BTRAV..TESTUW'
                20130   'Erreur update BTRT..TFAMLIA_V par BTRAV..TESTUW'
                20140   'Erreur update BFAC..TSECTION par BTRAV..TESTUW'
                20150   'Erreur insert #TREFCMT par BTRAV..TESTRMD'
                20151   'Erreur insert BREF..TREFCMT par #TREFCMT'
                20160   'Erreur insert BREF..TREFCMT par #TREFCMT'
                20170   'Erreur insert #TREMINDER par BTRAV..TESTRMD'
                20180   'Erreur insert BREF..TREMINDER par #TREMINDER'
                20190   'Erreur insert #TREMINUSR par BTRAV..TESTRMD'
                20191   'Erreur insert BREF..TREMINUSR Loop #TREMINUSR'
                20192   'Erreur insert BEST..TREQJOB Fixe Data 99-1997-U'
                20193   'Erreur update BEST..TREQJOB Fixe U'
                20200   'Erreur delete BEST..TCTRACC par BTRAV..TBESTGTAKEY'
                20210   'Erreur delete BEST..TCTRACC par #MOD004TESTCTRULT'
                20220   'Erreur insert BEST..TCTRACC par #MOD004TESTCTRULT'
_________________
MODIFICATION 7
Auteur:	M. DJELLOULI
Date:		25/08/2005
Version:
Description:	Correction Insertion / update TCTRULT pour les Alloués Auto
_________________
MODIFICATION 8
Auteur:	M. DJELLOULI
Date:		31/08/2005
Version:
Description:	Correction Suite à MAJ de ligne TCTRULT au lieu d'une Insertion
                    Donc, on ne voit pas tt les sections Modifiées aux Bonnes Dates
_________________
MODIFICATION 9
Auteur:	G. BUISSON
Date:		28/11/2008
Version:
Description:	Spot 16534 : Ajout d'un order by sur le declare cursor
_________________
MODIFICATION    [010]
Auteur:         D.GATIBELZA
Date:		    30/09/2009
Version:        9.1
Description:	ESTDOM18114 plantage NY ESEJ1000 ; retrouver l'origine des plantages sur le contrat en question
_________________
MODIFICATION    [011]
Auteur:         D.GATIBELZA
Date:		    01/10/2009
Version:        9.1
Description:	ESTDOM18114 plantage NY ESEJ1000 ; retrouver l'origine des plantages sur le contrat en question ( corrections )
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 10/11/2009  |[15043] maj de la table TCTRULT à faire uniquement sur la dernière ligne - prendre max(CRE_D)
                |             |
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
_________________
MODIFICATION    [012]
Auteur:         D.GATIBELZA
Date:           07/12/2009
Version:        9.1
Description:    ESTDOM15043 Ultimes  Revisions des regles de gestion et corrections de l'écran estimation des ultimes
                - Mise aux normes de la table BTRAV TESTCTRULT devient : BTRAV..EST_ULT_ESEJ1000_TCTRULT
_________________
MODIFICATION    [013]
Auteur:         JF VDV
Date:           14/01/2010
Version:        9.1
Description:    [15043] Ajout d'un set FORCE PLAN pour les table TFAMLIA, TSECTION
[014] 08/08/2013 Florent :spot:25427 Centralisation des bases (filiales)
[015] 19/05/2014 Roger   :spot:26775 utilisation de la variable @suser_Name
*****************************************************/
declare @erreur     int,
        @tran_imbr  bit,
        @nbligne    smallint,
        @nbtime     smallint,
        @numero_max_trefcmt   int,
        @numero_avd_treminder   int,
        @numero_max_treminder int,
        @numero_max_treminusr int,
        @d_str      varchar(20)
declare @errno    int
declare @errmsg   varchar(255)
declare @MaxCre_D   Datetime            -- MOD08

select @erreur = 0
select @tran_imbr = 1


/* creation d'une table temporaire #TREFCMT, #TREMINDER et #TREMINUSR */
create table #TREFCMT(
    CMT_NT      numeric(10,0)   identity ,
    CMTLIN_NT   int             null,
    CMT_T       UCMT_T          null
)

create table #TREMINDER(
    RMD_NF          numeric(10,0)   identity ,
    RMDISS_D        UUPD_D          DEFAULT getdate(),
    RMDOBJ_LL       UL64            null,
    RMDDOM_CT       char(3)         null,
    RMDENTIDT_CT    varchar(20)     null,
    RMDENTLAB_LL    UL64            null
)

create table #TREMINUSR(
    RMD_NF          numeric(10,0)   identity ,
    RMDADDUSR_CF    UUSR_CF         DEFAULT ''
)


---------------------------------------------------------
--  DEBUT MOD004
--  Création Table Temporaire "Existance Traités Alloués"
create TABLE #MOD004TESTCTRULT (
    CTR_NF          UCTR_NF     NOT null,
    UWY_NF          UUWY_NF     NOT null,
    UW_NT           UUW_NT      NOT null,
    END_NT          UEND_NT     NOT null,
    SEC_NF          USEC_NF     NOT null,
    CRE_D           datetime    NOT null,
    SSD_CF          USSD_CF         null,
    DIV_NT          UDIV_NT         null,
    CUR_CF          UCUR_CF         null,
    CALAMTPRM_M     UAMT_M          null,
    ENTAMTPRM_M     UAMT_M          null,
    RETAMTPRM_M     UAMT_M          null,
    ADMMODPRM_CT    char(1)         null,
    RESPRM_M        UAMT_M          null,
    CALAMTCLM_M     UAMT_M          null,
    ENTAMTCLM_M     UAMT_M          null,
    RETAMTCLM_M     UAMT_M          null,
    ADMMODCLM_CT    char(1)         null,
    ORICOD_LS       UL16            null,
    UPDUSR_CF       char(10)        null,
    ULTUPDTYP_CF    char(1)         null
)

create TABLE #MOD004TEMP (
    CTR_NF          UCTR_NF     NOT null,
    END_NT          UEND_NT     NOT null,
    SEC_NF          USEC_NF     NOT null,
    UWY_NF          UUWY_NF     NOT null,
    UW_NT           UUW_NT      NOT null,
    SSD_CF          USSD_CF         null,
    DIV_NT          UDIV_NT         null,
    CRE_D           datetime    NOT null
)

create TABLE #MOD004IDENT (
    CTR_NF          UCTR_NF     NOT null,
    END_NT          UEND_NT     NOT null,
    SEC_NF          USEC_NF     NOT null,
    UWY_NF          UUWY_NF     NOT null,
    UW_NT           UUW_NT      NOT null,
    SSD_CF          USSD_CF         null,
    DIV_NT          UDIV_NT         null,
    CRE_D           datetime    NOT null
)

-- MOD0008
create TABLE #MOD004SECTION (
    CTR_NF          UCTR_NF     NOT null,
    END_NT          UEND_NT     NOT null,
    SEC_NF          USEC_NF     NOT null,
    UWY_NF          UUWY_NF     NOT null,
    UW_NT           UUW_NT      NOT null,
    SSD_CF          USSD_CF         null,
    DIV_NT          UDIV_NT         null,
    CRE_D           datetime    NOT null
)

create TABLE #MOD004select (
    CTR_NF          UCTR_NF     NOT null,
    UWY_NF          UUWY_NF     NOT null,
    UW_NT           UUW_NT      NOT null,
    END_NT          UEND_NT     NOT null,
    SEC_NF          USEC_NF     NOT null,
    CRE_D           datetime    NOT null,
    SSD_CF          USSD_CF         null,
    DIV_NT          UDIV_NT         null,
    CUR_CF          UCUR_CF         null,
    CALAMTPRM_M     UAMT_M          null,
    ENTAMTPRM_M     UAMT_M          null,
    RETAMTPRM_M     UAMT_M          null,
    ADMMODPRM_CT    char(1)         null,
    RESPRM_M        UAMT_M          null,
    CALAMTCLM_M     UAMT_M          null,
    ENTAMTCLM_M     UAMT_M          null,
    RETAMTCLM_M     UAMT_M          null,
    ADMMODCLM_CT    char(1)         null,
    ORICOD_LS       UL16            null,
    UPDUSR_CF       char(10)        null,
    ULTUPDTYP_CF    char(1)         null
)

--  FIN MOD004
---------------------------------------------------------

-- Debut MOD007
create TABLE #UPDTCTRULT (
    CTR_NF          UCTR_NF     NOT null,
    END_NT          UEND_NT     NOT null,
    SEC_NF          USEC_NF     NOT null,
    UWY_NF          UUWY_NF     NOT null,
    UW_NT           UUW_NT      NOT null,
    CRE_D           UUPD_D          DEFAULT getdate() NOT null,
    SSD_CF          USSD_CF     NOT null,
    DIV_NT          UDIV_NT     NOT null,
    CUR_CF          UCUR_CF         DEFAULT '' NOT null,
    CALAMTPRM_M     UAMT_M          null,
    ENTAMTPRM_M     UAMT_M          null,
    RETAMTPRM_M     UAMT_M          null,
    ADMMODPRM_CT    char(1)         DEFAULT '' NOT null,
    RESPRM_M        UAMT_M          null,
    CALAMTCLM_M     UAMT_M          null,
    ENTAMTCLM_M     UAMT_M          null,
    RETAMTCLM_M     UAMT_M          null,
    ADMMODCLM_CT    char(1)         DEFAULT '' NOT null,
    ORICOD_LS       UL16            null,
    UPDUSR_CF       char(10)        null,
    CREUSR_CF       UUPDUSR_CF      DEFAULT user NOT null,
    LSTUPD_D        UUPD_D          DEFAULT getdate() NOT null,
    LSTUPDUSR_CF    UUPDUSR_CF      DEFAULT user NOT null
)
-- FIN MOD007


/* -----------------------------------------------------------
    Début de la transaction
** ----------------------------------------------------------- */
if @@trancount = 0
begin
    select @tran_imbr = 0
    begin tran
end

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

    /* ----------------------------------------------------------------
       Mise a jour de la table des montants stats par exercice (TUNDSTA)
       ---------------------------------------------------------------- */
    update BEST..TUNDSTA
       set A.CACCPRM_M = B.PRMCPLACC_M,
           A.CACCUPR_M = B.UPRCPLACC_M,
           A.CACCCLM_M = B.CLMCPLACC_M,
           A.CACCACR_M = B.ACRCPLACC_M,
           A.CACCLOA_M = B.CHACPLACC_M,
           A.CACCRESPRM_M = B.RESCPLACC_M,
           A.ACCPRM_M = B.ACCPRM_M,
           A.ACCUPR_M = B.ACCUPR_M,
           A.ACCCLM_M = B.ACCCLM_M,
           A.ACCACR_M = B.ACCACR_M,
           A.ACCLOA_M = B.ACCCHA_M,
           A.LSTUPD_D = getdate(),
           A.ACY_NF = B.ACY_NF,
           A.SCOENDMTH_NF = B.SCOENDMTH_NF
    from BEST..TUNDSTA A, BTRAV..TESTCPLAMT B
    where A.CTR_NF = B.CTR_NF
      and A.UWY_NF = B.UWY_NF
      and A.UW_NT  = B.UW_NT
      and A.END_NT = B.END_NT
      and A.SEC_NF = B.SEC_NF

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20010
        select @errmsg = 'Erreur update BEST..TUNDSTA par BTRAV..TESTCPLAMT '
        goto ERREUR
    end


    /* -----------------------------------------------------------------
       Mise a jour de la table des Primes et sinistres ultimes (TCTRULT)
       ----------------------------------------------------------------- */

    /* mise a jour d'une ligne si le type de mise a jour des ultimes est "U" */
    update BEST..TCTRULT
       set A.CALAMTPRM_M = B.CALAMTPRM_M,
           A.CALAMTCLM_M = B.CALAMTCLM_M,
           A.LSTUPD_D = getdate( )
    from BEST..TCTRULT A, BTRAV..EST_ULT_ESEJ1000_TCTRULT B     --[012] BTRAV..TESTCTRULT B
    where B.ULTUPDTYP_CF = 'U'
      and A.CTR_NF = B.CTR_NF
      and A.UWY_NF = B.UWY_NF
      and A.UW_NT  = B.UW_NT
      and A.END_NT = B.END_NT
      and A.SEC_NF = B.SEC_NF
      and A.CRE_D = ( select max(CRE_D)from BEST..TCTRULT c        --[15043]
                      where A.CTR_NF = C.CTR_NF
                        and A.UWY_NF = C.UWY_NF
                        and A.UW_NT  = C.UW_NT
                        and A.END_NT = C.END_NT
                        and A.SEC_NF = C.SEC_NF
                      group by c.CTR_NF,c.UWY_NF,c.UW_NT,c.END_NT,c.SEC_NF )

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20020
        select @errmsg = 'Erreur update BEST..TCTRULT par BTRAV..EST_ULT_ESEJ1000_TCTRULT (ULTUPDTYP_CF=U)'
        goto ERREUR
    end


    /* insertion d'une ligne si le type de mise a jour des ultimes est "I" */
    insert into BEST..TCTRULT ( CTR_NF,  END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, SSD_CF, DIV_NT, CUR_CF, CALAMTPRM_M,
                                ENTAMTPRM_M, RETAMTPRM_M, ADMMODPRM_CT, RESPRM_M, CALAMTCLM_M, ENTAMTCLM_M, RETAMTCLM_M,
                                ADMMODCLM_CT, ORICOD_LS, UPDUSR_CF, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF )
    select B.CTR_NF, B.END_NT, B.SEC_NF, B.UWY_NF, B.UW_NT, B.CRE_D, B.SSD_CF, B.DIV_NT,
           B.CUR_CF, B.CALAMTPRM_M, B.ENTAMTPRM_M, B.RETAMTPRM_M, B.ADMMODPRM_CT, B.RESPRM_M,
           B.CALAMTCLM_M, B.ENTAMTCLM_M, B.RETAMTCLM_M, B.ADMMODCLM_CT, B.ORICOD_LS, B.UPDUSR_CF,
           "", B.CRE_D, ""
    from BTRAV..EST_ULT_ESEJ1000_TCTRULT B      --[012] BTRAV..TESTCTRULT B
    where B.ULTUPDTYP_CF = "I"

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20030
        select @errmsg = 'Erreur insert BEST..TCTRULT par BTRAV..EST_ULT_ESEJ1000_TCTRULT (ULTUPDTYP_CF=I)'
        goto ERREUR
    end


    /* -------------------------------------------------------------------- */
    /* ----------------------    DEBUT MOD004   --------------------------- */

    -- 1. Contrôle s'il existe dans BTRAV..EST_ULT_ESEJ1000_TCTRULT, des traités Alloués
    -- Stockage des enregistrements dans Table Temporaire #MOD004TESTCTRULT
    -- Récupération de Toutes les Sections de tous les Traités pour lesquels on a au moins 1 Modif sur 1 section
    insert into #MOD004TESTCTRULT ( CTR_NF,  END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, SSD_CF, DIV_NT, CUR_CF, CALAMTPRM_M,
                                    ENTAMTPRM_M, RETAMTPRM_M, ADMMODPRM_CT, RESPRM_M, CALAMTCLM_M, ENTAMTCLM_M, RETAMTCLM_M,
                                    ADMMODCLM_CT, ORICOD_LS, UPDUSR_CF, ULTUPDTYP_CF )
    select DISTINCT B.CTR_NF, B.END_NT, B.SEC_NF, B.UWY_NF, B.UW_NT, B.CRE_D, B.SSD_CF, B.DIV_NT, B.CUR_CF, B.CALAMTPRM_M,
                    B.ENTAMTPRM_M, B.RETAMTPRM_M, B.ADMMODPRM_CT, B.RESPRM_M, B.CALAMTCLM_M, B.ENTAMTCLM_M, B.RETAMTCLM_M,
                    B.ADMMODCLM_CT, B.ORICOD_LS, B.UPDUSR_CF,  ""
    from BTRAV..EST_ULT_ESEJ1000_TCTRULT B, BTRT..TCONTR A          --[012] BTRAV..TESTCTRULT B
    where A.ALLTRT_B = 1        -- Traités Alloués
      and A.CTR_NF = B.CTR_NF
      and A.UWY_NF = B.UWY_NF
      and A.UW_NT  = B.UW_NT
      and A.END_NT = B.END_NT

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20040
        select @errmsg = 'Erreur insert #MOD004TESTCTRULT par BTRAV..EST_ULT_ESEJ1000_TCTRULT'
        goto ERREUR
    end

    -- Nouveau Branchement : on continue l'update de TSECTION si Pas de Traités Alloués
    select 1
    from #MOD004TESTCTRULT

    if @@rowcount = 0
        goto NextUpdtSect


    -- 2. Recherche pour les enregistrements de #MOD004TESTCTRULT,
    -- le dernier enregistrement de chaque section différente présente dans BEST..TCTRULT
    -- Stockage de ces enregistrements dans la table temporaire #MOD004TEMP
    insert into #MOD004TEMP (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, SSD_CF, DIV_NT, CRE_D)
    select DISTINCT B.CTR_NF, B.END_NT, B.SEC_NF, B.UWY_NF, B.UW_NT, B.SSD_CF, B.DIV_NT, max(B.CRE_D)
    from BEST..TCTRULT B
    where exists ( select 1 from #MOD004TESTCTRULT A
                   where A.CTR_NF = B.CTR_NF
                  -- and A.SEC_NF = B.SEC_NF                -- Sans la Section !
                     and A.UWY_NF = B.UWY_NF
                     and A.UW_NT = B.UW_NT
                     and A.END_NT = B.END_NT )
    group by B.CTR_NF, B.END_NT, B.SEC_NF, B.UWY_NF, B.UW_NT, B.SSD_CF, B.DIV_NT

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20050
        select @errmsg = 'Erreur insert #MOD004TEMP par #MOD004TESTCTRULT'
        goto ERREUR
    end


    -- 3. Contrôle s'il existe dans BTRAV..EST_ULT_ESEJ1000_TCTRULT, des traités Alloués
    -- Stockage des enregistrements dans Table Temporaire #MOD004TESTCTRULT
    insert  into #MOD004select ( CTR_NF,  END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, SSD_CF, DIV_NT, CUR_CF, CALAMTPRM_M,
                                 ENTAMTPRM_M, RETAMTPRM_M, ADMMODPRM_CT, RESPRM_M, CALAMTCLM_M, ENTAMTCLM_M, RETAMTCLM_M,
                                 ADMMODCLM_CT, ORICOD_LS, UPDUSR_CF, ULTUPDTYP_CF )
    select B.CTR_NF, B.END_NT, B.SEC_NF, B.UWY_NF, B.UW_NT, B.CRE_D, B.SSD_CF, B.DIV_NT, B.CUR_CF, B.CALAMTPRM_M,
           B.ENTAMTPRM_M, B.RETAMTPRM_M, B.ADMMODPRM_CT, B.RESPRM_M, B.CALAMTCLM_M, B.ENTAMTCLM_M, B.RETAMTCLM_M,
           B.ADMMODCLM_CT, B.ORICOD_LS, B.UPDUSR_CF,  ""
    from BEST..TCTRULT B, #MOD004TEMP A
    where A.CTR_NF  = B.CTR_NF
      and A.END_NT  = B.END_NT
      and A.SEC_NF  = B.SEC_NF
      and A.UWY_NF  = B.UWY_NF
      and A.UW_NT   = B.UW_NT
      and A.SSD_CF  = B.SSD_CF
      and A.DIV_NT  = B.DIV_NT
      and A.CRE_D   = B.CRE_D                   -- Y Compris les derniers enregistrements insérés précédemment de BTRAV..EST_ULT_ESEJ1000_TCTRULT

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20060
        select @errmsg = 'Erreur insert #MOD004select par #MOD004TEMP'
        goto ERREUR
    end


    -- 4. on sélectionne les enregistrements avec :
    --     Au Moins 1 Section en mode automatique sur la prime ou les Sinistres
    -- ET  Au moins 1 Section en Mode Manuel
    insert into #MOD004IDENT (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, SSD_CF, DIV_NT, CRE_D)
    select A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.SSD_CF, A.DIV_NT, A.CRE_D
    from #MOD004TEMP A
    where exists ( select 1
                   from #MOD004select B
                   where A.CTR_NF  = B.CTR_NF
                     and A.END_NT  = B.END_NT
                     and A.SEC_NF  = B.SEC_NF                          -- La sélection s'effectue sur la Section !
                     and A.UWY_NF  = B.UWY_NF
                     and A.UW_NT   = B.UW_NT
                     and A.SSD_CF  = B.SSD_CF
                     and A.DIV_NT  = B.DIV_NT
                     and A.CRE_D   = B.CRE_D
                     and ( (B.ADMMODPRM_CT ='A') or (B.ADMMODCLM_CT ='A') )  )
      and exists ( select 1
                   from #MOD004select B
                   where A.CTR_NF  = B.CTR_NF
                     and A.END_NT  = B.END_NT
                     and A.SEC_NF  = B.SEC_NF                          -- La sélection s'effectue sur la Section !
                     and A.UWY_NF  = B.UWY_NF
                     and A.UW_NT   = B.UW_NT
                     and A.SSD_CF  = B.SSD_CF
                     and A.DIV_NT  = B.DIV_NT
                     and A.CRE_D   = B.CRE_D
                     and ( (B.ADMMODPRM_CT ='M') or (B.ADMMODCLM_CT ='M') )  )

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20070
        select @errmsg = 'Erreur insert #MOD004IDENT par #MOD004select'
        goto ERREUR
    end


    -- MOD0008
    -- 41. MOD004IDENT contient uniquement les sections répondant aux critères sélectionnés
    -- on sélectionne donc toutes les sections des Contrats répondants à ces critères
    insert into #MOD004SECTION (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, SSD_CF, DIV_NT, CRE_D)
    select DISTINCT A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.SSD_CF, A.DIV_NT, A.CRE_D
    from #MOD004TEMP A
    where exists ( select 1 from #MOD004IDENT B
                   where A.CTR_NF  = B.CTR_NF
                     and A.END_NT  = B.END_NT
                     and A.UWY_NF  = B.UWY_NF
                     and A.UW_NT   = B.UW_NT
                     and A.SSD_CF  = B.SSD_CF
                     and A.DIV_NT  = B.DIV_NT )

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20070
        select @errmsg = 'Erreur insert #MOD004SECTION par #MOD004IDENT'
        goto ERREUR
    end


    -- MAJ de TCTRULT les Traités qui sont dans le Calul des Alloués Automatiques
    -- Pour les recharger ensuite
    insert into #UPDTCTRULT ( CTR_NF,
                              END_NT,
                              SEC_NF,
                              UWY_NF,
                              UW_NT,
                              CRE_D,
                              SSD_CF,
                              DIV_NT,
                              CUR_CF,
                              CALAMTPRM_M,
                              ENTAMTPRM_M,
                              RETAMTPRM_M,
                              ADMMODPRM_CT,
                              RESPRM_M,
                              CALAMTCLM_M,
                              ENTAMTCLM_M,
                              RETAMTCLM_M,
                              ADMMODCLM_CT,
                              ORICOD_LS,
                              UPDUSR_CF,
                              CREUSR_CF,
                              LSTUPD_D,
                              LSTUPDUSR_CF )
    select A.CTR_NF,
           A.END_NT,
           A.SEC_NF,
           A.UWY_NF,
           A.UW_NT,
           A.CRE_D,                    -- La CRE_D récupérée est celle attachée au Contrat dans la BTRAV..EST_ULT_ESEJ1000_TCTRULT
           A.SSD_CF,
           A.DIV_NT,
           B.CUR_CF,
           B.CALAMTPRM_M,
           B.ENTAMTPRM_M,
           B.CALAMTPRM_M,
           'A',           --
           B.RESPRM_M,
           B.CALAMTCLM_M,
           B.ENTAMTCLM_M,
           case when (B.RETAMTPRM_M = 0)  then 0
                when (B.RETAMTPRM_M != 0) then round((B.CALAMTPRM_M * (B.RETAMTCLM_M / B.RETAMTPRM_M)),3) -- égal à ( B.CALAMTPRM_M * [ULR]) ([ULR] = B.RETAMTCLM_M / B.RETAMTPRM_M)
           end,     -- MOD004
           B.ADMMODCLM_CT,
           "Account",
           "ESEJ1000",
           "",
           getdate(),
           ""
    from #MOD004select B, #MOD004SECTION A
    where A.CTR_NF  = B.CTR_NF
      and A.END_NT  = B.END_NT
      and A.SEC_NF  = B.SEC_NF
      and A.UWY_NF  = B.UWY_NF
      and A.UW_NT   = B.UW_NT
      and A.SSD_CF  = B.SSD_CF
      and A.DIV_NT  = B.DIV_NT
      -- and B.ADMMODPRM_CT ='M'                    -- Toutes Sections Confondues les Anciennes Alloués et les Manuelles sont Recalculés
      and NOT EXISTS ( select 1
                       from BTRAV..EST_ULT_ESEJ1000_TCTRULT C       --[012] BTRAV..TESTCTRULT C      -- on ne récupère pas dans les Enregistrements à Insérés
                       where C.ULTUPDTYP_CF = "I"    --[011] REACTIVATION /*[010] C.ULTUPDTYP_CF = "I" and    -- Ceux qui ont déjà été insérés en Début de Proc */
                         and A.CTR_NF  = C.CTR_NF
                         and A.END_NT  = C.END_NT
                         and A.SEC_NF  = C.SEC_NF
                         and A.UWY_NF  = C.UWY_NF
                         and A.UW_NT   = C.UW_NT
                         and A.SSD_CF  = C.SSD_CF
                         and A.DIV_NT  = C.DIV_NT )

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20072
      select @errmsg = 'Erreur insert #UPDTCTRULT par #MOD004select B, #MOD004IDENT A'
      goto ERREUR
    end


    -- Maj de la Date de Création pour Toutes les Sections Récupérées dans #UPDTCTRULT
    -- on Met à jour La CRE_D pour l'enregistrement Final par le Contrat / Récupéré dans la BTRAV..EST_ULT_ESEJ1000_TCTRULT
    update #UPDTCTRULT
       set CRE_D = B.CRE_D
    from #UPDTCTRULT A, BTRAV..EST_ULT_ESEJ1000_TCTRULT B   --[012] BTRAV..TESTCTRULT B
    where A.CTR_NF  = B.CTR_NF
      and A.END_NT  = B.END_NT
      and A.UWY_NF  = B.UWY_NF
      and A.UW_NT   = B.UW_NT


    --[011] debut:
    -- d'abord un update
    update BEST..TCTRULT
       set CUR_CF           =b.CUR_CF,
           CALAMTPRM_M      =b.CALAMTPRM_M,
           ENTAMTPRM_M      =b.ENTAMTPRM_M,
           RETAMTPRM_M      =b.RETAMTPRM_M,
           ADMMODPRM_CT     =b.ADMMODPRM_CT,
           RESPRM_M         =b.RESPRM_M,
           CALAMTCLM_M      =b.CALAMTCLM_M,
           ENTAMTCLM_M      =b.ENTAMTCLM_M,
           RETAMTCLM_M      =b.RETAMTCLM_M,
           ADMMODCLM_CT     =b.ADMMODCLM_CT,
           ORICOD_LS        =b.ORICOD_LS,
           UPDUSR_CF        =b.UPDUSR_CF,
           CREUSR_CF        =b.CREUSR_CF,
           LSTUPD_D         =b.LSTUPD_D,
           LSTUPDUSR_CF     =b.LSTUPDUSR_CF
    from BEST..TCTRULT a, #UPDTCTRULT b
    where a.CTR_NF  = b.CTR_NF
      and a.END_NT  = b.END_NT
      and a.SEC_NF  = b.SEC_NF
      and a.UWY_NF  = b.UWY_NF
      and a.UW_NT   = b.UW_NT
      and a.SSD_CF  = b.SSD_CF
      and a.DIV_NT  = b.DIV_NT
      and a.CRE_D   = b.CRE_D

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20020
        select @errmsg = 'Erreur update BEST..TCTRULT par #UPDTCTRULT'
        goto ERREUR
    end
    --[011] fin:


    -- 5. INSERTION / update des ENregistrements dans TCTRULT
    insert into BEST..TCTRULT ( CTR_NF,
                                END_NT,
                                SEC_NF,
                                UWY_NF,
                                UW_NT,
                                CRE_D,
                                SSD_CF,
                                DIV_NT,
                                CUR_CF,
                                CALAMTPRM_M,
                                ENTAMTPRM_M,
                                RETAMTPRM_M,
                                ADMMODPRM_CT,
                                RESPRM_M,
                                CALAMTCLM_M,
                                ENTAMTCLM_M,
                                RETAMTCLM_M,
                                ADMMODCLM_CT,
                                ORICOD_LS,
                                UPDUSR_CF,
                                CREUSR_CF,
                                LSTUPD_D,
                                LSTUPDUSR_CF )
    select A.CTR_NF,
           A.END_NT,
           A.SEC_NF,
           A.UWY_NF,
           A.UW_NT,
           A.CRE_D,
           A.SSD_CF,
           A.DIV_NT,
           A.CUR_CF,
           A.CALAMTPRM_M,
           A.ENTAMTPRM_M,
           A.RETAMTPRM_M,
           A.ADMMODPRM_CT,
           A.RESPRM_M,
           A.CALAMTCLM_M,
           A.ENTAMTCLM_M,
           A.RETAMTCLM_M,
           A.ADMMODCLM_CT,
           A.ORICOD_LS,
           A.UPDUSR_CF,
           A.CREUSR_CF,
           A.LSTUPD_D,
           A.LSTUPDUSR_CF
    from #UPDTCTRULT A
    where NOT EXISTS ( select 1                         --[011]
                       from BEST..TCTRULT b             --[011]
                       where b.CTR_NF  = A.CTR_NF       --[011]
                         and b.END_NT  = A.END_NT       --[011]
                         and b.SEC_NF  = A.SEC_NF       --[011]
                         and b.UWY_NF  = A.UWY_NF       --[011]
                         and b.UW_NT   = A.UW_NT        --[011]
                         and b.SSD_CF  = A.SSD_CF       --[011]
                         and b.DIV_NT  = A.DIV_NT       --[011]
                         and b.CRE_D   = A.CRE_D )      --[011]

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20076
        select @errmsg = 'Erreur insert BEST..TCTRULT par #UPDTCTRULT'
        goto ERREUR
    end


    -- 6. MISE a JOUR de TESTUW pour les Traités ALLOUES
    update BTRAV..TESTUW
       set A.ESTEND_B = 1, A.ESTUPDTYP_CT = 'I', A.ADMMODCTR_CT = 'A'
    from #MOD004TESTCTRULT B, BTRAV..TESTUW A
    where A.CTR_NF  = B.CTR_NF
      and A.END_NT  = B.END_NT
      and A.SEC_NF  = B.SEC_NF
      and A.UWY_NF  = B.UWY_NF
      and A.UW_NT   = B.UW_NT

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20090
        select @errmsg = 'Erreur update BTRAV..TESTUW par #MOD004TESTCTRULT'
        goto ERREUR
    end

    NextUpdtSect:
    /* -----------------------   FIN MOD004   ----------------------------- */
    /* -------------------------------------------------------------------- */


    /* --------------------------------------------------------------------------
       Mise a jour de la table TSECTION de la base TRAITE
     ---------------------------------------------------------------------------- */

    /*********************************************************************************************/
    /*********************************************************************************************/
    /***** ATTENTION ! LES TRIGGERS ONT ETE SUPPRIMES JUSTE AVANT LE LANCEMENT DE CETTE PROC *****/
    /***** LA MISE A JOUR D'AUTRES CHAMPS DE TSECTION DOIT ETRE REALISEE AVEC PRUDENCE ET    *****/
    /***** EN COHERENCE AVEC L'ACTION DES TRIGGERS 						     *****/
    /*********************************************************************************************/
    /*********************************************************************************************/
    update BTRT..TSECTION
       set A.ADMMODPRM_CT = B.ADMMODCTR_CT,
           A.ESTUPDTYP_CT = B.ESTUPDTYP_CT,
           A.ESTEND_B = B.ESTEND_B
    from BTRT..TSECTION A, BTRAV..TESTUW B
    where A.CTR_NF = B.CTR_NF
      and A.UWY_NF = B.UWY_NF
      and A.UW_NT = B.UW_NT
      and A.END_NT = B.END_NT
      and A.SEC_NF = B.SEC_NF

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20100
        select @errmsg = 'Erreur update BTRT..TSECTION par BTRAV..TESTUW'
        goto ERREUR
    end


    /* --------------------------------------------------------------------------
       Mise a jour de la table TSECTION_V de la base TRAITE
     ---------------------------------------------------------------------------- */
    update BTRT..TSECTION_V
       set A.ADMMODPRM_CT = B.ADMMODCTR_CT,
           A.ESTUPDTYP_CT = B.ESTUPDTYP_CT,
           A.ESTEND_B = B.ESTEND_B
    from BTRT..TSECTION_V A, BTRAV..TESTUW B
    where A.CTR_NF = B.CTR_NF
      and A.UWY_NF = B.UWY_NF
      and A.UW_NT = B.UW_NT
      and A.SEC_NF = B.SEC_NF
      and A.END_NT = ( select max( END_NT )
                       from BTRT..TSECTION_V
                       where CTR_NF = B.CTR_NF
                         and UWY_NF = B.UWY_NF
                         and UW_NT = B.UW_NT
                         and SEC_NF = B.SEC_NF )

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20110
        select @errmsg = 'Erreur update BTRT..TSECTION par BTRAV..TESTUW'
        goto ERREUR
    end


    /* ------------------------------------------------------------
       Mise a jour de la table TFAMLIA de la base TRAITE
     -------------------------------------------------------------- */

    /*********************************************************************************************/
    /*********************************************************************************************/
    /***** ATTENTION ! LES TRIGGERS ONT ETE SUPPRIMES JUSTE AVANT LE LANCEMENT DE CETTE PROC *****/
    /***** LA MISE A JOUR D'AUTRES CHAMPS DE TFAMLIA DOIT ETRE REALISEE AVEC PRUDENCE ET     *****/
    /***** EN COHERENCE AVEC L'ACTION DES TRIGGERS 						     *****/
    /*********************************************************************************************/
    /*********************************************************************************************/
set FORCEPLAN on                    -- [15043]

    update BTRT..TFAMLIA
       set A.SCOGLOEGP_M = B.SCOGLOEGP_M,
           A.PMLRAT_R = B.PMLRAT_R,
           A.EGPLESSCO_M = B.TOTCLM_M,
           A.SCOEGPCAL_B = B.SCOEGPCAL_B
    from BTRT..TFAMLIA A, BTRAV..TESTUW B
    where A.CTR_NF = B.CTR_NF
      and A.UWY_NF = B.UWY_NF
      and A.UW_NT  = B.UW_NT
      and A.END_NT = B.END_NT
      and A.SEC_NF = B.SEC_NF

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20120
        select @errmsg = 'Erreur update BTRT..TFAMLIA par BTRAV..TESTUW'
        goto ERREUR
    end


    /* ------------------------------------------------------------
       Mise a jour de la table TFAMLIA_V de la base TRAITE
     -------------------------------------------------------------- */
    update BTRT..TFAMLIA_V
       set A.SCOGLOEGP_M = B.SCOGLOEGP_M,
           A.PMLRAT_R = B.PMLRAT_R,
           A.EGPLESSCO_M = B.TOTCLM_M,
           A.SCOEGPCAL_B = B.SCOEGPCAL_B
    from BTRT..TFAMLIA_V A, BTRAV..TESTUW B
    where A.CTR_NF = B.CTR_NF
      and A.UWY_NF = B.UWY_NF
      and A.UW_NT = B.UW_NT
      and A.SEC_NF = B.SEC_NF
      and A.END_NT = ( select max( END_NT )
                       from BTRT..TFAMLIA_V
                       where CTR_NF = B.CTR_NF
                         and UWY_NF = B.UWY_NF
                         and UW_NT = B.UW_NT
                         and SEC_NF = B.SEC_NF )

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20130
        select @errmsg = 'Erreur update BTRT..TFAMLIA_V par BTRAV..TESTUW'
        goto ERREUR
    end


    /* ------------------------------------------------------------
       Mise a jour de la table TSECTION de la base FACULTATIVE
     -------------------------------------------------------------- */
    update BFAC..TSECTION
       set A.ADMMODPRM_CT = B.ADMMODCTR_CT,
           A.ESTUPDTYP_CT = B.ESTUPDTYP_CT
    from BFAC..TSECTION A, BTRAV..TESTUW B
    where A.CTR_NF = B.CTR_NF
      and A.UWY_NF = B.UWY_NF
      and A.UW_NT  = B.UW_NT
      and A.END_NT = B.END_NT
      and A.SEC_NF = B.SEC_NF

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20140
        select @errmsg = 'Erreur update BFAC..TSECTION par BTRAV..TESTUW'
        goto ERREUR
    end

set FORCEPLAN off              -- [150413]

    /* -------------------------------------------------------------------------------------------------
       Mise a jour de la table TREFCMT de la base REFERENCE si le type de traitement est quotidien ('Q')
     --------------------------------------------------------------------------------------------------- */
    if ( @p_typetraitement = "Q" )
    begin
        /* récupération du dernier numéro de commentaire de la table TREFCMT */
        select @numero_max_trefcmt = max( CMT_NT )
        from BREF..TREFCMT

        /* alimentation de #TREFCMT à partir de la table agenda BTRAV..TESTRMD */
        insert into #TREFCMT (CMTLIN_NT, CMT_T)
        select 1, CMT_T
        from BTRAV..TESTRMD

        select @erreur = @@error
        if @erreur != 0
        begin
            select @errno  = 20150
            select @errmsg = 'Erreur insert #TREFCMT par BTRAV..TESTRMD'
            goto ERREUR
        end

        /* insertion de nouvelles lignes dans la table TREFCMT */
        insert into BREF..TREFCMT
        select @numero_max_trefcmt + CMT_NT , CMTLIN_NT, CMT_T
        from #TREFCMT

        select @erreur = @@error
        if @erreur != 0
        begin
            select @errno  = 20151
            select @errmsg = 'Erreur insert BREF..TREFCMT par #TREFCMT'
            goto ERREUR
        end

        /* Montagnac
           select @d_str="#"+convert(char(10),getdate(),102)+"#"    */
        insert into BREF..TREFCMT
        select @numero_max_trefcmt + CMT_NT , CMTLIN_NT, @d_str+CMT_T
        from #TREFCMT

        select @erreur = @@error
        if @erreur != 0
        begin
            select @errno  = 20160
            select @errmsg = 'Erreur insert BREF..TREFCMT par #TREFCMT'
            goto ERREUR
        end
    end


    /* ------------------------------------------------------------
       Mise a jour de la table TREMINDER de la base REFERENCE
     -------------------------------------------------------------- */

    if ( @p_typetraitement = "Q" )
    begin
        /* récupération du dernier et de l'avant dernier numéros de commentaire de la table TREMINDER */
        select @numero_max_treminder = max( RMD_NF )
        from BREF..TREMINDER

        select @numero_avd_treminder = ( max( RMD_NF ) - 1 )
        from BREF..TREMINDER

        /* alimentation de #TREMINDER à partir de la table agenda BTRAV..TESTRMD */
        insert into #TREMINDER ( RMDISS_D, RMDOBJ_LL, RMDDOM_CT, RMDENTIDT_CT, RMDENTLAB_LL )
        select getdate( ), RMDOBJ_LL, RMDDOM_CT, RMDENTIDT_CT, RMDENTLAB_LL
        from BTRAV..TESTRMD

        select @erreur = @@error
        if @erreur != 0
        begin
            select @errno  = 20170
            select @errmsg = 'Erreur insert #TREMINDER par BTRAV..TESTRMD'
            goto ERREUR
        end

        /* insertion de nouvelles lignes dans la table TREMINDER */
        insert into BREF..TREMINDER ( RMD_NF, RMDISS_D, RMDISSUSR_CF, RMDEXP_D, RMDOBJ_LL, ACTEXP_B, ACTDON_B,
                                      RMDEVTTYP_CF, RMDTOFIL_B, RMDTODEL_B, RMDCTY_CF, RMDDOM_CT, RMDENTIDT_CT,
                                      RMDENTLAB_LL, RMDTECTYP_CT, RMDCMT_NT )
        select @numero_max_treminder + RMD_NF, RMDISS_D, "", "", RMDOBJ_LL, 0, 0, 0, 0, 0, "",
               RMDDOM_CT, RMDENTIDT_CT, RMDENTLAB_LL, 0, @numero_max_trefcmt + RMD_NF
        from #TREMINDER

        select @erreur = @@error
        if @erreur != 0
        begin
            select @errno  = 20180
            select @errmsg = 'Erreur insert BREF..TREMINDER par #TREMINDER'
            goto ERREUR
        end
    end


    /* ------------------------------------------------------------
       Mise a jour de la table TREMINUSR de la base REFERENCE
       ------------------------------------------------------------ */
    if ( @p_typetraitement = "Q" )
    begin
        /* alimentation de #TREMINUSR à partir de la table agenda BTRAV..TESTRMD */
        insert into #TREMINUSR ( RMDADDUSR_CF )
        select  UWRSPUSR_CF
        from BTRAV..TESTRMD

        select @erreur = @@error
        if @erreur != 0
        begin
            select @errno  = 20190
            select @errmsg = 'Erreur insert #TREMINUSR par BTRAV..TESTRMD'
            goto ERREUR
        end


        /* insertion de nouvelles lignes dans la table TREMINUSR 	*/

        /***************************************************************/
        /* Modifs du 26/05/98 - M.HA-THUC					*/
        /* Rajout d'un curseur pour insérer des lignes dans TREMINUSR	*/
        /* car le trigger n'est pas adapté à des traitements 		*/
        /* ensemblistes							*/
        /***************************************************************/
        declare cur_treminusr cursor for select  RMD_NF, RMDADDUSR_CF
                                         from #TREMINUSR
                                         order by RMD_NF, RMDADDUSR_CF
        for read only

        declare @RMD_NF numeric( 10, 0 ),
                @RMDADDUSR_CF UUSR_CF

        open cur_treminusr
        fetch cur_treminusr into @RMD_NF, @RMDADDUSR_CF

        while (@@sqlstatus = 0)
        begin
            insert BREF..TREMINUSR ( RMD_NF, RMDADDUSR_CF, RMDISSUSR_CF, ACTEXP_B, ACTDON_B, ACTDON_D )
            values ( @numero_max_treminder + @RMD_NF, @RMDADDUSR_CF, @RMDADDUSR_CF, 0, 0, "" )

            select @erreur = @@error
            if @erreur != 0
            begin
                select @errno  = 20191
                select @errmsg = 'Erreur insert BREF..TREMINUSR Loop #TREMINUSR'
                goto ERREUR
            end

        fetch cur_treminusr into @RMD_NF, @RMDADDUSR_CF
        end

        close cur_treminusr
        deallocate cursor cur_treminusr
    end


    /* ---------------------------------
       Mise a jour de la table TREQJOB
       --------------------------------- */
    select 1
    from BEST..TREQJOB
    where REQCOD_CT = 'U'
    and SITE_CF = @site_cf

    if @@rowcount = 0
    /* insert si premier lancement de la chaîne */
    begin
	    insert BEST..TREQJOB ( SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, LAUNCH_D, SITE_CF )
        values ( 99, 1997, 1, getdate(), 'U', getdate(), getdate(), @site_cf )

        select @erreur = @@error
        if @erreur != 0
        begin
            select @errno  = 20192
            select @errmsg = 'Erreur INSERT BEST..TREQJOB Fixe Data 99-1997-U'
            goto ERREUR
        end
    end
    else
        /* sinon update */
        begin
            update BEST..TREQJOB
               set LAUNCH_D = getdate()
            where REQCOD_CT = 'U'
            and SITE_CF = @site_cf

        select @erreur = @@error
        if @erreur != 0
        begin
            select @errno  = 20193
            select @errmsg = 'Erreur UPDATE BEST..TREQJOB Fixe U'
            goto ERREUR
        end
    end


    /**********************************************************************************/
    delete BEST..TCTRACC from BEST..TCTRACC a
    where not exists ( select 1
                       from BTRAV..TBESTGTAKEY kt
                       where a.CTR_NF=kt.CTR_NF
                         and a.END_NT=kt.END_NT
                         and a.SEC_NF=kt.SEC_NF
                         and a.UWY_NF=kt.UWY_NF
                         and a.UW_NT=kt.UW_NT )
          and (   exists(select 1 from BTRT..TCONTR x, BREF..TBATCHSSD c 
                         where a.CTR_NF=x.CTR_NF 
                         and a.UWY_NF=x.UWY_NF 
                         and a.UW_NT=x.UW_NT 
                         and a.END_NT=x.END_NT 
                         and x.SSD_CF=c.SSD_CF 
                         and c.BATCHUSER_CF=@suser_Name)  --[015]
               or exists(select 1 from BFAC..TCONTR y, BREF..TBATCHSSD e 
                         where a.CTR_NF=y.CTR_NF 
                         and a.UWY_NF=y.UWY_NF 
                         and a.UW_NT=y.UW_NT 
                         and a.END_NT=y.END_NT 
                         and y.SSD_CF=e.SSD_CF 
                         and e.BATCHUSER_CF=@suser_Name) --[015]
              )

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20200
        select @errmsg = 'Erreur delete BEST..TCTRACC par BTRAV..TBESTGTAKEY'
        goto ERREUR
    end

    /**********************************************************************************/

    /* -------------------------------------------------------------------- */
    /* ----------------------    DEBUT MOD004   --------------------------- */
    -- 6. INSERTION des ENREGISTREMENTS dans TCTRACC
    -- Debut MOD005
    delete BEST..TCTRACC from BEST..TCTRACC a
    where exists ( select 1
                   from #MOD004TESTCTRULT B
                   where a.CTR_NF=B.CTR_NF
                     and a.END_NT=B.END_NT
                     and a.SEC_NF=B.SEC_NF
                     and a.UWY_NF=B.UWY_NF
                     and a.UW_NT=B.UW_NT )
    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20210
        select @errmsg = 'Erreur delete BEST..TCTRACC par #MOD004TESTCTRULT'
        goto ERREUR
    end
    -- Fin MOD005

    insert  into BEST..TCTRACC ( CTR_NF, END_NT, SEC_NF, UW_NT, UWY_NF )
    select DISTINCT CTR_NF, END_NT, SEC_NF, UW_NT, UWY_NF
    from #MOD004TESTCTRULT

    select @erreur = @@error
    if @erreur != 0
    begin
        select @errno  = 20220
        select @errmsg = 'Erreur insert BEST..TCTRACC par #MOD004TESTCTRULT'
        goto ERREUR
    end
    /* -----------------------   FIN MOD004   ----------------------------- */
    /* -------------------------------------------------------------------- */


if @tran_imbr = 0
  commit tran

/* ----------------------------------------------------------------------
   suppression des tables temporaires #TREFCMT, #TREMINDER et #TREMINUSR
   ---------------------------------------------------------------------- */
drop table #TREFCMT
drop table #TREMINDER
drop table #TREMINUSR

/* ------------------------------------------------------------------------------
   reinitialisation des tables de travail EST_ULT_ESEJ1000_TCTRULT, TESTRMD, TESTUW, TESTCPLAMT
   ------------------------------------------------------------------------------ */
--[012] truncate table BTRAV..EST_ULT_ESEJ1000_TCTRULT      --[012] BTRAV..TESTCTRULT
truncate table BTRAV..TESTRMD
truncate table BTRAV..TESTUW
truncate table BTRAV..TESTCPLAMT

/* ------------------------------------------------------------
   réinitialisation des tables  BEST..TCTRACC et BEST..TSBJPRM
   ----------------------------------------------------------- */
/* modification : 9/3/1999 truncate -> delete selectif / tctracc */
/* seuls les enregistrements n'éxistant pas dans TBESTGTAKEY  sont supprimés */
/* truncate table BEST..TCTRACC */
/* cf lignes avant commit-tran */

truncate table BTRAV..TBESTGTAKEY

delete BEST..TSBJPRM
 from BEST..TSBJPRM a
  where exists(select 1 from BTRT..TCONTR x, BREF..TBATCHSSD c 
               where a.CTR_NF=x.CTR_NF 
               and a.UWY_NF=x.UWY_NF 
               and a.UW_NT=x.UW_NT 
               and a.END_NT=x.END_NT 
               and x.SSD_CF=c.SSD_CF 
               and c.BATCHUSER_CF=@suser_Name)  --[015]
     or exists(select 1 from BFAC..TCONTR y, BREF..TBATCHSSD e 
               where a.CTR_NF=y.CTR_NF 
               and a.UWY_NF=y.UWY_NF 
               and a.UW_NT=y.UW_NT 
               and a.END_NT=y.END_NT 
               and y.SSD_CF=e.SSD_CF 
               and e.BATCHUSER_CF=@suser_Name)  --[015]

return 0

ERREUR:
  raiserror @errno @errmsg
  rollback transaction
  return @erreur
go
if object_id('dbo.PuUNDSTA_01') is not null
  print '<<< CREATED PROC dbo.PuUNDSTA_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuUNDSTA_01 >>>'
go
grant execute on dbo.PuUNDSTA_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuUNDSTA_01 TO GDBBATCH
go
