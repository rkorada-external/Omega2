--DEFECT 84455 insert Error messages

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

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 2061,
	"Planned date is out of IFRS 4 closing period for selected closing date",
	"La date planifiee est en dehors de la periode de closing IFRS 4",
	1, 0
PRINT "Message REFERENCES#2061"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 2062,
	"Planned date is out of EBS closing period for selected closing date",
	"La date planifiee est en dehors de la periode de closing EBS",
	1, 0
PRINT "Message REFERENCES#2062"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 2063,
	"Micro AOC can not be created on booking or POS IFRS17 End date",
	"Impossible de creer une demande Micro AOC le jour de la comptabilisation ou le jour de fin du POS IFRS17",
	1, 0
PRINT "Message REFERENCES#2063"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 2064,
	"Planned date is out of SAP closing period for selected closing date",
	"La date planifiee est en dehors de la periode de closing SAP",
	1, 0
PRINT "Message REFERENCES#2064"


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