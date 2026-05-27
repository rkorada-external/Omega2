USE BSAR
go
set nocount on
go


setuser 'dbo'
go

if not exists (select name from systypes where name='UGAAPCOD_NT')
begin

	exec sp_addtype 'UGAAPCOD_NT', 'numeric(18, 0)', 'null'
end
go



--25/03/2020 NLD :spira:83103 -- in BSAR.dbo.TTECLEDA_A, rename NEWCOLS2_NF to GAAPCOD_NT having numeric(18, 0) as new datatype

declare
 @erreur     int
,@maj        datetime


if not exists(select 1 from syscolumns col, sysobjects obj where col.name='GAAPCOD_NT' and obj.name = 'TTECLEDA_A' and col.id = obj.id)
  begin
  
	print 'Script de mise a jour TTECLEDA_A.GAAPCODE_NT'


	select @maj=getdate()

	print '**** Debut alter table TTECLEDA_A à %1!',@maj

	exec('alter table TTECLEDA_A modify NEWCOLS2_NF UGAAPCOD_NT null')

	print 'Alter table TTECLEDA_A, lignes %1!',@@rowcount

	exec('sp_rename "TTECLEDA_A.NEWCOLS2_NF", "GAAPCOD_NT"')

	print 'exec sp_rename TTECLEDA_A,  lignes %1!',@@rowcount

	select @maj=getdate()
	print '**** Fin alter table TTECLEDA_A! à %1!', @maj

end
else
	print '**** La colonne GAAPCOD_NT existe dans la table TTECLEDA_A, rien à faire'
go
 
