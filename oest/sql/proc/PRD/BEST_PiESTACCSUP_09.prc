USE BEST
go
IF OBJECT_ID('PiESTACCSUP_09') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_09
  PRINT '<<< DROPPED PROC PiESTACCSUP_09 >>>'
END
go
create procedure PiESTACCSUP_09(
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
Date de creation: 16/11/2021
Description du programme: 	
	- sélection des écritures de services pour recalcul dans la chaine ESIJ0790.cmd
Conditions d'execution: 
Commentaires: Creation à partir de PiESTACCSUP_06
_________________
[01]  16/11/2021 SBE  :spira:99765 IFRS17- REQ.LIF.01: AE interface for Life from SAS - Change delta approach
[02]  01/03/2022 SBE  :spira:102384 IFRS17- REQ.LIF.01: AE interface for Life from SAS - Manage I17 Norm in delta approach
[03]  29/08/2023 SBE  :spira:110097 IFRS17- REQ.LIF.01: AE interface for Life from SAS - Not create AE with amount = 0 - Copy
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
select 1 TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF, 
  CUR_CF, sum(AMT_M) AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, 
  RETCUR_CF, sum(RETAMT_M) RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, max(CRE_D),
  CREUSR_CF, max(LSTUPD_D), LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF  --[008]
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
				and exists(select 1 from BREF..TBATCHSSD c where a.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())
group by ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF, 
  CUR_CF, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, 
  RETCUR_CF, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL,  CREUSR_CF, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF

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
-- Initialisation of TRN_NT
update BTRAV..EST_ESIJ0790_TACCSUP set trn_nt = 1

-- Spira 110097
-- Delete of line with RETAMT = 0 or AMT = 0

delete from BTRAV..EST_ESIJ0790_TACCSUP
where (RETCTR_NF != "" AND RETCTR_NF != "NULL" AND RETAMT_M = 0) OR (CTR_NF != "" AND AMT_M = 0)


-- Create Cursor
declare insert_taccsup  cursor  for
select trn_nt from BTRAV..EST_ESIJ0790_TACCSUP

declare @trn_nt int, @maxtrn_nt int, @curtrn_nt int

select @maxtrn_nt =  max(trn_nt) from best..taccsup
select @curtrn_nt = 1

-- Open Cursor
open insert_taccsup

-- Fetch Cursor
fetch insert_taccsup into @trn_nt

While (@@sqlstatus = 0)
BEGIN
    update BTRAV..EST_ESIJ0790_TACCSUP set trn_nt = @curtrn_nt + @maxtrn_nt where current of insert_taccsup
    select @curtrn_nt = @curtrn_nt + 1
    fetch insert_taccsup into @trn_nt
END

-- Close and Desalocate Cursor
CLOSE insert_taccsup
deallocate cursor insert_taccsup

-- Insertion of reverse amount from BTRAV..EST_ESIJ0790_TACCSUP
insert into best..taccsup 
select TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF, 
  CUR_CF, AMT_M*-1, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, 
  RETCUR_CF, RETAMT_M*-1, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, getdate(),
  CREUSR_CF, getdate(), LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
  from BTRAV..EST_ESIJ0790_TACCSUP

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
EXEC sp_procxmode 'dbo.PiESTACCSUP_09', 'unchained'
go
IF OBJECT_ID('dbo.PiESTACCSUP_09') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiESTACCSUP_09 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiESTACCSUP_09 >>>'
go
GRANT EXECUTE ON dbo.PiESTACCSUP_09 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiESTACCSUP_09 TO GDBBATCH
go
