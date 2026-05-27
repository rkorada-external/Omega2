use BEST
go
if object_id('dbo.PsLOBSII_01') is not null
begin
  drop procedure dbo.PsLOBSII_01
  if object_id('dbo.PsLOBSII_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PsLOBSII_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLOBSII_01 >>>'
end
go
create procedure PsLOBSII_01
  (
  @p_lag_cf ULAG_CF
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
  LOB_CF
 ,LOB_LS=(select LOB_GS from BREF..TLOBL b where b.LOB_CF=a.LOB_CF and LAG_CF=@p_lag_cf)
 ,SEGNAT_CT
 ,NORME_CF
 ,COEF_R
 ,VALEND_D
 ,CLOSING_D
 ,CRE_D
 ,CREUSR_CF
 ,LSTUPD_D
 ,LSTUPDUSR_CF
 from TLOBSII a
go
if object_id('dbo.PsLOBSII_01') is not null
  print '<<< CREATED procedure dbo.PsLOBSII_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLOBSII_01 >>>'
go
grant execute on dbo.PsLOBSII_01 TO GOMEGA
go
