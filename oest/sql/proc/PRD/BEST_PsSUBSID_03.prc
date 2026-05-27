use BEST
go

/*
 * DROP PROC dbo.PsSUBSID_03
 */
IF OBJECT_ID('dbo.PsSUBSID_03') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSUBSID_03
    PRINT '<<< DROPPED PROC dbo.PsSUBSID_03 >>>'
END
go

/*
 * creation de la procedure
 */

create procedure PsSUBSID_03
as

/***************************************************
Programme: PsSUBSID_03
Fichier script associé : ESSSUB03.PRC
Domaine : (ES) Estimation
Base principale : BREF
Version: 1
Auteur:
Date de creation:
Description du programme:
      Sélection d'enregistrement dans TSUBSID

Parametres:
Conditions d'execution:
Commentaires:
---------------------------------------------
[001]  08/08/2013   R. CASSIS  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
*****************************************************/

declare @erreur int


Select A.ssd_cf,
       A.ssdomglag_cf,
       A.ssd_ls,
       A.ssdcur_cf
from BREF..TSUBSID A, BREF..TBATCHSSD C
where A.SSD_CF = C.SSD_CF
and   C.BATCHUSER_CF = suser_name()
order by A.ssd_cf

return 0
go
IF OBJECT_ID('dbo.PsSUBSID_03') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSUBSID_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSUBSID_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSUBSID_03
 */
GRANT EXECUTE ON dbo.PsSUBSID_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSUBSID_03 TO GDBBATCH
go

