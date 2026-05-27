/***************************************************
Domain            : Estimate
Base              : BREF
Author            : L. Wernert 
Creation date     : 24/04/2020
Spira							: 82192
Description       : New messages for technical controls
*****************************************************/

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

/**** START ****/

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30117,
	"(Assumed or Retro) Contract number is missing",
	"Le contrat (Acceptation ou Retro) est manquant",
	1, 0
PRINT "Message ESTIMATION#30117"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30118,
	"Treaty Assumed Section is missing",
	"Le No de Section du Traite d Acceptation est manquant",
	1, 0
PRINT "Message ESTIMATION#30118"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30119,
	"Treaty Retrocession Section is missing",
	"Le No de Section du Traite de Retrocession est manquant",
	1, 0
PRINT "Message ESTIMATION#30119"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30120,
	"Assumed Treaty U/W Year is missing",
	"Exercice Acceptation est manquant",
	1, 0
PRINT "Message ESTIMATION#30120"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30129,
	"Retro U/W Year is missing",
	"Exercice Retro est manquant",
	1, 0
PRINT "Message ESTIMATION#30129"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30122,
	"Accounting Month is missing",
	"mois de compte est manquant",
	1, 0
PRINT "Message ESTIMATION#30112"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30123,
	"Accounting Month must be equal to 3,6,9,12,13",
	"Le mois de compte doit etre egal à 3,6,9,12,13",
	1, 0
PRINT "Message ESTIMATION#30123"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30121,
	"Accounting Year is missing",
	"Annee de compte est manquante",
	1, 0
PRINT "Message ESTIMATION#30121"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30124,
	"Currency is missing",
	"La Devise est manquante",
	1, 0
PRINT "Message ESTIMATION#30124"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30131,
	"Transaction Code must be on 5 digits",
	"Le poste comptable doit etre sur 5 chiffres",
	1, 0
PRINT "Message ESTIMATION#30131"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30125,
	"GAAP number is missing",
	"Le numero de GAAP est manquant",
	1, 0
PRINT "Message ESTIMATION#30125"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30126,
	"GAAP number must be between 1 and 5",
	"Le numero de GAAP doit etre compris entre 1 et 5",
	1, 0
PRINT "Message ESTIMATION#30126"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30127,
	"Amount is missing",
	"Le montant est obligatoire",
	1, 0
PRINT "Message ESTIMATION#30127"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30128,
	"The Amount must be a decimal (18 digits including 3 digits after comma)",
	"Le montant doit etre un decimal (18 car. dont 3 apres virgule)",
	1, 0
PRINT "Message ESTIMATION#30118"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30130,
	"Assumed amount is missing ",
	"Montant d acceptation est manquant",
	1, 0
PRINT "Message ESTIMATION#30130"



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