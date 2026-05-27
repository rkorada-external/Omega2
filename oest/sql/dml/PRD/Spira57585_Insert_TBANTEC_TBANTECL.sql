--Defect 57585 Insert New Closing Type 'Y'

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


/* if language in ('FR', 'IT', 'SP') */
insert #TVAL values('F','ESTCOMTYP_CT','4','Suivi Closing','Suivi Closing',null)
insert #TVAL values('I','ESTCOMTYP_CT','4','Suivi Closing','Suivi Closing',null)
insert #TVAL values('S','ESTCOMTYP_CT','4','Suivi Closing','Suivi Closing',null)

/* if language in ('EN','GE') :*/
insert #TVAL values('E','ESTCOMTYP_CT','4','Closing Follow-Up','Closing Follow-Up',null)
insert #TVAL values('G','ESTCOMTYP_CT','4','Closing Follow-Up','Closing Follow-Up',null)


/*
**************** FIN Modif
*/

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
insert #TLAG values('G','G')
insert #TLAG values('I','I')
insert #TLAG values('S','S')
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

insert #TQUAL values('ESTCOMTYP_CT',1,1,0,0)
/* Fin Modif */

set nocount off
go


print 'delete des nouvelles codifs si elles existent déjà'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = 'Y'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = 'Y'


print 'insert bref..tbantec'
insert bref..tbantec
select a.COL_LS,b.COLVAL_CT,ACTCOD_B=1,b.CODVALSSD_CF,suser_name(),null,1
from #TQUAL a, #TVAL b
  where a.COL_LS=b.COL_LS
    and b.LAG_CF='F' -- pour ne mettre qu'une ligne par code

print 'insert bref..tbantecl'
insert bref..tbantecl
select c.LAGI_CF,a.COL_LS,b.COLVAL_CT,b.COLVAL_LM,b.COLVAL_LS,b.CODVALSSD_CF,suser_name(),null
from #TQUAL a, #TVAL b, #TLAG c
  where a.COL_LS=b.COL_LS
    and b.LAG_CF=c.LAGS_CF
go
set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go