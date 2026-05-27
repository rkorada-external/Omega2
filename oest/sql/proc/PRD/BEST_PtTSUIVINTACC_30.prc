USE BEST
go
IF OBJECT_ID('dbo.PtTSUIVINTACC_30') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtTSUIVINTACC_30
    IF OBJECT_ID('dbo.PtTSUIVINTACC_30') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtTSUIVINTACC_30 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtTSUIVINTACC_30 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PtTSUIVINTACC_30
     ( @p_SSD        USSD_CF,
       @p_ESB        UESB_CF,
       @p_NUMFIC     UUWENTNBR_NT,
       @p_USR_CF     UUSR_CF,
       @p_TYPEMNT  CHAR(3),
       @p_BALSHEY_NF  smallint,
       @p_BALSHRMTH_NF  smallint
     )
with execute as caller as

/*************************************************************************************
Programme: PtTSUIVINTACC_30
Fichier script associé : BEST_PtTSUIVINTACC_30.prc
Fiche spot : 
Domaine : OMEGA TO GEAC ESTIMATION
Base principale : BEST
Version: 1
Auteur: Shiva Akhileswaran
Date de creation: 08/06/2015
Description: Data validation procedure
Input Parametres:
       @p_SSD : Subsidiary
       @p_ESB : etablissement
       @p_NUMFIC  : numero fichier
       @p_USR_CF : utilisateur
       @p_TYPEMNT  CHAR(3),
       @p_BALSHEY_NF  smallint,
       @p_BALSHRMTH_NF  smallint
Return:
       retourne :
          => Success : 0
          => Failure : 1
Commentaires: 

MODIFICATION 


**************************************************************************************/

DECLARE @erreur          int,
        @trans_etat      int,
        @v_step          char(02),
        @v_ident         varchar(50),
        @p_erreur        varchar(250),
        @V_NBANO_NT      int,
        @V_NBLGKO_NT     int,
        @p_SSD_char      varchar(02),
        @p_ESB_char      varchar(02), 
        @p_NUMFIC_char   varchar(06),
        @v_cre_d         datetime,
        @v_entpery_nf    smallint,
        @v_entpermth_nf  tinyint,    
        @v_spcend_d      datetime,
        @v_account_d     datetime,
        @v_closing_b     bit,
        @v_retour        int

-- Temp Table used for checking duplicate Line number.
Create Table #TST (NUMLIGNE_NT    VARCHAR(50)     NULL,
                   NBR_DOUBLON    Int             NULL)

-- Initialize error variable.
select @erreur = 0

-- recuperer les parametres en entree  --
   SELECT @v_step = '01'
   SELECT @p_SSD_char = convert(varchar(02),@p_SSD), @p_ESB_char = convert(varchar(02),@p_ESB), @p_NUMFIC_char = convert(varchar(06),@p_NUMFIC)
   SELECT @v_ident = '- Clé : SSD_CF=' + @p_SSD_char + ' - ESB_CF=' +  @p_ESB_char + ' - NUMFIC=' + @p_NUMFIC_char 


-- Inserts errors into the Anomalies table for different validations.
--   ** Validations related to Line Number field ****
-- => Checks for NULL in Line Number.
     SELECT @v_step = '03'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,285 
                  FROM BTRAV..OGLM0030_WORKFILE1 
                     WHERE NUMLIGNE_NT IS NULL                   
            -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
              GOTO fin

-- => Ensure Line number doesn't have a decimal point.
     SELECT @v_step = '04'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,295
                  FROM BTRAV..OGLM0030_WORKFILE1 
                     WHERE CHARINDEX('.',NUMLIGNE_NT) != 0
            -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
              GOTO fin
           
-- => Ensure Line number doesn't have a comma.
     SELECT @v_step = '05'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,271   
                  FROM BTRAV..OGLM0030_WORKFILE1 
                     WHERE CHARINDEX(',',NUMLIGNE_NT) != 0
            -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
              GOTO fin

--=> Ensure Line number is numeric.
     SELECT @v_step = '06'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,278   
                  FROM BTRAV..OGLM0030_WORKFILE1
                     WHERE ISNUMERIC(ISNULL(NUMLIGNE_NT,'0')) != 1                    
                        -- traiter code retour insert --
           SELECT @erreur = @@error, @trans_etat = @@transtate
           IF @erreur != 0 OR @trans_etat > 1
              GOTO fin 
     
-- => Updated zero for all line numbers in BTRAV..OGLM0030_WORKFILE1 that have a format error
     SELECT @v_step = '07'
     UPDATE BTRAV..OGLM0030_WORKFILE1
            SET NUMLIGNE_NT = '0'
            WHERE CHARINDEX(',',NUMLIGNE_NT) != 0
            OR    CHARINDEX('.',NUMLIGNE_NT) != 0
            OR    ISNUMERIC(NUMLIGNE_NT) != 1
            OR    NUMLIGNE_NT IS NULL           
                        -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 

-- => Ensure Line Number is > 0.
      SELECT @v_step = '08'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),280   
                         FROM BTRAV..OGLM0030_WORKFILE1
                            WHERE convert(int,NUMLIGNE_NT) <= 0
                            AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC
                                           WHERE NUMFIC_NT   = @p_NUMFIC
                                             AND SSD_CF      = @p_SSD
                                             AND ESB_CF      = @p_ESB
                                             AND MESS_N      in (285,295,271,278))      
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
               
-- => Check for duplicate line numbers.
    SELECT @v_step = '09'
          INSERT Into #TST
          SELECT NUMLIGNE_NT, Count(*)
          FROM   BTRAV..OGLM0030_WORKFILE1
          GROUP BY NUMLIGNE_NT
          HAVING COUNT(*) > 1
          ORDER BY NUMLIGNE_NT
    
          INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),284   
                       FROM #TST                        
              -- traiter code retour insert --
          SELECT @erreur = @@error, @trans_etat = @@transtate
          IF @erreur != 0 OR @trans_etat > 1
             GOTO fin 
               

--   ** Validations related to Subsidiary/Subledger ****
--=> Ensure SSD_CF/ESB_CF is not NULL
    SELECT @v_step = '10'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),286
                         FROM BTRAV..OGLM0030_WORKFILE1
                            WHERE SSD_CF IS NULL
                            OR    ESB_CF IS NULL                           
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin
               
-- => Ensure SSD_CF does not have a ',' OR '.'
      SELECT @v_step = '15'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),296   
                           FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE CHARINDEX(',',SSD_CF) != 0
                                OR    CHARINDEX('.',SSD_CF) != 0
       -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
               
-- => Ensure SSD_CF is numeric.
      SELECT @v_step = '17'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),274   
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                WHERE ISNUMERIC(a.SSD_CF) != 1 
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (286,296))      
             -- traiter code retour insert --
             SELECT @erreur = @@error, @trans_etat = @@transtate
             IF @erreur != 0 OR @trans_etat > 1
                GOTO fin
                
-- => Ensure that the Subsidiary is not more than 2 characters
      SELECT @v_step = '19'
             INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),273   
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                    WHERE CHAR_LENGTH(LTRIM(RTRIM(a.SSD_CF))) > 2
                                    AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (286,296,274))                
             -- traiter code retour insert --
             SELECT @erreur = @@error, @trans_etat = @@transtate
             IF @erreur != 0 OR @trans_etat > 1
                GOTO fin
				
-- => Ensure ESB_CF does not have a ',' OR '.'
      SELECT @v_step = '16'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),297   
                           FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE CHARINDEX(',',ESB_CF) != 0
                                OR    CHARINDEX('.',ESB_CF) != 0
      -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
               
               
-- => Ensure that ESB_CF is Numeric
      SELECT @v_step = '18'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),276   
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                    WHERE ISNUMERIC(a.ESB_CF) != 1
                                    AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (286,297))
             -- traiter code retour insert --
             SELECT @erreur = @@error, @trans_etat = @@transtate
             IF @erreur != 0 OR @trans_etat > 1
                GOTO fin
                
-- => Ensure that ESB_CF is not more than 2 chars.
      SELECT @v_step = '21'
             INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),275   
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                   WHERE CHAR_LENGTH(LTRIM(RTRIM(a.ESB_CF))) > 2
                                   AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (286,297,276))                                
             -- traiter code retour insert --
             SELECT @erreur = @@error, @trans_etat = @@transtate
             IF @erreur != 0 OR @trans_etat > 1
             GOTO fin
                
                
-- => Ensure that SSD_CF/ESB_CF is an AEGON combination.
      SELECT @v_step = '20'
             INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),401   
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                    WHERE  NOT ((CONVERT(int, a.SSD_CF) = 26 and CONVERT(int, a.ESB_CF) between 5 and 10))				
                                    AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (286,296,297,274, 276, 273))                
             -- traiter code retour insert --
             SELECT @erreur = @@error, @trans_etat = @@transtate
             IF @erreur != 0 OR @trans_etat > 1
                GOTO fin
                
-- => Ensure that SSD_CF/ESB_CF match the filename.
    SELECT @v_step = '14'
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (286,274,276,296,297)) = 0
               BEGIN                 
                 -- => Différence entre filiale/établissement enregistrement/nom du fichier
                      SELECT @v_step = '27'
                           INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),277   
                                         FROM BTRAV..OGLM0030_WORKFILE1 
                                         WHERE ISNULL(convert(int,SSD_CF),0) != @p_SSD 
                                            OR    ISNULL(convert(int,ESB_CF),0) != @p_ESB                
                           -- traiter code retour insert --
                           SELECT @erreur = @@error, @trans_etat = @@transtate
                           IF @erreur != 0 OR @trans_etat > 1
                              GOTO fin
                END 
                
-- => Ensure Balance Sheet Year is not NULL
    SELECT @v_step = '11'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),287
                         FROM BTRAV..OGLM0030_WORKFILE1
                            WHERE BALSHEY_NF IS NULL                         
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
               
-- => Ensure that the Balancesheet Year  doesn't have ',' OR '.'
       SELECT @v_step = '30'
               INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),299
                             FROM BTRAV..OGLM0030_WORKFILE1 a
                                  WHERE CHARINDEX(',',a.BALSHEY_NF)      != 0 
                                  OR    CHARINDEX('.',a.BALSHEY_NF)      != 0
                                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                             WHERE b.NUMFIC_NT   = @p_NUMFIC
                                               AND b.SSD_CF      = @p_SSD
                                               AND b.ESB_CF      = @p_ESB
                                               AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                               AND b.MESS_N      = 287)
               -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                  GOTO fin                                                         
                 
  -- => Ensure that Balance Sheet Year is Numeric
      SELECT @v_step = '39'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),326
                           FROM BTRAV..OGLM0030_WORKFILE1 a 
                                WHERE ISNUMERIC(a.BALSHEY_NF) != 1 
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (299,287))                           
            -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                                       

  -- => Ensure that Balance Sheet Year matches the calendar setting.
      SELECT @v_step = '40'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),403  
               FROM BTRAV..OGLM0030_WORKFILE1 a
                  WHERE  convert(int,a.BALSHEY_NF) <> @p_BALSHEY_NF
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (299,287,326))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
               
               
  -- => Ensure Balance Sheet Month is not NULL
      SELECT @v_step = '12'
              INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),288
                           FROM BTRAV..OGLM0030_WORKFILE1
                              WHERE BALSHRMTH_NF IS NULL           
                  -- traiter code retour insert --
              SELECT @erreur = @@error, @trans_etat = @@transtate
              IF @erreur != 0 OR @trans_etat > 1
                 GOTO fin 
                 
-- => Ensure that Balance sheet month doesn not have a ',' OR '.'.
     SELECT @v_step = '75'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),383
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                WHERE CHARINDEX(',',a.BALSHRMTH_NF) != 0 
                                OR    CHARINDEX('.',a.BALSHRMTH_NF) != 0  
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 288)
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin         
                
-- => Ensure that Balance sheet month is numeric.
     SELECT @v_step = '79'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,a.NUMLIGNE_NT),0),384   
             FROM BTRAV..OGLM0030_WORKFILE1 a
               WHERE ISNUMERIC(a.BALSHRMTH_NF) != 1 
               AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (383,288))
     -- traiter code retour insert --
     SELECT @erreur = @@error, @trans_etat = @@transtate
     IF @erreur != 0 OR @trans_etat > 1
        GOTO fin   
        
-- => Ensure that Balance sheet month is not more than 2 digits.
      SELECT @v_step = '83'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),385  
               FROM BTRAV..OGLM0030_WORKFILE1 a
                  WHERE CHAR_LENGTH(LTRIM(RTRIM(a.BALSHRMTH_NF))) > 2
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (288,383,384))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
		 
-- => Ensure that Balance sheet month matches the calendar.
      SELECT @v_step = '84'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),402  
               FROM BTRAV..OGLM0030_WORKFILE1 a
                  WHERE  convert(int,a.BALSHRMTH_NF) <> @p_BALSHRMTH_NF
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (288,383,384,385))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
	 
 -- => Ensure that Balance sheet month is between 1 and 12.
      SELECT @v_step = '84'
           IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (383,288,384,385)) = 0
           BEGIN           
            -- => Mois doit être entre 1 et 12
                  SELECT @v_step = '87'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),386  
                          FROM BTRAV..OGLM0030_WORKFILE1 
                            WHERE convert(int,BALSHRMTH_NF) NOT BETWEEN 1 AND 12
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
           END -- sous test pour mois
                 
  -- => Ensure Balance Sheet day is not NULL
      SELECT @v_step = '13'
              INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),289
                           FROM BTRAV..OGLM0030_WORKFILE1
                              WHERE BALSHRDAY_NF IS NULL     
                  -- traiter code retour insert --
              SELECT @erreur = @@error, @trans_etat = @@transtate
              IF @erreur != 0 OR @trans_etat > 1
                 GOTO fin
                 
-- => Ensure that Balance sheet day doesn't have a ',' OR '.'
     SELECT @v_step = '69'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),390
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                WHERE CHARINDEX(',',a.BALSHRDAY_NF) != 0 
                                OR    CHARINDEX('.',a.BALSHRDAY_NF) != 0  
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 289)
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin 
                
-- => Ensure that Balance Sheet day is numeric.
     SELECT @v_step = '70'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,a.NUMLIGNE_NT),0),391   
             FROM BTRAV..OGLM0030_WORKFILE1 a
               WHERE ISNUMERIC(a.BALSHRDAY_NF) != 1 
               AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (289,390))
     -- traiter code retour insert --
     SELECT @erreur = @@error, @trans_etat = @@transtate
     IF @erreur != 0 OR @trans_etat > 1
        GOTO fin   

-- => Ensure that Balance Sheet day is not more than 2 digits.
      SELECT @v_step = '71'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),392  
               FROM BTRAV..OGLM0030_WORKFILE1 a
                  WHERE CHAR_LENGTH(LTRIM(RTRIM(a.BALSHRDAY_NF))) > 2
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (289,390,391))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

    -- => Ensure that Balance Sheet day is between 1 and 31
      SELECT @v_step = '71'    
               IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (289,390,391,392)) = 0
               BEGIN           
                -- => jour doit être entre 1 et 31
                      SELECT @v_step = '72'
                      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),393  
                              FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE convert(int,BALSHRDAY_NF) NOT BETWEEN 1 AND 31
                      -- traiter code retour insert --
                      SELECT @erreur = @@error, @trans_etat = @@transtate
                      IF @erreur != 0 OR @trans_etat > 1
                         GOTO fin
               END -- sous test pour mois
                 
               
-- => Ensure TRNCOD_CF is not NULL
    SELECT @v_step = '14'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),315
                         FROM BTRAV..OGLM0030_WORKFILE1
                            WHERE TRNCOD_CF IS NULL     
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin  
               
-- => Ensure TRNCOD_CF is 8 chars in length.
      SELECT @v_step = '103'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),263  
              FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE CHAR_LENGTH(LTRIM(RTRIM(a.TRNCOD_CF))) != 8
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 315)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
               
                                

-- => Ensure that the Underwriting Year  doesn't have ',' OR '.'
    SELECT @v_step = '28'
           INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),298   
                         FROM BTRAV..OGLM0030_WORKFILE1 
                              WHERE CHARINDEX(',',UWY_NF)         != 0 
                              OR    CHARINDEX('.',UWY_NF)         != 0 
           -- traiter code retour insert --
              SELECT @erreur = @@error, @trans_etat = @@transtate
              IF @erreur != 0 OR @trans_etat > 1
              GOTO fin
                
-- => Ensure that Underwriting Year is numeric.
      SELECT @v_step = '36'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),251    
                           FROM BTRAV..OGLM0030_WORKFILE1 a 
                                WHERE ISNUMERIC(ISNULL(a.UWY_NF,'0')) != 1 
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 298)                
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin 
                
                
-- => Ensure that the Retro Underwriting Year  doesn't have ',' OR '.'
     SELECT @v_step = '31'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),301 
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                WHERE CHARINDEX(',',a.RTY_NF)      != 0 
                                OR    CHARINDEX('.',a.RTY_NF)      != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin       
                
-- => Ensure that Retro Underwriting Year is numeric.
     SELECT @v_step = '41'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),306 
                           FROM BTRAV..OGLM0030_WORKFILE1 a
                                WHERE ISNUMERIC(ISNULL(a.RTY_NF,'0'))  != 1
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 301)                
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                
        

-- => Ensure that all Year fields are 4 digits.
      SELECT @v_step = '44'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),252  
             FROM BTRAV..OGLM0030_WORKFILE1
                  WHERE CHAR_LENGTH(LTRIM(RTRIM(ISNULL(UWY_NF,'0000'))))     != 4 
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(RTY_NF,'0000'))))        != 4
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(BALSHEY_NF,'0000'))))    != 4
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin                                            
                      
    -- => Ensure that all Year fields are greater than 0.
      SELECT @v_step = '44'    
              IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC
               WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (306,251,326)) = 0
              BEGIN
              -- => Année doit être positive
                    SELECT @v_step = '41'
                    INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),253   
                          FROM BTRAV..OGLM0030_WORKFILE1 
                            WHERE convert(int,ISNULL(UWY_NF,'0'))       < 0
                            OR convert(int,ISNULL(RTY_NF,'0'))          < 0
                            OR convert(int,ISNULL(BALSHEY_NF,'0'))      < 0
                    -- traiter code retour insert --
                    SELECT @erreur = @@error, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                       GOTO fin  
               END -- sous test pour Année

-- => Ensure that END_NT doesn't have a ',' OR '.'.
    SELECT @v_step = '45'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),309
                           FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE CHARINDEX(',',END_NT) != 0 
                                OR    CHARINDEX('.',END_NT) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                         
                
-- => Ensure that END_NT is numeric.
      SELECT @v_step = '47'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),258   
              FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE ISNUMERIC(ISNULL(a.END_NT,'0'))   != 1
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 309) 
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
 -- => Ensure that END_NT is not more than 2 digits.
       SELECT @v_step = '49'
       INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
       SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),257  
               FROM BTRAV..OGLM0030_WORKFILE1 a
                 WHERE CHAR_LENGTH(LTRIM(RTRIM(a.END_NT))) > 2
                 AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (309,258))
       -- traiter code retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
          GOTO fin   
          
       -- => Ensure that END_NT value is 0.
      SELECT @v_step = '49'       
        IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (257,258,309)) = 0
        BEGIN       
         -- => Numero avenant ne doit pas être négatif
               SELECT @v_step = '51'
               INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,NUMLIGNE_NT),0),259   
                                FROM BTRAV..OGLM0030_WORKFILE1 
                                    WHERE ISNULL(convert(int,END_NT),0) <> 0                                    
               -- traiter code retour insert --
               SELECT @erreur = @@error, @trans_etat = @@transtate
               IF @erreur != 0 OR @trans_etat > 1
                  GOTO fin
          END -- sous test pour numero avenant
          
-- => Ensure that RETEND_NT doesn't have a ',' OR '.'.
      SELECT @v_step = '46'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),355
                           FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE CHARINDEX(',',RETEND_NT) != 0 
                                OR    CHARINDEX('.',RETEND_NT) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                         
                                 

-- => Ensure that RETEND_NT is numeric.
      SELECT @v_step = '48'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),356   
              FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE ISNUMERIC(ISNULL(a.RETEND_NT,'0'))   != 1
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 355) 
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
 
-- => Ensure that RETEND_NT is not more than 2 digits.
       SELECT @v_step = '50'
       INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
       SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),357  
               FROM BTRAV..OGLM0030_WORKFILE1 a
                 WHERE CHAR_LENGTH(LTRIM(RTRIM(a.RETEND_NT))) > 2
                 AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (355,356))
       -- traiter code retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
          GOTO fin   
        
     -- => Ensure that RETEND_NT value is 0.
      SELECT @v_step = '50'     
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (355,356,357)) = 0
            BEGIN       
             -- => Numero avenant ne doit pas être négatif
                   SELECT @v_step = '52'
                   INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                          SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,NUMLIGNE_NT),0),358   
                                    FROM BTRAV..OGLM0030_WORKFILE1 
                                        WHERE ISNULL(convert(int,RETEND_NT),0) <> 0                                    
                   -- traiter code retour insert --
                   SELECT @erreur = @@error, @trans_etat = @@transtate
                   IF @erreur != 0 OR @trans_etat > 1
                      GOTO fin
              END -- sous test pour numero avenant      


-- => Ensure that UW_NT doesn't have a ',' OR '.'.
    SELECT @v_step = '53'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),310
                           FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE CHARINDEX(',',UW_NT) != 0 
                                OR    CHARINDEX('.',UW_NT) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin       
                
-- => Ensure that UW_NT is numeric.
      SELECT @v_step = '55'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),255   
               FROM BTRAV..OGLM0030_WORKFILE1 a
                 WHERE ISNUMERIC(ISNULL(a.UW_NT,'0')) != 1
                 AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 310)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

 -- => Ensure that UW_NT is not more than 2 digits.
       SELECT @v_step = '57'
       INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
       SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),254   
                FROM BTRAV..OGLM0030_WORKFILE1 a
                  WHERE CHAR_LENGTH(LTRIM(RTRIM(a.UW_NT))) > 2
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (255,310))
       -- traiter code retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
          GOTO fin
          
     -- => Ensure that UW_NT value is 1.
	  IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (254,255,310)) = 0
	  BEGIN
	   -- => Numero d'ordre exercice doit être strictement positif
			 SELECT @v_step = '59'
			 INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
			 SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),256   
					  FROM BTRAV..OGLM0030_WORKFILE1
						WHERE  convert(int,ISNULL(UW_NT,'1')) <> 1
			 -- traiter code retour insert --
			 SELECT @erreur = @@error, @trans_etat = @@transtate
			 IF @erreur != 0 OR @trans_etat > 1
				GOTO fin
	   END -- sous test pour numero ordre exercice

-- => Ensure that RETUW_NT doesn't have a ',' OR '.'.
    SELECT @v_step = '54'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),359
                           FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE CHARINDEX(',',RETUW_NT) != 0 
                                OR    CHARINDEX('.',RETUW_NT) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin       


-- => Ensure that RETUW_NT is numeric.
      SELECT @v_step = '56'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),360   
               FROM BTRAV..OGLM0030_WORKFILE1 a
                 WHERE ISNUMERIC(ISNULL(a.RETUW_NT,'0')) != 1
                 AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 359)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => Ensure that RETUW_NT is not more than 2 digits.
       SELECT @v_step = '58'
       INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
       SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),361   
                FROM BTRAV..OGLM0030_WORKFILE1 a
                  WHERE CHAR_LENGTH(LTRIM(RTRIM(a.RETUW_NT))) > 2
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (359,360))
       -- traiter code retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
          GOTO fin
                     
     -- => Ensure that RETUW_NT value is 1.
	  IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (359,360,361)) = 0
	  BEGIN
	   -- => Numero d'ordre exercice retrocession doit être strictement positif
			 SELECT @v_step = '60'
			 INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
			 SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),362   
					  FROM BTRAV..OGLM0030_WORKFILE1
						WHERE  convert(int,ISNULL(RETUW_NT,'1')) <> 1
			 -- traiter code retour insert --
			 SELECT @erreur = @@error, @trans_etat = @@transtate
			 IF @erreur != 0 OR @trans_etat > 1
				GOTO fin
	   END -- sous test pour numero ordre exercice

-- => Ensure that SEC_NF doesn't have a ',' OR '.'.
    SELECT @v_step = '61'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),311
                           FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE CHARINDEX(',',SEC_NF) != 0 
                                OR    CHARINDEX('.',SEC_NF) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin 
                
-- => Ensure that SEC_NF is numeric.
      SELECT @v_step = '63'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),261   
              FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE ISNUMERIC(ISNULL(a.SEC_NF,'0'))  != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 311)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => Ensure that SEC_NF is not more than 2 digits.
      SELECT @v_step = '65'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),260  
                FROM BTRAV..OGLM0030_WORKFILE1 a
                   WHERE CHAR_LENGTH(LTRIM(RTRIM(a.SEC_NF))) > 2
                   AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (261,311))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => Ensure that SEC_NF is > 0
      SELECT @v_step = '65'
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (311,261,260)) = 0
            BEGIN
            
            -- => Section doit être strictement positif
                  SELECT @v_step = '67'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                         SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),262   
                                FROM BTRAV..OGLM0030_WORKFILE1 
                                   WHERE ISNULL(convert(int,SEC_NF),1) <= 0 
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
            END -- sous test pour section
         

-- => Ensure that RETSEC_NF doesn't have a ',' OR '.'.
    SELECT @v_step = '62'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),363
                           FROM BTRAV..OGLM0030_WORKFILE1 
                                WHERE CHARINDEX(',',RETSEC_NF) != 0 
                                OR    CHARINDEX('.',RETSEC_NF) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin 

-- => Ensure that RETSEC_NF is numeric.
      SELECT @v_step = '64'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),364   
              FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE ISNUMERIC(ISNULL(a.RETSEC_NF,'0'))  != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 363)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => Ensure that RETSEC_NF is not more than 2 digits.
      SELECT @v_step = '66'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),365  
                FROM BTRAV..OGLM0030_WORKFILE1 a
                   WHERE CHAR_LENGTH(LTRIM(RTRIM(a.RETSEC_NF))) > 2
                   AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (363,364))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
                                               
            
-- => Ensure that RETSEC_NF is > 0
      SELECT @v_step = '66'      
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (363,364,365)) = 0
            BEGIN
            
            -- => Section doit être strictement positif
                  SELECT @v_step = '68'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                         SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),366   
                                FROM BTRAV..OGLM0030_WORKFILE1 
                                   WHERE ISNULL(convert(int,RETSEC_NF),1) <= 0 
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
            END -- sous test pour section
-- Fin contrôle section

-- => Trim the space characters from CTR_NF/RETCTR_NF before validation.
    SELECT @v_step = '89'
     UPDATE BTRAV..OGLM0030_WORKFILE1
            SET CTR_NF = UPPER(RTRIM(LTRIM(ISNULL(CTR_NF,'')))),
                RETCTR_NF = UPPER(RTRIM(LTRIM(ISNULL(RETCTR_NF,''))))    
                        -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 

-- => Ensure that CTR_NF is not more than 8 chars.
      SELECT @v_step = '90'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),250   
              FROM BTRAV..OGLM0030_WORKFILE1
                WHERE CHAR_LENGTH(LTRIM(RTRIM(CTR_NF))) > 9
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => Ensure that RETCTR_NF is not more than 8 chars.
      SELECT @v_step = '91'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),313   
              FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE CHAR_LENGTH(LTRIM(RTRIM(a.RETCTR_NF))) > 9
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 289)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
-- Fin contrôle contrat


-- => Ensure that AMT_M field does not have a ','
      SELECT @v_step = '92'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),354
                           FROM BTRAV..OGLM0030_WORKFILE1
                                WHERE CHARINDEX(',',AMT_M) != 0
             -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
                GOTO fin
                
-- => Ensure that AMT_M field is numeric
      SELECT @v_step = '94'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),270   
              FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE ISNUMERIC(ISNULL(a.AMT_M,'0')) != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 354)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => Ensure that AMT_M field is not more than 19 characters.
      SELECT @v_step = '96'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),269  
               FROM BTRAV..OGLM0030_WORKFILE1 a
                     WHERE CHAR_LENGTH(LTRIM(RTRIM(a.AMT_M))) > 19
                     AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (270,354))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
                
-- => Ensure that RETAMT_M field does not have a ','
      SELECT @v_step = '93'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),371
                           FROM BTRAV..OGLM0030_WORKFILE1
                                WHERE CHARINDEX(',',RETAMT_M) != 0
             -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
                GOTO fin
                
         
-- => Ensure that RETAMT_M field is numeric
      SELECT @v_step = '95'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),372   
              FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE ISNUMERIC(ISNULL(a.RETAMT_M,'0')) != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 371)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => Ensure that RETAMT_M field is not more than 19 characters.
      SELECT @v_step = '97'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),373  
               FROM BTRAV..OGLM0030_WORKFILE1 a
                     WHERE CHAR_LENGTH(LTRIM(RTRIM(a.RETAMT_M))) > 19
                     AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (371,372))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin                  
-- Fin contrôle montant

-- => Trim the space characters from CUR_CF/RETCUR_CF before validation.
    SELECT @v_step = '98'
     UPDATE BTRAV..OGLM0030_WORKFILE1
            SET CUR_CF = UPPER(RTRIM(LTRIM(ISNULL(CUR_CF,'')))),
                RETCUR_CF = UPPER(RTRIM(LTRIM(ISNULL(RETCUR_CF,''))))                
                        -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
               
-- => Ensure that CUR_CF is not numeric
      SELECT @v_step = '99'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
           SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),268  
                    FROM BTRAV..OGLM0030_WORKFILE1
                       WHERE ISNUMERIC(ISNULL(CUR_CF,'C')) = 1
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => Ensure that CUR_CF is not more than 3 chars.
        SELECT @v_step = '101'
        INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
        SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),267   
                 FROM BTRAV..OGLM0030_WORKFILE1 a
                    WHERE CHAR_LENGTH(LTRIM(RTRIM(a.CUR_CF))) > 3
                      AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                       WHERE b.NUMFIC_NT   = @p_NUMFIC
                                         AND b.SSD_CF      = @p_SSD
                                         AND b.ESB_CF      = @p_ESB
                                         AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                         AND b.MESS_N      = 268)
        -- traiter code retour insert --
        SELECT @erreur = @@error, @trans_etat = @@transtate
        IF @erreur != 0 OR @trans_etat > 1
           GOTO fin    
         
         
-- => Ensure that RETCUR_CF is not numeric
      SELECT @v_step = '100'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
           SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),374  
                    FROM BTRAV..OGLM0030_WORKFILE1 
                       WHERE ISNUMERIC(ISNULL(RETCUR_CF,'C')) = 1
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin                        
                                                                

-- => Ensure that RETCUR_CF is not more than 3 chars.
        SELECT @v_step = '102'
        INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
        SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),375   
                 FROM BTRAV..OGLM0030_WORKFILE1 a
                    WHERE CHAR_LENGTH(LTRIM(RTRIM(a.RETCUR_CF))) > 3
                      AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                       WHERE b.NUMFIC_NT   = @p_NUMFIC
                                         AND b.SSD_CF      = @p_SSD
                                         AND b.ESB_CF      = @p_ESB
                                         AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                         AND b.MESS_N      = 374)
        -- traiter code retour insert --
        SELECT @erreur = @@error, @trans_etat = @@transtate
        IF @erreur != 0 OR @trans_etat > 1
           GOTO fin 
-- Fin contrôle devise  

	 -- => GEAC Close Period must be Numeric
     SELECT @v_step = '06'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,404
                  FROM BTRAV..OGLM0030_WORKFILE1
                     WHERE ISNUMERIC(ISNULL(GEAC_CLOSE_PERD_ADJ,'0')) != 1                    
                     
                        -- traiter code retour insert --
           SELECT @erreur = @@error, @trans_etat = @@transtate
           IF @erreur != 0 OR @trans_etat > 1
              GOTO fin 

	 -- => Ensure that GEAC_CLOSE_PERD_ADJ is 0/1.
	   SELECT @v_step = '104'
	   INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
			  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,NUMLIGNE_NT),0),405
						FROM BTRAV..OGLM0030_WORKFILE1 a
							WHERE convert(int,ISNULL(GEAC_CLOSE_PERD_ADJ, '0')) NOT IN (0,1)
                      AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                       WHERE b.NUMFIC_NT   = @p_NUMFIC
                                         AND b.SSD_CF      = @p_SSD
                                         AND b.ESB_CF      = @p_ESB
                                         AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                         AND b.MESS_N      = 404)
              
	   -- traiter code retour insert --
	   SELECT @erreur = @@error, @trans_etat = @@transtate
	   IF @erreur != 0 OR @trans_etat > 1
		  GOTO fin
	   
	 -- => Ensure that GEAC_REVERSAL_CODE is N/Q/R.     
	   SELECT @v_step = '105'
	   INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
			  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,NUMLIGNE_NT),0),406
						FROM BTRAV..OGLM0030_WORKFILE1 
							WHERE ISNULL(convert(char(1),GEAC_REVERSAL_CODE),'N') NOT IN ('N','Q','R')
	   -- traiter code retour insert --
	   SELECT @erreur = @@error, @trans_etat = @@transtate
	   IF @erreur != 0 OR @trans_etat > 1
		  GOTO fin
      
    SELECT @v_step = '102'
    INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),407   
             FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE CHAR_LENGTH(LTRIM(RTRIM(a.EVT_NF))) > 10
    -- traiter code retour insert --
    SELECT @erreur = @@error, @trans_etat = @@transtate
    IF @erreur != 0 OR @trans_etat > 1
       GOTO fin 
           
    SELECT @v_step = '102'
    INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),408   
             FROM BTRAV..OGLM0030_WORKFILE1 a
                WHERE CHAR_LENGTH(LTRIM(RTRIM(a.REVT_NF))) > 10
    -- traiter code retour insert --
    SELECT @erreur = @@error, @trans_etat = @@transtate
    IF @erreur != 0 OR @trans_etat > 1
       GOTO fin 

-- => Chercher les erreurs 
    SELECT @v_step = '130'

    SELECT  @V_NBANO_NT = (SELECT COUNT(1) FROM  BCTA..TANOINTACC
    WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC) 
        
    SELECT @V_NBLGKO_NT = (SELECT COUNT (DISTINCT NUMLIGNE_NT) FROM  BCTA..TANOINTACC
    WHERE SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC)
        -- traiter code retour select --
    SELECT @erreur = @@error, @trans_etat = @@transtate
    IF @erreur != 0 OR @trans_etat > 1
        GOTO fin
            
-- => mettre à jour TSUIVINTACC           
     SELECT @v_step = '131'    
        IF (@V_NBANO_NT != 0)
            BEGIN
                UPDATE BCTA..TSUIVINTACC
                SET NBANO_NT = @V_NBANO_NT,
                    NBLGKO_NT = @V_NBLGKO_NT,
                    FICSTS_CF    = 'KO',
                    LSTUPDUSR_CF = @p_USR_CF,
                    LSTUPD_D     = getdate()
                WHERE  SSD_CF = @p_SSD AND  ESB_CF  = @p_ESB AND  NUMFIC_NT = @p_NUMFIC AND FICSTS_CF = 'EC'
                -- traiter code retour update --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                    BEGIN
                          GOTO fin
                    END
                -- sortie normale avec erreur de format --
                GOTO fin2
            END    
        ELSE
         BEGIN		
		--=> alimenter la table BTRAV..OGLM0030_WORKFILE2 pour le contrôle de cohérence    
				 SELECT @v_step = '136' 
				 INSERT INTO BTRAV..OGLM0030_WORKFILE2
					(
					 NUMLINE_NT
					,SSD_CF            
					,ESB_CF                   
					,BALSHEY_NF     
					,BALSHRMTH_NF        
					,BALSHRDAY_NF        
					,VALPERY_NF     
					,VALPERMTH_NF   
					,TRNCOD_CF      
					,RETAUTGEN_B    
					,CTR_NF         
					,END_NT              
					,SEC_NF             
					,UWY_NF              
					,UW_NT               
					,OCCYEA_NF          
					,ACY_NF         
					,SCOSTRMTH_NF   
					,SCOENDMTH_NF         
					,CLM_NF         
					,CUR_CF         
					,AMT_M          
					,RETCTR_NF           
					,RETEND_NT      
					,RETSEC_NF      
					,RTY_NF         
					,RETUW_NT       
					,PLC_NT         
					,RETOCCYEA_NF   
					,RETACY_NF      
					,RETSCOSTRMTH_NF
					,RETSCOENDMTH_NF
					,RCL_NF         
					,RETCUR_CF      
					,RETAMT_M       
					,COMMAC_LL      
					,SPEENTTYP_CF   
					,SPEENTNAT_CT
                                        ,EVT_NF          
                                        ,REVT_NF                    
					,GEAC_CLOSE_PERD_ADJ
					,GEAC_REVERSAL_CODE
					,TYPEMNT_CT
					,CRE_D          
					,CREUSR_CF      
					,LSTUPD_D       
					,LSTUPDUSR_CF   
					,FILENAME
					,NUMLIGNE_NT
					,NUMFIC_NT
					)
					  SELECT convert(int,NUMLIGNE_NT),
							 @p_SSD,
							 @p_ESB,
							 convert(smallint,BALSHEY_NF),
							 convert(tinyint,BALSHRMTH_NF),
							 convert(tinyint,BALSHRDAY_NF),
							 convert(smallint,VALPERY_NF),
							 convert(tinyint,VALPERMTH_NF),
							 convert(char(8),rtrim(ltrim(TRNCOD_CF))),
							 convert(bit,RETAUTGEN_B),
							 convert(char(9),CTR_NF),
							 ISNULL(convert(tinyint,END_NT),0),
							 convert(tinyint,SEC_NF),
							 convert(smallint,UWY_NF),
							 ISNULL(convert(tinyint,UW_NT),1),							 							 							 
							 convert(smallint,OCCYEA_NF),
							 convert(smallint,ACY_NF),
							 convert(tinyint,SCOSTRMTH_NF),
							 convert(tinyint,SCOENDMTH_NF),
							 convert(int,CLM_NF),
							 convert(char(3),CUR_CF),
							 convert(decimal(18,3),str(round(convert(decimal(18,7),AMT_M),3),18,3)),
							 convert(char(9),RETCTR_NF),
							 ISNULL(convert(tinyint,RETEND_NT),0),							 
							 convert(tinyint,RETSEC_NF),
							 convert(smallint,RTY_NF),
							 ISNULL(convert(tinyint,RETUW_NT),1),							 							 
							 convert(int,PLC_NT),
							 convert(smallint,RETOCCYEA_NF),
							 convert(smallint,RETACY_NF),
							 convert(tinyint,RETSCOSTRMTH_NF),
							 convert(tinyint,RETSCOENDMTH_NF),
							 convert(int,RCL_NF),
							 convert(char(3),RETCUR_CF),
							 convert(decimal(18,3),str(round(convert(decimal(18,7),RETAMT_M),3),18,3)),
							 convert(varchar(64),rtrim(ltrim(COMMAC_LL))),
							 convert(tinyint,SPEENTTYP_CF),
							 convert(tinyint,SPEENTNAT_CT),
							 convert(char(10), EVT_NF),
               convert(char(10), REVT_NF),               
							 ISNULL(convert(int,GEAC_CLOSE_PERD_ADJ),0),
							 ISNULL(convert(char(1),GEAC_REVERSAL_CODE),'R'),
							 convert(char(3),@p_TYPEMNT),
							 getdate(),
							 @p_USR_CF,
							 getdate(),
							 @p_USR_CF,
							 FILENAME,
							 convert(numeric(6),NUMLIGNE_NT),
							 convert(int,NUMFIC_NT)
					   FROM BTRAV..OGLM0030_WORKFILE1  
				-- traiter code retour insert --
				SELECT @erreur = @@error, @trans_etat = @@transtate
				IF @erreur != 0 OR @trans_etat > 1
					BEGIN
						GOTO fin
					END
        END
-- SORTIE NORMALE : Validation et Envoi retour
COMMIT
select 0
return 0

-- SORTIE NORMALE avec erreur de format : Validation et Envoi retour
fin2:
COMMIT
select 1
return 1

-- SORTIE BRUTALE : Marche arriere et Envoi retour
fin:
ROLLBACK

select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_30 - Etape: ' + @v_step + @v_ident + ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
PRINT @p_erreur

-- update la table BTCA..TSUIVINTACC
   SELECT @v_step = '140'
   UPDATE BCTA..TSUIVINTACC
      SET FICSTS_CF    = 'KO',
          LSTUPDUSR_CF = @p_USR_CF,
          LSTUPD_D     = getdate()
    WHERE SSD_CF = @p_SSD
     AND  ESB_CF  = @p_ESB
     AND  NUMFIC_NT = @p_NUMFIC
     AND FICSTS_CF = 'EC'
-- traiter code retour sql --
   SELECT @erreur = @@error, @trans_etat = @@transtate
   IF @erreur != 0 OR @trans_etat > 1
      BEGIN
         select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_30 - Etape: ' + @v_step + @v_ident+' - Erreur SQL: ' + convert(char(5),@erreur)+ ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
         PRINT @p_erreur
      END

-- Insertion BCTA..TANOINTACC
   SELECT @v_step = '142'
   INSERT INTO BCTA..TANOINTACC (  NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                         VALUES ( @p_NUMFIC, @p_SSD, @p_ESB,0,279 )
   -- traiter code retour insert --
   SELECT @erreur = @@error, @trans_etat = @@transtate
   IF @erreur != 0 OR @trans_etat > 1
      BEGIN
         select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_30 - Etape: ' + @v_step + @v_ident+ ' - Erreur SQL: ' + convert(char(5),@erreur)+ ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
         PRINT @p_erreur
      END
select 1
return 1
go
EXEC sp_procxmode 'dbo.PtTSUIVINTACC_30', 'unchained'
go
IF OBJECT_ID('dbo.PtTSUIVINTACC_30') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtTSUIVINTACC_30 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtTSUIVINTACC_30 >>>'
go
GRANT EXECUTE ON dbo.PtTSUIVINTACC_30 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtTSUIVINTACC_30 TO GDBBATCH
go
