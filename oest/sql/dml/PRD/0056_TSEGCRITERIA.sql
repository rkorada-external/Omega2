/*==============================================================
Program: Segmentation Defect#37086
Version: 1
Author: G Rathi
Date of creation: 17/06/2015
Description: Fix for defect#37086
          
==============================================================*/
use BEST
GO

set nocount on
declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
go

-- update TSEGCRITERIA
update BEST..TSEGCRITERIA set SGTCRIPAR_LS='TERRI', SGTCRICTL_CT='5' where SGTCRI_CF in ('TERRITORIAL_SCOPE','DIVISION_MARKET')
go


declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go