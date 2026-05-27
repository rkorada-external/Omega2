USE BTEC
go

-- ------------------------------------------------------------------------------------
-- Script           : EST106616_INSERT_TFILSUP.sql
-- Domaine          : EST
-- Base Principale  : BTEC
-- :spira						: 106616
-- -------------------------------------------------------------------------------------


BEGIN TRAN
--SET flushmessage ON

DECLARE @erreur         int

PRINT ' '
PRINT 'DEBUT'

-- --------------------- --
-- Début des traitements --    
-- --------------------- --

insert into BTEC..TFILSUP values('3820DUMG', 212,       'USA1')
insert into BTEC..TFILSUP values('3820DUMG', 211,       'FRA1')
insert into BTEC..TFILSUP values('3820DUMG', 210,       'SGP1')

insert into BTEC..TFILSUP values('3820DUMS', 666,       'USA1')
insert into BTEC..TFILSUP values('3820DUMS', 667,       'FRA1')
insert into BTEC..TFILSUP values('3820DUMS', 668,       'SGP1')
 
SELECT @erreur = @@error
	IF @erreur != 0
  	BEGIN
    	PRINT 'BTEC..TFILSUP - INSERT FAILED - ERREUR : %1!',@erreur
      ROLLBACK TRAN
		END
		
select * from BTEC..TFILSUP where DOM_Cf like '%3820%'

-- ------------------- --
-- Fin transaction     --
-- ------------------- --
COMMIT TRAN
--ROLLBACK TRAN
GO