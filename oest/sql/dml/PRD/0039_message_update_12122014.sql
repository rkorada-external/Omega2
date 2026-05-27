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


exec bref..PiMESSAGE_02_O2 'CTA', 30136,
     "For Life treaties, contract must be cancelled through the Treaty menus.",
     "Pour les traités Vie, l'annulation doit se faire via les menus de Traités.", 
     0, 0
PRINT "Message CTA#30136"


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