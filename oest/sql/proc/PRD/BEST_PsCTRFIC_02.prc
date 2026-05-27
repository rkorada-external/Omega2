use BEST
go

/*
 * DROP PROC dbo.PsCTRFIC_02
 */
IF OBJECT_ID('dbo.PsCTRFIC_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCTRFIC_02
    PRINT '<<< DROPPED PROC dbo.PsCTRFIC_02 >>>'
END
go

/*
 * creation de la procedure
 */

create procedure PsCTRFIC_02
as

/***************************************************
Programme: PsCTRFIC_02
Fichier script associé : ESSFIC02.PRC
Domaine : (RT) Rétro
Base principale : BRET
Version: 1
Auteur: ME27 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:

      Extraction de TCTRFIC par le programme ESTC2101.c

Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur:       Tony RIPERT
Date:         15/03/2010
Version:
Description:
  SPOT 19211 : Ajout la colonne CED_NF (cédante)
[002]  08/08/2013   R. CASSIS  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
*****************************************************/

/*SELECT distinct SSD_CF,LIFTRTTYP_CF,isnull(UWGRP_CF,0),PCPRSKTRY_CF,CTR_NF FROM TCTRFIC
order by SSD_CF,UWGRP_CF,PCPRSKTRY_CF,LIFTRTTYP_CF*/

--[002]
SELECT distinct
       a.SSD_CF,
       a.LIFTRTTYP_CF,
       isnull(a.UWGRP_CF,0),
       a.PCPRSKTRY_CF,
       a.CTR_NF,
       a.CED_NF
FROM  BEST..TCTRFIC a, BREF..TBATCHSSD b
Where a.SSD_CF=b.SSD_CF
AND   b.BATCHUSER_CF = suser_name()
ORDER BY a.SSD_CF,a.UWGRP_CF,a.PCPRSKTRY_CF,a.LIFTRTTYP_CF,a.CED_NF

go




IF OBJECT_ID('dbo.PsCTRFIC_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCTRFIC_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCTRFIC_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCTRFIC_02
 */
GRANT EXECUTE ON dbo.PsCTRFIC_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCTRFIC_02 TO GDBBATCH
go

