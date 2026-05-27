/*==============================================================
Program: Est Life EST48
Version: 1
Author: S.Behague
Date of creation: 18/02/2015
Description: Reprise TREQJOB et TREQJOBPLAN - update PLAN_NF sur 6 caractères
          
==============================================================*/
use BEST
GO

set nocount on
declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
go

-- Reprise TLIFPLN
update best..tlifpln set PLAN_NF = 201504 where PLAN_NF = 2015
go

update best..tlifpln set PLAN_NF = 201405 where PLAN_NF = 2014
go

update best..tlifpln set PLAN_NF = 201312 where PLAN_NF = 2013
go

update best..tlifpln set PLAN_NF = 201211 where PLAN_NF = 2012
go

update best..tlifpln set PLAN_NF = 201112 where PLAN_NF = 2011
go

update best..tlifpln set PLAN_NF = 201011 where PLAN_NF = 2010
go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go