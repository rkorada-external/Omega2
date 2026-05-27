use BEST
go
if object_id('dbo.PsFRATINGSII_01') is not null
begin
  drop PROC dbo.PsFRATINGSII_01
  print '<<< DROPPED PROC dbo.PsFRATINGSII_01 >>>'
end
go
create procedure PsFRATINGSII_01
  (
  @p_clodatmax_d  datetime
  )
as

/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: P PEZOUT
Date de creation: 31/05/2012
Description du programme: :spot:23390 Génération du fichier FRANTINGSII (SOLVENCY)
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 Florent 17/08/2012 :spot:24041 Solvency II, maj ordre des colonnes comme le prend le ESTC3004.c !
2 Charles SOOCIE 09/09/2021 SPIRA 96084 Implementation of IFRS17 NPR "Default probability" and "Recovery rate"
*****************************************************/

declare @clodat_d datetime
select @clodat_d = @p_clodatmax_d
-- select @clodat_d

select RATING_CF,NORME_CF,DEFPROB_R,RECOVRAT_R,max(cre_d) cre_d
into #TRATINGSII
 from best..TRATINGSII
  where VALEND_D >= @clodat_d
    and VALEND_D is not null
	and NORME_CF != 'I17SL'
group by RATING_CF, NORME_CF, DEFPROB_R, RECOVRAT_R
order by RATING_CF, NORME_CF, DEFPROB_R, RECOVRAT_R

-- select count(*) 'nb lignes avec valend_d' from #TRATINGSII
insert into #TRATINGSII
select RATING_CF,NORME_CF,DEFPROB_R,RECOVRAT_R,max(t1.CRE_D) CRE_D
 from best..TRATINGSII t1
  where (t1.VALEND_D is null or t1.VALEND_D>=@clodat_d)
	and NORME_CF != 'I17SL'
    and t1.RATING_CF+t1.NORME_CF not in (select RATING_CF+NORME_CF from #TRATINGSII)
    and t1.CRE_D = (select max(t2.CRE_D) from best..TRATINGSII t2 where t1.RATING_CF=t2.RATING_CF and t1.NORME_CF=t2.NORME_CF
                        and (t2.VALEND_D is null or t2.VALEND_D<=@clodat_d) )
group by RATING_CF, NORME_CF, DEFPROB_R, RECOVRAT_R
order by RATING_CF, NORME_CF, DEFPROB_R, RECOVRAT_R
if @@error != 0
begin
   raiserror 20005 "APPLICATIF;TCURSII" -- erreur d'INSERTION
   return @@error
end

-- select Final -- modif 1
select RATING_CF=rtrim(RATING_CF),NORME_CF=rtrim(NORME_CF),CRE_D,DEFPROB_R,RECOVRAT_R from #TRATINGSII order by RATING_CF, NORME_CF, DEFPROB_R, RECOVRAT_R
return 0
go
if object_id('dbo.PsFRATINGSII_01') is not null
  print '<<< CREATED PROC dbo.PsFRATINGSII_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFRATINGSII_01 >>>'
go
grant execute on dbo.PsFRATINGSII_01 TO GOMEGA
go
