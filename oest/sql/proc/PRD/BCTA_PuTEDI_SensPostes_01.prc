USE BCTA
GO                              

/* DROP PROC PuTEDI_SensPostes_01 */
IF OBJECT_ID('PuTEDI_SensPostes_01') IS NOT NULL
BEGIN
   DROP PROCEDURE PuTEDI_SensPostes_01
   IF OBJECT_ID('PuTEDI_SensPostes_01') IS NOT NULL
      PRINT '<<< FAILED DROPPING PROCEDURE PuTEDI_SensPostes_01 >>>'
   ELSE
      PRINT '<<< DROPPED PROCEDURE PuTEDI_SensPostes_01 >>>'
END
GO

/* Creation de la procedure */
create procedure PuTEDI_SensPostes_01
with execute as caller as
BEGIN
/*
------------------------------------------------------------------------
Programme                : PuTEDI_SensPostes_01
Fichier script associé   : CPJJ2101.cmd
Domaine                  : Compta/Sinitres
Base principale          : BTRAV
Version                  : 11.1
Auteur                   : Ph.VESSIERE
Date de creation         : 2011.04.28 (YYYY.MM.DD)
------------------------------------------------------------------------
Description  :
   Modification du sens des postes.
   Pour certains brokers, les montants affectés à certains postes de messages sont dans le mauvais sens.
   Le but est ici d'inverser le sens via la clé suivante : N° Broker / N° Poste comptable / N° poste JV.
----------------------------------------------------------------------
MODIFICATION : [000]
Auteur       : Ph.VESSIERE
Date         : 2011.04.28 (YYYY.MM.DD)
Version      : 11.1
Description  : [SPOT21248] - Création.
----------------------------------------------------------------------
----------------------------------------------------------------------
MODIFICATION : [001]
Auteur       : D.CHETBOUL
Date         : 2011.07.26 (YYYY.MM.DD)
Version      : 11.2
Description  : [SPOT22293] - Modification de la liste des POSTES.
----------------------------------------------------------------------
----------------------------------------------------------------------
Modification - Removed dbo and added ‘with execute as caller as’
----------------------------------------------------------------------
*/

-- ------------------------ --
-- Definition des variables --
-- ------------------------ --

DECLARE @erreur INT            -- Quel est le code erreur (Update, Fetch, ...) ?
DECLARE @errmsg VARCHAR(128)   -- Quel est le message d'erreur ?

-- ---------------------------- --
-- Initialisation des variables --
-- ---------------------------- --

-- ------------- --
-- Environnement --
-- ------------- --

-- Et c'est parti pour les 2 update (TA & CM)... --
BEGIN TRANSACTION

-- --------------------------------- --
-- TA - Inversion du sens des postes --
-- --------------------------------- --

 UPDATE BTRAV..CPT_EDI_CPJJ1000_TEDIACCD
 SET AMT_M =  CASE 
					WHEN JVREF.SENS_CF = "D" THEN  ACCD.AMT_M * -1 ELSE ACCD.AMT_M 
			   END
 FROM 		BTRAV..CPT_EDI_CPJJ1000_TEDIACCG ACCG 
 INNER JOIN BTRAV..CPT_EDI_CPJJ1000_TEDIACCD ACCD
 ON 	ACCG.EDI_CF    = 	ACCD.EDI_CF
 AND 	ACCG.RECORD_NF = 	ACCD.RECORD_NF
 AND 	ACCG.EDI_CF = 'JVE'
 
 INNER JOIN BCTA..TEDICMCODEJVREF JVREF
 ON  ACCD.JVTRNCOD_CF = ISNULL(JVREF.JVTRNCOD_CF, ACCD.JVTRNCOD_CF)
 AND ACCD.TRNCOD_CF   = ISNULL(JVREF.TRNCOD_CF, ACCD.TRNCOD_CF)
 AND ACCG.CED_NF  	  = ISNULL(JVREF.CED_NF, ACCG.CED_NF) 
 
 WHERE JVREF.JVTRNCOD_CF IS NOT NULL


-- Y a t'il eu une erreur lors de l'exécution de l'update ? --
SELECT @erreur = @@error
IF @erreur != 0
BEGIN
   SELECT @errmsg = "LOC=200; ERROR ON UPDATE BTRAV..CPT_EDI_CPJJ1000_TEDIACCD"
      GOTO err
END

-- --------------------------------- --
-- CLM Inversion des postes  [001] 
-- --------------------------------- --

 UPDATE BTRAV..CPT_EDI_CPJJ1000_TEDICLMD
 SET AMT_M =  CASE 
 						WHEN JVREF.SENS_CF = "D" THEN  CLMD.AMT_M * -1 ELSE CLMD.AMT_M 
			   END
 FROM 		BTRAV..CPT_EDI_CPJJ1000_TEDICLMG CLMG 
 INNER JOIN BTRAV..CPT_EDI_CPJJ1000_TEDICLMD CLMD
 ON 	CLMG.EDI_CF    = CLMD.EDI_CF
 AND 	CLMG.RECORD_NF = CLMD.RECORD_NF
 AND 	CLMG.EDI_CF = 'JVE'
 
 INNER JOIN BCTA..TEDICMCODEJVREF JVREF
 ON  CLMD.JVTRNCOD_CF = ISNULL(JVREF.JVTRNCOD_CF, CLMD.JVTRNCOD_CF)
 AND CLMD.TRNCOD_CF   = ISNULL(JVREF.TRNCOD_CF 	, CLMD.TRNCOD_CF)
 AND CLMG.CED_NF  	  = ISNULL(JVREF.CED_NF 	, CLMG.CED_NF) 
 
 WHERE JVREF.JVTRNCOD_CF IS NOT NULL


-- Y a t'il eu une erreur lors de l'exécution de l'update ? --
SELECT @erreur = @@error
IF @erreur != 0
BEGIN
   SELECT @errmsg = "LOC=200; ERROR ON UPDATE BTRAV..CPT_EDI_CPJJ1000_TEDICLMD"
      GOTO err
END

-- Tout s'est correctement déroulé ! Allez hop, commit !
COMMIT TRAN
RETURN 0

-- ------ --
-- Erreur --
-- ------ --
err:
   /*Si Pb alors on annule la transaction*/
   raiserror 20000 "ERREUR PROC PuTEDI_SensPostes_01" /* erreur de modification */
   ROLLBACK TRANSACTION
   return @erreur
END
GO
EXEC sp_procxmode 'PuTEDI_SensPostes_01','unchained'
GO
IF OBJECT_ID('PuTEDI_SensPostes_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PuTEDI_SensPostes_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PuTEDI_SensPostes_01 >>>'
GO
GRANT EXECUTE ON PuTEDI_SensPostes_01 TO GOMEGA
GO
