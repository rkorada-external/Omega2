USE BEST
go

/*
 * DROP PROC dbo.PsSEGPAR_02
 */
IF OBJECT_ID('dbo.PsSEGPAR_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSEGPAR_02
    PRINT '<<< DROPPED PROC dbo.PsSEGPAR_02 >>>'
END
go

/*
 * creation de la procedure
 */

create procedure PsSEGPAR_02
as

/***************************************************
Programme: PsSEGPAR_02
Fichier script associé : ESSSEG02.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: ME27 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:

      Extraction de TSEGPAR pour le programme ESTC2102.c

Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
[001]  08/08/2013   R. CASSIS  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
*****************************************************/

--[001]
SELECT distinct
       a.SSD_CF,
       isnull(a.UWGRP_CF,0),
       a.PCPRSKTRY_CF,
       a.CLINAT_CF,
       isnull(a.ORDNBR_NT,0),
       a.SEG_NF
FROM  BEST..TSEGPAR a, BREF..TBATCHSSD b
Where a.SSD_CF=b.SSD_CF
AND   b.BATCHUSER_CF = suser_name()
order by a.SSD_CF,a.UWGRP_CF,a.PCPRSKTRY_CF,a.CLINAT_CF,a.ORDNBR_NT

go

/*    Insertion dans la table des procedures
 *-------------------------------------------*/


IF OBJECT_ID('dbo.PsSEGPAR_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSEGPAR_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSEGPAR_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSEGPAR_02
 */
GRANT EXECUTE ON dbo.PsSEGPAR_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSEGPAR_02 TO GDBBATCH
go

