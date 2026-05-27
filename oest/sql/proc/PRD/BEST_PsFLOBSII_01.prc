use BEST
go
if object_id('dbo.PsFLOBSII_01') is not null
begin
  drop PROC dbo.PsFLOBSII_01
  print '<<< DROPPED PROC dbo.PsFLOBSII_01 >>>'
end
go
create procedure PsFLOBSII_01
  (
  @p_clodatmax_d  datetime
  )
as
/***************************************************
Domaine: (ES) Estimation
Base principale: BEST
Auteur: Florent
Date de creation: 11/06/2012
Description du programme: :spot:23390 SOLVENCY II, Génération du fichier FRANTINGSII (SOLVENCY)
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 Florent 21/11/2012 :spot:24041 ajout des trim
*****************************************************/
declare @clodat_d datetime
select @clodat_d = @p_clodatmax_d

select LOB_CF,SEGNAT_CT,NORME_CF,COEF_R,CRE_D=max(CRE_D)
into #TLOBSII
 from TLOBSII
  where VALEND_D >= @clodat_d
group by LOB_CF,SEGNAT_CT,NORME_CF,COEF_R
order by LOB_CF,SEGNAT_CT,NORME_CF,COEF_R

insert into #TLOBSII
select LOB_CF,SEGNAT_CT,NORME_CF,COEF_R,CRE_D=max(CRE_D)
 from TLOBSII a
  where (a.VALEND_D is null or a.VALEND_D >= @clodat_d)
   and not exists(select 1 from #TLOBSII b where b.LOB_CF=a.LOB_CF and b.SEGNAT_CT=a.SEGNAT_CT and b.NORME_CF=a.NORME_CF)
   and a.CRE_D=(select max(c.CRE_D) from TLOBSII c where c.LOB_CF=a.LOB_CF and c.SEGNAT_CT=a.SEGNAT_CT and c.NORME_CF=a.NORME_CF
                 and (c.VALEND_D is null or c.VALEND_D<=@clodat_d) )
group by LOB_CF,SEGNAT_CT,NORME_CF,COEF_R
order by LOB_CF,SEGNAT_CT,NORME_CF,COEF_R
if @@error != 0
begin
   raiserror 20005 "APPLICATIF;TCURSII" -- erreur d'INSERTION
   return @@error
end

select rtrim(LOB_CF),rtrim(SEGNAT_CT),rtrim(NORME_CF),COEF_R,CRE_D
 from #TLOBSII a
  where exists(select 1 from BREF..TLOB b where a.LOB_CF=b.LOB_CF)
order by LOB_CF,SEGNAT_CT,NORME_CF
return 0
go
if object_id('dbo.PsFLOBSII_01') is not null
  print '<<< CREATED PROC dbo.PsFLOBSII_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFLOBSII_01 >>>'
go
grant execute on dbo.PsFLOBSII_01 TO GOMEGA
go
