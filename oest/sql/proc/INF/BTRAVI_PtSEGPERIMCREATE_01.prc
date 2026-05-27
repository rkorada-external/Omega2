USE BTRAVI
go
IF OBJECT_ID('dbo.PtSEGPERIMCREATE_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtSEGPERIMCREATE_01
    IF OBJECT_ID('dbo.PtSEGPERIMCREATE_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtSEGPERIMCREATE_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtSEGPERIMCREATE_01 >>>'
END
go
Create procedure dbo.PtSEGPERIMCREATE_01(@sgtuwtabCf varchar(16), @sgtscopeCt varchar(5), @prdsitCf varchar(4)) as

set nocount on

/***************************************************
Program:  PtSEGPERIMCREATE_01
File script : BTRAVI_PtSEGPERIMCREATE_01.prc
Main database : BTRAVI
Version: 1
Author: GGU
Creation date: 06/08/2013
Description:
	Retrieve columns from TSEGUWCOLUMN related to the table name given as parameter
	and also generates column to store result of segmentation (available segmentations + levels)
	Then create the new perimeter table with a _TMP extension
	This table will contains the new perimeter. The old one will be removed once 
	this one will be populated. Then the _TMP table will be renamed
	
Parameters:
	- @sgtuwtabCf: Table name
	- @sgtscopeCt: Perimeter scope
	- @prdsitCf: Current production site
	
Conditions:

Comments:


Modification 001
Author: Parth
Date: 	01/03/2018
SPIRA 67666 :- Increase size of variable @query.

Modification 002
Author: Bhimasen
Date: 	27/11/2024
US 4164 :- Increase size of variable @query.
**********************************************************************/

-- variable used to describe columns
declare @columnName UL16
declare @columnType char(32)
declare @columnPrecision int
declare @columnScale int
declare @columnLength int
declare @columnUserType int
declare @columnSegTypeId int
declare @columnSegLvl int

-- error variable used for cursor
declare @erreur int
select @erreur = 0

-- build the query
declare @query varchar(16384)

-- drop the temporary table if already exists
if object_id(@sgtuwtabCf + "_" + @prdsitCf + "_TMP") is not null
    begin
        select @query = "drop table BTRAVI.." + @sgtuwtabCf + "_" + @prdsitCf + "_TMP"
        execute (@query)
    end

-- start the create table query
select @query = "create table BTRAVI.." + @sgtuwtabCf + "_" + @prdsitCf + "_TMP ("

-- 
-- CRITERIA COLUMNS
-- 
	
-- select columns to create the perimeter table 
declare criteria_cursor cursor for
	select c.SGTUWCOL_CF, c.SGTUWTYP_CT, c.SGTUWSCA_NB, c.SGTUWPRE_NB, c.SGTUWLEN_NB, st.usertype as usertype
    from BEST..TSEGUWCOLUMN c
	inner join BEST..systypes st on c.SGTUWTYP_CT = st.name
	where c.SGTUWTAB_CF = @sgtuwtabCf
	order by c.SGTUWORDER_NB asc
	
open criteria_cursor

-- For each columns, build the final query string
fetch criteria_cursor into @columnName, @columnType, @columnScale, @columnPrecision, @columnLength, @columnUserType
while (@@sqlstatus = 0)
    begin
        -- If it's a custom user type
        if (@columnUserType > 80)
            begin
                select @query = @query + ltrim(rtrim(@columnName)) + " " + ltrim(rtrim(@columnType)) + " null, "
            end
        else
            begin
                -- depending on the column type => append to the query with the right declaration
                -- for char or varchar
                if (@columnUserType = 1 or @columnUserType = 2)
                    begin
                        select @query = @query + ltrim(rtrim(@columnName)) + " " + 
                            ltrim(rtrim(@columnType)) + "(" + ltrim(rtrim(str(@columnLength))) + ") null, " 
                    end
                -- for decimal type
                else if (@columnUserType = 26)
                    begin
                        select @query = @query + ltrim(rtrim(@columnName)) + " " + 
                            ltrim(rtrim(@columnType)) + "(" + str(@columnPrecision) + ", " + ltrim(rtrim(str(@columnScale))) + ") null, "
                    end
                -- for boolean data, can't be null, init to 0
                else if (@columnUserType = 16)
                    begin
                        select @query = @query + ltrim(rtrim(@columnName)) + " " + ltrim(rtrim(@columnType)) + " default 0, "
                    end
                -- for other data type (int, tinyint, smallint, datetime)
                else 
                    begin
                        select @query = @query + ltrim(rtrim(@columnName)) + " " + ltrim(rtrim(@columnType)) + " null, "
                    end
            end
            
        fetch criteria_cursor into @columnName, @columnType, @columnScale, @columnPrecision, @columnLength, @columnUserType
    end

close criteria_cursor
	
select @query = substring(@query, 1, len(@query) - 2)	

-- 
-- RESULT COLUMNS
-- 	
	
-- Select all available segmentations and levels to generate results columns
declare seg_cursor cursor for
	select distinct s.sgttyp_nt, l.sgtlvl_ct
		from BEST..TSEGMENTATION s
		inner join BEST..TSEGMENTLVL l on l.sgt_nt = s.sgt_nt and l.sgtver_nt = s.sgtver_nt
		inner join BEST..TSEGTYPE t on t.sgttyp_nt = s.sgttyp_nt
		where s.sgtsts_cf = '3' and t.SGTTYPSTS_CT = '1' and t.SGTSCOPE_CT in ('3', @sgtscopeCt)
		order by s.sgttyp_nt asc, l.sgtlvl_ct asc

open seg_cursor

-- For each column, build the query string for segment IDs
fetch seg_cursor into @columnSegTypeId, @columnSegLvl
while (@@sqlstatus = 0)
    begin
		select @query = @query + ", SEG_" + ltrim(str(@columnSegTypeId)) + "_LVL_" + ltrim(str(@columnSegLvl)) + " int null "  
        fetch seg_cursor into @columnSegTypeId, @columnSegLvl
    end

close seg_cursor
open seg_cursor

-- For each column, build the query string for segment labels
fetch seg_cursor into @columnSegTypeId, @columnSegLvl
while (@@sqlstatus = 0)
    begin
		select @query = @query + ", SEG_LABEL_" + ltrim(str(@columnSegTypeId)) + "_LVL_" + ltrim(str(@columnSegLvl)) + " UL16 null "  
        fetch seg_cursor into @columnSegTypeId, @columnSegLvl
    end

close seg_cursor

-- Use datapages lock in order to avoid variable-length columns limit of 254
select @query = @query + ") lock datapages"

-- execute the query
execute (@query)

-- Add rights
select @query = "grant all on " + @sgtuwtabCf + "_" + @prdsitCf + "_TMP to GOMEGA"
execute (@query)
select @query = "grant select on " + @sgtuwtabCf + "_" + @prdsitCf + "_TMP to GCONSULT"
execute (@query)

-- create the index
-- Removed - may have several rows having the same contract section id
--if @sgtscopeCt = '1'
--	begin
--	select @query = "CREATE UNIQUE CLUSTERED INDEX I" + @sgtuwtabCf + "_" + @prdsitCf + "_TMP_00 ON BTRAVI.."+ @sgtuwtabCf + "_" + @prdsitCf +"_TMP(CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF)"
--	execute (@query)	
--end
--else if @sgtscopeCt = '2'
--	begin
--	select @query = "CREATE UNIQUE CLUSTERED INDEX I" + @sgtuwtabCf + "_" + @prdsitCf + "_TMP_00 ON BTRAVI.."+ @sgtuwtabCf + "_" + @prdsitCf +"_TMP(CTR_NF, UWY_NF, RTO_NF)"
--	execute (@query)
--end
	
select @erreur = @@error
if @erreur != 0
begin
    raiserror 20005 "20005 ; ERROR Final create table; "
    return 1
end


return 0
go
EXEC sp_procxmode 'dbo.PtSEGPERIMCREATE_01', 'unchained'
go
IF OBJECT_ID('dbo.PtSEGPERIMCREATE_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtSEGPERIMCREATE_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtSEGPERIMCREATE_01 >>>'
go
GRANT EXECUTE ON dbo.PtSEGPERIMCREATE_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtSEGPERIMCREATE_01 TO GDBBATCH
go
