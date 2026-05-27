/*==============================================================================
  -- Creation date    : 29/12/2016
  -- Author             : MMA
  -- Origin               : SPIRA 57351
  -- Description        : Suppression des notifications des écarts pour ne garder que les plus récents
  -- Action              : delete
  -- Impacted table(s)  : BEST..TACCEXCPRO
  -- Impacted row(s)    : 148 rows (on DEV and UAT)
================================================================================*/

USE BEST
go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
go

declare 
 @enr    int
,@err    int
,@totenr int

DELETE FROM BEST..TACCEXCPRO 
--select distinct a1.* -- a1.SSD_CF,a1.ESB_CF,a1.LSTUPDUSR_CF,a1.CTR_NF,a1.SEC_NF,a1.UWY_NF,a1.ACY_NF,a1.DETTRNCOD_CF, a1.GAP_D
FROM BEST..TACCEXCPRO a1,  BEST..TACCEXCPRO a2
WHERE a1.SSD_CF     = a2.SSD_CF
AND a1.ESB_CF       = a2.ESB_CF
AND a1.CTR_NF       = a2.CTR_NF
AND a1.SEC_NF       = a2.SEC_NF
AND a1.UWY_NF       = a2.UWY_NF 
AND a1.ACY_NF       = a2.ACY_NF
AND a1.DETTRNCOD_CF = a2.DETTRNCOD_CF
AND a1.GAPSTS_NT    = a2.GAPSTS_NT
AND a2.GAPSTS_NT    = 2
AND a2.GAP_D        > a1.GAP_D

go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
go