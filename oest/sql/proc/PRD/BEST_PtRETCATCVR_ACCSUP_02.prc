USE BEST
go
IF OBJECT_ID('dbo.PtRETCATCVR_ACCSUP_02') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PtRETCATCVR_ACCSUP_02
  IF OBJECT_ID('dbo.PtRETCATCVR_ACCSUP_02') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtRETCATCVR_ACCSUP_02 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PtRETCATCVR_ACCSUP_02 >>>'
END
go
create procedure dbo.PtRETCATCVR_ACCSUP_02
(
 @p_ICLODAT_D   datetime
,@p_POSTOMEGA_B bit=0
)
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 03/03/2015
Description du programme: :spot:28139  Maj des ES venant des cat cover du trimestre et du site géographique
          Recalcul du montant d’écriture service  Cette action est déclenchée soit par:
           -  Une modification par l’utilisateur du montant d’ultime alors que la case « Booking » reste cochée.
               Dans ces deux cas, si « Booking » est à vrai et que l’égalité ULTAMT_M = TRNAMT_M + RETCEDAMT_M est vraie
                et qu’il y a un numéro d’écriture service de renseigné et que le montant d’écriture service dans TRETCATCVR
                 est différent du montant de l’écriture service dans TACCSUP
              Alors, modification du montant de cette écriture service en remplaçant l’ancien montant par TRNAMT_M.
              Le modificateur de l’écriture service est celui qui a modifié la ligne dans l’écran des écritures services cat cover.
          Débooking d’une écriture service  Si « Booking » est décoché et qu’un n° d’écriture service est renseigné
          Alors, création d’une écriture service de montant (-)montant de l’écriture service renseigné dans l’écran des cat cover
           et ajout dans les commentaires de la nouvelle ES le n° de l’ES annulée.
           Puis, mise à vide du n° d’ES dans TRETCATCVR.
Conditions d'execution: par ESIJ2001.cmd
Commentaires:
_________________
MODIFICATIONS
1 Florent :spot:29022 maj du montant acceptation aussi, si si !
*****************************************************/
declare
 @TRN_MIN int
,@erreur  int
,@lignes  int

--pour la gestion du compteur TRT_NT et NUMLINE_NT
create table #NUMACC
(
 TRN_NT       numeric(10,0) identity
,TRN_OLD      numeric(10,0) not null
,RCATCVR_NT   numeric(10,0) not null
,SSD_CF       USSD_CF       NOT NULL
,LSTUPD_D     UUPD_D        not null
,LSTUPDUSR_CF UUPDUSR_CF    not null
)
if @@error!=0 goto erreur

select @TRN_MIN=max(TRN_NT) FROM BEST..TACCSUP
print 'on enregistre à partir de quel n° d''ES on insère les lignes %1!',@TRN_MIN

update TACCSUP
 set RETAMT_M=c.TRNAMT_M
    ,AMT_M=c.TRNAMT_M
    ,LSTUPD_D=c.LSTUPD_D
    ,LSTUPDUSR_CF=c.LSTUPDUSR_CF
  from TACCSUP a, TRETCATCVR c
   where c.BALSH_D=@p_ICLODAT_D
     and c.SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
     and (case when BOOKING_B=1 and ULTAMT_M=(isnull(RETCEDAMT_M,0)+isnull(TRNAMT_M,0)) then 1 else 0 end)=1
     and a.TRN_NT=c.TRN_NT
     and a.RETAMT_M!=c.TRNAMT_M
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur
print 'maj des ES, suite ligne bookée et CAT COVER modifiées, lignes %1!',@lignes

insert #NUMACC(TRN_OLD,RCATCVR_NT,SSD_CF,LSTUPD_D,LSTUPDUSR_CF)
select TRN_NT,RCATCVR_NT,SSD_CF,LSTUPD_D,LSTUPDUSR_CF
  from TRETCATCVR
   where BALSH_D=@p_ICLODAT_D
     and SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
     and BOOKING_B=0
     and TRN_NT!=null
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur
if @lignes=0
begin
  print 'NO ES to to reverse,  exiting'
  return 0
end
print 'selection des nouvelles ES reverse pour faire un compteur avec l''identity, lignes %1!',@lignes

begin tran

insert TACCSUP
(TRN_NT,ACCTYP_NF,SSD_CF,ESB_CF,ENTPERY_NF,ENTPERMTH_NF,BALSHEY_NF,BALSHRMTH_NF,BALSHRDAY_NF,VALPERY_NF,VALPERMTH_NF,TRNCOD_CF,DBLTRNCOD_CF,RETAUTGEN_B,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,OCCYEA_NF,ACY_NF,SCOSTRMTH_NF,SCOENDMTH_NF,CLM_NF,CUR_CF,AMT_M,CED_NF,BRK_NF,GEMPRMPAY_NF,GANPAYORD_NT,RETCTR_NF,RETEND_NT,RETSEC_NF,RETRTY_NF,RETUW_NT,PLC_NT,RETOCCYEA_NF,RETACY_NF,RETSCOSTRMTH_NF,RETSCOENDMTH_NF,RCL_NF,RETCUR_CF,RETAMT_M,RTO_NF,INT_NF,RETPAY_NF,RETKEY_CF,ACCTRN_NT,COMMAC_LL,CRE_D,CREUSR_CF,LSTUPD_D,LSTUPDUSR_CF,SPEENTTYP_CF,SPEENTNAT_CT)
SELECT
  TRN_NT=x.TRN_NT+@TRN_MIN
 ,a.ACCTYP_NF
 ,a.SSD_CF
 ,a.ESB_CF
 ,a.ENTPERY_NF
 ,a.ENTPERMTH_NF
 ,a.BALSHEY_NF
 ,a.BALSHRMTH_NF
 ,a.BALSHRDAY_NF
 ,a.VALPERY_NF
 ,a.VALPERMTH_NF
 ,a.TRNCOD_CF
 ,a.DBLTRNCOD_CF
 ,a.RETAUTGEN_B
 ,a.CTR_NF
 ,a.END_NT
 ,a.SEC_NF
 ,a.UWY_NF
 ,a.UW_NT
 ,a.OCCYEA_NF
 ,a.ACY_NF
 ,a.SCOSTRMTH_NF
 ,a.SCOENDMTH_NF
 ,a.CLM_NF
 ,a.CUR_CF
 ,AMT_M=AMT_M * -1
 ,a.CED_NF
 ,a.BRK_NF
 ,a.GEMPRMPAY_NF
 ,a.GANPAYORD_NT
 ,a.RETCTR_NF
 ,a.RETEND_NT
 ,a.RETSEC_NF
 ,a.RETRTY_NF
 ,a.RETUW_NT
 ,a.PLC_NT
 ,a.RETOCCYEA_NF
 ,a.RETACY_NF
 ,a.RETSCOSTRMTH_NF
 ,a.RETSCOENDMTH_NF
 ,a.RCL_NF
 ,a.RETCUR_CF
 ,RETAMT_M=RETAMT_M * -1
 ,a.RTO_NF
 ,a.INT_NF
 ,a.RETPAY_NF
 ,a.RETKEY_CF
 ,a.ACCTRN_NT
 ,COMMAC_LL='REVERSE_ES:'+convert(varchar,a.TRN_NT)+' '+a.COMMAC_LL
 ,a.CRE_D
 ,a.CREUSR_CF
 ,LSTUPD_D=x.LSTUPD_D
 ,LSTUPDUSR_CF=x.LSTUPDUSR_CF
 ,a.SPEENTTYP_CF
 ,a.SPEENTNAT_CT
  from TACCSUP a, #NUMACC x
   where x.TRN_OLD=a.TRN_NT
     and x.SSD_CF=a.SSD_CF
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur2
print 'reverse des ES, suite CAT COVER booking décoché',@lignes
 
update TRETCATCVR
 set TRN_NT=null
    ,LSTUPD_D=getdate()
    ,LSTUPDUSR_CF=suser_name()
  from TRETCATCVR c, #NUMACC x
   where c.RCATCVR_NT=x.RCATCVR_NT
     and c.BALSH_D=@p_ICLODAT_D
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur2
print 'maj des CAT COVER pour mettre à vide le n° d''ES',@lignes

commit tran

return 0

erreur2:
rollback tran

erreur:
return 999
go
IF OBJECT_ID('dbo.PtRETCATCVR_ACCSUP_02') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PtRETCATCVR_ACCSUP_02 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PtRETCATCVR_ACCSUP_02 >>>'
go
GRANT EXECUTE ON dbo.PtRETCATCVR_ACCSUP_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtRETCATCVR_ACCSUP_02 TO GDBBATCH
go
