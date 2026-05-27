use BEST
go
if object_id('dbo.PsRESSUM_01') is not null
begin
  drop PROC dbo.PsRESSUM_01
  print '<<< DROPPED PROC dbo.PsRESSUM_01 >>>'
end
go
create procedure PsRESSUM_01
  (
  @p_end_nt UEND_NT
 ,@p_sec_nf USEC_NF
 ,@p_uw_nt  UUW_NT
 ,@p_uwy_nf UUWY_NF
 ,@p_ctr_nf UCTR_NF
 ,@p_LAG_CF ULAG_CF='F'
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER- ASCOTT- ME01)
Date de creation: 20/05/1997
Description du programme: Sélection d'enregistrement dans TRESSUM
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 Florent   23/05/2012 :spot:23390 SOLVENCY II, ajout de PRS_CF 730 (EBS)
*****************************************************/
declare @erreur int

select
  ctr_nf
 ,end_nt
 ,sec_nf
 ,uw_nt
 ,uwy_nf
 ,broker_m
 ,cur_cf
 ,dacost_m
 ,difbro_m
 ,ibnr_m
 ,loadin_m
 ,loscom_m
 ,losses_m
 ,osibnr_m
 ,prm_m
 ,procom_m
 ,uneprm_m
 ,prs_cf
 ,prs_ls =(select colval_ls from BREF..TBANALL where LAG_CF=@p_LAG_CF and COL_LS='PRS_CF' and COLVAL_CT=convert(char(5),a.prs_cf))
 ,prime_acquise = isnull(prm_m,0) + isnull(uneprm_m,0)
 ,charge_acquise = isnull(loadin_m,0) + isnull(dacost_m,0)
 ,sinistralite_totale = isnull(losses_m,0) + isnull(osibnr_m,0)
 -- resultat_acquis = prime_acquise + charge_acquise + sinistralite_totale
 ,resultat_acquis = isnull(prm_m,0) + isnull(uneprm_m,0) + isnull(loadin_m,0) + isnull(dacost_m,0) + isnull(losses_m,0) + isnull(osibnr_m,0)
 ,courtage_acquis = isnull(broker_m,0) + isnull(difbro_m,0)
 ,participation = isnull(procom_m,0) + isnull(loscom_m,0)
 -- resultat1 = resultat_acquis + courtage_acquis + participation
 ,resultat1 = isnull(prm_m,0) + isnull(uneprm_m,0) + isnull(loadin_m,0) + isnull(dacost_m,0) + isnull(losses_m,0) + isnull(osibnr_m,0) + isnull(broker_m,0) + isnull(difbro_m,0) + isnull(procom_m,0) + isnull(loscom_m,0)
 -- resultat2 = resultat1 / prime_acquise * 100
 ,resultat2 = round((isnull(prm_m,0) + isnull(uneprm_m,0) + isnull(loadin_m,0) + isnull(dacost_m,0) + isnull(losses_m,0) + isnull(osibnr_m,0) + isnull(broker_m,0) + isnull(difbro_m,0) + isnull(procom_m,0) + isnull(loscom_m,0)) / (case when isnull(prm_m,0) + isnull(uneprm_m,0) = 0 then 999999999999999.999 else isnull(prm_m,0) + isnull(uneprm_m,0) end) * 100,3)
 -- resultat3 = resultat2 - 100
 ,resultat3 = round((isnull(prm_m,0) + isnull(uneprm_m,0) + isnull(loadin_m,0) + isnull(dacost_m,0) + isnull(losses_m,0) + isnull(osibnr_m,0) + isnull(broker_m,0) + isnull(difbro_m,0) + isnull(procom_m,0) + isnull(loscom_m,0)) / (case when isnull(prm_m,0) + isnull(uneprm_m,0) = 0 then 999999999999999.999 else isnull(prm_m,0) + isnull(uneprm_m,0) end) * 100,3) - 100
 -- si prime_acquise = 0 alors prime_acquise = 999999999999999.999
 -- charge_acquise_r = charge_acquise / prime_acquise * 100
 ,charge_acquise_r = round((isnull(loadin_m,0) + isnull(dacost_m,0)) / (case when isnull(prm_m,0) + isnull(uneprm_m,0) = 0 then 999999999999999.999 else isnull(prm_m,0) + isnull(uneprm_m,0) end) * 100,3)
 -- sinistralite_totale_r = sinistralite_totale / prime_acquise * 100
 ,sinistralite_totale_r = round((isnull(losses_m,0) + isnull(osibnr_m,0)) / (case when isnull(prm_m,0) + isnull(uneprm_m,0) = 0 then 999999999999999.999 else isnull(prm_m,0) + isnull(uneprm_m,0) end) * 100,3)
 -- resultat_acquis_r1 = resultat_acquis / prime_acquise * 100
 ,resultat_acquis_r1 = round((isnull(prm_m,0) + isnull(uneprm_m,0) + isnull(loadin_m,0) + isnull(dacost_m,0) + isnull(losses_m,0) + isnull(osibnr_m,0)) / (case when isnull(prm_m,0) + isnull(uneprm_m,0) = 0 then 999999999999999.999 else isnull(prm_m,0) + isnull(uneprm_m,0) end) * 100,3)
 -- resultat_acquis_r2 = resultat_acquis_r1 - 100
 ,resultat_acquis_r2 = round((isnull(prm_m,0) + isnull(uneprm_m,0) + isnull(loadin_m,0) + isnull(dacost_m,0) + isnull(losses_m,0) + isnull(osibnr_m,0)) / (case when isnull(prm_m,0) + isnull(uneprm_m,0) = 0 then 999999999999999.999 else isnull(prm_m,0) + isnull(uneprm_m,0) end) * 100,3) - 100
 from TRESSUM a
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf
    and prs_cf in(710,730)  -- modif 1
select @erreur = @@error
if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TRESSUM"
  return @erreur
end

return 0
go
if object_id('dbo.PsRESSUM_01') is not null
  print '<<< CREATED PROC dbo.PsRESSUM_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsRESSUM_01 >>>'
go
grant execute on dbo.PsRESSUM_01 TO GOMEGA
go
