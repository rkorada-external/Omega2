USE BREF

GO

SET NOCOUNT ON

-- ---------------- --
-- Define variables --
-- ---------------- --
DECLARE @msg		VARCHAR(100)
		

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

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21011,
     "The corresponding assistance entry Cat Cover request cannot be found.",
     "La demande d'écriture service Cat cover à mettre à jour est introuvable.", 
     0, 0
PRINT "Message ESTIMATION#21011"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21012,
     "Duplicated row found in the DB.",
     "Entrée en double dans la base de donnée.", 
     0, 0
PRINT "Message ESTIMATION#21012"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21013,
     "The Grouping code is invalid for Cat Cover.",
     "Le poste de regroupement n'est pas valide pour les couvertures catastrophes.", 
     0, 0
PRINT "Message ESTIMATION#21013"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21014,
     "Duplicated row found in the input file.",
     "Entrée en double dans la fichier chargé.", 
     0, 0
PRINT "Message ESTIMATION#21014"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21015,
     "Invalid Claim Number.",
     "Le numéro de sinistre est invalide.", 
     0, 0
PRINT "Message ESTIMATION#21015"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21016,
     "Unable to update on this Closing period.",
     "Impossible d'éditer sur cette période de Clôture.", 
     0, 0
PRINT "Message ESTIMATION#21016"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21017,
     "Ledger does not correspond between screen and file.",
     "La filiale ne correspond pas entre l'écran et le fichier.", 
     0, 0
PRINT "Message ESTIMATION#21017"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21018,
     "Ledger does not correspond between file and DB.",
     "La filiale ne correspond pas entre le fichier et la base.", 
     0, 0
PRINT "Message ESTIMATION#21018"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21019,
     "Currency is the wrong one.",
     "La devise ne correspond pas.", 
     0, 0
PRINT "Message ESTIMATION#21019"

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