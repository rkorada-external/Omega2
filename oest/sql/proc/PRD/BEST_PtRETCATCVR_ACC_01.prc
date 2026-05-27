USE BEST
go
IF OBJECT_ID('PtRETCATCVR_ACC_01') IS NOT NULL
BEGIN
  DROP PROCEDURE PtRETCATCVR_ACC_01
  IF OBJECT_ID('PtRETCATCVR_ACC_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE PtRETCATCVR_ACC_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE PtRETCATCVR_ACC_01 >>>'
END
go
create procedure PtRETCATCVR_ACC_01
(
 @p_ICLODAT_D   datetime
)
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 03/03/2015
Description du programme: :spot:28139 Prendre les nouvelles cat cover via la compta du trimestre et du site géographique
Conditions d'execution: par ESIJ2001.cmd
Commentaires:
_________________
MODIFICATIONS
1 Florent :spot:29022 ajout gestion de @p_ICLODAT_D
2 -=Dch=- :spot:29163 modif de NOTIFCONTEXT_LL , remplace de ¤ par 
3 Florent :spot:29163 sur le contrat / exercice / section / devise / N° de sinistre
                       Si position OLR réelle et retard à la fois alors alimenter la colonne uniquement du montant Retard . 
                       Si position OLR reelle uniquement alors alimenter la colonne uniquement du montant Reel . 
                       Si position OLR retard uniquement alors alimenter la colonne uniquement du montant Retard
4 Riyadh   : Change requested for defect 54570
5 MZM      : Spira 79021 : Ne plus prendre encompte ACMTRS 111 
*****************************************************/
declare
 @CATCVR_MAX int
,@erreur  int
,@lignes  int

CREATE TABLE #CATCOVER
(
 RCATCVR_NT   numeric(10,0) IDENTITY
,SSD_CF       USSD_CF  NOT NULL
,ESB_CF       UESB_CF  NOT NULL
,RETCTR_NF    UCTR_NF  NOT NULL
,RTY_NF       UUWY_NF  NOT NULL
,RETSEC_NF    USEC_NF  NOT NULL
,AECUR_CF     UCUR_CF  NOT NULL
,CATCVRDMN_CT smallint NOT NULL
,RCL_NF       UCLM_NF  NULL
,PLC_NT       UPLC_NT  NULL
,RETCEDAMT_M  UAMT_M   DEFAULT 0 NOT NULL
)

CREATE TABLE #ACC_CATCOVER
(
 SSD_CF       USSD_CF  NOT NULL
,ESB_CF       UESB_CF  NOT NULL
,RETCTR_NF    UCTR_NF  NOT NULL
,RTY_NF       UUWY_NF  NOT NULL
,RETSEC_NF    USEC_NF  NOT NULL
,AECUR_CF     UCUR_CF  NOT NULL
,CATCVRDMN_CT smallint NOT NULL
,RCL_NF       UCLM_NF  NULL
,RETCEDAMT_M  UAMT_M   DEFAULT 0 NOT NULL
)

insert #ACC_CATCOVER
select SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,RETSEC_NF,AECUR_CF,ACMTRS_NT,RCL_NF
 ,RETCEDAMT_M=case when ACMTRS_NT=111 and sum(RETCEDAMT_ACC_M)!=null and sum(RETCEDAMT_OUT_M)!=null then sum(RETCEDAMT_OUT_M) * -1
                   else (isnull(sum(RETCEDAMT_ACC_M),0) + isnull(sum(RETCEDAMT_OUT_M),0)) * -1
                   end
 from (
        select a.SSD_CF,c.ESB_CF,a.RETCTR_NF,a.RTY_NF,a.RETSEC_NF,AECUR_CF=a.CNVCUR_CF,b.ACMTRS_NT,RCL_NF=case when b.ACMTRS_NT in(110,111) then a.RCL_NF else null end
        ,RETCEDAMT_ACC_M=round(a.CNVAMT_M / case when isnull(a.PLC_NT, 0)=0 then 1
                                        else isnull((select case when isnull(sum(RETSIGSHA_R), sum(RETACTSHA_R))=0 then 1 else isnull(sum(RETSIGSHA_R), sum(RETACTSHA_R)) end from BRET..TPLACEMT x  
                                                                        where x.RETCTR_NF=a.RETCTR_NF and x.RTY_NF=a.RTY_NF and PLCSTS_CT in (16, 19) and x.HIS_B=0),1)   --Modification 4
                               end,3)
        ,RETCEDAMT_OUT_M=convert(decimal(15,3),null)
         from BRET..TACCTRAI a, BREF..TTRSLNK b, BRET..TRETCTR c
          where PRS_CF=715
           and DETTRS_CF=TRNCOD_CF
           and (ACMTRS_NT in(111,113) and year(ACC_D)=year(@p_ICLODAT_D) or ACMTRS_NT not in(111,113))
           and a.RETCTR_NF=c.RETCTR_NF
           and a.RTY_NF=c.RTY_NF
           and a.SSD_CF=c.SSD_CF
           and LOB_CF not in('30','31')
           and RETCTRSTS_CT in(3,19)
           AND RETCTRCAT_CF='02'
           and a.SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
           --sinistre ouvert
           and (b.ACMTRS_NT in(112,113) or exists(select 1 from BCTA..TRETCLM x where a.RCL_NF=x.RCL_NF and a.SSD_CF=x.SSD_CF and x.CLMSTS_CF='1'))
        union all
        select a.SSD_CF,c.ESB_CF,a.RETCTR_NF,a.RTY_NF,a.RETSEC_NF,AECUR_CF=a.CUR_CF,b.ACMTRS_NT,RCL_NF=case when b.ACMTRS_NT in(110,111) then a.RCL_NF else null end
        ,RETCEDAMT_ACC_M=convert(decimal(15,3),null)
        ,RETCEDAMT_OUT_M=round(a.TRN_M / case when isnull(a.PLC_NT, 0)=0 then 1
                                     else isnull((select case when isnull(sum(RETSIGSHA_R), sum(RETACTSHA_R))=0 then 1 else isnull(sum(RETSIGSHA_R), sum(RETACTSHA_R)) end from BRET..TPLACEMT x
                                                                        where x.RETCTR_NF=a.RETCTR_NF and x.RTY_NF=a.RTY_NF and PLCSTS_CT in (16, 19) and x.HIS_B=0),1)   -- Modification 4
                               end,3)
         from BRET..TOUTTRAI a, BREF..TTRSLNK b, BRET..TRETCTR c
          where PRS_CF=715
           and b.ACMTRS_NT != 111   -- 05
           and DETTRS_CF=TRNCOD_CF
           and a.RETCTR_NF=c.RETCTR_NF
           and a.RTY_NF=c.RTY_NF
           and a.SSD_CF=c.SSD_CF
           and LOB_CF not in('30','31')
           and RETCTRSTS_CT in(3,19)
           AND RETCTRCAT_CF='02'
           and a.SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
           --sinistre ouvert
           and (b.ACMTRS_NT in(112,113) or exists(select 1 from BCTA..TRETCLM x where a.RCL_NF=x.RCL_NF and a.SSD_CF=x.SSD_CF and x.CLMSTS_CF='1'))
   ) a
group by SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,RETSEC_NF,AECUR_CF,ACMTRS_NT,RCL_NF
order by 1,2,3,4,5,6,7,8
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur
print 'Récupération des mvt compta pour les CAT COVER, lignes %1!',@lignes

insert #CATCOVER (SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,RETSEC_NF,AECUR_CF,CATCVRDMN_CT,RCL_NF,RETCEDAMT_M)
select SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,RETSEC_NF,AECUR_CF,CATCVRDMN_CT,RCL_NF,RETCEDAMT_M
 from #ACC_CATCOVER a
  where not exists(select 1 from TRETCATCVR x where a.RETCTR_NF=x.RETCTR_NF and a.RTY_NF=x.RTY_NF
                   and a.RETSEC_NF=x.RETSEC_NF and a.AECUR_CF=x.AECUR_CF and a.CATCVRDMN_CT=x.CATCVRDMN_CT 
                   and isnull(a.RCL_NF,0)=isnull(x.RCL_NF,0) and MANUAL_B=0 and x.BALSH_D=@p_ICLODAT_D)
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur
print 'sélection des CAT COVER à créer, lignes %1!',@lignes

select @CATCVR_MAX=RCATCVR_NT from TRETCATCVR
if @CATCVR_MAX=null select @CATCVR_MAX=0
print 'Récupération du compteur max des CAT COVER %1!',@CATCVR_MAX

select distinct
 DOBJECT_ID=convert(varchar,RCATCVR_NT)+'-'+a.RETCTR_NF+'-'+convert(varchar,a.RETSEC_NF)+'-'+convert(char(4),a.RTY_NF)+'-'+convert(varchar,a.SSD_CF)+'-'+convert(varchar,a.ESB_CF)
,NOTIFTYP_NT=191
,USR_CF=a.LSTULTUPDUSR_CF
,NOTIFCONTEXT_LL='CAT COVER bookées et modifiées'
 from TRETCATCVR a, #ACC_CATCOVER x
  where a.RETCTR_NF=x.RETCTR_NF
    and a.RTY_NF=x.RTY_NF
    and a.RETSEC_NF=x.RETSEC_NF
    and a.AECUR_CF=x.AECUR_CF
    and a.CATCVRDMN_CT=x.CATCVRDMN_CT 
    and isnull(a.RCL_NF,0)=isnull(x.RCL_NF,0)
    and MANUAL_B=0
    and a.RETCEDAMT_M!=x.RETCEDAMT_M
    and BOOKING_B=1
    and TRN_NT!=null
    and a.BALSH_D=@p_ICLODAT_D
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur
print 'Sortie du fichier pour le journal -diary- des CAT COVER bookées et modifiées, lignes %1!',@lignes

begin tran

update TRETCATCVR
 set RETCEDAMT_M=x.RETCEDAMT_M
    ,LSTUPD_D=getdate()
    ,LSTUPDUSR_CF=suser_name()
 from TRETCATCVR a, #ACC_CATCOVER x
  where a.RETCTR_NF=x.RETCTR_NF
    and a.RTY_NF=x.RTY_NF
    and a.RETSEC_NF=x.RETSEC_NF
    and a.AECUR_CF=x.AECUR_CF
    and a.CATCVRDMN_CT=x.CATCVRDMN_CT 
    and isnull(a.RCL_NF,0)=isnull(x.RCL_NF,0)
    and MANUAL_B=0
    and a.RETCEDAMT_M!=x.RETCEDAMT_M
    and a.BALSH_D=@p_ICLODAT_D
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur2
print 'maj des CAT COVER modifiées par la compta, lignes %1!',@lignes

insert TRETCATCVR	(RCATCVR_NT,SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,RETSEC_NF,AECUR_CF,BALSH_D,CATCVRDMN_CT,RCL_NF,RETCEDAMT_M)
select RCATCVR_NT+@CATCVR_MAX,SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,RETSEC_NF,AECUR_CF,@p_ICLODAT_D,CATCVRDMN_CT,RCL_NF,RETCEDAMT_M
 from #CATCOVER
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0 goto erreur2
print 'Insertion des CAT COVER nouvelles de la compta, lignes %1!',@lignes

commit tran

return 0

erreur2:
rollback tran

erreur:
return 999
go
IF OBJECT_ID('PtRETCATCVR_ACC_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE PtRETCATCVR_ACC_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE PtRETCATCVR_ACC_01 >>>'
go
GRANT EXECUTE ON PtRETCATCVR_ACC_01 TO GOMEGA,GDBBATCH
go
