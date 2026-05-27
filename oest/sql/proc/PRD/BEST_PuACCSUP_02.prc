USE BEST
Go
 /* DROP PROC PuACCSUP_02
*/
IF OBJECT_ID('PuACCSUP_02') IS NOT NULL
   BEGIN
   DROP PROC PuACCSUP_02
   PRINT '<<< DROPPED PROC PuACCSUP_02 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PuACCSUP_02
     (
       @p_trnmax_nt  numeric(10, 0)
     )

as

/***************************************************
Programme: PuACCSUP_02
Fichier script associé : ESUACC01.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME69 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
	- Mise a jour du poste de contre-partie pour les ecritures générées

Parametres:
       - @p_trnmax_nt : TRN_NT de TACCSUP maxi avant insertion des lignes générées

Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1 - MOD01
Auteur:	M.DJELLOULI
Date:	24/01/2006
Version:
Description:	SPOT 12408 - Correction de la CRE_D sur les lignes nouvellement Générés
_________________
MODIFICATION 2 - MOD02
Auteur:	M.DJELLOULI
Date:	08/02/2006
Version:
Description:	Correction Suite à Plantage INSERT INTO #TACCSUP
[003] 08/08/2013 R. CASSIS :spot:25427 - Ajout jointure table tbatchssd pour Omega2
[004] 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1

CREATE TABLE #TACCSUP
(
    TRN_NT          numeric(10,0) NOT NULL,
    ACCTYP_NF       tinyint       NOT NULL,
    SSD_CF          USSD_CF       NOT NULL,
    ESB_CF          UESB_CF       NOT NULL,
    ENTPERY_NF      smallint      NOT NULL,
    ENTPERMTH_NF    tinyint       NOT NULL,
    BALSHEY_NF      smallint      NOT NULL,
    BALSHRMTH_NF    tinyint       NOT NULL,
    BALSHRDAY_NF    tinyint       NOT NULL,
    VALPERY_NF      smallint      NOT NULL,
    VALPERMTH_NF    tinyint       NOT NULL,
    TRNCOD_CF       UDETTRS_CF    DEFAULT '' NOT NULL,
    DBLTRNCOD_CF    UDETTRS_CF    NULL,
    RETAUTGEN_B     bit           DEFAULT 0 NOT NULL,
    CTR_NF          UCTR_NF       NULL,
    END_NT          UEND_NT       NULL,
    SEC_NF          USEC_NF       NULL,
    UWY_NF          UUWY_NF       NULL,
    UW_NT           UUW_NT        NULL,
    OCCYEA_NF       smallint      NULL,
    ACY_NF          smallint      NULL,
    SCOSTRMTH_NF    tinyint       NULL,
    SCOENDMTH_NF    tinyint       NULL,
    CLM_NF          UCLM_NF       NULL,
    CUR_CF          UCUR_CF       NULL,
    AMT_M           UAMT_M        NULL,
    CED_NF          UCLI_NF       NULL,
    BRK_NF          UCLI_NF       NULL,
    GEMPRMPAY_NF    UCLI_NF       NULL,
    GANPAYORD_NT    UPAYORD_NT    NULL,
    RETCTR_NF       URETCTR_NF    NULL,
    RETEND_NT       tinyint       NULL,
    RETSEC_NF       URETSEC_NF    NULL,
    RETRTY_NF       UUWY_NF       NULL,
    RETUW_NT        tinyint       NULL,
    PLC_NT          UPLC_NT       NULL,
    RETOCCYEA_NF    smallint      NULL,
    RETACY_NF       smallint      NULL,
    RETSCOSTRMTH_NF tinyint       NULL,
    RETSCOENDMTH_NF tinyint       NULL,
    RCL_NF          UCLM_NF       NULL,
    RETCUR_CF       UCUR_CF       NULL,
    RETAMT_M        UAMT_M        NULL,
    RTO_NF          UCLI_NF       NULL,
    INT_NF          UCLI_NF       NULL,
    RETPAY_NF       UCLI_NF       NULL,
    RETKEY_CF       char(1)       NULL,
    ACCTRN_NT       numeric(10,0) NULL,
    COMMAC_LL       UL64          NULL,
    CRE_D           UUPD_D        DEFAULT getdate() NOT NULL,
    CREUSR_CF       UUPDUSR_CF    DEFAULT user NOT NULL,
    LSTUPD_D        UUPD_D        DEFAULT getdate() NOT NULL,
    LSTUPDUSR_CF    UUPDUSR_CF    DEFAULT user NOT NULL,
    SPEENTTYP_CF    tinyint       NULL,
    SPEENTNAT_CT    tinyint       DEFAULT 1 NOT NULL,
    EVT_NF          varchar(10)   NULL,    --[004]
    REVT_NF         varchar(10)   NULL     --(004]
)


-- Debut MOD01 - M.DJELLOULI - 24/01/2006
-- Préselection des Lignes Rétro Générées
-- La Rétrogénérée est à priori >= TRN_NT existant !
--SELECT *
--INTO #TACCSUP
--FROM BEST..TACCSUP A
--WHERE ACCTRN_NT IN (SELECT TRN_NT FROM BEST..TACCSUP B)
--  and TRN_NT >= @p_trnmax_nt

-- MOD002
--[003]
INSERT INTO #TACCSUP
  (TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF,
  TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF,
  CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RETRTY_NF, RETUW_NT, PLC_NT,
  RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,
  ACCTRN_NT, COMMAC_LL, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF)  --[004]
SELECT
  TRN_NT, ACCTYP_NF, A.SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF,
  TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF,
  CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RETRTY_NF, RETUW_NT, PLC_NT,
  RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,
  ACCTRN_NT, COMMAC_LL, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF  --[004]
FROM BEST..TACCSUP A, BREF..TBATCHSSD X
WHERE ACCTRN_NT IN (SELECT TRN_NT FROM BEST..TACCSUP B)
and   TRN_NT >= @p_trnmax_nt
and   A.SSD_CF = X.SSD_CF
and   X.BATCHUSER_CF = suser_name()

select @erreur = @@error
if @erreur != 0  goto fin

-- Maj Temporaire des Lignes Rétro Générées
UPDATE #TACCSUP
SET CRE_D = A.CRE_D, CREUSR_CF = A.LSTUPDUSR_CF, LSTUPDUSR_CF = "dbo"    -- On utilise LSTUPDUSR_CF à la place de CREUSR_CF
FROM #TACCSUP B, BEST..TACCSUP A
WHERE A.TRN_NT = B.ACCTRN_NT

select @erreur = @@error
if @erreur != 0  goto fin

/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_imbr = 0
  BEGIN TRAN
  end

/* ----------------------------------------------------------------
   Mise a jour de la table des montants stats par exercice (TUNDSTA)
   ---------------------------------------------------------------- */

--[003]
update	BEST..TACCSUP
set	A.DBLTRNCOD_CF = B.CTRSCOD_CF
from	BEST..TACCSUP A, BREF..TDETTRS B, BREF..TBATCHSSD C
where	A.TRN_NT > @p_trnmax_nt
and	A.TRNCOD_CF = B.DETTRS_CF
and   A.SSD_CF = C.SSD_CF
and   C.BATCHUSER_CF = suser_name()

select @erreur = @@error

if @erreur != 0  goto fin

-- Maj Finale de la TABLE BEST..TACCSUP
UPDATE BEST..TACCSUP
SET CRE_D = A.CRE_D, CREUSR_CF = A.CREUSR_CF, LSTUPDUSR_CF = "dbo"
FROM #TACCSUP A, BEST..TACCSUP B
WHERE A.TRN_NT = B.TRN_NT

select @erreur = @@error
if @erreur != 0  goto fin

-- Fin MOD01

/**********************************************************************************/

if @tran_imbr = 0
	COMMIT TRAN

return @erreur

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/


IF OBJECT_ID('PuACCSUP_02') IS NOT NULL
   PRINT '<<< CREATED PROC PuACCSUP_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PuACCSUP_02 >>>'
go
/*
 * Granting/Revoking Permissions on PuACCSUP_02
 */
GRANT EXECUTE ON PuACCSUP_02 TO GOMEGA
go
GRANT EXECUTE ON PuACCSUP_02 TO GDBBATCH
go

