USE BEST
go
IF OBJECT_ID('dbo.PsLIFEST_09_1') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFEST_09_1
    IF OBJECT_ID('dbo.PsLIFEST_09_1') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFEST_09_1 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFEST_09_1 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure dbo.PsLIFEST_09_1
	(
	@p_balshtyea_nf	 smallint,
    @p_balshtmth_nf  tinyint,
	@p_cre_d         datetime
	)
as

/***************************************************

Programme               : PsLIFEST_09_1

Fichier script associé  : PsLIFEST_09_1.PRC

Domaine                 : (ES) Estimation

Base principale         : BEST

Version                 : 1

Auteur                  : Tony RIPERT

Date de creation        : 20/07/2010

Description du programme:

      Sélection des postes 1900 et 1901 dans TLIFEST

_________________
MODIFICATION 1
Auteur      : JF VDV
Date        : 10.1
Description : [20198] - Eviter les doublons dans TLIFEST (cas inventaire en journee)
_________________
MODIFICATION 2
Description : Removed dbo and added 'with execute as caller as'
Modification 3: S.ASKRI spot 29257: proc generant un fichier vide

*****************************************************/

/*
SELECT l.SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF,
       convert(char(8),CRE_D,112) + ' ' + convert(char(8),CRE_D,108),
       PRS_CF, ACMTRS_NT, BALSHEY_NF, BALSHTMTH_NF, CUR_CF, ESTMNT_M,
       UPD_NF = ' ', LOB_CF = '  ', ACCSTS_CT = 0, ACCADMTYP_CF = 0,
       ESTCRB_CT = NULL, CED_NF = NULL, BRK_NF = NULL, PAY_NF = NULL,
       GAYPAYORD_NT = NULL, ADJCOD_CT = NULL, RETCOD_CT = NULL,
       DETTRS_NT = NULL, ADJSIG_B = 0, ESB_CF = 0, LIFTRTTYP_CF = "",
       INDSUP_B, ORICOD_LS, CREUSR_CF, 
       convert(char(8),LSTUPD_D,112) + ' ' + convert(char(8),LSTUPD_D,108),
       LSTUPDUSR_CF,
       SPIMOD_CF = NULL
FROM   BEST..TLIFEST l, BTRAV..TESTSSD e
where  l.SSD_CF        = e.SSD_CF
and    l.BALSHEY_NF    = @p_balshtyea_nf
and    l.BALSHTMTH_NF !> @p_balshtmth_nf
and    l.acmtrs_nt in (1900, 1901, 2900, 2901)
and    cre_d  < DATEADD(DAY,1,@p_cre_d)     -- [20198]  pour éliminer les écritures du jour
*/
return 0
go
EXEC sp_procxmode 'dbo.PsLIFEST_09_1', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFEST_09_1') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFEST_09_1 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFEST_09_1 >>>'
go
GRANT EXECUTE ON dbo.PsLIFEST_09_1 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFEST_09_1 TO GDBBATCH
go