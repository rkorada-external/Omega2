use BEST
go
if object_id('dbo.PsRATINGSII_01') is not null
begin
  drop procedure dbo.PsRATINGSII_01
  if object_id('dbo.PsRATINGSII_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PsRATINGSII_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PsRATINGSII_01 >>>'
end
go
create procedure PsRATINGSII_01
  (
  @p_lag_cf    ULAG_CF
  )
as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : Florent
Date de creation         : 20/03/2012
Description du programme : :spot:23390 SOLVENCY II
Conditions d'execution :
Commentaires :
_________________
MODIFICATIONS
*****************************************************/
select
  RATING_CF
 ,NORME_CF
 ,VALEND_D
 ,CLOSING_D
 ,DEFPROB_R
 ,RECOVRAT_R
 ,CRE_D
 ,CREUSR_CF
 ,LSTUPD_D
 ,LSTUPDUSR_CF
 from TRATINGSII
go
if object_id('dbo.PsRATINGSII_01') is not null
  print '<<< CREATED procedure dbo.PsRATINGSII_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsRATINGSII_01 >>>'
go
grant execute on dbo.PsRATINGSII_01 TO GOMEGA
go
