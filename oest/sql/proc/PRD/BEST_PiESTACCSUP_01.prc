use BEST
go
if object_id('PiESTACCSUP_01') is not null
begin
  drop PROC PiESTACCSUP_01
  print '<<< DROPPED PROC PiESTACCSUP_01 >>>'
end
go
create procedure PiESTACCSUP_01
(
@p_cre_d datetime -- date de lancement de la chaîne
)
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation: 01/10/97
Description du programme: - recherche de la période comptable en cours
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  M.DJELLOULI 26/04/2005 :SPOT:5084 - Ajout Zone SPEENTTYP_CF - MOD001
2  M.DJELLOULI 27/04/2005 :SPOT:11445 - EST_ESIJ0090_TESTPLC remplace  TESTPLC, EST_ESIJ0090_TESTCES remplace TESTCES,
                          EST_ESIJ0090_TACCSUP remplace TESTACCSUP - MOD002
3  M.DJELLOULI 24/06/2005 :SPOT:5085 - Ajout Zone SPEENTNAT_CT - MOD003
4  JF VDV      23/05/2012 :spot:23390 - SOLVENCY aménagements
5  Pune        03/10/2013 Removed dbo and added ‘with execute as caller as’
6  Florent     09/12/2013 :spot:25427 - maj partition
[007] 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
[001] 18/10/2022 M.NAJI :spira 107371 optimisation
*****************************************************/
declare
  @erreur         int,
  @tran_imbr  bit,
  @blcshtyea_nf   int,        /* année de la période comptable en cours */
  @blcshtmth_nf tinyint,  /* mois de la période comptable en cours */
  @spcend_d   datetime,   /* variable de sortie de PsCALEND_02 */
  @account_d  datetime,   /* variable de sortie de PsCALEND_02 */
  @closing_b      bit         /* variable de sortie de PsCALEND_02 */

select @erreur=0
select @tran_imbr=1

---------------------------------
-- Truncate des tables de travail
---------------------------------
truncate table BTRAV..EST_ESIJ0090_TACCSUP  -- MOD002
truncate table BTRAV..EST_ESIJ0090_TESTCES
truncate table BTRAV..EST_ESIJ0090_TESTPLC

---------------------------------------------
-- Recherche de la période comptable en cours
---------------------------------------------
execute @erreur=BREF..PsCALEND_02
            @p_cre_d,
            'C',
            @blcshtyea_nf output,
            @blcshtmth_nf output,
            @spcend_d output,
            @account_d output,
            @closing_b output
if @erreur != 0  goto fin

------------------------------------------
-- Sélection des écritures de service
---------------------------------------------
insert into BTRAV..EST_ESIJ0090_TACCSUP
select  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
    BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
    END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF    , CLM_NF,
    CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
    RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
    RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT,   COMMAC_LL, CRE_D,
    CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF      -- MOD001  [007]
from    BEST..TACCSUP
where   ( ACCTYP_NF=1 or ACCTYP_NF=99 )
and RETAUTGEN_B=1 and SPEENTNAT_CT in(1,4)    -- modif 4
and ( VALPERY_NF > @blcshtyea_nf or
    ( VALPERY_NF=@blcshtyea_nf and VALPERMTH_NF >= @blcshtmth_nf ) )
and SSD_CF in ( select T.SSD_CF from BREF..TBATCHSSD T where T.BATCHUSER_CF=suser_name() ) -- modif 6
select @erreur=@@error
if @erreur != 0  goto fin

------------------------------------------------------------
-- Début de la transaction
------------------------------------------------------------
if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end

------------------------------------------------------------------
-- Mise à jour de la table des écritures de services BEST..TACCSUP
------------------------------------------------------------------
execute @erreur=BEST..PdACCSUP_02 with recompile
select @erreur=@@error
if @erreur != 0  goto fin

------------------------------------------------------------
-- Fin de la transaction
------------------------------------------------------------
if @tran_imbr=0 commit tran

-----------------------------------
-- Descente de la table en fichiers
-----------------------------------
select TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
    BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
    END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF    , CLM_NF,
    CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
    RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
    RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT,   COMMAC_LL,
    convert( char(8), CRE_D, 112 ), CREUSR_CF, convert( char(8), LSTUPD_D, 112 ), LSTUPDUSR_CF ,
    SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF   -- MOD001 [007]
from    BTRAV..EST_ESIJ0090_TACCSUP

return 0

fin:
if @tran_imbr=0 rollback tran
return 1
go
if object_id('PiESTACCSUP_01') is not null
  print '<<< CREATED PROC PiESTACCSUP_01 >>>'
else
  print '<<< FAILED CREATING PROC PiESTACCSUP_01 >>>'
go
grant execute on PiESTACCSUP_01 TO GOMEGA
go
grant execute on PiESTACCSUP_01 TO GDBBATCH
go
