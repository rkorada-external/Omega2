USE BEST
go
IF OBJECT_ID('PtTSUIVINTACC_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PtTSUIVINTACC_01
    IF OBJECT_ID('PtTSUIVINTACC_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PtTSUIVINTACC_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PtTSUIVINTACC_01 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PtTSUIVINTACC_01
     ( @p_SSD        USSD_CF,
       @p_ESB        UESB_CF,
       @p_NUMFIC     UUWENTNBR_NT,
       @p_USR_CF     UUSR_CF,
       @p_date_d     datetime = NULL)
with execute as caller as

/*************************************************************************************
Programme: PtTSUIVINTACC_01
Fichier script associé : BEST_PtTSUIVINTACC_01.prc
Fiche spot : 23860 
            :spot:23860     LRAK
Domaine : ESTIMATION
Base principale : BEST
Version: 1
Auteur: LRAK (ASCOTT)
Date de creation: 04/06/2012
Description du programme: Controler les lignes dans BTRAV..EST_ESIJ0801_TESTUTISUP
Contrôle de format des données écritures service ESTIMATION à intégrer
Parametres en entrée:
       @p_SSD : filiale
       @p_ESB : etablissement
       @p_NUMFIC  : numero fichier
       @p_USR_CF : utilisateur
Parametres en sortie:
       retourne :
          => sans erreur : 0
            => ayant erreur : 1

Commentaires: Cette cartouche est tres importante.
              Merci de l'enrichir lors des modifications

MODIFICATION "Removed dbo and added 'with execute as caller as'"              

[001] 04/02/2014 R. cassis :spot:25427  Ajout Grant to gdbbatch
[002] 2016-04-14 M. Mendoza :spot:28469  Validates input subsidiary and subledger (@p_ssd, @p_esb) match for all CTR_NFs on the file
[003] 2020-05-21 Shiva A :Spira :87246  Added validation to ensure that the balance sheet date is unique.
[003] 2021-04-06 S.Behague :Spira :95331
[004] 2025-11-26 S.Behague :US7362 L&H- SAS AE intégration issue on US last day of closing
**************************************************************************************/

DECLARE @erreur          int,
        @trans_etat      int,
        @v_step          char(04),
        @v_ident         varchar(50),
        @p_erreur        varchar(250),
        @V_NBANO_NT      int,
        @V_NBLGKO_NT     int,
        @p_SSD_char      varchar(02),
        @p_ESB_char      varchar(02), 
        @p_NUMFIC_char   varchar(06),
        @v_TRN_NT        numeric(10,0),
        @v_cre_d         datetime,
        @v_entpery_nf    smallint,
        @v_entpermth_nf  tinyint,   
        @v_spcend_d      datetime,
        @v_account_d     datetime,
        @v_closing_b     bit,
        @v_retour        int,
        @v_max_balsht_d  datetime

-- table temporaire pour doublon de numéro de ligne
Create Table #TST (NUMLIGNE_NT    VARCHAR(50)     NULL,
                   NBR_DOUBLON    Int             NULL)
                   
Create Table #TMP_BALSHTD
(
    NUMLIGNE_NT  VARCHAR(50) NOT NULL,
    BALSHT_D     DATETIME    NOT NULL
)

-- initialiser des variables
select @erreur = 0

-- recuperer les parametres en entree  --
   SELECT @v_step = '01'
   SELECT @p_SSD_char = convert(varchar(02),@p_SSD), @p_ESB_char = convert(varchar(02),@p_ESB), @p_NUMFIC_char = convert(varchar(06),@p_NUMFIC)
   SELECT @v_ident = '- Clé : SSD_CF=' + @p_SSD_char + ' - ESB_CF=' +  @p_ESB_char + ' - NUMFIC=' + @p_NUMFIC_char 


-- DEBUT CONTROLES : insertion directe des anomalies dans BCTA..TANOINTACC
-- => Numéro de ligne ne doit pas être à NULL
     SELECT @v_step = '03'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,285 
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                     WHERE NUMLIGNE_NT IS NULL                   
            -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
              GOTO fin

-- => Numéro de ligne ne doit pas contenir de point
     SELECT @v_step = '04'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,295
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                     WHERE CHARINDEX('.',NUMLIGNE_NT) != 0
            -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
              GOTO fin
           
-- => Numéro de ligne ne doit pas contenir de virgule
     SELECT @v_step = '05'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,271   
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                     WHERE CHARINDEX(',',NUMLIGNE_NT) != 0
            -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
              GOTO fin

--=> Numéro de ligne doit être numérique
     SELECT @v_step = '06'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,MESS_N )
            SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,278   
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                     WHERE ISNUMERIC(ISNULL(NUMLIGNE_NT,'0')) != 1                    
                        -- traiter code retour insert --
           SELECT @erreur = @@error, @trans_etat = @@transtate
           IF @erreur != 0 OR @trans_etat > 1
              GOTO fin 
     
-- => Mise à jour à zéro de tous les numéros de ligne en erreur de format de BTRAV..EST_ESIJ0801_TESTUTISUP
     SELECT @v_step = '07'
     UPDATE BTRAV..EST_ESIJ0801_TESTUTISUP
            SET NUMLIGNE_NT = '0'
            WHERE CHARINDEX(',',NUMLIGNE_NT) != 0
            OR    CHARINDEX('.',NUMLIGNE_NT) != 0
            OR    ISNUMERIC(NUMLIGNE_NT) != 1
            OR    NUMLIGNE_NT IS NULL           
                        -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 

-- Début Contrôle des champs obligatoires pour BTRAV..EST_ESID0801_TESTUTISUP
-- => Filiale et établissement ne doivent pas être à NULL
    SELECT @v_step = '08'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),286
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                            WHERE SSD_CF IS NULL
                            OR    ESB_CF IS NULL                           
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin
               
-- => Année bilan ne doit pas être à NULL
    SELECT @v_step = '09'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),287
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                            WHERE BALSHEY_NF IS NULL                         
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
               
-- => Mois Bilan ne doit pas être à NULL
    SELECT @v_step = '10'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),288
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                            WHERE BALSHRMTH_NF IS NULL           
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 

-- => Jour Bilan ne doit pas être à NULL
    SELECT @v_step = '11'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),289
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                            WHERE BALSHRDAY_NF IS NULL     
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin
               
-- => Année Fin Validité ne doit pas être à NULL
    SELECT @v_step = '12'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),290
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                            WHERE VALPERY_NF IS NULL     
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
               
-- => Mois Fin Validité ne doit pas être à NULL
    SELECT @v_step = '13'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),291
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                            WHERE VALPERMTH_NF IS NULL     
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
               
-- => Generation Auto rétro ne doit pas être à NULL
    SELECT @v_step = '14'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),292
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                            WHERE RETAUTGEN_B IS NULL     
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin
               
-- => Poste comptable ne doit pas être à NULL
    SELECT @v_step = '18'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),315
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                            WHERE TRNCOD_CF IS NULL     
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin  
-- Fin Contrôle des champs obligatoires pour BTRAV..EST_ESID0801_TESTUTISUP
      
-- => suite des contrôles conditionnée par numéro de ligne correcte (convertible en int)
-- => doublons de numéro de ligne
     SELECT @v_step = '19'
      Insert Into #TST
      Select NUMLIGNE_NT, Count(*)
      From   BTRAV..EST_ESIJ0801_TESTUTISUP
      Group by NUMLIGNE_NT
      Having Count(*) > 1
      Order By NUMLIGNE_NT
      
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),284   
                         FROM #TST                        
                -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
      
-- => Numéro de ligne doit être > 0
      SELECT @v_step = '20'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),280   
                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP
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
                 
-- Début contrôle sur Filiale et Etablissement
-- => Filiale ne doit contenir ni point ni virgule 
      SELECT @v_step = '21'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),296   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',SSD_CF) != 0
                                OR    CHARINDEX('.',SSD_CF) != 0
       -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
                                
-- => Etablissement ne doit contenir ni point ni virgule 
      SELECT @v_step = '22'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),297   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',ESB_CF) != 0
                                OR    CHARINDEX('.',ESB_CF) != 0
      -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
        
-- => Filiale doit être numérique
      SELECT @v_step = '23'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),274   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
                   
-- => Etablissement doit être numérique
      SELECT @v_step = '24'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),276   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Filiale ne doit pas dépasser 2 chiffres
      SELECT @v_step = '25'
             INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),273   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
                        
-- => Etablissement ne doit pas dépasser 2 chiffres
      SELECT @v_step = '26'
             INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),275   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
                      
      -- => sous test pour Filiale et Etablissement
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (286,274,276,296,297)) = 0
               BEGIN                 
                 -- => Différence entre filiale/établissement enregistrement/nom du fichier
                      SELECT @v_step = '27'
                           INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),277   
                                         FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                         WHERE ISNULL(convert(int,SSD_CF),0) != @p_SSD 
                                            OR    ISNULL(convert(int,ESB_CF),0) != @p_ESB                
                           -- traiter code retour insert --
                           SELECT @erreur = @@error, @trans_etat = @@transtate
                           IF @erreur != 0 OR @trans_etat > 1
                              GOTO fin
                END -- sous test Filiale et Etablissement
-- Fin contrôle sur Filiale et Etablissement

-- Début contrôle des années
-- => Années ne doivent contenir ni virgule ni point
-- => Exercice d'acceptation ne doit contenir ni virgule ni point
      SELECT @v_step = '28'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),298   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',UWY_NF)         != 0 
                                OR    CHARINDEX('.',UWY_NF)         != 0 
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin

-- => Exercice de survenance ne doit contenir ni virgule ni point
      SELECT @v_step = '29'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),300   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',OCCYEA_NF)      != 0 
                                OR    CHARINDEX('.',OCCYEA_NF)      != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                                
                                
-- => Année bilan ne doit contenir ni virgule ni point                               
     SELECT @v_step = '30'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),299
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
                               
-- => Exercice de rétrocession ne doit contenir ni virgule ni point                               
     SELECT @v_step = '31'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),301 
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                                WHERE CHARINDEX(',',a.RTY_NF)      != 0 
                                OR    CHARINDEX('.',a.RTY_NF)      != 0  
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 290)                
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin        
                                                   
-- => Année Fin Validité ne doit contenir ni virgule ni point                                                      
    SELECT @v_step = '32'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),302
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                                WHERE CHARINDEX(',',a.VALPERY_NF)      != 0 
                                OR    CHARINDEX('.',a.VALPERY_NF)      != 0  
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 290)                
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                                                                                                    
                               
-- => Année de Compte Accept ne doit contenir ni virgule ni point
    SELECT @v_step = '33'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),303
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',ACY_NF) != 0 
                                OR    CHARINDEX('.',ACY_NF) != 0      
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin

-- => Exercice de survenance retro ne doit contenir ni virgule ni point
    SELECT @v_step = '34'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),293
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',RETOCCYEA_NF) != 0 
                                OR    CHARINDEX('.',RETOCCYEA_NF) != 0      
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin              

-- => Année de Compte Rétro ne doit contenir ni virgule ni point
    SELECT @v_step = '35'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),314
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',RETACY_NF) != 0 
                                OR    CHARINDEX('.',RETACY_NF) != 0      
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin              
                                                                               
-- => Année doit être numérique                   
-- => Exercice d'acceptation doit être numérique
      SELECT @v_step = '36'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),251    
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a 
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

-- => Année de survenance du sinistre doit être numérique
      SELECT @v_step = '37'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),304
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a 
                                WHERE ISNUMERIC(ISNULL(a.OCCYEA_NF,'0')) != 1 
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 300)
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin 

-- => Exercice de survenance retro doit être numérique
      SELECT @v_step = '38'
            INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),325
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a 
                                WHERE ISNUMERIC(ISNULL(a.RETOCCYEA_NF,'0')) != 1 
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 293)                                            
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                                       

-- => Année bilan doit être numérique
      SELECT @v_step = '39'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),326
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a 
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

-- => Année Fin Validité doit être numérique 
      SELECT @v_step = '40'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
        SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),327
            FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
             WHERE  ISNUMERIC(a.VALPERY_NF)  != 1
             AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (290,302))
     -- traiter code retour insert --
     SELECT @erreur = @@error, @trans_etat = @@transtate
     IF @erreur != 0 OR @trans_etat > 1
        GOTO fin
        
-- => Exercice de rétrocession doit être numérique                               
     SELECT @v_step = '41'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),306 
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                                WHERE ISNUMERIC(ISNULL(a.RTY_NF,'0'))  != 1
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (290,301))                
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                

-- => Année de Compte Accept. doit être numérique                                                  
    SELECT @v_step = '42'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),307
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                                WHERE ISNUMERIC(ISNULL(a.ACY_NF,'0')) != 1
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 303)              
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                                                            

-- => Année de Compte Rétro  doit être numérique 
    SELECT @v_step = '43'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),308
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                                WHERE ISNUMERIC(ISNULL(a.RETACY_NF,'0')) != 1 
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 314)     
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                                                                     
        
-- => Année doit contenir 4 digits
      SELECT @v_step = '44'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),252  
             FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                  WHERE CHAR_LENGTH(LTRIM(RTRIM(ISNULL(UWY_NF,'0000'))))     != 4 
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(OCCYEA_NF,'0000'))))     != 4
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(RTY_NF,'0000'))))        != 4
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(BALSHEY_NF,'0000'))))    != 4
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(VALPERY_NF,'0000'))))    != 4
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(ACY_NF,'0000'))))        != 4
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(RETOCCYEA_NF,'0000'))))  != 4
                  OR CHAR_LENGTH(LTRIM(RTRIM(ISNULL(RETACY_NF,'0000'))))     != 4
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin                                            
                      
    -- => sous test pour Année  
              IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC
               WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (308,307,306,304,251,325,326,327)) = 0
              BEGIN
              -- => Année doit être positive
                    SELECT @v_step = '41'
                    INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),253   
                          FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                            WHERE convert(int,ISNULL(UWY_NF,'0'))       < 0
                            OR convert(int,ISNULL(OCCYEA_NF,'0'))       < 0
                            OR convert(int,ISNULL(RTY_NF,'0'))          < 0
                            OR convert(int,ISNULL(BALSHEY_NF,'0'))      < 0
                            OR convert(int,ISNULL(VALPERY_NF,'0'))      < 0
                            OR convert(int,ISNULL(ACY_NF,'0'))          < 0
                            OR convert(int,ISNULL(RETOCCYEA_NF,'0'))    < 0
                            OR convert(int,ISNULL(RETACY_NF,'0'))       < 0
                    -- traiter code retour insert --
                    SELECT @erreur = @@error, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                       GOTO fin  
               END -- sous test pour Année
-- Fin contrôle des années

-- Début contrôle avenant    
-- => Numero avenant ne doit contenir ni point ni virgule
    SELECT @v_step = '45'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),309
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',END_NT) != 0 
                                OR    CHARINDEX('.',END_NT) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                         

-- => Numero avenant rétro ne doit contenir ni point ni virgule
    SELECT @v_step = '46'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),355
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',RETEND_NT) != 0 
                                OR    CHARINDEX('.',RETEND_NT) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin                         
                                 
-- => Numero avenant doit être numérique
      SELECT @v_step = '47'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),258   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Numero avenant rétro doit être numérique
      SELECT @v_step = '48'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),356   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
 
 -- => Numero avenant ne doit pas dépasser 2 chiffres
       SELECT @v_step = '49'
       INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
       SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),257  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Numero avenant rétro ne doit pas dépasser 2 chiffres
       SELECT @v_step = '50'
       INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
       SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),357  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

       -- => sous test pour numero avenant
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (257,258,309)) = 0
            BEGIN       
             -- => Numero avenant ne doit pas être négatif
                   SELECT @v_step = '51'
                   INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                          SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,NUMLIGNE_NT),0),259   
                                    FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                        WHERE ISNULL(convert(int,END_NT),0) < 0                                    
                   -- traiter code retour insert --
                   SELECT @erreur = @@error, @trans_etat = @@transtate
                   IF @erreur != 0 OR @trans_etat > 1
                      GOTO fin
              END -- sous test pour numero avenant
        
        -- => sous test pour numero avenant rétro
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (355,356,357)) = 0
            BEGIN       
             -- => Numero avenant ne doit pas être négatif
                   SELECT @v_step = '52'
                   INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                          SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,NUMLIGNE_NT),0),358   
                                    FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                        WHERE ISNULL(convert(int,RETEND_NT),0) < 0                                    
                   -- traiter code retour insert --
                   SELECT @erreur = @@error, @trans_etat = @@transtate
                   IF @erreur != 0 OR @trans_etat > 1
                      GOTO fin
              END -- sous test pour numero avenant      
-- Fin contrôle avenant                      

-- Début contrôle ordre exercice
-- => Numero d'ordre exercice acceptation ne doit contenir ni point ni virgule
    SELECT @v_step = '53'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),310
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',UW_NT) != 0 
                                OR    CHARINDEX('.',UW_NT) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin       

-- => Numero d'ordre exercice retrocession ne doit contenir ni point ni virgule
    SELECT @v_step = '54'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),359
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',RETUW_NT) != 0 
                                OR    CHARINDEX('.',RETUW_NT) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin       

-- => Numero d'ordre exercice doit être numérique
      SELECT @v_step = '55'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),255   
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Numero d'ordre exercice retrocession doit être numérique
      SELECT @v_step = '56'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),360   
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

 -- => Numero d'ordre exercice ne doit pas dépasser 2 chiffres
       SELECT @v_step = '57'
       INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
       SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),254   
                FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Numero d'ordre exercice retrocession ne doit pas dépasser 2 chiffres
       SELECT @v_step = '58'
       INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
       SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),361   
                FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
                     
      -- => sous test pour numero ordre exercice
              IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (254,255,310)) = 0
              BEGIN
               -- => Numero d'ordre exercice doit être strictement positif
                     SELECT @v_step = '59'
                     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),256   
                              FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                                WHERE  convert(int,ISNULL(UW_NT,'1')) <= 0
                     -- traiter code retour insert --
                     SELECT @erreur = @@error, @trans_etat = @@transtate
                     IF @erreur != 0 OR @trans_etat > 1
                        GOTO fin
               END -- sous test pour numero ordre exercice
       
       -- => sous test pour numero ordre exercice retrocession
              IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (359,360,361)) = 0
              BEGIN
               -- => Numero d'ordre exercice retrocession doit être strictement positif
                     SELECT @v_step = '60'
                     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),362   
                              FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                                WHERE  convert(int,ISNULL(RETUW_NT,'1')) <= 0
                     -- traiter code retour insert --
                     SELECT @erreur = @@error, @trans_etat = @@transtate
                     IF @erreur != 0 OR @trans_etat > 1
                        GOTO fin
               END -- sous test pour numero ordre exercice
-- Fin contrôle ordre exercice                     

-- Début contrôle section
-- => Section ne doit contenir ni point ni virgule
    SELECT @v_step = '61'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),311
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',SEC_NF) != 0 
                                OR    CHARINDEX('.',SEC_NF) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin 

-- => retrocession Section ne doit contenir ni point ni virgule
    SELECT @v_step = '62'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),363
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',RETSEC_NF) != 0 
                                OR    CHARINDEX('.',RETSEC_NF) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin 
                      
-- => Section doit être numérique
      SELECT @v_step = '63'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),261   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => retrocession Section doit être numérique
      SELECT @v_step = '64'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),364   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Section ne doit pas dépasser 2 chiffres
      SELECT @v_step = '65'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),260  
                FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => retrocession Section ne doit pas dépasser 2 chiffres
      SELECT @v_step = '66'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),365  
                FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
                                               
      -- => sous test pour section
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (311,261,260)) = 0
            BEGIN
            
            -- => Section doit être strictement positif
                  SELECT @v_step = '67'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                         SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),262   
                                FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                   WHERE ISNULL(convert(int,SEC_NF),1) <= 0 
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
            END -- sous test pour section
            
      -- => sous test pour retrocession section
            IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (363,364,365)) = 0
            BEGIN
            
            -- => Section doit être strictement positif
                  SELECT @v_step = '68'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                         SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),366   
                                FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                   WHERE ISNULL(convert(int,RETSEC_NF),1) <= 0 
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
            END -- sous test pour section
-- Fin contrôle section

-- Début contrôle jour      
-- => jour bilan ne doit contenir ni point ni virgule
     SELECT @v_step = '69'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),390
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
                
-- => jour bilan doit être numérique
     SELECT @v_step = '70'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,a.NUMLIGNE_NT),0),391   
             FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => jour bilan ne doit pas dépasser 2 chiffres
      SELECT @v_step = '71'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),392  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

    -- => sous test pour jour bilan
               IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (289,390,391,392)) = 0
               BEGIN           
                -- => jour doit être entre 1 et 31
                      SELECT @v_step = '72'
                      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),393  
                              FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE convert(int,BALSHRDAY_NF) NOT BETWEEN 1 AND 31
                      -- traiter code retour insert --
                      SELECT @erreur = @@error, @trans_etat = @@transtate
                      IF @erreur != 0 OR @trans_etat > 1
                         GOTO fin
               END -- sous test pour mois
-- Fin contrôle jour  

-- Début contrôle mois      
-- => Mois ne doit contenir ni point ni virgule
     SELECT @v_step = '73'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),312
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',SCOSTRMTH_NF) != 0 
                                OR    CHARINDEX('.',SCOSTRMTH_NF) != 0  
                                OR    CHARINDEX(',',SCOENDMTH_NF) != 0 
                                OR    CHARINDEX('.',SCOENDMTH_NF) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin 
 
-- => Mois retrocession ne doit contenir ni point ni virgule
     SELECT @v_step = '74'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),367
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',RETSCOSTRMTH_NF) != 0 
                                OR    CHARINDEX('.',RETSCOSTRMTH_NF) != 0  
                                OR    CHARINDEX(',',RETSCOENDMTH_NF) != 0 
                                OR    CHARINDEX('.',RETSCOENDMTH_NF) != 0  
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin

-- => Mois bilan ne doit contenir ni point ni virgule
     SELECT @v_step = '75'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),383
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Mois fin validité ne doit contenir ni point ni virgule
     SELECT @v_step = '76'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),387
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                                WHERE CHARINDEX(',',a.VALPERMTH_NF) != 0 
                                OR    CHARINDEX('.',a.VALPERMTH_NF) != 0  
                                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 291)
             -- traiter code retour insert --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                GOTO fin         
                                                          
-- => Mois doit être numérique
     SELECT @v_step = '77'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,a.NUMLIGNE_NT),0),265   
             FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
               WHERE ISNUMERIC(ISNULL(a.SCOSTRMTH_NF,'0')) != 1 
               OR    ISNUMERIC(ISNULL(a.SCOENDMTH_NF,'0')) != 1 
               AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 312)
     -- traiter code retour insert --
     SELECT @erreur = @@error, @trans_etat = @@transtate
     IF @erreur != 0 OR @trans_etat > 1
        GOTO fin

-- => Mois rétrocession doit être numérique
     SELECT @v_step = '78'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,a.NUMLIGNE_NT),0),368   
             FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
               WHERE ISNUMERIC(ISNULL(a.RETSCOSTRMTH_NF,'0')) != 1 
               OR    ISNUMERIC(ISNULL(a.RETSCOENDMTH_NF,'0')) != 1 
               AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 367)
     -- traiter code retour insert --
     SELECT @erreur = @@error, @trans_etat = @@transtate
     IF @erreur != 0 OR @trans_etat > 1
        GOTO fin
        
-- => Mois bilan doit être numérique
     SELECT @v_step = '79'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,a.NUMLIGNE_NT),0),384   
             FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
        
-- => Mois de fin de validité doit être numérique
     SELECT @v_step = '80'
     INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
     SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,ISNULL(convert(int,a.NUMLIGNE_NT),0),388   
             FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
               WHERE ISNUMERIC(a.VALPERMTH_NF) != 1 
               AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (291,387))
     -- traiter code retour insert --
     SELECT @erreur = @@error, @trans_etat = @@transtate
     IF @erreur != 0 OR @trans_etat > 1
        GOTO fin             
        
-- => Mois ne doit pas dépasser 2 chiffres
      SELECT @v_step = '81'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),264  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                  WHERE (CHAR_LENGTH(LTRIM(RTRIM(a.SCOSTRMTH_NF))) > 2 OR CHAR_LENGTH(LTRIM(RTRIM(a.SCOENDMTH_NF))) > 2)
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (265,312))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => Mois retrocession ne doit pas dépasser 2 chiffres
      SELECT @v_step = '82'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),369  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                  WHERE (CHAR_LENGTH(LTRIM(RTRIM(a.RETSCOSTRMTH_NF))) > 2 OR CHAR_LENGTH(LTRIM(RTRIM(a.RETSCOENDMTH_NF))) > 2)
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (368,367))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => Mois bilan ne doit pas dépasser 2 chiffres
      SELECT @v_step = '83'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),385  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Mois fin validité ne doit pas dépasser 2 chiffres
      SELECT @v_step = '84'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),389  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                  WHERE CHAR_LENGTH(LTRIM(RTRIM(a.VALPERMTH_NF))) > 2
                  AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      in (291,387,388))
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
                         
     -- => sous test pour mois
           IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (264,265,312)) = 0
           BEGIN           
            -- => Mois doit être entre 1 et 12
                  SELECT @v_step = '85'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),266  
                          FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                            WHERE (ISNULL(convert(int,SCOSTRMTH_NF),1) NOT BETWEEN 1 AND 12 OR ISNULL(convert(int,SCOENDMTH_NF),1) NOT BETWEEN 1 AND 12)
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
           END -- sous test pour mois
     
     -- => sous test pour mois retrocession
           IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (367,368,369)) = 0
           BEGIN           
            -- => Mois doit être entre 1 et 12
                  SELECT @v_step = '86'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),370  
                          FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                            WHERE (ISNULL(convert(int,RETSCOSTRMTH_NF),1) NOT BETWEEN 1 AND 12 OR ISNULL(convert(int,RETSCOENDMTH_NF),1) NOT BETWEEN 1 AND 12)
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
           END -- sous test pour mois
           
     -- => sous test pour mois bilan
           IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (383,288,384,385)) = 0
           BEGIN           
            -- => Mois doit être entre 1 et 12
                  SELECT @v_step = '87'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),386  
                          FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                            WHERE convert(int,BALSHRMTH_NF) NOT BETWEEN 1 AND 12
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
           END -- sous test pour mois
           
     -- => sous test pour mois fin de validité
           IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (291,387,388,389)) = 0
           BEGIN           
            -- => Mois doit être entre 1 et 12
                  SELECT @v_step = '88'
                  INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                  SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),999  
                          FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                            WHERE convert(int,VALPERMTH_NF) NOT BETWEEN 1 AND 12
                  -- traiter code retour insert --
                  SELECT @erreur = @@error, @trans_etat = @@transtate
                  IF @erreur != 0 OR @trans_etat > 1
                     GOTO fin
           END -- sous test pour mois
-- Fin contrôle mois

-- Début contrôle contrat
-- => mise en majuscule du numero contrat                 
    SELECT @v_step = '89'
     UPDATE BTRAV..EST_ESIJ0801_TESTUTISUP
            SET CTR_NF = UPPER(RTRIM(LTRIM(ISNULL(CTR_NF,'')))),
                RETCTR_NF = UPPER(RTRIM(LTRIM(ISNULL(RETCTR_NF,''))))    
                        -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 

-- => Numero contrat d'acceptation > 9 caractères
      SELECT @v_step = '90'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),250   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                WHERE CHAR_LENGTH(LTRIM(RTRIM(CTR_NF))) > 9
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => Numero contrat de rétrocession > 9 caractères
      SELECT @v_step = '91'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),313   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- Début contrôle montant 
-- => Montant acceptation ne doit pas contenir de virgule
      SELECT @v_step = '92'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),354
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                                WHERE CHARINDEX(',',AMT_M) != 0
             -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
                GOTO fin

-- => Montant retrocession ne doit pas contenir de virgule
      SELECT @v_step = '93'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),371
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                                WHERE CHARINDEX(',',RETAMT_M) != 0
             -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
                GOTO fin
                
-- => Montant acceptation doit être numérique
      SELECT @v_step = '94'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),270   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
         
-- => Montant retrocession doit être numérique
      SELECT @v_step = '95'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),372   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
                             
-- => Montant acceptation ne doit pas contenir plus de 22 caractères
      SELECT @v_step = '96'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),269  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Montant retrocession ne doit pas contenir plus de 22 caractères
      SELECT @v_step = '97'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),373  
               FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- Début contrôle devise
-- => mise en majuscule de la devise                 
    SELECT @v_step = '98'
     UPDATE BTRAV..EST_ESIJ0801_TESTUTISUP
            SET CUR_CF = UPPER(RTRIM(LTRIM(ISNULL(CUR_CF,'')))),
                RETCUR_CF = UPPER(RTRIM(LTRIM(ISNULL(RETCUR_CF,''))))                
                        -- traiter code retour insert --
            SELECT @erreur = @@error, @trans_etat = @@transtate
            IF @erreur != 0 OR @trans_etat > 1
               GOTO fin 
-- => Devise acceptation ne peut pas être numérique
      SELECT @v_step = '99'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
           SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),268  
                    FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                       WHERE ISNUMERIC(ISNULL(CUR_CF,'C')) = 1
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => Devise retrocession ne peut pas être numérique
      SELECT @v_step = '100'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
           SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),374  
                    FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                       WHERE ISNUMERIC(ISNULL(RETCUR_CF,'C')) = 1
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin                        
                                                                
-- => Devise acceptation ne doit pas dépasser 3 caractères
        SELECT @v_step = '101'
        INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
        SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),267   
                 FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- => Devise retrocession ne doit pas dépasser 3 caractères
        SELECT @v_step = '102'
        INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
        SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),375   
                 FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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

-- Début contrôle poste comptable                     
-- => Poste comptable doit contenir 8 caractères
      SELECT @v_step = '103'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),263  
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
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
-- Fin contrôle poste comptable 

-- Début contrôle génération auto
-- => génération auto rétro doit être numérique avec la valeur 0 ou 1
      SELECT @v_step = '104'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),320   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                WHERE (ISNUMERIC(a.RETAUTGEN_B) != 1 OR a.RETAUTGEN_B NOT IN ('0','1'))
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 292)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
-- Fin contrôle génération auto

-- Début contrôle placement
-- => placement ne doit contenir ni point ni virgule 
      SELECT @v_step = '105'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),321   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',PLC_NT) != 0
                                OR    CHARINDEX('.',PLC_NT) != 0
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => placement doit être numérique
      SELECT @v_step = '106'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),322   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                WHERE ISNUMERIC(ISNULL(a.PLC_NT,'0')) != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 321)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => placement doit être positif
      IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (321,322)) = 0
      BEGIN
          SELECT @v_step = '107'
          INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
          SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),294   
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                    WHERE ISNULL(convert(int,PLC_NT),0) < 0 
                    AND PLC_NT IS NOT NULL
          -- traiter code retour insert --
          SELECT @erreur = @@error, @trans_etat = @@transtate
          IF @erreur != 0 OR @trans_etat > 1
             GOTO fin
      END
-- Fin contrôle placement

-- Début contrôle numéro de sinistre 
-- => numéro de sinistre rétrocession ne doit contenir ni point ni virgule 
      SELECT @v_step = '108'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),324   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                                WHERE CHARINDEX(',',RCL_NF) != 0
                                OR    CHARINDEX('.',RCL_NF) != 0
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => numéro de sinistre rétrocession doit être numérique
      SELECT @v_step = '109'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),323   
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                WHERE ISNUMERIC(ISNULL(a.RCL_NF,'0')) != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 324)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => numéro de sinistre rétrocession doit être positif
      IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (323,324)) = 0
      BEGIN
          SELECT @v_step = '110'
          INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
          SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),376   
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                    WHERE ISNULL(convert(int,RCL_NF),0) < 0 
                    AND RCL_NF IS NOT NULL
          -- traiter code retour insert --
          SELECT @erreur = @@error, @trans_etat = @@transtate
          IF @erreur != 0 OR @trans_etat > 1
             GOTO fin
      END
         
-- => numéro de sinistre acceptation ne doit contenir ni point ni virgule 
      SELECT @v_step = '111'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),317
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                                WHERE CHARINDEX(',',CLM_NF) != 0
                                OR    CHARINDEX('.',CLM_NF) != 0
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => numéro de sinistre acceptation doit être numérique
      SELECT @v_step = '112'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),319
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                WHERE ISNUMERIC(ISNULL(a.CLM_NF,'0')) != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 317)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => numéro de sinistre acceptation doit être positif
      IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (319,317)) = 0
      BEGIN
          SELECT @v_step = '113'
          INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
          SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),377   
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                    WHERE ISNULL(convert(int,CLM_NF),0) < 0 
                    AND CLM_NF IS NOT NULL
          -- traiter code retour insert --
          SELECT @erreur = @@error, @trans_etat = @@transtate
          IF @erreur != 0 OR @trans_etat > 1
             GOTO fin
      END
-- Fin contrôle numéro de sinistre

-- Début contrôle de type écriture
-- => type écriture ne doit contenir ni point ni virgule 
      SELECT @v_step = '114'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),351
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                                WHERE CHARINDEX(',',SPEENTTYP_CF) != 0
                                OR    CHARINDEX('.',SPEENTTYP_CF) != 0
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => type écriture doit être numérique
      SELECT @v_step = '115'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),352
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                WHERE ISNUMERIC(ISNULL(a.SPEENTTYP_CF,'0')) != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 351)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => type écriture  doit être strictement positif
      IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (351,352)) = 0
      BEGIN
          SELECT @v_step = '116'
          INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
          SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),378
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                    WHERE ISNULL(convert(int,SPEENTTYP_CF),0) <= 0 
                    AND SPEENTTYP_CF IS NOT NULL
          -- traiter code retour insert --
          SELECT @erreur = @@error, @trans_etat = @@transtate
          IF @erreur != 0 OR @trans_etat > 1
             GOTO fin
      END
-- Fin contrôle type écriture

-- Début contrôle nature écriture
-- => nature écriture ne doit contenir ni point ni virgule 
      SELECT @v_step = '117'
             INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),379
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                                WHERE CHARINDEX(',',SPEENTNAT_CT) != 0
                                OR    CHARINDEX('.',SPEENTNAT_CT) != 0
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin

-- => nature écriture doit être numérique
      SELECT @v_step = '118'
      INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
      SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,a.NUMLIGNE_NT),380
              FROM BTRAV..EST_ESIJ0801_TESTUTISUP a
                WHERE ISNUMERIC(ISNULL(a.SPEENTNAT_CT,'0')) != 1 
                AND NOT EXISTS (SELECT 1 FROM BCTA..TANOINTACC b
                                           WHERE b.NUMFIC_NT   = @p_NUMFIC
                                             AND b.SSD_CF      = @p_SSD
                                             AND b.ESB_CF      = @p_ESB
                                             AND b.NUMLIGNE_NT  = convert(int,a.NUMLIGNE_NT)
                                             AND b.MESS_N      = 379)
      -- traiter code retour insert --
      SELECT @erreur = @@error, @trans_etat = @@transtate
      IF @erreur != 0 OR @trans_etat > 1
         GOTO fin
         
-- => nature écriture  doit être strictement positif
      IF (SELECT COUNT(1) FROM  BCTA..TANOINTACC WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC AND MESS_N IN (379,380)) = 0
      BEGIN
          SELECT @v_step = '119'
          INSERT INTO BCTA..TANOINTACC ( NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
          SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),381
                  FROM BTRAV..EST_ESIJ0801_TESTUTISUP 
                    WHERE ISNULL(convert(int,SPEENTNAT_CT),0) <= 0
                    AND SPEENTNAT_CT IS NOT NULL
          -- traiter code retour insert --
          SELECT @erreur = @@error, @trans_etat = @@transtate
          IF @erreur != 0 OR @trans_etat > 1
             GOTO fin
      END
-- Fin contrôle nature écriture

-- => commentaire ne doit pas dépasser 64 caractères
      SELECT @v_step = '120'
             INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
                    SELECT DISTINCT @p_NUMFIC,@p_SSD,@p_ESB,convert(int,NUMLIGNE_NT),382   
                           FROM BTRAV..EST_ESIJ0801_TESTUTISUP
                                    WHERE CHAR_LENGTH(LTRIM(RTRIM(COMMAC_LL))) > 64
             -- traiter code retour insert --
          SELECT @erreur = @@error, @trans_etat = @@transtate
          IF @erreur != 0 OR @trans_etat > 1
             GOTO fin


-- => déterminer la période de saisie
    SELECT @v_step = '125'
        
if @p_date_d = NULL 
	select @p_date_d =getdate()
  
        --select @v_cre_d = getdate()
        select @v_retour = 0
        
        Execute @v_retour = BREF..PsCALEND_02
                @p_date_d,
                'C',
                @v_entpery_nf output,
          @v_entpermth_nf output,
                @v_spcend_d output,
                @v_account_d output,
                @v_closing_b output
    
        -- traiter code retour select --
        SELECT @erreur = @@error, @trans_etat = @@transtate
        IF @v_retour != 0 OR @erreur != 0 OR @trans_etat > 1
            GOTO fin
        
        SELECT @v_step = '126'
        if (convert(Char(10),@p_date_d,112) > convert(Char(10),@v_spcend_d,112) and convert(Char(10),@p_date_d,112) <= convert(Char(10),@v_account_d,112))
            BEGIN
              INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
                VALUES (@p_NUMFIC,@p_SSD,@p_ESB,0,395)
              -- traiter code retour select --
                SELECT @erreur = @@error, @trans_etat = @@transtate
                IF @erreur != 0 OR @trans_etat > 1
                    GOTO fin
            END

    --[002]
    SELECT @v_step = '127'
    INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
        select distinct @p_NUMFIC,convert(int,A.SSD_CF),convert(int,A.esb_cf),convert(int,a.NUMLIGNE_NT),5030
        from btrav..EST_ESIJ0801_TESTUTISUP a
        where A.CTR_NF is not null
        and not exists (
            select 1 from btrt..TCONTR b
            where A.CTR_NF = B.CTR_NF
            and convert(int,A.END_NT) = B.END_NT
            and convert(int,A.UWY_NF) = B.UWY_NF
            and convert(int,A.UW_NT) = B.UW_NT
            and convert(int,a.ssd_cf) = b.ssd_cf
            and convert(int,a.esb_cf) = b.accesb_cf
        )
     -- traiter code retour insert --
    SELECT @erreur = @@error, @trans_etat = @@transtate
    IF @erreur != 0 OR @trans_etat > 1
        GOTO fin

    SELECT @v_step = '128'
    INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
        select distinct @p_NUMFIC,convert(int,A.SSD_CF),convert(int,A.esb_cf),convert(int,a.NUMLIGNE_NT),5031
        from btrav..EST_ESIJ0801_TESTUTISUP a
        where A.RETCTR_NF is not null
        and not exists (
            select 1 from bret..TRETCTR b
            where A.RETCTR_NF = B.RETCTR_NF
            and convert(int,A.RTY_NF) = B.RTY_NF
            and convert(int,a.ssd_cf) = b.ssd_cf
            and convert(int,a.esb_cf) = b.esb_cf
        )
     -- traiter code retour insert --
    SELECT @erreur = @@error, @trans_etat = @@transtate
    IF @erreur != 0 OR @trans_etat > 1
        GOTO fin
        
    -- Check for multiple balance sheet dates.
    SELECT @v_step = '129'
    INSERT INTO #TMP_BALSHTD ( NUMLIGNE_NT, BALSHT_D )
    SELECT DISTINCT NUMLIGNE_NT, Convert(Datetime, Convert(Varchar(4), BALSHEY_NF) 
                                 || '/' || Convert(Varchar(2), BALSHRMTH_NF)
                                 || '/' || Convert(Varchar(2), BALSHRDAY_NF))
    FROM  BTRAV..EST_ESIJ0801_TESTUTISUP a
    WHERE BALSHEY_NF not like '%[^0-9]%'
    AND BALSHRMTH_NF not like '%[^0-9]%'    
    AND BALSHRDAY_NF not like '%[^0-9]%'
    AND CONVERT(int,NUMLIGNE_NT) <> 0
    
    -- traiter code retour insert --
    SELECT @erreur = @@error, @trans_etat = @@transtate
    IF @erreur != 0 OR @trans_etat > 1
        GOTO fin    
    
    -- Flag an error if there are more than 1.
    SELECT @v_step = '130'  
    IF (SELECT COUNT(DISTINCT BALSHT_D) FROM  #TMP_BALSHTD) > 1
    BEGIN
        -- Get the max balance sheet date.
        select @v_max_balsht_d=max(BALSHT_D) from #TMP_BALSHTD
    
        -- Flag every line that doesn't match the max balance sheet date.
        INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
        select distinct @p_NUMFIC,convert(int,A.SSD_CF),convert(int,A.esb_cf),convert(int,a.NUMLIGNE_NT),809
        from btrav..EST_ESIJ0801_TESTUTISUP a, #TMP_BALSHTD b
        where a.NUMLIGNE_NT = b.NUMLIGNE_NT
        and @v_max_balsht_d <> b.balsht_d        
                              
         -- traiter code retour insert --
        SELECT @erreur = @@error, @trans_etat = @@transtate
        IF @erreur != 0 OR @trans_etat > 1
            GOTO fin
    END

-- FIN CONTROLES : insertion directe des anomalies dans BCTA..TANOINTACC                        

-- => Chercher les erreurs 
    SELECT @v_step = '200'
    
        SELECT  @V_NBANO_NT = (SELECT COUNT(1) FROM  BCTA..TANOINTACC
        WHERE  SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC) 
        
        SELECT @V_NBLGKO_NT = (SELECT COUNT (DISTINCT NUMLIGNE_NT) FROM  BCTA..TANOINTACC
        WHERE SSD_CF = @p_SSD AND ESB_CF = @p_ESB AND NUMFIC_NT = @p_NUMFIC)
        -- traiter code retour select --
        SELECT @erreur = @@error, @trans_etat = @@transtate
        IF @erreur != 0 OR @trans_etat > 1
            GOTO fin
            
-- => mettre à jour TSUIVINTACC           
     SELECT @v_step = '201'    
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
       
--=> alimenter la table BTRAV..EST_ESID0801_TESTUTISUP pour le contrôle de cohérence    
     SELECT @v_step = '202' 
     INSERT INTO BTRAV..EST_ESID0801_TESTUTISUP
        (
        TRN_NT
        ,NUMLINE_NT
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
        ,CRE_D          
        ,CREUSR_CF      
        ,LSTUPD_D       
        ,LSTUPDUSR_CF      
        )
          SELECT convert(numeric(10,0),TRN_NT),
                 convert(int,NUMLIGNE_NT),
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
                 convert(tinyint,END_NT),
                 convert(tinyint,SEC_NF),
                 convert(smallint,UWY_NF),
                 convert(tinyint,UW_NT),
                 convert(smallint,OCCYEA_NF),
                 convert(smallint,ACY_NF),
                 convert(tinyint,SCOSTRMTH_NF),
                 convert(tinyint,SCOENDMTH_NF),
                 convert(int,CLM_NF),
                 convert(char(3),CUR_CF),
                 convert(decimal(18,3),str(round(convert(decimal(18,3),AMT_M),3),18,3)),
                 convert(char(9),RETCTR_NF),
                 convert(tinyint,RETEND_NT),
                 convert(tinyint,RETSEC_NF),
                 convert(smallint,RTY_NF),
                 convert(tinyint,RETUW_NT),
                 convert(int,PLC_NT),
                 convert(smallint,RETOCCYEA_NF),
                 convert(smallint,RETACY_NF),
                 convert(tinyint,RETSCOSTRMTH_NF),
                 convert(tinyint,RETSCOENDMTH_NF),
                 convert(int,RCL_NF),
                 convert(char(3),RETCUR_CF),
                 convert(decimal(18,3),str(round(convert(decimal(18,3),RETAMT_M),3),18,3)),
                 convert(varchar(64),rtrim(ltrim(COMMAC_LL))),
                 convert(tinyint,SPEENTTYP_CF),
                 convert(tinyint,SPEENTNAT_CT),
                 getdate(),
                 @p_USR_CF,
                 getdate(),
                 @p_USR_CF
           FROM BTRAV..EST_ESIJ0801_TESTUTISUP
        -- traiter code retour insert --
        SELECT @erreur = @@error, @trans_etat = @@transtate
        IF @erreur != 0 OR @trans_etat > 1
            BEGIN
                GOTO fin
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

select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_01 - Etape: ' + @v_step + @v_ident + ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
PRINT @p_erreur

-- update la table BTCA..TSUIVINTACC
   SELECT @v_step = '203'
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
         select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_01 - Etape: ' + @v_step + @v_ident+' - Erreur SQL: ' + convert(char(5),@erreur)+ ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
         PRINT @p_erreur
      END

-- Insertion BCTA..TANOINTACC
   SELECT @v_step = '204'
   INSERT INTO BCTA..TANOINTACC (  NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N )
                         VALUES ( @p_NUMFIC, @p_SSD, @p_ESB,0,279 )
   -- traiter code retour insert --
   SELECT @erreur = @@error, @trans_etat = @@transtate
   IF @erreur != 0 OR @trans_etat > 1
      BEGIN
         select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_01 - Etape: ' + @v_step + @v_ident+ ' - Erreur SQL: ' + convert(char(5),@erreur)+ ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
         PRINT @p_erreur
      END
select 1
return 1
go
EXEC sp_procxmode 'PtTSUIVINTACC_01', 'unchained'
go
IF OBJECT_ID('PtTSUIVINTACC_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PtTSUIVINTACC_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PtTSUIVINTACC_01 >>>'
go
GRANT EXECUTE ON PtTSUIVINTACC_01 TO GOMEGA
go
GRANT EXECUTE ON PtTSUIVINTACC_01 TO GDBBATCH
go
