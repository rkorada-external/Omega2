use BEST
go

use BEST
go

/*
 * DROP PROC dbo.PsDETTRS_11
 */
IF OBJECT_ID('dbo.PsDETTRS_11') IS NOT NULL
BEGIN
    DROP PROC dbo.PsDETTRS_11
    PRINT '<<< DROPPED PROC dbo.PsDETTRS_11 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsDETTRS_11
	
as

/***************************************************

Programme: PsDETTRS_11
Fichier script associé : ESSDET11.PRC
Domaine : (ES) Estimation
Base principale : BREF
Version: 1
Auteur: C.Soulier (CGI)
Date de creation: 30 juillet 1997
Description du programme: 
 
      Extraction du poste comptable (detttrs_cf), du poste de contrepartie (ctrscod_cf), 
	du type de poste (trstyp_ct), du poste retro accocie (rettrscod_cf) et des flags 
	ret_b et comp_b de la table TDETTRS

Parametres: aucun
Conditions d'execution: 
Commentaires: servira en estimation pour la fonction de transformation 
	de poste comptable acceptation en poste retrocession

_________________
MODIFICATION 1
[001] 27/12/2013 R. cassis :spot:25427 Centralization - ajout Grant
*****************************************************/

SELECT dettrs_cf, ctrscod_cf, trstyp_ct, rettrscod_cf, ret_b, comp_b 
FROM 	bref..tdettrs
ORDER BY dettrs_cf

go
IF OBJECT_ID('dbo.PsDETTRS_11') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsDETTRS_11 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsDETTRS_11 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsDETTRS_11
 */
GRANT EXECUTE ON dbo.PsDETTRS_11 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsDETTRS_11 TO GDBBATCH
go

