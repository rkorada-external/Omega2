use BEST
go
if object_id('dbo.PsCURQUOTD_SII') IS NOT null
begin
  drop PROC dbo.PsCURQUOTD_SII
  print '<<< DROPPED PROC dbo.PsCURQUOTD_SII >>>'
end
go
create procedure PsCURQUOTD_SII
  (
  @p_lag_cf ULAG_CF='F'
 ,@p_cur_cf UCUR_CF=null
  )
as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : Florent
Date de creation         : 27/03/2012
Description du programme : :spot:23390 SOLVENCY II
Conditions d'execution :
Commentaires :
_________________
MODIFICATIONS
  Auteur   Date       Description
*****************************************************/
if @p_cur_cf=null
  select a.CUR_CF,a.CUR_LL,a.CUR_LS
   from BREF..TCURL a, BREF..TCUR b
    where a.LAG_CF=@p_lag_cf
      and a.CUR_CF=b.CUR_CF
      and getdate() between isnull(b.CURINC_D,'18001231') and isnull(b.CUREXP_D,'21001231')
      and not exists(select 1 from BREF..TBANAL b where COL_LS='GRPCUR_CF' and a.CUR_CF=b.COLVAL_CT)
else
  select a.CUR_LS
   from BREF..TCURL a, BREF..TCUR b
    where a.LAG_CF=@p_lag_cf
      and a.CUR_CF=b.CUR_CF
      and a.CUR_CF=@p_cur_cf
      and getdate() between isnull(b.CURINC_D,'18001231') and isnull(b.CUREXP_D,'21001231')
      and not exists(select 1 from BREF..TBANAL b where COL_LS='GRPCUR_CF' and a.CUR_CF=b.COLVAL_CT)
go
if object_id('dbo.PsCURQUOTD_SII') IS NOT null
  print '<<< CREATED PROC dbo.PsCURQUOTD_SII >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsCURQUOTD_SII >>>'
go
GRANT execute on dbo.PsCURQUOTD_SII TO GOMEGA
go
