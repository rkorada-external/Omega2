USE BEST
go
IF OBJECT_ID('dbo.PsFLOARAT_I17G_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFLOARAT_I17G_01
    IF OBJECT_ID('dbo.PsFLOARAT_I17G_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFLOARAT_I17G_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFLOARAT_I17G_01 >>>'
END
go

/*
 * creation de la procedure 
*/

CREATE PROCEDURE dbo.PsFLOARAT_I17G_01 AS

/***************************************************

PROCEDURE	            : PsFLOARAT_I17G_01
DOMAINE 	                : EXTRACTION FOLARAT FILE I17G
SPIRA		                : 82279
BASE PRINCIPALE        : BEST
VERSION		            : 0.1
AUTEUR		                : L.ELFAHIM
DATE DE CREATION     : 12/2018

______________
MODIFICATION 	: xxxxxx
AUTOR		        : xxxxxx
DATE		            : xxxxxx
DESCRIPTION	    : xxxxxx
*****************************************************/

declare @erreur int

-- CREATION OF TEMPORARY TABLES
CREATE TABLE #TMP
(
    CTR_NF 	    UCTR_NF not null,
    END_NT 	    UEND_NT not null,
    SEC_NF 	        USEC_NF not null,
    UWY_NF 	    UUWY_NF not null,
    UW_NT 	        UUW_NT not null,
    FIXCOM_R	    USHORAT_R null,
    OVRCOM_R	USHORAT_R null,
    TAX_R 	        USHORAT_R null,
    PRDBRK_R	    USHORAT_R null,
    TAXWO_R 	    USHORAT_R null
)        

CREATE TABLE #TMP1
(
    CTR_NF 	    UCTR_NF not null,
    END_NT 	    UEND_NT not null,
    SEC_NF 	        USEC_NF not null,
    UWY_NF 	    UUWY_NF not null,
    UW_NT 	        UUW_NT not null,
    TAX_R 	        USHORAT_R null
)        

-- FILL IN CREATED TEMPORARY TABLES 
INSERT INTO #TMP
SELECT 
    CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,         
    UW_NT,
    FIXCOM_R AS COMMIS_R,
    OVRCOM_R AS OVECOM_R,            
    NULL AS TAX_R,
    PRDBRK_R AS BROKER_R,
    NULL AS TAXWO_R
    FROM BTRT..TFAMCHG
    --WHERE CTR_NF='04T000392'
    --AND SEC_NF = 1
    --AND UWY_NF = 2019 

INSERT INTO #TMP1
SELECT 
    CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,         
    UW_NT,
    SUM(TAX_R) AS TAX_R
    FROM BTRT..TFAMCHGT 
    WHERE TAXBAS_CF = '1'
    --AND CTR_NF='04T000392'
    --AND SEC_NF = 1
    --AND UWY_NF = 2019 
    GROUP BY CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT

-- FIRST UPDATE OF TEMPORARY TABLE
UPDATE  #TMP 
SET        #TMP.TAX_R   = #TMP1.TAX_R
FROM     #TMP, #TMP1
WHERE 	 #TMP.CTR_NF  = #TMP1.CTR_NF
AND    	 #TMP.END_NT  = #TMP1.END_NT
AND    	 #TMP.SEC_NF   = #TMP1.SEC_NF
AND    	 #TMP.UWY_NF = #TMP1.UWY_NF
AND    	 #TMP.UW_NT   = #TMP1.UW_NT

-- ERASE TEMPORARY TABLE
DELETE FROM #TMP1

INSERT INTO #TMP1
SELECT 
    CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,         
    UW_NT,
    SUM(TAX_R) AS TAX_R
    FROM BTRT..TFAMCHGT 
    WHERE TAXBAS_CF = '2'
    --AND CTR_NF='04T000392'
    --AND SEC_NF = 1
    --AND UWY_NF = 2019 
    GROUP BY CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT

-- FIRST UPDATE OF TEMPORARY TABLE
UPDATE  #TMP 
SET        #TMP.TAXWO_R   = #TMP1.TAX_R
FROM     #TMP, #TMP1
WHERE 	 #TMP.CTR_NF  = #TMP1.CTR_NF
AND    	 #TMP.END_NT  = #TMP1.END_NT
AND    	 #TMP.SEC_NF   = #TMP1.SEC_NF
AND    	 #TMP.UWY_NF = #TMP1.UWY_NF
AND    	 #TMP.UW_NT   = #TMP1.UW_NT

BEGIN
	SELECT * FROM #TMP
END

return 0
go
EXEC sp_procxmode 'dbo.PsFLOARAT_I17G_01', 'unchained'
go
IF OBJECT_ID('dbo.PsFLOARAT_I17G_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsFLOARAT_I17G_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFLOARAT_I17G_01 >>>'
go
GRANT EXECUTE ON dbo.PsFLOARAT_I17G_01 TO GDBBATCH
go
GRANT EXECUTE ON dbo.PsFLOARAT_I17G_01 TO GOMEGA
go
