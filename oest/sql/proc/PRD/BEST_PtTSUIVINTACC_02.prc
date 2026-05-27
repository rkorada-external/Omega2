USE BEST
go
IF OBJECT_ID('dbo.PtTSUIVINTACC_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtTSUIVINTACC_02
    IF OBJECT_ID('dbo.PtTSUIVINTACC_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtTSUIVINTACC_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtTSUIVINTACC_02 >>>'
END
go
CREATE PROCEDURE dbo.PtTSUIVINTACC_02
(
  @p_SSD        USSD_CF,
  @p_ESB        UESB_CF,
  @p_NUMFIC     UUWENTNBR_NT,
  @p_USR_CF     UUSR_CF,
  @p_TRN_NT     decimal(10,0)
)
AS
/********************************************************************************
Programme: PtTSUIVINTACC_02
Fichier script associé : BEST_PtTSUIVINTACC_02.prc
Fiche spot : 23860
                :spot:23860     LRAK
Domaine : ESTIMATION
Base principale : BEST
Version: 1
Auteur: LRAK (ASCOTT)
Date de creation: 10/05/2012
Description du programme: Mise à jour de BCTA..TSUIVINTACC et BCTA..TANOINTACC
Contrôle de cohérence des données écritures service ESTIMATION à intégrer
Parametres en entrée:
       @p_SSD : filiale
       @p_ESB : etablissement
       @p_NUMFIC  : numero fichier
       @p_USR_CF : utilisateur
       @p_TRN_NT : max(TRN_NT)+1 de BEST..TACCSUP avant intégration
Parametres en sortie:
       retourne :
          => sans erreur : 0
          => ayant erreur : 1

Commentaires: Cette cartouche est tres importante.
              Merci de l'enrichir lors des modifications
Modifications :
04/02/2020  SA   Made the +500 logic to ANO_CT conditional. (Spira 84479)
********************************************************************************/

DECLARE @erreur          int,
        @trans_etat      int,
        @tran_imbr       bit,
        @v_step          char(02),
        @v_ident         varchar(50),
        @V_NBANO_NT      int,
        @V_NBLGKO_NT     int,
        @p_SSD_char      varchar(02),
        @p_ESB_char      varchar(02), 
        @p_NUMFIC_char   varchar(06),
        @p_erreur        varchar(250)

-- table temporaire pour TANOINTACC
create table #TANOINTACC
    (
    NUMFIC_NT   UUWENTNBR_NT NOT NULL,
    SSD_CF      USSD_CF      NOT NULL,
    ESB_CF      UESB_CF      NOT NULL,
    NUMLIGNE_NT numeric(5,0) DEFAULT 0 NOT NULL,
    MESS_N      numeric(5,0) DEFAULT 0 NOT NULL
    )

-- initialiser des variables
select @erreur = 0, @tran_imbr = 1

---if @@trancount = 0
---   begin
---      select @tran_imbr = 0
---      BEGIN TRAN
---   end

-- recuperer les parametres en entree  --
   SELECT @v_step = '01'
   SELECT @p_SSD_char = convert(varchar(02),@p_SSD), @p_ESB_char = convert(varchar(02),@p_ESB), @p_NUMFIC_char = convert(varchar(06),@p_NUMFIC)
   SELECT @v_ident = '- Clé : SSD_CF=' + @p_SSD_char + ' - ESB_CF=' +  @p_ESB_char + ' - NUMFIC=' + @p_NUMFIC_char 
 
-- => appel de la procédure de contrôle et insertion dans TACCSUP
   SELECT @v_step = '10'
                    INSERT #TANOINTACC
                    (
                    NUMFIC_NT,
                    SSD_CF,
                    ESB_CF,
                    NUMLIGNE_NT,
                    MESS_N
                    )
                  SELECT
                    @p_NUMFIC,
                    @p_SSD,
                    @p_ESB,
                    convert(numeric(5,0),NUMLINE_NT),
                    CASE WHEN ANO_CT < 500 THEN
                        convert(numeric(5,0),ANO_CT)+500
                    ELSE
                        convert(numeric(5,0),ANO_CT)
                    END
                  FROM
                        BEST..TCTRANO
                  WHERE SSD_CF = @p_SSD 
                    AND SEG_NF = @p_USR_CF 
                  -- traiter code retour insert --
                    SELECT @erreur = @@error, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                      GOTO fin
                      
                -- => compter les erreurs
                SELECT @v_step = '15'
                    SELECT  @V_NBANO_NT = (SELECT COUNT(1) FROM  #TANOINTACC)
                    SELECT @V_NBLGKO_NT = (SELECT COUNT (DISTINCT NUMLIGNE_NT) FROM  #TANOINTACC)
                    -- traiter code retour select --
                    SELECT @erreur = @@error, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                        GOTO fin                  
               
                   IF (@V_NBANO_NT != 0)
                        BEGIN
                        -- => mettre à jour TSUIVINTACC           
                             SELECT @v_step = '20'    
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
                                           GOTO fin
                        
                        -- => Insertion BCTA..TANOINTACC
                              SELECT @v_step = '25'   
                                INSERT BCTA..TANOINTACC
                                            (
                                            NUMFIC_NT,
                                            SSD_CF,
                                            ESB_CF,
                                            NUMLIGNE_NT,
                                            MESS_N
                                            )
                                       SELECT 
                                            NUMFIC_NT,
                                            SSD_CF,
                                            ESB_CF,
                                            NUMLIGNE_NT,
                                            MESS_N    
                                        FROM #TANOINTACC
                                -- traiter code retour insert --
                                        SELECT @erreur = @@error, @trans_etat = @@transtate
                                        IF @erreur != 0 OR @trans_etat > 1
                                           GOTO fin
                        END
                   ELSE
                        BEGIN
                             -- => mettre à jour TSUIVINTACC           
                                SELECT @v_step = '30'    
                                UPDATE BCTA..TSUIVINTACC
                                    SET FICSTS_CF   = 'OK',
                                        LSTUPD_D    = getdate(),
                                        MINMVT_NT   = @p_TRN_NT,
                                        MAXMVT_NT   = (select max(TRN_NT) from BEST..TACCSUP)   
                                    WHERE ssd_cf    = @p_SSD
                                    AND esb_cf      = @p_ESB
                                    AND numfic_nt   = @p_NUMFIC
                                    AND FICSTS_CF   = 'EC'
                                    -- traiter code retour insert --
                                    SELECT @erreur = @@error, @trans_etat = @@transtate
                                    IF @erreur != 0 OR @trans_etat > 1
                                         GOTO fin       
                        END
        
---if @tran_imbr = 0
---   begin
      COMMIT TRAN
---   end      
-- SORTIE NORMALE : Validation et Envoi retour
return 0

-- SORTIE BRUTALE : Marche arriere et Envoi retour
fin:
---if @tran_imbr = 0
---  BEGIN
      ROLLBACK TRAN
---   END


select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_02 - Etape: ' + @v_step + @v_ident + ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
PRINT @p_erreur

-- update la table BTCA..TSUIVINTACC
   SELECT @v_step = '35'
   UPDATE BCTA..TSUIVINTACC
      SET FICSTS_CF    = 'KO',
          LSTUPDUSR_CF = @p_USR_CF,
          LSTUPD_D     = getdate()
    WHERE SSD_CF = @p_SSD
     AND  ESB_CF  = @p_ESB
     AND  NUMFIC_NT = @p_NUMFIC
     AND  FICSTS_CF = 'EC'
-- traiter code retour sql --
   SELECT @erreur = @@error, @trans_etat = @@transtate
   IF @erreur != 0 OR @trans_etat > 1 
      BEGIN
         select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_02 - Etape: ' + @v_step + @v_ident+' - Erreur SQL: ' + convert(char(5),@erreur) + ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
         PRINT @p_erreur
      END

-- Insertion BCTA..TANOINTACC
   SELECT @v_step = '40'
   INSERT INTO BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
                         VALUES (@p_NUMFIC, @p_SSD, @p_ESB,0,353)
   -- traiter code retour insert --
   SELECT @erreur = @@error, @trans_etat = @@transtate
   IF @erreur != 0 OR @trans_etat > 1
      BEGIN
         select @p_erreur = 'Erreur BEST_PtTSUIVINTACC_02 - Etape: ' + @v_step + @v_ident+ ' - Erreur SQL: ' + convert(char(5),@erreur) + ' Supprimer les ${DFILT}/${NCHAIN}_*.dat avant de relancer le traitement'
         PRINT @p_erreur
      END
return 1
go
EXEC sp_procxmode 'dbo.PtTSUIVINTACC_02', 'unchained'
go
IF OBJECT_ID('dbo.PtTSUIVINTACC_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtTSUIVINTACC_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtTSUIVINTACC_02 >>>'
go
GRANT EXECUTE ON dbo.PtTSUIVINTACC_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtTSUIVINTACC_02 TO GDBBATCH
go
