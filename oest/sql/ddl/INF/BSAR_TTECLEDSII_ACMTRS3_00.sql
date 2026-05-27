USE BSAR
go
set nocount on
go

--09/11/2018 Charles IFRS 17 REQ 10.2
declare
 @erreur     int
,@clodat_d   datetime
,@per_cf     char(3)
,@LETTRE_maj char(1)
,@maj        datetime
,@count       int

select @count = 1

select @LETTRE_maj='A', @maj = getdate()

exec @erreur=BREF..PsCALEND_EBS @maj,1,@clodat_d output, @per_cf output
if @erreur!=0 return

print 'Période EBS %1!/%2!',@clodat_d,@per_cf

SELECT @LETTRE_maj=right(TABCIBLE_CF,1)
 FROM BSAR..TBOPAR
  where TAB_CF='TTECLEDSII'
    and PAR_D=null 
    and FIELD2_CF=@clodat_d

print 'Maj de TTECLEDSII.ACMTRS3 pour la table %1!',@LETTRE_maj



  if not exists(select 1 from syscolumns col, sysobjects obj where col.name='ACMTRS3_NT' and obj.name = 'TTECLEDSII_'+@LETTRE_maj and col.id = obj.id)
  begin
    select @maj=getdate()
    exec('alter table TTECLEDSII_'+@LETTRE_maj+' add ACMTRS3_NT VARCHAR(4) DEFAULT 9999 ')
    print 'Alter table TTECLEDSII_%1! %2!, lignes %3!',@LETTRE_maj,@maj,@@rowcount
  end
  else
    print 'Pas de traitmement pour la table TTECLEDSII_%1!',@LETTRE_maj


go
