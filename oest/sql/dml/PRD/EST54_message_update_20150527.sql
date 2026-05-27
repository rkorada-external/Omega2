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
	"Â§ error(s) detected. Transaction Â§/Â§ is not eligible because his type is PWA.",
	"$ erreur(s) dÃ©tectÃ©e(s). La transaction $/$ nâ€™est pas eligible car elle est de type RSA.", 
	0, 0
PRINT "Message APPLICATIF#20114"
*/

----------------------------START--------------------


exec bref..PiMESSAGE_02_O2 'REFERENCES', 30057,
     "Retrocession Account Freeze Start date must be less or equal to the End of exceptional period",
     "la date de Début gèle des comptes retrocessions doit être inférieur ou égale à la date de fin de période exceptionnel", 
     0, 0
PRINT "Message REFERENCES#30057"

exec bref..PiMESSAGE_02_O2 'REFERENCES', 30058,
     "Retrocession Account Freeze End date must be greater or equal to the technical booking",
     "la date de Fin gèle des comptes retrocessions doit être supérieur ou égale à la date de comptabilité technique", 
     0, 0
PRINT "Message REFERENCES#30058"

exec bref..PiMESSAGE_02_O2 'REFERENCES', 30059,
     "Mandatory Closing option must be ticked for this month",
     'La coche "Closing Obligatoire" doit être coché pour le mois selectionné',
     0, 0
PRINT "Message REFERENCES#30059"

exec bref..PiMESSAGE_02_O2 'REFERENCES', 30060,
     "Mandatory Closing option must not be ticked for this month",
     'La coche "Closing Obligatoire" ne doit pas être coché pour le mois selectionné', 
     0, 0
PRINT "Message REFERENCES#30060"

exec bref..PiMESSAGE_02_O2 'REFERENCES', 30061,
     "Retrocession Account Freeze Start date must be less or equal to the Retrocession Account Freeze End date",
     "la date de Début gèle des comptes retrocessions doit être inférieur ou égale à la date de fin de gèle des comptes retrocessions", 
     0, 0
PRINT "Message REFERENCES#30061"


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