use BEST
go

IF OBJECT_ID('dbo.PsNCBExtractR') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsNCBExtractR
   PRINT '<<< DROPPED PROC dbo.PsNCBExtractR >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsNCBExtractR
as

/***************************************************

Programme: PsNCBExtractR
Fichier script associ� : BEST_PsNCBExtractR.prc
Domaine : BEST
Base principale : BEST
Version: 1
Auteur: CAS 01/04/2021
Date de creation:
Description du programme:
     NDIC NCB Retro data extraction
Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 
Auteur: M.NAJI
Date: 29/01/2026
Version:
Description: US 8384 SERQS > Impact Estimation - IFRS4 - Copie 4H
*****************************************************/

SELECT 
	RETSEC.RETCTR_NF,
	0,
	RETSEC.RETSEC_NF,
	RETSEC.RTY_NF,
	1,
	'RET' AS CTR_TYP,
	ISNULL(RFAMMIS.NCB_R,0) AS NCB_R,
	NULL,
	NULL,
	NULL,
	NULL
FROM
	BRET..TRETSEC RETSEC
JOIN BRET..TRETCTR RETCTR
	ON RETSEC.RETCTR_NF=RETCTR.RETCTR_NF
	AND RETSEC.RTY_NF=RETCTR.RTY_NF
-- JOIN BREF..TBATCHSSD BATCHSSD
-- 	ON RETSEC.SSD_CF=BATCHSSD.SSD_CF
-- 	AND BATCHSSD.BATCHUSER_CF=suser_name()
LEFT OUTER JOIN BRET..TRFAMMIS RFAMMIS
	ON RETSEC.RETCTR_NF=RFAMMIS.RETCTR_NF
	AND RETSEC.RTY_NF=RFAMMIS.RTY_NF
	AND RETSEC.SSD_CF=RFAMMIS.SSD_CF
	AND RETSEC.RETSEC_NF=RFAMMIS.RETSEC_NF
LEFT OUTER JOIN BRET..TRETIFRS RETIFRS
	ON RETSEC.RETCTR_NF=RETIFRS.RETCTR_NF
	AND RETSEC.RTY_NF=RETIFRS.RTY_NF	
WHERE (RETCTR.RETCTRSTS_CT=3 OR RETCTR.RETCTRSTS_CT=19)
AND RETCTR.TERCTR_B<>1
AND RETSEC.LOB_CF<>'30' AND RETSEC.LOB_CF<>'31'

return 0
go

/*
 * fin de la procedure
 */

IF OBJECT_ID('dbo.PsNCBExtractR') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsNCBExtractR >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsNCBExtractR >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsNCBExtractR
 */
GRANT EXECUTE ON dbo.PsNCBExtractR TO GOMEGA
go
GRANT EXECUTE ON dbo.PsNCBExtractR TO GDBBATCH
go
