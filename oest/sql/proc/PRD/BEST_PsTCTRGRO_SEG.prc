use BEST
go
if object_id('dbo.PsTCTRGRO_SEG') is not null
begin
  drop PROC dbo.PsTCTRGRO_SEG
  print '<<< DROPPED PROC dbo.PsTCTRGRO_SEG >>>'
end
go
create procedure PsTCTRGRO_SEG
  (
  @P_SSD_CF    USSD_CF
 ,@P_SEGTYP_CT USEGTYP_CT
 ,@P_VRS_NF    numeric(10,0)
  )
as
/***************************************************
Domaine : Estimations
Base principale : BEST
Auteur: Florent
Date de creation: 24/05/2017
Description du programme: :spira:58025 gestion segmentation estimation uniquqment dans base BEST
Conditions d'execution: par le batch asynchrone de la segmentation : ESED0401.cmd
Commentaires: exclusivement pour le mode batch 3 qui vient de la copie d'une version précédente
_________________
MODIFICATIONS
*****************************************************/
select CTR_NF,END_NT,SEC_NF,VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF,DIV_NT,CED_NF,UWGRP_CF,LOB_CF,SOB_CF,TOP_CF,NAT_CF
,SUBNAT_CF,PCPRSKTRY_CF,SECINC_D,SECCAN_D,CTRRET_B,CRE_D
,CTRNAT_CF=case when (select distinct CTRTYP_CT from BFAC..TCONTR f
                        where a.CTR_NF=f.CTR_NF and a.END_NT=f.END_NT and a.SSD_CF=f.SSD_CF
                          and f.CTRSTS_CT IN(16,18,19))=2 then 'F'
                 when (select distinct max(NAT_CF) from BTRT..TSECTION s
                        where a.CTR_NF=s.CTR_NF and a.END_NT=s.END_NT and a.SSD_CF=s.SSD_CF
                          and a.SEC_NF=s.SEC_NF and s.SECSTS_CT IN(14,16,17,19,23)) < '30' then 'P' else 'N'
            end, UWY_NF
 from TCTRGRO a
  where VRS_NF=@P_VRS_NF and SSD_CF=@P_SSD_CF and SEGTYP_CT=@P_SEGTYP_CT
order by a.CTR_NF,a.END_NT,a.SEC_NF,a.SSD_CF,a.SEGTYP_CT,a.SEG_NF,a.UWY_NF 
go
if object_id('dbo.PsTCTRGRO_SEG') is not null
  print '<<< CREATED PROC dbo.PsTCTRGRO_SEG >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsTCTRGRO_SEG >>>'
go
grant execute on dbo.PsTCTRGRO_SEG TO GOMEGA, GDBBATCH
go
