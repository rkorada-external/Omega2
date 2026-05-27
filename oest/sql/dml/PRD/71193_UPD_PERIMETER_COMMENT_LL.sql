USE BEST
go
/* UBGL_ON */
-- ------------------------------------------------------------------------------------
-- Script   : 71193_EST_ESID891_PERIMETER_MODIFY_COMMENT_LL.sql
-- Domain   : ESTIMATION
-- Database : BEST
-- Auteur   : L. Wernert
-- Creation date    : 21/08/2019
-- Spira    : 71193
-- Description  : Increase the number of characters allowed in the field COMMENT_LL
-- -------------------------------------------------------------------------------------
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Start:  ' + convert(char(9),getdate(),6) + '  ' +  convert(char(8),getdate(),8) + substring(convert(char(27),getdate(),109),21,4)
print @msg
go

ALTER TABLE BTRAV..EST_ESID0891_PERIMETER 
MODIFY COMMENT_LL NVARCHAR(250) NULL

go
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  End:  ' + convert(char(9),getdate(),6) + ' ' + convert(char(8),getdate(),8) + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
