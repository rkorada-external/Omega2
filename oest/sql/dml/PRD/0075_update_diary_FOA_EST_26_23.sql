use BREF
go

set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go

UPDATE BREF..TNOTIFTYPE SET NOTNAT_CT='FOA' WHERE NOTIFTYP_NT IN (251,252,253)
go

set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
