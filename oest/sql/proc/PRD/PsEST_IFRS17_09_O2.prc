USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_09_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_09_O2
    IF OBJECT_ID('PsEST_IFRS17_09_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_09_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_09_O2 >>>'
END
go
create procedure PsEST_IFRS17_09_O2 
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
Date: 27/03/2019
Description: Spira 76819 Balance sheet month and year issue
_________________
*/


declare
        @error_type   int,
        @blcshtyea_nf smallint,
        @blcshtmth_nf tinyint,
        @TYPPER             Char(1),
        @DATE               Datetime,
        @SPCEND_D           Datetime,
        @ACCOUNT_D          Datetime,   
        @CLOSING_B          Bit 
        
Create table #TLIFEST_BAL (													
    CTR_NF        UCTR_NF    NOT NULL,
    END_NT        UEND_NT    NOT NULL,
    SEC_NF        USEC_NF    NOT NULL,
    UWY_NF        UUWY_NF    NOT NULL,
    UW_NT         UUW_NT     NOT NULL,
    CRE_D         UUPD_D     NOT NULL,
    BALSHEY_NF    smallint   NOT NULL,
    BALSHTMTH_NF  tinyint    NOT NULL,
    ACY_NF        smallint   NOT NULL,
    GAAP_NT       tinyint    NOT NULL,
    DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
    ACM_NF        tinyint    DEFAULT 13 NOT NULL,
    PRS_CF        smallint   NOT NULL,
    ACMTRS_NT     smallint   NOT NULL,
    SSD_CF        USSD_CF    NOT NULL,
    CUR_CF        UCUR_CF    NOT NULL,
    ESTMNT_M      UAMT_M     NOT NULL,
    INDSUP_B      bit        DEFAULT 0  NOT NULL,
    ORICOD_LS     UL16       NULL,
    CREUSR_CF     UUPDUSR_CF NOT NULL,
    LSTUPD_D      UUPD_D     NOT NULL,
    LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
    ORICTR_NF     UCTR_NF    NULL,
    ORISEC_NF     USEC_NF    NULL,
    ORIUWY_NF     UUWY_NF    NULL,
    DIFF_M        UAMT_M     NULL,
    PROPAGATION_B bit        DEFAULT 0  NOT NULL,
    CALCULATED_B  bit        DEFAULT 0  NOT NULL,
    BATCH_B       bit        DEFAULT 0  NOT NULL)
    
    
    Create table #TLIFEST_TEMP (													
    CTR_NF        UCTR_NF    NOT NULL,
    END_NT        UEND_NT    NOT NULL,
    SEC_NF        USEC_NF    NOT NULL,
    UWY_NF        UUWY_NF    NOT NULL,
    UW_NT         UUW_NT     NOT NULL,
    CRE_D         UUPD_D     NOT NULL,
    BALSHEY_NF    smallint   NOT NULL,
    BALSHTMTH_NF  tinyint    NOT NULL,
    ACY_NF        smallint   NOT NULL,
    GAAP_NT       tinyint    NOT NULL,
    DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
    ACM_NF        tinyint    DEFAULT 13 NOT NULL,
    PRS_CF        smallint   NOT NULL,
    ACMTRS_NT     smallint   NOT NULL,
    SSD_CF        USSD_CF    NOT NULL,
    CUR_CF        UCUR_CF    NOT NULL,
    ESTMNT_M      UAMT_M     NOT NULL,
    INDSUP_B      bit        DEFAULT 0  NOT NULL,
    ORICOD_LS     UL16       NULL,
    CREUSR_CF     UUPDUSR_CF NOT NULL,
    LSTUPD_D      UUPD_D     NOT NULL,
    LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
    ORICTR_NF     UCTR_NF    NULL,
    ORISEC_NF     USEC_NF    NULL,
    ORIUWY_NF     UUWY_NF    NULL,
    DIFF_M        UAMT_M     NULL,
    PROPAGATION_B bit        DEFAULT 0  NOT NULL,
    CALCULATED_B  bit        DEFAULT 0  NOT NULL,
    BATCH_B       bit        DEFAULT 0  NOT NULL,
    ACCADMTYP_CT  UACCADMTYP_CT NULL)
    
--MOD1 START

--SELECT  @blcshtyea_nf  = MIN(BLCSHTYEA_NF ) FROM BREF..TCALEND Where END_D > GETDATE()
--SELECT  @blcshtmth_nf  = MIN(BLCSHTMTH_NF ) FROM BREF..TCALEND Where END_D > GETDATE() AND BLCSHTYEA_NF  = @blcshtyea_nf

select @DATE   = getdate()
select @TYPPER = 'E'

execute @error_type = BREF..PsCALEND_02 @DATE ,
                                    @TYPPER ,
                                    @BLCSHTYEA_NF output,
                                    @BLCSHTMTH_NF output,
                                    @SPCEND_D     output,
                                    @ACCOUNT_D    output,
                                    @CLOSING_B    output
                                    
if @error_type != 0
begin
    Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND" /* erreur de lecture */
    return @error_type
end                                    
--MOD1 END

    
---Case  COMPLETE ACOUNT

INSERT INTO #TLIFEST_BAL
SELECT
     L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D, BALSHEY_NF,BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,
    ESTMNT_M,
     INDSUP_B, ORICOD_LS ,CREUSR_CF,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B               
from TLIFEST L , #TLOADING_STEP9 T9
WHERE L.CTR_NF = T9.CTR_NF 
  AND L.ACY_NF > T9.MAXUWY_NF --MOD1
  AND L.UWY_NF > T9.MAXUWY_NF --MOD1
  AND L.DETTRNCOD_CF in (SELECT SUBSTRING(PCPTRS_CF,1,2) + SUBSTRING(TRS_CF,1,1) + SUBSTRING(SUBTRS_CF,1,2)  FROM BREF..TSUBTRS WHERE TRSTYPE_CT=3)
  AND T9.MAXUWY_NF is not null
  ORDER BY  LSTUPD_D

INSERT INTO #TLIFEST_BAL
SELECT
     L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D, BALSHEY_NF,BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,
    0,
     INDSUP_B, ORICOD_LS ,CREUSR_CF,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B               
from TLIFEST L , #TLOADING_STEP9 T9
WHERE L.CTR_NF = T9.CTR_NF 
  AND L.ACY_NF > T9.MAXUWY_NF --MOD1
  AND L.UWY_NF > T9.MAXUWY_NF --MOD1
  AND L.DETTRNCOD_CF NOT IN (SELECT SUBSTRING(PCPTRS_CF,1,2) + SUBSTRING(TRS_CF,1,1) + SUBSTRING(SUBTRS_CF,1,2)  FROM BREF..TSUBTRS WHERE TRSTYPE_CT=3)
  AND T9.MAXUWY_NF is not null
  ORDER BY  LSTUPD_D
  

INSERT INTO #TLIFEST_TEMP
SELECT
     CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,CREUSR_CF,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B , 0              
from #TLIFEST_BAL A
WHERE A.LSTUPD_D = (SELECT MAX(LSTUPD_D) FROM #TLIFEST_BAL C
                 where   C.DETTRNCOD_CF = A.DETTRNCOD_CF
                  and   C.acy_nf    = A.acy_nf
                  and   C.UWY_nf    = A.UWy_nf
                  and   C.CTR_NF = A.CTR_NF
                  and   C.END_NT = A.END_NT
                  and   C.SEC_NF = A.SEC_NF
                  and   C.UW_NT = A.UW_NT
                  --and   C.BALSHTMTH_NF = A.BALSHTMTH_NF
                  and   C.prs_cf    = A.prs_cf
                  and   C.gaap_nt    = A.gaap_nt)
                  AND A.ESTMNT_M is not null
                  

UPDATE #TLIFEST_TEMP SET ACCADMTYP_CT = (SELECT ACCADMTYP_CT FROM BTRT..TSECTION WHERE CTR_NF = #TLIFEST_TEMP.CTR_NF AND SEC_NF = 1 AND UWY_NF = (SELECT MAXUWY_NF FROM #TLOADING_STEP9 T9 WHERE CTR_NF = #TLIFEST_TEMP.CTR_NF )) WHERE CTR_NF in (Select CTR_NF FROM BTRAV..EST_IFRS17_PERIMETER) 
UPDATE #TLIFEST_TEMP SET ACCADMTYP_CT = (SELECT RETACCTYP_CT FROM BRET..TRETCTR WHERE RETCTR_NF = #TLIFEST_TEMP.CTR_NF AND RTY_NF = (SELECT MAXUWY_NF FROM #TLOADING_STEP9 T9 WHERE CTR_NF = #TLIFEST_TEMP.CTR_NF )) WHERE CTR_NF in (Select RETCTR_NF FROM BTRAV..EST_IFRS17_PERIMETER) 

UPDATE #TLIFEST_TEMP   SET ESTMNT_M = case when (SELECT MAX( ESTMNT_M) FROM #TLIFEST_TEMP L 
                                                     WHERE L.DETTRNCOD_CF = #TLIFEST_TEMP.DETTRNCOD_CF  
                                                      AND L.CTR_NF = #TLIFEST_TEMP.CTR_NF 
                                                     AND L.END_NT = #TLIFEST_TEMP.END_NT
                                                     AND L.SEC_NF = #TLIFEST_TEMP.SEC_NF
                                                     AND L.UW_NT = #TLIFEST_TEMP.UW_NT
                                                     AND L.GAAP_NT = #TLIFEST_TEMP.GAAP_NT
                                                     AND L.UWY_nf in (SELECT MIN(UWY_NF) FROM #TLIFEST_TEMP P WHERE L.CTR_NF = P.CTR_NF  ))
                                        is  null then 0         
                                       else  (SELECT MAX( ESTMNT_M) FROM #TLIFEST_TEMP L 
                                      WHERE L.DETTRNCOD_CF = #TLIFEST_TEMP.DETTRNCOD_CF  
                                      AND L.CTR_NF = #TLIFEST_TEMP.CTR_NF 
                                      AND L.END_NT = #TLIFEST_TEMP.END_NT
                                      AND L.SEC_NF = #TLIFEST_TEMP.SEC_NF
                                      AND L.UW_NT = #TLIFEST_TEMP.UW_NT
                                      AND L.GAAP_NT = #TLIFEST_TEMP.GAAP_NT
                                      AND L.UWY_nf in (SELECT MIN(UWY_NF) FROM #TLIFEST_TEMP P WHERE L.CTR_NF = P.CTR_NF  ))END
                                      
DECLARE @count INT 
DECLARE @ACM INT
SELECT @ACM = 3
WHILE @ACM < 13 
  BEGIN
  Select @count = 0
    
    INSERT INTO #TLIFESTD
    SELECT CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,GETDATE(),@blcshtyea_nf,@blcshtmth_nf, UWY_NF,GAAP_NT,DETTRNCOD_CF,@ACM,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF, 0,INDSUP_B, 'QE-RESET' ,user,GETDATE(),user,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B
    FROM #TLIFEST_TEMP 
    WHERE ACCADMTYP_CT in (1,4)
    AND UWY_NF=ACY_NF
                   
    WHILE @COUNT < 10 
    BEGIN
      INSERT INTO #TLIFESTD
      SELECT CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,GETDATE(),@blcshtyea_nf,@blcshtmth_nf, UWY_NF + @count ,GAAP_NT,DETTRNCOD_CF,@ACM,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,0,INDSUP_B, 'QE-RESET' ,user,GETDATE(),user,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B
      FROM #TLIFEST_TEMP 
      WHERE ACCADMTYP_CT in (2,3,5) 
      AND ACY_NF= (SELECT MAXUWY_NF FROM #TLOADING_STEP9 T9 WHERE CTR_NF = #TLIFEST_TEMP.CTR_NF ) + 1
      AND (UWY_NF + @count) < (@blcshtyea_nf + 5)
      
      SET @COUNT = @COUNT + 1
    END  
      
    SET @ACM = @ACM + 3
  END

UPDATE #TLIFESTD   SET ESTMNT_M = 0 Where UWY_nf in (SELECT MIN(UWY_NF) FROM #TLIFESTD L WHERE L.CTR_NF = #TLIFESTD.CTR_NF  ) AND ACM_NF in (3,6,9) AND DETTRNCOD_CF in (SELECT DETTRNCOD1_CF FROM bref ..TSUBTRSASSO where ASSOTYP_CT = '1' and CTX_NT=1)
UPDATE #TLIFESTD   SET ESTMNT_M = 0 Where UWY_nf in (SELECT MIN(UWY_NF) FROM #TLIFESTD L WHERE L.CTR_NF = #TLIFESTD.CTR_NF  ) AND ACM_NF in (3,6,9,12) AND DETTRNCOD_CF in (SELECT DETTRNCOD2_CF FROM bref ..TSUBTRSASSO where ASSOTYP_CT = '1' and CTX_NT=1)

---Case Not COMPLETE ACOUNT


DELETE FROM #TLIFEST_BAL
INSERT INTO #TLIFEST_BAL
SELECT
     L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D, BALSHEY_NF,BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,
    0,
     INDSUP_B, ORICOD_LS ,CREUSR_CF,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B               
from TLIFEST L , #TLOADING_STEP9 T9
WHERE L.CTR_NF = T9.CTR_NF 
  --AND L.ACY_NF >= T9.MAXUWY_NF 
  --AND L.UWY_NF >= T9.MAXUWY_NF 
  --AND L.DETTRNCOD_CF NOT IN (SELECT SUBSTRING(PCPTRS_CF,1,2) + SUBSTRING(TRS_CF,1,1) + SUBSTRING(SUBTRS_CF,1,2)  FROM BREF..TSUBTRS WHERE TRSTYPE_CT=3)
  AND T9.MAXUWY_NF is  null
  ORDER BY  LSTUPD_D

DELETE FROM #TLIFEST_TEMP

INSERT INTO #TLIFEST_TEMP
SELECT
     CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,CREUSR_CF,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B , 0              
from #TLIFEST_BAL A
WHERE A.LSTUPD_D = (SELECT MAX(LSTUPD_D) FROM #TLIFEST_BAL C
                 where   C.DETTRNCOD_CF = A.DETTRNCOD_CF
                  and   C.acy_nf    = A.acy_nf
                  and   C.UWY_nf    = A.UWy_nf
                  and   C.CTR_NF = A.CTR_NF
                  and   C.END_NT = A.END_NT
                  and   C.SEC_NF = A.SEC_NF
                  and   C.UW_NT = A.UW_NT
                  --and   C.BALSHTMTH_NF = A.BALSHTMTH_NF
                  and   C.prs_cf    = A.prs_cf
                  and   C.gaap_nt    = A.gaap_nt)
                  AND A.ESTMNT_M is not null
                  
UPDATE #TLIFEST_TEMP SET ACCADMTYP_CT = (SELECT ACCADMTYP_CT FROM BTRT..TSECTION WHERE CTR_NF = #TLIFEST_TEMP.CTR_NF AND SEC_NF = 1 AND UWY_NF = (SELECT UWY_NF FROM #TLOADING_STEP9 T9 WHERE CTR_NF = #TLIFEST_TEMP.CTR_NF )) WHERE CTR_NF in (Select CTR_NF FROM BTRAV..EST_IFRS17_PERIMETER) 
UPDATE #TLIFEST_TEMP SET ACCADMTYP_CT = (SELECT RETACCTYP_CT FROM BRET..TRETCTR WHERE RETCTR_NF = #TLIFEST_TEMP.CTR_NF AND RTY_NF = (SELECT UWY_NF FROM #TLOADING_STEP9 T9 WHERE CTR_NF = #TLIFEST_TEMP.CTR_NF )) WHERE CTR_NF in (Select RETCTR_NF FROM BTRAV..EST_IFRS17_PERIMETER) 
                 
               
                  
SELECT @ACM = 3
WHILE @ACM < 13 
  BEGIN
  Select @count = 0
    
    INSERT INTO #TLIFESTD
    SELECT CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,GETDATE(),@blcshtyea_nf,@blcshtmth_nf, UWY_NF,GAAP_NT,DETTRNCOD_CF,@ACM,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF, 0,INDSUP_B, 'QE-RESET' ,user,GETDATE(),user,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B
    FROM #TLIFEST_TEMP 
    WHERE ACCADMTYP_CT in (1,4)
    AND UWY_NF=ACY_NF

    WHILE @COUNT < 10 
    BEGIN
      INSERT INTO #TLIFESTD
      SELECT CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,GETDATE(),@blcshtyea_nf,@blcshtmth_nf, UWY_NF + @count ,GAAP_NT,DETTRNCOD_CF,@ACM,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,0,INDSUP_B, 'QE-RESET' ,user,GETDATE(),user,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B
      FROM #TLIFEST_TEMP 
      WHERE ACCADMTYP_CT in (2,3,5) 
      AND ACY_NF= (SELECT MAXUWY_NF FROM #TLOADING_STEP9 T9 WHERE CTR_NF = #TLIFEST_TEMP.CTR_NF ) + 1
      AND (UWY_NF + @count) < (@blcshtyea_nf + 5)
      
      SET @COUNT = @COUNT + 1
    END  
      
    SET @ACM = @ACM + 3
  END                 
                  

if object_id('#TLIFEST_BAL') is not null drop Table #TLIFEST_BAL 
if object_id('#TLIFEST_TEMP') is not null drop Table #TLIFEST_TEMP 
go 
EXEC sp_procxmode 'PsEST_IFRS17_09_O2', 'unchained'
go

IF OBJECT_ID('PsEST_IFRS17_09_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_09_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_09_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_09_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_09_O2 TO GDBBATCH
go
