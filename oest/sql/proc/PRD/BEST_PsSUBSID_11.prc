use BEST
go

/* DROP PROC dbo.PsSUBSID_11
 */
IF OBJECT_ID('dbo.PsSUBSID_11') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSUBSID_11
   PRINT '<<< DROPPED PROC dbo.PsSUBSID_11 >>>'
END
go

/*
 * creation de la procedure
 */

create procedure PsSUBSID_11
as

/***************************************************
Programme: PsSUBSID_11
Fichier script associé : ESSSSD11.PRC
Domaine : (ES) Estimation
Base principale : BREF
Version: 1
Auteur: ME27 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
      Sélection d'enregistrement dans TSUBSID

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

declare @erreur int

--[001]
Select a.ssd_cf,
       a.ssd_ls,
       a.ssdomglag_cf
from  BREF..TSUBSID a, BREF..TBATCHSSD b
Where a.SSD_CF=b.SSD_CF
AND   b.BATCHUSER_CF = suser_name()

return 0
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/


IF OBJECT_ID('dbo.PsSUBSID_11') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSUBSID_11 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSUBSID_11 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSUBSID_11
 */
GRANT EXECUTE ON dbo.PsSUBSID_11 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSUBSID_11 TO GDBBATCH
go

