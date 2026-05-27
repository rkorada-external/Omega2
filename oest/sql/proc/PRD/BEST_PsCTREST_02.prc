use BEST
go
if object_id('dbo.PsCTREST_02') is not null
begin
  drop PROC dbo.PsCTREST_02
  print '<<< DROPPED PROC dbo.PsCTREST_02 >>>'
end
go
create procedure PsCTREST_02
  (
  @p_end_nt UEND_NT
 ,@p_sec_nf USEC_NF
 ,@p_uw_nt  UUW_NT
 ,@p_uwy_nf UUWY_NF
 ,@p_ctr_nf UCTR_NF
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER - ASCOTT)
Date de creation: 20/05/1997
Description du programme: Sélection d'enregistrement dans TCTREST
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 L.DEBEVER 21/01/1998 pour le type 10100, mt proposé, mt manuels et mt retenu sont en fait des taux en % et sont donc multipliés par 100 en lecture
2 Florent   23/05/2012 :spot:23390 SOLVENCY II, ajout de PRS_CF 730 (EBS)
*****************************************************/
select
  acmtrs_nt
 ,cre_d
 ,ctr_nf
 ,end_nt
 ,prs_cf
 ,sec_nf
 ,uw_nt
 ,uwy_nf
 ,admmod_ct
 ,calamt_m = calamt_m * case when acmtrs_nt=10100 then 100 else 1 end
 ,clodat_d
 ,creusr_cf
 ,cur_cf
 ,div_nt
 ,entamt_m = entamt_m * case when acmtrs_nt=10100 then 100 else 1 end
 ,lstupd_d
 ,lstupdusr_cf
 ,oricod_ls
 ,retamt_m = retamt_m * case when acmtrs_nt=10100 then 100 else 1 end
 ,ssd_cf
 ,updusr_cf
 from TCTREST
  where acmtrs_nt in(10100,20000,21000,22000,23000)
    and ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and prs_cf in(710,730) --modif 2
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf
if @@error!=0
begin
  raiserror 20005 "APPLICATIF;TCTREST"
  return 999
end

return 0
go
if object_id('dbo.PsCTREST_02') is not null
  print '<<< CREATED PROC dbo.PsCTREST_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsCTREST_02 >>>'
go
grant execute on dbo.PsCTREST_02 TO GOMEGA
go
