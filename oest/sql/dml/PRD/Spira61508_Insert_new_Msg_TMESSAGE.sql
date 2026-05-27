-- DEFECT 61508 Insert new msgs 20041, 20042, 20043
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

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 20041,
	"Ledger unthorized to load local AE",
	"Ledger non autorisée à charger des ES locales",
	0, 0
PRINT "Message ESTIMATION#20041"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 20042,
	"Transaction code not authorized for local adjustments.",
	"Le code de transaction n'est pas autorisé pour les ajustements locaux.",
	0, 0
PRINT "Message ESTIMATION#20042"


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 20043,
	"Local entry nature not conformed",
	"La nature de ES locale n'est pas conforme",
	0, 0
PRINT "Message ESTIMATION#20043"

GO

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 20044,
	"Incorrect Validity date",
	"Date de validité incorrecte ",
	0, 0
PRINT "Message ESTIMATION#20044"

GO
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 20045,
	"Incorrect Accounting Period",
	"Periode comptable incorrecte ",
	0, 0
PRINT "Message ESTIMATION#20045"

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
