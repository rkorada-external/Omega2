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

insert #TVAL values('E','ANO_CT','300','Inc Bshye Endval','Balsheyear unequal to end of validity',null)
insert #TVAL values('F','ANO_CT','300','Diff Ann Bil Per Valid','Annee bilan <> fin per. de validite',null)
insert #TVAL values('E','ANO_CT','301','Inc Bshmth Endval','Balsheymth unequal to end of validity',null)
insert #TVAL values('F','ANO_CT','301','Diff mois Bil Per Valid','Mois bilan <> fin de per. de validite',null)
insert #TVAL values('E','ANO_CT','302','Bshmth','Balshmth must be a quarter month',null)
insert #TVAL values('F','ANO_CT','302','Mois bilan','Mois bilan doit etre mois trim.',null)
insert #TVAL values('E','ANO_CT','303','Incorr Ledger local AE','Ledger cannot load quaterly loc AE',null)
insert #TVAL values('F','ANO_CT','303','Incorr Etab ES locales','Etab. non autorise ES loc trim.',null)
insert #TVAL values('E','ANO_CT','304','Incorr Ledger local AE','Ledger cannot load monthly local AE',null)
insert #TVAL values('F','ANO_CT','304','Incorr Etab ES locales','Etab. non autorise ES loc mens.',null)
insert #TVAL values('E','ANO_CT','305','Wrong mnth period','Wrong loading period monthly AE',null)
insert #TVAL values('F','ANO_CT','305','Mois bilan faux','Mois bilan incorrect',null)
insert #TVAL values('E','ANO_CT','306','Wrong quarter period','Wrong quarter. loading period AE',null)
insert #TVAL values('F','ANO_CT','306','Trim bilan faux','Erreur liee au libelle d''inventaire',null)
insert #TVAL values('E','ANO_CT','307','Inv TC','T. Local AE Trans. Code anomaly ',null)
insert #TVAL values('F','ANO_CT','307','TC incorrect','Erreur liee aux TC ES locales',null)
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
insert #TQUAL values('ANO_CT',1,1,0,0)

set nocount off
go

print 'delete des nouvelles codifs si elles existent déjà'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '300'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '300'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '301'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '301'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '302'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '302'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '303'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '303'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '304'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '304'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '305'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '305'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '306'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '306'
delete bref..tbantecl where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '307'
delete bref..tbantec where col_ls in(select COL_LS from #TQUAL) and COLVAL_CT = '307'

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