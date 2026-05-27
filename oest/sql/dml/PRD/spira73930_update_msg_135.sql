-- DEFECT 73930 Update message 135
--OLd message : Unable to load estimates on treaties ended. / Impossible de charger des estimations sur des traités terminés.
-- New Message : Unable to load estimates on treaties ended and NTU / Impossible de charger des estimations sur des traités terminés et sans suite
--Auther : Riyadh

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

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 135,
	"Unable to load estimates on treaties ended, understudy and NTU",
	"Impossible de charger des estimations sur des traités terminés, provisoire et sans suite",
	0, 0
PRINT "Message ESTIMATION#135"
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
