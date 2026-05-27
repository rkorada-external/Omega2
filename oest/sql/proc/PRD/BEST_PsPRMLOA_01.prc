use BEST
go
if object_id('dbo.PsPRMLOA_01') is not null
begin
  drop PROC dbo.PsPRMLOA_01
  print '<<< DROPPED PROC dbo.PsPRMLOA_01 >>>'
end
go
create procedure PsPRMLOA_01
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
Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER -ASCOTT)
Date de creation: 20/05/1997
Description du programme: Sélection d'enregistrement dans TPRMLOA
Conditions d'execution:
Commentaires:
_________________
MODIFICATION
1 DEBEVER      22/08/1997 Modif PROVISOIRE pour éviter de relivrer une PBL, Rajout selection sur code filiale à partir du contrat et non d'un paramètre
                          --> RAJOUTER LE PARAMETRE APRES RECETTE D'AOUT
2 O.Arik(AURA) 06/06/2001 Recuperation des lignes correspondant au courtage sur REC (acmtrs_nt=10401)
3 Florent      23/05/2012 :spot:23390 SOLVENCY II, ajout de PRS_CF 730 (EBS)
*****************************************************/
declare
  @erreur int
 ,@ssd    USSD_CF

select @ssd=convert(tinyint,substring(@p_ctr_nf,1,2))

select
  A.acmtrs_nt
 ,@p_ctr_nf
 ,@p_end_nt
 ,A.prs_cf
 ,@p_sec_nf
 ,@p_uw_nt
 ,@p_uwy_nf
 ,P.cur_cf
 ,P.estacc_m
 ,P.recacc_m
 ,P.reserv_m
 ,A.prs_cf
 ,A.acmtrs_nt
 ,A.acmtrs_ls
 ,total = P.estacc_m + P.recacc_m
 ,prs_ls=(select colval_ls from BREF..TBANALL where LAG_CF=@p_LAG_CF and COL_LS='PRS_CF' and COLVAL_CT=convert(char(5),A.prs_cf))
 from TPRMLOA P, BREF..TACMTRSH A
  where A.acmtrs_nt in(10020,10120,10320,10420,10000,10100,10300,10400,10401) -- modif 3
    and P.ctr_nf = @p_ctr_nf
    and P.end_nt = @p_end_nt
    and A.prs_cf in(710,730)  -- modif 3
    and P.sec_nf = @p_sec_nf
    and P.uw_nt = @p_uw_nt
    and P.uwy_nf = @p_uwy_nf
    and P.acmtrs_nt =* A.acmtrs_nt
    and P.prs_cf =* A.prs_cf
    and A.ssd_cf = @ssd
order by A.prs_cf,A.acmtrs_nt
select @erreur = @@error
if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TPRMLOA"
  return @erreur
end
return 0
go
if object_id('dbo.PsPRMLOA_01') is not null
  print '<<< CREATED PROC dbo.PsPRMLOA_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsPRMLOA_01 >>>'
go
grant execute on dbo.PsPRMLOA_01 TO GOMEGA
go
