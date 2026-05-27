USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_04_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_04_O2
    IF OBJECT_ID('PsEST_IFRS17_04_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_04_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_04_O2 >>>'
END
go
create procedure PsEST_IFRS17_04_O2 
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
Author: 
Date: 
Description: 
_________________
*/


declare
        @error_type   int,
        @MsgAnomalie    varchar(120),
        @MsgAnomalie1    varchar(120),
        @AnomalieCode    varchar(120),
    @nbligne_ESTIFRS17 int,    
    @nbligne_PERIMETER int,   
   @nbligne_STEP3 int    

select @nbligne_STEP3 = count(*) FROM #TLOADING_STEP3

select @nbligne_PERIMETER = count(*) FROM BTRAV..EST_IFRS17_PERIMETER
 
select #TLOADING_STEP3.RETCTR_NF, #TLOADING_STEP3.RTY_NF, #TLOADING_STEP3.CTR_NF, #TLOADING_STEP3.UWY_NF                                                                                                                                 FROM #TLOADING_STEP3

select BTRAV..EST_IFRS17_PERIMETER.RETCTR_NF, BTRAV..EST_IFRS17_PERIMETER.RTY_NF, BTRAV..EST_IFRS17_PERIMETER.CTR_NF, BTRAV..EST_IFRS17_PERIMETER.UWY_NF, BTRAV..EST_IFRS17_PERIMETER.ESTTYPE_LL, BTRAV..EST_IFRS17_PERIMETER.ESTCRB_CT              FROM BTRAV..EST_IFRS17_PERIMETER



  select @error_type = 4
        select @MsgAnomalie = 'Forbidden to change the estimates type because some assumed treaties linked to this   '
      select @MsgAnomalie1 = ' contract are missing  '
      
      Select @AnomalieCode = 'Compare with input file'
  
  INSERT INTO #TANO_TMP
  SELECT 
      S.RETCTR_NF,
      S.RTY_NF,
      @error_type as ANO_CT,
      @AnomalieCode as ANOCODE_LL,
      @MsgAnomalie + S.RETCTR_NF +
      @MsgAnomalie1   as ANO_LL
       FROM #TLOADING_STEP3 S LEFT JOIN BTRAV..EST_IFRS17_PERIMETER P ON S.RETCTR_NF = P.RETCTR_NF AND S.RTY_NF = P.RTY_NF AND S.CTR_NF = P.CTR_NF AND S.UWY_NF = P.UWY_NF
  Where P.RETCTR_NF IS NULL  
  AND (S.RETCTR_NF IN (SELECT RETCTR_NF FROM BRET..TSSDACTR TS WHERE TS.RETCTR_NF = S.RETCTR_NF ) 
      OR ( S.RETCTR_NF  IN (SELECT RETCTR_NF FROM BRET..TCESSION TC WHERE TC.RETCTR_NF = S.RETCTR_NF )))
  
  select @error_type = 4
      select @MsgAnomalie = 'Forbidden to change the estimates type because the assumed treaty is not linked to the    '
      select @MsgAnomalie1 = ' retro contract '
      Select @AnomalieCode = 'Compare with input file'
  INSERT INTO #TANO_TMP
  SELECT 
      P.RETCTR_NF,
      P.RTY_NF,   
      @error_type as ANO_CT,
      @AnomalieCode as ANOCODE_LL,
      @MsgAnomalie + P.RETCTR_NF +
      @MsgAnomalie1  as ANO_LL    
   FROM BTRAV..EST_IFRS17_PERIMETER P LEFT JOIN #TLOADING_STEP3 S ON S.RETCTR_NF = P.RETCTR_NF AND S.RTY_NF = P.RTY_NF AND S.CTR_NF = P.CTR_NF AND S.UWY_NF = P.UWY_NF
  Where S.RETCTR_NF IS NULL  
  AND (P.RETCTR_NF IN (SELECT RETCTR_NF FROM BRET..TSSDACTR TS WHERE TS.RETCTR_NF = P.RETCTR_NF ) 
      OR ( P.RETCTR_NF  IN (SELECT RETCTR_NF FROM BRET..TCESSION TC WHERE TC.RETCTR_NF = P.RETCTR_NF )))
      
      IF ((SELECT COUNT(*) FROM #TANO_TMP) > 0)
          Begin
          PRINT 'ERROR(S) LINKED TO RETRO CHAIN'
            PRINT 'STEP 4 : COMPLETE'
            GOTO ENDPROCESS
          END
--END/*
/*IF(@nbligne_PERIMETER > @nbligne_STEP3)
BEGIN
SELECT * FROM BTRAV..EST_IFRS17_PERIMETER P  LEFT JOIN  #TLOADING_STEP3 S ON S.RETCTR_NF = P.RETCTR_NF AND S.RTY_NF = P.RTY_NF AND S.CTR_NF = P.CTR_NF AND S.UWY_NF = P.UWY_NF
Where S.RETCTR_NF IS NULL AND (P.RETCTR_NF IN (SELECT RETCTR_NF FROM BRET..TSSDACTR TS WHERE TS.RETCTR_NF = P.RETCTR_NF ) OR ( P.RETCTR_NF  IN (SELECT RETCTR_NF FROM BRET..TCESSION TC WHERE TC.RETCTR_NF = P.RETCTR_NF )))

END*/
/*IF(@nbligne_PERIMETER > @nbligne_STEP3)
BEGIN
END*/
  
 /* if ( @nbligne_PERIMETER != @nbligne_STEP3 )
    begin
    
    
    IF ( @nbligne_PERIMETER < @nbligne_STEP3 )
    BEGIN
      PRINT 'ERROR - ALL RETRO CHAIN TREATIES NOT PRESENT'
           
      select @error_type = 4
      select @MsgAnomalie = 'impossible to change Estimate type because some contracts  '
      select @MsgAnomalie1 = ' are missing in the list for retro contract  '
      Select @AnomalieCode = 'Compare with input file'


      SELECT 
      @error_type as ANO_CT,
      @AnomalieCode as ANOCODE_LL,
      @MsgAnomalie + S3.CTR_NF +
      @MsgAnomalie1 + S3.RETCTR_NF  as ANO_LL
      FROM #TLOADING_STEP3 S3
        LEFT JOIN BTRAV..EST_IFRS17_PERIMETER P ON S3.RETCTR_NF = P.RETCTR_NF AND S3.CTR_NF = P.CTR_NF AND  S3.RTY_NF = P.RTY_NF AND  S3.UWY_NF = P.UWY_NF
        WHERE  S3.RETCTR_NF is NOT NULL 
        AND P.RETCTR_NF is NULL
        AND P.CTR_NF IS NULL
        AND P.RTY_NF IS NULL
        AND P.UWY_NF IS NULL
        ORDER BY S3.RETCTR_NF
        
        
        INSERT INTO #TANO_TMP
        SELECT 
        S3.RETCTR_NF,
        S3.RTY_NF,
      @error_type as ANO_CT,
      @AnomalieCode as ANOCODE_LL,
      @MsgAnomalie + S3.CTR_NF +
      @MsgAnomalie1 + S3.RETCTR_NF  as ANO_LL
      FROM #TLOADING_STEP3 S3
        LEFT JOIN BTRAV..EST_IFRS17_PERIMETER P ON S3.RETCTR_NF = P.RETCTR_NF AND S3.CTR_NF = P.CTR_NF AND  S3.RTY_NF = P.RTY_NF AND  S3.UWY_NF = P.UWY_NF
        WHERE  S3.RETCTR_NF is NOT NULL 
        AND P.RETCTR_NF is NULL
        AND P.CTR_NF IS NULL
        AND P.RTY_NF IS NULL
        AND P.UWY_NF IS NULL
        ORDER BY S3.RETCTR_NF
        
        
        
      GOTO ENDPROCESS
    END
    IF ( @nbligne_PERIMETER > @nbligne_STEP3 AND  @nbligne_STEP3  !=0)
    BEGIN
    PRINT 'ERROR - RETRO CHAIN TREATIES INCORRECT'
    SELECT * FROM #TLOADING_STEP3 S3
    SELECT * FROM BTRAV..EST_IFRS17_PERIMETER
        select @error_type = 4
      select @MsgAnomalie = 'impossible to change Estimate type because some contracts  '
      select @MsgAnomalie1 = ' don''t match with the list for retro contract  '
      Select @AnomalieCode = 'Compare with input file'
      
      SELECT 
      @error_type as ANO_CT,
      @AnomalieCode as ANOCODE_LL,
      @MsgAnomalie + P.CTR_NF +
      @MsgAnomalie1 + S3.RETCTR_NF  as ANO_LL
      FROM #TLOADING_STEP3 S3
        , BTRAV..EST_IFRS17_PERIMETER P WHERE  P.CTR_NF !=S3.CTR_NF AND  S3.RETCTR_NF = P.RETCTR_NF
        
      INSERT INTO #TANO_TMP
      SELECT 
        S3.RETCTR_NF,
        S3.RTY_NF,
      @error_type ,
      @AnomalieCode ,
      @MsgAnomalie + P.CTR_NF +
      @MsgAnomalie1 + S3.RETCTR_NF  
      FROM #TLOADING_STEP3 S3
        , BTRAV..EST_IFRS17_PERIMETER P WHERE  P.CTR_NF !=S3.CTR_NF AND  S3.RETCTR_NF = P.RETCTR_NF
        
        
      GOTO ENDPROCESS
    END    
      
    END 
    ELSE if ( @nbligne_PERIMETER = @nbligne_STEP3 and @nbligne_PERIMETER > 0  )
    BEGIN
    
      select @error_type = 4
      select @MsgAnomalie = 'impossible to change Estimate type because some contracts  '
      select @MsgAnomalie1 = ' are missing in the list for retro contract  '
      Select @AnomalieCode = 'Compare with input file'
        
        if((SELECT count(*) FROM #TLOADING_STEP3 S3   , BTRAV..EST_IFRS17_PERIMETER P 
             WHERE  S3.RETCTR_NF = P.RETCTR_NF AND (P.CTR_NF is null OR P.CTR_NF !=S3.CTR_NF))!=0) 
          BEGIN
          INSERT INTO #TANO_TMP
        SELECT 
        S3.RETCTR_NF,
        S3.RTY_NF,
         @error_type as ANO_CT,
         @AnomalieCode as ANOCODE_LL,
         @MsgAnomalie + S3.CTR_NF +
         @MsgAnomalie1 + S3.RETCTR_NF  as ANO_LL
         FROM #TLOADING_STEP3 S3   , BTRAV..EST_IFRS17_PERIMETER P 
      WHERE  S3.RETCTR_NF = P.RETCTR_NF AND (P.CTR_NF is null OR P.CTR_NF !=S3.CTR_NF)
            PRINT 'ERROR(S) LINKED TO RETRO CHAIN'
            PRINT 'STEP 4 : COMPLETE'
            GOTO ENDPROCESS
          END  
        ELSE 
          BEGIN
            PRINT 'NO ERROR LINKED TO RETRO CHAIN'
            PRINT 'STEP 4 : COMPLETE'
          
          END   
      
      
    END
    

    select * from #TANO_TMP
      select @error_type = 4
      select @MsgAnomalie = 'impossible to change Estimate type because some contracts  '
      select @MsgAnomalie1 = ' don''t match with the list for retro contract  '
      Select @AnomalieCode = 'Compare with input file'
    
    INSERT INTO #TANO_TMP
    SELECT 
          P.RETCTR_NF,
          P.RTY_NF,
          @error_type as ANO_CT,
          @AnomalieCode as ANOCODE_LL,
          @MsgAnomalie + P.CTR_NF +
          @MsgAnomalie1 + P.RETCTR_NF  as ANO_LL
          FROM  BTRAV..EST_IFRS17_PERIMETER P Where RETCTR_NF NOT IN (SELECT RETCTR_NF FROM #TLOADING_STEP3 S3  WHERE P.RETCTR_NF = S3.RETCTR_NF AND P.CTR_NF = S3.CTR_NF)
          AND RETCTR_NF IS NOT NULL
          AND CTR_NF IS NOT NULL
          
         -- AND (RETCTR_NF IN (SELECT RETCTR_NF FROM BRET..TSSDACTR ) or RETCTR_NF IN (SELECT RETCTR_NF FROM BRET..TCESSION ))
          
          
          IF ((SELECT COUNT(*) FROM #TANO_TMP) > 0)
          Begin
          PRINT 'ERROR(S) LINKED TO RETRO CHAIN'
            PRINT 'STEP 4 : COMPLETE'
            GOTO ENDPROCESS
          END
          
      select @error_type = 4
      select @MsgAnomalie = 'impossible to change Estimate type because some contracts  '
      select @MsgAnomalie1 = ' are missing in the list for retro contract  '
      Select @AnomalieCode = 'Compare with input file'
    select * from #TANO_TMP
    INSERT INTO #TANO_TMP
    SELECT 
          S3.RETCTR_NF,
          S3.RTY_NF,
          @error_type as ANO_CT,
          @AnomalieCode as ANOCODE_LL,
          @MsgAnomalie + S3.CTR_NF +
          @MsgAnomalie1 + S3.RETCTR_NF  as ANO_LL
          FROM   #TLOADING_STEP3 S3 Where RETCTR_NF NOT IN (SELECT RETCTR_NF FROM BTRAV..EST_IFRS17_PERIMETER P WHERE P.RETCTR_NF = S3.RETCTR_NF AND P.CTR_NF = S3.CTR_NF)
          AND RETCTR_NF IS NOT NULL
          AND CTR_NF IS NOT NULL
          --AND (RETCTR_NF IN (SELECT RETCTR_NF FROM BRET..TSSDACTR ) or RETCTR_NF IN (SELECT RETCTR_NF FROM BRET..TCESSION ))
          select * from #TANO_TMP
          IF ((SELECT COUNT(*) FROM #TANO_TMP) > 0)
          Begin
          PRINT 'ERROR(S) LINKED TO RETRO CHAIN'
            PRINT 'STEP 4 : COMPLETE'
            GOTO ENDPROCESS
          END*/
ENDPROCESS:
Return
go 
EXEC sp_procxmode 'PsEST_IFRS17_04_O2', 'unchained'
go

IF OBJECT_ID('PsEST_IFRS17_04_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_04_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_04_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_04_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_04_O2 TO GDBBATCH
go


