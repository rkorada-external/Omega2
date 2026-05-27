USE BEST
go
IF OBJECT_ID('dbo.PsSUBTRSESBPROP_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSUBTRSESBPROP_01
    IF OBJECT_ID('dbo.PsSUBTRSESBPROP_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSUBTRSESBPROP_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSUBTRSESBPROP_01 >>>'
END
go
/*
 * creation de la procedure 
 */

create procedure dbo.PsSUBTRSESBPROP_01
	
as

/***************************************************

Programme: PsSUBTRSESBPROP_01
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
        SSD_CF,
        ESB_CF,
        GLTFEEDING_B,
        INTERNRETRO_B,
        SRVFEEDING_B,
        PREMIUMPNPEGPI_CT,
        RETROAUTO_B,
        COMACIMPACT_B,
        CASHFLOWPOS_CT,
        GAAP1TRS_CT,
        GAAP2TRS_CT,
        GAAP3TRS_CT,
        GAAP4TRS_CT,
        GAAP5TRS_CT,
        CRE_D,
        CREUSR_CF,
        LSTUPD_D,
        LSTUPDUSR_CF	
        
  FROM BREF..TSUBTRSESBPROP
 ORDER BY PCPTRS_CF,
                TRS_CF,
                SUBTRS_CF
go
EXEC sp_procxmode 'dbo.PsSUBTRSESBPROP_01', 'unchained'
go
IF OBJECT_ID('dbo.PsSUBTRSESBPROP_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSUBTRSESBPROP_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSUBTRSESBPROP_01 >>>'
go
GRANT EXECUTE ON dbo.PsSUBTRSESBPROP_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSUBTRSESBPROP_01 TO GDBBATCH
go
