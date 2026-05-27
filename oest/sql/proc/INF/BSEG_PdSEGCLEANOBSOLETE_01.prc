USE BSEG
go

IF OBJECT_ID('dbo.PdSEGCLEANOBSOLETE_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PdSEGCLEANOBSOLETE_01
    IF OBJECT_ID('dbo.PdSEGCLEANOBSOLETE_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdSEGCLEANOBSOLETE_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PdSEGCLEANOBSOLETE_01 >>>'
END
go

Create procedure dbo.PdSEGCLEANOBSOLETE_01 as

set nocount on

/***************************************************
Program:		PdSEGCLEANOBSOLETE_01
File script :	BSEG_PdSEGCLEANOBSOLETE_01.prc
Main database :	BSEG
Version:		1
Author:			NGA
Creation date:	26/02/2014
Description:
	. For each obsolete run:
		- Deletes TSEGRUNs
		- Deletes associated TSEGRUNAGG values
		- Drops associated TSEGRUNRES_[run] table
		- Drops associated TSEGRUNERR_[run] table
Parameters:
	N/A
Conditions:

Comments:

****************************************************/

declare @sgtrunNt USGTRUN_NT
declare @sgtrunstsCt UBANVAL_CT
declare @restablename varchar(64)
declare @errtablename varchar(64)
declare @query varchar(1000)
declare @dropped int
declare @tableUsername varchar(30)


-- Fetch the user ID, bypassing any alias
IF EXISTS (SELECT 1 FROM sysalternates WHERE suid=SUSER_ID())
	select @tableUsername = (SELECT user_name(altsuid) FROM sysalternates WHERE suid=SUSER_ID())
ELSE
	select @tableUsername = suser_name()


-- If exist, delete tables with non replaced #sgtrunNt token
select @restablename = @tableUsername + '.TSEGRUNRES_#sgtrunNt'
select @errtablename = @tableUsername + '.TSEGRUNERR_#sgtrunNt'

if exists (select 1
	from  sysobjects
	where id = object_id(@restablename)
	and   type = 'U'
	and   loginame = suser_name())
begin
	PRINT select "Dropping table " + @restablename
	select @query = "DROP TABLE " + @restablename
	execute (@query)
	select @dropped = 1
end
if exists (select 1
	from  sysobjects
	where id = object_id(@errtablename)
	and   type = 'U'
	and   loginame = suser_name())
begin
	PRINT select "Dropping table " + @errtablename
	select @query = "DROP TABLE " + @errtablename
	execute (@query)
	select @dropped = 1
end


-- Fetch obsolete runs
declare obsolete_runs_c cursor for
	select r.SGTRUN_NT, r.SGTRUNSTS_CT, r.SGTRESTABNME_LL, r.SGTERRTABNME_LL
    from TSEGRUN r
	where r.SGTOBSOLETE_B = 1 and LSTUPD_D <= dateadd(hour, -20, getdate())

open obsolete_runs_c

-- For each obsolete run, try to remove associated tables and delete this run
fetch obsolete_runs_c into @sgtrunNt, @sgtrunstsCt, @restablename, @errtablename
while (@@sqlstatus != 2)
    begin
        if (@@sqlstatus = 1)
        begin
            PRINT "Error in result fetching, aborting"
            return 1
        end
        else
        begin
            select @dropped = 0
            if exists (select 1
                from  sysobjects
                where id = object_id(@restablename)
                and   type = 'U'
                and   loginame = suser_name())
            begin
                PRINT select "Dropping table " + @restablename
                select @query = "DROP TABLE " + @restablename
                execute (@query)
                select @dropped = 1
            end
            
            if exists (select 1
                from  sysobjects
                where id = object_id(@errtablename)
                and   type = 'U'
                and   loginame = suser_name())
            begin
                PRINT select "Dropping table " + @errtablename
                select @query = "DROP TABLE " + @errtablename
                execute (@query)
                select @dropped = 1
            end

            if (@dropped = 1 or (@sgtrunstsCt != '5' and @restablename like '%' + @tableUsername + '%'))
            begin
                PRINT select "Deleting run ID " + convert(varchar, @sgtrunNt)
                DELETE FROM TSEGRUN WHERE SGTRUN_NT=@sgtrunNt
                DELETE FROM TSEGRUNAGG WHERE SGTRUN_NT=@sgtrunNt
            end
        end

        fetch obsolete_runs_c into @sgtrunNt, @sgtrunstsCt, @restablename, @errtablename
    end

close obsolete_runs_c
return 0
go
EXEC sp_procxmode 'dbo.PdSEGCLEANOBSOLETE_01', 'unchained'
go
IF OBJECT_ID('dbo.PdSEGCLEANOBSOLETE_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PdSEGCLEANOBSOLETE_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PdSEGCLEANOBSOLETE_01 >>>'
go
GRANT EXECUTE ON dbo.PdSEGCLEANOBSOLETE_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdSEGCLEANOBSOLETE_01 TO GDBBATCH
go
