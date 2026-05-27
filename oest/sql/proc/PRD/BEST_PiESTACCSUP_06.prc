USE BEST
go
IF OBJECT_ID('PiESTACCSUP_06') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_06
  PRINT '<<< DROPPED PROC PiESTACCSUP_06 >>>'
END
go
create procedure PiESTACCSUP_06(
  @p_balshtyea_nf int,
  @p_balshtmth_nf tinyint,
  @p_clodatmax_d  datetime,
  @p_ssd_cf int,
  @p_esb_cf UESB_CF,
  @p_NORME      varchar(4))
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: S.Behague
Date de creation: 13/03/2020
Description du programme: 	
	- sélection des écritures de services pour recalcul dans la chaine ESIJ0790.cmd
Conditions d'execution: 
Commentaires: Creation à partir de PiESTACCSUP_02
_________________
[01] - S.Behague :spira:94451 - I17: AE - Delta used IFRS 4 closing date instead of IFRS 17 one - Copy for INT temporary fix
[02]  17/03/2021 SBE  :spira:94451 I17: AE - Delta used IFRS 4 closing date instead of IFRS 17 one - Copy for INT temporary fix
[03]  10/11/2021 SBE  :spira:99765 IFRS17- REQ.LIF.01: AE interface for Life from SAS - Change delta approach
[04]  01/03/2022 SBE  :spira:102384 IFRS17- REQ.LIF.01: AE interface for Life from SAS - Manage I17 Norm in delta approach
*****************************************************/
declare   @erreur       int,
          @tran_imbr  bit

select @erreur=0, @tran_imbr=1

truncate table BTRAV..EST_ESIJ0790_TACCSUP

if @@trancount = 0
begin
  select @tran_imbr = 0
  BEGIN TRAN
end


-- Sélection des écritures de service
insert into BTRAV..EST_ESIJ0790_TACCSUP
select  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF, 
  CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, 
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF  --[008]
from  BEST..TACCSUP a
where 
        ( VALPERY_NF > @p_balshtyea_nf or
        ( VALPERY_NF = @p_balshtyea_nf and VALPERMTH_NF >= @p_balshtmth_nf ) )
        and speentnat_ct in (9, 10, 11) 
        AND SPEENTTYP_CF in (8, 9)
				AND ( 
					( substring(TRNCOD_CF,8,1) IN ('I', 'J') AND @p_NORME = 'I17G' ) OR
					( substring(TRNCOD_CF,8,1) IN ('K', 'L') AND @p_NORME = 'I17P' ) OR
					( substring(TRNCOD_CF,8,1) IN ('M', 'N') AND @p_NORME = 'I17L' )
				)
        and ssd_cf = @p_ssd_cf
        and esb_cf = @p_esb_cf

--and    --MOD01 MOD02
       -- (balshey_nf < datepart(yy,@p_clodatmax_d) or 
       -- (balshey_nf = datepart(yy,@p_clodatmax_d) and balshrmth_nf <= datepart(mm,@p_clodatmax_d) ))
and exists(select 1 from BREF..TBATCHSSD c where a.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())

select @erreur = @@error
if @erreur != 0  goto fin

-- SBE Format Fichier à extraire
select SSD_CF,ESB_CF,'',BALSHEY_NF,BALSHRMTH_NF,BALSHRDAY_NF,VALPERY_NF,VALPERMTH_NF,TRNCOD_CF,
RETAUTGEN_B,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,OCCYEA_NF,ACY_NF,SCOSTRMTH_NF,SCOENDMTH_NF,CLM_NF,CUR_CF,AMT_M,RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,
RETUW_NT,PLC_NT,RETOCCYEA_NF,RETACY_NF,RETSCOSTRMTH_NF,RETSCOENDMTH_NF,RCL_NF,RETCUR_CF,RETAMT_M,COMMAC_LL,SPEENTTYP_CF,SPEENTNAT_CT,EVT_NF,REVT_NF

from  BTRAV..EST_ESIJ0790_TACCSUP

select @erreur = @@error
if @erreur != 0  goto fin

-- Spira 99765 

delete best..taccsup from best..taccsup t, BTRAV..EST_ESIJ0790_TACCSUP bt
where t.TRN_NT = bt.TRN_NT

select @erreur = @@error
if @erreur != 0  goto fin

/**********************************************************************************/
if @tran_imbr = 0
   COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN
return 1
go
EXEC sp_procxmode 'dbo.PiESTACCSUP_06', 'unchained'
go
IF OBJECT_ID('dbo.PiESTACCSUP_06') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiESTACCSUP_06 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiESTACCSUP_06 >>>'
go
GRANT EXECUTE ON dbo.PiESTACCSUP_06 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiESTACCSUP_06 TO GDBBATCH
go
