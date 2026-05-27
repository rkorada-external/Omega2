USE BEST
go

IF OBJECT_ID('PsLIFEST_13_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsLIFEST_13_O2
    IF OBJECT_ID('PsLIFEST_13_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsLIFEST_13_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsLIFEST_13_O2 >>>'
END
go

create procedure PsLIFEST_13_O2
WITH EXECUTE AS CALLER AS
/****************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert
Creation date     : 05/10/2018
Description       : Extracts yearly loaded estimates out of BTRAV..EST_ESID0811_TLIFESTQ
_________________
Modification: [MOD1] 
Author: L. Wernert
Date: 19/03/2019
Description: Increase the precision of the numeric field ROW_NUMBER

*****************************************************/

-- Extraction
--  CTR_NF,SEC_NF,UWY_NF,ACM_NF,ACY_NF,CUR_CF,DETTRNCOD_CF,GAAP_NT,ESTMNT_M,NUMERODELINE where ACM_NF=13 ORDER BY CTR_NF,SEC_NF,UWY

CREATE TABLE #EST_ESID0811_TLIFESTQ_TEMP
(
    CTR_NF        UCTR_NF    NOT NULL,
    SEC_NF        USEC_NF    NOT NULL,
    UWY_NF        UUWY_NF    NOT NULL,
    ACM_NF        UUW_NT        NOT NULL,
    ACY_NF        UUWY_NF       NOT NULL,    
    CUR_CF        UCUR_CF    NOT NULL,
    DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
    GAAP_NT       tinyint    NOT NULL,
    ESTMNT_M      UAMT_M     NOT NULL,
    ROW_NUMBER    numeric(10,0) identity -- [MOD1]

)

Insert into #EST_ESID0811_TLIFESTQ_TEMP
SELECT 
  tlifq.CTR_NF, 
  tlifq.SEC_NF, 
  tlifq.UWY_NF, 
  tlifq.ACM_NF,
  tlifq.ACY_NF,
  tlifq.CUR_CF,
  tlifq.DETTRNCOD_CF, 
  tlifq.GAAP_NT, 
  tlifq.ESTMNT_M 
  FROM 
  BTRAV..EST_ESID0811_TLIFESTQ tlifq
WHERE tlifq.ACM_NF = 13
--GROUP BY 
--  tlifq.CTR_NF, tlifq.SEC_NF, tlifq.UWY_NF


SELECT * FROM  #EST_ESID0811_TLIFESTQ_TEMP t
WHERE t.ACM_NF = 13
--GROUP BY 
--  t.CTR_NF, t.SEC_NF, t.UWY_NF

return 0
go

EXEC sp_procxmode 'PsLIFEST_13_O2', 'unchained'
go
IF OBJECT_ID('PsLIFEST_13_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFEST_13_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFEST_13_O2 >>>'
go
GRANT EXECUTE ON PsLIFEST_13_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFEST_13_O2 TO GDBBATCH
go