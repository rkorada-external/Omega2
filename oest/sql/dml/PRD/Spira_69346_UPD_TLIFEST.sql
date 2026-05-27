USE BTRAV
go

-- ------------------------------------------------------------------------------------
-- Script           : Spira_69346_UPD_TLIFEST.sql
-- Domaine          : ESTIMATION
-- Base Principale  : BEST
-- Auteur           : S.Behague
-- Date de création : 07/11/2018
-- spira            : 69346
-- Description      : Génération à tort d' Ecritures VOBA en Parent et Local GAAP dans le cadre des OI
-- -------------------------------------------------------------------------------------

/*
 * DROP PROC delete_TLIFEST
 */
IF OBJECT_ID('Update_TLIFEST') IS NOT NULL
BEGIN
    DROP PROC Update_TLIFEST
    PRINT '<<< DROPPED PROC Update_TLIFEST >>>'
END

GO

--=============================
--  DEBUT CREATION PROCEDURE
--=============================
CREATE PROCEDURE Update_TLIFEST (  @PAR_SPOT   VARCHAR(05),  -- Attention seuls 4 derniers chiffres seront utilisés !!!
                                   @CTR_NF     UCTR_NF
                                 )
AS

BEGIN TRAN
--SET flushmessage ON

-- ------------------------- --
-- Declaration des variables --
-- ------------------------- --

DECLARE @nb_lus1        int
      , @nb_maj1        int
      , @nb_amaj1       int
      , @nb_lus2        int
      , @nb_maj2        int
      , @nb_amaj2       int
      , @nb_ins1        int
      , @erreur         int
      , @trans_etat     int
      , @datejour       datetime


-- --------------------- --
-- Début des traitements --
-- --------------------- --
PRINT ' '
PRINT 'DEBUT - SPOT : %1!', @PAR_SPOT

-- Vérification minimale des paramètres en entrée :  --
-- paramètres obligatoires  
IF (@PAR_SPOT = NULL)

   BEGIN
        PRINT 'TOUS LES PARAMETRES SONT OBLIGATOIRES ET NON NULL - SPOT : %1! ', @PAR_SPOT
   END

-- si paramètres renseignés alors continuer controles  
ELSE
   IF (SELECT DATALENGTH(@PAR_SPOT)) != 5
      BEGIN
           PRINT 'LE NUMERO SPOT DOIT ETRE 5 CHIFFRES - SPOT : %1!', @PAR_SPOT
      END
   ELSE
      BEGIN
-- --------------------- --
-- Début des traitements --    
-- --------------------- --
           PRINT 'LES PARAMETRES PASSES -'

-- Initialiser les paramètres
           SELECT @nb_maj1  = 0    -- nb lignes créées
                , @datejour = getdate() 

----------------------------------------------------
---------- Update Table BEST..TLIFEST ---------------
----------------------------------------------------
          select "Avant UPDATE TLIFEST" "Avant UPDATE TLIFEST", * FROM BEST..TLIFEST
          WHERE  ctr_nf = @CTR_NF

          UPDATE BEST..TLIFEST SET ESTMNT_M = 0 FROM BEST..TLIFEST
          WHERE  CTR_NF = @CTR_NF

                    -- récuperer codes retour et nb lignes impactées --
                    SELECT @erreur = @@error, @nb_maj1 = @@rowcount, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                      BEGIN
                            PRINT 'BEST..TLIFEST - UPDATE ERREUR : %1!',@erreur
                            ROLLBACK TRAN
                            GOTO fin
                      END
          select "Après UPDATE TLIFEST" "Après UPDATE TLIFEST", * FROM BEST..TLIFEST
          WHERE  ctr_nf = @CTR_NF


      END 

-- ------------------- --
-- Fin transaction     --
-- ------------------- --
COMMIT TRAN
--ROLLBACK TRAN

fin:
PRINT 'FIN   - SPOT : %1!', @PAR_SPOT

GO

IF OBJECT_ID('Update_TLIFEST') IS NOT NULL
    PRINT '<<< CREATED PROC Update_TLIFEST >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC Update_TLIFEST >>>'
go

--=============================
--  FIN CREATION PROCEDURE
--=============================

/*
 * Granting/Revoking Permissions on Update_TLIFEST
 */
GRANT EXECUTE ON Update_TLIFEST TO GOMEGA
GO
GRANT EXECUTE ON Update_TLIFEST TO GDBBATCH
GO
--======================================
--  ETIQUETTE DEBUT TRAITEMENT PRINCIPAL
--======================================
SET nocount ON

DECLARE @msg varchar(200)

PRINT''
SELECT @msg = @@servername + ' => ' + host_name()
PRINT @msg
SELECT @msg = 'Debut Spira_69346_UPD_TLIFEST.sql '
            + CONVERT(char(10), getdate(), 103)
            + ' '
            + CONVERT(char(8), getdate(), 8)
            + ' '
            + SUBSTRING(CONVERT(char(27), getdate(), 109), 21, 6)

PRINT @msg

SET nocount OFF
GO

--=============================
-- TRAITEMENT PRINCIPAL
--=============================
-- RAPPEL PARAMETRES

-- Appel procedure Update_TLIFEST  

EXECUTE BTRAV..Update_TLIFEST  '69346', '14P000459'
EXECUTE BTRAV..Update_TLIFEST  '69346', '14P000460'


--====================================
--  ETIQUETTE FIN TRAITEMENT PRINCIPAL
--====================================
SET nocount ON
DECLARE @msg varchar(200)

PRINT ' '
SELECT @msg = 'Fin Spira_69346_UPD_TLIFEST.sql '
            + convert(char(10),getdate(),103)
            + ' '
            + convert(char(8),getdate(),8) 
            + ' '
            + substring(convert(char(27),getdate(),109),21,6)

PRINT @msg

SET nocount OFF
GO

--  Drop procedure apres utilisation
IF OBJECT_ID('Update_TLIFEST') IS NOT NULL
BEGIN
    DROP PROC Update_TLIFEST
    PRINT '<<< DROPPED PROC Update_TLIFEST >>>'
END
go
