use BEST
go

use BEST
go

/*
 * DROP PROC dbo.PsRETTRF_01
 */
IF OBJECT_ID('dbo.PsRETTRF_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsRETTRF_01
    PRINT '<<< DROPPED PROC dbo.PsRETTRF_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsRETTRF_01
	
as

/***************************************************

Programme: PsRETTRF_01
Fichier script associé : ESSRTF01.PRC
Domaine : (ES) Estimation
Base principale : BREF
Version: 1
Auteur: C.Soulier (CGI)
Date de creation: 30 juillet 1997
Description du programme: 
 
      Extraction de la table TRETTRF

Parametres: aucun
Conditions d'execution: 
Commentaires: servira en estimation pour la fonction de transformation 
	de poste comptable acceptation en poste retrocession

_________________
MODIFICATION 1
[001] 27/12/2013 R. cassis :spot:25427 Centralization - ajout Grant
*****************************************************/

SELECT 	dettrs_cf, 
		accadmtyp_ct, 
		retaccadm_b,
		trf_b,
		del_b
FROM 	bref..trettrf
ORDER BY dettrs_cf, accadmtyp_ct, retaccadm_b
go

IF OBJECT_ID('dbo.PsRETTRF_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsRETTRF_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsRETTRF_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETTRF_01
 */
GRANT EXECUTE ON dbo.PsRETTRF_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsRETTRF_01 TO GDBBATCH
go

