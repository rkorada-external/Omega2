use BEST
go
if object_id('dbo.PsLIFTHR_02') IS NOT null
begin
  drop PROC dbo.PsLIFTHR_02
  print '<<< DROPPED PROC dbo.PsLIFTHR_02 >>>'
end
go
create procedure PsLIFTHR_02
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Version: 1
Auteur: Florent
Date de creation: 16/11/2004
Description du programme: Fenêtre de référence seuil et destinataires
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare
  @erreur int
 ,@LAG_CF char(1)
 ,@SITE   char(4)

select @SITE = case when substring(@@servername,4,1)='S' then 'SGP_'
                    when substring(@@servername,4,1)='N' then 'USA_'
                    when substring(@@servername,4,1)='P' then 'FRA_'
                    when @@servername='PRDU01_SRV' then 'FRAM' end -- serveur Mutre_Prd

select @LAG_CF=isnull(LAG_CF,'E') from BREF..TUSR where USR_CF=suser_name()
if @LAG_CF=null select @LAG_CF='E'

select b.SSD_CF
    ,c.ESB_CF
    ,b.SSD_LS
    ,c.ESB_LS
    ,CUR_CF=case when a.CUR_CF=null then b.SSDCUR_CF else a.CUR_CF end
    ,CUR_LS=(select x.CUR_LS from BREF..TCURL x where x.CUR_CF=IsNull(a.CUR_CF,b.SSDCUR_CF) and LAG_CF=@LAG_CF)
    ,a.AMT_M
    ,CREUSR_CF
    ,CRE_D
    ,LSTUPDUSR_CF
    ,LSTUPD_D
    ,BLOQUE_B=1
 from TLIFTHR a, BREF..TSUBSID b, BREF..TESB c
  where b.PRDSIT_CF like @SITE
    and b.SSD_CF*=a.SSD_CF
    and c.SSD_CF*=a.SSD_CF
    and c.ESB_CF*=a.ESB_CF
    and b.SSD_CF=c.SSD_CF
select @erreur=@@error
if @erreur != 0
begin
  raiserror 20005 'APPLICATIF;TLIFTHR/BREF..TSUBSID/BREF..TESB'
  return @erreur
end

return 0
go
if object_id('dbo.PsLIFTHR_02') IS NOT null
  print '<<< CREATED PROC dbo.PsLIFTHR_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsLIFTHR_02 >>>'
go
grant execute on dbo.PsLIFTHR_02 TO GOMEGA
go
