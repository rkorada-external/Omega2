use BEST
go
if object_id('dbo.PdLOBSII_01') is not null
begin
  drop procedure dbo.PdLOBSII_01
  if object_id('dbo.PdLOBSII_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PdLOBSII_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PdLOBSII_01 >>>'
end
go
create procedure PdLOBSII_01
  (
  @p_CRE_D         UUPD_D
 ,@p_LOB_CF_old    ULOB_CF
 ,@p_NORME_CF_old  varchar(5)
 ,@p_SEGNAT_CT_old char(1)
 ,@p_erreur        varchar(64)=null output
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
1 28/11/2012 Florent :spot:24041 Pas de delete si CLOSING_D renseignée
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@nbligne   int

select @erreur=0,@tran_imbr=1
if @@trancount=0
begin
  select @tran_imbr=0
  begin TRAN
end

delete TLOBSII
 where CRE_D=@p_CRE_D
   and LOB_CF=@p_LOB_CF_old
   and NORME_CF=@p_NORME_CF_old
   and SEGNAT_CT=@p_SEGNAT_CT_old
   and CLOSING_D=null
select @erreur = @@error, @nbligne = @@rowcount
if @erreur != 0
begin
  select @p_erreur="20003 APPLICATIF;TLOBSII " + convert(varchar(10), @erreur) + ";"
  goto fin
end
if @tran_imbr = 0 COMMIT TRAN
return

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PdLOBSII_01') is not null
  print '<<< CREATED procedure dbo.PdLOBSII_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PdLOBSII_01 >>>'
go
grant execute on dbo.PdLOBSII_01 TO GOMEGA
go
