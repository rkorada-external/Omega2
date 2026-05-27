USE BEST
go

/** Drop procedure if already exists **/
IF OBJECT_ID('dbo.PsLIFEST_09_ID1') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFEST_09_ID1
    IF OBJECT_ID('dbo.PsLIFEST_09_ID1') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFEST_09_ID1 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFEST_09_ID1 >>>'
END
go


/** creation de la procedure **/
CREATE PROCEDURE dbo.PsLIFEST_09_ID1
AS

/***************************************************

Programme: PsLIFEST_09_ID1

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: BONNERUE Gwendal

Date de creation: 13/08/2015

Description du programme: Extraction de TLISFEST pour l'ESDJ8040 et update de
TCALL


Parametres:

Conditions d'execution: Execute a chaque intraday

Commentaires:

*****************************************************/

UPDATE  BEST..TCALL
SET     TREATED_B = 1



SELECT  l.SSD_CF ,
        l.CTR_NF ,
        l.END_NT ,
        l.SEC_NF ,
        l.UWY_NF ,
        l.UW_NT ,
        l.ACY_NF ,
        Convert(Char(8), l.CRE_D, 112) + ' ' + Convert(Char(8), l.CRE_D, 108) AS CRE_D ,
        l.PRS_CF ,
        l.ACMTRS_NT ,
        l.BALSHEY_NF ,
        l.BALSHTMTH_NF ,
        l.CUR_CF ,
        CASE WHEN l.ACMTRS_NT > 2000 THEN -1* l.ESTMNT_M
            ELSE l.ESTMNT_M
        END  ESTMNT_M ,
        l.INDSUP_B ,
        l.ORICOD_LS ,
        l.CREUSR_CF ,
        l.LSTUPD_D ,
        l.LSTUPDUSR_CF ,
        l.DETTRNCOD_CF ,
        DETTRS_CF     = ' ' ,
        l.GAAP_NT ,
        l.DIFF_M ,
        l.PROPAGATION_B ,
        l.ACM_NF ,
        l.ORICTR_NF ,
        l.ORISEC_NF ,
        l.ORIUWY_NF ,
        UPD_NF        = ' ' ,
        LOB_CF        = '  ' ,
        ACCSTS_CT     = 0 ,
        ACCADMTYP_CT  = 0 ,
        ESTCRB_CT     = NULL ,
        CED_NF        = NULL ,
        BRK_NF        = 0 ,
        CASE WHEN l.ORICOD_LS = 'Calculated' THEN 1
            ELSE NULL
        END SPIMOD_CT ,
        PAY_NF        = NULL ,
        NAT_CF        = NULL ,
        GANPAYORD_NT  = NULL ,
        ADJCOD_CT     = NULL ,
        RETCOD_CT     = NULL ,
        ACCRET_B      = 0 ,
        ESB_CF        = 0 ,
        LIFTRTTYP_CF  = ' ' ,
        UWGRP_CF      = 0 ,
        CNATYP_CT     = 0 ,
        RENOUV_B      = 0 ,
        CLOPRD        = 0 ,
        DBCLO_D       = 0 ,
        ORICRE_D      = 0 ,
        ORISSD_CF     = 0 ,
        BATCH_B       = 0 ,
        NBCOLNEW      = 0 ,
        NBCOL         = 0
FROM    BEST..TLIFEST   l ,
        BEST..TCALL d ,
        BREF..TBATCHSSD e
WHERE   e.SSD_CF          = d.SSD_CF
  AND   e.BATCHUSER_CF    = suser_name()
  AND   d.SSD_CF          = l.SSD_CF
  AND   d.CTR_NF          = l.CTR_NF
  AND   d.SEC_NF          = l.SEC_NF
  AND   d.UWY_NF          = l.UWY_NF
  AND   l.PRS_CF          = 500
  AND   d.treated_b       = 1
  AND   (l.CRE_D          = (SELECT  MAX(CRE_D)
                             FROM    BEST..TLIFEST
                             WHERE   CTR_NF       = l.CTR_NF
                               AND   SEC_NF       = l.SEC_NF
                               AND   UWY_NF       = l.UWY_NF
                               AND   ACY_NF       = l.ACY_NF
                               AND   ACMTRS_NT    = l.ACMTRS_NT
                               AND   DETTRNCOD_CF = l.DETTRNCOD_CF
                               AND   GAAP_NT      = l.GAAP_NT
                               AND   SSD_CF       = l.SSD_CF
                               AND   END_NT       = l.END_NT
                               AND   UW_NT        = l.UW_NT
                               AND   BALSHEY_NF   = l.BALSHEY_NF)
  )
ORDER BY  l.CTR_NF
        , l.SEC_NF
        , l.UWY_NF
        , l.ACY_NF
        , l.ACMTRS_NT
        , l.DETTRNCOD_CF
        , l.GAAP_NT
go

IF OBJECT_ID('dbo.PsLIFEST_09_ID1') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFEST_09_ID1 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFEST_09_ID1 >>>'
go
GRANT EXECUTE ON dbo.PsLIFEST_09_ID1 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFEST_09_ID1 TO GDBBATCH
go
