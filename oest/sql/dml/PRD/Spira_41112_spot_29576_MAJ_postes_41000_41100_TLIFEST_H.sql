/*==============================================================
Program: EST41 - Spira 41112
Version: 1
Author: S.Behague
Date of creation: 26/10/2015
Description: Correction BEST..TLIFEST_H
             Poste 41000 positionné sur ACMTRS 1503 pour LOB 30
             Poste 41100 positionné sur ACMTRS 1504 pour LOB 30
==============================================================*/

use BEST
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

while @enr!=0
begin
                            
        update best..tlifest_h
        set acmtrs_nt = case when dettrncod_cf = '41000' then 1503
                             when dettrncod_cf = '41100' then 1504
                        else
                             lif.acmtrs_nt
                        end
        from best..tlifest_h lif, btrt..tsection sec
        where lif.ctr_nf = sec.ctr_nf
        and lif.uwy_nf = sec.uwy_nf
        and lif.uw_nt  = sec.uw_nt
        and lif.end_nt = sec.end_nt
        and lif.sec_nf = sec.sec_nf
        and sec.lob_cf = '30'
        and lif.dettrncod_cf in ('41000','41100')
        and lif.acmtrs_nt in (1063,1064)
        
 select @err=@@error, @enr=@@rowcount, @totenr=@totenr+@@rowcount
  if @@transtate > 1 or @err!=0 break
  commit
  if @enr=0 break
end
                      

set rowcount 0
--print 'Maj BEST..TLIFEST_H.acmtrs_nt = ' ', lignes %1!',@totenr
go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go