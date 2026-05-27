use BREF
go
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
go
if object_id('#TVAL') is not null
begin
  drop TABLE #TVAL
  if object_id('#TVAL') is not null
      print '<<< FAILED DROPPING TABLE #TVAL >>>'
  else
      print '<<< DROPPED TABLE #TVAL >>>'
end
go
create TABLE #TVAL
	(
  LAG_CF       ULAG_CF    NOT null
 ,COL_LS       UL16       NOT null
 ,COLVAL_CT    UBANVAL_CT NOT null
 ,COLVAL_LM    UL32       NOT null
 ,COLVAL_LS    UL16       NOT null
 ,CODVALSSD_CF USSD_CF    null
	)
go


insert #TVAL values('E','NOTIFPSTYPE_CT','250', 'Est. follow-up', 'Est. follow-up', null)


insert #TVAL values('F','NOTIFPSTYPE_CT','250', 'Est. follow-up', 'Est. follow-up', null)


insert #TVAL values('G','NOTIFPSTYPE_CT','250', 'Est. follow-up', 'Est. follow-up', null)


insert #TVAL values('I','NOTIFPSTYPE_CT','250', 'Est. follow-up', 'Est. follow-up', null)


insert #TVAL values('S','NOTIFPSTYPE_CT','250', 'Est. follow-up', 'Est. follow-up', null)


go
if object_id('#TLAG') is not null
begin
  drop TABLE #TLAG
  if object_id('#TLAG') is not null
    print '<<< FAILED DROPPING TABLE #TLAG >>>'
  else
    print '<<< DROPPED TABLE #TLAG >>>'
end
go
create TABLE #TLAG
  (
  LAGI_CF char(1) not null -- langue ? mettre pour les codification
 ,LAGS_CF char(1) not null -- langue source
  )
go
if object_id('#TLAG') is not null
  print '<<< CREATED TABLE #TLAG >>>'
else
  print '<<< FAILED CREATING TABLE #TLAG >>>'
go
insert #TLAG values('E','E')
insert #TLAG values('F','F')
insert #TLAG values('G','E') -- pour l'allemand c'est la version anglaise qu'il faut mettre
insert #TLAG values('I','F')
insert #TLAG values('S','F')
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
  COL_LS       UL16       NOT null           -- code banalis?
 ,TECCOD_B     bit        DEFAULT 0 NOT null -- Utilisateur 0, Technique 1
 ,CODFMT_CT    UCODFMT_CT NOT null           -- Tinyint (1 ? 255) 1, Caract?re 2, Num?rique (1 ? 99999) 3, Smallint (1 ? 65535) 4, Bit 5
 ,CODLNG_N     tinyint    DEFAULT 0 NOT null -- longueur 0 pour type num?rique, 1 ? n pour type caract?re
 ,CODNAT_CT    tinyint    NOT null           -- Groupe 0, Filiale 1, Mixte 2
	)
go
insert #TQUAL values('NOTIFPSTYPE_CT',0,1,0,0)
insert #TQUAL values('SPEENTTYP_CF',0,1,0,0)

set nocount off
go
--print 'delete des nouvelles codifs si elles existent dj'
--delete bref..tbanall where col_ls in(select COL_LS from #TQUAL where TECCOD_B=0)
--delete bref..tbanal where col_ls in(select COL_LS from #TQUAL where TECCOD_B=0)

print 'delete from bref..tbanall'
delete from bref..tbanall where COL_LS='NOTIFPSTYPE_CT' and  COLVAL_CT IN ('250')
go
print 'delete from bref..tbanal'
delete from bref..tbanal where COL_LS='NOTIFPSTYPE_CT' and  COLVAL_CT IN ('250')
go


print 'insert bref..tbanal'
insert bref..tbanal
select a.COL_LS,b.COLVAL_CT,ACTCOD_B=1,b.CODVALSSD_CF,suser_name(),null,1
 from #TQUAL a, #TVAL b
  where a.COL_LS=b.COL_LS
    and a.TECCOD_B=0
    and b.LAG_CF='F' -- pour ne mettre qu'une ligne par code

print 'insert bref..tbanall'
insert bref..tbanall
select c.LAGI_CF,a.COL_LS,b.COLVAL_CT,b.COLVAL_LM,b.COLVAL_LS,b.CODVALSSD_CF,suser_name(),null
 from #TQUAL a, #TVAL b, #TLAG c
  where a.COL_LS=b.COL_LS
    and a.TECCOD_B=0
    and b.LAG_CF=c.LAGS_CF

go
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
