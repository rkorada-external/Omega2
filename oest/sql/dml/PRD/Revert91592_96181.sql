use BREF
go
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
go

if object_id('#TQUAL') is not null
begin
  drop TABLE #TQUAL
  if object_id('#TQUAL') is not null
    print '<<< FAILED DROPPING TABLE #TQUAL >>>'
  else
    print '<<< DROPPED TABLE #TQUAL >>>'
end
go
create TABLE #TQUAL
                (
  COL_LS       UL16       NOT null           -- code banalisé
 ,TECCOD_B     bit        DEFAULT 0 NOT null -- Utilisateur 0, Technique 1
 ,CODFMT_CT    UCODFMT_CT NOT null           -- Tinyint (1 à 255) 1, Caractère 2, Numérique (1 à 99999) 3, Smallint (1 à 65535) 4, Bit 5
 ,CODLNG_N     tinyint    DEFAULT 0 NOT null -- longueur 0 pour type numérique, 1 à n pour type caractère
 ,CODNAT_CT    tinyint    NOT null           -- Groupe 0, Filiale 1, Mixte 2
                )
go
insert #TQUAL values('FileTYPE_NT',1,1,0,0)
set nocount off
go

select * from #TQUAL

print 'delete des nouvelles codifs si elles existent déjà'
delete bref..tbancodl where col_ls in(select COL_LS from #TQUAL)
delete bref..tbancod where col_ls in(select COL_LS from #TQUAL)
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL where TECCOD_B=1)
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL where TECCOD_B=1)
delete bref..tbanall where col_ls in(select COL_LS from #TQUAL where TECCOD_B=0)
delete bref..tbanal where col_ls in(select COL_LS from #TQUAL where TECCOD_B=0)

go

if object_id('#TQUAL') is not null
begin
  drop TABLE #TQUAL
  if object_id('#TQUAL') is not null
    print '<<< FAILED DROPPING TABLE #TQUAL >>>'
  else
    print '<<< DROPPED TABLE #TQUAL >>>'
end
go
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
