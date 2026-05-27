use BEST
go

/*
 * DROP PROC dbo.PsCURCVSN_05
 */
IF OBJECT_ID('dbo.PsCURCVSN_05') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCURCVSN_05
    PRINT '<<< DROPPED PROC dbo.PsCURCVSN_05 >>>'
END
go

/*
 * creation de la procedure
 */

create procedure PsCURCVSN_05
as

/***************************************************

Programme: PsCURCVSN_05
Fichier script associé : ESSCUR05.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: C.Soulier (CGI)
Date de creation: 30 juillet 1997
Description du programme:

      Extraction de la table TCURCVSN et tri des enregistrements
	selectionnes selon ACPCUR_CF/SSD_CF/RETCTR_NF/RTY_NF/PLC_NT

Parametres: aucun
Conditions d'execution:
Commentaires: - servira en estimation pour la fonction de transformation
	          de la devise acceptation vers la devise retrocession.
		!!!!!Attention!!!! l'ordre de tri (ORDER BY...) est important pour
		l'utilisation du resultat de cette procedure par la fonction de
		transformation de devise. Ne pas le modifier.


_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
[001]  08/08/2013   R. CASSIS  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
*****************************************************/

--[001]
SELECT a.acpcur_cf,
		 a.ssd_cf,
		 a.retctr_nf,
		 a.rty_nf,
	 	 a.plc_nt,
		 a.acccur_cf
FROM 	bret..tcurcvsn a, BREF..TBATCHSSD b
Where a.SSD_CF=b.SSD_CF
AND   b.BATCHUSER_CF = suser_name()
ORDER BY acpcur_cf, ssd_cf, retctr_nf, rty_nf, plc_nt


go
IF OBJECT_ID('dbo.PsCURCVSN_05') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCURCVSN_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCURCVSN_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCURCVSN_05
 */
GRANT EXECUTE ON dbo.PsCURCVSN_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCURCVSN_05 TO GDBBATCH
go

