use BSAR
go
if object_id('dbo.PsTCTRGRO_EST') is not null
begin
  drop PROC dbo.PsTCTRGRO_EST
  print '<<< DROPPED PROC dbo.PsTCTRGRO_EST >>>'
end
go
create procedure PsTCTRGRO_EST
  (
  @P_SSD_CF    USSD_CF
 ,@P_SEGTYP_CT USEGTYP_CT
 ,@P_VRS_NF    numeric(10,0)
  )
as
/***************************************************
Domaine : Estimations
Base principale : BSAR
Auteur: Florent
Date de creation: 16/10/2014
Description du programme: :spot:27466 Extraction de TCTRGRO au format de BEST..TCTRGRO
Conditions d'execution: par les batch asynchrones de la segmentation
Commentaires:
_________________
MODIFICATIONS
1 Florent 30/10/2014 :spot:27722 on prend la dernière cédante du contrat valide pour le test de la rétro interne
2  Florent   01/06/2015 :spot:28694 Segmentation VIE
*****************************************************/
create table #TCTRGRO_EST
(
  CTR_NF       UCTR_NF       NOT NULL,
  END_NT       UEND_NT       NOT NULL,
  SEC_NF       USEC_NF       NOT NULL,
  VRS_NF       numeric(10,0) NOT NULL,
  SSD_CF       USSD_CF       NOT NULL,
  SEGTYP_CT    USEGTYP_CT    DEFAULT ''        NOT NULL,
  SEG_NF       USEG_NF       DEFAULT ''        NOT NULL,
  DIV_NT       UDIV_NT       NULL,
  CED_NF       UCLI_NF       NULL,
  UWGRP_CF     UGRP_CF       NULL,
  LOB_CF       ULOB_CF       NULL,
  SOB_CF       USOB_CF       NULL,
  TOP_CF       UTOP_CF       NULL,
  NAT_CF       UCTRNAT_CF    NULL,
  SUBNAT_CF    UCTRSUBNAT_CF NULL,
  PCPRSKTRY_CF UCTY_CF       NULL,
  SECINC_D     datetime      NULL,
  SECCAN_D     datetime      NULL,
  CTRRET_B     tinyint       DEFAULT 0         NOT NULL,
  CRE_D        UUPD_D        DEFAULT getdate() NOT NULL,
  CTRNAT_CF    char(1)       NULL
)

insert #TCTRGRO_EST (CTR_NF,END_NT,SEC_NF,VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF)
select CTR_NF,END_NT,SEC_NF,@P_VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF
 from BSAR..TCTRGRO a
  where a.SSD_CF=@P_SSD_CF
    and a.SEGTYP_CT=@P_SEGTYP_CT

create unique clustered index iCTRGRO_EST on #TCTRGRO_EST(CTR_NF,END_NT,SEC_NF)

-- update is done only in the case of contract being in the perimeter: valid contract not terminated
if exists(select 1 from BREF..TESB where LIFE_CF=2 and SSD_CF=@P_SSD_CF)
begin --Dommage
  update #TCTRGRO_EST
   set DIV_NT=s.DIV_NT
      ,CED_NF=c.CED_NF
      ,UWGRP_CF=c.UWGRP_CF
      ,LOB_CF=s.LOB_CF
      ,SOB_CF=s.SOB_CF
      ,TOP_CF=s.TOP_CF
      ,NAT_CF=s.NAT_CF
      ,SUBNAT_CF=s.SUBNAT_CF
      ,PCPRSKTRY_CF=s.PCPRSKTRY_CF
      ,SECINC_D=s.SECINC_D
      ,SECCAN_D=s.SECCAN_D
      ,CTRRET_B=isnull((select case when i.CLISSD_CF=null then 0 else 1 end from BCLI..TCLIENT i where i.CLI_NF=(select max(y.CED_NF) from BMIS..TCONTR y where y.CTR_NF=c.CTR_NF
                        and y.UWY_NF=(select max(z.UWY_NF) from BMIS..TCONTR z where c.CTR_NF=z.CTR_NF
                                       and (   (z.CTRTYP_CT=1 and z.CTRSTS_CT IN(14,16,17,19,23))
                                            or (z.CTRTYP_CT=2 and z.CTRSTS_CT IN(16,18,19))
                                           )) )),0)
       ,CTRNAT_CF=case when c.CTRTYP_CT=2 then 'F' when c.CTRTYP_CT=1 and s.NAT_CF < '30' then 'P' else 'N' end
   from #TCTRGRO_EST a, BMIS..TSECTION s, BMIS..TCONTR c
    where a.CTR_NF=c.CTR_NF
      and a.END_NT=c.END_NT
      and a.SSD_CF=c.SSD_CF
      and c.SSD_CF=@P_SSD_CF    
      and c.CTR_NF=s.CTR_NF
      and c.END_NT=s.END_NT
      and a.CTR_NF=s.CTR_NF
      and a.END_NT=s.END_NT
      and a.SEC_NF=s.SEC_NF
      and c.SSD_CF=s.SSD_CF
      and s.SSD_CF=@P_SSD_CF
      and (   (c.CTRTYP_CT=1 and s.LOB_CF not in('30','31') and s.SECSTS_CT IN(14,16,17,19,23) and c.CTRSTS_CT IN(14,16,17,19,23))
           or (c.CTRTYP_CT=2 and s.SECSTS_CT IN(16,18,19) and c.CTRSTS_CT IN(16,18,19))
          ) -- 1 TRT / 2 Facs
      and s.SECACCSTS_CT!=9
end
else -- Vie: BTRT uniquement
begin
  update #TCTRGRO_EST
   set DIV_NT=s.DIV_NT
      ,CED_NF=c.CED_NF
      ,UWGRP_CF=c.UWGRP_CF
      ,LOB_CF=s.LOB_CF
      ,SOB_CF=s.SOB_CF
      ,TOP_CF=s.TOP_CF
      ,NAT_CF=s.NAT_CF
      ,SUBNAT_CF=s.SUBNAT_CF
      ,PCPRSKTRY_CF=s.PCPRSKTRY_CF
      ,SECINC_D=s.SECINC_D
      ,SECCAN_D=s.SECCAN_D
      ,CTRRET_B=isnull((select case when i.CLISSD_CF=null then 0 else 1 end from BCLI..TCLIENT i where i.CLI_NF=(select max(y.CED_NF) from BMIS..TCONTR y where y.CTR_NF=c.CTR_NF
                        and y.UWY_NF=(select max(z.UWY_NF) from BMIS..TCONTR z where c.CTR_NF=z.CTR_NF
                                       and (   (z.CTRTYP_CT=1 and z.CTRSTS_CT IN(14,16,17,19,23))
                                            or (z.CTRTYP_CT=2 and z.CTRSTS_CT IN(16,18,19))
                                           )) )),0)
       ,CTRNAT_CF=case when s.NAT_CF < '30' then 'P' else 'N' end
   from #TCTRGRO_EST a, BTRT..TSECTION s, BTRT..TCONTR c
    where a.CTR_NF=c.CTR_NF
      and a.END_NT=c.END_NT
      and a.SSD_CF=c.SSD_CF
      and c.SSD_CF=@P_SSD_CF    
      and c.CTR_NF=s.CTR_NF
      and c.END_NT=s.END_NT
      and a.CTR_NF=s.CTR_NF
      and a.END_NT=s.END_NT
      and a.SEC_NF=s.SEC_NF
      and c.SSD_CF=s.SSD_CF
      and s.SSD_CF=@P_SSD_CF
      and s.LOB_CF in('30','31')
      and s.SECSTS_CT IN(14,16,17,19,23)
      and c.CTRSTS_CT IN(14,16,17,19,23)
      and s.SECACCSTS_CT!=9
      and c.ESTCRB_CT='E'
end
  
select * from #TCTRGRO_EST
order by CTR_NF,END_NT,SEC_NF,SSD_CF,SEGTYP_CT,SEG_NF
go
if object_id('dbo.PsTCTRGRO_EST') is not null
  print '<<< CREATED PROC dbo.PsTCTRGRO_EST >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsTCTRGRO_EST >>>'
go
grant execute on dbo.PsTCTRGRO_EST TO GOMEGA, GDBBATCH
go
