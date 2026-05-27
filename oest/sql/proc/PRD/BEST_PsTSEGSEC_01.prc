use BEST
go
if object_id('dbo.PsTSEGSEC_01') is not null
begin
  drop PROC dbo.PsTSEGSEC_01
  print '<<< DROPPED PROC dbo.PsTSEGSEC_01 >>>'
end
go
create procedure PsTSEGSEC_01
  (
  @p_segtyp_ct USEGTYP_CT
 ,@p_ssd_cf    USSD_CF
 ,@p_vrs_nf    Numeric
  )
as
/***************************************************
Domaine : Estimations
Base principale : BSAR
Version: 1
Auteur: ME57
Date de creation: 04/08/2004
Description du programme:  selection d'enregistrement dans tsegment_tsegest
Conditions d'execution:
Conditions d'execution: le segtyp_ct A de TSEGMENT joint sur le segtyp_ct A ou/et S de TSEGEST
_________________
MODIFICATIONS
1  Florent   14/02/2012 :spot:23390 SOLVENCY II,on prend aussi le segment S, T et U quand le type est A
*****************************************************/
declare
 @erreur int

select
  a.VRS_NF
 ,a.SSD_CF
 ,b.SEGTYP_CT -- modif 1
 ,a.SEG_NF
 ,a.SEG_LL
 ,a.CUR_CF
 ,a.SEGNAT_CT
 ,a.CTRRET_B
 ,a.ANO_B
 ,a.RETRO_NP  -- modif 1
 ,b.UWY_NF
 ,b.CRE_D
 ,b.PRMAMT_M
 ,b.CLMAMT_M
 ,LOSRAT_R=b.LOSRAT_R*10000 -- S/P en %
 ,b.AMORAT_CT
 from TSEGMENT a, TSEGEST b
  where a.VRS_NF=b.VRS_NF
   and a.SSD_CF=b.SSD_CF
   and ((@p_segtyp_ct='A' and b.SEGTYP_CT in('A','S','T','U')) or(@p_segtyp_ct!='A' and b.SEGTYP_CT=@p_segtyp_ct)) -- modif 1
   and a.SEG_NF=b.seg_nf
   and a.CUR_CF=b.CUR_CF
   and a.VRS_NF=@p_vrs_nf
   and a.SSD_CF=@p_ssd_cf
   and a.SEGTYP_CT=@p_segtyp_ct
order by a.VRS_NF,a.SEG_NF,b.UWY_NF
select @erreur = @@error
If @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TSEGMENT a, TSEGEST b"
  return @erreur
end

return 0
go
if object_id('dbo.PsTSEGSEC_01') is not null
  print '<<< CREATED PROC dbo.PsTSEGSEC_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsTSEGSEC_01 >>>'
go
grant execute on dbo.PsTSEGSEC_01 TO GOMEGA
go
