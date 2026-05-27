--DEFECT 85163 insert Error messages

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

exec bref..PiMESSAGE_02_O2 'REFERENCES', 20000,
	"§ should be equal or after today's date",
	"La § doit etre superieure ou egale a la date d aujourd hui",
	0, 0
PRINT "Message REFERENCES#20000"
exec bref..PiMESSAGE_02_O2 'REFERENCES', 20001,
	"End date should be equal or after Start date",
	"La date de fin doit etre superieure ou egale a la date de debut",
	0, 0
PRINT "Message REFERENCES#20001"
exec bref..PiMESSAGE_02_O2 'REFERENCES', 20002,
	"GAAP Transaction mapping not allowed. There is already an existing mapping !",
	"Demande impossible. Une regle de mapping existe déjà  !",
	1, 0
PRINT "Message REFERENCES#20002"

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