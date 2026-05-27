USE BEST
go
IF OBJECT_ID ('dbo.PsSUBTRS_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSUBTRS_01
    IF OBJECT_ID ('dbo.PsSUBTRS_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSUBTRS_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSUBTRS_01 >>>'
END
go
/*
 * creation de la procedure 
 */

create procedure dbo.PsSUBTRS_01
	
as

/***************************************************

Programme: PsSUBTRS_01
Fichier script associé : 
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: R. BEN EZZINE
Date de creation: 07/01/2014
Description du programme: 
 
      

Parametres: aucun
Conditions d'execution: 
Commentaires: servira en estimation pour la fonction 
_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
*****************************************************/

SELECT  PCPTRS_CF,
        TRS_CF,
        SUBTRS_CF,
        SUBTRS_GL,
        SUBTRS_GS,
        SUBTRSEXP_D,
        SUBTRSINC_D,
        CMT_NT,
        TRSINPUTTYPE_CT,
        TRSNATURE_CT,
        LOGSIG_CT,
        LOB_CF,
        TRSTYPE_CT,
        TRSPURERETRO_B,
        DACVOBATYPE_CT,
        COMPLEMENT_B, 
        NEWBALSHEETPROPAG_B,
        CELLPROTECEXC_B

  FROM BREF..TSUBTRS
 ORDER BY PCPTRS_CF,
               TRS_CF,
               SUBTRS_CF
go

IF OBJECT_ID('dbo.PsSUBTRS_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSUBTRS_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSUBTRS_01 >>>'
go
GRANT EXECUTE ON dbo.PsSUBTRS_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSUBTRS_01 TO GDBBATCH
go
