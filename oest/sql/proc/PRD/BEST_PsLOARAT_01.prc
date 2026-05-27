use BEST
go
IF OBJECT_ID('dbo.PsLOARAT_01') IS NOT NULL
begin
  drop PROC dbo.PsLOARAT_01
  print '<<< DROPPED PROC dbo.PsLOARAT_01 >>>'
end
go
create procedure PsLOARAT_01
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
Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER - ASCOTT)
Date de creation: 20/05/1997
Description du programme: Sélection d'enregistrement dans TLOARAT
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
 ,broker_r * 100
 ,commis_r * 100
 ,ovecom_r * 100
 ,tax_r * 100
 ,charges_r=(ovecom_r + commis_r) * 100
 ,prs_cf
 ,prs_ls =(select colval_ls from BREF..TBANALL where LAG_CF=@p_LAG_CF and COL_LS='PRS_CF' and COLVAL_CT=convert(char(5),a.prs_cf))
 from TLOARAT a
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf
select @erreur = @@error
if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TLOARAT"
  return @erreur
end
return 0
go
if object_id('dbo.PsLOARAT_01') is not null
  print '<<< CREATED PROC dbo.PsLOARAT_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsLOARAT_01 >>>'
go
grant execute on dbo.PsLOARAT_01 TO GOMEGA
go
