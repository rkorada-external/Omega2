use BEST
go
if object_id('dbo.PiLIFNEWBIZ_01') is not null
begin
  drop procedure dbo.PiLIFNEWBIZ_01
  if object_id('dbo.PiLIFNEWBIZ_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PiLIFNEWBIZ_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PiLIFNEWBIZ_01 >>>'
end
go
create procedure PiLIFNEWBIZ_01
  (
  @p_CTR_NF       UCTR_NF
 ,@p_END_NT       UEND_NT
 ,@p_SEC_NF       USEC_NF
 ,@p_ACY_NF       smallint
 ,@p_ACMTRS_NT    smallint
 ,@p_NEWBIZ_R     USHA_R
 ,@p_LSTUPD_D     UUPD_D      = null output
 ,@p_LSTUPDUSR_CF UUPDUSR_CF  = null output
 ,@p_ERREUR       varchar(64) = null output
  )
as
/***************************************************
Domaine                   : Estimation Vie
Base principale           : BEST
Auteur                    : Florent
Date de création          : 21/12/2009
Description du programme  : :spot:17932 gestion affaires nouvelles
Conditions d'éxécution    : par la dw d_tb_sp_newbiz
Commentaires              :
_________________
MODIFICATIONS
M  Auteur      Date       Description
*****************************************************/
declare
 @erreur    integer
,@tran_imbr bit

select @tran_imbr=1,@p_LSTUPD_D=getdate(),@p_LSTUPDUSR_CF=suser_name()
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin tran
end

insert TLIFNEWBIZ
  (
  CTR_NF
 ,END_NT
 ,SEC_NF
 ,ACY_NF
 ,ACMTRS_NT
 ,CRE_D
 ,NEWBIZ_R
 ,CREUSR_CF
  )
 values
  (
  @p_CTR_NF
 ,@p_END_NT
 ,@p_SEC_NF
 ,@p_ACY_NF
 ,@p_ACMTRS_NT
 ,@p_LSTUPD_D
 ,@p_NEWBIZ_R
 ,@p_LSTUPDUSR_CF
  )
select @erreur=@@error
if @erreur!=0
begin
  if @erreur=2601
    select @p_erreur="20002 APPLICATIF;2601;TLIFNEWBIZ"
  else
    select @p_erreur="20001 APPLICATIF;TLIFNEWBIZ " + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
if object_id('dbo.PiLIFNEWBIZ_01') is not null
  print '<<< CREATED procedure dbo.PiLIFNEWBIZ_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PiLIFNEWBIZ_01 >>>'
go
grant execute on dbo.PiLIFNEWBIZ_01 To GOMEGA
go
