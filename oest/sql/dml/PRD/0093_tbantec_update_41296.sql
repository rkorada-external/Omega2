use BREF
go

declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
go
/* In case where some values must be deleted */



if object_id('#TDEL') is not null
begin
  drop TABLE #TDEL
  if object_id('#TDEL') is not null
      print '<<< FAILED DROPPING TABLE #TDEL >>>'
  else
      print '<<< DROPPED TABLE #TDEL >>>'
end
go

create TABLE #TDEL
                (
COL_LS       UL16       NOT null
,COLVAL_CT    UBANVAL_CT NOT null
                )
go

insert #TDEL values('TYPMOD1_CT', '13')
insert #TDEL values('TYPMOD1_CT', '14')

go


/* End deletion process */

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

insert #TVAL values('E', 'TYPMOD1_CT', '13', 'File upload', 'File upload',null)
insert #TVAL values('E', 'TYPMOD1_CT', '14', 'Automatic Calculation', 'Automatic Calcul',null)

insert #TVAL values('F', 'TYPMOD1_CT', '13', 'Chargement fichier', 'chargemt Fichier',null)
insert #TVAL values('F', 'TYPMOD1_CT', '14', 'Calcul Automatique', 'Calcul Automatic',null)

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
insert #TQUAL values('TYPMOD1_CT',1,1,0,0)
set nocount off
go

print 'removing duplicate values from bref..tbantecl'
delete bref..tbantecl
from bref..tbantecl a, #TDEL b
  where a.COL_LS=b.COL_LS
    and a.COLVAL_CT=b.COLVAL_CT


print 'removing duplicate values from bref..tbantec'
delete bref..tbantec
from bref..tbantec a, #TDEL b
  where a.COL_LS=b.COL_LS
    and a.COLVAL_CT=b.COLVAL_CT


print 'insert bref..tbantec'
insert bref..tbantec
select a.COL_LS,b.COLVAL_CT,ACTCOD_B=0,b.CODVALSSD_CF,suser_name(),null,1
from #TQUAL a, #TVAL b
  where a.COL_LS=b.COL_LS
    and a.TECCOD_B=1
    and b.LAG_CF='F' -- pour ne mettre qu'une ligne par code

print 'insert bref..tbantecl'
insert bref..tbantecl
select c.LAGI_CF,a.COL_LS,b.COLVAL_CT,b.COLVAL_LM,b.COLVAL_LS,b.CODVALSSD_CF,suser_name(),null
from #TQUAL a, #TVAL b, #TLAG c
  where a.COL_LS=b.COL_LS
    and a.TECCOD_B=1
    and b.LAG_CF=c.LAGS_CF
go

set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
