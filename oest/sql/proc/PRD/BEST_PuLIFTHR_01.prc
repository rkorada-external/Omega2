use BEST
go
if object_id('dbo.PuLIFTHR_01') IS NOT null
begin
  drop PROC dbo.PuLIFTHR_01
  print '<<< DROPPED PROC dbo.PuLIFTHR_01 >>>'
end
go
create procedure PuLIFTHR_01
  (
  @p_SSD_CF    USSD_CF
 ,@p_ESB_CF    UESB_CF
 ,@p_CUR_CF    UCUR_CF
 ,@p_AMT_M     UAMT_M
 ,@p_CREUSR_CF UUSR_CF
 ,@p_erreur   varchar(64) = null output
  )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Version: 1
Auteur: Florent
Date de creation: 15/11/2004
Description du programme: Fenêtre de référence seuil et destinataires
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare
  @erreur int
 ,@tran_imbr bit

select @erreur = 0, @tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

if @p_CREUSR_CF=null
begin
  --cas de la création d'un seuil
  insert TLIFTHR
    (
     SSD_CF
    ,ESB_CF
    ,CUR_CF
    ,AMT_M
    ,CREUSR_CF
    ,CRE_D
    ,LSTUPDUSR_CF
    ,LSTUPD_D
    )
  select
     @p_SSD_CF
    ,@p_ESB_CF
    ,@p_CUR_CF
    ,@p_AMT_M
    ,suser_name()
    ,getdate()
    ,suser_name()
    ,getdate()
  select @erreur=@@error
  if @erreur!=0
  begin
    if @erreur=2601
      select @p_erreur="20002 APPLICATIF;TLIFTHR"
    else
      select @p_erreur="20001 APPLICATIF;TLIFTHR" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end
else
begin
  update TLIFTHR
   set AMT_M = @p_AMT_M
      ,LSTUPDUSR_CF = suser_name()
      ,LSTUPD_D = convert(char(8),getdate(),112)
    from TLIFTHR
     where SSD_CF=@p_SSD_CF
       and ESB_CF=@p_ESB_CF
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20004 APPLICATIF;TLIFTHR.AMT_M" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PuLIFTHR_01') IS NOT null
  print '<<< CREATED PROC dbo.PuLIFTHR_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuLIFTHR_01 >>>'
go
grant execute on dbo.PuLIFTHR_01 TO GOMEGA
go
