use BEST
go
if object_id('dbo.PiLIFDES_01') IS NOT null
begin
  drop PROC dbo.PiLIFDES_01
  print '<<< DROPPED PROC dbo.PiLIFDES_01 >>>'
end
go
create procedure PiLIFDES_01
  (
  @p_SSD_CF   USSD_CF
 ,@p_ESB_CF   UESB_CF
 ,@p_UWGRP_CF UGRP_CF
 ,@p_USR_CF   UUSR_CF
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

insert TLIFDES
  (
   SSD_CF
  ,ESB_CF
  ,UWGRP_CF
  ,USR_CF
  ,CREUSR_CF
  ,CRE_D
  ,LSTUPDUSR_CF
  ,LSTUPD_D
  )
select
   @p_SSD_CF
  ,@p_ESB_CF
  ,@p_UWGRP_CF
  ,@p_USR_CF
  ,suser_name()
  ,getdate()
  ,suser_name()
  ,getdate()
select @erreur=@@error
if @erreur!=0
begin
  if @erreur=2601
    select @p_erreur="20002 APPLICATIF;TLIFDES"
  else
    select @p_erreur="20001 APPLICATIF;TLIFDES" + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PiLIFDES_01') IS NOT null
  print '<<< CREATED PROC dbo.PiLIFDES_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PiLIFDES_01 >>>'
go
grant execute on dbo.PiLIFDES_01 TO GOMEGA
go
