/*==============================================================
Program: EST41 - Spira 41112
Version: 1
Author: S.Behague
Date of creation: 26/10/2015
Description: Correction BEST..TLIFEST
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

-- Effacement des duplicate keys
delete best..tlifest from best..tlifest lif1
where exists ( select * from best..tlifest lif2, btrt..tsection sec 
        where lif1.ctr_nf = sec.ctr_nf
and lif1.uwy_nf = sec.uwy_nf
and lif1.uw_nt  = sec.uw_nt
and lif1.end_nt = sec.end_nt
and lif1.sec_nf = sec.sec_nf
and sec.lob_cf = '30'
and lif1.CTR_NF = lif2.CTR_NF
and lif1.END_NT = lif2.END_NT
and lif1.SEC_NF = lif2.SEC_NF
and lif1.UWY_NF = lif2.UWY_NF
and lif1.UW_NT = lif2.UW_NT
and lif1.CRE_D = lif2.CRE_D
and lif1.BALSHEY_NF = lif2.BALSHEY_NF
and lif1.BALSHTMTH_NF = lif2.BALSHTMTH_NF
and lif1.ACY_NF = lif2.ACY_NF
and lif1.PRS_CF = lif2.PRS_CF
and lif1.DETTRNCOD_CF = lif2.DETTRNCOD_CF
and lif1.GAAP_NT = lif2.GAAP_NT
and lif1.SSD_CF = lif2.SSD_CF
and lif1.ACMTRS_NT != lif2.ACMTRS_NT
and lif1.DETTRNCOD_CF in ('41000','41100')
and lif1.ACMTRS_NT in (1503,1504)
)
go

declare 
 @enr    int
,@err    int
,@totenr int

while @enr!=0
begin
                            
        update best..tlifest
        set acmtrs_nt = case when dettrncod_cf = '41000' then 1503
                             when dettrncod_cf = '41100' then 1504
                        else
                             lif.acmtrs_nt
                        end
        from best..tlifest lif, btrt..tsection sec
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
--print 'Maj best..tlifest = ' ', lignes %1!',@totenr
go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go