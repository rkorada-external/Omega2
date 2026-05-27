use BEST
go
if object_id('dbo.PsCURSII_01') is not null
begin
  drop procedure dbo.PsCURSII_01
  if object_id('dbo.PsCURSII_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PsCURSII_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PsCURSII_01 >>>'
end
go
create procedure PsCURSII_01
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
  CUR_CF
 ,CUR_LS=(select CUR_LS from BREF..TCURL b where b.CUR_CF=a.CUR_CF and LAG_CF=@p_lag_cf)
 ,GRPCUR_CF
 ,VALEND_D
 ,CLOSING_D
 ,CRE_D
 ,CREUSR_CF
 ,LSTUPD_D
 ,LSTUPDUSR_CF
 from TCURSII a
go
if object_id('dbo.PsCURSII_01') is not null
  print '<<< CREATED procedure dbo.PsCURSII_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsCURSII_01 >>>'
go
grant execute on dbo.PsCURSII_01 TO GOMEGA
go
