/*
* This script is used to add column to TSEGMENTRULE Table 
* SEG US - 4529
* Date:- 05/02/2025
* Author :- Pooja Yelve
*/


USE BEST
go

if exists (select 1 from syscolumns where id = object_id("TSEGMENTRULE") and name = "CMT_NT")
begin
	PRINT '<<< COLUMN CMT_NT ALREADY EXISTS >>>'
end
else
begin
	exec ("ALTER TABLE TSEGMENTRULE ADD CMT_NT  int default (0) NOT NULL")
	PRINT '<<< COLUMN CMT_NT ADDED ON BEST..TSEGMENTRULE >>>'
end
go
