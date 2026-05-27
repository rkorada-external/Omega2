USE BSAR
GO

/* DROP PROC dbo.PsETATCAC_03 */
IF OBJECT_ID('dbo.PsETATCAC_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsETATCAC_03
    IF OBJECT_ID('dbo.PsETATCAC_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsETATCAC_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsETATCAC_03 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsETATCAC_03  (
                                @ParamDate datetime,
                                @DateTCurquot datetime,
                                @NameTableCompta char(32),
                                @AnneeBilan int,
                                @Taux char(3)
                                )
as

/***************************************************
Programme: PsETATCAC_03
Fichier script associé : BEST_PsETATCAC_03.PRC
Domaine : Estimations
Base principale : BSAR
Version: 1
Auteur: M.DJELLOULI / O.GIRAUX
Date de creation: 06/10/2005 M.DJELLOULI From O.GIRAUX 03/07/2002
Description du programme:

SCRIPT DE GENERATION des ETATS CAC RETRO pour filiales 2 et 3 ( Pour les Commissaires aux comptes )
---------------------------------------------------------------------

Procédure à suivre pour récupérer les mvts:

1.Recharger les tables BSAR..TTECLEDA_x, BREF..TCURQUOT, BREF..TTRSLNK en mai_infomega à partir
de prod_infomega

2.Mettre à jour les variables ci-dessous :
- @change_d : date de change
- @table : suffixe de la table TTECLEDA : A, B, C, D ...
- @annee_bilan :Année bilan

3. Tt sélectionner jusqu'à la partie "SELECTION FINALE" ( chercher ce mot ds le code)
4. Exécuter ensuite chaque select l'un après l'autre
5. Enregistrer chaque résultat ds un fichier .csv
6. Récupérer chaque fichier .csv précédemment généré et mettre le contenu ds un .xls
avec différents onglets correspondant aux tranches d'exercices. ( on a des milliers de lignes pour
la filiale 2, qq dizaines seulement pour filiale 3)


Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur:    J. Ribot
Date:     14/06/2007
Version:
Description:  SPOT 14170 ajout filiale 05 07  02/10/2007 14170/2 filiale 6 pour 3T 2007


MODIFICATION 2
Auteur:    J. Ribot
Date:     04/12/2007
Version:
Description:  SPOT 14170 pour ne pas prendre le legale Italien

MODIFICATION 3
Auteur:    J. Ribot
Date:     03/03/2008
Version:
Description:  SPOT 15149  on utilise le taux moyens (BREF..TAVERATE) et non plus le taux mensuel (BREF..TCURQUOT) dans les états CAC

MODIFICATION 5

     13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs

MODIFICATION 6

 22/04/2008    J.Ribot  SPOT15168 ajout parametre TAUX pour sortie etats CAC au taux moyen et au taux cloture en un seul passage

_________________
MODIFICATION 7

 03/10/2008    JFVDV  [SPOT16159] Ajout de la colonne établissement (ESB_CF) après la colonne filiale (SSD_CF)
                                  ne pas traiter les mouvements de l'établissemnt ESB_CF = 10 pour la filiale SSD_CF = 5

_________________
MODIFICATION 8

 14/11/2008    JFVDV  [SPOT16438] Ajout de la filiale 17 et pour la filiale 5, prendre tous les établissements
_________________
MODIFICATION    [009]
Auteur:         D.GATIBELZA
Date:           01/04/2009
Version:        9.1
Description:    ESTDOM17162 Etats CAC  inclure le témoin IFRS
_________________
MODIFICATION    [010]
Auteur:         Ph. VESSIERE
Date:           26/06/2009
Version:        9.1
Description:    [SPOT17610] - ESTDOM - EVOLUTIONS SUR FICHIER CAC 2Q2009
_________________
MODIFICATION    [011]
Auteur:         Ph. VESSIERE
Date:           2010.09.28
Version:        10.1
Description:    [SPOT19157] - ESTDOM - Remplissage des tables Retro en TXC ou TXM (= @taux)
                   (+) - BTRAVI..EST_ESID7100_ETATCAC_RETRO_TXC
                   (+) - BTRAVI..EST_ESID7100_ETATCAC_RETRO_TXM
*****************************************************/

-- --------------------------------------------------------------------
-- Définition Variables
-- --------------------------------------------------------------------

declare @erreur int
declare	@RetourProc     int
declare @MsgErreur char(256)
declare @SuffixeTable char(1)

declare @NbLineTemp1 int
declare @NbLineTemp2 int
declare @NbLineTemp3 int
declare @NbLineTemp4 int

Select @NameTableCompta = rtrim(ltrim(Upper(@NameTableCompta)))
-- Vérification Préliminaire des Paramètres
if ((@NameTableCompta = null) or (@NameTableCompta = ''))
    Begin
         Select @MsgErreur="0010. Paramètre : Nom de la Table Incorrect"
         goto ErreurCAC
    End

Select @SuffixeTable = Right(rtrim(ltrim(@NameTableCompta)),1)
Select @SuffixeTable
if ((@SuffixeTable != 'A' AND @SuffixeTable != 'B' AND @SuffixeTable != 'C' AND @SuffixeTable != 'D' AND @SuffixeTable != 'E' AND @SuffixeTable != 'F') or (@SuffixeTable = null) or (@SuffixeTable = ''))
    Begin
         Select @MsgErreur="0020. Paramètre : Erreur Suffixe de la Table Compta Incorrect"
         goto ErreurCAC
    End

if ((@DateTCurquot = null))
    Begin
         Select @MsgErreur="0030. Paramètre : Date pour Taux de Change TCURQUOT Incorrecte"
         goto ErreurCAC
    End

if ((@AnneeBilan = 0) or (@AnneeBilan = null))
    Begin
         Select @MsgErreur="0040. Paramètre : Année Bilan Incorrecte"
         goto ErreurCAC
    End




-- --------------------------------------------------------------------
-- Création des Tables de Travail
-- --------------------------------------------------------------------

if object_id('#tacmtrsh') is not null
	drop table #tacmtrsh
CREATE TABLE #tacmtrsh(
    ACMTRS_NT    smallint          NOT NULL,
    DETTRS_CF    UDETTRS_CF        NOT NULL,
    ACMTRS_LL    UL64              NOT NULL)

if object_id('#tcledr') is not null
	drop table #tcledr
CREATE TABLE #tcledr
(
    ctr_nf      UCTR_NF     NULL ,
    sec_nf      USEC_NF     NULL ,
    uwy_nf      UUWY_NF     NULL ,
    ctrnat_ct   char        NULL ,
    lobacc_cf   ULOB_CF     NULL ,
    ced_nf      UCLI_NF     NULL ,
    uworg_cf    smallint    NULL ,
	  trncod_cf   UDETTRS_CF  NOT NULL ,
    ssd_cf      USSD_CF     NOT NULL ,
    amt_m       UAMT_M      default 0 ,
    cur_cf      UCUR_CF     NULL ,
    TYPE        int         default 0,
    retctrcat_cf UCTRNAT_CF NULL,
    seg_nf      USEG_NF     NULL,
    RETCTR_NF    URETCTR_NF NOT NULL,
    CTRORI_CF    char(2)    DEFAULT '' NOT NULL,
    esb_cf      UESB_CF     NULL,   -- [SPOT16159] vde le 03/10/2008
    end_nt      UEND_NT     NULL,   -- [SPOT17610]
    uw_nt       UUW_NT      NULL,   -- [SPOT17610]
    colval_lm   UL32        NULL    -- [SPOT17610]
)

-- Création de l'Indexe attacher à la Table Temporaire #tcleda
IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#tcledr') AND name='I_tcledr_00')
BEGIN
    DROP INDEX #tcledr.I_tcledr_00
END

CREATE NONCLUSTERED INDEX I_tcledr_00
    ON #tcledr(TRNCOD_CF)

    if @@error != 0
       begin
         Select @MsgErreur="0051. Erreur sur la Création de l'Index de la Table #tcledr"
         goto ErreurCAC
       end


if object_id('#temp0') is not null
	drop table #temp0

if object_id('#temp') is not null
	drop table #temp
CREATE TABLE #temp (
    ctr_nf      UCTR_NF     NULL ,
    sec_nf      USEC_NF     NULL ,
    uwy_nf      UUWY_NF     NULL ,
    ctrnat_ct   char        NULL ,
    lobacc_cf   ULOB_CF     NULL ,
    acmtrs_ll   UL64        NULL ,
    ced_nf      UCLI_NF     NULL ,
    uworg_cf    smallint    NULL ,
    ssd_cf      USSD_CF     NOT NULL ,
    MTOR        UAMT_M      default 0 ,
    cur_cf      UCUR_CF     NULL ,
    TYPE        int         default 0,
    retctrcat_cf UCTRNAT_CF NULL,
    seg_nf      USEG_NF     NULL,
    CTRORI_CF    char(2)    DEFAULT '' NOT NULL,
    esb_cf      UESB_CF     NULL,       -- [SPOT16159] vde le 03/10/2008
    TRNTYP_CT   tinyint     NULL,       -- [009]
    end_nt      UEND_NT     NULL,       -- [SPOT17610]
    uw_nt       UUW_NT      NULL,       -- [SPOT17610]
    colval_lm   UL32        NULL        -- [SPOT17610]
)
-- Création des l'Indexe attacher à la Table Temporaire #temp
IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#temp') AND name='I_temp_00')
BEGIN
    DROP INDEX #temp.I_temp_00
END
IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#temp') AND name='I_temp_01')
BEGIN
    DROP INDEX #temp.I_temp_01
END
IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#temp') AND name='I_temp_02')
BEGIN
    DROP INDEX #temp.I_temp_02
END
IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#temp') AND name='I_temp_03')
BEGIN
    DROP INDEX #temp.I_temp_03
END
IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#temp') AND name='I_temp_04')
BEGIN
    DROP INDEX #temp.I_temp_04
END

CREATE NONCLUSTERED INDEX I_temp_01
    ON #temp(CTR_NF, UWY_NF)
CREATE NONCLUSTERED INDEX I_temp_02
    ON #temp(CUR_CF, SSD_CF)
CREATE NONCLUSTERED INDEX I_temp_03
    ON #temp(CED_NF, UWORG_CF)
CREATE NONCLUSTERED INDEX I_temp_04
    ON #temp(SSD_CF, CTR_NF, SEC_NF, UWY_NF, CTRNAT_CT, LOBACC_CF, TYPE, ACMTRS_LL, SEG_NF, UWORG_CF, CED_NF)

    if @@error != 0
       begin
         Select @MsgErreur="0052. Erreur sur la Création de l'Index de la Table #tacmtrsh"
         goto ErreurCAC
       end


if object_id('#temp2') is not null
	drop table #temp2

CREATE TABLE #temp2
(
    ctr_nf      UCTR_NF     NULL ,
    sec_nf      USEC_NF     NULL ,
    uwy_nf      UUWY_NF     NULL ,
    ctrnat_ct   char        NULL ,
    lobacc_cf   ULOB_CF     NULL ,
    ssd_cf      USSD_CF     NOT NULL ,
    TYPE        int         default 0,
    CHARGES     UAMT_M      default 0 ,
    COURTAGE    UAMT_M      default 0 ,
    FAR         UAMT_M      default 0 ,
    IBNR2       UAMT_M      default 0 ,
    PB          UAMT_M      default 0 ,
    PNA         UAMT_M      default 0 ,
    PRIMES      UAMT_M      default 0 ,
    PROVSIN     UAMT_M      default 0 ,
    PVEQ        UAMT_M      default 0 ,
    RFAR        UAMT_M      default 0 ,
    RIBNR2      UAMT_M      default 0 ,
    RPNA        UAMT_M      default 0 ,
    RPROVSIN    UAMT_M      default 0 ,
    RPVEQ       UAMT_M      default 0 ,
    RSNEM       UAMT_M      default 0 ,
    SINP        UAMT_M      default 0 ,
    SNEM        UAMT_M      default 0 ,
    RFRAGES     UAMT_M      default 0 ,
    PBSURRET    UAMT_M      default 0 ,
    FGESCLO     UAMT_M      default 0,
    seg_nf      USEG_NF     NULL,
    esb_cf      UESB_CF     NULL,       -- [SPOT16159] vde le 03/10/2008
    TRNTYP_CT   tinyint     NULL,       -- [009]
    end_nt      UEND_NT     NULL,       -- [SPOT17610]
    uw_nt       UUW_NT      NULL,       -- [SPOT17610]
    colval_lm   UL32        NULL        -- [SPOT17610]
 )

-- Création des l'Indexe attacher à la Table Temporaire #temp2
IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#temp2') AND name='I_temp2_00')
BEGIN
    DROP INDEX #temp2.I_temp2_00
END
CREATE NONCLUSTERED INDEX I_temp2_00
    ON #temp2(CTR_NF, SEC_NF, UWY_NF, CTRNAT_CT, LOBACC_CF, SSD_CF, TYPE, SEG_NF)


----------------------------------------------------------------
--regroupement du regroupement des postes comptables niveau 3
----------------------------------------------------------------
/*** 1 primes ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'PRIMES'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (1010, 1011, 1012, 1013, 1014)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 2 PNA cloture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'PNA'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (1030)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 3 PNA Ouverture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'RPNA'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (1020)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 4 charges ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'CHARGES'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (2010, 2011, 2012)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 5 sinistres ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'SINP'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (3010, 3012,3013,3014)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 6 IBNR2 cloture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'IBNR2'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
--and acmtrs_nt in (3090)
and acmtrs_nt in (3090, 3112)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 7 IBNR2 ouverture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'RIBNR2'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
--and acmtrs_nt in (3080)
and acmtrs_nt in (3080, 3102)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 8 Courtage ****/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'COURTAGE'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (2014)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 9 FAR cloture ****/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'FAR'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (2030, 2031)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 10 FAR ouverture ****/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'RFAR'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (2020, 2021)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 11 Prov equilibrage cloture ****/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'PVEQ'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (3110)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 12 prov equilibrage ouverture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'RPVEQ'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (3100)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 13 frais de gestion ouverture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'RFRAGES'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (3101)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 14 PB ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'PB'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (2015, 2016)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 15 PB / surcom retro ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'PBSURRET'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (2013, 2017)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 16 sap cloture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'PROVSIN'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
--and acmtrs_nt in (3030, 3031, 3032, 3112)
and acmtrs_nt in (3030, 3031, 3032)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 17 sap ouverture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'RPROVSIN'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
--and acmtrs_nt in (3020, 3102, 3021, 3022)
and acmtrs_nt in (3020, 3021, 3022)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 18 cloture snem ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'SNEM'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (3070)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

/*** 19 ouverture snem ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'RSNEM'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (3060)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end


/*** 20 frais de gestion cloture ***/
insert #tacmtrsh
    (acmtrs_nt,
     DETTRS_CF,
     acmtrs_ll)
select acmtrs_nt, DETTRS_CF, 'FGESCLO'
from bref..ttrslnk b
where b.prs_cf = 751
and dettrs_cf like '2%'
and acmtrs_nt in (3111)
    if @@error != 0
       begin
         Select @MsgErreur="1010. Erreur sur Insertion dans la Table #tacmtrsh"
         goto ErreurCAC
       end

-- Création de l'Indexe attacher à la Table Temporaire #tacmtrsh
IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#tacmtrsh') AND name='I_tacmtrsh_00')
BEGIN
    DROP INDEX #tacmtrsh.I_tacmtrsh_00
END

CREATE UNIQUE CLUSTERED INDEX I_tacmtrsh_00
    ON #tacmtrsh(DETTRS_CF)

    if @@error != 0
       begin
         Select @MsgErreur="0050. Erreur sur la Création de l'Index de la Table #tacmtrsh"
         goto ErreurCAC
       end


-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--   PARTIE 1
-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

        If (@SuffixeTable = 'A')
        Begin
                -- [SPOT17610] - Add ssd_cf = 1, Add end_nt & uw_nt & colval_lm columns.
                insert #tcledr
                       (ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, amt_m   , cur_cf   , TYPE    , retctrcat_cf, seg_nf, retctr_nf, esb_cf, end_nt, uw_nt, colval_lm )
                select  ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, retamt_m, retcur_cf, TYPE = 0, retctrcat_cf, seg_nf, retctr_nf, esb_cf, end_nt, uw_nt, NULL
            	from bsar..ttecleda_a
                	WHERE ssd_cf in (1, 2, 3, 5, 6, 7, 17)                       --  SPOT 14170 filiale  05 07  14170/2 filiale 6 pour 3T 2007 +  [SPOT16438] ajout filiale 17
                      and substring( trncod_cf, 2, 1 ) not in ('S','C','O','R','I','T')  --  SPOT 14170 pour ne pas prendre le legale Italien
            	and trncod_cf like "2%"
            	and balshey_nf = @AnneeBilan

        End

        If (@SuffixeTable = 'B')
        Begin
                -- [SPOT17610] - Add ssd_cf = 1, Add end_nt & uw_nt & colval_lm columns.
                        insert #tcledr
                              ( ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, amt_m   , cur_cf   , TYPE    , retctrcat_cf, seg_nf,retctr_nf, esb_cf, end_nt, uw_nt, colval_lm)
                        select  ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf,	trncod_cf, ssd_cf, retamt_m, retcur_cf, TYPE = 0, retctrcat_cf, seg_nf,retctr_nf, esb_cf, end_nt, uw_nt, NULL
                    	from bsar..ttecleda_b
                	WHERE ssd_cf in (1, 2, 3, 5, 6, 7, 17)                       --  SPOT 14170 filiale  05 07  14170/2 filiale 6 pour 3T 2007  +  [SPOT16438] ajout filiale 17
                      and substring( trncod_cf, 2, 1 ) not in ('S','C','O','R','I','T')  --  SPOT 14170 pour ne pas prendre le legale Italien
                    	and trncod_cf like "2%"
                	    and balshey_nf = @AnneeBilan
        End

        If (@SuffixeTable = 'C')
        Begin
                -- [SPOT17610] - Add ssd_cf = 1, Add end_nt & uw_nt & colval_lm columns.
                       insert #tcledr
                               (ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, amt_m   , cur_cf   , TYPE    , retctrcat_cf, seg_nf,retctr_nf, esb_cf, end_nt, uw_nt, colval_lm)
                        select  ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf,	trncod_cf, ssd_cf, retamt_m, retcur_cf, TYPE = 0, retctrcat_cf, seg_nf,retctr_nf, esb_cf, end_nt, uw_nt, NULL
                    	from bsar..ttecleda_c
                	WHERE ssd_cf in (1, 2, 3, 5, 6, 7, 17)                       --  SPOT 14170 filiale  05 07  14170/2 filiale 6 pour 3T 2007   +  [SPOT16438] ajout filiale 17
                      and substring( trncod_cf, 2, 1 ) not in ('S','C','O','R','I','T')  --  SPOT 14170 pour ne pas prendre le legale Italien
                    	and trncod_cf like "2%"
                	    and balshey_nf = @AnneeBilan
        End

        If (@SuffixeTable = 'D')
        Begin
                -- [SPOT17610] - Add ssd_cf = 1, Add end_nt & uw_nt & colval_lm columns.
                       insert #tcledr
                               (ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, amt_m   , cur_cf   , TYPE    , retctrcat_cf, seg_nf, retctr_nf, esb_cf, end_nt, uw_nt, colval_lm )
                        select  ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, retamt_m, retcur_cf, TYPE = 0, retctrcat_cf, seg_nf, retctr_nf, esb_cf, end_nt, uw_nt, NULL
                    	from bsar..ttecleda_d
                	WHERE ssd_cf in (1, 2, 3, 5, 6, 7, 17)                       --  SPOT 14170 filiale  05 07  14170/2 filiale 6 pour 3T 2007   +  [SPOT16438] ajout filiale 17
                      and substring( trncod_cf, 2, 1 ) not in ('S','C','O','R','I','T')  --  SPOT 14170 pour ne pas prendre le legale Italien
                    	and trncod_cf like "2%"
                	    and balshey_nf = @AnneeBilan
        End

        If (@SuffixeTable = 'E')
        Begin
                -- [SPOT17610] - Add ssd_cf = 1, Add end_nt & uw_nt & colval_lm columns.
                       insert #tcledr
                               (ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, amt_m   , cur_cf   , TYPE    , retctrcat_cf, seg_nf, retctr_nf, esb_cf, end_nt, uw_nt, colval_lm)
                        select  ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf,	trncod_cf, ssd_cf, retamt_m, retcur_cf, TYPE = 0, retctrcat_cf, seg_nf, retctr_nf, esb_cf, end_nt, uw_nt, NULL
                    	from bsar..ttecleda_e
                	WHERE ssd_cf in (1, 2, 3, 5, 6, 7, 17)                       --  SPOT 14170 filiale  05 07  14170/2 filiale 6 pour 3T 2007   +  [SPOT16438] ajout filiale 17
                      and substring( trncod_cf, 2, 1 ) not in ('S','C','O','R','I','T')  --  SPOT 14170 pour ne pas prendre le legale Italien
                    	and trncod_cf like "2%"
                	    and balshey_nf = @AnneeBilan
        End

        If (@SuffixeTable = 'F')
        Begin
                -- [SPOT17610] - Add ssd_cf = 1, Add end_nt & uw_nt & colval_lm columns.
                       insert #tcledr
                               (ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, amt_m   , cur_cf   , TYPE    , retctrcat_cf, seg_nf, retctr_nf, esb_cf, end_nt, uw_nt, colval_lm)
                        select  ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ced_nf, uworg_cf, trncod_cf, ssd_cf, retamt_m, retcur_cf, TYPE = 0, retctrcat_cf, seg_nf, retctr_nf, esb_cf, end_nt, uw_nt, NULL
                    	from bsar..ttecleda_f
                	WHERE ssd_cf in (1, 2, 3, 5, 6, 7, 17)                       --  SPOT 14170 filiale  05 07  14170/2 filiale 6 pour 3T 2007  +  [SPOT16438] ajout filiale 17
                      and substring( trncod_cf, 2, 1 ) not in ('S','C','O','R','I','T')  --  SPOT 14170 pour ne pas prendre le legale Italien
                    	and trncod_cf like "2%"
                	    and balshey_nf = @AnneeBilan
        End

    if @@error != 0
       begin
         Select @MsgErreur="1020. Erreur sur Insertion dans la Table #tcledr"
         goto ErreurCAC
       end

-- [SPOT16159] On élimine tous les mouvements de l'établissement 10 pour la filiale 5
-- [SPOT16438] suppression de la restriction de l'établissement sur la filiale 5
--DELETE #TCLEDR
--WHERE SSD_CF = 5
--and   ESB_CF = 10

--if @@error != 0
--   begin
--     Select @MsgErreur="1020. Erreur Suppresion de la Table #TCLEDR"
--     goto ErreurCAC
--   end

-- [SPOT17610] - Keep only #TCLEDR records with (ssd_cf = 1 AND ESB_CF = 2).
DELETE #TCLEDR
 WHERE SSD_CF = 1
   AND ESB_CF != 2

if @@error != 0
   begin
     Select @MsgErreur="1020. Erreur Suppresion de la Table #TCLEDR"
     goto ErreurCAC
   end

-- [SPOT17610] - Update colval_lm.
 SELECT DISTINCT TUWCTR_END.CTR_NF, TUWCTR_END.UWY_NF, TUWCTR_END.END_NT, TUWCTR_END.UW_NT, TBANALL_END.COLVAL_LM
    INTO #TCLEDR_COLVAL_LM
    FROM bsbo..TUWCTR TUWCTR_END, bref..TBANALL TBANALL_END
   WHERE TUWCTR_END.CTRQUA2_CF*=CONVERT(int, TBANALL_END.COLVAL_CT)
     AND TBANALL_END.COL_LS='CTRQUA2_CF'
     AND TBANALL_END.LAG_CF ='F'
GROUP BY TUWCTR_END.CTR_NF, TUWCTR_END.UWY_NF, TUWCTR_END.END_NT, TUWCTR_END.UW_NT, TBANALL_END.COLVAL_LM
ORDER BY TUWCTR_END.CTR_NF, TUWCTR_END.UWY_NF, TUWCTR_END.END_NT, TUWCTR_END.UW_NT, TBANALL_END.COLVAL_LM

UPDATE #TCLEDR
   SET #TCLEDR.COLVAL_LM = #TCLEDR_COLVAL_LM.COLVAL_LM
  FROM #TCLEDR, #TCLEDR_COLVAL_LM
 WHERE #TCLEDR.CTR_NF = #TCLEDR_COLVAL_LM.CTR_NF
   AND #TCLEDR.UWY_NF = #TCLEDR_COLVAL_LM.UWY_NF
   AND #TCLEDR.END_NT = #TCLEDR_COLVAL_LM.END_NT
   AND #TCLEDR.UW_NT = #TCLEDR_COLVAL_LM.UW_NT

DROP TABLE #TCLEDR_COLVAL_LM

update #tcledr
set CTRORI_CF="78"
from #tcledr a, bret..tretctr b
where a.retctr_nf=b.retctr_nf
and b.ctrori_cf="78"
    if @@error != 0
       begin
         Select @MsgErreur="1021. Erreur sur maj de la table #tcledr CTRORI_CF"
         goto ErreurCAC
       end

update #tcledr
set RETCTRCAT_cf=b.retctrcat_cf
from #tcledr a, bret..tretctr b
where a.retctr_nf=b.retctr_nf
  and a.retctrcat_cf is null
    if @@error != 0
       begin
         Select @MsgErreur="1022. Erreur sur maj de la table #tcledr RETCTRCAT_cf"
         goto ErreurCAC
       end



-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--   PARTIE 2
-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

---------------------------------------------------------
-- #temp0 - Maj libelle postee comptable
-- [009] ajout jointure TBOPRSLNK
---------------------------------------------------------
/* Adaptive Server has expanded all '*' elements in the following statement */ select a.ctr_nf, a.sec_nf, a.uwy_nf, a.ctrnat_ct, a.lobacc_cf, a.ced_nf, a.uworg_cf, a.trncod_cf, a.ssd_cf, a.amt_m, a.cur_cf, a.TYPE, a.retctrcat_cf, a.seg_nf, a.RETCTR_NF, a.CTRORI_CF, a.esb_cf, a.end_nt, a.uw_nt, a.colval_lm, b.acmtrs_ll, c.TRNTYP_CT
into #temp0
from #tcledr a, #tacmtrsh b, BSAR..TBOPRSLNK c
where a.trncod_cf = b.dettrs_cf
  and c.dettrs_cf = a.trncod_cf

if @@error != 0
   begin
     Select @MsgErreur="2010. Erreur sur Insertion dans la Table #temp0"
     goto ErreurCAC
   end


drop table #tcledr

if @@error != 0
   begin
     Select @MsgErreur="2020. Erreur sur SuppressionTable #TCLEDA"
     goto ErreurCAC
   end



---------------------------------------------------------
-- #temp - Cumul sur la clef
---------------------------------------------------------
insert #temp ( ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, TYPE, acmtrs_ll, ced_nf, uworg_cf,
               ssd_cf, cur_cf, MTOR, retctrcat_cf, seg_nf, CTRORI_CF, esb_cf,
               TRNTYP_CT,  -- [009]
               colval_lm)  -- [SPOT17610]
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, TYPE,  acmtrs_ll, ced_nf, uworg_cf,
       ssd_cf, cur_cf, sum(amt_m), retctrcat_cf , seg_nf, CTRORI_CF, esb_cf,
       TRNTYP_CT,          -- [009]
       colval_lm           -- [SPOT17610]
from #temp0
group by ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, TYPE, acmtrs_ll, ced_nf, uworg_cf, ssd_cf, cur_cf , retctrcat_cf , seg_nf, CTRORI_CF, esb_cf,
         TRNTYP_CT,         -- [009]
         colval_lm          -- [SPOT17610]
order by ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, TYPE, acmtrs_ll, ced_nf, uworg_cf, ssd_cf, cur_cf , retctrcat_cf , seg_nf, CTRORI_CF, esb_cf,
         TRNTYP_CT,         -- [009]
         colval_lm          -- [SPOT17610]

if @@error != 0
   begin
     Select @MsgErreur="2030. Erreur sur Création Table #TEMP"
     goto ErreurCAC
   end

drop table #temp0

if @@error != 0
   begin
     Select @MsgErreur="2050. Erreur sur Suppression Table #TEMP0 - BTRT CONTRT"
     goto ErreurCAC
   end

---------------------------------------------------------
-- Selection Taux de Changes
---------------------------------------------------------
If (@Taux = 'TXM')                       -- SPOT 15168 on utilise le parametre pour choisir la table des taux
        Begin
         /* Adaptive Server has expanded all '*' elements in the following statement */ select bref..taverate.SSD_CF, bref..taverate.CUR_CF, bref..taverate.EXC_D, bref..taverate.EXC_R, bref..taverate.EXCTYP_CF, bref..taverate.EXCORI_CF, bref..taverate.ACTCOD_B, bref..taverate.LSTUPDUSR_CF, bref..taverate.TIMESTAMP, bref..taverate.LSTUPD_D         into #taverate
         from bref..taverate                      -- SPOT 15149 on utilise taverate
         where convert ( char (8), exc_d, 112)  = @DateTCurquot
         and ssd_cf in (1, 2, 3, 5, 6, 7, 17)           --  SPOT 14170 filiale  05 07   14170/2 filiale 6 pour 3T 2007    +  [SPOT16438] ajout filiale 17

         if @@error != 0
            begin
              Select @MsgErreur="2070. Erreur sur Sélection Taux de Change #taverate"
              goto ErreurCAC
            end

--        End

           ---------------------------------------------------------
           -- Maj #temp - Conversion montant monnaie filiale
           ---------------------------------------------------------
           set arithabort numeric_truncation off
           update #temp
           set MTOR = MTOR * exc_r
           from #temp a, #taverate b
           where
           (a.cur_cf = b.cur_cf and a.ssd_cf = b.ssd_cf)         -- conversion dans la devise de la filiale
           set arithabort numeric_truncation on

           if @@error != 0
              begin
                Select @MsgErreur="2080. Erreur sur Conversion Monnaire Filliale #temp - #taverate"
                goto ErreurCAC
              end

           drop table #taverate

           if @@error != 0
              begin
                Select @MsgErreur="2090. Erreur sur Suppression Table #taverate"
                goto ErreurCAC
              end

          End

If (@Taux = 'TXC')                       -- SPOT 15168 on utilise le parametre pour choisir la table des taux
        Begin
         /* Adaptive Server has expanded all '*' elements in the following statement */ select bref..tcurquot.SSD_CF, bref..tcurquot.CUR_CF, bref..tcurquot.EXC_D, bref..tcurquot.EXC_R, bref..tcurquot.EXCTYP_CF, bref..tcurquot.EXCORI_CF, bref..tcurquot.ACTCOD_B, bref..tcurquot.LSTUPDUSR_CF, bref..tcurquot.timestamp, bref..tcurquot.LSTUPD_D         into #tcurquot
         from bref..tcurquot                     -- SPOT 15149 on utilise  tcurquot
         where convert ( char (8), exc_d, 112)  = @DateTCurquot
         and ssd_cf in (1, 2, 3, 5, 6, 7, 17)           --  SPOT 14170 filiale  05 07   14170/2 filiale 6 pour 3T 2007   +  [SPOT16438] ajout filiale 17

         if @@error != 0
            begin
              Select @MsgErreur="2070. Erreur sur Sélection Taux de Change #tcurquot"
              goto ErreurCAC
            end

--        End

           ---------------------------------------------------------
           -- Maj #temp - Conversion montant monnaie filiale
           ---------------------------------------------------------
           set arithabort numeric_truncation off
           update #temp
           set MTOR = MTOR * exc_r
           from #temp a, #tcurquot b
           where
           (a.cur_cf = b.cur_cf and a.ssd_cf = b.ssd_cf)         -- conversion dans la devise de la filiale
           set arithabort numeric_truncation on

           if @@error != 0
              begin
                Select @MsgErreur="2080. Erreur sur Conversion Monnaire Filliale #temp - #tcurquot"
                goto ErreurCAC
              end

           drop table #tcurquot

           if @@error != 0
              begin
                Select @MsgErreur="2090. Erreur sur Suppression Table #tcurquot"
                goto ErreurCAC
              end

          End
---------------------------------------------------------
-- #ced - ced_nf pas tout le temps renseigne
-- on le met a jour quand ced_nf = NULL
-- #ced = table des CTR/CED avec CED renseigne
---------------------------------------------------------
if object_id('#ced') is not null
	drop table #ced

select distinct CTR_NF, SEC_NF, UWY_NF, CED_NF
into #ced
from #temp
where CED_NF is not NULL
and   CTR_NF is NOT NULL

IF EXISTS (SELECT * FROM sysindexes
     WHERE id=OBJECT_ID('#ced') AND name='I_ced_00')
BEGIN
    DROP INDEX #ced.I_ced_00
END
CREATE CLUSTERED INDEX I_ced_00
    ON #ced(CTR_NF, SEC_NF, UWY_NF)


---------------------------------------------------------
-- Maj #temp de CED_NF
---------------------------------------------------------
update #temp
set ced_nf = b.CED_NF
from #temp a, #ced b
where a.CTR_NF = b.CTR_NF
and   a.SEC_NF = b.SEC_NF
and   a.UWY_NF = b.UWY_NF
and  a.CED_NF = NULL

update #temp
set ced_nf = b.CED_NF
from #temp a, btrt..tcontr b
where a.CTR_NF = b.CTR_NF
and   a.UWY_NF = b.UWY_NF
and  a.CED_NF = NULL

update #temp
set ced_nf = b.CED_NF
from #temp a, bfac..tcontr b
where a.CTR_NF = b.CTR_NF
and   a.UWY_NF = b.UWY_NF
and  a.CED_NF = NULL

---------------------------------------------------------
-- drop #ced
---------------------------------------------------------
drop table #ced


---------------------------------------------------------
-- Maj #temp - determination des types
---------------------------------------------------------

-- TYPE 1
-- Hors H20, hors SOREMA et hors filiales
update #temp
set TYPE = 1
where (uworg_cf <> 86 or uworg_cf is null)
and retctrcat_cf <> '02'
and CTRORI_CF <> "78"
and (ced_nf is null or ced_nf not in
(12040, 21115, 21399, 22231, 30132, 31081, 40237, 40608, 50157, 60018, 70130, 70131,
70132, 70133, 70147, 70210, 70466, 71080, 71851, 76572, 80001, 80077, 90435, 90696,
91126, 91190, 91670, 91977))

if @@error != 0
   begin
     Select @MsgErreur="2100. Erreur sur Update #temp TYPE = 1"
     goto ErreurCAC
   end

-- TYPE 2
-- H20 et hors filiales
update #temp
set TYPE = 2
where uworg_cf = 86
and retctrcat_cf <> '02'
and CTRORI_CF <> "78"
and (ced_nf is null or ced_nf not in
(12040, 21115, 21399, 22231, 30132, 31081, 40237, 40608, 50157, 60018, 70130, 70131,
70132, 70133, 70147, 70210, 70466, 71080, 71851, 76572, 80001, 80077, 90435, 90696,
91126, 91190, 91670, 91977))

if @@error != 0
   begin
     Select @MsgErreur="2110. Erreur sur Update #temp TYPE = 2"
     goto ErreurCAC
   end

-- TYPE 3
-- H20 avec filiales
update #temp
set TYPE = 3
where uworg_cf = 86
and retctrcat_cf <> '02'
and CTRORI_CF <> "78"
and ced_nf in
(12040, 21115, 21399, 22231, 30132, 31081, 40237, 40608, 50157, 60018, 70130, 70131,
70132, 70133, 70147, 70210, 70466, 71080, 71851, 76572, 80001, 80077, 90435, 90696,
91126, 91190, 91670, 91977)

if @@error != 0
   begin
     Select @MsgErreur="2120. Erreur sur Update #temp TYPE = 3"
     goto ErreurCAC
   end

-- TYPE 4
-- Hors H20, hors SOREMA avec filiales
update #temp
set TYPE = 4
where (uworg_cf <> 86 or uworg_cf is null)
and retctrcat_cf <> '02'
and CTRORI_CF <> "78"
and ced_nf in
(12040, 21115, 21399, 22231, 30132, 31081, 40237, 40608, 50157, 60018, 70130, 70131,
70132, 70133, 70147, 70210, 70466, 71080, 71851, 76572, 80001, 80077, 90435, 90696,
91126, 91190, 91670, 91977)

if @@error != 0
   begin
     Select @MsgErreur="2130. Erreur sur Update #temp TYPE = 4"
     goto ErreurCAC
   end


-- TYPE 5
-- Couvertures hors SOREMA
update #temp
set TYPE = 5
where retctrcat_cf = '02'

-- TYPE 6
-- Ex SOREMA hors filiales
update #temp
set TYPE = 6
where retctrcat_cf <> '02'
and CTRORI_CF = "78"
and ced_nf in
(12040, 21115, 21399, 22231, 30132, 31081, 40237, 40608, 50157, 60018, 70130, 70131,
70132, 70133, 70147, 70210, 70466, 71080, 71851, 76572, 80001, 80077, 90435, 90696,
91126, 91190, 91670, 91977)

if @@error != 0
   begin
     Select @MsgErreur="2140. Erreur sur Update #temp TYPE = 6"
     goto ErreurCAC
   end


-- TYPE 7
-- Ex SOREMA avec filiales
update #temp
set TYPE = 7
where retctrcat_cf <> '02'
and CTRORI_CF = "78"
and (ced_nf is null or ced_nf not in
(12040, 21115, 21399, 22231, 30132, 31081, 40237, 40608, 50157, 60018, 70130, 70131,
70132, 70133, 70147, 70210, 70466, 71080, 71851, 76572, 80001, 80077, 90435, 90696,
91126, 91190, 91670, 91977))

if @@error != 0
   begin
     Select @MsgErreur="2150. Erreur sur Update #temp TYPE = 7"
     goto ErreurCAC
   end




-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--   PARTIE 3
-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

---------------------------------------------------------
-- #temp1 - Cumul
---------------------------------------------------------
select ssd_cf, ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, TYPE, acmtrs_ll, MT=sum(MTOR), seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
into #temp1
from #temp
group by ssd_cf, ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, TYPE, acmtrs_ll  , seg_nf, esb_cf,
         TRNTYP_CT,  -- [009]
         colval_lm   -- [SPOT17610]
order by ssd_cf, ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, TYPE, acmtrs_ll  , seg_nf, esb_cf,
         TRNTYP_CT,  -- [009]
         colval_lm   -- [SPOT17610]

if @@error != 0
   begin
     Select @MsgErreur="3010. Erreur sur Création #temp1 "
     goto ErreurCAC
   end

drop table #temp
if @@error != 0
   begin
     Select @MsgErreur="3020. Erreur sur Suppression #temp"
     goto ErreurCAC
   end


---------------------------------------------------------
-- #temp2 - Par type de poste
---------------------------------------------------------
set arithabort numeric_truncation off
insert #temp2
      (ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, CHARGES, seg_nf, esb_cf,
       TRNTYP_CT,   -- [009]
       colval_lm)   -- [SPOT17610]
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT     , seg_nf, esb_cf,
       TRNTYP_CT,   -- [009]
       colval_lm    -- [SPOT17610]
from #temp1
where acmtrs_ll = "CHARGES"

if @@error != 0
   begin
     Select @MsgErreur="3030. Erreur sur Insertion #temp2 - CHARGES "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    COURTAGE,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]

from #temp1
where acmtrs_ll = "COURTAGE"

if @@error != 0
   begin
     Select @MsgErreur="3040. Erreur sur Insertion #temp2 - COURTAGE "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    FAR,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "FAR"

if @@error != 0
   begin
     Select @MsgErreur="3050. Erreur sur Insertion #temp2 - FAR "
     goto ErreurCAC
   end


insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    IBNR2,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "IBNR2"

if @@error != 0
   begin
     Select @MsgErreur="3060. Erreur sur Insertion #temp2 - IBNR2 "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    PB,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "PB"

if @@error != 0
   begin
     Select @MsgErreur="3070. Erreur sur Insertion #temp2 - PB "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    PNA,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT , seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "PNA"

if @@error != 0
   begin
     Select @MsgErreur="3080. Erreur sur Insertion #temp2 - PNA "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    PRIMES,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "PRIMES"

if @@error != 0
   begin
     Select @MsgErreur="3090. Erreur sur Insertion #temp2 - PRIMES "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    PROVSIN,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "PROVSIN"

if @@error != 0
   begin
     Select @MsgErreur="3100. Erreur sur Insertion #temp2 - PROVSIN "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    PVEQ,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "PVEQ"

if @@error != 0
   begin
     Select @MsgErreur="3110. Erreur sur Insertion #temp2 - PVEQ "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    RFAR,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "RFAR"

if @@error != 0
   begin
     Select @MsgErreur="3120. Erreur sur Insertion #temp2 - RFAR "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    RIBNR2,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "RIBNR2"

if @@error != 0
   begin
     Select @MsgErreur="3130. Erreur sur Insertion #temp2 - RIBNR2 "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    RPNA,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,    -- [009]
       colval_lm     -- [SPOT17610]
from #temp1
where acmtrs_ll = "RPNA"

if @@error != 0
   begin
     Select @MsgErreur="3140. Erreur sur Insertion #temp2 - RPNA "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    RPROVSIN,
    seg_nf,
    esb_cf,
    TRNTYP_CT,           -- [009]
    colval_lm            -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,        -- [009]
       colval_lm         -- [SPOT17610]
from #temp1
where acmtrs_ll = "RPROVSIN"

if @@error != 0
   begin
     Select @MsgErreur="3150. Erreur sur Insertion #temp2 - RPROVSIN "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    RPVEQ,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,        -- [009]
       colval_lm         -- [SPOT17610]
from #temp1
where acmtrs_ll = "RPVEQ"

if @@error != 0
   begin
     Select @MsgErreur="3160. Erreur sur Insertion #temp2 - RPVEQ "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    RSNEM,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,        -- [009]
       colval_lm         -- [SPOT17610]
from #temp1
where acmtrs_ll = "RSNEM"

if @@error != 0
   begin
     Select @MsgErreur="3170. Erreur sur Insertion #temp2 - RSNEM "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    SINP,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,        -- [009]
       colval_lm         -- [SPOT17610]
from #temp1
where acmtrs_ll = "SINP"

if @@error != 0
   begin
     Select @MsgErreur="3180. Erreur sur Insertion #temp2 - SINP "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    SNEM,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,        -- [009]
       colval_lm         -- [SPOT17610]
from #temp1
where acmtrs_ll = "SNEM"

if @@error != 0
   begin
     Select @MsgErreur="3190. Erreur sur Insertion #temp2 - SNEM "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    RFRAGES,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)

select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,        -- [009]
       colval_lm         -- [SPOT17610]
from #temp1
where acmtrs_ll = "RFRAGES"

if @@error != 0
   begin
     Select @MsgErreur="3200. Erreur sur Insertion #temp2 - RFRAGES "
     goto ErreurCAC
   end

insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    FGESCLO,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,        -- [009]
       colval_lm         -- [SPOT17610]
from #temp1
where acmtrs_ll = "FGESCLO"
set arithabort numeric_truncation on

if @@error != 0
   begin
     Select @MsgErreur="3210. Erreur sur Insertion #temp2 - FGESCLO "
     goto ErreurCAC
   end


insert #temp2
(
    ctr_nf,
    sec_nf,
    uwy_nf,
    ctrnat_ct,
    lobacc_cf,
    ssd_cf,
    TYPE,
    PBSURRET,
    seg_nf,
    esb_cf,
    TRNTYP_CT,       -- [009]
    colval_lm        -- [SPOT17610]
)
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, MT, seg_nf, esb_cf,
       TRNTYP_CT,        -- [009]
       colval_lm         -- [SPOT17610]
from #temp1
where acmtrs_ll = "PBSURRET"

if @@error != 0
   begin
     Select @MsgErreur="3211. Erreur sur Insertion #temp2 - PBSURRET "
     goto ErreurCAC
   end

-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--   PARTIE 4
-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

---------------------------------------------------------
-- VERIFICATION #temp1 = #temp2
---------------------------------------------------------

Select @NbLineTemp1 = count(*) from #temp1
Select @NbLineTemp2 = count(*) from #temp2

select ' '
select ' '
select ' '
select '******************************************* '
select '*  Vérification  Temp1 & Temp2            * '
select '******************************************* '
select '*'
select '*   Nombre de Lignes dans #Temp1 = ', @NbLineTemp1
select '*   Nombre de Lignes dans #Temp2 = ', @NbLineTemp2
select '*'
select '*-----------------------------------------* '
select ' '

 If (@NbLineTemp1 != @NbLineTemp2)
 Begin
     select '*   ATTENTION  sur Vérification  T1 & T2 ! '
     select '*-----------------------------------------* '
     -- Select @MsgErreur="Erreur sur Vérification Lignes #Temp1 et #Temp2"
    goto ErreurCAC
 End
Else
 Begin
    select '*            Vérification OK              * '
    select '*-----------------------------------------* '
 End
select ' '
select ' '


-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--   PARTIE 5
-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

---------------------------------------------------------
-- SI VERIFICATION #temp1 = #temp2 OK
---------------------------------------------------------
drop table #temp1

if @@error != 0
   begin
     Select @MsgErreur="5000. Erreur sur Suppression #temp1 "
     goto ErreurCAC
   end


---------------------------------------------------------
-- #temp2 - Par type de poste
---------------------------------------------------------
if object_id('#temp3') is not null
	drop table #temp3
select ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, seg_nf, esb_cf,
       TRNTYP_CT,   -- [009]
       colval_lm,   -- [SPOT17610]
CHARGES= sum(CHARGES),
COURTAGE = sum(COURTAGE),
FAR=sum(FAR),
IBNR2=sum(IBNR2),
PB= sum(PB),
PNA=sum(PNA),
PRIMES=sum(PRIMES),
PROVSIN=sum(PROVSIN),
PVEQ=sum(PVEQ),
RFAR=sum(RFAR),
RIBNR2=sum(RIBNR2),
RPNA=sum(RPNA),
RPROVSIN=sum(RPROVSIN),
RPVEQ=sum(RPVEQ),
RSNEM=sum(RSNEM),
SINP=sum(SINP),
SNEM=sum(SNEM),
RFRAGES=sum(RFRAGES),
PBSURRET=sum(PBSURRET),
FGESCLO=sum(FGESCLO)
into #temp3
from #temp2
group by ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, seg_nf, esb_cf,
         TRNTYP_CT,       -- [009]
         colval_lm        -- [SPOT17610]
order by ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, TYPE, seg_nf, esb_cf,
         TRNTYP_CT,       -- [009]
         colval_lm        -- [SPOT17610]

if @@error != 0
   begin
     Select @MsgErreur="5010. Erreur sur Insertion #temp3 "
     goto ErreurCAC
   end


drop table #temp2
if @@error != 0
   begin
     Select @MsgErreur="5020. Erreur sur Suppression #temp2 "
     goto ErreurCAC
   end


-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--   PARTIE 6
-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
Select @NbLineTemp3 = count(*) from #temp3
select '*   Nb Lignes dans #Temp3 ..................... = ', @NbLineTemp3


--------------------------------------------------------------------------------------
-- Création des Enregistrements dans la BTRAVI..EST_ESID7100_ETATCACR
--------------------------------------------------------------------------------------
Truncate TABLE BTRAVI..EST_ESID7100_ETATCACR

if @@error != 0
   begin
     Select @MsgErreur="6010. Erreur sur Truncate BTRAVI..EST_ESID7100_ETATCACR"
     goto ErreurCAC
   end


Insert into BTRAVI..EST_ESID7100_ETATCACR
(ctr_nf, sec_nf, uwy_nf, ctrnat_ct, lobacc_cf, ssd_cf, esb_cf, TYPE, seg_nf, CHARGES,
COURTAGE, FAR, IBNR2, PB, PNA, PRIMES, PROVSIN, PVEQ, RFAR, RIBNR2, RPNA, RPROVSIN,
RPVEQ, RSNEM, SINP, SNEM, RFRAGES, PBSURRET, FGESCLO,
TRNTYP_CT,   -- [009]
colval_lm    -- [SPOT17610]
)
SELECT
ctr_nf,
sec_nf,
uwy_nf,
ctrnat_ct,
lobacc_cf,
ssd_cf,
esb_cf,   -- [SPOT16159]
TYPE,
seg_nf,
CHARGES,COURTAGE,FAR,IBNR2,PB,PNA,PRIMES,PROVSIN,PVEQ,RFAR,RIBNR2,RPNA,
RPROVSIN,RPVEQ,RSNEM,SINP,SNEM,RFRAGES,PBSURRET,FGESCLO,
TRNTYP_CT,   -- [009]
colval_lm    -- [SPOT17610]
from #temp3

if @@error != 0
   begin
     Select @MsgErreur="6020. Erreur sur Insertion BTRAVI..EST_ESID7100_ETATCACR"
     goto ErreurCAC
   end


-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--   PARTIE 7
-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

--------------------------------------------------------------------------------------
-- VERIFICATION #temp3 = BTRAVI..EST_ESID7100_ETATCACR
--------------------------------------------------------------------------------------

Select @NbLineTemp4 = count(*) from BTRAVI..EST_ESID7100_ETATCACR

select ' '
select ' '
select ' '
select '******************************************************************* '
select '*         Vérification  Temp3 & BTRAVI..EST_ESID7100_ETATCACR     * '
select '******************************************************************* '
select '*   Nb Lignes dans #Temp3....................... = ', @NbLineTemp3
select '*   Nb Lignes dans BTRAVI..EST_ESID7100_ETATCACR = ', @NbLineTemp4
select '*-----------------------------------------------------------------* '
select ' '

If (@NbLineTemp3 != @NbLineTemp4)
    Begin
        select '*          ATTENTION! Temp3 & BTRAV Différent                     * '
        select '*-----------------------------------------------------------------* '
    End
Else
    Begin
        select '*                       Vérification OK                           * '
        select '*-----------------------------------------------------------------* '
    End

select ' '
select ' '


-- SI VERIFICATION #temp3 = #temp2 OK

drop table #temp3
if @@error != 0
   begin
     Select @MsgErreur="7010. Erreur sur Suppression #temp3"
     goto ErreurCAC
   end


select '******************************************************************** '
select "* Sélection Filiales/Tranches d'Exercices de EST_ESID7100_ETATCACR * "
select '******************************************************************** '

select '* ', "Filiale : ", ssd_cf,  " - Exercice : ", uwy_nf,  " - Nb Lignes = ", count (*)
from BTRAVI..EST_ESID7100_ETATCACR
group by ssd_cf, uwy_nf
order by ssd_cf, uwy_nf
select '******************************************************************* '

-- ----------------------------------------------------------------------------------- --
-- PARTIE 8                                                                            --
--    Backup de BTRAVI..EST_ESID7100_ETATCACR vers :                                    --
--       . Si Retro avec Taux = "TXC" => BTRAVI..EST_ESID7100_ETATCAC_RETRO_TXC --
--       . Si Retro avec Taux = "TXM" => BTRAVI..EST_ESID7100_ETATCAC_RETRO_TXM --
-- ----------------------------------------------------------------------------------- --

-- 08.1 - Nettoyage de la BTRAV de réception avant backup des données --
IF @Taux = 'TXC'
BEGIN
   DELETE
     FROM BTRAVI..EST_ESID7100_ETATCAC_RETRO_TXC
END

IF @Taux = 'TXM'
BEGIN
   DELETE
     FROM BTRAVI..EST_ESID7100_ETATCAC_RETRO_TXM
END

-- 08.2 - Backup des données --
IF @Taux = 'TXC'
BEGIN
   INSERT INTO BTRAVI..EST_ESID7100_ETATCAC_RETRO_TXC
        SELECT *
          FROM BTRAVI..EST_ESID7100_ETATCACR
END

IF @Taux = 'TXM'
BEGIN
   INSERT INTO BTRAVI..EST_ESID7100_ETATCAC_RETRO_TXM
        SELECT *
          FROM BTRAVI..EST_ESID7100_ETATCACR
END

-- --- --
-- Fin --
-- --- --
goto fin


ErreurCAC:
    Select "Erreur : " , @MsgErreur
    Raiserror 20020
    return 1

fin:
return 0

go
EXEC sp_procxmode 'dbo.PsETATCAC_03','unchained'
go
IF OBJECT_ID('dbo.PsETATCAC_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsETATCAC_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsETATCAC_03 >>>'
go
GRANT EXECUTE ON dbo.PsETATCAC_03 TO GOMEGA
go
