USE BEST
go
IF OBJECT_ID('dbo.PtRETCATCVR_ACCSUP_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PtRETCATCVR_ACCSUP_01
  IF OBJECT_ID('dbo.PtRETCATCVR_ACCSUP_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtRETCATCVR_ACCSUP_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PtRETCATCVR_ACCSUP_01 >>>'
END
go
create procedure dbo.PtRETCATCVR_ACCSUP_01
(
 @p_ICLODAT_D   datetime
,@p_POSTOMEGA_B bit=0
)
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 09/02/2015
Description du programme: sélection des cat cover du trimestre et du site géographique pour les nouvelle ES de TACCSUP
                          et insertion dans la TACCSUP   
Conditions d'execution: par ESIJ2001.cmd
Commentaires: doit être au format de BTRAV..EST_ESID0801_TESTUTISUP
_________________
MODIFICATIONS
1 Florent :spot:28935 30/06/2015 ajout gestion de @p_ICLODAT_D
2 Florent :spot:29163 05/04/2016 correction sous requête pour lister les anomalies
*****************************************************/
declare
 @SSD     USSD_CF
,@erreur  int
,@lignes  int
,@TRN_MIN int
,@retour  int
,@utilisateur UUPDUSR_CF

create table #CATCVRDETTRS
(
 ACMTRS_NT  smallint   NOT NULL
,DETTRS_CF  UDETTRS_CF NOT NULL
,CTRSCOD_CF UDETTRS_CF DEFAULT '' NOT NULL
)
if @@error!=0 goto erreur

exec @retour=PsRETCATCVR_DETTRS_01
if @@error!=0 or @retour!=0 goto erreur

--pour la gestion du compteur TRT_NT et NUMLINE_NT
create table #NUMACC
(
  TRN_NT     numeric(10,0) identity
 ,RCATCVR_NT numeric(10,0) not null
 ,SSD_CF     USSD_CF       not null
)
if @@error!=0 goto erreur

select @utilisateur=suser_name()

insert #NUMACC(RCATCVR_NT,SSD_CF)
select RCATCVR_NT,SSD_CF
 from TRETCATCVR a
  where BALSH_D=@p_ICLODAT_D
    and SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
    --Nouvelle ES
    and (case when BOOKING_B=1 and TRN_NT=null and ULTAMT_M=(isnull(RETCEDAMT_M,0)+isnull(TRNAMT_M,0)) then 1 else 0 end)=1
order by SSD_CF,RETCTR_NF,RTY_NF,RETSEC_NF,AECUR_CF
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur
if @lignes=0
begin
  print 'NO ES to create !  exiting'
  return 0
end
print 'selection des nouvelles écritures services pour faire un compteur avec l''identity, lignes %1!',@lignes
	
print 'sélection des filiales à gérer pour les ES'
select distinct SSD_CF
into #TSSD
 from #NUMACC

print 'on prend la première filiale de la liste'
set rowcount 1
select @SSD=SSD_CF from #TSSD
delete #TSSD
set rowcount 0

select @TRN_MIN=max(TRN_NT) FROM BEST..TACCSUP
print 'on enregistre à partir de quel n° d''ES on insère les lignes %1!',@TRN_MIN

print 'vidage de la table de travail des ES'
truncate table BTRAV..EST_ESID0801_TESTUTISUP
if @@error!=0 goto erreur

print 'bouclage sur la filiale et envoi PiACCSUP_02'
while @SSD!=null
begin
  insert BTRAV..EST_ESID0801_TESTUTISUP
  (TRN_NT,ACCTYP_NF,SSD_CF,ESB_CF,ENTPERY_NF,ENTPERMTH_NF,BALSHEY_NF,BALSHRMTH_NF,BALSHRDAY_NF,VALPERY_NF,VALPERMTH_NF,TRNCOD_CF,DBLTRNCOD_CF,RETAUTGEN_B,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,OCCYEA_NF,ACY_NF,SCOSTRMTH_NF,SCOENDMTH_NF,CLM_NF,CUR_CF,AMT_M,CED_NF,BRK_NF,GEMPRMPAY_NF,GANPAYORD_NT,RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,PLC_NT,RETOCCYEA_NF,RETACY_NF,RETSCOSTRMTH_NF,RETSCOENDMTH_NF,RCL_NF,RETCUR_CF,RETAMT_M,RTO_NF,INT_NF,RETPAY_NF,RETKEY_CF,ACCTRN_NT,COMMAC_LL,CRE_D,CREUSR_CF,LSTUPD_D,LSTUPDUSR_CF,NUMLINE_NT,SPEENTTYP_CF,SPEENTNAT_CT)
  select
    c.TRN_NT
   ,ACCTYP_NF=case when PLC_NT=null then 2 else 4 end
   ,a.SSD_CF
   ,ESB_CF
   ,ENTPERY_NF=Year(BALSH_D)
   ,ENTPERMTH_NF=Month(BALSH_D)
   ,BALSHEY_NF=Year(BALSH_D)
   ,BALSHRMTH_NF=Month(BALSH_D)
   ,BALSHRDAY_NF=Day(BALSH_D)
   ,VALPERY_NF=Year(BALSH_D)
   ,VALPERMTH_NF=Month(BALSH_D)
   ,TRNCOD_CF=b.DETTRS_CF
   ,DBLTRNCOD_CF=b.CTRSCOD_CF
   ,RETAUTGEN_B=0
   ,CTR_NF=null
   ,END_NT=null
   ,SEC_NF=null
   ,UWY_NF=null
   ,UW_NT=null
   ,OCCYEA_NF=null
   ,ACY_NF=null
   ,SCOSTRMTH_NF=null
   ,SCOENDMTH_NF=null
   ,CLM_NF=null
   ,CUR_CF=null
   ,AMT_M=null
   ,CED_NF=null
   ,BRK_NF=null
   ,GEMPRMPAY_NF=null
   ,GANPAYORD_NT=null
   ,a.RETCTR_NF
   ,RETEND_NT=0
   ,a.RETSEC_NF
   ,a.RTY_NF
   ,RETUW_NT=1
   ,PLC_NT
   ,RETOCCYEA_NF=Year(BALSH_D)
   ,RETACY_NF=Year(BALSH_D)
   ,RETSCOSTRMTH_NF=Month(BALSH_D)
   ,RETSCOENDMTH_NF=Month(BALSH_D)
   ,RCL_NF
   ,RETCUR_CF=a.AECUR_CF
   ,RETAMT_M=TRNAMT_M
   ,RTO_NF=case when PLC_NT=null then null else (select x.RTO_NF from BRET..TPLACEMT x
                                                 where x.RETCTR_NF=a.RETCTR_NF and x.RTY_NF=a.RTY_NF and x.PLC_NT=a.PLC_NT
                                                   and x.HIS_B=0)end
   ,INT_NF=null
   ,RETPAY_NF=null
   ,RETKEY_CF=null
   ,ACCTRN_NT=null
   ,COMMAC_LL='CATCVR_'+STR(a.RCATCVR_NT,10)+case when RCL_NF=null then 'no claim' else 'CLM_'+convert(varchar,RCL_NF) end + ' of '+ convert(char(7),BALSH_D,111)
   ,CRE_D=getdate()
   ,CREUSR_CF=suser_name()
   ,LSTUPD_D=getdate()
   ,LSTUPDUSR_CF=suser_name()
   ,NUMLINE_NT=a.RCATCVR_NT
   ,SPEENTTYP_CF=7
   --Les écritures services sont créées en Post Omega IFRS avec une nature = 2
   ,SPEENTNAT_CT=case when @p_POSTOMEGA_B=0 then 1 else 2 end
   from TRETCATCVR a, #CATCVRDETTRS b, #NUMACC c
    where a.CATCVRDMN_CT=b.ACMTRS_NT
      and a.RCATCVR_NT=c.RCATCVR_NT
      and c.SSD_CF=@SSD
      and a.BALSH_D=@p_ICLODAT_D
  order by a.SSD_CF,RETCTR_NF,RTY_NF,RETSEC_NF,AECUR_CF
  if @@error!=0 goto erreur

  exec PiACCSUP_04 @SSD, @utilisateur
  -- si on a une erreur autre que des anomalies fonctionnelles on sort
  if @@error!=20113 and @@error!=0 goto erreur
  -- on prend la prochaine filiale dans la liste
  set rowcount 1
  select @SSD=SSD_CF from #TSSD
  if @@rowcount=0
    select @SSD=null
  else
  	delete #TSSD
  set rowcount 0
end

begin tran

update TRETCATCVR
 set TRN_NT=a.TRN_NT
  from TRETCATCVR c, TACCSUP a, #NUMACC b
   where a.TRN_NT > @TRN_MIN
     and b.RCATCVR_NT=convert(decimal(10,0),substring(a.COMMAC_LL,8,10))
     and b.RCATCVR_NT=c.RCATCVR_NT
     and c.SSD_CF=a.SSD_CF
     and a.COMMAC_LL like 'CATCVR_[ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9]%'
     and c.BALSH_D=@p_ICLODAT_D
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur
print 'on mets à jour les CAT COVER qui sont passées en ES avec le n° d''ES de TACCSUP, lignes %1!',@lignes
print '-- COMMAC_LL contient le n° de la CAT COVER'

update TACCSUP
 set COMMAC_LL=substring(a.COMMAC_LL,18,99)
  from TACCSUP a, #NUMACC b
   where a.TRN_NT > @TRN_MIN
     and b.RCATCVR_NT=convert(decimal(10,0),substring(a.COMMAC_LL,8,10))
     and a.COMMAC_LL like 'CATCVR_[ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9][ ,0-9]%'
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur
print 'on enlève le n° des CAT COVER de TACCSUP qui sont passées en ES, lignes %1!',@lignes

commit tran

print 'récup des anomalies qui peuvent exister'
select ANO_CT
,ANO_LM=(select COLVAL_LM from BREF..TBANTECL r where COL_LS='ANO_CT' and convert(int,COLVAL_CT)=a.ANO_CT and LAG_CF='F')
,b.*
 from TCTRANO a, TRETCATCVR b
   where VRS_NF=1
     and SEG_NF=@utilisateur
     and SEGTYP_CT='A'
     and b.RCATCVR_NT=a.NUMLINE_NT
     and b.BALSH_D=@p_ICLODAT_D
return 0

erreur:
if @@trancount > 0 rollback tran
return 999
go
IF OBJECT_ID('dbo.PtRETCATCVR_ACCSUP_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PtRETCATCVR_ACCSUP_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PtRETCATCVR_ACCSUP_01 >>>'
go
GRANT EXECUTE ON dbo.PtRETCATCVR_ACCSUP_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtRETCATCVR_ACCSUP_01 TO GDBBATCH
go
