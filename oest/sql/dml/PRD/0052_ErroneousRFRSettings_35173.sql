--
-- Remove erroneous RFR settings
--
USE BREF
go
DELETE BREF..TSUBTRSESBPROP where SUBTRS_CF IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
go
