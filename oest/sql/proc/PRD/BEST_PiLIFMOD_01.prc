use BEST
go
if object_id('dbo.PiLIFMOD_01') IS NOT null
begin
  drop procedure dbo.PiLIFMOD_01
  if object_id('dbo.PiLIFMOD_01') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PiLIFMOD_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PiLIFMOD_01 >>>'
end
go
create procedure PiLIFMOD_01
  (
   @p_CTR_NF       UCTR_NF
  ,@p_SEC_NF       USEC_NF
  ,@p_CRE_D        datetime
  ,@p_BALSHEY_NF   smallint
  ,@p_BALSHTMTH_NF tinyint
  ,@p_SSD_CF       USSD_CF
  ,@p_TYPMOD1_CT   tinyint
  ,@p_TYPMOD2_CT   tinyint
  ,@p_CUR_CF       UCUR_CF
  ,@p_CMT_NT       UCMT_NT
  ,@p_erreur       varchar(64) = null output
  )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 01/09/2004
Description du programme: estimation Vie, suivi dépassement du seuil
Conditions d'execution: par w_reponse_seuil_lifmod
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare
  @erreur    int,
  @tran_imbr bit

select @erreur = 0, @tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

insert TLIFMOD
  (
   CTR_NF
  ,SEC_NF
  ,CRE_D
  ,BALSHEY_NF
  ,BALSHTMTH_NF
  ,SSD_CF
  ,TYPMOD1_CT
  ,TYPMOD2_CT
  ,CUR_CF
  ,CMT_NT
  ,ORICOD_LS
  ,CREUSR_CF
  ,LSTUPD_D
  ,LSTUPDUSR_CF
  )
select
   @p_CTR_NF
  ,@p_SEC_NF
  ,@p_CRE_D
  ,@p_BALSHEY_NF
  ,@p_BALSHTMTH_NF
  ,@p_SSD_CF
  ,@p_TYPMOD1_CT
  ,@p_TYPMOD2_CT
  ,@p_CUR_CF
  ,@p_CMT_NT
  ,'TP'
  ,suser_name()
  ,getdate()
  ,suser_name()
select @erreur=@@error
if @erreur!=0
begin
  if @erreur=2601
    select @p_erreur="20002 APPLICATIF;TLIFMOD"
  else
    select @p_erreur="20001 APPLICATIF;TLIFMOD" + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PiLIFMOD_01') IS NOT null
  print '<<< CREATED procedure dbo.PiLIFMOD_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PiLIFMOD_01 >>>'
go
grant execute on dbo.PiLIFMOD_01 TO GOMEGA
go
