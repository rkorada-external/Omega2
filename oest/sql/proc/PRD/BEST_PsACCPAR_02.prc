USE BEST
Go

/* 
    DROP PROC dbo.PsACCPAR_02 */
IF OBJECT_ID('dbo.PsACCPAR_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsACCPAR_02
    PRINT '<<< DROPPED PROC dbo.PsACCPAR_02 >>>'
END
go

/*
 * creation de la procedure */
create procedure PsACCPAR_02

as
/***************************************************
Programme:          PsACCPAR_02
Domaine :           (ES) Estimation
Base principale :   BEST
Version:            1
Auteur:             ME27 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:   Sélection d'enregistrement dans TACCPAR

Commentaires:
_________________
MODIFICATION    1
Auteur        : TRIPERT
Date          : 29/07/2010
Version       : 10.1
Description   : Ajout l'extraction des flags (RESTEC_B, RESDAC_B, RESFIN_B, SUMRISK_B)
                -Dom: corrections pour livraison.
*****************************************************/

SELECT ACMTRS_NT,
       PRS_CF,
       ADJCOD_CT,
       RETCOD_CT,
       DETTRS_CF,
       ADJSIG_B,
       SPIMOD_CT,
       RESTEC_B,
       RESDAC_B,
       RESFIN_B,
       SUMRISK_B
FROM BEST..TACCPAR
ORDER BY ACMTRS_NT, DETTRS_CF

return 0
go

/*
 * fin de la procedure */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/
exec sp_SCOR_INSPRC 'ESSACC02', 'PsACCPAR_02', 'BEST', 'ME27'
go

IF OBJECT_ID('dbo.PsACCPAR_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsACCPAR_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsACCPAR_02 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsACCPAR_02 */
GRANT EXECUTE ON dbo.PsACCPAR_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCPAR_02 TO GDBBATCH
go
