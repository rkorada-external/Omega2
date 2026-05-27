USE BEST
go
IF OBJECT_ID('dbo.PsLIFEST_09_ID2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFEST_09_ID2
    IF OBJECT_ID('dbo.PsLIFEST_09_ID2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFEST_09_ID2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFEST_09_ID2 >>>'
END
go
/***** create procedure dbo.PsLIFEST_09_ID2 *****/


/** creation de la procedure **/
CREATE PROCEDURE dbo.PsLIFEST_09_ID2
(
    @p_balshtyea_nf  smallint
)
AS

/***************************************************

Programme: PsLIFEST_09_ID2

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ESSE Nicolas

Date de creation: 29/07/2015

Description du programme: Extraction des mouvements precedents et suivants les
changements dans la grille (suite a un fileupload EST38 ou une saisie manuelle
EST52) le perimetre defini par la table d'appel.

Parametres:

Conditions d'execution: Execute a chaque intraday

BEST..PsLIFEST_09_ID2 2022 

Commentaires:
[001] 24/04/2016  MBO : SPOT:30352 SPIRA:44672 : ajout des millisecondes
[002] DFI - 14/06/2016 - SPOT::SPIRA:44675 Rapports sur type comptable 1 (survenance) : extraire tous les UWY, ajout jointure sur TSECTION
[003] M.NAJI - 14/09/2022 - SPIRA:106046 Optimisation  
*****************************************************/

DECLARE @CRE_D_MAX  DATETIME

SELECT  @CRE_D_MAX  = MAX(END_D) FROM BEST..TIDLIFEST_CALL

select  distinct
    s.ssd_cf,
    s.CTR_NF ,
    s.SEC_NF ,
    s.UWY_NF,
    c.END_D
into #TSECTION_LIFEST_CALL
FROM   BTRT..TSECTION s
-- jointure pour avoir les infos ACCADMTYP_CT de la section pour le même exercice que LIFEST si ACCADMTYP_CT !=1  ou un des 4 années  s.ACCADMTYP_CT=1
-- attention  UW_NT et END_NT ne font pas partie de la jointure  , 
JOIN BEST..TIDLIFEST_CALL   c on s.ssd_cf =c.ssd_cf and s.ctr_nf =  c.ctr_nf and s.sec_nf = c.sec_nf --and s.uwy_nf =c.UWY_NF 
                                               and ( (s.ACCADMTYP_CT=1 AND s.UWY_NF BETWEEN @p_balshtyea_nf - 4 AND @p_balshtyea_nf)
                                                         OR
                                                        (s.ACCADMTYP_CT !=1 AND s.UWY_NF = c.UWY_NF)
                                                      )
and     s.SSD_CF   in (select  SSD_CF from   BREF..TBATCHSSD WHERE   BATCHUSER_CF    = suser_name()) 



select 
	l.SSD_CF ,
	l.CTR_NF ,
	l.END_NT ,
	l.SEC_NF ,
	l.UWY_NF ,
	l.UW_NT ,
	l.ACY_NF ,
	Convert(Char(8), max(l.CRE_D), 112) + ' ' + Convert(Char(12),max( l.CRE_D), 20) AS CRE_D , 
	l.PRS_CF ,
	l.ACMTRS_NT ,
	l.BALSHEY_NF ,
	l.BALSHTMTH_NF ,
	l.CUR_CF ,
	CASE WHEN l.ACMTRS_NT > 2000 THEN -1* l.ESTMNT_M		ELSE l.ESTMNT_M	END  ESTMNT_M ,
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
	CASE WHEN l.ORICOD_LS = 'Calculated' THEN 1	ELSE NULL	END SPIMOD_CT ,
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

FROM BEST..TLIFEST l
-- jointure avec #TSECTION_LIFEST_CALL pour filtrer 
JOIN #TSECTION_LIFEST_CALL c on l.ctr_nf =  c.ctr_nf and l.sec_nf = c.sec_nf and l.uwy_nf =c.UWY_NF  and l.CRE_D <= c.END_D
where l.ACY_NF BETWEEN @p_balshtyea_nf - 4 AND @p_balshtyea_nf
AND   l.CRE_D           <= @CRE_D_MAX
AND   l.PRS_CF          = 500
group by 
	l.CTR_NF,
	l.END_NT,
	l.SEC_NF,
	l.UWY_NF,
	l.UW_NT,
	l.BALSHEY_NF,
-- BALSHTMTH_NF,
	l.ACY_NF,
	l.PRS_CF,
	l.ACMTRS_NT,
	l.GAAP_NT,
	l.DETTRNCOD_CF,
	l.SSD_CF
HAVING  -- permet de garder la ligne du plus grand CRE_D
	l.CRE_D=max(l.CRE_D)

/* old version
SELECT  distinct l.SSD_CF ,
        l.CTR_NF ,
        l.END_NT ,
        l.SEC_NF ,
        l.UWY_NF ,
        l.UW_NT ,
        l.ACY_NF ,
        Convert(Char(8), l.CRE_D, 112) + ' ' + Convert(Char(12), l.CRE_D, 20) AS CRE_D , --[001]
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
        BEST..TIDLIFEST_CALL d ,
        BREF..TBATCHSSD e,
        BTRT..TSECTION s
WHERE   e.SSD_CF          = d.SSD_CF
  AND   e.BATCHUSER_CF    = suser_name()
  AND   d.SSD_CF          = l.SSD_CF
  AND   d.CTR_NF          = l.CTR_NF
  AND   d.SEC_NF          = l.SEC_NF
  AND   s.UWY_NF          = l.UWY_NF
  AND   l.PRS_CF          = 500
  AND   l.CRE_D           <= @CRE_D_MAX
  AND   (l.ACY_NF BETWEEN @p_balshtyea_nf - 4 AND @p_balshtyea_nf)
  AND   (l.CRE_D          = ( SELECT MAX(CRE_D)
                              FROM BEST..TLIFEST
                              WHERE CRE_D       <= d.END_D
                                AND CTR_NF       = l.CTR_NF
                                AND SEC_NF       = l.SEC_NF
                                AND UWY_NF       = l.UWY_NF
                                AND ACY_NF       = l.ACY_NF
                                AND ACMTRS_NT    = l.ACMTRS_NT
                                AND DETTRNCOD_CF = l.DETTRNCOD_CF
                                AND GAAP_NT      = l.GAAP_NT
                                AND SSD_CF       = l.SSD_CF
                                AND END_NT       = l.END_NT
                                AND UW_NT        = l.UW_NT
                                AND BALSHEY_NF   = l.BALSHEY_NF)
    OR
        l.CRE_D          = ( SELECT MAX(CRE_D)
                             FROM BEST..TLIFEST
                             WHERE CRE_D        < d.START_D
                               AND CTR_NF       = l.CTR_NF
                               AND SEC_NF       = l.SEC_NF
                               AND UWY_NF       = l.UWY_NF
                               AND ACY_NF       = l.ACY_NF
                               AND ACMTRS_NT    = l.ACMTRS_NT
                               AND DETTRNCOD_CF = l.DETTRNCOD_CF
                               AND GAAP_NT      = l.GAAP_NT
                               AND SSD_CF       = l.SSD_CF
                               AND END_NT       = l.END_NT
                               AND UW_NT        = l.UW_NT
                               AND BALSHEY_NF   = l.BALSHEY_NF)
            )
    AND (
        s.CTR_NF=d.CTR_NF
        AND s.SEC_NF=d.SEC_NF 
        AND (
            (s.ACCADMTYP_CT=1 AND s.UWY_NF BETWEEN @p_balshtyea_nf - 4 AND @p_balshtyea_nf)
            OR
            (s.ACCADMTYP_CT !=1 AND s.UWY_NF = d.UWY_NF)
        )
    )
ORDER BY    l.CTR_NF ,
            l.SEC_NF ,
            l.UWY_NF ,
            l.ACY_NF ,
            l.ACMTRS_NT ,
            l.DETTRNCOD_CF ,
            l.GAAP_NT
*/


UPDATE  BEST..TIDLIFEST_CALL
SET     FLAG_B = 1
FROM    BEST..TIDLIFEST_CALL d ,
        BREF..TBATCHSSD e
WHERE   END_D <= @CRE_D_MAX
AND     e.SSD_CF = d.SSD_CF
AND     e.BATCHUSER_CF = suser_name()
go
EXEC sp_procxmode 'dbo.PsLIFEST_09_ID2', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFEST_09_ID2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFEST_09_ID2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFEST_09_ID2 >>>'
go
GRANT EXECUTE ON dbo.PsLIFEST_09_ID2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFEST_09_ID2 TO GDBBATCH
go
