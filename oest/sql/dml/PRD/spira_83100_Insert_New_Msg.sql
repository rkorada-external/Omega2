--DEFECT 83100 insert Error messages

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

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 991,
	"Target and Origin GAAP should be filled before saving",
	"Le GAAP source et cible sont obligatoires",
	0, 0
PRINT "Message ESTIMATION#991"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 992,
	"Target and Origin Grouping should be filled before saving",
	"Le regroupement source et cible sont obligatoires",
	0, 0
PRINT "Message ESTIMATION#992"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 993,
	"Start date is mandatory",
	"La date de début est obligatoire",
	0, 0
PRINT "Message ESTIMATION#993"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 994,
	"Start date should be equal or after today's date",
	"La date de début doit être supérieure ou égale à la date d'aujourd'hui",
	0, 0
PRINT "Message ESTIMATION#994"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 995,
	"The entered Grouping code does not exist for selected GAAP",
	"Le code de regroupement saisi n'existe pas pour le GAAP selectionné",
	0, 0
PRINT "Message ESTIMATION#995"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 996,
	"The entered Transaction code does not exist for selected GAAP and Grouping code",
	"Le poste saisi n'existe pas pour le GAAP et le regroupement selectionnés",
	0, 0
PRINT "Message ESTIMATION#996"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 997,
	"End date should be equal or after Start date",
	"La date de fin doit être supérieure ou égale à la date de début",
	0, 0
PRINT "Message ESTIMATION#997"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 998,
	"Target Transaction code should be filled before saving",
	"Le Poste comptable cible est obligatoire",
	0, 0
PRINT "Message ESTIMATION#998"
exec bref..PiMESSAGE_02_O2 'ESTIMATION', 999,
	"GAAP Transaction mapping not allowed.~r~nThere is already an existing mapping! §",
	"Demande impossible.~r~nUn GAAP Transaction mapping existe déjà ! §",
	0, 0
PRINT "Message ESTIMATION#999"
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