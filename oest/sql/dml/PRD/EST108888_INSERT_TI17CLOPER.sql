USE BEST
go

-- --------------------------------------------------------------------------------------------- --
-- Script           : EST108888_INSERT_TI17CLOPER .sql
-- Domaine          : est
-- Base Principale  : BEST    
-- Auteur           : J. BOnneau-Dillon
-- Date de création : 07/03/2023
-- --------------------------------------------------------------------------------------------- --


BEGIN TRAN

DECLARE @erreur	int



-- Insertion dans TI17CLOPER.
INSERT INTO BEST..TI17CLOPER  ( SSD_CF, ESB_CF, PARM1, PARM2, PARM3 ) 
        VALUES (1, 7, '0', '0', '0')

SELECT @erreur = @@error
	IF @erreur != 0
  	BEGIN
    	PRINT 'BEST..TI17CLOPER - Insert FAILED - ERREUR : %1!',@erreur
      ROLLBACK TRAN
      GOTO fin
		END


INSERT INTO BEST..TI17CLOPER  ( SSD_CF, ESB_CF, PARM1, PARM2, PARM3 ) 
        VALUES (2, 5, '0', '0', '0')

SELECT @erreur = @@error
	IF @erreur != 0
  	BEGIN
    	PRINT 'BEST..TI17CLOPER - Insert FAILED - ERREUR : %1!',@erreur
      ROLLBACK TRAN
      GOTO fin
		END


SELECT * FROM BEST..TI17CLOPER WHERE (SSD_CF = 1 AND ESB_CF = 7) OR (SSD_CF = 2 AND ESB_CF = 5)

  
-- ------------------- --
-- Fin transaction     --
-- ------------------- --
COMMIT TRAN
-- ROLLBACK TRAN

fin:
PRINT 'End error	'
GO