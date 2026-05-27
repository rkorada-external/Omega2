use BEST
go
if object_id('dbo.PsLIFDES_02') IS NOT null
begin
  drop procedure dbo.PsLIFDES_02
  if object_id('dbo.PsLIFDES_02') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PsLIFDES_02 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLIFDES_02 >>>'
end
go
create procedure PsLIFDES_02
  (
  @p_SSD_CF USSD_CF
 ,@p_ESB_CF UESB_CF
   )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 03/11/2004
Description du programme: estimation Vie, Fenêtre de référence seuil et destinataires
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare
  @erreur  int
 ,@LAG_CF  char(1)

select @LAG_CF=isnull(LAG_CF,'E') from BREF..TUSR where USR_CF=suser_name()
if @LAG_CF=null select @LAG_CF='E'

select
    a.SSD_CF
   ,a.ESB_CF
   ,a.UWGRP_CF
   ,a.USR_CF
   ,a.CREUSR_CF
   ,a.CRE_D
   ,a.LSTUPDUSR_CF
   ,a.LSTUPD_D
   ,UWGRP_LS=isnull((select GRP_LS from BREF..TGRP where GRP_CF=a.UWGRP_CF and SSD_CF=@p_SSD_CF),'')
   ,NOM=USRNME_LM+' '+USRFNME_LM
   ,EMEL=isnull(USREML_LD,USRNME_LM+' '+USRFNME_LM)
 from TLIFDES a, BREF..TUSR b
  where a.SSD_CF=@p_SSD_CF
    and a.ESB_CF=@p_ESB_CF
    and a.USR_CF=b.USR_CF
select @erreur = @@error
if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TCLIENT/TCONTR"
  return @erreur
end

return 0
go
if object_id('dbo.PsLIFDES_02') IS NOT null
  print '<<< CREATED procedure dbo.PsLIFDES_02 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLIFDES_02 >>>'
go
grant execute on dbo.PsLIFDES_02 TO GOMEGA
go
