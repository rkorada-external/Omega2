-- DEFECT 89188 Insert new msgs 30132 - 30137
--Auther : S.Behague

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

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30132,
	"SAS AE Type: Expected value 8 or 9 for SAS AE",
	"SAS ES Type: valeur attendue 8 ou 9 pour les SAS ES",
	1, 0
PRINT "Message ESTIMATION#30132"


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30133,
	"SAS AE Currency: must be equal to main currency of the section",
	"SAS ES Devise: doit etre egale a la principale devise de la section",
	1, 0
PRINT "Message ESTIMATION#30133"


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30134,
	"SAS AE Currency: must be equal to  currency of the Retro treaty",
	"SAS ES Devise:doit etre egale a la devise du traite Retro",
	1, 0
PRINT "Message ESTIMATION#30134"


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30135,
	"SAS 17 AE: beginning accounting period should be >= balance sheet month",
	"SAS I17 ES: : debut periode Scor doit etre >= mois bilan",
	1, 0
PRINT "Message ESTIMATION#30135"


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30136,
	"SAS I17 AE: End accounting period should be between the beginning and the end of balance sheet quarter",
	"SAS I17 ES: : fin periode Scor doit etre comprise entre le debut et la fin du trimestre bilan ",
	1, 0
PRINT "Message ESTIMATION#30136"


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30137,
	"SAS AE TC:  suffix I,J,K,L,M,N are allowed",
	"SAS ES TC: suffixes I,J,K,L,M,N autorises",
	1, 0
PRINT "Message ESTIMATION#30137"


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
