USE BEST
go
IF OBJECT_ID('dbo.PsLIFESTD_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFESTD_01
    IF OBJECT_ID('dbo.PsLIFESTD_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFESTD_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFESTD_01 >>>'
END
go
-- creation de la procedure

create procedure PsLIFESTD_01
(
  @p_balshtyea_nf  smallint,
  @p_balshtmth_nf  tinyint,
  @p_cre_d         datetime
)
with execute as caller as

/***************************************************
Programme:               PsLIFEST_09
Fichier script associÃƒÂ© : ESSEST09.PRC
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
[011] 23/05/2019 S. Behague :spira:78530: APOLO QE : complete account on 4 quarters
[012] 03/09/2019 B. Lagha   :spot :79098: Get the real value of BATCH_B
[013] 19/01/2022 S. Behague :spira :101516: Apolo - Retro interne
*****************************************************/

DECLARE	@vti_balshtmth_nf  tinyint,
		@vdt_cre_d         datetime

SELECT	@vti_balshtmth_nf = @p_balshtmth_nf + 1,
		@vdt_cre_d        = DateAdd(Day, 1, @p_cre_d)

SELECT
	T.CTR_NF,
	T.END_NT,
	T.SEC_NF,
	T.UWY_NF,
	T.UW_NT,
	T.BALSHEY_NF,
	T.ACY_NF,
	T.ACM_NF,
	T.ACMTRS_NT,
	T.GAAP_NT,
	T.DETTRNCOD_CF,
	Max(BALSHTMTH_NF) BALSHTMTH_NF
INTO
	#TLIFESTD
FROM
	BEST..TLIFESTD T,
	BTRT..TCONTR C, --[010]
	BTRAV..TESTSSD B
WHERE
	B.SSD_CF NOT IN (5, 6) AND
	T.SSD_CF = B.SSD_CF AND
	T.BALSHEY_NF = @p_balshtyea_nf AND
	T.PRS_CF = 500 AND
	T.BALSHTMTH_NF < @vti_balshtmth_nf AND
	T.CRE_D < @vdt_cre_d AND
	T.CTR_NF = C.CTR_NF AND --[010]
	--T.UWY_NF = C.UWY_NF AND --[010]
	C.ESTCRB_CT IN ('T', 'U') --[010]
GROUP BY 
	T.CTR_NF,
	T.END_NT,
	T.SEC_NF,
	T.UWY_NF,
	T.UW_NT,
	T.BALSHEY_NF,
	T.ACY_NF,
	T.ACM_NF,
	T.ACMTRS_NT,
	T.GAAP_NT,
	T.DETTRNCOD_CF

--[010]
UNION

SELECT
	T.CTR_NF,
	T.END_NT,
	T.SEC_NF,
	T.UWY_NF,
	T.UW_NT,
	T.BALSHEY_NF,
	T.ACY_NF,
	T.ACM_NF,
	T.ACMTRS_NT,
	T.GAAP_NT,
	T.DETTRNCOD_CF,
	Max(BALSHTMTH_NF) BALSHTMTH_NF
FROM
	BEST..TLIFESTD T,
	BRET..TRETCTR RC,
	BTRAV..TESTSSD B
WHERE
	B.SSD_CF NOT IN (5, 6) AND
	T.SSD_CF = B.SSD_CF AND
	T.BALSHEY_NF = @p_balshtyea_nf AND
	T.PRS_CF = 500 AND
	T.BALSHTMTH_NF < @vti_balshtmth_nf AND
	T.CRE_D < @vdt_cre_d AND
	T.CTR_NF = RC.RETCTR_NF AND
	--T.UWY_NF = RC.RTY_NF AND
	RC.ESTCRB_CT IN ('T', 'U')
GROUP BY 
	T.CTR_NF,
	T.END_NT,
	T.SEC_NF,
	T.UWY_NF,
	T.UW_NT,
	T.BALSHEY_NF,
	T.ACY_NF,
	T.ACM_NF,
	T.ACMTRS_NT,
	T.GAAP_NT,
	T.DETTRNCOD_CF
	
-- Select final
SELECT
	T1.SSD_CF,
	T1.CTR_NF,
	T1.END_NT,
	T1.SEC_NF,
	T1.UWY_NF,
	T1.UW_NT,
	T1.ACY_NF,
	CONVERT(Char(8), T1.CRE_D, 112) + ' ' + Convert(Char(8), T1.CRE_D, 108) CRE_D,
	T1.PRS_CF,
	T1.ACMTRS_NT,
	T1.BALSHEY_NF,
	T1.BALSHTMTH_NF,
	T1.CUR_CF,
	CASE
		WHEN T1.ACMTRS_NT > 2000
		THEN -1* T1.ESTMNT_M
		ELSE T1.ESTMNT_M
		END  ESTMNT_M,
	T1.INDSUP_B,
	T1.ORICOD_LS,
	T1.CREUSR_CF,
	T1.LSTUPD_D,
	T1.LSTUPDUSR_CF,
	T1.DETTRNCOD_CF,
	DETTRS_CF     = ' ',
	T1.GAAP_NT,T1.DIFF_M,
	T1.PROPAGATION_B,
	T1.ACM_NF,
	T1.ORICTR_NF,
	T1.ORISEC_NF,
	T1.ORIUWY_NF,UPD_NF	= ' ',
	LOB_CF				= '  ',
	ACCSTS_CT			= 0,
	ACCADMTYP_CT		= 0,
	ESTCRB_CT			= NULL,
	CED_NF				= NULL,
	BRK_NF				= 0,
	CASE
		WHEN T1.CALCULATED_B = 1
		THEN 1
		ELSE NULL
		END SPIMOD_CT,
	PAY_NF				= NULL,
	NAT_CF				= NULL,
	GANPAYORD_NT		= NULL,
	ADJCOD_CT			= NULL,
	RETCOD_CT			= NULL,
	ACCRET_B			= 0,
	ESB_CF				= 0,
	LIFTRTTYP_CF		= ' ',
	UWGRP_CF			= 0,
	CNATYP_CT			= 0,
	RENOUV_B			= 0,
	CLOPRD				= 0,
	DBCLO_D				= 0,
	ORICRE_D			= 0,
	ORISSD_CF			= 0,
--	BATCH_B				= 0,
	CASE WHEN T1.BATCH_B = 1
        THEN 1
        ELSE 0
    END BATCH_B,      -- SPOT 79098 [012]
	NBCOLNEW			= 0,
	NBCOL				= 0
FROM
	BEST..TLIFESTD T1,
	#TLIFESTD T2
WHERE
	T1.CTR_NF		= T2.CTR_NF AND
	T1.END_NT		= T2.END_NT AND
	T1.SEC_NF		= T2.SEC_NF AND
	T1.UWY_NF		= T2.UWY_NF AND
	T1.UW_NT		= T2.UW_NT AND
	T1.BALSHEY_NF	= T2.BALSHEY_NF AND
	T1.BALSHTMTH_NF	= T2.BALSHTMTH_NF AND
	T1.ACY_NF		= T2.ACY_NF AND
	T1.ACM_NF		= T2.ACM_NF AND
	T1.ACMTRS_NT	= T2.ACMTRS_NT AND
	T1.GAAP_NT		= T2.GAAP_NT AND
	T1.DETTRNCOD_CF	= T2.DETTRNCOD_CF AND
	T1.CRE_D		= (SELECT
							MAX(CRE_D)
						FROM
							BEST..TLIFESTD l2
						WHERE
							l2.CTR_NF		= T2.CTR_NF AND
							l2.END_NT		= T2.END_NT AND
							l2.SEC_NF		= T2.SEC_NF AND
							l2.UWY_NF		= T2.UWY_NF AND
							l2.UW_NT		= T2.UW_NT AND
							l2.BALSHEY_NF	= T2.BALSHEY_NF AND
							l2.BALSHTMTH_NF	= T2.BALSHTMTH_NF AND
							l2.ACY_NF		= T2.ACY_NF AND
							l2.ACM_NF		= T2.ACM_NF AND
							l2.ACMTRS_NT	= T2.ACMTRS_NT AND
							l2.GAAP_NT		= T2.GAAP_NT AND
							l2.DETTRNCOD_CF	= T2.DETTRNCOD_CF
					  )
ORDER BY
	T1.CTR_NF,
	T1.SEC_NF,
	T1.UWY_NF,
	T1.ACY_NF,
	T1.ACM_NF,
	T1.ACMTRS_NT,
	T1.DETTRNCOD_CF,
	T1.GAAP_NT

return 0
go
EXEC sp_procxmode 'dbo.PsLIFESTD_01', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFESTD_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFESTD_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFESTD_01 >>>'
go
GRANT EXECUTE ON dbo.PsLIFESTD_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFESTD_01 TO GDBBATCH
go
