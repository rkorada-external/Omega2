USE BREF

GO

SET NOCOUNT ON

-- ---------------- --
-- Define variables --
-- ---------------- --
DECLARE @msg		VARCHAR(100),
		@mess_l		VARCHAR(200),
		@messthm_c	VARCHAR(12),
		@mess_n		INT
		
/*************************************
Spira : 94401
Old message : Transaction code is unauthorized/Poste comptable non autorise
New message : TC forbidden for NonLife Ledger/PC non autorise pour Ets Non Vie
Author : Karri Bhimasen
**************************************/

-- -------------------- --
-- Initialize variables --
-- -------------------- --
SELECT @msg=@@servername + ' => ' + host_name()
                         + ' Start omega_messages '
                         + CONVERT(CHAR(9), GETDATE(), 6) + ' '
                         + CONVERT(CHAR(8), GETDATE(), 8) + ' '
                         + SUBSTRING(CONVERT(CHAR(27), GETDATE(), 109), 21, 4)
PRINT @msg

SET NOCOUNT OFF
GO

SET FLUSHMESSAGE ON


----------------------------START--------------------


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21036,
     "TC forbidden for NonLife Ledger",
     "PC non autorise pour Ets Non Vie", 
     1, 0
PRINT "Message ESTIMATION#21036"

----------------------------END----------------------
GO

SET NOCOUNT ON

-- ---------------- --
-- Define variables --
-- ---------------- --
DECLARE @msg   VARCHAR(100)

-- -------------------- --
-- Initialize variables --
-- -------------------- --
SELECT @msg=@@servername + ' => ' + host_name()
                         + ' End omega_messages '
                         + CONVERT(CHAR(9), GETDATE(), 6) + ' '
                         + CONVERT(CHAR(8), GETDATE(), 8) + ' '
                         + SUBSTRING(CONVERT(CHAR(27), GETDATE(), 109), 21, 4)
PRINT @msg

SET NOCOUNT OFF
GO

