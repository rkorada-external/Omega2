USE BREF
go

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
PRINT "DELLETE MESSAGE IF EXIST (21030,21031,21032,21033,21050,21000,21001)"
DELETE FROM BREF..TMESSAGE WHERE MESS_N IN(21030,21031,21032,21033,21050,21000,21001)
GO

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21030,
     "The assumed event does not exists.",
     "L'événement acceptation n'existe pas.", 
     0, 0
PRINT "Message ESTIMATION#21030"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21031,
     "The assumed event does not correspond to the Assumed single Claim.",
     "L'événement acceptation ne correspond pas au sinistre individuel Acceptation.", 
     0, 0
PRINT "Message ESTIMATION#21031"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21032,
     "The assumed event does not correspond to the Assumed single Claim.",
     "L'événement acceptation ne correspond pas au sinistre individuel Acceptation.", 
     0, 0
PRINT "Message ESTIMATION#21032"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21033,
     "The retro event does not correspond to the Retro single Claim.",
     "L'événement retro ne correspond pas au sinistre individuel Retrocession.", 
     0, 0
PRINT "Message ESTIMATION#21033"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21050,
     "This Event is not valid for this Claim.",
     "Cet événement ne correspond pas à ce Sinistre.", 
     0, 0
PRINT "Message ESTIMATION#21050"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21000,
     "This underwriting year is not bookable.",
     "Cette année d'exercice n'est pas comptabilisable.", 
     0, 0
PRINT "Message ESTIMATION#21000"

exec bref..PiMESSAGE_02_O2 'ESTIMATION', 21001,
     "AE Cat Cover requests screen is read-only during the day of technical booking.",
     "Cette année d'exercice n'est pas comptabilisable.", 
     0, 0
PRINT "Message ESTIMATION#21001"

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