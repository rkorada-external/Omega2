use BEST
go

/* DROP PROC dbo.PsSSDACTR_01
*/
IF OBJECT_ID('dbo.PsSSDACTR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSSDACTR_01
   PRINT '<<< DROPPED PROC dbo.PsSSDACTR_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsSSDACTR_01
as

/***************************************************
Programme: PsSSDACTR_01
Fichier script associé : ESSSSD01.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME69 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
      Sélection d'enregistrement dans BRET..TSSDACTR

Parametres:
Conditions d'execution:
Commentaires:
---------------------------------------------
[001]  08/08/2013   R. CASSIS  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
*****************************************************/

declare @erreur int

Select a.RETCTR_NF, a.RTY_NF, a.PLC_NT, a.RETSEC_NF, a.UW_NT, a.CTR_NF, a.UWY_NF, a.SEC_NF, a.END_NT, a.CLISSD_NF, a.RTOSSD_CF, a.SSD_CF
from	BRET..TSSDACTR a, BREF..TBATCHSSD b
where a.SSD_CF=b.SSD_CF
and   b.BATCHUSER_CF = suser_name()
order	by a.RETCTR_NF, a.RTY_NF, a.PLC_NT, a.RETSEC_NF asc

return 0
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/


IF OBJECT_ID('dbo.PsSSDACTR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSSDACTR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSSDACTR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSSDACTR_01
 */
GRANT EXECUTE ON dbo.PsSSDACTR_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSSDACTR_01 TO GDBBATCH
go

