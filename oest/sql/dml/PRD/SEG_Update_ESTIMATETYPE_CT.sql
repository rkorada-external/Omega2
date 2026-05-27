use BEST
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


-- --------------------------------------------------------------------------------------------- --
-- Script           : SEG_Update_ESTIMATETYPE_CT.sql
-- Domain           : SEG
-- Main Database    : BEST
-- Creation date    : 2016.03.02
-- Description      : Update ESTIMATETYPE_CT to ESTCRB_CT
-- --------------------------------------------------------------------------------------------- --

----------------------------START--------------------
PRINT "Update ESTIMATETYPE_CT to ESTCRB_CT"
begin tran

update BEST..TSEGCRITERIA  set SGTCRIPAR_LS='ESTCRB_CT'  where SGTCRIPAR_LS='ESTIMATETYPE_CT'

commit tran
PRINT "PROCESS COMPLETED"
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