USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_13_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_13_O2
    IF OBJECT_ID('PsEST_IFRS17_13_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_13_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_13_O2 >>>'
END
go
create procedure PsEST_IFRS17_13_O2 
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
Description: TLIFMOD multi SSD issue Duplicate Key Spira 77000

*******************
Modification: MOD2
Author: Riyadh 
Date: 27/03/2019
Description: Spira 76818 Balance sheet month and year issue

*******************
Modification: MOD3
Author: Riyadh 
Date: 14/08/2019
Description:Spira 80698 : Duplicate key index in TLIFMOD during upload_Retro case
_________________
Modification: MOD4
Author: S.Behague
Date: 06/12/2021
Description: Spira 98335 Script to move to quaterly estimates - Remaining issues
_________________
*/


declare
        @error_type   int,
        @blcshtyea_nf smallint,
        @blcshtmth_nf tinyint,
        @MinYear smallint,
        @MaxYear smallint,
        @Year smallint,
        @GAAP_NT tinyint,
        @TYPPER             Char(1),
        @DATE               Datetime,
        @SPCEND_D           Datetime,
        @ACCOUNT_D          Datetime,   
        @CLOSING_B          Bit  
        
 CREATE TABLE #TCTR
(
  CTR_NF        UCTR_NF			  NULL,
  SEC_NF        USEC_NF    NOT NULL,
  SSD_CF        USSD_CF    NOT NULL,
  CUR_CF        UCUR_CF     NULL
)

CREATE TABLE #TLIFEST_S13
(
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
    BATCH_B     bit        DEFAULT 0  NOT NULL
)

create table #TLIFMODRET (
  CTR_NF UCTR_NF not null,
  SEC_NF USEC_NF not null,
  CRE_D datetime not null,
  BALSHEY_NF smallint not null,
  BALSHTMTH_NF tinyint not null,
  SSD_CF USSD_CF not null,
  TYPMOD1_CT tinyint not null,
  TYPMOD2_CT tinyint null,
  CUR_CF UCUR_CF null,
  CMT_NT UCMT_NT null,
  SENMAI_D datetime null,
  ORICOD_LS UL16 not null,
  CREUSR_CF UUSR_CF not null,
  LSTUPD_D datetime not null,
  LSTUPDUSR_CF UUSR_CF not null,
  [Timestamp] timestamp null,
  DISPLAY_B UBOOLEAN_B default 1  not null,
  MAINCUR_CF UCUR_CF null
)

--MOD2 START

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
--MOD2 END



--TLIFMOD UPDATE



INSERT INTO #TLIFMOD
SELECT 
  A.CTR_NF ,
  A.SEC_NF ,
  GETDATE() ,
  @blcshtyea_nf ,
  @blcshtmth_nf ,
  A.SSD_CF ,
  2 ,
  NULL ,
  A.CUR_CF ,
  NULL,
  NULL ,
  'QE-RESET', 
  USER, 
  GETDATE(),
  USER, 
  null ,
  1 
  FROM BEST..TLIFMOD  A Inner join BTRAV..EST_IFRS17_PERIMETER B
  on A.CTR_NF = B.CTR_NF 
  Where A.CUR_CF in (select distinct PCPCUR_CF from BTRT..TSECTION S where S.CTR_NF = A.CTR_NF and S.SEC_NF = A.SEC_NF )
           and  A.CRE_D in (Select MAX(CRE_D) from BEST..TLIFMOD L where L.CTR_NF = A.CTR_NF and L.SEC_NF = A.SEC_NF and A.SSD_CF in (select distinct SSD_CF from BTRT..TCONTR C where C.CTR_NF = B.CTR_NF and C.UWY_NF = B.UWY_NF ))
           and a.SSD_CF in (select distinct SSD_CF from BTRT..TCONTR C where C.CTR_NF = B.CTR_NF and C.UWY_NF = B.UWY_NF )
           

select distinct RETCTR_NF, RTY_NF into #EST_IFRS17_PERIMETER1 from BTRAV..EST_IFRS17_PERIMETER  --MOD3

--MOD1 START
INSERT INTO #TLIFMODRET
  SELECT 
  A.CTR_NF ,
  A.SEC_NF ,
  A.CRE_D ,
  @blcshtyea_nf ,
  @blcshtmth_nf ,
  A.SSD_CF ,
  2 ,
  NULL ,
  A.CUR_CF ,
  NULL,
  NULL ,
  'QE-RESET', 
  USER, 
  A.LSTUPD_D,
  USER, 
  null ,
  1 ,
  null
  FROM BEST..TLIFMOD  A inner join #EST_IFRS17_PERIMETER1 B
  on A.CTR_NF = B.RETCTR_NF
  Where    A.CRE_D in (Select MAX(CRE_D) from BEST..TLIFMOD L where L.CTR_NF = A.CTR_NF and L.SEC_NF = A.SEC_NF and A.SSD_CF in (select distinct SSD_CF from BRET..TRETCTR C where C.RETCTR_NF = B.RETCTR_NF and C.RTY_NF = B.RTY_NF ))
            and a.SSD_CF in (select distinct SSD_CF from BRET..TRETCTR C where C.RETCTR_NF = B.RETCTR_NF and C.RTY_NF = B.RTY_NF )
              
  UPDATE #TLIFMODRET SET MAINCUR_CF = (select distinct RETSPECUR_CF from BRET..TRETSEC S where S.RETCTR_NF = #TLIFMODRET.CTR_NF and S.RETSEC_NF = #TLIFMODRET.SEC_NF and RETSPECUR_CF is not NULL and RETSPECUR_CF != '' having S.LSTUPD_D = MAX(S.LSTUPD_D) )
      
  UPDATE #TLIFMODRET SET MAINCUR_CF = (select distinct RETPCPCUR_CF from BRET..TRETCTR S where S.RETCTR_NF = #TLIFMODRET.CTR_NF) where MAINCUR_CF is NULL or MAINCUR_CF = ''
  
  
  INSERT INTO #TLIFMOD
  SELECT 
  A.CTR_NF ,
  A.SEC_NF ,
  GETDATE() ,
  @blcshtyea_nf ,
  @blcshtmth_nf ,
  A.SSD_CF ,
  2 ,
  NULL ,
  A.CUR_CF ,
  NULL,
  NULL ,
  'QE-RESET', 
  USER, 
  GETDATE(),
  USER, 
  null ,
  1 
  FROM #TLIFMODRET  A
  Where A.CUR_CF = A.MAINCUR_CF
  --MOD1 END
  INSERT INTO #TCTR
  Select  
  S.CTR_NF, 
  S.SEC_NF ,
  S.SSD_CF,
  S.PCPCUR_CF
  from BTRT..TSECTION S  LEFT JOIN BEST..TLIFMOD L
  on S.CTR_NF = L.CTR_NF and S.SEC_NF = L.SEC_NF 
  Where L.CTR_NF is null
    and S.CTR_NF in (select CTR_NF from BTRAV..EST_IFRS17_PERIMETER) 
  Union
  Select  
  distinct R.RETCTR_NF, 
  R.RETSEC_NF ,
  R.SSD_CF,
  R.RETSPECUR_CF
  FROM BRET..TRETSEC R LEFT JOIN BEST..TLIFMOD L
  on R.RETCTR_NF = L.CTR_NF and R.RETSEC_NF = L.SEC_NF 
  Where L.CTR_NF is null
    and R.RETSPECUR_CF is not null
    and  R.RETCTR_NF in (select RETCTR_NF from BTRAV..EST_IFRS17_PERIMETER)
 
 --MOD1 START
 UPDATE #TCTR SET CUR_CF = (select distinct RETPCPCUR_CF from BRET..TRETCTR S where S.RETCTR_NF = #TCTR.CTR_NF) 
 WHERE (CUR_CF IS NULL or CUR_CF = '')
    AND CTR_NF in (select RETCTR_NF from BTRAV..EST_IFRS17_PERIMETER)
    
 --MOD1 END 
  INSERT INTO #TLIFMOD
SELECT 
  C.CTR_NF ,
  C.SEC_NF ,
  GETDATE() ,
  @blcshtyea_nf ,
  @blcshtmth_nf ,
  C.SSD_CF ,
  2 ,
  NULL ,
  C.CUR_CF ,
  NULL,
  NULL ,
  'QE-RESET', 
  USER, 
  GETDATE(),
  USER, 
  null ,
  1 
  FROM #TCTR C
  
--TLIFMOD2 UPDATE

Select @MaxYear = @blcshtyea_nf+4
Select @MinYear = @blcshtyea_nf-4  

select @year=@MinYear
WHILE(@year<=@MaxYear)
Begin
    SELECT @GAAP_NT = 1
    WHILE(@GAAP_NT <=5)
    BEGIN
        INSERT  #TLIFMOD2(CTR_NF
       ,SEC_NF
       ,CRE_D
       ,BALSHEY_NF
       ,BALSHTMTH_NF
       ,ACY_NF
        ,COMACC_B
        ,GAAP_NT
        ,PRIPRMAMT_M
        ,AFTPRMAMT_M
        ,PRIRESTECAMT_M
        ,AFTRESTECAMT_M
        ,PRIRESDACAMT_M
        ,AFTRESDACAMT_M
        ,PRIRESFINAMT_M
        ,AFTRESFINAMT_M
        ,CREUSR_CF
        ,LSTUPD_D
        ,LSTUPDUSR_CF)
        SELECT 
        DISTINCT
         CTR_NF
        ,SEC_NF
        ,getdate()
        ,@blcshtyea_nf 
        ,@blcshtmth_nf 
        ,@year
        ,0
        ,@GAAP_NT
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,USER
        ,getdate()
        ,USER
         FROM #TLIFEST 
        GROUP BY CTR_NF , SEC_NF 
        SELECT @GAAP_NT = @GAAP_NT + 1 
    END
    
    select @year = @year + 1
END


INSERT INTO #TLIFEST_S13
SELECT DISTINCT L.CTR_NF,L.END_NT,L.SEC_NF,L.UWY_NF,L.UW_NT,L.CRE_D,L.BALSHEY_NF,L.BALSHTMTH_NF,L.ACY_NF,L.GAAP_NT,L.DETTRNCOD_CF,L.ACM_NF,L.PRS_CF,L.ACMTRS_NT,L.SSD_CF,L.CUR_CF,L.ESTMNT_M,L.INDSUP_B,L.ORICOD_LS ,L.CREUSR_CF,L.LSTUPD_D,L.LSTUPDUSR_CF,L.ORICTR_NF,L.ORISEC_NF ,L.ORIUWY_NF,L.DIFF_M ,L.PROPAGATION_B,L.CALCULATED_B,L.BATCH_B               
FROM TLIFEST L, #TLIFEST T
WHERE L.CTR_NF = T.CTR_NF AND L.SEC_NF = T.SEC_NF AND L.GAAP_NT = T.GAAP_NT AND  L.ACMTRS_NT in ( 1010 , 2010,1400,1450,1460) AND L.ACY_NF <= @MaxYear AND L.ACY_NF >= @MinYear AND L.LSTUPD_D IN (SELECT MAX(LSTUPD_D) FROM TLIFEST S WHERE S.CTR_NF = L.CTR_NF AND S.SEC_NF = L.SEC_NF AND S.GAAP_NT = S.GAAP_NT AND S.DETTRNCOD_CF = L.DETTRNCOD_CF AND s.ACY_NF = L.ACY_NF  AND S.UWY_NF = L.UWY_NF)




UPDATE #TLIFMOD2 SET  PRIPRMAMT_M    =  isnull( (SELECT SUM(ESTMNT_M)FROM #TLIFEST_S13 L WHERE L.CTR_NF = #TLIFMOD2.CTR_NF AND L.SEC_NF = #TLIFMOD2.SEC_NF AND L.GAAP_NT=#TLIFMOD2.GAAP_NT AND L.ACY_NF = #TLIFMOD2.ACY_NF AND L.ACMTRS_NT in ( 1010 , 2010) ),0)
                     ,AFTPRMAMT_M    =  isnull( (SELECT SUM(ESTMNT_M)FROM #TLIFEST L WHERE L.CTR_NF = #TLIFMOD2.CTR_NF AND L.SEC_NF = #TLIFMOD2.SEC_NF AND L.GAAP_NT=#TLIFMOD2.GAAP_NT AND L.ACY_NF = #TLIFMOD2.ACY_NF AND L.ACMTRS_NT in ( 1010 , 2010) AND L.LSTUPD_D IN (SELECT MAX(LSTUPD_D) FROM #TLIFEST S WHERE S.CTR_NF = L.CTR_NF AND S.SEC_NF = L.SEC_NF AND S.GAAP_NT = S.GAAP_NT AND S.DETTRNCOD_CF = L.DETTRNCOD_CF AND s.ACY_NF = L.ACY_NF)),0)
                     ,PRIRESTECAMT_M =  isnull( (SELECT SUM(ESTMNT_M)FROM #TLIFEST_S13 L WHERE L.CTR_NF = #TLIFMOD2.CTR_NF AND L.SEC_NF = #TLIFMOD2.SEC_NF AND L.GAAP_NT=#TLIFMOD2.GAAP_NT AND L.ACY_NF = #TLIFMOD2.ACY_NF AND L.ACMTRS_NT in (1400) ),0)
                     ,AFTRESTECAMT_M =  isnull( (SELECT SUM(ESTMNT_M)FROM #TLIFEST L WHERE L.CTR_NF = #TLIFMOD2.CTR_NF AND L.SEC_NF = #TLIFMOD2.SEC_NF AND L.GAAP_NT=#TLIFMOD2.GAAP_NT AND L.ACY_NF = #TLIFMOD2.ACY_NF AND L.ACMTRS_NT in ( 1400) AND L.LSTUPD_D IN (SELECT MAX(LSTUPD_D) FROM #TLIFEST S WHERE S.CTR_NF = L.CTR_NF AND S.SEC_NF = L.SEC_NF AND S.GAAP_NT = S.GAAP_NT AND S.DETTRNCOD_CF = L.DETTRNCOD_CF AND s.ACY_NF = L.ACY_NF)),0)
                     ,PRIRESDACAMT_M =  isnull( (SELECT SUM(ESTMNT_M)FROM #TLIFEST_S13 L WHERE L.CTR_NF = #TLIFMOD2.CTR_NF AND L.SEC_NF = #TLIFMOD2.SEC_NF AND L.GAAP_NT=#TLIFMOD2.GAAP_NT AND L.ACY_NF = #TLIFMOD2.ACY_NF AND L.ACMTRS_NT in ( 1450) ),0)
                     ,AFTRESDACAMT_M =  isnull( (SELECT SUM(ESTMNT_M)FROM #TLIFEST L WHERE L.CTR_NF = #TLIFMOD2.CTR_NF AND L.SEC_NF = #TLIFMOD2.SEC_NF AND L.GAAP_NT=#TLIFMOD2.GAAP_NT AND L.ACY_NF = #TLIFMOD2.ACY_NF AND L.ACMTRS_NT in (1450) AND L.LSTUPD_D IN (SELECT MAX(LSTUPD_D) FROM #TLIFEST S WHERE S.CTR_NF = L.CTR_NF AND S.SEC_NF = L.SEC_NF AND S.GAAP_NT = S.GAAP_NT AND S.DETTRNCOD_CF = L.DETTRNCOD_CF AND s.ACY_NF = L.ACY_NF)),0)
                     ,PRIRESFINAMT_M =  isnull( (SELECT SUM(ESTMNT_M)FROM #TLIFEST_S13 L WHERE L.CTR_NF = #TLIFMOD2.CTR_NF AND L.SEC_NF = #TLIFMOD2.SEC_NF AND L.GAAP_NT=#TLIFMOD2.GAAP_NT AND L.ACY_NF = #TLIFMOD2.ACY_NF AND L.ACMTRS_NT in ( 1460) ),0)
                     ,AFTRESFINAMT_M =  isnull( (SELECT SUM(ESTMNT_M)FROM #TLIFEST L WHERE L.CTR_NF = #TLIFMOD2.CTR_NF AND L.SEC_NF = #TLIFMOD2.SEC_NF AND L.GAAP_NT=#TLIFMOD2.GAAP_NT AND L.ACY_NF = #TLIFMOD2.ACY_NF AND L.ACMTRS_NT in ( 1460) AND L.LSTUPD_D IN (SELECT MAX(LSTUPD_D) FROM #TLIFEST S WHERE S.CTR_NF = L.CTR_NF AND S.SEC_NF = L.SEC_NF AND S.GAAP_NT = S.GAAP_NT AND S.DETTRNCOD_CF = L.DETTRNCOD_CF AND s.ACY_NF = L.ACY_NF)),0)






GO

EXEC sp_procxmode 'PsEST_IFRS17_13_O2', 'unchained'  
go

IF OBJECT_ID('PsEST_IFRS17_13_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_13_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_13_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_13_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_13_O2 TO GDBBATCH
go
