USE BEST
go
IF OBJECT_ID('dbo.PsLIFEST_09_CUR') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFEST_09_CUR
    IF OBJECT_ID('dbo.PsLIFEST_09_CUR') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFEST_09_CUR >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFEST_09_CUR >>>'
END
go


-- creation de la procedure

create procedure PsLIFEST_09_CUR
(
  @p_balshtyea_nf  smallint
)
with execute as caller as

/***************************************************
Programme:               PsLIFEST_09_CUR
Fichier script associÃÂ© : ESSEST09.PRC
Domaine :                (ES) Estimation
Base principale :        BEST
Version:                 1
Auteur:                  ME27 avec Infotool version 2.0
Date de creation:
Description du programme:
      Sélection d'enregistrement dans TLIFEST

Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: ANB
Date: 10/9/98
Version: 2
Description: Ajout du test sur le bilan en cours
_________________
MODIFICATION 2
Auteur: GIBU
Date: 04/09/2003
Version: 3
Description: Ajout du parametre BALSHTMTH_NF pour limiter extraction
             Suite au deblocage de la saisie en periode exceptionnelle
             il est possible d'avoir des lignes sur une periode
             posterieure a celle a traiter. Il ne faut pas les prendre
_________________
MODIFICATION 3
Auteur      : T.RIPERT
Date        : 04/09/2003
Version     : 3
Description : Exclusion des postes 1900 et 1901
_________________
MODIFICATION 4
Auteur      : JF VDV
Date        : 10.1
Description : [20198] - Eviter les doublons dans TLIFEST (cas inventaire en journee)
_________________
MODIFICATION 5
Description : Removed dbo and added ?with execute as caller as?
[006] 06/01/2014 R. BEN EZZINE :spot:25427  - Extraction des derniers mouvements uniquement pour insertion en incremental dans la Tlifest
_________________
MODIFICATION 6
Description : Removed dbo and added ?with execute as caller as?
[006] 15/05/2014 R. BEN EZZINE - version 2B
_________________
MODIFICATION 7
Description : Optimisation de la procedure
[007] 25/08/2014 S. GOLDSTEIN
[008] 04/09/2014 R. Cassis :spot:27290 no dbo. for create index on temp table
[009] 10/08/2015 R. Cassis :spot:29206 Refonte de la procedure pour optimisation
_________________
MODIFICATION 8
Describe : Add Quarterly
[010] 17/12/2018 R. Vieville Adding the CTR_NF, UWY_NF and ESTCRB_CT check for contract reto and assume 
[011] 03/09/2019 B. Lagha  :spot:79098 Get the real value of BATCH_B
*****************************************************/

DECLARE  @vdt_cre_d         char(8)


SELECT   @vdt_cre_d        = convert (char(8) , @p_balshtyea_nf*10000+100+1)


select distinct ssd_cf
INTO #TESTSSD
FROM
	BTRAV..TESTSSD
WHERE
	SSD_CF NOT IN (5, 6)
	
SELECT 
 	CTR_NF        ,         
    END_NT        ,       
    SEC_NF        ,       
    UWY_NF        ,       
    UW_NT         ,       
    CONVERT(Char(8), CRE_D, 112) + ' ' + Convert(Char(8), CRE_D, 108) CRE_D,        
    BALSHEY_NF    ,       
    BALSHTMTH_NF  ,       
    ACY_NF        ,       
    GAAP_NT       ,       
    DETTRNCOD_CF  ,       
    ACM_NF        ,       
    PRS_CF        ,       
    ACMTRS_NT     ,       
    SSD_CF        ,       
    CUR_CF        ,       
	 CASE
		WHEN ACMTRS_NT > 2000
		THEN -1* ESTMNT_M
		ELSE ESTMNT_M
	 END  ESTMNT_M, 
    INDSUP_B      ,       
    ORICOD_LS     ,       
    CREUSR_CF     ,       
    LSTUPD_D,         
    LSTUPDUSR_CF  ,       
    ORICTR_NF     ,       
    ORISEC_NF     ,       
    ORIUWY_NF     ,       
    DIFF_M        ,     
    PROPAGATION_B ,       
    CALCULATED_B  ,       
    BATCH_B   ,
    CASE
		WHEN CALCULATED_B = 1
		THEN 1
		ELSE NULL
	 END SPIMOD_CT    
FROM
	BEST..TLIFEST T
WHERE T.CRE_D >= @vdt_cre_d 
and SSD_CF in  (select ssd_cf from  #TESTSSD) 


return 0
go
EXEC sp_procxmode 'dbo.PsLIFEST_09_CUR', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFEST_09_CUR') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFEST_09_CUR >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFEST_09_CUR >>>'
go
GRANT EXECUTE ON dbo.PsLIFEST_09_CUR TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFEST_09_CUR TO GDBBATCH
go
