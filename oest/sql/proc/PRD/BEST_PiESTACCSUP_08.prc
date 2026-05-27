USE BEST
go
IF OBJECT_ID('PiESTACCSUP_08') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_08
  PRINT '<<< DROPPED PROC PiESTACCSUP_08 >>>'
END
go
create procedure PiESTACCSUP_08(
  @p_balshtyea_nf int,
  @p_balshtmth_nf tinyint,
  @p_clodatmax_d  datetime,
  @p_NORME      varchar(4)
  )
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: S.Behague
Date de creation: 24/06/2020
Description du programme: 	
	- sélection des écritures de services IFRS17 Life
Conditions d'execution: 
Commentaires: Creation à partir de PiESTACCSUP_02
[01]  14/04/2021 SBE  :spira:94597 IFRS17 AE- send P&C IFRS17 AE to RA and SAP
[02]  29/04/2021 SBE  :spira:92905 I17P: Management of Life AE for the Closing norm "LOCAL"
[03]  10/02/2021 SBE  :spira:102254 IFRS17- REQ.LIF.01: AE interface for Life from SAS - Retrocession with placement <> 100%
[04]  10/03/2022 SBE  :spira:102711 Manage AE IFRS 17 not coming from SAS
[05]  27/10/2022 SBE  :spira:107343 Absence dans le closing des AE GUI/File upload avec AE Type renseigné ( SPEENTYPE)
**************************************/
declare   @erreur     int,
          @tran_imbr  bit

select @erreur=0, @tran_imbr=1

Create Table #tmp_accsup (RETCTR_NF       URETCTR_NF    NULL,
                          RTY_NF          UUWY_NF       NULL)
                          
Create Table #sumtaux (RETCTR_NF       URETCTR_NF    NULL,
                       RTY_NF          UUWY_NF       NULL,
                       SUMRETSIGSHA_R  USHA_R       NULL)
                   
truncate table BTRAV..EST_ESFD0070_TACCSUP

if @@trancount = 0
begin
  select @tran_imbr = 0
  BEGIN TRAN
end

-- Sélection des écritures de service
insert into BTRAV..EST_ESFD0070_TACCSUP
select TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF , CLM_NF,
CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF --[008]
from BEST..TACCSUP a
where
( VALPERY_NF > @p_balshtyea_nf or
( VALPERY_NF = @p_balshtyea_nf and VALPERMTH_NF >= @p_balshtmth_nf ) )
and
(balshey_nf < datepart(yy,@p_clodatmax_d) or
(balshey_nf = datepart(yy,@p_clodatmax_d) and balshrmth_nf <= datepart(mm,@p_clodatmax_d) ))
and SPEENTNAT_CT in (9, 10, 11)
AND ( 
( substring(TRNCOD_CF,8,8) IN ('I', 'J') AND @p_NORME = 'I17G' ) OR
( substring(TRNCOD_CF,8,8) IN ('K', 'L') AND @p_NORME = 'I17P' ) OR
( substring(TRNCOD_CF,8,8) IN ('M', 'N') AND @p_NORME = 'I17L' )
)
AND SPEENTTYP_CF in (8, 9)
and exists(select 1 from BREF..TBATCHSSD c where a.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())
union -- ASSUMED --
select a.TRN_NT, a.ACCTYP_NF, a.SSD_CF, a.ESB_CF,a. ENTPERY_NF,a. ENTPERMTH_NF,a. BALSHEY_NF, a.BALSHRMTH_NF,
a.BALSHRDAY_NF, a.VALPERY_NF,a.VALPERMTH_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF,a. RETAUTGEN_B, a.CTR_NF,
a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF , a.CLM_NF,
a.CUR_CF, a.AMT_M, a.CED_NF, a.BRK_NF,a.GEMPRMPAY_NF, a.GANPAYORD_NT,a.RETCTR_NF, a.RETEND_NT, a.RETSEC_NF,
a.RETRTY_NF, a.RETUW_NT, a.PLC_NT, a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF, a.RCL_NF,
a.RETCUR_CF, a.RETAMT_M, a.RTO_NF, a.INT_NF, a.RETPAY_NF,a.RETKEY_CF, a.ACCTRN_NT, a.COMMAC_LL, a.CRE_D,
a.CREUSR_CF,a.LSTUPD_D, a.LSTUPDUSR_CF, a.SPEENTTYP_CF, a.SPEENTNAT_CT, a.EVT_NF, a.REVT_NF
from BEST..TACCSUP a, btrt..tsection s
where
		 a.ctr_nf is not null
 and a.ctr_nf = s.ctr_nf
 and a.sec_nf = s.sec_nf
 and a.uwy_nf = s.uwy_nf
 and s.lob_cf in ('30','31')
and ( VALPERY_NF > @p_balshtyea_nf or
( VALPERY_NF = @p_balshtyea_nf and VALPERMTH_NF >= @p_balshtmth_nf ) )
and
(balshey_nf < datepart(yy,@p_clodatmax_d) or
(balshey_nf = datepart(yy,@p_clodatmax_d) and balshrmth_nf <= datepart(mm,@p_clodatmax_d) ))
and SPEENTNAT_CT in (9, 10, 11)
AND ( 
( substring(TRNCOD_CF,8,8) IN ('I', 'J') AND @p_NORME = 'I17G' ) OR
( substring(TRNCOD_CF,8,8) IN ('K', 'L') AND @p_NORME = 'I17P' ) OR
( substring(TRNCOD_CF,8,8) IN ('M', 'N') AND @p_NORME = 'I17L' )
)
AND ( (SPEENTTYP_CF <> 8 and SPEENTTYP_CF <> 9 ) OR SPEENTTYP_CF IS NULL )
and exists(select 1 from BREF..TBATCHSSD c where a.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())
union -- RETRO --
select a.TRN_NT, a.ACCTYP_NF, a.SSD_CF, a.ESB_CF,a. ENTPERY_NF,a. ENTPERMTH_NF,a. BALSHEY_NF, a.BALSHRMTH_NF,
a.BALSHRDAY_NF, a.VALPERY_NF,a.VALPERMTH_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF,a. RETAUTGEN_B, a.CTR_NF,
a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF , a.CLM_NF,
a.CUR_CF, a.AMT_M, a.CED_NF, a.BRK_NF,a.GEMPRMPAY_NF, a.GANPAYORD_NT,a.RETCTR_NF, a.RETEND_NT, a.RETSEC_NF,
a.RETRTY_NF, a.RETUW_NT, a.PLC_NT, a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF, a.RCL_NF,
a.RETCUR_CF, a.RETAMT_M, a.RTO_NF, a.INT_NF, a.RETPAY_NF,a.RETKEY_CF, a.ACCTRN_NT, a.COMMAC_LL, a.CRE_D,
a.CREUSR_CF,a.LSTUPD_D, a.LSTUPDUSR_CF, a.SPEENTTYP_CF, a.SPEENTNAT_CT, a.EVT_NF, a.REVT_NF
from BEST..TACCSUP a, bret..tretsec s
where
     a.retctr_nf is not null
 and a.retctr_nf = s.retctr_nf
 and a.retsec_nf = s.retsec_nf
 and a.retrty_nf = s.rty_nf
 and s.lob_cf in ('30','31') 
and ( VALPERY_NF > @p_balshtyea_nf or
( VALPERY_NF = @p_balshtyea_nf and VALPERMTH_NF >= @p_balshtmth_nf ) )
and
(balshey_nf < datepart(yy,@p_clodatmax_d) or
(balshey_nf = datepart(yy,@p_clodatmax_d) and balshrmth_nf <= datepart(mm,@p_clodatmax_d) ))
and SPEENTNAT_CT in (9, 10, 11)
AND ( 
( substring(TRNCOD_CF,8,8) IN ('I', 'J') AND @p_NORME = 'I17G' ) OR
( substring(TRNCOD_CF,8,8) IN ('K', 'L') AND @p_NORME = 'I17P' ) OR
( substring(TRNCOD_CF,8,8) IN ('M', 'N') AND @p_NORME = 'I17L' )
)
AND ( (SPEENTTYP_CF <> 8 and SPEENTTYP_CF <> 9 ) OR SPEENTTYP_CF IS NULL )
and exists(select 1 from BREF..TBATCHSSD c where a.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())

select @erreur = @@error
if @erreur != 0  goto fin

-- [03] --
-- Sélection des contrats Retro 
INSERT INTO #tmp_accsup
select distinct retctr_nf, RTY_NF from BTRAV..EST_ESFD0070_TACCSUP where retctr_nf is not null 

-- Sélection de la somme des taux pour les contrats retro sélectionnés
INSERT INTO #sumtaux
select plc.RETCTR_NF, plc.RTY_NF, sum(plc.RETSIGSHA_R) from #tmp_accsup ae, bret..tplacemt plc
where  plc.RETCTR_NF = ae.RETCTR_nf 
and    plc.RTY_NF = ae.RTY_NF
and    plc.his_b = 0
and    plc.plcsts_ct in (16,19)
and    plc.accplc_b=1
group by plc.RETCTR_NF, plc.RTY_NF

-- Update des montants de BTRAV..EST_ESFD0070_TACCSUP
update BTRAV..EST_ESFD0070_TACCSUP set AMT_M=round(AMT_M/tx.SUMRETSIGSHA_R,3) , RETAMT_M=round(RETAMT_M/tx.SUMRETSIGSHA_R,3)
from BTRAV..EST_ESFD0070_TACCSUP ae , #sumtaux tx
where ae.RETCTR_NF=tx.RETCTR_NF 
and   ae.RTY_NF = tx.RTY_NF

-- Descente de la table en fichiers
select SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF, 
  CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,  
  RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETAUTGEN_B, ACCTYP_NF
  ,TRN_NT --[009] ajout nouvelle colonnes
  ,ORICOD_LS=case WHEN SPEENTNAT_CT = 1 then 'IFRSGTA' ELSE 'EBSGTA' end
  ,RETROAUTO_B=case when ACCTYP_NF=0 then 1 else null end 
  ,SPEENTNAT_CT
  ,EVT_NF
  ,REVT_NF
  ,ACCTRN_NT
from  BTRAV..EST_ESFD0070_TACCSUP
/**********************************************************************************/
if @tran_imbr = 0
   COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN
return 1
go
IF OBJECT_ID('PiESTACCSUP_08') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTACCSUP_08 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTACCSUP_08 >>>'
go
GRANT EXECUTE ON PiESTACCSUP_08 TO GOMEGA
go
GRANT EXECUTE ON PiESTACCSUP_08 TO GDBBATCH
go
