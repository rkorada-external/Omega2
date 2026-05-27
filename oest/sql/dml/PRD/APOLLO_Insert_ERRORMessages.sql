-- USE BREF

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

----------------------------EXAMPLE--------------------
/*
exec bref..PiMESSAGE_02_O2 'APPLICATIF', 20114,
	"§ error(s) detected. Transaction §/§ is not eligible because his type is PWA.",
	"$ erreur(s) détectée(s). La transaction $/$ n'est pas eligible car elle est de type RSA.", 
	0, 0
PRINT "Message APPLICATIF#20114"
*/

----------------------------START--------------------


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30100,
	"Inconsistency: between Import file and Type file",
	"Incohérence entre type sélectionné et fichier importé",
	0, 0
PRINT "Message ESTIMATION#30100"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30101,
	"An ERROR has occurred in Row '§' : '§'.",
	"ERREUR ligne '§' : '§'.",
	0, 0
PRINT "Message ESTIMATION#30101"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30102,
	"Duplicate Row Line'§' and Line '§'.",
	"Duplicate Row Line'§' and Line '§'.",
	0, 0
PRINT "Message ESTIMATION#30102"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 139,
	"CF quater must be >= closing date",
	"Trim CF doit etre >= Date Closing",
	0, 0
PRINT "Message ESTIMATION#30102"




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
