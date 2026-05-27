/** Alter Procedure Script **/

use BEST
go

drop procedure dbo.PiTLIFPLN_02_O2
go

/* Adaptive Server has expanded all '*' elements in the following statement */ create procedure dbo.PiTLIFPLN_02_O2
(
	@p_ssd_cf	USSD_CF,
	@p_usr_cf	UUSR_CF,
	@p_batch_mode UL16 = NULL
)
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: P.-E. Marx (Capgemini)
Date de creation: 23/02/2015
Description du programme:
---------------------------
Contrôles de cohérences lors du chargement massif par fichier d'écritures de service plan.
Si tout est OK, INSERTion des lignes ds BEST..TLIFPLN.
Fonctionnement de la proc :
----------------------------
Pour repérer les anomalies, on remplit une table tempo à partir de btrav..TESTLIFPLN
et de la requête correspondant aux règles que doivent suivre les mouvements.
Un écart du nombre de lignes indique que certains mouvements sont en anomalies et
il y a débranchement sur la fin de la proc pour remplir la table des anos.
Description générale:
------------------------
( libellés visibles ds TBANTECL : COL_LS = ANO_CT )
    - mise a jour automatique des infos tiers
    - mise a jour du poste de contrepartie
    - mise a jour de l'année de survenance retro a partir exercice retro
         si partie retro renseignée et année de survenance retro non renseignée
    - ajout du num de ligne ds la table TCTRANO

Au niveau de l'appli, on a déjà un ens de contrôles vérifiant si lorsqu'une info acceptation est saisie,
le contrat l'est également (idem coté rétro) + d'autres vérifiant que les champs obligatoires sont bien présents.

_________________
Modification  - Quarterly Upload 
Author: TDE
Date: 29/10/2018
Description: Prevent loading on No Estimate contract and Quarterly Contract
_________________
Modification [02] - type in TCTRANO_TMP 
Author: R Vieville
Date: 08/01/2019
Description: wrong type on ANO_CT in temporary table TCTRANO (tinyint -> int)
_________________
Modification [03] : SPIRA - 74536 - UPload Photoplan - list of errors not displayed
Date              : 07/03/2019
Author            : B.LAGHA
Description       : Ajout d'un controle afin de verifier si un contrat dont l'UWY existe ou pas en BDD.
_________________
Modification [04] : SPIRA - 74536 - UPload Photoplan - list of errors not displayed
Date              : 14/08/2020
Author            : B.LAGHA
Description       : Il faut pouvoir charger des ajustements plan sur les exercices fictifs

********************************************************************************************************************************************************/
declare @erreur     	int,
		@error_type		int,
        @tran_imbr		bit,
        @MsgAnomalie    varchar(120),
        @NumMsgAnomalie    varchar(120),      -- Numéros des Erreurs Rencontrées
        @MsgGlobalAnomalie    varchar(240),   -- Anomalies GLobales Rencontrées
		@cre_d			datetime,	/* date du jour */
		@spcend_d		datetime,	/* variable en sortie de PsCALEND_02 */
		@account_d		datetime,	/* variable en sortie de PsCALEND_02 */
		@closing_b		bit,		/* variable en sortie de PsCALEND_02 */
		@nbligne_teslifpln	int,		/* nbre lignes de la table utilisateurs en entrée */
		@nbligne_templifpln	int,		/* nbre lignes en sortie de traitement */
		@nbligne_tctrano	int,		/* nbre lignes en Anomalies */
		@max_trn_nt		numeric( 10, 0 ), /* numéro d'écriture maxi de BEST..TLIFPLN */
		@max_plan_nf    int -- Année de plan max pour controle

select @erreur = 0
select @tran_imbr = 1
select @cre_d = getdate()
select @error_type = -1
select @MsgAnomalie = ""
select @NumMsgAnomalie = " - Autres Anomalies Trouvées N° "


/* ------------------------------------------------------------
   Création des tables temporaires
 -------------------------------------------------------------- */

create table #TLIFPLN1 (
	TRN_NT			numeric(10,0)	NULL,
	ACCTYP_NF		tinyint	NULL,
	SSD_CF			USSD_CF	NULL,
	ESB_CF			UESB_CF	NULL,
	PLAN_NF			numeric(10, 0)	NULL,
	BALSHEY_NF		UUWY_NF	NULL,
	BALSHRMTH_NF	tinyint	NULL,
	BALSHRDAY_NF	tinyint	NULL,
	TRNCOD_CF		UDETTRS_CF	NULL,
	DBLTRNCOD_CF	UDETTRS_CF	NULL,
	CTR_NF			UCTR_NF	NULL,
	END_NT			UEND_NT	NULL,
	SEC_NF			USEC_NF	NULL,
	UWY_NF			UUWY_NF	NULL,
	UW_NT			UUW_NT	NULL,
	OCCYEA_NF		UUWY_NF	NULL,
	ACY_NF			UUWY_NF	NULL,
	SCOSTRMTH_NF	tinyint	NULL,
	SCOENDMTH_NF	tinyint	NULL,
	CUR_CF			UCUR_CF	NULL,
	AMT_M			UAMT_M		NULL,
	CED_NF			UCLI_NF	NULL,
	BRK_NF			UCLI_NF	NULL,
	GEMPRMPAY_NF	UCLI_NF	NULL,
	GANPAYORD_NT	UPAYORD_NT	NULL,
	RETCTR_NF		URETCTR_NF	NULL,
	RETEND_NT		UEND_NT	NULL,
	RETSEC_NF		URETSEC_NF	NULL,
	RTY_NF			UUWY_NF	NULL,
	RETUW_NT		UUW_NT	NULL,
	PLC_NT			UPLC_NT	NULL,
	RETOCCYEA_NF	UUWY_NF	NULL,
	RETACY_NF		UUWY_NF	NULL,
	RETSCOSTRMTH_NF	tinyint	NULL,
	RETSCOENDMTH_NF	tinyint	NULL,
	RETCUR_CF		UCUR_CF	NULL,
	RETAMT_M		UAMT_M	NULL,
	RTO_NF			UCLI_NF	NULL,
	INT_NF			UCLI_NF	NULL,
	RETPAY_NF		UCLI_NF	NULL,
	RETKEY_CF		char(1)	NULL,
	COMMAC_LL		UL64		  NULL,
	CRE_D			UUPD_D		  NULL,
	CREUSR_CF		UUPDUSR_CF	  NULL,
	LSTUPD_D		UUPD_D		  NULL,
	LSTUPDUSR_CF	UUPDUSR_CF	  NULL,
	POSTBPC_B		bit		default 0	NOT NULL,
	NUMLINE_NT		int		NULL
)

create table #TLIFPLN2 (
	TRN_NT			numeric(10,0)	NULL,
	ACCTYP_NF		tinyint	NULL,
	SSD_CF			USSD_CF	NULL,
	ESB_CF			UESB_CF	NULL,
	PLAN_NF			numeric(10, 0)	NULL,
	BALSHEY_NF		UUWY_NF	NULL,
	BALSHRMTH_NF	tinyint	NULL,
	BALSHRDAY_NF	tinyint	NULL,
	TRNCOD_CF		UDETTRS_CF	NULL,
	DBLTRNCOD_CF	UDETTRS_CF	NULL,
	CTR_NF			UCTR_NF	NULL,
	END_NT			UEND_NT	NULL,
	SEC_NF			USEC_NF	NULL,
	UWY_NF			UUWY_NF	NULL,
	UW_NT			UUW_NT	NULL,
	OCCYEA_NF		UUWY_NF	NULL,
	ACY_NF			UUWY_NF	NULL,
	SCOSTRMTH_NF	tinyint	NULL,
	SCOENDMTH_NF	tinyint	NULL,
	CUR_CF			UCUR_CF	NULL,
	AMT_M			UAMT_M		NULL,
	CED_NF			UCLI_NF	NULL,
	BRK_NF			UCLI_NF	NULL,
	GEMPRMPAY_NF	UCLI_NF	NULL,
	GANPAYORD_NT	UPAYORD_NT	NULL,
	RETCTR_NF		URETCTR_NF	NULL,
	RETEND_NT		UEND_NT	NULL,
	RETSEC_NF		URETSEC_NF	NULL,
	RTY_NF			UUWY_NF	NULL,
	RETUW_NT		UUW_NT	NULL,
	PLC_NT			UPLC_NT	NULL,
	RETOCCYEA_NF	UUWY_NF	NULL,
	RETACY_NF		UUWY_NF	NULL,
	RETSCOSTRMTH_NF	tinyint	NULL,
	RETSCOENDMTH_NF	tinyint	NULL,
	RETCUR_CF		UCUR_CF	NULL,
	RETAMT_M		UAMT_M	NULL,
	RTO_NF			UCLI_NF	NULL,
	INT_NF			UCLI_NF	NULL,
	RETPAY_NF		UCLI_NF	NULL,
	RETKEY_CF		char(1)	NULL,
	COMMAC_LL		UL64		  NULL,
	CRE_D			UUPD_D		  NULL,
	CREUSR_CF		UUPDUSR_CF	  NULL,
	LSTUPD_D		UUPD_D		  NULL,
	LSTUPDUSR_CF	UUPDUSR_CF	  NULL,
	POSTBPC_B		bit		default 0	NOT NULL,
	NUMLINE_NT		int		NULL
	 )

CREATE TABLE #TCTRANO_TMP
(
    CTR_NF     UCTR_NF       NULL,
    END_NT     UEND_NT       NULL,
    SEC_NF     USEC_NF       NULL,
    VRS_NF     numeric(10,0) NULL,
    SSD_CF     USSD_CF       NULL,
    SEGTYP_CT  USEGTYP_CT    DEFAULT '' NULL,
    SEG_NF     USEG_NF       DEFAULT '' NULL,
    ANO_CT     int       	 DEFAULT 0 NULL, -- [02] change tinyint to in for ANO_CT
    NUMLINE_NT int           DEFAULT 0 NULL
)

-- Suppression des lignes d'ano.

Execute BEST..PdCTRANO_06_O2 @p_ssd_cf,@p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Accès BEST..PdCTRANO_06_O2'
	goto ErreurNorm
    end


-- On supprime de btrav..EST_ESID0871_TESTLIFPLN toutes les lignes de filiale differente de la filiale
-- passée en paramètre, on ne doit normalement que très rarement tomber ds ce cas, cela signifie
-- que le user a saisi par erreur plusieurs filiales ds son fichier

DELETE btrav..EST_ESID0871_TESTLIFPLN
where SSD_CF      != @p_ssd_cf
and	LSTUPDUSR_CF = @p_usr_cf

-- *********************************************************************************************
-- Calcul et stockage du nombre de lignes de la table utilisateurs btrav..EST_ESID0871_TESTLIFPLN
-- **********************************************************************************************

select @nbligne_teslifpln = count(*) FROM btrav..EST_ESID0871_TESTLIFPLN
where
	SSD_CF       = @p_ssd_cf
and	LSTUPDUSR_CF = @p_usr_cf


-- *************************************************************************************
--
--          1ère ETAPE: MAJ AUTOMATIQUE DE CERTAINS CHAMPS
--
-- *************************************************************************************

UPDATE	btrav..EST_ESID0871_TESTLIFPLN
SET	CRE_D        = @cre_d,
	LSTUPD_D     = @cre_d,
	CREUSR_CF    = @p_usr_cf
FROM	btrav..EST_ESID0871_TESTLIFPLN
where 	SSD_CF       = @p_ssd_cf
and	    LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error

if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur MAJ btrav..EST_ESID0871_TESTLIFPLN - Date de Saisie"
	goto ErreurNorm
    end

-- accès à la table BTRT..TCONTR pour renseigner les infos accept
-- --------------------------------------------------------------

UPDATE btrav..EST_ESID0871_TESTLIFPLN
SET	SSD_CF = B.SSD_CF,
	ESB_CF = B.ACCESB_CF,
	CED_NF = B.CED_NF,
	BRK_NF = B.PRD_NF,
	GEMPRMPAY_NF = B.GENPRMPAY_NF,
	GANPAYORD_NT = B.GANPAYORD_NT
FROM	btrav..EST_ESID0871_TESTLIFPLN A,
        btrt..TCONTR B
where
    A.SSD_CF       = @p_ssd_cf
and	A.LSTUPDUSR_CF = @p_usr_cf
and	A.CTR_NF       = B.CTR_NF
and	A.END_NT       = B.END_NT
and	B.UWY_NF       = (select max(C.UWY_NF) from btrt..TCONTR C where C.UWY_NF <= A.UWY_NF and C.CTR_NF = A.CTR_NF)
and	A.UW_NT        = B.UW_NT

select @erreur = @@error
if @erreur != 0
    begin
      select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0871_TESTLIFPLN - Info Acceptation BTRT..TCONTR'
      goto ErreurNorm
    end

-- accès à la table BRET..TRETCTR pour renseigner les champs filiale, établissement
-- --------------------------------------------------------------------------------

UPDATE btrav..EST_ESID0871_TESTLIFPLN
SET	SSD_CF = B.SSD_CF,
	ESB_CF = B.ESB_CF
FROM	btrav..EST_ESID0871_TESTLIFPLN A,
        bret..TRETCTR B
where
    A.SSD_CF        = @p_ssd_cf
and	A.LSTUPDUSR_CF  = @p_usr_cf
and	A.RETCTR_NF     = B.RETCTR_NF
and	B.RTY_NF        = (select max(C.RTY_NF) from bret..TRETCTR C where C.RTY_NF <= A.RTY_NF and C.RETCTR_NF = A.RETCTR_NF)

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur MAJ btrav..EST_ESID0871_TESTLIFPLN - Info Contrats BRET..TRETCTR"
	goto ErreurNorm
    end

-- Maj par défaut de l'ex de survenance acceptation
-- ------------------------------------------------

UPDATE btrav..EST_ESID0871_TESTLIFPLN
SET	OCCYEA_NF = UWY_NF
where
    CTR_NF       != NULL
and OCCYEA_NF    = null
and SSD_CF       = @p_ssd_cf
and	LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = '"Erreur MAJ btrav..EST_ESID0871_TESTLIFPLN - Maj par défaut de l''ex de survenance acceptation'
	goto ErreurNorm
    end

-- Maj par défaut de l'exercice de survenance rétrocession
-- -------------------------------------------------------

UPDATE btrav..EST_ESID0871_TESTLIFPLN
SET	RETOCCYEA_NF = RTY_NF
where
    RETCTR_NF    != NULL
and RETOCCYEA_NF = null
and SSD_CF       = @p_ssd_cf
and	LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0871_TESTLIFPLN - Maj par défaut de l''ex de survenance rétro '
	goto ErreurNorm
    end

-- Maj infos tiers rétro
-- placements non historisés et comptables, valides (16)ou résiliés (19)
-- ---------------------------------------------------------------------

UPDATE btrav..EST_ESID0871_TESTLIFPLN
SET a.RTO_NF    = b.RTO_NF,
    a.INT_NF    = b.INT_NF,
      RETPAY_NF = PAY_NF,
	  RETKEY_CF = KEY_CF

FROM btrav..EST_ESID0871_TESTLIFPLN a,
     bret..TPLACEMT b
	 where
             a.RETCTR_NF != NULL
         and a.RETCTR_NF = b.RETCTR_NF
		 and a.RTY_NF    = b.RTY_NF
		 and a.PLC_NT    = b.PLC_NT
		 and HIS_B       = 0
		 and ACCPLC_B    = 1
  		 and (PLCSTS_CT  = 16 or PLCSTS_CT = 19)
         and A.SSD_CF    = @p_ssd_cf
         and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0871_TESTLIFPLN - Maj infos tiers rétro '
	goto ErreurNorm
    end

-- Maj poste de contrepartie
-- -------------------------

UPDATE btrav..EST_ESID0871_TESTLIFPLN
SET  DBLTRNCOD_CF = CTRSCOD_CF
FROM btrav..EST_ESID0871_TESTLIFPLN A,
     bref..TDETTRS B
where
    DETTRS_CF      = TRNCOD_CF
and A.SSD_CF       = @p_ssd_cf
and	A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0871_TESTLIFPLN - Maj poste de contrepartie'
	goto ErreurNorm
    end
	
-- Maj date bilan
-- --------------

UPDATE btrav..EST_ESID0871_TESTLIFPLN
SET a.BALSHEY_NF = b.BALSHEYEA_NF,
	a.BALSHRMTH_NF = b.BALSHTMTH_NF,
	a.BALSHRDAY_NF = 30
FROM btrav..EST_ESID0871_TESTLIFPLN a,
	 best..TREQJOB b
where
	a.SSD_CF = b.SSD_CF
and a.PLAN_NF = b.VRS_NF
and b.REQCOD_CT = 'A'

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0871_TESTLIFPLN - Maj date de bilan'
	goto ErreurNorm
    end
	


-- **********************************************************************************
--                                                                                  *
--                     2ème ETAPE: CONTROLES DE COHERENCE                           *
--    LES LIBELLES DES ANOS CI-DESSOUS SE TROUVENT DANS LA TABLE BREF..TBANTECL     *
--                  ILS SONT REFERENCES PAR "ANO_CT"                                *
--                                                                                  *
-- **********************************************************************************

-- -----------------------------------------------------------------------------
--                   CONTROLES DU POSTE COMPTABLE
--                   si pb ===> ano 33
-- -----------------------------------------------------------------------------
-- I - VERIFIER
-- Quand le contrat rétrocession est renseigné, même si on a de l'acceptation, le fichier contient un poste de type rétro.
INSERT into #TLIFPLN1
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
     A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
from BTRAV..EST_ESID0871_TESTLIFPLN A, BREF..TDETTRS B, BREF..TSUBTRS C
  where A.SSD_CF=@p_ssd_cf
    and    A.LSTUPDUSR_CF=@p_usr_cf
    and A.TRNCOD_CF=B.DETTRS_CF
     and C.PCPTRS_CF=SUBSTRING(A.TRNCOD_CF,3,2)
     and C.TRS_CF=SUBSTRING(A.TRNCOD_CF,5,1)
     and C.SUBTRS_CF=SUBSTRING(A.TRNCOD_CF,6,2)
    and B.OPN_B=1          -- poste open
    and ( ( C.TRSTYPE_CT != 4 and ( (CTR_NF!=NULL and RETCTR_NF in(NULL,'') and TRNCOD_CF like '[13][123]%[2ACEG]') -- Assumed "normal" TC
        or (RETCTR_NF!=NULL and TRNCOD_CF like '[24][123]%[2ACEG]') ) ) -- Retro "normal" TC
          or ( C.TRSTYPE_CT = 4 and ( (CTR_NF!=NULL and RETCTR_NF in(NULL,'') and TRNCOD_CF like '[13][25]%[02ACEG]') -- Assumed deposit TC
        or (RETCTR_NF!=NULL and TRNCOD_CF like '[24][25]%[02ACEG]') ) ) ) -- Retro deposit TC
           
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) aux  postes comptables"
     goto ErreurAno
end

delete #TLIFPLN1
from #TLIFPLN1 a
where TRNCOD_CF like '_[1-9]%'
   and not exists(select 1 from BREF..TDETTRS d, BREF..TSUBTRSESB s, BREF..TSUBTRS tc                     --MOD027
                   where d.dettrs_cf=a.TRNCOD_CF
                     and s.ssd_cf=a.SSD_CF
                     and s.ESB_CF=a.ESB_CF                                                 --MOD027
                     and d.pcptrs_cf=s.pcptrs_cf
                     and d.trs_cf=s.trs_cf
                     and d.subtrs_cf=s.subtrs_cf
                     and d.pcptrs_cf=tc.pcptrs_cf
                     and d.trs_cf=tc.trs_cf
                     and d.subtrs_cf=tc.subtrs_cf
                     and d.opn_b=1
                     and (tc.trstype_ct = 4 or d.dettrs_cf!=d.ctrscod_cf))
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) aux  postes comptables"
     goto ErreurAno
end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN1 */
/* génération d'une anomalie et sortie de la procédure, ANO 33   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN1
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0

if ( @nbligne_templifpln != @nbligne_teslifpln )
     begin
     select @error_type = 33
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '33 a '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and     LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and     LSTUPDUSR_CF = @p_usr_cf
     end

-- Purge de la table #TLIFPLN1 avant réutilisation
DELETE #TLIFPLN1

-- II - VERIFIER
-- Si le poste comptable est identique au poste de contrepartie, cela signifie que le poste comptable principal saisi est un poste de contre-partie
-- (rappel le poste de contre-partie est mis à jour dans la proc à l'aide de la table bref..TDETTRS)
--                   si pb ===> ano 50
-- Cette vérification interdit les postes bilan hors dépôts

INSERT INTO #TLIFPLN1
SELECT A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
     A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM btrav..EST_ESID0871_TESTLIFPLN A, BREF..TSUBTRS C
WHERE
        A.SSD_CF        = @p_ssd_cf
AND      A.LSTUPDUSR_CF   = @p_usr_cf
AND C.PCPTRS_CF         = SUBSTRING(A.TRNCOD_CF,3,2)
AND C.TRS_CF        = SUBSTRING(A.TRNCOD_CF,5,1)
AND C.SUBTRS_CF     = SUBSTRING(A.TRNCOD_CF,6,2)
AND ( C.TRSTYPE_CT  = 4 OR
           A.TRNCOD_CF != A.DBLTRNCOD_CF )   -- le poste principal doit toujours être différent du poste de contre-partie pour les non dépots


select @nbligne_templifpln = count(*) FROM #TLIFPLN1
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0

if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	select @error_type = 50
    select @MsgAnomalie = 'Anomalie(s) liee(s) au poste comptable principal = poste de contre-partie'
    select @NumMsgAnomalie = @NumMsgAnomalie + '50 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end


/************************************************************************************
**                           CHECKING EXISTENCE OF UWY                             ** 
**                           if problem => anomaly 106                             **
**                               AUTHOR : B.LAIGHA                                 **
************************************************************************************/
--                           MODIFICATION [03] START                               --
-------------------------------------------------------------------------------------
-- Purge de la table #TLIFPLN1 avant réutilisatin --
-----------------------------------------------------
DELETE #TLIFPLN1

-- MODIFICATION [04] START 
select @max_plan_nf = max(CAST(SUBSTRING(CAST(VRS_NF AS VARCHAR(6)),1,4) AS int))
from BEST..TREQJOB
where SSD_CF = @p_ssd_cf
  and REQCOD_CT = 'A'
  
INSERT into #TLIFPLN1
SELECT	A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	btrav..EST_ESID0871_TESTLIFPLN A
WHERE	A.SSD_CF        = @p_ssd_cf
  and	A.LSTUPDUSR_CF  = @p_usr_cf
  and A.UWY_NF       <= @max_plan_nf + 4
  and (
    (A.UWY_NF >= (select min(B.UWY_NF) from BTRT..TCONTR  B where B.CTR_NF = A.CTR_NF))
    or
    (A.UWY_NF >= (select min(C.UWY_NF) from BFAC..TCONTR  C where C.CTR_NF = A.CTR_NF))
    ) 
  
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) au contrat'
  goto ErreurAno
end
-- MODIFICATION [04] END 
----------------------------------------------------------------------------------
-- compare the number of lines between #TLIFPLN1 and EST_ESID0871_TESTLIFPLN    --
-- if difference exists we generate an anomaly 106                              --
---------------------------------------------------------------------------------- 
select @nbligne_templifpln = count(*) FROM #TLIFPLN1
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0

if ( @nbligne_templifpln != @nbligne_teslifpln )
begin
  select @error_type = 106
  select @MsgAnomalie = "Anomalie(s) liee(s) non existance d'un contarat TRT|FAC pour un UWY"
  select @NumMsgAnomalie = @NumMsgAnomalie + '106 '

  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
  SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, 'P', @p_usr_cf, @error_type, NUMLINE_NT
  FROM	btrav..EST_ESID0871_TESTLIFPLN
  WHERE	CTR_NF != NULL 
    and	TRN_NT not in (SELECT TRN_NT FROM #TLIFPLN1)
    and	SSD_CF       = @p_ssd_cf
    and	LSTUPDUSR_CF = @p_usr_cf
end

--                           MODIFICATION [03] END                                 --
-------------------------------------------------------------------------------------

-- Purge de la table #TLIFPLN1 avant réutilisation
DELETE #TLIFPLN1

/*-----------------------------------------------------------------------------*/
/*                CONTROLE FACULTATIVES INTERDITES                             */
/*                      si pb ano 94                                          */
/*-----------------------------------------------------------------------------*/

INSERT into #TLIFPLN1
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	btrav..EST_ESID0871_TESTLIFPLN A,
		BTRT..TSECTION B
where
        A.SSD_CF       = @p_ssd_cf
and	    A.LSTUPDUSR_CF = @p_usr_cf
and 	A.CTR_NF = B.CTR_NF
and		A.SEC_NF = B.SEC_NF

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) au contrat'
	goto ErreurAno
    end

-- Retro

INSERT INTO
	#TLIFPLN1
SELECT
	A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	btrav..EST_ESID0871_TESTLIFPLN A,
	BRET..TRETSEC B
WHERE
	A.SSD_CF       = @p_ssd_cf AND
	A.LSTUPDUSR_CF = @p_usr_cf AND
	A.RETCTR_NF = B.RETCTR_NF AND
	A.RETSEC_NF = B.RETSEC_NF

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) au contrat'
	goto ErreurAno
    end

-- Comparaison du nombre de lignes entre les tables btrav..EST_ESID0871_TESTLIFPLN et #TLIFPLN1
-- génération d'une anomalie ===> ANO 94 et sortie de la procédure
-- ---------------------------------------------------------------------------------------------

select @nbligne_templifpln = count(*) FROM #TLIFPLN1
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0

if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	select @error_type = 94
    select @MsgAnomalie = 'Anomalie(s) liee(s) au poste comptable principal = poste de contre-partie'
    select @NumMsgAnomalie = @NumMsgAnomalie + '94 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN1 avant réutilisation
DELETE #TLIFPLN1

select @max_plan_nf = max(CAST(SUBSTRING(CAST(VRS_NF AS VARCHAR(6)),1,4) AS int))
from BEST..TREQJOB
where SSD_CF = @p_ssd_cf
  and REQCOD_CT = 'A'

/*-----------------------------------------------------------------------------*/
/*                CONTROLE ANNEE COMPTE ACCEPTATION                            */
/*                      si pb ano 95                                          */
/*-----------------------------------------------------------------------------*/

INSERT into #TLIFPLN1
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM btrav..EST_ESID0871_TESTLIFPLN A
where A.SSD_CF       = @p_ssd_cf
  and A.LSTUPDUSR_CF = @p_usr_cf
  and (
        ( A.CTR_NF = NULL OR A.CTR_NF = '' )
      OR
        ( A.CTR_NF != NULL and A.ACY_NF BETWEEN @max_plan_nf - 4 AND @max_plan_nf + 4 )
      )

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) a l''annee de compte acceptation'
	goto ErreurAno
    end

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) a l''annee de compte acceptation'
	goto ErreurAno
end

-- Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN1
-- génération d'une anomalie et sortie de la procédure, ANO 95
-- -------------------------------------------------------------

select @nbligne_templifpln = count(*) FROM #TLIFPLN1
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    select @error_type     = 95
        select @MsgAnomalie    = 'Anomalie(s) liee(s) a l''annee de compte acceptation'
        select @NumMsgAnomalie = @NumMsgAnomalie + 'XX '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN1 avant réutilisation
-- ------------------------------------------------
DELETE #TLIFPLN1

/*-----------------------------------------------------------------------------*/
/*                CONTROLE ANNEE COMPTE RETRO                                  */
/*                      si pb ano 95                                          */
/*-----------------------------------------------------------------------------*/
INSERT into #TLIFPLN1
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM btrav..EST_ESID0871_TESTLIFPLN A
where
      A.SSD_CF       = @p_ssd_cf
  and A.LSTUPDUSR_CF = @p_usr_cf
  and (
        ( A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
        OR
        ( A.RETCTR_NF != NULL and A.RETACY_NF BETWEEN @max_plan_nf - 4 AND @max_plan_nf + 4 )
      )

select @erreur = @@error
if @erreur != 0
begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) à l''année de compte rétrocession'
    goto ErreurAno
end

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) a l''annee de compte rétrocession'
	goto ErreurAno
end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN1 */
/* génération d'une anomalie et sortie de la procédure, ANO 95   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN1
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0

if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    select @error_type = 95
        select @MsgAnomalie = "Anomalie(s) liee(s) a l'annee de compte retrocession"
        select @NumMsgAnomalie = @NumMsgAnomalie + 'XX '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "P", @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN1 avant réutilisation
-- ------------------------------------------------
DELETE #TLIFPLN1

/*-----------------------------------------------------------------------------*/
/*                CONTROLE EXISTENCE PLAN                                  */
/*                      si pb ano 97                                          */
/*-----------------------------------------------------------------------------*/
INSERT into #TLIFPLN1
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM btrav..EST_ESID0871_TESTLIFPLN A
where
      A.SSD_CF       = @p_ssd_cf
  and A.LSTUPDUSR_CF = @p_usr_cf
  and EXISTS (SELECT 1 FROM BEST..TREQJOB B where B.SSD_CF = A.SSD_CF
											  and B.REQCOD_CT = 'A'
											  and B.VRS_NF = A.PLAN_NF)

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) a l''annee d''exercice'
	goto ErreurAno
end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN1 */
/* génération d'une anomalie et sortie de la procédure, ANO 97   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN1
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0

if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    select @error_type = 97
        select @MsgAnomalie = "Anomalie(s) liee(s) a l'annee d'exercice"
        select @NumMsgAnomalie = @NumMsgAnomalie + 'XX '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN1 avant réutilisation
-- ------------------------------------------------
DELETE #TLIFPLN1

/*-----------------------------------------------------------------------------*/
/*                CONTROLE DATE DE BPC                                  */
/*                      si pb ano 98                                          */
/*-----------------------------------------------------------------------------*/
INSERT into #TLIFPLN1
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM btrav..EST_ESID0871_TESTLIFPLN A, BEST..TREQJOB B
where
      A.SSD_CF       = @p_ssd_cf
  and A.LSTUPDUSR_CF = @p_usr_cf
  and B.SSD_CF = A.SSD_CF
  and B.REQCOD_CT = 'A'
  and B.VRS_NF = A.PLAN_NF
  and (A.POSTBPC_B = 1 OR (A.POSTBPC_B = 0 AND A.CRE_D <= B.END_D) )

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN1 - Anomalie(s) liee(s) a l''annee d''exercice'
	goto ErreurAno
end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN1 */
/* génération d'une anomalie et sortie de la procédure, ANO 98   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN1
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0

if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    select @error_type = 98
        select @MsgAnomalie = "Anomalie(s) liee(s) a l'annee d'exercice"
        select @NumMsgAnomalie = @NumMsgAnomalie + 'XX '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN1)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

	
-- -----------------------------------------------------------------------------
-- GENERATION & CONTROLE DES ERREURS de NIVEAU 1
-- -----------------------------------------------------------------------------
select @nbligne_tctrano = 0
select @nbligne_tctrano = count(*) FROM #TCTRANO_TMP
if ( @nbligne_tctrano = Null ) Select @nbligne_tctrano = 0
if ( @nbligne_tctrano > 0 )
	begin
	goto ErreurAno
	end

-- A PARTIR DE CE NIVEAU DU CODE, LA PROC TRAVAILLE SYSTEMATIQUEMENT A PARTIR DES TABLES TEMPO
-- ET PLUS A PARTIR DE btrav..EST_ESID0871_TESTLIFPLN, POUR DES QUESTIONS DE RAPIDITE

-- Temporary table to retrieve max underwriting year and accounting type

CREATE TABLE #maxuwy
(
    CTR_NF        UCTR_NF       NOT NULL,
    SEC_NF        USEC_NF       NULL,
    MAXUWY_NF     UUWY_NF       NULL,
    ACCADMTYP_CT  UACCADMTYP_CT NULL,
	STS_CT     UCTRSTS_CT    NULL
)

/* Fill MAXUWY from BTRT for assumed contracts */
INSERT into #maxuwy
SELECT  
    s.CTR_NF as CTR_NF, 
    s.SEC_NF as SEC_NF,
    MAXUWY_NF = s.UWY_NF, 
    s.ACCADMTYP_CT,
	s.SECSTS_CT AS STS_CT
FROM #TLIFPLN1 t, BTRT..TSECTION s
WHERE s.SEC_NF = t.SEC_NF 
  AND s.CTR_NF = t.CTR_NF
  AND s.UWY_NF = (select MAX(u.UWY_NF) from BTRT..TSECTION u where s.SEC_NF = u.SEC_NF AND s.CTR_NF = u.CTR_NF AND u.SECSTS_CT IN (14,16,17,19))
  AND s.SECSTS_CT IN (14,16,17,19)/* Section has the rights to have estimations */
  AND t.SSD_CF = @p_ssd_cf
  AND (t.RETCTR_NF = NULL OR t.RETCTR_NF = '') 
GROUP BY s.SEC_NF, s.CTR_NF,s.ACCADMTYP_CT, s.SECSTS_CT


select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération maxuwy - Contrats d'acceptation "
	goto ErreurAno
    end

/* Fill MAXUWY from BRET for retro contracts */

INSERT into #maxuwy
SELECT 
    s.RETCTR_NF as CTR_NF, 
    t.RETSEC_NF as SEC_NF,
    MAXUWY_NF = s.RTY_NF,
    s.RETACCTYP_CT AS ACCADMTYP_CT,
	s.RETCTRSTS_CT AS STS_CT
FROM #TLIFPLN1 t, BRET..TRETCTR s
WHERE t.RETCTR_NF = s.RETCTR_NF 
  AND s.RTY_NF = (select MAX(u.RTY_NF) from BRET..TRETCTR u where s.RETCTR_NF = u.RETCTR_NF AND u.RETCTRSTS_CT in (3,19))
  AND s.RETCTRSTS_CT in (3,19)
  AND t.SSD_CF = @p_ssd_cf
  AND (t.CTR_NF = NULL OR t.CTR_NF = '')
--GROUP BY t.RETSEC_NF, t.RETCTR_NF
GROUP BY s.RETACCTYP_CT, s.RETCTRSTS_CT

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération maxuwy - Contrats de retro "
	goto ErreurAno
    end
	
/*-----------------------------------------------------------------------------*/
/*                Invalid section status                					  */
/*                      Ano 48                                       			*/
/*-----------------------------------------------------------------------------*/

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B,
		BTRT..TSECTION C
where 
	(A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and A.CTR_NF = B.CTR_NF
and A.CTR_NF = C.CTR_NF
and	A.SEC_NF = B.SEC_NF
and	A.SEC_NF = C.SEC_NF
AND c.SECSTS_CT IN (14,16,17,19)/* Section has the rights to have estimations */
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas accept "
	goto ErreurAno
    end
	
-- On est ds le contrôle du code crible des contrats, cas retro
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B,
		BRET..TRETCTR C
where 
	(A.CTR_NF = NULL OR A.CTR_NF = '')
and A.RETCTR_NF = B.CTR_NF
and A.RETCTR_NF = C.RETCTR_NF
and	A.RETSEC_NF = B.SEC_NF
and c.RETCTRSTS_CT in (3,19)
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas retro "
	goto ErreurAno
    end
	
/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
/* génération d'une anomalie et sortie de la procédure, ANO 48   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    -- génération d'une anomalie et sortie de la procédure
	    SELECT @error_type = 48
        select @MsgAnomalie = "Code crible interdit"
        select @NumMsgAnomalie = @NumMsgAnomalie + '48 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN2 avant réutilisation
-- -----------------------------------------------
DELETE #TLIFPLN2


/*-----------------------------------------------------------------------------*/
/*                CONTROLE DU TYPE D'ESTIMATIONS (CODE CRIBLE)                 */
/*                      Ano 99                                       */
/*-----------------------------------------------------------------------------*/

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B,
		BTRT..TCONTR C
where 
	(A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and A.CTR_NF = B.CTR_NF
and A.CTR_NF = C.CTR_NF
and	A.SEC_NF = B.SEC_NF
and C.UWY_NF = CASE WHEN A.UWY_NF < B.MAXUWY_NF
					THEN A.UWY_NF
					ELSE B.MAXUWY_NF
				END
and C.ESTCRB_CT NOT IN ('N', 'D')
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas accept "
	goto ErreurAno
    end
	
-- On est ds le contrôle du code crible des contrats, cas retro
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B,
		BRET..TRETCTR C
where 
	(A.CTR_NF = NULL OR A.CTR_NF = '')
and A.RETCTR_NF = B.CTR_NF
and A.RETCTR_NF = C.RETCTR_NF
and	A.RETSEC_NF = B.SEC_NF
and C.RTY_NF = CASE WHEN A.RTY_NF < B.MAXUWY_NF
					THEN A.RTY_NF
					ELSE B.MAXUWY_NF
				END
and C.ESTCRB_CT NOT IN ('N', 'D')
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas retro "
	goto ErreurAno
    end

-- Cas des non existants
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where 
	( ( (A.CTR_NF = NULL OR A.CTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.RETCTR_NF = B.CTR_NF
and	A.RETSEC_NF = B.SEC_NF ) )
OR ( (A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.CTR_NF = B.CTR_NF
and	A.SEC_NF = B.SEC_NF ) ) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas non existants "
	goto ErreurAno
    end
	
/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
/* génération d'une anomalie et sortie de la procédure, ANO 99   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    -- génération d'une anomalie et sortie de la procédure
	    SELECT @error_type = 99
        select @MsgAnomalie = "Code crible interdit"
        select @NumMsgAnomalie = @NumMsgAnomalie + '99 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN2 avant réutilisation
-- -----------------------------------------------
DELETE #TLIFPLN2

/*-----------------------------------------------------------------------------*/
/*                CONTROLE D'EXISTENCE DES SECTIONS                 */
/*                      Type 1 - Ano 100                                       */
/*-----------------------------------------------------------------------------*/

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B
where 
	(A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and A.CTR_NF = B.CTR_NF
and	A.SEC_NF = B.SEC_NF
and B.ACCADMTYP_CT = 1
and A.UWY_NF = A.ACY_NF
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas accept "
	goto ErreurAno
    end
	
-- On est ds le contrôle d'existence des sections type 1, cas retro
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B
where 
	(A.CTR_NF = NULL OR A.CTR_NF = '')
and A.RETCTR_NF = B.CTR_NF
and	A.RETSEC_NF = B.SEC_NF
and B.ACCADMTYP_CT = 1
and A.RTY_NF = A.RETACY_NF
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas retro "
	goto ErreurAno
	end
   
-- Cas des non existants
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where 
	( ( (A.CTR_NF = NULL OR A.CTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.RETCTR_NF = B.CTR_NF
and	A.RETSEC_NF = B.SEC_NF ) )
OR ( (A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.CTR_NF = B.CTR_NF
and	A.SEC_NF = B.SEC_NF ) ) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas non existants "
	goto ErreurAno
    end
	
-- On est ds le contrôle d'existence des sections type 1, il faut donc insérer tt ce qui
-- est d'autre type

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B
where 
	( (A.CTR_NF = B.CTR_NF and A.SEC_NF = B.SEC_NF) OR (A.RETCTR_NF = B.CTR_NF and A.RETSEC_NF = B.SEC_NF) )
and B.ACCADMTYP_CT != 1
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - Type 1'
	goto ErreurAno
    end


/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
/* génération d'une anomalie et sortie de la procédure, ANO 100   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    -- génération d'une anomalie et sortie de la procédure
	    SELECT @error_type = 100
        select @MsgAnomalie = "Section acceptation inconnue"
        select @NumMsgAnomalie = @NumMsgAnomalie + '100 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN2 avant réutilisation
-- -----------------------------------------------
DELETE #TLIFPLN2

/*-----------------------------------------------------------------------------*/
/*                CONTROLE D'EXISTENCE DES SECTIONS                 */
/*                      Type 2 résilié, 4, 5 - Ano 101                         */
/*-----------------------------------------------------------------------------*/

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B
where
	(A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and A.CTR_NF = B.CTR_NF
and	A.SEC_NF = B.SEC_NF
and ( (B.ACCADMTYP_CT = 2 and B.STS_CT = 19) OR (B.ACCADMTYP_CT = 4 OR B.ACCADMTYP_CT = 5) )
and A.UWY_NF <= B.MAXUWY_NF
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas accept "
	goto ErreurAno
    end

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B
where
	(A.CTR_NF = NULL OR A.CTR_NF = '')
and A.RETCTR_NF = B.CTR_NF
and	A.RETSEC_NF = B.SEC_NF
and ( (B.ACCADMTYP_CT = 2 and B.STS_CT = 19) OR (B.ACCADMTYP_CT = 4 OR B.ACCADMTYP_CT = 5) )
and A.RTY_NF <= B.MAXUWY_NF
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas retro "
	goto ErreurAno
    end

-- On est ds le contrôle d'existence des sections type 2 résilié/4/5, il faut donc insérer tt ce qui
-- est d'autre type

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B
where
	( (A.CTR_NF = B.CTR_NF and A.SEC_NF = B.SEC_NF) OR (A.RETCTR_NF = B.CTR_NF and A.RETSEC_NF = B.SEC_NF) )
and ( (B.ACCADMTYP_CT != 2 or B.STS_CT != 19) AND (B.ACCADMTYP_CT != 4 AND B.ACCADMTYP_CT != 5) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - Résiliés'
	goto ErreurAno
    end

-- Cas des non existants
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where 
	( ( (A.CTR_NF = NULL OR A.CTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.RETCTR_NF = B.CTR_NF
and	A.RETSEC_NF = B.SEC_NF ) )
OR ( (A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.CTR_NF = B.CTR_NF
and	A.SEC_NF = B.SEC_NF ) ) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas non existants "
	goto ErreurAno
    end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
/* génération d'une anomalie et sortie de la procédure, ANO 101   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    -- génération d'une anomalie et sortie de la procédure
	    SELECT @error_type = 101
        select @MsgAnomalie = "Section acceptation inconnue"
        select @NumMsgAnomalie = @NumMsgAnomalie + '101 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN2 avant réutilisation
-- -----------------------------------------------
DELETE #TLIFPLN2

/*-----------------------------------------------------------------------------*/
/*                CONTROLE D'EXISTENCE DES SECTIONS                 */
/*                      Type 3 - Ano 102                         */
/*-----------------------------------------------------------------------------*/

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
     A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM #TLIFPLN1 A,
        #maxuwy B,
           BREF..TSUBTRS C,
          BREF..TSUBTRSBLOCKLIFEST D
where
     (A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and A.CTR_NF = B.CTR_NF
and  A.SEC_NF = B.SEC_NF
and B.ACCADMTYP_CT = 3
and C.PCPTRS_CF+C.TRS_CF+C.SUBTRS_CF = SUBSTRING(A.TRNCOD_CF,3,5)
and C.PCPTRS_CF+C.TRS_CF+C.SUBTRS_CF = D.PCPTRS_CF+D.TRS_CF+D.SUBTRS_CF
and ( C.CELLPROTECEXC_B = 1 OR D.BLOCK_NF = 3 OR (C.CELLPROTECEXC_B = 0 AND A.UWY_NF = A.ACY_NF) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Accès à la table BTRT..TSECTION "
	goto ErreurAno
    end
     
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
     A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM #TLIFPLN1 A,
        #maxuwy B,
           BREF..TSUBTRS C,
          BREF..TSUBTRSBLOCKLIFEST D
where
     (A.CTR_NF = NULL OR A.CTR_NF = '')
and A.RETCTR_NF = B.CTR_NF
and  A.RETSEC_NF = B.SEC_NF
and B.ACCADMTYP_CT = 3
and C.PCPTRS_CF+C.TRS_CF+C.SUBTRS_CF = SUBSTRING(A.TRNCOD_CF,3,5)
and C.PCPTRS_CF+C.TRS_CF+C.SUBTRS_CF = D.PCPTRS_CF+D.TRS_CF+D.SUBTRS_CF
and ( C.CELLPROTECEXC_B = 1 OR D.BLOCK_NF = 3 OR (C.CELLPROTECEXC_B = 0 AND A.RTY_NF = A.RETACY_NF) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Accès à la table BTRT..TSECTION "
	goto ErreurAno
    end


-- On est ds le contrôle d'existence des sections type 3, il faut donc insérer tt ce qui
-- est d'autre type

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        #maxuwy B
where
	( (A.CTR_NF = B.CTR_NF and A.SEC_NF = B.SEC_NF) OR (A.RETCTR_NF = B.CTR_NF and A.RETSEC_NF = B.SEC_NF) )
and B.ACCADMTYP_CT != 3
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - Type 3'
	goto ErreurAno
    end

-- Cas des non existants
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where 
	( ( (A.CTR_NF = NULL OR A.CTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.RETCTR_NF = B.CTR_NF
and	A.RETSEC_NF = B.SEC_NF ) )
OR ( (A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.CTR_NF = B.CTR_NF
and	A.SEC_NF = B.SEC_NF ) ) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas non existants "
	goto ErreurAno
    end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
/* génération d'une anomalie et sortie de la procédure, ANO 102   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    -- génération d'une anomalie et sortie de la procédure
	    SELECT @error_type = 102
        select @MsgAnomalie = "Section acceptation inconnue"
        select @NumMsgAnomalie = @NumMsgAnomalie + '102 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN2 avant réutilisation
-- -----------------------------------------------
DELETE #TLIFPLN2

-- -----------------------------------------------------------------------------
--            AUTRE CONTROLE SUR LE POSTE COMPTABLE /LOB
--             On fait ceci après les contrôles concernant les sections
--                      si pb ===> ano 18
--                  On vérifie que lorsqu'on a saisi:
--            - un poste du type 1xxx ou 2xxx: on est bien sur 1 lob non vie
--            - un poste du type 3xxx ou 4xxx on est sur bien sur 1 lob vie
-- -----------------------------------------------------------------------------

-- Cas de l'acceptation pure et affaire traité
-- --------------------------------------------
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
 FROM	#TLIFPLN1 A, BTRT..TSECTION B, #maxuwy C
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
    and A.CTR_NF!=NULL
    and A.RETCTR_NF in(NULL,'')
    and	A.CTR_NF=B.CTR_NF
	and A.CTR_NF=C.CTR_NF
    and	A.END_NT=B.END_NT
    and	A.SEC_NF=B.SEC_NF
	and A.SEC_NF=C.SEC_NF
    and B.UWY_NF = (case when A.UWY_NF <= C.MAXUWY_NF then A.UWY_NF else C.MAXUWY_NF end)
	and	A.UW_NT=B.UW_NT
    and A.SSD_CF=B.SSD_CF
    and A.TRNCOD_CF like case when B.LOB_CF='30' then '3%'
                              when B.LOB_CF!='30' then '1%'
                         end
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - Cas de l''acceptation pure et affaire trt '
	goto ErreurAno
end

-- Cas où le contrat rétro est renseigné
-- Même si on a de l'acceptation, le fichier contient un poste de type rétrocession.
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
 FROM	#TLIFPLN1 A, bret..TRETSEC B, #maxuwy C
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
    and A.RETCTR_NF!=NULL
    and A.RETCTR_NF=B.RETCTR_NF
    and A.RETSEC_NF=B.RETSEC_NF
	and A.RETCTR_NF=C.CTR_NF
	and A.RETSEC_NF=C.SEC_NF
    and B.RTY_NF = (case when A.RTY_NF <= C.MAXUWY_NF then A.RTY_NF else C.MAXUWY_NF end)
    and A.SSD_CF=B.SSD_CF
    and A.TRNCOD_CF like case when B.LOB_CF='30' then '4%'
                              when B.LOB_CF!='30' then '2%'
                         end
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - Cas où le contrat rétro est renseignét'
	goto ErreurAno
end

-- Cas des non existants
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where 
	( ( (A.CTR_NF = NULL OR A.CTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.RETCTR_NF = B.CTR_NF
and	A.RETSEC_NF = B.SEC_NF ) )
OR ( (A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.CTR_NF = B.CTR_NF
and	A.SEC_NF = B.SEC_NF ) ) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas non existants "
	goto ErreurAno
    end

-- Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2
-- génération d'une anomalie et sortie de la procédure en fin de contrôle, ANO 18
-- --------------------------------------------------------------------------------
select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    select @error_type = 18
        select @MsgAnomalie = 'Anomalie(s) liee(s) aux  postes comptables'
        select @NumMsgAnomalie = @NumMsgAnomalie + '18 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "P", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end


-- Purge de la table #TLIFPLN2 avant réutilisation
-- -----------------------------------------------
DELETE #TLIFPLN2

/*-----------------------------------------------------------------------------*/
/*                CONTROLE DES PLACEMENTS                                      */
/*                      si pb ano 23                                           */
/*-----------------------------------------------------------------------------*/

/* Un controle est déjà fait au niveau de l'appli pour n'avoir une valeur de placement
que lorsque le contrat rétro est renseigné */

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        bret..TPLACEMT B
where
        A.PLC_NT != NULL
  and	A.RETCTR_NF = B.RETCTR_NF
  and	A.RTY_NF = B.RTY_NF
  and	A.PLC_NT = B.PLC_NT
  and	B.HIS_B = 0
  and	B.ACCPLC_B = 1
  and (B.PLCSTS_CT = 16 or B.PLCSTS_CT = 19)


-- On est ds le contrôle des num de placements, il faut donc insérer tt ce qui
-- est sans placement car sinon, on aura décallage ensuite en comptant le nbr de lignes

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where
  A.PLC_NT = NULL OR A.PLC_NT = 0

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - CONTROLE DES PLACEMENTS '
	goto ErreurAno
    end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN1 */
/* génération d'une anomalie et sortie de la procédure, ANO 23   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    SELECT @error_type = 23
        select @MsgAnomalie = 'certain(s) placement(s) ne sont pas référencés dans la base rétrocession'
        select @NumMsgAnomalie = @NumMsgAnomalie + '23 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'P', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end


-- Purge de la table #TLIFPLN2 avant réutilisation
-- -----------------------------------------------
DELETE #TLIFPLN2


/*-----------------------------------------------------------------------------*/
/*                CONTROLE DES DEVISES ACCEPTATION                             */
/*                      si pb ano 24                                           */
/*-----------------------------------------------------------------------------*/


-- Accès à la table BREF..TCURQUOT ( affaire acceptation renseignée ) pour contrôler CUR_CF
-- ----------------------------------------------------------------------------------------

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where
    (A.CTR_NF != NULL
and	exists(	select 1 FROM BREF..TCURQUOT B
	                 where	A.CUR_CF = B.CUR_CF
	                 and 	A.SSD_CF = B.SSD_CF )
and not exists( select 1 FROM BREF..TEUROCUR C
                         where   A.CUR_CF = C.CUR_CF
                         and     A.CUR_CF != 'EUR'  )
   )
OR   ( A.CTR_NF = NULL OR A.CTR_NF = '')

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - CONTROLE DES DEVISES ACCEPTATION'
	goto ErreurAno
    end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
/* génération d'une anomalie et sortie de la procédure, ANO 24   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin
	    SELECT @error_type = 24
        select @MsgAnomalie = 'Devise acceptation incorrecte'
        select @NumMsgAnomalie = @NumMsgAnomalie + '24 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT ISNULL(CTR_NF,RETCTR_NF), ISNULL(END_NT,RETEND_NT), ISNULL(SEC_NF,RETSEC_NF), 1, SSD_CF, 'P', @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and	LSTUPDUSR_CF = @p_usr_cf
	end

-- Purge de la table #TLIFPLN2 avant réutilisation
-- -----------------------------------------------
DELETE #TLIFPLN2

/*-----------------------------------------------------------------------------*/
/*                CONTROLE DES DEVISES RETRO                                   */
/*                      si pb ano 25                                           */
/*-----------------------------------------------------------------------------*/

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where
    ( A.RETCTR_NF != NULL
and	exists( select 1 FROM BREF..TCURQUOT B
	                 where	A.RETCUR_CF = B.CUR_CF
	                 and 	A.SSD_CF = B.SSD_CF )
and not exists(select 1 FROM BREF..TEUROCUR C
                        where   A.RETCUR_CF = C.CUR_CF
                        and     A.RETCUR_CF != 'EUR'  )
   )
OR ( A.RETCTR_NF = NULL OR A.RETCTR_NF = "")

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - CONTROLE DES DEVISES RETRO "
	goto ErreurAno
    end

/* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
/* génération d'une anomalie et sortie de la procédure, ANO 25   */
/* ------------------------------------------------------------- */

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
	begin -- ##
	    SELECT @error_type = 25
        select @MsgAnomalie = "Devise rétro incorrecte"
        select @NumMsgAnomalie = @NumMsgAnomalie + '25 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "P", @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0871_TESTLIFPLN
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
        and SSD_CF       = @p_ssd_cf
        and LSTUPDUSR_CF = @p_usr_cf
	end


-- -- Purge de  #TLIFPLN2 avant réutilisation
-- -- ---------------------------------------
-- DELETE #TLIFPLN2

-- /*-----------------------------------------------------------------------------*/
-- /*                CONTROLE DU CODE CRIB POUR CONTRAT NO ESTIMATE               */
-- /*                      si pb ano 5035                                           */
-- /*-----------------------------------------------------------------------------*/

-- INSERT into #TLIFPLN2
-- select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
-- 	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
-- 	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
-- 	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
-- 	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
-- 	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
-- FROM	#TLIFPLN1 A
-- LEFT OUTER JOIN BTRT..TCONTR tcontr ON A.CTR_NF = tcontr.CTR_NF AND A.UWY_NF=tcontr.UWY_NF
-- LEFT OUTER JOIN BRET..TRETCTR tret ON A.CTR_NF = tret.RETCTR_NF AND A.UWY_NF=tret.RTY_NF
-- WHERE CASE 
--     WHEN tcontr.CTR_NF IS NOT NULL 
--     THEN tcontr.ESTCRB_CT 
--     ELSE tret.ESTCRB_CT END = 'V'
--  AND A.SSD_CF = @p_ssd_cf
--  AND A.LSTUPDUSR_CF = @p_usr_cf

-- select @erreur = @@error
-- if @erreur != 0
--     begin
--     select @MsgAnomalie = "Erreur Génération TLIFPLN2 - CONTROLE DU CODE CRIBLE NO ESTIMATE"
-- 	goto ErreurAno
--     end

-- /* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
-- /* génération d'une anomalie et sortie de la procédure, ANO 5035   */
-- /* ------------------------------------------------------------- */

-- select @nbligne_templifpln = count(*) FROM #TLIFPLN2
-- if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
-- if ( @nbligne_templifpln != @nbligne_teslifpln )
-- 	begin -- ##
-- 	    SELECT @error_type = 5035
--         select @MsgAnomalie = "Contract with code crib No Estimate"
--         select @NumMsgAnomalie = @NumMsgAnomalie + '5035 '

--         INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
--         SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "P", @p_usr_cf,  @error_type, NUMLINE_NT
--         FROM btrav..EST_ESID0871_TESTLIFPLN
--         WHERE
--             TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
--         and SSD_CF       = @p_ssd_cf
--         and LSTUPDUSR_CF = @p_usr_cf

-- 	end


-- -- Purge de  #TLIFPLN2 avant réutilisation
-- -- ---------------------------------------
-- DELETE #TLIFPLN2

-- /*-----------------------------------------------------------------------------*/
-- /*                CONTROLE DU CODE CRIB POUR CONTRAT NO ESTIMATE               */
-- /*                      si pb ano 5036                                           */
-- /*-----------------------------------------------------------------------------*/

-- INSERT into #TLIFPLN2
-- select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
-- 	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
-- 	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
-- 	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
-- 	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
-- 	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
-- FROM	#TLIFPLN1 A
-- LEFT OUTER JOIN BTRT..TCONTR tcontr ON A.CTR_NF = tcontr.CTR_NF AND A.UWY_NF=tcontr.UWY_NF
-- LEFT OUTER JOIN BRET..TRETCTR tret ON A.CTR_NF = tret.RETCTR_NF AND A.UWY_NF=tret.RTY_NF
-- WHERE CASE 
--     WHEN tcontr.CTR_NF IS NOT NULL 
--     THEN tcontr.ESTCRB_CT 
--     ELSE tret.ESTCRB_CT END in ('T','U')
--  AND A.SSD_CF = @p_ssd_cf
--  AND A.LSTUPDUSR_CF = @p_usr_cf

-- select @erreur = @@error
-- if @erreur != 0
--     begin
--     select @MsgAnomalie = "Erreur Génération TLIFPLN2 - CONTROLE DU CODE CRIBLE QUARTERLY"
-- 	goto ErreurAno
--     end

-- /* Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2 */
-- /* génération d'une anomalie et sortie de la procédure, ANO 5035   */
-- /* ------------------------------------------------------------- */

-- select @nbligne_templifpln = count(*) FROM #TLIFPLN2
-- if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
-- if ( @nbligne_templifpln != @nbligne_teslifpln )
-- 	begin -- ##
-- 	    SELECT @error_type = 5036
--         select @MsgAnomalie = "Contract with code crib Quarterly"
--         select @NumMsgAnomalie = @NumMsgAnomalie + '5036 '

--         INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
--         SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "P", @p_usr_cf,  @error_type, NUMLINE_NT
--         FROM btrav..EST_ESID0871_TESTLIFPLN
--         WHERE
--             TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
--         and SSD_CF       = @p_ssd_cf
--         and LSTUPDUSR_CF = @p_usr_cf
-- 	end


-- Purge de  #TLIFPLN2 avant réutilisation
-- ---------------------------------------
DELETE #TLIFPLN2

/*-----------------------------------------------------------------------------*/
/*                    CONTROLE SI L'AFFAIRE ACCEPTATION                        */
/*                     A LE STATUT "TERMINE COMPTABLE"                         */
/*                              si pb ano 47                                   */
/*-----------------------------------------------------------------------------*/

/* TRAITES */
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A,
        btrt..TCONTR B
where
    A.SSD_CF        = @p_ssd_cf
and	A.LSTUPDUSR_CF  = @p_usr_cf
and A.CTR_NF       != NULL
and A.CTR_NF        = B.CTR_NF
and	A.END_NT        = B.END_NT
and	A.UWY_NF        = B.UWY_NF
and	A.UW_NT         = B.UW_NT
and B.CTRACCSTS_CT != 9  -- On exclut les contrats "Terminé comptable"

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where NOT EXISTS ( SELECT 1 FROM btrt..TCONTR B where
    A.SSD_CF        = @p_ssd_cf
and	A.LSTUPDUSR_CF  = @p_usr_cf
and A.CTR_NF       != NULL
and A.CTR_NF        = B.CTR_NF
and	A.END_NT        = B.END_NT
and	A.UWY_NF        = B.UWY_NF
and	A.UW_NT         = B.UW_NT )

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - Cas de l''affaire terminée comptable'
	goto ErreurAno
end

-- On est toujours dans le contrôle du statut "terminé comptable", mais il faut aussi insérer tt ce qui
-- est rétro pure car sinon, on aura décalage ensuite en comptant le nbr de lignes

INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where
    (A.CTR_NF = NULL OR A.CTR_NF =  '')
and A.RETCTR_NF != NULL

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TLIFPLN2 - Cas de l''affaire terminée comptable'
  goto ErreurAno
end

-- Cas des non existants
	
INSERT into #TLIFPLN2
select A.TRN_NT,A.ACCTYP_NF,A.SSD_CF,A.ESB_CF,A.PLAN_NF,A.BALSHEY_NF,A.BALSHRMTH_NF,A.BALSHRDAY_NF,A.TRNCOD_CF,
	A.DBLTRNCOD_CF,A.CTR_NF,A.END_NT,A.SEC_NF,A.UWY_NF,A.UW_NT,A.OCCYEA_NF,A.ACY_NF,A.SCOSTRMTH_NF,
	A.SCOENDMTH_NF,A.CUR_CF,A.AMT_M,A.CED_NF,A.BRK_NF,A.GEMPRMPAY_NF,A.GANPAYORD_NT,A.RETCTR_NF,A.RETEND_NT,
	A.RETSEC_NF,A.RTY_NF,A.RETUW_NT,A.PLC_NT,A.RETOCCYEA_NF,A.RETACY_NF,A.RETSCOSTRMTH_NF,A.RETSCOENDMTH_NF,
	A.RETCUR_CF,A.RETAMT_M,A.RTO_NF,A.INT_NF,A.RETPAY_NF,A.RETKEY_CF,A.COMMAC_LL,A.CRE_D,A.CREUSR_CF,
	A.LSTUPD_D,A.LSTUPDUSR_CF,A.POSTBPC_B, A.NUMLINE_NT
FROM	#TLIFPLN1 A
where 
	( ( (A.CTR_NF = NULL OR A.CTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.RETCTR_NF = B.CTR_NF
and	A.RETSEC_NF = B.SEC_NF ) )
OR ( (A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and NOT EXISTS (SELECT 1 FROM #maxuwy B where
A.CTR_NF = B.CTR_NF
and	A.SEC_NF = B.SEC_NF ) ) )
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TLIFPLN2 - Cas non existants "
	goto ErreurAno
    end

-- Comparaison du nombre de lignes entre EST_ESID0871_TESTLIFPLN et #TLIFPLN2
-- génération d'une anomalie ===>  ANO 47
-- -----------------------------------------------------------------------------

select @nbligne_templifpln = count(*) FROM #TLIFPLN2
if ( @nbligne_templifpln = Null ) Select @nbligne_templifpln = 0
if ( @nbligne_templifpln != @nbligne_teslifpln )
begin
  -- génération d'une anomalie et sortie de la procédure
  SELECT @error_type     = 47
  select @MsgAnomalie    = 'Affaire terminée comptable'
  select @NumMsgAnomalie = @NumMsgAnomalie + '47 '

  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
  SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, 'P', @p_usr_cf, @error_type, NUMLINE_NT
  FROM btrav..EST_ESID0871_TESTLIFPLN
  WHERE
      TRN_NT NOT IN (SELECT TRN_NT FROM #TLIFPLN2)
  and SSD_CF       = @p_ssd_cf
  and LSTUPDUSR_CF = @p_usr_cf
end


/************************************************************************************/
/*                                                                                  */
/*                     3ème ETAPE:  DETERMINATION DU TYPE D'ECRITURE                */
/*                                                                                  */
/************************************************************************************/

/* Ecritures de type 1 */
/* Acceptation pure    */
/* ------------------- */

UPDATE #TLIFPLN1
SET	ACCTYP_NF = 1
where ( CTR_NF != NULL AND CTR_NF != "")
and	( RETCTR_NF = NULL OR RETCTR_NF = "")

select @erreur = @@error
if @erreur != 0
    begin
      select @MsgAnomalie = "Erreur UPDATE TLIFPLN1 - 3eme Etape - Ecriture de TYPE 1 "
	  goto ErreurAno
    end

/* Ecritures de type 4 */
/* Rétro pure à la part */
/* ------------------- */

UPDATE #TLIFPLN1
SET	ACCTYP_NF = 4
where	( CTR_NF = NULL OR CTR_NF = "")
and	( RETCTR_NF != NULL AND RETCTR_NF != "")

select @erreur = @@error
if @erreur != 0
    begin
	  select @MsgAnomalie = "Erreur UPDATE TLIFPLN1 - 3eme Etape - Ecriture de TYPE 4 "
	  goto ErreurAno
    end

select @nbligne_tctrano = 0
select @nbligne_tctrano = count(*) FROM #TCTRANO_TMP
if ( @nbligne_tctrano = Null ) Select @nbligne_tctrano = 0
if ( @nbligne_tctrano > 0 )
	begin
	 goto ErreurAno
	end

-- ***********************************************************************************
--
--    ETAPE 4 - TOUT S'EST BIEN PASSE, IL N'Y A PAS EU DE DEBRANCHEMENT SUITE A ANO
--
-- ************************************************************************************


/*********************************************/
/* Gestion du compteur pour le champs TRN_NT */
/*********************************************/

-- recherche du numéro de ligne maxi dans BEST..TLIFPLN

select @max_trn_nt = max( TRN_NT )
FROM 	BEST..TLIFPLN

-- ********************************************************************
-- INSERTion dans la table BEST..TLIFPLN si tous les contrôles sont OK
-- ********************************************************************

-- -------------------------------------------------------------
-- Début de la transaction
-- --------------------------------------------------------------

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


INSERT into BEST..TLIFPLN
	( ACCTYP_NF,SSD_CF,ESB_CF,PLAN_NF,BALSHEY_NF,BALSHRMTH_NF,BALSHRDAY_NF,TRNCOD_CF,
	DBLTRNCOD_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,OCCYEA_NF,ACY_NF,SCOSTRMTH_NF,
	SCOENDMTH_NF,CUR_CF,AMT_M,CED_NF,BRK_NF,GEMPRMPAY_NF,GANPAYORD_NT,RETCTR_NF,RETEND_NT,
	RETSEC_NF,RETRTY_NF,RETUW_NT,PLC_NT,RETOCCYEA_NF,RETACY_NF,RETSCOSTRMTH_NF,RETSCOENDMTH_NF,
	RETCUR_CF,RETAMT_M,RTO_NF,INT_NF,RETPAY_NF,RETKEY_CF,COMMAC_LL,CRE_D,CREUSR_CF,
	LSTUPD_D,LSTUPDUSR_CF,POSTBPC_B)
	select ACCTYP_NF,SSD_CF,ESB_CF,PLAN_NF,BALSHEY_NF,BALSHRMTH_NF,BALSHRDAY_NF,TRNCOD_CF,
	DBLTRNCOD_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,OCCYEA_NF,ACY_NF,SCOSTRMTH_NF,
	SCOENDMTH_NF,CUR_CF,AMT_M,CED_NF,BRK_NF,GEMPRMPAY_NF,GANPAYORD_NT,RETCTR_NF,RETEND_NT,
	RETSEC_NF,RTY_NF,RETUW_NT,PLC_NT,RETOCCYEA_NF,RETACY_NF,RETSCOSTRMTH_NF,RETSCOENDMTH_NF,
	RETCUR_CF,RETAMT_M,RTO_NF,INT_NF,RETPAY_NF,RETKEY_CF,COMMAC_LL,CRE_D,CREUSR_CF,
	LSTUPD_D,LSTUPDUSR_CF,POSTBPC_B
FROM	#TLIFPLN1

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- *****************************************************************************************
-- Suppression des lignes de btrav..EST_ESID0871_TESTLIFPLN pour la filiale et l'utilisateur
-- *****************************************************************************************

DELETE btrav..EST_ESID0871_TESTLIFPLN
where SSD_CF       = @p_ssd_cf
and	LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- -----------------------------------------------------------
--   Fin de la transaction
-- ------------------------------------------------------------

if @tran_imbr = 0
    COMMIT TRAN
    return 0

/************************************************************************************/
/*                     EN CAS DE DETECTION D'ANOMALIES                              */
/************************************************************************************/

ErreurNorm:
    Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
    raiserror 20113 @MsgGlobalAnomalie
    return 1


ErreurAno:
-- On enregistre les Erreurs dans la Tables des Anomalies.
-- On retourne Un code Erreur Echec de la Procedure.
-- L'ancienne Gestion des ANomalies a été remplacées (Les erreurs sont inscrites au fur et à mesure plutôt qu'un contrôle #é&~@é## en fin de procédure
-- Il n'existe pas de ROLLBACK de PRocédure à ce niveau. (Car aucun Begin TRAN avant Etape 4)

    INSERT INTO BEST..TCTRANO (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT ISNULL(CTR_NF, ''), ISNULL(END_NT, 0),
           ISNULL(SEC_NF, 0),  ISNULL(VRS_NF, 0),
           ISNULL(SSD_CF, 0),  ISNULL(SEGTYP_CT, ''),
           ISNULL(SEG_NF, ''),  ISNULL(ANO_CT, 0),
           ISNULL(NUMLINE_NT, -1)
    FROM #TCTRANO_TMP
    WHERE SSD_CF = @p_ssd_cf
      and SEG_NF = @p_usr_cf

    if @p_batch_mode != 'batch'
        BEGIN
            Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
            raiserror 20113 @MsgGlobalAnomalie
        END    
    return 1

ErreurMAJ:
    if @tran_imbr = 0 ROLLBACK TRAN

    Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
    raiserror 20113 @MsgGlobalAnomalie
    return 1
go

