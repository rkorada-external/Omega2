use BEST
go
if object_id('dbo.PiRATINGSII_01') is not null
begin
  drop procedure dbo.PiRATINGSII_01
  if object_id('dbo.PiRATINGSII_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PiRATINGSII_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PiRATINGSII_01 >>>'
end
go
create procedure PiRATINGSII_01
  (
  @p_CRE_D        UUPD_D
 ,@p_RATING_CF    varchar(5)
 ,@p_NORME_CF     varchar(5)
 ,@p_VALEND_D     datetime
 ,@p_DEFPROB_R    USHORAT_R
 ,@p_RECOVRAT_R   USHORAT_R
 ,@p_CLOSING_D    datetime
 ,@p_LSTUPD_D     UUPD_D=null output
 ,@p_LSTUPDUSR_CF UUPDUSR_CF=null output
 ,@p_erreur       varchar(64)=null output
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
declare @erreur int,
        @tran_imbr  bit

if @p_lstupd_d=null select @p_lstupd_d=getdate()
if isnull(@p_lstupdusr_cf,'')='' select @p_lstupdusr_cf=suser_name()

select @erreur = 0,@tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

insert TRATINGSII(CRE_D,CREUSR_CF,RATING_CF,NORME_CF,VALEND_D,DEFPROB_R,RECOVRAT_R,CLOSING_D,LSTUPD_D,LSTUPDUSR_CF)
values(@p_CRE_D,suser_name(),@p_RATING_CF,@p_NORME_CF,@p_VALEND_D,@p_DEFPROB_R,@p_RECOVRAT_R,@p_CLOSING_D,@p_LSTUPD_D,@p_LSTUPDUSR_CF)
select @erreur = @@error
if @erreur != 0
begin
  if @erreur = 2601
    select @p_erreur = "20002 APPLICATIF;2601;TRATINGSII"
  else
    select @p_erreur = "20001 APPLICATIF;TRATINGSII " + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PiRATINGSII_01') is not null
  print '<<< CREATED procedure dbo.PiRATINGSII_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PiRATINGSII_01 >>>'
go
grant execute on dbo.PiRATINGSII_01 TO GOMEGA
go
