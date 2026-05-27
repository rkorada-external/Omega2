use BEST
go
IF OBJECT_ID('PsACCTRN_01') IS NOT NULL
BEGIN
  DROP PROC PsACCTRN_01
  PRINT '<<< DROPPED PROC PsACCTRN_01 >>>'
END
go
create procedure PsACCTRN_01
as
/***************************************************
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     ME69 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:   Sélection d'enregistrement dans TACCTRNE
_________________
MODIFICATION
[01] Florent     16/10/1997 Pour préfixer le nom de la proc par BEST puisqu'elle est temporairement dans BCTA
[02] J.Ribot     24/01/2003 ajout 0.000 (derniere colonne du select final) pour montant retro interne dans GT
[03] D.GATIBELZA 02/02/2011 1GL
[04] R. CASSIS   18/03/2011 :spot:21408 On met origine GTA dans le 16eme champ ajouté
[05] JF VDV      19/06/2012 :spot:23908 formattage des mois & jour bilan sur deux caracteres avec un "0" eventuellement devant
[06] R. CASSIS   08/08/2013 :spot:25427 Ajout jointure table tbatchssd pour Omega2
[07] Florent     14/01/2016 :spot:29066 ajout colonnes GT
*****************************************************/
declare @erreur int

-- On selectionne les mouvements  quotidien de BCTA..TACCTRN flagués dans BCTA..TDRYTRN
-- on l'enrichissant avec d'autres info du contrat acceptation
-- UNION ALL est utilisé car le contrat peut être FAC ou Traité
CREATE TABLE #GTA (
    TRN_NT          numeric(10,0)   NOT NULL,
    SSD_CF          USSD_CF         NOT NULL,
    ESB_CF          UESB_CF         NOT NULL,
    BLCSHT_D        datetime            NULL,
    TRNCOD_CF       UDETTRS_CF                  DEFAULT '',
    CTRNCOD_CF      UDETTRS_CF                  DEFAULT '',
    CTR_NF          UCTR_NF         NOT NULL,
    END_NT          UEND_NT                     DEFAULT 0,
    SEC_NF          USEC_NF             NULL,
    UWY_NF          UUWY_NF         NOT NULL,
    UW_NT           UUW_NT                      DEFAULT 1,
    OCCYEA_NF       smallint            NULL,
    ACY_NF          smallint        NOT NULL,
    SCOSTRMTH_NF    tinyint         NOT NULL,
    SCOENDMTH_NF    tinyint         NOT NULL,
    CLM_NF          int                 NULL,
    CUR_CF          UCUR_CF                     DEFAULT '',
    ORICURAMT_M     UAMT_M          NOT NULL,
    CED_NF          UCLI_NF         NOT NULL,
    PRD_NF          UCLI_NF             NULL,
    GENPRMPAY_NF    UCLI_NF             NULL,
    GANPAYORD_NT    UPAYORD_NT                  DEFAULT 'A',
    TRNSTS_CT       tinyint         NOT NULL
)

insert into	#GTA
select dry.TRN_NT,
       dry.SSD_CF,
       dry.ESB_CF,
       acc.BLCSHT_D,
       acc.TRNCOD_CF,
       acc.CTRNCOD_CF,
       acc.CTR_NF,
       acc.END_NT,
       acc.SEC_NF,
       acc.UWY_NF,
       acc.UW_NT,
       acc.OCCYEA_NF,
       acc.ACY_NF,
       acc.SCOSTRMTH_NF,
       acc.SCOENDMTH_NF,
       acc.CLM_NF,
       acc.CUR_CF,
       acc.ORICURAMT_M,
       acc.CED_NF,
       ctr.PRD_NF,
       ctr.GENPRMPAY_NF,
       ctr.GANPAYORD_NT,
       acc.TRNSTS_CT
from BCTA..TDRYTRN dry, BCTA..TACCTRN acc, BTRT..TCONTR  ctr, BREF..TBATCHSSD T3  --[06]
where dry.TRN_NT    = acc.TRN_NT
  AND dry.SSD_CF    = acc.SSD_CF
  AND dry.ESB_CF    = acc.ESB_CF
  AND acc.CTR_NF    = ctr.CTR_NF
  AND acc.UWY_NF    = ctr.UWY_NF
  AND acc.UW_NT     = ctr.UW_NT
  AND acc.END_NT    = ctr.END_NT
  AND dry.ESTFLG_B  = 0
  AND acc.SSD_CF    = T3.SSD_CF        --[06]
  AND T3.BATCHUSER_CF = suser_name()   --[06]

insert into #GTA
select dry.TRN_NT,
       dry.SSD_CF,
       dry.ESB_CF,
       acc.BLCSHT_D,
       acc.TRNCOD_CF,
       acc.CTRNCOD_CF,
       acc.CTR_NF,
       acc.END_NT,
       acc.SEC_NF,
       acc.UWY_NF,
       acc.UW_NT,
       acc.OCCYEA_NF,
       acc.ACY_NF,
       acc.SCOSTRMTH_NF,
       acc.SCOENDMTH_NF,
       acc.CLM_NF,
       acc.CUR_CF,
       acc.ORICURAMT_M,
       acc.CED_NF,
       ctr.PRD_NF,
       ctr.GENPRMPAY_NF,
       ctr.GANPAYORD_NT,
       acc.TRNSTS_CT
from BCTA..TDRYTRN dry, BCTA..TACCTRN acc, BFAC..TCONTR ctr, BREF..TBATCHSSD T3  --[06]
where dry.TRN_NT    = acc.TRN_NT
  AND dry.SSD_CF    = acc.SSD_CF
  AND dry.ESB_CF    = acc.ESB_CF
  AND acc.CTR_NF    = ctr.CTR_NF
  AND acc.UWY_NF    = ctr.UWY_NF
  AND acc.UW_NT     = ctr.UW_NT
  AND acc.END_NT    = ctr.END_NT
  AND dry.ESTFLG_B  = 0
  AND acc.SSD_CF    = T3.SSD_CF       --[06]
  AND T3.BATCHUSER_CF = suser_name()  --[06]
select @erreur = @@error
if @erreur != 0
begin
  raiserror 20001 "APPLICATIF;TACCTRN"
  return @erreur
end

/**************** Mise en commentaire jusqu'à la livraison d'estimation ********************/
------ Préparation d'une table temporaire avec les affaires ( FAC et TRT ) extraits
select distinct CTR_NF,
                END_NT,
                SEC_NF,
                UWY_NF,
                UW_NT
into #TCTRACC
from #GTA
where TRNSTS_CT = 1
if @erreur != 0
begin
    raiserror 20001 "APPLICATIF;TACCTRN"
    return @erreur
end

/*******************************************************************************************/
begin tran
------ Mise à jour du flag ESTFLG_B pour les mouvements extraits ------------------------------
UPDATE  BCTA..TDRYTRN
   SET dry.ESTFLG_B = 1
from BCTA..TDRYTRN dry, #GTA acc
where dry.TRN_NT    = acc.TRN_NT
  AND dry.SSD_CF    = acc.SSD_CF
  AND dry.ESB_CF    = acc.ESB_CF
  AND acc.TRNSTS_CT = 1
select @erreur = @@error
if @erreur != 0
begin
    rollback tran
    raiserror 20004 "APPLICATIF;TACCTRN"
    return @erreur
end

/**************** Mise en commentaire jusqu'à la livraison d'estimation ********************/
------ Suppression des affaires de la table temporaire qui sont aussi dans TCTRACC pour eviter
------ de les réinsérer et avoir un message d'insertion de doublons
DELETE #TCTRACC
from #TCTRACC, BEST..TCTRACC acc
WHERE #TCTRACC.CTR_NF = acc.CTR_NF
  AND #TCTRACC.SEC_NF = acc.SEC_NF
  AND #TCTRACC.UWY_NF = acc.UWY_NF
  AND #TCTRACC.UW_NT  = acc.UW_NT
  AND #TCTRACC.END_NT = acc.END_NT
select @erreur = @@error
if @erreur != 0
begin
    rollback tran
    raiserror 20003 "APPLICATIF;#TCTRACC"
    return @erreur
end

INSERT INTO BEST..TCTRACC ( CTR_NF, END_NT, SEC_NF, UW_NT, UWY_NF )
SELECT CTR_NF, END_NT, SEC_NF, UW_NT, UWY_NF
FROM #TCTRACC
select @erreur = @@error
if @erreur != 0
begin
    rollback tran
    raiserror 20001 "APPLICATIF;#TCTRACC"
    return @erreur
end
/*******************************************************************************************/
select
  SSD_CF
 ,ESB_CF
 ,datepart(yy, BLCSHT_D)
 ,case when datepart(mm, BLCSHT_D) < 10  then '0' + convert(char(01), datepart(mm, BLCSHT_D)) 	-- [23908]
 	     else convert(char(02), datepart(mm, BLCSHT_D))
       end
 ,case when datepart(dd, BLCSHT_D) < 10  then '0' + convert(char(01), datepart(dd, BLCSHT_D)) 	-- [23908]
       else convert(char(02), datepart(dd, BLCSHT_D))
       end
 ,TRNCOD_CF
 ,CTRNCOD_CF
 ,CTR_NF
 ,END_NT
 ,SEC_NF
 ,UWY_NF
 ,UW_NT
 ,OCCYEA_NF
 ,ACY_NF
 ,SCOSTRMTH_NF
 ,SCOENDMTH_NF
 ,CLM_NF
 ,CUR_CF
 ,ORICURAMT_M
 ,CED_NF
 ,PRD_NF
 ,GENPRMPAY_NF
 ,GANPAYORD_NT
 ,NULL RETCTR_NF
 ,NULL RETEND_NT
 ,NULL RETSEC_NF
 ,NULL RETRTY_NF
 ,NULL RETUW_NT
 ,NULL RETOCCYEA_NF
 ,NULL RETACY_NF
 ,NULL RETSCOSTRMTH_NF
 ,NULL RETSCOENDMTH_NF
 ,NULL RCL_NF
 ,NULL RETCUR_CF
 ,NULL RETAMT_M
 ,NULL PLC_NT
 ,NULL RTO_NF
 ,NULL INT_NF
 ,NULL RETPAY_NF
 ,NULL RETKEY_CF
 ,0.000                       --- montant retro interne 24/01/2003 JR
 ,NULL CompanyCode            --[03]
 ,NULL CompanyID              --[03]
 ,NULL LedgerGroup            --[03]
 ,NULL GL_ACCOUNT_Principal   --[03]
 ,NULL GL_ACCOUNT_CounterPart --[03]
 ,NULL Accounting_Year        --[03]
 ,NULL Accounting_Month       --[03]
 ,NULL Partner                --[03]
 ,NULL Cedent                 --[03]
 ,NULL Segment                --[03]
 ,NULL Transaction_Type       --[03]
 ,NULL GAAP_Diff              --[03]
 ,NULL Document_Type          --[03]
 ,NULL Reconciliation_Key     --[03]
 ,TRN_NT=null                      --[03]
 ,'GTA' ORICOD_LS             --[04]
 ,RETROAUTO_B=null            --[07] et les autres colonnes
 ,SPEENTNAT_CT=null
 ,EVT_NF=null
 ,REVT_NF=null
 ,RETARDRETINT_B=null
 ,NEWCOLS1_NF=null
 ,NEWCOLS2_NF=null
 ,NEWCOLS3_NF=null
 ,NEWCOLS4_NF=null
 ,NEWCOLS5_NF=null
 ,NEWCOLS6_NF=null
 ,NEWCOLS7_NF=null
 ,NEWCOLS8_NF=null
 ,NEWCOLS9_NF=null
from #GTA
where TRNSTS_CT = 1

select @erreur = @@error
if @erreur != 0
begin
  rollback tran
  raiserror 20005 "APPLICATIF;TACCTRN" /* erreur de modification */
  return @erreur
end

commit
drop TABLE #GTA
return 0
go
IF OBJECT_ID('PsACCTRN_01') IS NOT NULL
  PRINT '<<< CREATED PROC PsACCTRN_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PsACCTRN_01 >>>'
go
GRANT EXECUTE ON PsACCTRN_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCTRN_01 TO GDBBATCH
go
