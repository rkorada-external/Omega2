use BEST
go
if object_id('dbo.PsLIFDES_01') IS NOT null
begin
  drop procedure dbo.PsLIFDES_01
  if object_id('dbo.PsLIFDES_01') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PsLIFDES_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLIFDES_01 >>>'
end
go
create procedure PsLIFDES_01
  (
   @p_CTR_NF  UCTR_NF
  ,@p_RETRO_B bit=0
   )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 08/09/2004
Description du programme: estimation Vie, suivi dépassement du seuil, destinataire emel
Conditions d'execution: gu_app.iu_rs.uf_send_email
Commentaires: détail
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare
  @erreur     int
 ,@lignes     integer
 ,@SSD_CF     USSD_CF
 ,@ESB_CF     UESB_CF
 ,@UWGRP_CF   UGRP_CF

if @p_RETRO_B=1
begin
  select @SSD_CF=a.SSD_CF, @ESB_CF=a.ESB_CF, @UWGRP_CF=b.GRP_CF
   from BRET..TRETCTR a, BREF..TUSRANFN b
    where RETCTR_NF=@p_ctr_nf
      and RTY_NF=(select max(RTY_NF) from BRET..TRETCTR c where c.RETCTR_NF=@p_ctr_nf and RETCTRSTS_CT in (3,19))
      and a.ADMUSR_CF=b.USR_CF
      and b.PCPGRP_B=1
  select @erreur = @@error
  if @erreur != 0
  begin
    raiserror 20005 "APPLICATIF;TRETCTR"
    return @erreur
  end
end
else
begin
  select @SSD_CF=SSD_CF, @ESB_CF=ACCESB_CF, @UWGRP_CF=UWGRP_CF
   from BTRT..TCONTR
    where CTR_NF=@p_ctr_nf
  --    and b.LSTUWY_B=1
      and UWY_NF=(select max(UWY_NF) from BTRT..TCONTR c where c.CTR_NF=@p_ctr_nf and CTRSTS_CT in (14,17,16,19))
  select @erreur = @@error
  if @erreur != 0
  begin
    raiserror 20005 "APPLICATIF;TCLIENT/TCONTR"
    return @erreur
  end
end


select EMEL=isnull(USREML_LD,USRNME_LM+' '+USRFNME_LM)
 from TLIFDES a, BREF..TUSR b
  where a.SSD_CF=@SSD_CF
    and a.ESB_CF=@ESB_CF
    and a.UWGRP_CF=@UWGRP_CF
    and a.USR_CF=b.USR_CF

return 0
go
if object_id('dbo.PsLIFDES_01') IS NOT null
  print '<<< CREATED procedure dbo.PsLIFDES_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLIFDES_01 >>>'
go
grant execute on dbo.PsLIFDES_01 TO GOMEGA
go
