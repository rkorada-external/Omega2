USE BEST
go

/** Drop procedure if already exists **/
IF OBJECT_ID('dbo.PsACCTRN_01_ID') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsACCTRN_01_ID
    IF OBJECT_ID('dbo.PsACCTRN_01_ID') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsACCTRN_01_ID >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsACCTRN_01_ID >>>'
END
go


/** creation de la procedure **/
CREATE PROCEDURE dbo.PsACCTRN_01_ID
AS

/***************************************************

Programme: PsACCTRN_01_ID

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: BONNERUE Gwendal

Date de creation: 30/07/2015

Description du programme: Sélection d'enregistrement dans TACCTRNE



Parametres:

Conditions d'execution:

Commentaires:

*****************************************************/

declare @erreur int

/* On selectionne les mouvements  quotidien de BCTA..TACCTRN flagués dans
 BCTA..TDRYTRN on l'enrichissant avec d'autres info du contrat acceptation
 UNION ALL est utilisé car le contrat peut être FAC ou Traité*/
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

INSERT INTO #GTA
SELECT dry.TRN_NT,
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
FROM  BCTA..TDRYTRN dry,
      BCTA..TACCTRN acc,
      BTRT..TCONTR  ctr,
      BREF..TBATCHSSD T3,
      BEST..TCALL call
WHERE dry.TRN_NT    = acc.TRN_NT
  AND dry.SSD_CF    = acc.SSD_CF
  AND dry.ESB_CF    = acc.ESB_CF
  AND call.SSD_CF   = acc.SSD_CF
  AND call.ESB_CF   = acc.ESB_CF
  AND call.CTR_NF   = acc.CTR_NF
  AND call.UWY_NF   = acc.UWY_NF
  AND call.ACY_NF   = acc.ACY_NF
  AND acc.CTR_NF    = ctr.CTR_NF
  AND acc.UWY_NF    = ctr.UWY_NF
  AND acc.UW_NT     = ctr.UW_NT
  AND acc.END_NT    = ctr.END_NT
  AND acc.SSD_CF    = T3.SSD_CF
  AND T3.BATCHUSER_CF = suser_name()

SELECT @erreur = @@error
if @erreur != 0
BEGIN
    raiserror 20005 "APPLICATIF;TACCTRN" /* erreur de modification */
    RETURN @erreur
END


SELECT  SSD_CF,
        ESB_CF,
        datepart(yy, BLCSHT_D),
        CASE
         WHEN datepart(mm, BLCSHT_D) < 10  then '0' + convert(char(01), datepart(mm, BLCSHT_D))
         ELSE convert(char(02), datepart(mm, BLCSHT_D))
        END,
        CASE
         WHEN datepart(dd, BLCSHT_D) < 10  then '0' + convert(char(01), datepart(dd, BLCSHT_D))
         ELSE convert(char(02), datepart(dd, BLCSHT_D))
        END,
        TRNCOD_CF,
        CTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CLM_NF,
        CUR_CF,
        ORICURAMT_M,
        CED_NF,
        PRD_NF,
        GENPRMPAY_NF,
        GANPAYORD_NT,
        NULL RETCTR_NF,
        NULL RETEND_NT,
        NULL RETSEC_NF,
        NULL RETRTY_NF,
        NULL RETUW_NT,
        NULL RETOCCYEA_NF,
        NULL RETACY_NF,
        NULL RETSCOSTRMTH_NF,
        NULL RETSCOENDMTH_NF,
        NULL RCL_NF,
        NULL RETCUR_CF,
        NULL RETAMT_M,
        NULL PLC_NT,
        NULL RTO_NF,
        NULL INT_NF,
        NULL RETPAY_NF,
        NULL RETKEY_CF,
        0.000,
        NULL CompanyCode,
        NULL CompanyID,
        NULL LedgerGroup,
        NULL GL_ACCOUNT_Principal,
        NULL GL_ACCOUNT_CounterPart,
        NULL Accounting_Year,
        NULL Accounting_Month,
        NULL Partner,
        NULL Cedent,
        NULL Segment,
        NULL Transaction_Type,
        NULL GAAP_Diff,
        NULL Document_Type,
        NULL Reconciliation_Key,
        TRN_NT,
        'GTA' ORICOD_LS
FROM #GTA
WHERE TRNSTS_CT = 1

SELECT @erreur = @@error
IF @erreur != 0
BEGIN
  rollback tran
  raiserror 20005 "APPLICATIF;TACCTRN" /* erreur de modification */
  RETURN @erreur
END
COMMIT

DROP TABLE #GTA
go

IF OBJECT_ID('dbo.PsACCTRN_01_ID') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsACCTRN_01_ID >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsACCTRN_01_ID >>>'
go
GRANT EXECUTE ON dbo.PsACCTRN_01_ID TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCTRN_01_ID TO GDBBATCH
go
