/********************************************************
Author		:	Bhimasen K
Date		:	21/10/2024
Domain		:	Estimation
Description :	Adding two new columns in the segmentation type table to handle the Retro NP in the segementation process
*********************************************************/

USE BEST
go

if exists (select 1 from syscolumns where id = object_id("TSEGTYPE") and name = "RTY_NF")
begin
	PRINT '<<< COLUMN RTY_NF ALREADY EXISTS >>>'
end
else
begin
	exec ("ALTER TABLE TSEGTYPE ADD RTY_NF UUWY_NF NULL")
	PRINT '<<< COLUMN RTY_NF ADDED ON BEST..TSEGTYPE >>>'
end
go 

if exists (select 1 from syscolumns where id = object_id("TSEGTYPE") and name = "SGTTYPMOD_NT")
begin
	PRINT '<<< COLUMN SGTTYPMOD_NT ALREADY EXISTS >>>'
end
else
begin
	exec ("ALTER TABLE TSEGTYPE ADD SGTTYPMOD_NT tinyint  default 0 NOT NULL")
	PRINT '<<< COLUMN SGTTYPMOD_NT ADDED ON BEST..TSEGTYPE >>>'
end
go 
