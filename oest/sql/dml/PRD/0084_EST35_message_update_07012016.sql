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


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 5024,
     "Rates must be less than 100%",
     "Le taux doit être inférieur à 100%", 
     0, 0
PRINT "Message ESTIMATION#5024"


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 5025,
     "Rates must be positive",
     "Le taux doit être positif", 
     0, 0
PRINT "Message ESTIMATION#5025"


exec bref..PiMESSAGE_02_O2 'ESTIMATION', 5026,
     "The accumulation transaction code is not authorized in this grid",
     "Le poste cumul n'est pas autorisé dans cette grille", 
     0, 0
PRINT "Message ESTIMATION#5026"



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