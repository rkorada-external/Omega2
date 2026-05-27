USE BEST
go
/*
 * creation de la procedure 
*/

create or replace procedure dbo.PsGetSegment_01
(
    @p_norm_cf		char(5)
)
as

/***************************************************

Procedure: PsGetSegment_01
Domaine : Expenses and Maintenance calculation
Base principale : BEST
Auteur: LEL
Date de creation: 24/2021
_______________
MODIFICATION 1
[001] MiS  17/01/2023 :spira:108037 : Ajout condition pour I17S

Auteur: LEL
Date: 16/09/2021
Description: ACF/PCA: Expenses calculation

*****************************************************/

declare   @erreur int

BEGIN
	SELECT   CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT,  
        CASE 
            WHEN @p_norm_cf = "I17G" THEN GRPIFRSSEG_CT
            WHEN @p_norm_cf = "I17S" THEN GRPIFRSSEG_CT
            WHEN @p_norm_cf = "I17P" THEN PARIFRSSEG_CT
            WHEN @p_norm_cf = "I17L" THEN LOCIFRSSEG_CT
            ELSE  NULL
        END
    FROM BTRT..TSECIFRS
    union all
    SELECT   CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT,  
        CASE 
            WHEN @p_norm_cf = "I17G" THEN GRPIFRSSEG_CT
            WHEN @p_norm_cf = "I17S" THEN GRPIFRSSEG_CT
            WHEN @p_norm_cf = "I17P" THEN PARIFRSSEG_CT
            WHEN @p_norm_cf = "I17L" THEN LOCIFRSSEG_CT
            ELSE  NULL
        END
    FROM BFAC..TSECIFRS
END

return 0
go
EXEC sp_procxmode 'dbo.PsGetSegment_01', 'unchained'
go
IF OBJECT_ID('dbo.PsGetSegment_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsGetSegment_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsGetSegment_01 >>>'
go
GRANT EXECUTE ON dbo.PsGetSegment_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsGetSegment_01 TO GDBBATCH
go
