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
,COLVAL_LS    UL16       NOT null
,COLVAL_LM    UL32       NOT null
,CODVALSSD_CF USSD_CF    null
                )
go

insert #TVAL values('E','STATEMFRQ_CF','15','15 days','15 days',null)
insert #TVAL values('F','STATEMFRQ_CF','15','15 jours','15 jours',null)
insert #TVAL values('E','STATEMFRQ_CF','30','30 days','30 days',null)
insert #TVAL values('F','STATEMFRQ_CF','30','30 jours','30 jours',null)
insert #TVAL values('E','STATEMFRQ_CF','45','45 days','45 days',null)
insert #TVAL values('F','STATEMFRQ_CF','45','45 jours','45 jours',null)
insert #TVAL values('E','STATEMFRQ_CF','60','60 days','60 days',null)
insert #TVAL values('F','STATEMFRQ_CF','60','60 jours','60 jours',null)
insert #TVAL values('E','STATEMFRQ_CF','255','or Date','or Date',null)
insert #TVAL values('F','STATEMFRQ_CF','255','ou Date','ou Date',null)

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
  LAGI_CF char(1) not null -- langue à mettre pour les codification
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
  COL_LS       UL16       NOT null           -- code banalisé
,TECCOD_B     bit        DEFAULT 0 NOT null -- Utilisateur 0, Technique 1
,CODFMT_CT    UCODFMT_CT NOT null           -- Tinyint (1 à 255) 1, Caractère 2, Numérique (1 à 99999) 3, Smallint (1 à 65535) 4, Bit 5
,CODLNG_N     tinyint    DEFAULT 0 NOT null -- longueur 0 pour type numérique, 1 à n pour type caractère
,CODNAT_CT    tinyint    NOT null           -- Groupe 0, Filiale 1, Mixte 2
                )
go
insert #TQUAL values('STATEMFRQ_CF',0,1,0,0)

set nocount off
go


print 'delete des nouvelles codifs si elles existent déjà'
delete bref..tbancodl where col_ls in(select COL_LS from #TQUAL)
delete bref..tbancod where col_ls in(select COL_LS from #TQUAL)
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL where TECCOD_B=1)
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL where TECCOD_B=1)
delete bref..tbanall where col_ls in(select COL_LS from #TQUAL where TECCOD_B=0)
delete bref..tbanal where col_ls in(select COL_LS from #TQUAL where TECCOD_B=0)

print 'insert bref..tbancod'
insert bref..tbancod select COL_LS,TECCOD_B,CODFMT_CT,CODLNG_N,CODNAT_CT,suser_name(),null,"6" from #TQUAL where COL_LS='STATEMFRQ_CF'

print 'insert bref..tbancodl'
insert bref..tbancodl
select LAGI_CF,'STATEMFRQ_CF', case when LAGS_CF='F' then 'Fréquence Relevé Rgl' else 'Statement frequency' end,suser_name(),null
from #TLAG


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