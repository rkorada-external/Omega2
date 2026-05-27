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

----------------------------EXAMPLE--------------------
/*
exec bref..PiMESSAGE_02_O2 'APPLICATIF', 20114,
	"§ error(s) detected. Transaction §/§ is not eligible because his type is PWA.",
	"$ erreur(s) détectée(s). La transaction $/$ n’est pas eligible car elle est de type RSA.", 
	0, 0
PRINT "Message APPLICATIF#20114"
*/

----------------------------START--------------------


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30013,
     "The contract is a retrocession and it is closed at contract/underwriting year level",
     "Le contrat est de type retrocession  et il est «terminé » au niveau du contrat/exercice", 
     0, 0
PRINT "Message ESTIMATION#30013"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30012,
     "The list of non-closed UWYs is empty",
     "La liste des exercices « non-terminé » est vide", 
     0, 0
PRINT "Message ESTIMATION#30012"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30014,
     "Unable to load estimates on closed retrocessions.",
     "Impossible de charger des estimations sur des rétrocessions terminées.", 
     0, 0
PRINT "Message ESTIMATION#30014"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 30015,
     "The contract/underwriting year is closed",
     "Le contrat/Exercice est 'Terminé'", 
     0, 0
PRINT "Message ESTIMATION#30015"


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
