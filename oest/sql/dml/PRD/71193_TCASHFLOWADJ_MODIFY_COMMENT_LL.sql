USE BEST
go

-- ------------------------------------------------------------------------------------
-- Script   : 71193_TCASHFLOWADJ_MODIFY_COMMENT_LL.sql
-- Domain   : ESTIMATION
-- Database : BEST
-- Auteur   : L. Wernert
-- Creation date    : 22/11/2018
-- Spira    : 71193
-- Description  : Increase the number of characters allowed in the field COMMENT_LL
-- -------------------------------------------------------------------------------------
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Start:  ' + convert(char(9),getdate(),6) + '  ' +  convert(char(8),getdate(),8) + substring(convert(char(27),getdate(),109),21,4)
print @msg
go

ALTER TABLE BEST..TCASHFLOWADJ 
MODIFY COMMENT_LL NVARCHAR(250) NULL

go
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  End:  ' + convert(char(9),getdate(),6) + ' ' + convert(char(8),getdate(),8) + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
