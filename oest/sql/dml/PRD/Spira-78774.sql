-------------------------
-- Spira 78774 - Begin --
-------------------------

---------------------------------------------------------------------
-- Update data type of TRNCOD_Cf clumn of BEST..TCASHFLOWADJ table --
-- old type est : UDETTRS_CF <--> char(8), new type est : char(5)  --
---------------------------------------------------------------------
USE BEST
GO

ALTER TABLE TCASHFLOWADJ
MODIFY TRNCOD_CF char(5) not null
GO

-------------------------------------------------------------------------
-- Update data type of TRNCOD_Cf clumn of EST_ESID0891_PERIMETER table --
-- old type est : UDETTRS_CF <--> char(8), new type est : char(5)      --
-------------------------------------------------------------------------
USE BTRAV
GO

ALTER TABLE EST_ESID0891_PERIMETER
MODIFY TRNCOD_CF char(5) not null
GO

-----------------------
-- Spira 78774 - End --
-----------------------