use BEST
go
if object_id('dbo.PsFCURSII_01') is not null
begin
  drop PROC dbo.PsFCURSII_01
  print '<<< DROPPED PROC dbo.PsFCURSII_01 >>>'
end
go
create procedure PsFCURSII_01
  (
  @p_clodatmax_d  datetime
  )
as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : P PEZOUT
Date de creation        : 31/05/2012
Description du programme: :spot:23390 Génération du fichier FCURSII (SOLVENCY)
Conditions d'execution  :
Commentaires:
_________________
MODIFICATIONS
[001] 14/08/2012 R. Cassis   :spot:24041 - Changement d'ordre des colones dans le select
*****************************************************/
declare @clodat_d datetime
select @clodat_d = @p_clodatmax_d
-- select @clodat_d

select
cur_cf,
GRPCUR_CF,
max(cre_d) cre_d

into #TCURSII

from best..TCURSII
where
   VALEND_D >= @clodat_d
and VALEND_D is not null

group by cur_cf, GRPCUR_CF

insert into #TCURSII
select
t1.CUR_CF,
t1.GRPCUR_CF,
max(t1.CRE_D) CRE_D

from best..TCURSII t1
where
   (t1.VALEND_D is null or t1.VALEND_D>=@clodat_d)
and t1.CUR_CF not in (select CUR_CF from #TCURSII)
and t1.CRE_D =   (
                select max(t2.CRE_D) from best..TCURSII t2
                where t1.CUR_CF=t2.CUR_CF
                and (t2.VALEND_D is null or t2.VALEND_D<=@clodat_d)
                and not exists (select 1 from best..TCURSII t3 where t3.CUR_CF=t2.CUR_CF and t3.CRE_D=t2.CRE_D and t3.VALEND_D<=@clodat_d)
                )
group by t1.CUR_CF, t1.GRPCUR_CF
if @@error != 0
begin
   raiserror 20005 "APPLICATIF;TCURSII" -- erreur d'INSERTION
   return @@error
end

-- select Final
-- ------------
--[001]
select cur_cf,
       cre_d,
       GRPCUR_CF
from #TCURSII

return 0
go
if object_id('dbo.PsFCURSII_01') is not null
  print '<<< CREATED PROC dbo.PsFCURSII_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFCURSII_01 >>>'
go
grant execute on dbo.PsFCURSII_01 TO GOMEGA
go

