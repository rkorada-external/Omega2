USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_11_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_11_O2
    IF OBJECT_ID('PsEST_IFRS17_11_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_11_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_11_O2 >>>'
END
go
create procedure PsEST_IFRS17_11_O2 
AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Riyadh
Creation date     : 09/07/2018

Description       : 
_________________
Modification: MOD1 
Author: Riyadh 
Date: 14/08/2019
Description: Spira 80697 : Duplicate index in table TLIDRID during upload
_________________
Modification: MOD2
Author: S.Behague
Date: 31/03/2021
Description: Spira 95137 : Apolo QE - Script to change estimate type from yearly to quaterly - TLIFDRID feeding
_________________
Modification: MOD3
Author: S.Behague
Date: 03/12/2021
Description: Spira 98335 Script to move to quaterly estimates - Remaining issues
_________________
*/


declare
        @error_type   int,
        @blcshtyea_nf smallint,
        @blcshtmth_nf tinyint
        
 CREATE TABLE #TLIFDRID_TEMP
(
    
    CTR_NF       UCTR_NF    NOT NULL,
    END_NT       UEND_NT    NOT NULL,
    SEC_NF       USEC_NF    NOT NULL,
    UWY_NF       UUWY_NF    NOT NULL,
    UW_NT        UUW_NT     NOT NULL,
    CRE_D        UUPD_D      NOT NULL,
    BALSHEY_NF   smallint   NOT NULL,
    BALSHTMTH_NF tinyint    NOT NULL,
    ACY_NF       smallint   NOT NULL,
    ACM_NF      tinyint NOT NULL,
    SSD_CF       USSD_CF    NOT NULL,
    AUTUPD_B     bit        DEFAULT 0         NOT NULL,
    COMACC_B     bit        DEFAULT 0         NOT NULL,
    CMT_NT       UCMT_NT    NULL,
    CREUSR_CF    UUPDUSR_CF     NOT NULL,
    LSTUPD_D     UUPD_D      NOT NULL,
    LSTUPDUSR_CF UUPDUSR_CF      NOT NULL,
    RESPROPAG_B  bit        DEFAULT 0         NOT NULL,
    SEGUPD_B     bit        DEFAULT 0         NOT NULL
)       

SELECT  @blcshtyea_nf  = MIN(BLCSHTYEA_NF ) FROM BREF..TCALEND Where END_D > GETDATE()
SELECT  @blcshtmth_nf  = MIN(BLCSHTMTH_NF ) FROM BREF..TCALEND Where END_D > GETDATE() AND BLCSHTYEA_NF  = @blcshtyea_nf

INSERT INTO #TLOADING_STEP11
SELECT DISTINCT L.CTR_NF, L.SEC_NF, 0
FROM #TLIFEST L,  #TRETRO R
WHERE L.CTR_NF =* R.RETCTR_NF 
AND L.ACY_NF  IN (SELECT DISTINCT retaccyer_nf FROM BRET..TRACCSEN R WHERE R.RETCTR_NF = L.CTR_NF AND R.ACCSENSTS_CT <>5 AND R.SCOENDMTH_NF <> 12 )
AND R.OLD_ESTCRB_CT in ('O','V') AND R.NEW_ESTCRB_CT = 'T'
UNION
SELECT DISTINCT L.CTR_NF, L.SEC_NF, 0
FROM TLIFEST L, #TASSUMED A
WHERE L.CTR_NF =* A.CTR_NF 
AND A.OLD_ESTCRB_CT in ('O','V') AND A.NEW_ESTCRB_CT = 'T'
AND ( L.ACY_NF NOT IN (SELECT DISTINCT ACY_NF FROM BCTA..TCPLACC C WHERE C.CTR_NF = L.CTR_NF )OR L.ACY_NF  IN (SELECT DISTINCT ACY_NF FROM BCTA..TCPLACC C WHERE C.CTR_NF = L.CTR_NF AND C.SCOENDMTH_NF <> 12))

UPDATE #TLOADING_STEP11 SET MAXACY_NF = (SELECT MAX(UWY_NF) FROM TLIFDRI L WHERE L.CTR_NF=#TLOADING_STEP11.CTR_NF AND COMACC_B = 1)
UPDATE #TLOADING_STEP11 SET MAXACY_NF = (SELECT MAX(ACY_NF) FROM BCTA..TCPLACC L WHERE L.CTR_NF=#TLOADING_STEP11.CTR_NF ) WHERE MAXACY_NF is null


INSERT into #TLIFDRID_TEMP
SELECT 
 
    D.CTR_NF       ,
    D.END_NT   ,
    D.SEC_NF   ,
    D.UWY_NF   ,
    D.UW_NT    ,
    D.CRE_D    ,
    0  ,
    0,
    D.ACY_NF       ,
    0     ,
    D.SSD_CF      ,
    D.AUTUPD_B    ,
    D.COMACC_B    ,
    0      ,
    USER   ,
    D.LSTUPD_D    ,
    USER,
    D.RESPROPAG_B  ,
    0   
FROM TLIFDRI D, #TLOADING_STEP11 L 
WHERE D.CTR_NF = L.CTR_NF
  --AND D.SEC_NF = L.SEC_NF
  --AND D.UWY_NF = L.MAXACY_NF +1
  and D.LSTUPD_D = (select max(LSTUPD_D) from TLIFDRI D1 where D1.CTR_NF = D.CTR_NF and D1.SEC_NF = D.SEC_NF and D.UWY_NF = D1.UWY_NF and D1.ACY_NF = D.ACY_NF) --MOD1

-- spira 98335  
delete #TLIFDRID_TEMP from #TLIFDRID_TEMP D,  #TLOADING_STEP11 L
where D.CTR_NF = L.CTR_NF
and COMACC_B= 0
and exists (select 1 from #TLIFDRID_TEMP D1 where D1.CTR_NF = L.CTR_NF and D1.COMACC_B = 1)

  
DECLARE @count INT 
DECLARE @ACM INT
SELECT @ACM = 3


WHILE @ACM < 13 
  BEGIN
       
        INSERT INTO  #TLIFDRID   
        SELECT  distinct
        D.CTR_NF       ,
        D.END_NT   ,
        D.SEC_NF   ,
        D.UWY_NF  ,
        D.UW_NT    ,
        GETDATE()    ,
        @blcshtyea_nf    ,
        @blcshtmth_nf,
        D.ACY_NF   ,
        @ACM    ,
        D.SSD_CF      ,
        D.AUTUPD_B    ,
        D.COMACC_B    ,
        0      ,
        USER   ,
        GETDATE()    ,
        USER,
        D.RESPROPAG_B  ,
        D.SEGUPD_B
        FROM #TLIFDRID_TEMP D, BRET..TRETCTR R
        WHERE D.CTR_NF = R.RETCTR_NF 
        --and D.UWY_NF = R.RTY_NF
        and D.SSD_CF = R.SSD_CF
        and R.RETCTRSTS_CT not in (19)
        
        INSERT INTO  #TLIFDRID   
        SELECT  distinct
        D.CTR_NF       ,
        D.END_NT   ,
        D.SEC_NF   ,
        D.UWY_NF ,
        D.UW_NT    ,
        GETDATE()    ,
        @blcshtyea_nf    ,
        @blcshtmth_nf,
        D.ACY_NF    ,
        @ACM    ,
        D.SSD_CF      ,
        D.AUTUPD_B    ,
        D.COMACC_B    ,
        0      ,
        USER   ,
        GETDATE()    ,
        USER,
        D.RESPROPAG_B  ,
        D.SEGUPD_B
        FROM #TLIFDRID_TEMP D,BTRT..TCONTR A
        WHERE D.CTR_NF = A.CTR_NF 
        --and D.UWY_NF = A.UWY_NF  
        and D.SSD_CF = A.SSD_CF
        and A.CTRSTS_CT not in (19)
        
    SET @ACM = @ACM + 3
  END
  
  /**************** Contract Cancelled ************/
  SELECT @ACM = 3


WHILE @ACM < 13 
  BEGIN
  Select @count = 0

    WHILE @COUNT < 5 
    BEGIN
       
        INSERT INTO  #TLIFDRID   
        SELECT  distinct
        D.CTR_NF       ,
        D.END_NT   ,
        D.SEC_NF   ,
        D.UWY_NF   ,
        D.UW_NT    ,
        GETDATE()    ,
        @blcshtyea_nf    ,
        @blcshtmth_nf,
        D.ACY_NF   + @COUNT    ,
        @ACM    ,
        D.SSD_CF      ,
        D.AUTUPD_B    ,
        D.COMACC_B    ,
        0      ,
        USER   ,
        GETDATE()    ,
        USER,
        D.RESPROPAG_B  ,
        D.SEGUPD_B
        FROM #TLIFDRID_TEMP D, BRET..TRETCTR R
        WHERE D.CTR_NF = R.RETCTR_NF 
        --and D.UWY_NF = R.RTY_NF
        and D.SSD_CF = R.SSD_CF
        and R.RETCTRSTS_CT in (19)
        
        INSERT INTO  #TLIFDRID   
        SELECT  distinct
        D.CTR_NF       ,
        D.END_NT   ,
        D.SEC_NF   ,
        D.UWY_NF   ,
        D.UW_NT    ,
        GETDATE()    ,
        @blcshtyea_nf    ,
        @blcshtmth_nf,
        D.ACY_NF   + @COUNT    ,
        @ACM    ,
        D.SSD_CF      ,
        D.AUTUPD_B    ,
        D.COMACC_B    ,
        0      ,
        USER   ,
        GETDATE()    ,
        USER,
        D.RESPROPAG_B  ,
        D.SEGUPD_B
        FROM #TLIFDRID_TEMP D,BTRT..TCONTR A
        WHERE D.CTR_NF = A.CTR_NF 
        --and D.UWY_NF = A.UWY_NF  
        and D.SSD_CF = A.SSD_CF
        and A.CTRSTS_CT  in (19)
        
      SET @COUNT = @COUNT + 1
    END  
      
    SET @ACM = @ACM + 3
  END
  
  
  
GO

EXEC sp_procxmode 'PsEST_IFRS17_11_O2', 'unchained'
go

IF OBJECT_ID('PsEST_IFRS17_11_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_11_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_11_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_11_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_11_O2 TO GDBBATCH
go
