USE BTRAV
go

-- ------------------------------------------------------------------------------------
-- Script           : Spira_70063_UPD_TCONTR_BY_SECTION.sql
-- Domaine          : ESTIMATION
-- Base Principale  : BTRT, BRET
-- Auteur           : S.Behague
-- Date de création : 18/10/2018
-- spira            : 70063
-- Description      : Changement code crible à 'O' pour les codes 'V' avec des estimations dans la grille (TLIFEST)
-- -------------------------------------------------------------------------------------

/*
 * DROP PROC delete_TLIFEST
 */
IF OBJECT_ID('Update_TCONTR') IS NOT NULL
BEGIN
    DROP PROC Update_TCONTR
    PRINT '<<< DROPPED PROC Update_TCONTR >>>'
END

GO

--=============================
--  DEBUT CREATION PROCEDURE
--=============================
CREATE PROCEDURE Update_TCONTR (  @PAR_SPOT   VARCHAR(05)  -- Attention seuls 4 derniers chiffres seront utilisés !!!
                                 )
AS

CREATE TABLE #tmpcontr
(
    CTR_NF              UCTR_NF    NOT NULL,
    UWY_NF              UUWY_NF    NOT NULL
) 
CREATE TABLE #tmpctrtochange
(
    CTR_NF              UCTR_NF    NOT NULL,
    UWY_NF              UUWY_NF    NOT NULL
)
CREATE TABLE #tmpretctrtochange
(
    RETCTR_NF           URETCTR_NF    NOT NULL,
    RTY_NF              UUWY_NF    NOT NULL
)
CREATE TABLE #tmpretctr
(
    RETCTR_NF           URETCTR_NF    NOT NULL,
    RTY_NF              UUWY_NF    NOT NULL
)


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
---------- Update Table BTRT..TCONTR ---------------
----------------------------------------------------
          insert into #tmpcontr
          select ctr_nf, uwy_nf from btrt..tcontr where estcrb_ct = 'V'

          insert into #tmpctrtochange 
          select distinct ctr.* from #tmpcontr ctr, best..tlifest lif where 
              ctr.ctr_nf = lif.ctr_nf
          and ctr.uwy_nf = lif.uwy_nf

          select "Avant UPDATE TCONTR" "Avant UPDATE TCONTR", ctr.* FROM BTRT..TCONTR ctr, #tmpctrtochange tmp
          WHERE  ctr.CTR_NF = tmp.CTR_NF
          AND    ctr.uwy_nf = tmp.uwy_nf

          UPDATE BTRT..TCONTR SET ESTCRB_CT = 'O' FROM BTRT..TCONTR ctr, #tmpctrtochange tmp
          WHERE  ctr.CTR_NF = tmp.CTR_NF
          AND    ctr.uwy_nf = tmp.uwy_nf

                    -- récuperer codes retour et nb lignes impactées --
                    SELECT @erreur = @@error, @nb_maj1 = @@rowcount, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                      BEGIN
                            PRINT 'BTRT..TCONTR - UPDATE ERREUR : %1!',@erreur
                            ROLLBACK TRAN
                            GOTO fin
                      END
          select "Après UPDATE TCONTR" "Après UPDATE TCONTR", ctr.* FROM BTRT..TCONTR ctr, #tmpctrtochange tmp
          WHERE  ctr.CTR_NF = tmp.CTR_NF
          AND    ctr.uwy_nf = tmp.uwy_nf

----------------------------------------------------
---------- Update Table BTRT..TSection--------------
----------------------------------------------------

          select "Avant UPDATE TSECTION" "Avant UPDATE TSECTION", sec.* FROM BTRT..TSECTION sec, #tmpctrtochange tmp
          WHERE  sec.CTR_NF = tmp.CTR_NF
          AND    sec.uwy_nf = tmp.uwy_nf

          UPDATE BTRT..TSECTION SET ESTCRB_CT = 'O' FROM BTRT..TSECTION sec, #tmpctrtochange tmp
          WHERE  sec.CTR_NF = tmp.CTR_NF
          AND    sec.uwy_nf = tmp.uwy_nf

                    -- récuperer codes retour et nb lignes impactées --
                    SELECT @erreur = @@error, @nb_maj1 = @@rowcount, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                      BEGIN
                            PRINT 'BTRT..TSECTION - UPDATE ERREUR : %1!',@erreur
                            ROLLBACK TRAN
                            GOTO fin
                      END
          select "Apres UPDATE TSECTION" "Apres UPDATE TSECTION", sec.* FROM BTRT..TSECTION sec, #tmpctrtochange tmp
          WHERE  sec.CTR_NF = tmp.CTR_NF
          AND    sec.uwy_nf = tmp.uwy_nf

-----------------------------------------------------
---------- Update Table BRET..TRETCTR ---------------
-----------------------------------------------------
          insert into #tmpretctr 
          select retctr_nf, rty_nf from bret..tretctr where estcrb_ct = 'V'

          insert into #tmpretctrtochange
          select distinct ctr.* from #tmpretctr ctr, best..tlifest lif where 
              ctr.retctr_nf = lif.ctr_nf
          and ctr.rty_nf = lif.uwy_nf

          select "Avant UPDATE TRETCTR" "Avant UPDATE TRETCTR", ctr.* FROM BRET..TRETCTR ctr, #tmpretctrtochange tmp 
          WHERE  ctr.RETCTR_NF = tmp.RETCTR_NF
          AND    ctr.rty_nf = tmp.rty_nf

          UPDATE BRET..TRETCTR SET ESTCRB_CT = 'O' FROM BRET..TRETCTR ctr, #tmpretctrtochange tmp
          WHERE  ctr.RETCTR_NF = tmp.RETCTR_NF
          AND    ctr.rty_nf = tmp.rty_nf

                    -- récuperer codes retour et nb lignes impactées --
                    SELECT @erreur = @@error, @nb_maj1 = @@rowcount, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                      BEGIN
                            PRINT 'BRET..TRETCTR - UPDATE ERREUR : %1!',@erreur
                            ROLLBACK TRAN
                            GOTO fin
                      END

          select "Apres UPDATE TRETCTR" "Apres UPDATE TRETCTR", ctr.* FROM BRET..TRETCTR ctr, #tmpretctrtochange tmp
          WHERE  ctr.RETCTR_NF = tmp.RETCTR_NF
          AND    ctr.rty_nf = tmp.rty_nf
      END 

-- ------------------- --
-- Fin transaction     --
-- ------------------- --
COMMIT TRAN
--ROLLBACK TRAN

fin:
PRINT 'FIN   - SPOT : %1!', @PAR_SPOT

GO

IF OBJECT_ID('Update_TCONTR') IS NOT NULL
    PRINT '<<< CREATED PROC Update_TCONTR >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC Update_TCONTR >>>'
go

--=============================
--  FIN CREATION PROCEDURE
--=============================

/*
 * Granting/Revoking Permissions on Update_TCONTR
 */
GRANT EXECUTE ON Update_TCONTR TO GOMEGA
GO
GRANT EXECUTE ON Update_TCONTR TO GDBBATCH
GO
--======================================
--  ETIQUETTE DEBUT TRAITEMENT PRINCIPAL
--======================================
SET nocount ON

DECLARE @msg varchar(200)

PRINT''
SELECT @msg = @@servername + ' => ' + host_name()
PRINT @msg
SELECT @msg = 'Debut Spira_70063_UPD_TCONTR_BY_SECTION.sql '
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

-- Appel procedure Update_TCONTR  

EXECUTE BTRAV..Update_TCONTR  '70063'


--====================================
--  ETIQUETTE FIN TRAITEMENT PRINCIPAL
--====================================
SET nocount ON
DECLARE @msg varchar(200)

PRINT ' '
SELECT @msg = 'Fin Spira_70063_UPD_TCONTR_BY_SECTION.sql '
            + convert(char(10),getdate(),103)
            + ' '
            + convert(char(8),getdate(),8) 
            + ' '
            + substring(convert(char(27),getdate(),109),21,6)

PRINT @msg

SET nocount OFF
GO

--  Drop procedure apres utilisation
IF OBJECT_ID('Update_TCONTR') IS NOT NULL
BEGIN
    DROP PROC Update_TCONTR
    PRINT '<<< DROPPED PROC Update_TCONTR >>>'
END
go
