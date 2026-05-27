use BEST
go
if object_id('dbo.PuCURSII_01') is not null
begin
  drop procedure dbo.PuCURSII_01
  if object_id('dbo.PuCURSII_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PuCURSII_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PuCURSII_01 >>>'
end
go
create procedure PuCURSII_01
  (
  @p_CRE_D         UUPD_D
 ,@p_CUR_CF        UCUR_CF
 ,@p_CUR_CF_old    UCUR_CF
 ,@p_GRPCUR_CF     UCUR_CF
 ,@p_GRPCUR_CF_old UCUR_CF
 ,@p_VALEND_D      datetime
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

update TCURSII
 set CUR_CF=@p_CUR_CF
    ,GRPCUR_CF=@p_GRPCUR_CF
    ,VALEND_D=@p_VALEND_D
    ,LSTUPD_D=@p_LSTUPD_D
    ,LSTUPDUSR_CF=@p_LSTUPDUSR_CF
 where CRE_D=@p_CRE_D
   and CUR_CF=@p_CUR_CF_old
   and GRPCUR_CF=@p_GRPCUR_CF_old
select @erreur = @@error, @nbligne = @@rowcount
if @erreur != 0
begin
  select @p_erreur="20004 APPLICATIF;TCURSII " + convert(varchar(10), @erreur) + ";"
  goto fin
end
if @nbligne = 0
begin
  select @p_erreur = "20006 APPLICATIF;TCURSII " + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PuCURSII_01') is not null
  print '<<< CREATED procedure dbo.PuCURSII_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PuCURSII_01 >>>'
go
grant execute on dbo.PuCURSII_01 TO GOMEGA
go
