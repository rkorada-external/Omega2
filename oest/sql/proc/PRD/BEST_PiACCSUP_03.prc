use BEST
go
/*
 * DROP PROC PiACCSUP_03
 */
IF OBJECT_ID('PiACCSUP_03') IS NOT NULL
BEGIN
    DROP PROC PiACCSUP_03
    PRINT '<<< DROPPED PROC PiACCSUP_03 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiACCSUP_03(
	@p_ssd_cf		tinyint )

with execute as caller as

/***************************************************

Programme: PiACCSUP_03

Fichier script associé : ESISUP03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 24/11/97

Description du programme:
	- contrôles de cohérences des écritures de services issues de l'IBNR TOOL
pour insertion dans la table BEST..TACCSUP


Parametres:


Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: M.HA-THUC

Date:	20/07/98

Version:

Description: les lignes sont contrôlées à partir de BTRAV..TESTUTISUD
	au lieu de BTRAV..TESTUTISUP
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 17/09/2009  |[18053] Pour les fac xxLyyyyy, remplacement du test sur les lettres par un interval qui couvre l'ensemble du domaine des FACs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------

_________________
Modification - Removed dbo and added ‘with execute as caller as’
[002] 07/04/2014 R. Cassis :spot:25427 Omega2 1B - Suppression de la condition sur le 3eme caractere du contrat qui ne sert plus
*****************************************************/



declare 	@erreur     		int,
        	@tran_imbr		bit,
		@cre_d			datetime,	/* date du jour */
		@entpery_nf		smallint,	/* année de saisie */
		@entpermth_nf 	tinyint,	/* mois de saisie */
		@spcend_d		datetime,	/* variable en sortie de PsCALEND_02 */
		@account_d		datetime,	/* variable en sortie de PsCALEND_02 */
		@closing_b		bit,		/* variable en sortie de PsCALEND_02 */
		@nbligne_testutisud	int,		/* nbre lignes de la table utilisateurs en entrée */
		@nbligne_tempaccsup	int,		/* nbre lignes en sortie de traitement */
		@max_trn_nt		numeric( 10, 0 ) /* numéro d'écriture maxi de BEST..TACCSUP */

select @erreur = 0
select @tran_imbr = 1
select @cre_d = getdate()


/* ------------------------------------------------------------
   Création des tables temporaires
 -------------------------------------------------------------- */

create table #TACCSUP1 (
	TRN_NT			numeric(10,0)	NULL,
	ACCTYP_NF		tinyint	NULL,
	SSD_CF			USSD_CF	NULL,
	ESB_CF			UESB_CF	NULL,
	ENTPERY_NF		UUWY_NF	NULL,
	ENTPERMTH_NF		tinyint	NULL,
	BALSHEY_NF		UUWY_NF	NULL,
	BALSHRMTH_NF		tinyint	NULL,
	BALSHRDAY_NF		tinyint	NULL,
       VALPERY_NF		UUWY_NF	NULL,
	VALPERMTH_NF		tinyint	NULL,
	TRNCOD_CF		UDETTRS_CF	NULL,
	DBLTRNCOD_CF		UDETTRS_CF	NULL,
	RETAUTGEN_B		tinyint	NULL,
	CTR_NF			UCTR_NF	NULL,
	END_NT			UEND_NT	NULL,
	SEC_NF			USEC_NF	NULL,
	UWY_NF			UUWY_NF	NULL,
	UW_NT			UUW_NT		NULL,
	OCCYEA_NF		UUWY_NF	NULL,
	ACY_NF			UUWY_NF	NULL,
	SCOSTRMTH_NF		tinyint	NULL,
	SCOENDMTH_NF		tinyint	NULL,
	CLM_NF			UCLM_NF	NULL,
	CUR_CF			UCUR_CF	NULL,
	AMT_M			UAMT_M		NULL,
	CED_NF			UCLI_NF	NULL,
	BRK_NF			UCLI_NF	NULL,
	GEMPRMPAY_NF		UCLI_NF	NULL,
	GANPAYORD_NT		UPAYORD_NT	NULL,
	RETCTR_NF		URETCTR_NF	NULL,
	RETEND_NT		UEND_NT	NULL,
	RETSEC_NF		URETSEC_NF	NULL,
	RTY_NF			UUWY_NF	NULL,
	RETUW_NT		UUW_NT		NULL,
	PLC_NT			UPLC_NT	NULL,
	RETOCCYEA_NF		UUWY_NF	NULL,
	RETACY_NF		UUWY_NF	NULL,
	RETSCOSTRMTH_NF	tinyint	NULL,
	RETSCOENDMTH_NF	tinyint	NULL,
	RCL_NF			UCLM_NF	NULL,
	RETCUR_CF		UCUR_CF	NULL,
	RETAMT_M		UAMT_M		NULL,
	RTO_NF			UCLI_NF	NULL,
	INT_NF			UCLI_NF	NULL,
	RETPAY_NF		UCLI_NF	NULL,
	RETKEY_CF		char(1)	NULL,
	ACCTRN_NT		numeric(10,0) NULL,
	COMMAC_LL		UL64		NULL,
	CRE_D			UUPD_D		NULL,
	CREUSR_CF		UUPDUSR_CF	NULL,
	LSTUPD_D		UUPD_D		NULL,
	LSTUPDUSR_CF		UUPDUSR_CF	NULL )

create table #TACCSUP2 (
	TRN_NT			numeric(10,0)	NULL,
	ACCTYP_NF		tinyint	NULL,
	SSD_CF			USSD_CF	NULL,
	ESB_CF			UESB_CF	NULL,
	ENTPERY_NF		UUWY_NF	NULL,
	ENTPERMTH_NF		tinyint	NULL,
	BALSHEY_NF		UUWY_NF	NULL,
	BALSHRMTH_NF		tinyint	NULL,
	BALSHRDAY_NF		tinyint	NULL,
       VALPERY_NF		UUWY_NF	NULL,
	VALPERMTH_NF		tinyint	NULL,
	TRNCOD_CF		UDETTRS_CF	NULL,
	DBLTRNCOD_CF		UDETTRS_CF	NULL,
	RETAUTGEN_B		tinyint	NULL,
	CTR_NF			UCTR_NF	NULL,
	END_NT			UEND_NT	NULL,
	SEC_NF			USEC_NF	NULL,
	UWY_NF			UUWY_NF	NULL,
	UW_NT			UUW_NT		NULL,
	OCCYEA_NF		UUWY_NF	NULL,
	ACY_NF			UUWY_NF	NULL,
	SCOSTRMTH_NF		tinyint	NULL,
	SCOENDMTH_NF		tinyint	NULL,
	CLM_NF			UCLM_NF	NULL,
	CUR_CF			UCUR_CF	NULL,
	AMT_M			UAMT_M		NULL,
	CED_NF			UCLI_NF	NULL,
	BRK_NF			UCLI_NF	NULL,
	GEMPRMPAY_NF		UCLI_NF	NULL,
	GANPAYORD_NT		UPAYORD_NT	NULL,
	RETCTR_NF		URETCTR_NF	NULL,
	RETEND_NT		UEND_NT	NULL,
	RETSEC_NF		URETSEC_NF	NULL,
	RTY_NF			UUWY_NF	NULL,
	RETUW_NT		UUW_NT		NULL,
	PLC_NT			UPLC_NT	NULL,
	RETOCCYEA_NF		UUWY_NF	NULL,
	RETACY_NF		UUWY_NF	NULL,
	RETSCOSTRMTH_NF	tinyint	NULL,
	RETSCOENDMTH_NF	tinyint	NULL,
	RCL_NF			UCLM_NF	NULL,
	RETCUR_CF		UCUR_CF	NULL,
	RETAMT_M		UAMT_M		NULL,
	RTO_NF			UCLI_NF	NULL,
	INT_NF			UCLI_NF	NULL,
	RETPAY_NF		UCLI_NF	NULL,
	RETKEY_CF		char(1)	NULL,
	ACCTRN_NT		numeric(10,0) NULL,
	COMMAC_LL		UL64		NULL,
	CRE_D			UUPD_D		NULL,
	CREUSR_CF		UUPDUSR_CF	NULL,
	LSTUPD_D		UUPD_D		NULL,
	LSTUPDUSR_CF		UUPDUSR_CF	NULL )

create table #TACCSUP3 (
	TRN_NT			numeric(10,0)	identity,
	ACCTYP_NF		tinyint	NULL,
	SSD_CF			USSD_CF	NULL,
	ESB_CF			UESB_CF	NULL,
	ENTPERY_NF		UUWY_NF	NULL,
	ENTPERMTH_NF		tinyint	NULL,
	BALSHEY_NF		UUWY_NF	NULL,
	BALSHRMTH_NF		tinyint	NULL,
	BALSHRDAY_NF		tinyint	NULL,
       VALPERY_NF		UUWY_NF	NULL,
	VALPERMTH_NF		tinyint	NULL,
	TRNCOD_CF		UDETTRS_CF	NULL,
	DBLTRNCOD_CF		UDETTRS_CF	NULL,
	RETAUTGEN_B		tinyint	NULL,
	CTR_NF			UCTR_NF	NULL,
	END_NT			UEND_NT	NULL,
	SEC_NF			USEC_NF	NULL,
	UWY_NF			UUWY_NF	NULL,
	UW_NT			UUW_NT		NULL,
	OCCYEA_NF		UUWY_NF	NULL,
	ACY_NF			UUWY_NF	NULL,
	SCOSTRMTH_NF		tinyint	NULL,
	SCOENDMTH_NF		tinyint	NULL,
	CLM_NF			UCLM_NF	NULL,
	CUR_CF			UCUR_CF	NULL,
	AMT_M			UAMT_M		NULL,
	CED_NF			UCLI_NF	NULL,
	BRK_NF			UCLI_NF	NULL,
	GEMPRMPAY_NF		UCLI_NF	NULL,
	GANPAYORD_NT		UPAYORD_NT	NULL,
	RETCTR_NF		URETCTR_NF	NULL,
	RETEND_NT		UEND_NT	NULL,
	RETSEC_NF		URETSEC_NF	NULL,
	RTY_NF			UUWY_NF	NULL,
	RETUW_NT		UUW_NT		NULL,
	PLC_NT			UPLC_NT	NULL,
	RETOCCYEA_NF		UUWY_NF	NULL,
	RETACY_NF		UUWY_NF	NULL,
	RETSCOSTRMTH_NF	tinyint	NULL,
	RETSCOENDMTH_NF	tinyint	NULL,
	RCL_NF			UCLM_NF	NULL,
	RETCUR_CF		UCUR_CF	NULL,
	RETAMT_M		UAMT_M		NULL,
	RTO_NF			UCLI_NF	NULL,
	INT_NF			UCLI_NF	NULL,
	RETPAY_NF		UCLI_NF	NULL,
	RETKEY_CF		char(1)	NULL,
	ACCTRN_NT		numeric(10,0) NULL,
	COMMAC_LL		UL64		NULL,
	CRE_D			UUPD_D		NULL,
	CREUSR_CF		UUPDUSR_CF	NULL,
	LSTUPD_D		UUPD_D		NULL,
	LSTUPDUSR_CF		UUPDUSR_CF	NULL )


/* ------------------------------------------------------------
   Début de la transaction
 -------------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


/************************************************************/
/* Calcul du nombre de lignes de la table BTRAV..TESTUTISUD */
/************************************************************/

select @nbligne_testutisud = count(*) from BTRAV..TESTUTISUD


/*******************************/
/* 1ère ETAPE: CHAMPS CALCULES */
/*******************************/

/* accès à la table BREF..TCALEND pour déterminer la période de saisie */
/* ------------------------------------------------------------------- */

Execute @erreur = BREF..PsCALEND_02
			@cre_d,
			'C',
			@entpery_nf output,
        		@entpermth_nf output,
			@spcend_d output,
			@account_d output,
			@closing_b output

if @erreur != 0  goto fin


update	BTRAV..TESTUTISUD
set	ENTPERY_NF = @entpery_nf,
	ENTPERMTH_NF = @entpermth_nf,
	CRE_D = @cre_d,
	LSTUPD_D = @cre_d,
	CREUSR_CF = "IBNR",
	LSTUPDUSR_CF = "IBNR"
from	BTRAV..TESTUTISUD

select @erreur = @@error

if @erreur != 0  goto fin


/* accès à la table BFAC..TCONTR pour renseigner les champs filiale,... */
/* -------------------------------------------------------------------- */

update BTRAV..TESTUTISUD
set	SSD_CF = B.SSD_CF,
	ESB_CF = B.ACCESB_CF,
	CED_NF = B.CED_NF,
	BRK_NF = B.GENPRMSEN_NF,
	GEMPRMPAY_NF = B.GENPRMPAY_NF,
	GANPAYORD_NT = B.GANPAYORD_NT
from	BTRAV..TESTUTISUD A, BFAC..TCONTR B
where	A.CTR_NF = B.CTR_NF
and	A.END_NT = B.END_NT
and	A.UWY_NF = B.UWY_NF
and	A.UW_NT = B.UW_NT

select @erreur = @@error

if @erreur != 0  goto fin


/* accès à la table BTRT..TCONTR pour renseigner les champs filiale,... */
/* -------------------------------------------------------------------- */

update BTRAV..TESTUTISUD
set	SSD_CF = B.SSD_CF,
	ESB_CF = B.ACCESB_CF,
	CED_NF = B.CED_NF,
	BRK_NF = B.GENPRMSEN_NF,
	GEMPRMPAY_NF = B.GENPRMPAY_NF,
	GANPAYORD_NT = B.GANPAYORD_NT
from	BTRAV..TESTUTISUD A, BTRT..TCONTR B
where	A.CTR_NF = B.CTR_NF
and	A.END_NT = B.END_NT
and	A.UWY_NF = B.UWY_NF
and	A.UW_NT = B.UW_NT

select @erreur = @@error

if @erreur != 0  goto fin


/*************************************/
/* 2ème ETAPE: CONTROLE DE COHERENCE */
/*************************************/

insert into #TACCSUP1
select	TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
	BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
	END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF	, CLM_NF,
	CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
	RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
	RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT,	COMMAC_LL, CRE_D,
	CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
from	BTRAV..TESTUTISUD
where	CTR_NF != NULL
and	RETCTR_NF = NULL
and	PLC_NT = NULL
and	VALPERY_NF = BALSHEY_NF
and 	VALPERMTH_NF >= 1
and	VALPERMTH_NF <= 12
and 	VALPERMTH_NF >= ENTPERMTH_NF
and	VALPERMTH_NF <= BALSHRMTH_NF
and	RETAUTGEN_B = 1
and	SCOSTRMTH_NF <= SCOENDMTH_NF
and	BALSHEY_NF = ENTPERY_NF
and	BALSHRMTH_NF >= 1
and	BALSHRMTH_NF <= 12
and	BALSHRMTH_NF = ENTPERMTH_NF
and	BALSHRDAY_NF = datepart( dd, dateadd( dd, -1, dateadd( mm, +1, convert( char(6), BALSHEY_NF * 100+ BALSHRMTH_NF ) + '01' ) ) )
and	ACY_NF = BALSHEY_NF
and	SCOSTRMTH_NF = BALSHRMTH_NF
and	SCOENDMTH_NF = BALSHRMTH_NF

select @erreur = @@error

if @erreur != 0  goto fin


/* Comparaison du nombre de lignes des tables TESTUTISUD et #TACCSUP1 */
/* ------------------------------------------------------------------ */

select @nbligne_tempaccsup = count(*) from #TACCSUP1

if ( @nbligne_tempaccsup != @nbligne_testutisud )
	begin
	/* génération d'une anomalie et sortie de la procédure */
	raiserror 20113 "Anomalie(s) liee(s) aux periodes de validite, libelle d'inventaire, periode de compte acceptation, periode de compte retrocession ou poste comptable"
	goto fin
	return 0
	end


/***************************************************/
/* 3ème ETAPE: CONTROLE DE PRESENCE DANS LES BASES */
/***************************************************/

/* Accès à la table BFAC..TSECTION pour les affaires acceptation renseignées uniquement */
/* ------------------------------------------------------------------------------------ */

insert into #TACCSUP2
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
	A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
	A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
	A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
	A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
	A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,	A.COMMAC_LL, A.CRE_D,
	A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF
from	#TACCSUP1 A, BFAC..TSECTION B
where
    --substring( A.CTR_NF, 3, 1 ) between 'A' and 'M' --[002]
   	A.CTR_NF = B.CTR_NF
and	A.END_NT = B.END_NT
and	A.SEC_NF = B.SEC_NF
and	A.UWY_NF = B.UWY_NF
and	A.UW_NT = B.UW_NT

select @erreur = @@error

if @erreur != 0  goto fin


/* Accès à la table BTRT..TSECTION pour les affaires acceptation renseignées uniquement */
/* ------------------------------------------------------------------------------------ */

insert into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
	A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
	A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
	A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
	A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
	A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,	A.COMMAC_LL, A.CRE_D,
	A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF
from	#TACCSUP1 A, BTRT..TSECTION B
where
     --substring( A.CTR_NF, 3, 1 ) not between 'A' and 'M' --[002]
   	A.CTR_NF = B.CTR_NF
and	A.END_NT = B.END_NT
and	A.SEC_NF = B.SEC_NF
and	A.UWY_NF = B.UWY_NF
and	A.UW_NT = B.UW_NT

select @erreur = @@error

if @erreur != 0  goto fin


/* Comparaison du nombre de lignes des tables TESTUTISUD et #TACCSUP2 */
/* ------------------------------------------------------------------ */

select @nbligne_tempaccsup = count(*) from #TACCSUP2

if ( @nbligne_tempaccsup != @nbligne_testutisud )
	begin
	/* génération d'une anomalie et sortie de la procédure */
	raiserror 20114 "Certaine(s) affaire(s) ne sont pas referencees dans les bases"
	goto fin
	end


/* Purge de la table #TACCSUP1 avant réutilisation */
/* ----------------------------------------------- */

delete #TACCSUP1


/* Vérification du poste comptable : "11494102" */
/* -------------------------------------------- */

insert into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
	A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, B.CTRSCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
	A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
	A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
	A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
	A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,	A.COMMAC_LL, A.CRE_D,
	A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF
from	#TACCSUP2 A, BREF..TDETTRS B
where	A.TRNCOD_CF = "11494102"
and	A.TRNCOD_CF = B.DETTRS_CF

select @erreur = @@error

if @erreur != 0  goto fin


/* Comparaison du nombre de lignes des tables TESTUTISUD et #TACCSUP1 */
/* ------------------------------------------------------------------ */

select @nbligne_tempaccsup = count(*) from #TACCSUP1

if ( @nbligne_tempaccsup != @nbligne_testutisud )
	begin
	/* génération d'une anomalie et sortie de la procédure */
	raiserror 20116 "Le poste comptable est différent de 11494102 ou n'existe pas dans BREF..TDETTRS"
	goto fin
	end


/* Purge de la table #TACCSUP2 avant réutilisation */
/* ----------------------------------------------- */

delete #TACCSUP2


/* Accès à la table BREF..TCURQUOT ( affaire acceptation renseignée ) pour contrôler CUR_CF */
/* ---------------------------------------------------------------------------------------- */

insert into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
	A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
	A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
	A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
	A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
	A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,	A.COMMAC_LL, A.CRE_D,
	A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF
from	#TACCSUP1 A
where	exists(
	select 1 from BREF..TCURQUOT B
	where	A.CUR_CF = B.CUR_CF
	and 	A.SSD_CF = B.SSD_CF )
and     not exists(
        select 1 from BREF..TEUROCUR C
        where   A.CUR_CF = C.CUR_CF
        and     A.CUR_CF != 'EUR' )

select @erreur = @@error

if @erreur != 0  goto fin


/* Comparaison du nombre de lignes des tables TESTUTISUD et #TACCSUP2 */
/* ------------------------------------------------------------------ */

select @nbligne_tempaccsup = count(*) from #TACCSUP2

if ( @nbligne_tempaccsup != @nbligne_testutisud )
	begin
	/* génération d'une anomalie et sortie de la procédure */
	raiserror 20117 "Certaine(s) monnaie(s) ne sont pas referencees dans la table BREF..TCURQUOT"
	goto fin
	end


/************************************************/
/* 4ème ETAPE: DETERMINATION DU TYPE D'ECRITURE */
/************************************************/

/* Ecritures de type 99 */
/* ------------------- */

update #TACCSUP2
set	ACCTYP_NF = 99

select @erreur = @@error

if @erreur != 0  goto fin


/*****************************************************************************************************/
/* Suppression des écritures dans TACCSUP de type 98 et 99 où période comptable >= période de saisie */
/*****************************************************************************************************/

delete	 BEST..TACCSUP
where	 SSD_CF = @p_ssd_cf
and	 ( ACCTYP_NF = 98 or ACCTYP_NF = 99 )
and	 ( ( BALSHEY_NF > @entpery_nf ) or ( ( BALSHEY_NF = @entpery_nf ) and ( BALSHRMTH_NF >= @entpermth_nf ) ) )

select @erreur = @@error

if @erreur != 0  goto fin


/*********************************************/
/* Gestion du compteur pour le champs TRN_NT */
/*********************************************/

/* recherche du numéro de ligne maxi dans BEST..TACCSUP */

select @max_trn_nt = max( TRN_NT )
from 	BEST..TACCSUP


/* insertion dans la #TACCSUP3 */

insert into #TACCSUP3
	( ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF,
	VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF, END_NT, SEC_NF,
	UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF,	CUR_CF, AMT_M,
	CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
	RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
	RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
	CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF )
select ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF,
	VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF, END_NT, SEC_NF,
	UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF,	CUR_CF, AMT_M,
	CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
	RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
	RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
	CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
from	#TACCSUP2

select @erreur = @@error

if @erreur != 0  goto fin


/***********************************************************************/
/* Insertion dans la table BEST..TACCSUP si tous les contrôles sont OK */
/***********************************************************************/

insert into BEST..TACCSUP
	( TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
	BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
	END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF,	CUR_CF, AMT_M,
	CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RETRTY_NF,
	RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
	RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
	CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF )
select TRN_NT + @max_trn_nt, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF,
	BALSHRMTH_NF, BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B,
	CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF,
	CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT,
	RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,
	ACCTRN_NT, COMMAC_LL, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
from	#TACCSUP3

select @erreur = @@error

if @erreur != 0  goto fin


/**********************************************************************************/


/* ------------------------------------------------------------
   Fin de la transaction
 -------------------------------------------------------------- */

if @tran_imbr = 0
	 COMMIT TRAN

return 0


fin:
if @tran_imbr = 0
	 ROLLBACK TRAN

return 1

go
IF OBJECT_ID('PiACCSUP_03') IS NOT NULL
    PRINT '<<< CREATED PROC PiACCSUP_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PiACCSUP_03 >>>'
go
/*
 * Granting/Revoking Permissions on PiACCSUP_03
 */
GRANT EXECUTE ON PiACCSUP_03 TO GOMEGA
go

