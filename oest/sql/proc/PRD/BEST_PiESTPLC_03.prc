USE BEST
go
IF OBJECT_ID('PiESTPLC_03') IS NOT NULL
BEGIN
  DROP PROC PiESTPLC_03
  PRINT '<<< DROPPED PROC PiESTPLC_03 >>>'
END
go
create procedure PiESTPLC_03
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1 Copie de PiESTPLC_01
[01]  26/08/2029 SBE  :spira:87674 IFRS 17 - Omega SAP interface - SAS Engine transactions management 
*****************************************************/
declare   @erreur       int,
          @tran_imbr  bit

select @erreur = 0
select @tran_imbr = 1

/* ------------------------------------------------------------
   Début de la transaction
 -------------------------------------------------------------- */
if @@trancount = 0
begin
 select @tran_imbr = 0
 BEGIN TRAN
end

/* -------------------------------------------------------
   Sélection des placements dans la table BRET..TPLACEMT
-------------------------------------------------------- */
insert  into BTRAV..EST_ESFJ0090_TESTPLC
  (    RETCTR_NF,
     RETEND_NT,
     RETSEC_NF,
     RTY_NF,
     RETUW_NT,
     PLC_NT,
     OVRCOM_R,
     RTO_NF,
     INT_NF,
     PAY_NF,
     KEY_CF,
     SSDRTO_B,
     RETSIGSHA_R,
     LOB_CF,
     RETOVRCOM_B ,
     FIXCOM_R,
     BASIS_NT,
     OVRBASIS_NT)

select  distinct C.RETCTR_NF,
         C.RETEND_NT,
         C.RETSEC_NF,
         C.RTY_NF,
         C.RETUW_NT,
         A.PLC_NT,
         A.OVRCOM_R,
         A.RTO_NF,
         A.INT_NF,
         A.PAY_NF,
         A.KEY_CF,
         A.SSDRTO_B,
         A.RETSIGSHA_R,
         C.LOB_CF,
         A.RETOVRCOM_B,
         A.FIXCOM_R,
         A.BASIS_NT,
         A.OVRBASIS_NT
         from BRET..TPLACEMT A, BTRAV..EST_ESFJ0090_TESTCES C
         where  C.RETCTR_NF = A.RETCTR_NF
         and  C.RTY_NF = A.RTY_NF
         and  ( A.PLCSTS_CT = 16 or A.PLCSTS_CT = 19 )
         and  A.ACCPLC_B = 1
         and  A.HIS_B = 0
select @erreur = @@error
if @erreur != 0  goto fin

/* -------------------------------------------------------
   Suppression des placements rachetés
-------------------------------------------------------- */
delete BTRAV..EST_ESFJ0090_TESTPLC
from  BTRAV..EST_ESFJ0090_TESTPLC A
where exists (
  select  1
  from  BRET..TCMUPLCT D, BRET..TCOMMUT E
  where A.RETCTR_NF = D.RETCTR_NF
  and   A.RTY_NF = D.RTY_NF
  and A.PLC_NT = D.PLC_NT
  and A.LOB_CF = D.LOB_CF
  and D.RETCTR_NF = E.RETCTR_NF
  and D.CMU_NT = E.CMU_NT
  and D.INICMUVER_CT = 0
  and E.CMUCALSTS_CF = "05" )
select @erreur = @@error
if @erreur != 0  goto fin

/* -----------------------------------------
   Jointure avec la table BRET..TRETCTR
----------------------------------------- */
update  BTRAV..EST_ESFJ0090_TESTPLC
set A.SSD_CF = B.SSD_CF,
  A.ESB_CF = B.ESB_CF,
  A.ORICUR_B = B.ORICUR_B,
  A.RAICOM_B = B.RAICOM_B
from  BTRAV..EST_ESFJ0090_TESTPLC A, BRET..TRETCTR B
where A.RETCTR_NF = B.RETCTR_NF
and A.RTY_NF = B.RTY_NF
select @erreur = @@error
if @erreur != 0  goto fin

/* --------------------------------------------------------------------------
   Mise à jour de RAICOM_B si les conditions ne sont pas au niveau contrat
-------------------------------------------------------------------------- */
update  BTRAV..EST_ESFJ0090_TESTPLC
set A.RAICOM_B = B.RAICOM_B
from  BTRAV..EST_ESFJ0090_TESTPLC A, BRET..TPLACEMT B
where A.RETCTR_NF = B.RETCTR_NF
and A.RTY_NF = B.RTY_NF
and   B.CTRCOMCON_B = 0
select @erreur = @@error
if @erreur != 0  goto fin

/* ---------------------------------------------------
   Descente de la table BTRAV..EST_ESFJ0090_TESTPLC en fichier
---------------------------------------------------- */
select  SSD_CF,
    ESB_CF,
    RETCTR_NF,
    RETEND_NT,
    RETSEC_NF,
    RTY_NF,
    RETUW_NT,
    PLC_NT,
    OVRCOM_R,
    RTO_NF,
    INT_NF,
    PAY_NF,
    KEY_CF,
    ORICUR_B,
    SSDRTO_B,
    RETSIGSHA_R,
    LOB_CF,
    RAICOM_B,
    RETOVRCOM_B,
    '',  -- PLA_CTR_NF 19
    '', --PLA_END_NT 20
    '', --PLA_SEC_NF 21
    '', --PLA_UWY_NF 22
    '', --PLA_UW_NT 23
    '', --PLA_CUR_CF 24
    '', --PLA_CESSH_R 25
    '', --PLA_CLMFUN_R 26
    '', --PLA_URRFUN_R 27
    '', --PLA_CLMFUNINT_R 28
    '', --PLA_URRFUNINT_R 29
    '', --PLA_CONRETCTR_B 30
    '', --PLA_DEPORI_B 31
    '', --PLA_RTOCTY_CF 32
    BASIS_NT,
    OVRBASIS_NT,
    FIXCOM_R
from
BTRAV..EST_ESFJ0090_TESTPLC

-- Fin de la transaction
if @tran_imbr = 0
   COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN
return 1
go
IF OBJECT_ID('PiESTPLC_03') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTPLC_03 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTPLC_03 >>>'
go
GRANT EXECUTE ON PiESTPLC_03 TO GOMEGA,GDBBATCH
go
