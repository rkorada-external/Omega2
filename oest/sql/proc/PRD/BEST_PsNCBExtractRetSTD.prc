use BEST
go

IF OBJECT_ID('dbo.PsNCBExtractRetSTD') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsNCBExtractRetSTD
   PRINT '<<< DROPPED PROC dbo.PsNCBExtractRetSTD >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsNCBExtractRetSTD
as

/***************************************************

Programme: PsNCBExtractRetSTD
Fichier script associé : BEST_PsNCBExtractRetSTD.prc
Domaine : BEST
Base principale : BEST
Version: 1
Auteur: KBgawe 16/07/2020
Date de creation:
Description du programme:
     NDIC NCB data extraction
Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 
Auteur:
Date:
Version:
Description:
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
	NULL
FROM
	BRET..TRETSEC RETSEC
JOIN BRET..TRETCTR RETCTR
	ON RETSEC.RETCTR_NF=RETCTR.RETCTR_NF
	AND RETSEC.RTY_NF=RETCTR.RTY_NF
JOIN BREF..TBATCHSSD BATCHSSD
	ON RETSEC.SSD_CF=BATCHSSD.SSD_CF
	AND BATCHSSD.BATCHUSER_CF=suser_name()
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

IF OBJECT_ID('dbo.PsNCBExtractRetSTD') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsNCBExtractRetSTD >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsNCBExtractRetSTD >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsNCBExtractRetSTD
 */
GRANT EXECUTE ON dbo.PsNCBExtractRetSTD TO GOMEGA
go
GRANT EXECUTE ON dbo.PsNCBExtractRetSTD TO GDBBATCH
go
