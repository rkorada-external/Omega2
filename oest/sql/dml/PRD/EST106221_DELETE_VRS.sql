USE BEST
GO

-- --------------------------------------------------------------------------------------------- --
-- Script           : EST106221_DELETE_VRS_TSEGEST_TSEGMENT_TVERSION.sql
-- Domaine          : EST
-- Auteur           : F.DEGONZAGUE
-- Date de création : 08/10/2022
-- Spira/comment    : SUPPORT REQUEST VERSION IN ANOMALY
-- --------------------------------------------------------------------------------------------- --


BEGIN TRAN
--SET flushmessage ON

DECLARE @erreur         int

PRINT ' '
PRINT 'DEBUT'

-- --------------------- --
-- Début des traitements --    
-- --------------------- --


select * from BEST..TSEGEST 
	WHERE VRS_NF = 108 and SSD_CF = 17	  
  

DELETE BEST..TSEGEST 
	WHERE VRS_NF = 108 and SSD_CF = 17	  
        
SELECT @erreur = @@error
	IF @erreur != 0
  	BEGIN
    	PRINT 'BEST..TSEGEST - DELETE FAILED - ERREUR : %1!',@erreur
      ROLLBACK TRAN
		END

select * from BEST..TSEGEST 
	WHERE VRS_NF = 108 and SSD_CF = 17	  
  
--------------------------------------------------------------

select * from BEST..TSEGMENT 
	WHERE VRS_NF = 108 and SSD_CF = 17	   

DELETE BEST..TSEGMENT 
	WHERE VRS_NF = 108 and SSD_CF = 17	  
  
        
SELECT @erreur = @@error
	IF @erreur != 0
  	BEGIN
    	PRINT 'BEST..TSEGMENT - DELETE FAILED - ERREUR : %1!',@erreur
      ROLLBACK TRAN
		END

select * from BEST..TSEGMENT 
	WHERE VRS_NF = 108 and SSD_CF = 17	  

	
--------------------------------------------------------------

select * from BEST..TVERSION 
	WHERE VRS_NF = 108 and SSD_CF = 17	  
 

DELETE BEST..TVERSION 
	WHERE VRS_NF = 108 and SSD_CF = 17	  

        
SELECT @erreur = @@error
	IF @erreur != 0
  	BEGIN
    	PRINT 'BEST..TVERSION - DELETE FAILED - ERREUR : %1!',@erreur
      ROLLBACK TRAN
		END

select * from BEST..TVERSION 
	WHERE VRS_NF = 108 and SSD_CF = 17	  

-- ------------------- --
-- Fin transaction     --
-- ------------------- --
COMMIT TRAN
--ROLLBACK TRAN
GO