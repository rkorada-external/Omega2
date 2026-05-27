/*==============================================================
Program: EST41 - Spira 41112
Version: 1
Author: S.Behague
Date of creation: 26/10/2015
Description: Correction BEST..TLIFEST
             Poste 41000 positionné sur ACMTRS 2503 pour LOB 30
             Poste 41100 positionné sur ACMTRS 2504 pour LOB 30
==============================================================*/

use BREF
go

set nocount on
declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
go

declare 
 @enr    int
,@err    int
,@totenr int

select @enr=1,@totenr=0
set rowcount 500000

delete from bref..ttrslnk where substring(dettrs_cf, 3, 5) = '41000' and      prs_cf = 500 and   substring(dettrs_cf, 1, 1) = '4' and lstupdusr_cf = 'ANB'
go

delete from bref..ttrslnk where substring(dettrs_cf, 3, 5) = '41100' and      prs_cf = 500 and   substring(dettrs_cf, 1, 1) = '4' and lstupdusr_cf = 'ANB'
go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go