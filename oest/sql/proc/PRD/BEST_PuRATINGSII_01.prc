use BEST
go
if object_id('dbo.PuRATINGSII_01') is not null
begin
  drop procedure dbo.PuRATINGSII_01
  if object_id('dbo.PuRATINGSII_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PuRATINGSII_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PuRATINGSII_01 >>>'
end
go
create procedure PuRATINGSII_01
  (
  @p_CRE_D         UUPD_D
 ,@p_RATING_CF     varchar(5)
 ,@p_RATING_CF_old varchar(5)
 ,@p_NORME_CF      varchar(5)
 ,@p_NORME_CF_old  varchar(5)
 ,@p_VALEND_D      datetime
 ,@p_DEFPROB_R     USHORAT_R
 ,@p_RECOVRAT_R    USHORAT_R
 ,@p_CLOSING_D     datetime
 ,@p_LSTUPD_D      UUPD_D=null output
 ,@p_LSTUPDUSR_CF  UUPDUSR_CF=null output
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
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@nbligne   int

if @p_lstupd_d=null select @p_lstupd_d=getdate()
if isnull(@p_lstupdusr_cf,'')='' select @p_lstupdusr_cf=suser_name()

select @erreur = 0,@tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

update TRATINGSII
 set RATING_CF=@p_RATING_CF
    ,NORME_CF=@p_NORME_CF
    ,VALEND_D=@p_VALEND_D
    ,DEFPROB_R=@p_DEFPROB_R
    ,RECOVRAT_R=@p_RECOVRAT_R
    ,LSTUPD_D=@p_LSTUPD_D
    ,LSTUPDUSR_CF=@p_LSTUPDUSR_CF
 where CRE_D=@p_CRE_D
   and RATING_CF=@p_RATING_CF_old
   and NORME_CF=@p_NORME_CF_old
select @erreur = @@error, @nbligne = @@rowcount
if @erreur != 0
begin
  select @p_erreur="20004 APPLICATIF;TRATINGSII " + convert(varchar(10), @erreur) + ";"
  goto fin
end
if @nbligne = 0
begin
  select @p_erreur = "20006 APPLICATIF;TRATINGSII " + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PuRATINGSII_01') is not null
  print '<<< CREATED procedure dbo.PuRATINGSII_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PuRATINGSII_01 >>>'
go
grant execute on dbo.PuRATINGSII_01 TO GOMEGA
go
