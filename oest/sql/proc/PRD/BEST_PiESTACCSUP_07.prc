USE BEST
go
IF OBJECT_ID('PiESTACCSUP_07') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_07
  PRINT '<<< DROPPED PROC PiESTACCSUP_07 >>>'
END
go
create procedure PiESTACCSUP_07(
@p_cre_d datetime -- date de lancement de la chaîne
)
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: S.Behague
Date de creation: 31/08/2020
Description du programme: 	
	- sélection des écritures de services pour recalcul dans la chaine ESIJ0790.cmd
Conditions d'execution: 
Commentaires: Creation à partir de PiESTACCSUP_01
_________________
[01]  02/09/2029 SBE  :spira:87674 IFRS 17 - Omega SAP interface - SAS Engine transactions management 
[02]  17/03/2021 SBE  :spira:94451 I17: AE - Delta used IFRS 4 closing date instead of IFRS 17 one - Copy for INT temporary fix

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
truncate table BTRAV..EST_ESFD0070_TACCSUP
truncate table BTRAV..EST_ESFJ0090_TESTCES
truncate table BTRAV..EST_ESFJ0090_TESTPLC

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
insert into BTRAV..EST_ESFD0070_TACCSUP
select  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
    BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
    END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF    , CLM_NF,
    CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
    RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
    RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT,   COMMAC_LL, CRE_D,
    CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
from    BEST..TACCSUP
where   ( ACCTYP_NF=1 or ACCTYP_NF=99 )
and RETAUTGEN_B=1 and SPEENTNAT_CT in(9,10,11)   AND SPEENTTYP_CF in (8, 9)
and ( VALPERY_NF > @blcshtyea_nf or
    ( VALPERY_NF=@blcshtyea_nf and VALPERMTH_NF >= @blcshtmth_nf ) )
and SSD_CF in ( select T.SSD_CF from BREF..TBATCHSSD T where T.BATCHUSER_CF=suser_name() )
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
delete  BEST..TACCSUP
from    BEST..TACCSUP A, BTRAV..EST_ESFD0070_TACCSUP B
where   B.TRN_NT = A.ACCTRN_NT
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
from    BTRAV..EST_ESFD0070_TACCSUP

return 0

fin:
if @tran_imbr=0 rollback tran
return 1
go
if object_id('PiESTACCSUP_07') is not null
  print '<<< CREATED PROC PiESTACCSUP_07 >>>'
else
  print '<<< FAILED CREATING PROC PiESTACCSUP_07 >>>'
go
grant execute on PiESTACCSUP_07 TO GOMEGA
go
grant execute on PiESTACCSUP_07 TO GDBBATCH
go
