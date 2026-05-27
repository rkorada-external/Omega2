/*==============================================================================
  -- Creation date    : 19/01/2017
  -- Author             : MMA
  -- Origin               : SPIRA 58705 , reprise SPIRA 57346
  -- Description        : Supression des poste Dépôts
  -- Action              : DELETE
  -- Impacted table(s)  : BEST..TACCEXCPRO
  -- Impacted row(s)    : 100 rows (on UAT), 272 rows (on PRD)
================================================================================*/
USE BEST
go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg

select a.*
FROM  BEST..TACCEXCPRO a, bref..TSUBTRS s
where s.PCPTRS_CF + s.TRS_CF + s.SUBTRS_CF =  a.DETTRNCOD_CF
And s.TRSTYPE_CT= 4


go

declare 
 @enr    int
,@err    int
,@totenr int

DELETE
FROM  BEST..TACCEXCPRO
FROM  BEST..TACCEXCPRO a, bref..TSUBTRS s
WHERE s.PCPTRS_CF + s.TRS_CF + s.SUBTRS_CF =  a.DETTRNCOD_CF
And s.TRSTYPE_CT= 4

go

select * 
FROM  BEST..TACCEXCPRO

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
go