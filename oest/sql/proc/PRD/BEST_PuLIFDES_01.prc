use BEST
go
if object_id('dbo.PuLIFDES_01') IS NOT null
begin
  drop PROC dbo.PuLIFDES_01
  print '<<< DROPPED PROC dbo.PuLIFDES_01 >>>'
end
go
create procedure PuLIFDES_01
  (
  @p_SSD_CF       USSD_CF
 ,@p_ESB_CF       UESB_CF
 ,@p_UWGRP_CF     UGRP_CF
 ,@p_USR_CF       UUSR_CF
 ,@p_UWGRP_CF_old UGRP_CF
 ,@p_USR_CF_old   UUSR_CF
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

update TLIFDES
 set UWGRP_CF = @p_UWGRP_CF
    ,USR_CF = @p_USR_CF
    ,LSTUPDUSR_CF = suser_name()
    ,LSTUPD_D = getdate()
  from TLIFDES
   where SSD_CF=@p_SSD_CF
     and ESB_CF=@p_ESB_CF
     and UWGRP_CF=@p_UWGRP_CF_old
     and USR_CF=@p_USR_CF_old
select @erreur=@@error
if @erreur!=0
begin
  if @erreur=2601
    select @p_erreur="20002 APPLICATIF;TLIFDES"
  else
    select @p_erreur="20004 APPLICATIF;TLIFDES" + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PuLIFDES_01') IS NOT null
  print '<<< CREATED PROC dbo.PuLIFDES_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuLIFDES_01 >>>'
go
grant execute on dbo.PuLIFDES_01 TO GOMEGA
go
