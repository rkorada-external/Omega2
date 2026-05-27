USE BSAR
go
set nocount on
go
create table #tletter (cnt int, letter char(1))
go

insert into #tletter values (1, 'H')
insert into #tletter values (2, 'P')
insert into #tletter values (3, 'S')
insert into #tletter values (4, 'T')



--09/11/2018 Charles IFRS 17 REQ 10.2
declare
 @erreur     int
,@clodat_d   datetime
,@per_cf     char(3)
,@LETTRE     char(1)
,@LETTRE_maj char(1)
,@maj        datetime
,@count       int

select @count = 1

select @LETTRE='H', @maj = getdate()

exec @erreur=BREF..PsCALEND_EBS @maj,1,@clodat_d output, @per_cf output
if @erreur!=0 return

print 'Période EBS %1!/%2!',@clodat_d,@per_cf

SELECT @LETTRE_maj=right(TABCIBLE_CF,1)
 FROM BSAR..TBOPAR
  where TAB_CF='TTECLEDSII'
    and PAR_D=null 
    and FIELD2_CF=@clodat_d


while (SELECT COUNT(1) FROM #tletter) < 5
begin 
   SELECT @LETTRE = letter from   #tletter where cnt = @count
   print 'Maj de TTECLEDSII.ACMTRS3 pour la table %1!',@LETTRE_maj
  if not exists(select 1 from syscolumns col, sysobjects obj where col.name='ACMTRS3_NT' and obj.name = 'TTECLEDSII_'+@LETTRE and col.id = obj.id)
  begin
    select @maj=getdate()
    exec('alter table TTECLEDSII_'+@LETTRE+' add ACMTRS3_NT VARCHAR(4) DEFAULT 9999 ')
    print 'Alter table TTECLEDSII_%1! %2!, lignes %3!',@LETTRE,@maj,@@rowcount
  end
  else
    print 'Pas de traitmement pour la table TTECLEDSII_%1!',@LETTRE

  select @count=@count+1
  
  if (@count > 4)
        break
  
end
go
