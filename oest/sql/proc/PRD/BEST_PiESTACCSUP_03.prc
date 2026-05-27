USE BEST
Go

/*
 * DROP PROC PiESTACCSUP_03
 */
IF OBJECT_ID('PiESTACCSUP_03') IS NOT NULL
BEGIN
    DROP PROC PiESTACCSUP_03
    PRINT '<<< DROPPED PROC PiESTACCSUP_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiESTACCSUP_03(
	@p_cre_d 	datetime,
	@p_trn_nt	numeric(10,0) )
     
with execute as caller as

/***************************************************

Programme: PiESTACCSUP_03

Fichier script associé : ESIACC04.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 01/10/97

Description du programme: 
	- recherche de la période comptable en cours
     	- sélection des écritures de services

Parametres:
 	- date de lancement de la chaîne


Conditions d'execution: 
	- cette procédure est appelée par le batch asynchrone de génération rétro


Commentaires:

_________________
MODIFICATION 1
Auteur:     M.DJELLOULI - MOD001
Date:        26/04/2005
Description: SPOT 5084 - Ajout Zone SPEENTTYP_CF

_________________
MODIFICATION 2
Auteur:     M.DJELLOULI - MOD001
Date:        27/04/2005
Description: SPOT 11445 - EST_ESIJ0090_TESTPLC remplace  TESTPLC
                                    EST_ESIJ0090_TESTCES remplace TESTCES
                                    EST_ESIJ0090_TACCSUP remplace TESTACCSUP
_________________
MODIFICATION 3
Auteur:     M.DJELLOULI - MOD003
Date:        24/06/2005
Description: SPOT 5085 - Ajout Zone SPEENTNAT_CT

_________________
MODIFICATION
Auteur:         JF VDV
Date:           23/05/2012
Version:
Description:    [23390] - SOLVENCY aménagements
_________________
MODIFICATION - Removed dbo and added ‘with execute as caller as’
[005] 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
*****************************************************/


declare 	@erreur     	int,
        	@tran_imbr	bit,
		@blcshtyea_nf	int,		/* année de la période comptable en cours */
		@blcshtmth_nf tinyint,	/* mois de la période comptable en cours */
  		@spcend_d 	datetime,	/* variable de sortie de PsCALEND_02 */
  		@account_d 	datetime,	/* variable de sortie de PsCALEND_02 */
		@closing_b  	bit     	/* variable de sortie de PsCALEND_02 */


select @erreur = 0
select @tran_imbr = 1


/* ------------------------------
   Truncate des tables de travail
   ------------------------------ */

truncate table BTRAV..EST_ESIJ0090_TACCSUP
truncate table BTRAV..EST_ESIJ0090_TESTCES
truncate table BTRAV..EST_ESIJ0090_TESTPLC


/* ------------------------------------------------------------
   Début de la transaction
 -------------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


/* ---------------------------------------------
   Recherche de la période comptable en cours
--------------------------------------------- */

Execute @erreur = BREF..PsCALEND_02 
			@p_cre_d, 
			'C',
			@blcshtyea_nf output,
        		@blcshtmth_nf output,
			@spcend_d output,
			@account_d output,
			@closing_b output

if @erreur != 0  goto fin


/* ---------------------------------------------
   Sélection des écritures de service
--------------------------------------------- */

insert into BTRAV..EST_ESIJ0090_TACCSUP
select	TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
	BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
	END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF	, CLM_NF,	
	CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
	RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,	
	RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT,	COMMAC_LL, CRE_D,
      CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF      -- MOD001  [007]
from	BEST..TACCSUP
where	TRN_NT = @p_trn_nt
and	( ACCTYP_NF = 1 or ACCTYP_NF = 99 )
and	RETAUTGEN_B = 1
and	( VALPERY_NF > @blcshtyea_nf or 
	( VALPERY_NF = @blcshtyea_nf and VALPERMTH_NF >= @blcshtmth_nf ) )
and SPEENTNAT_CT in (1,4)		-- [23390]

select @erreur = @@error

if @erreur != 0  goto fin


/* ------------------------------------------------------------------
   Mise à jour de la table des écritures de services BEST..TACCSUP
------------------------------------------------------------------ */

delete	BEST..TACCSUP
from 	BEST..TACCSUP A, BTRAV..EST_ESIJ0090_TACCSUP B
where	B.TRN_NT = A.ACCTRN_NT

select @erreur = @@error

if @erreur != 0  goto fin


/* -----------------------------------
   Descente de la table en fichiers
----------------------------------- */

select TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
	BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
	END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF	, CLM_NF,	
	CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
	RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,	
	RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT,	COMMAC_LL, 
	convert( char(8), CRE_D, 112 ), CREUSR_CF, convert( char(8), LSTUPD_D, 112 ), LSTUPDUSR_CF  , SPEENTTYP_CF, SPEENTNAT_CT,
	EVT_NF, REVT_NF      -- MOD001  [007]
from	BTRAV..EST_ESIJ0090_TACCSUP


                 
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

/*
 * fin de la procedure 
 */


/*   Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESIACC04', 'PiESTACCSUP_03', 'BEST', 'ME69'
go

IF OBJECT_ID('PiESTACCSUP_03') IS NOT NULL
    PRINT '<<< CREATED PROC PiESTACCSUP_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PiESTACCSUP_03 >>>'
go
/*
 * Granting/Revoking Permissions on PiESTACCSUP_03
 */
GRANT EXECUTE ON PiESTACCSUP_03 TO GOMEGA
go
GRANT EXECUTE ON PiESTACCSUP_03 TO GDBBATCH
go

