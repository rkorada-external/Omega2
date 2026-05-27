USE BSAR
go
set nocount on
go
--08/10/2015 Florent :spot:29446 ajout de la colonne TIFI dans les tables SII
declare
 @erreur     int
,@clodat_d   datetime
,@per_cf     char(3)
,@LETTRE     char(1)
,@LETTRE_maj char(1)
,@maj        datetime

select @LETTRE='A', @maj = getdate()

exec @erreur=BREF..PsCALEND_EBS @maj,1,@clodat_d output, @per_cf output
if @erreur!=0 return

print 'Période EBS %1!/%2!',@clodat_d,@per_cf

SELECT @LETTRE_maj=right(TABCIBLE_CF,1)
 FROM BSAR..TBOPAR
  where TAB_CF='TTECLEDSII'
    and PAR_D=null 
    and FIELD2_CF=@clodat_d

print 'Maj de TTECLEDSII.COMMENT_CF pour la table %1!',@LETTRE_maj

while @LETTRE in('A','B','C','D','E','F')
begin 
  if not exists(select 1 from syscolumns col, sysobjects obj where col.name='TIFI_M' and obj.name = 'TTECLEDSII_'+@LETTRE and col.id = obj.id)
  begin
    select @maj=getdate()
    exec('alter table TTECLEDSII_'+@LETTRE+' add TIFI_M UAMT_M NULL')
    print 'Alter table TTECLEDSII_%1! %2!, lignes %3!',@LETTRE,@maj,@@rowcount
  end
  else
    print 'Pas de traitmement pour la table TTECLEDSII_%1!',@LETTRE

  if @LETTRE=@LETTRE_maj
  begin
    exec("update BSAR..TTECLEDSII_"+@LETTRE+" set TIFI_M=0, COMMENT_CF=str_replace(COMMENT_CF,'~','')")
    print 'Maj TTECLEDSII_%1! COMMENT_CF %2!, lignes %3!',@LETTRE,@maj,@@rowcount
  end

  select @LETTRE=char(ascii(@LETTRE)+1)
end
go
