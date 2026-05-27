use BEST
go
if object_id('dbo.PsTSEGPOR_SEG') is not null
begin
  drop PROC dbo.PsTSEGPOR_SEG
  print '<<< DROPPED PROC dbo.PsTSEGPOR_SEG >>>'
end
go
create procedure PsTSEGPOR_SEG
  (
  @P_SSD_CF    USSD_CF
 ,@P_SEGTYP_CT USEGTYP_CT
  )
as
/***************************************************
Domaine : Estimations
Base principale : BEST
Auteur: Florent
Date de creation: 17/10/2014
Description du programme: :spot:27466 Extraction du périmètre au format de BSAR..TSEGPOR (table plus utilisée)
Conditions d'execution: par les batch asynchrones de la segmentation
Commentaires:
_________________
MODIFICATIONS
1 Florent 30/10/2014 :spot:27722 on prend la dernière cédante du contrat valide pour le test de la rétro interne
2 Florent 01/06/2015 :spot:28694 Segmentation VIE
3 Florent 24/05/2017 :spira:58025 Création de la proc en BEST avec nouveau nom
*****************************************************/
if exists(select 1 from BREF..TESB where LIFE_CF=2 and SSD_CF=@P_SSD_CF)
begin --Dommage
  select distinct c.CTR_NF,c.END_NT,s.SEC_NF,SEGTYP_CT=@P_SEGTYP_CT,c.SSD_CF
  ,CTRNAT_CT=case when s.NAT_CF < '30' then 'P' else 'N' end
  ,CTRRET_B=isnull((select case when i.CLISSD_CF=null then 0 else 1 end from BCLI..TCLIENT i where i.CLI_NF=(select max(y.CED_NF) from BTRT..TCONTR y where y.CTR_NF=c.CTR_NF
                     and y.UWY_NF=(select max(z.UWY_NF) from BTRT..TCONTR z where c.CTR_NF=z.CTR_NF
                                    and z.CTRTYP_CT=1 and z.CTRSTS_CT IN(14,16,17,19,23)
                                        ) )),0)
   from BTRT..TSECTION s, BTRT..TCONTR c
    where c.SSD_CF=@P_SSD_CF
      and c.CTR_NF=s.CTR_NF
      and c.UWY_NF=s.UWY_NF
      and c.UW_NT=s.UW_NT
      and c.END_NT=s.END_NT
      and c.SSD_CF=s.SSD_CF
      and s.SSD_CF=@P_SSD_CF
      and s.LOB_CF not in('30','31')
      and s.SECSTS_CT IN(14,16,17,19,23)
      and c.CTRSTS_CT IN(14,16,17,19,23)
      and s.SECACCSTS_CT!=9
  union
  select distinct c.CTR_NF,c.END_NT,s.SEC_NF,SEGTYP_CT=@P_SEGTYP_CT,c.SSD_CF
  ,CTRNAT_CT='F'
  ,CTRRET_B=isnull((select case when i.CLISSD_CF=null then 0 else 1 end from BCLI..TCLIENT i where i.CLI_NF=(select max(y.CED_NF) from BFAC..TCONTR y where y.CTR_NF=c.CTR_NF
                     and y.UWY_NF=(select max(z.UWY_NF) from BFAC..TCONTR z where c.CTR_NF=z.CTR_NF
                                    and z.CTRTYP_CT=1 and z.CTRSTS_CT IN(14,16,17,19,23)
                                        ) )),0)
   from BFAC..TSECTION s, BFAC..TCONTR c
    where c.SSD_CF=@P_SSD_CF
      and c.CTR_NF=s.CTR_NF
      and c.UWY_NF=s.UWY_NF
      and c.UW_NT=s.UW_NT
      and c.END_NT=s.END_NT
      and c.SSD_CF=s.SSD_CF
      and s.SSD_CF=@P_SSD_CF
      and s.SECSTS_CT IN(16,18,19)
      and c.CTRSTS_CT IN(16,18,19)
      and s.SECACCSTS_CT!=9
  order by c.CTR_NF,c.END_NT,s.SEC_NF
end
else -- Vie: BTRT uniquement
begin
  select distinct c.CTR_NF,c.END_NT,s.SEC_NF,SEGTYP_CT=@P_SEGTYP_CT,c.SSD_CF
  ,CTRNAT_CT=case when s.NAT_CF < '30' then 'P' else 'N' end
  ,CTRRET_B=isnull((select case when i.CLISSD_CF=null then 0 else 1 end from BCLI..TCLIENT i where i.CLI_NF=(select max(y.CED_NF) from BTRT..TCONTR y where y.CTR_NF=c.CTR_NF
                     and y.UWY_NF=(select max(z.UWY_NF) from BTRT..TCONTR z where c.CTR_NF=z.CTR_NF
                                    and (   (z.CTRTYP_CT=1 and z.CTRSTS_CT IN(14,16,17,19,23))
                                         or (z.CTRTYP_CT=2 and z.CTRSTS_CT IN(16,18,19))
                                        )) )),0)
   from BTRT..TSECTION s, BTRT..TCONTR c
    where c.SSD_CF=@P_SSD_CF
      and c.CTR_NF=s.CTR_NF
      and c.UWY_NF=s.UWY_NF
      and c.UW_NT=s.UW_NT
      and c.END_NT=s.END_NT
      and c.SSD_CF=s.SSD_CF
      and s.SSD_CF=@P_SSD_CF
      and s.LOB_CF in('30','31')
      and s.SECSTS_CT IN(14,16,17,19,23)
      and c.CTRSTS_CT IN(14,16,17,19,23)
      and s.SECACCSTS_CT!=9
      and c.ESTCRB_CT='E'
  order by c.CTR_NF,c.END_NT,s.SEC_NF
end
go
if object_id('dbo.PsTSEGPOR_SEG') is not null
  print '<<< CREATED PROC dbo.PsTSEGPOR_SEG >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsTSEGPOR_SEG >>>'
go
grant execute on dbo.PsTSEGPOR_SEG TO GOMEGA, GDBBATCH
go
