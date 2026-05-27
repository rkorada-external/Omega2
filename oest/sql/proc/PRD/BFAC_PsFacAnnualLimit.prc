USE BFAC

GO
IF OBJECT_ID('dbo.PsFacAnnualLimit') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFacAnnualLimit
    IF OBJECT_ID('dbo.PsFacAnnualLimit') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFacAnnualLimit >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFacAnnualLimit >>>'
END
GO

CREATE PROCEDURE dbo.PsFacAnnualLimit

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

SELECT b.SSD_CF,
a.CTR_NF,
b.SEC_NF,
a.UWY_NF,
a.UW_NT,
a.END_NT,
a.DIV_NT,
a.ACCLIACUR_CF,
a.MPLSCEAMT_M
FROM BFAC..TACCLIA a
INNER JOIN BFAC..TSECTION b ON a.CTR_NF = b.CTR_NF AND
a.UWY_NF = b.UWY_NF AND
a.UW_NT = b.UW_NT AND
a.END_NT = b.END_NT AND
a.DIV_NT = b.DIV_NT
INNER JOIN BFAC..TCONTR c ON a.CTR_NF = c.CTR_NF AND
a.UWY_NF = c.UWY_NF AND
a.UW_NT = c.UW_NT AND
a.END_NT = c.END_NT
WHERE b.LOB_CF NOT IN ('5','10','12','30', '31') AND
b.SECSTS_CT IN (14, 16, 17, 18, 19) AND
c.CTRSTS_CT IN (14, 16, 17, 18, 19) AND
a.MPLSCEAMT_M IS NOT NULL AND
b.SSD_CF in (select ssd_cf from bref..tbatchssd where batchuser_cf= suser_name())
UNION
SELECT b.SSD_CF,
a.CTR_NF,
b.SEC_NF,
a.UWY_NF,
a.UW_NT,
a.END_NT,
a.DIV_NT,
a.ACCLIACUR_CF,
d.SCOPML_M
FROM BFAC..TACCLIA a
INNER JOIN BFAC..TSECTION b ON a.CTR_NF = b.CTR_NF AND
a.UWY_NF = b.UWY_NF AND
a.UW_NT = b.UW_NT AND
a.END_NT = b.END_NT AND
a.DIV_NT = b.DIV_NT
INNER JOIN BFAC..TCONTR c ON a.CTR_NF = c.CTR_NF AND
a.UWY_NF = c.UWY_NF AND
a.UW_NT = c.UW_NT AND
a.END_NT = c.END_NT
INNER JOIN BFAC..TFAMLIA d ON b.CTR_NF = d.CTR_NF AND
b.UWY_NF = d.UWY_NF AND
b.UW_NT = d.UW_NT AND
b.END_NT = d.END_NT AND 
b.SEC_NF = d.SEC_NF
WHERE b.LOB_CF IN ('5','10','12') AND
b.SECSTS_CT IN (14, 16, 17, 18, 19) AND
c.CTRSTS_CT IN (14, 16, 17, 18, 19) AND
d.SCOPML_M IS NOT NULL AND
b.SSD_CF in (select ssd_cf from bref..tbatchssd where batchuser_cf= suser_name())

GO
IF OBJECT_ID('dbo.PsFacAnnualLimit') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsFacAnnualLimit >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFacAnnualLimit >>>'
GO
GRANT EXECUTE ON dbo.PsFacAnnualLimit TO GOMEGA
GO
GRANT EXECUTE ON dbo.PsFacAnnualLimit TO GDBBATCH
GO