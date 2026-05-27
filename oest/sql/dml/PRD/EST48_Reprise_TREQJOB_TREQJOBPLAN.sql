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

-- Reprise TREQJOB
update best..treqjob set vrs_nf = case when balshtmth_nf <= 9 then convert(int,convert(char(4),balsheyea_nf)+'0'+convert(char(2),BALSHTMTH_NF))
                                       else convert(int,convert(char(4),balsheyea_nf)+convert(char(2),BALSHTMTH_NF))
                                       end
where reqcod_ct = 'A'
go

-- Reprise TREQJOBPLAN
update best..treqjobplan set vrs_nf = case when balshtmth_nf <= 9 then convert(int,convert(char(4),balsheyea_nf)+'0'+convert(char(2),BALSHTMTH_NF))
                                       else convert(int,convert(char(4),balsheyea_nf)+convert(char(2),BALSHTMTH_NF))
                                       end
where reqcod_ct = 'A'
go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go