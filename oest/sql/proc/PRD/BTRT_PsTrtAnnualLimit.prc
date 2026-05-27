USE BTRT

GO
IF OBJECT_ID('dbo.PsTrtAnnualLimit') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTrtAnnualLimit
    IF OBJECT_ID('dbo.PsTrtAnnualLimit') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTrtAnnualLimit >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTrtAnnualLimit >>>'
END
GO

CREATE PROCEDURE dbo.PsTrtAnnualLimit

AS
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BFAC
Auteur                  : NBD
Date de creation        : 06/01/2021
Description du programme: Record into file the content of the annual limit file from BFAC
Conditions d'execution  : chaine ESID0060
Commentaires            : Called by ESFD0063.cmd
_________________
MODIFICATIONS
[MOD001]	07/20/2022	JBD Spira 105157 ESFD0060 - extract ratios from O2 TP -> This SP should have been only in DW, but was already on TP. Now it's officialy in TP. Just add a comment FYI.

*****************************************************/

SELECT a.SSD_CF,
a.CTR_NF,
a.SEC_NF,
a.UWY_NF,
a.UW_NT,
a.END_NT,
b.DIV_NT,
a.LIACUR_CF,
a.LIALIM_M
FROM BTRT..TFAMLIA a
INNER JOIN BTRT..TSECTION b ON a.CTR_NF = b.CTR_NF AND
a.SEC_NF = b.SEC_NF AND
a.UWY_NF = b.UWY_NF AND
a.UW_NT = b.UW_NT AND
a.END_NT = b.END_NT
INNER JOIN BTRT..TCONTR c ON a.CTR_NF = c.CTR_NF AND
a.UWY_NF = c.UWY_NF AND 
a.UW_NT = c.UW_NT AND
a.END_NT = c.END_NT
WHERE b.LOB_CF NOT IN ('30', '31') AND
b.SECSTS_CT IN (14, 16, 17, 18, 19) AND
c.CTRSTS_CT IN (14, 16, 17, 18, 19) AND
a.LIALIM_M IS NOT NULL AND
a.SSD_CF in (select ssd_cf from bref..tbatchssd where batchuser_cf= suser_name())

GO
IF OBJECT_ID('dbo.PsTrtAnnualLimit') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTrtAnnualLimit >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTrtAnnualLimit >>>'
GO
GRANT EXECUTE ON dbo.PsTrtAnnualLimit TO GOMEGA
GO
GRANT EXECUTE ON dbo.PsTrtAnnualLimit TO GDBBATCH
GO