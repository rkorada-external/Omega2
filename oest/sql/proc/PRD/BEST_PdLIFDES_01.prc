use BEST
go
if object_id('dbo.PdLIFDES_01') IS NOT null
begin
  drop PROC dbo.PdLIFDES_01
  print '<<< DROPPED PROC dbo.PdLIFDES_01 >>>'
end
go
create procedure PdLIFDES_01
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
Date de creation: 04/11/2004
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

delete TLIFDES
 where SSD_CF=@p_SSD_CF
   and ESB_CF=@p_ESB_CF
   and UWGRP_CF=@p_UWGRP_CF
   and USR_CF=@p_USR_CF
select @erreur=@@error
if @erreur!=0
begin
  select @p_erreur="20003 APPLICATIF;TLIFDES" + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PdLIFDES_01') IS NOT null
  print '<<< CREATED PROC dbo.PdLIFDES_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PdLIFDES_01 >>>'
go
grant execute on dbo.PdLIFDES_01 TO GOMEGA
go
