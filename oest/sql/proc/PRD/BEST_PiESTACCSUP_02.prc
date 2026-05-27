USE BEST
go
IF OBJECT_ID('PiESTACCSUP_02') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_02
  PRINT '<<< DROPPED PROC PiESTACCSUP_02 >>>'
END
go
create procedure PiESTACCSUP_02(
  @p_balshtyea_nf int,
  @p_balshtmth_nf tinyint,
  @p_clodatmax_d  datetime,
  @s_flag_Job_EBS char(1))
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation: 06/10/97
Description du programme: 	
	- s�lection des �critures de services par ESID0062.cmd
Conditions d'execution: 
Commentaires:
_________________
MODIFICATION 1 -> MOD01
Auteur: O.GIRAUX
Date: 18/11/2002
Description: Ajout test sur clodat
_________________
MODIFICATION  2-> MOD02
Auteur: J.Ribot
Date: 13/01/2003
Description: remplace clodat par clodatmax
_________________
MODIFICATION  3-> MOD03
Auteur: M. DJELLOULI
Date: 27/04/2005
Description: EST_ESIJ0090_TACCSUP remplace TESTACCSUP
_________________
MODIFICATION 4
Auteur:     M.DJELLOULI - MOD004
Date:        24/06/2005
Description: SPOT 5085 - Ajout Zone SPEENTNAT_CT
_________________
MODIFICATION [005]
Auteur:         JF VDV
Date:           23/05/2012
Version:
Description:    [23390] - SOLVENCY am�nagements
_________________
[006] 06/07/2012 JF VDV    [23390] - Amenagements SOLVENCY II (valeurs conditionn�es de la zone SPEENTNAT_CT en sortie)
_________________
MODIFICATION - Removed dbo and added �with execute as caller as�
_________________
[007] 12/08/2013 Florent   :spot:25427 Centralisation des bases (filiales)
[008] 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
[009] 14/01/2016 Florent :spot:29066 - Add 2 columns EVT_NF and REVT_NF en sortie
[010] 14/04/2020 R. Cassis :spira:82010 Les contrats ayant un endorsment invalide (CTRLCK_B = 1) sont exclus de l'extraction pour �tre au niveau de la r�tro
[011] 22/04/2020 S.Behague :spira:82196 - IFRS17- REQ.LIF.01: AE interface for Life from SAS
[012] 05/05/2020 R. Cassis :spira:82010 Les contrats ayant un endorsment invalide (CTRLCK_B = 1 trt, = 0 fac) sont exclus de l'extraction pour �tre au niveau de la r�tro
[013] 10/08/2021 B. Lagha  :spira:95950 - IFRS17 AE extraction - pericase issue
[014] 24/11/2025 M. NAJI  :US 7605	User Story	SERQS - AE retro SERQS to be extracted by assumed site closing
**************************************/
declare   @erreur       int,
          @tran_imbr  bit ,
          @usr char(4) 
          
select @usr=suser_name()

select @erreur=0, @tran_imbr=1

truncate table BTRAV..EST_ESIJ0090_TACCSUP

-- if @@trancount = 0
-- begin
--   select @tran_imbr = 0
--   BEGIN TRAN
-- end

select  b.SSD_CF SSD_TRT,c.SSD_CF SSD_FAC,
	a.TRN_NT, a.ACCTYP_NF, a.SSD_CF, a.ESB_CF, a.ENTPERY_NF, a.ENTPERMTH_NF, a.BALSHEY_NF, a.BALSHRMTH_NF,
	a.BALSHRDAY_NF, a.VALPERY_NF, a.VALPERMTH_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF, a.RETAUTGEN_B, a.CTR_NF,
	a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF  , a.CLM_NF, 
	a.CUR_CF, a.AMT_M, a.CED_NF, a.BRK_NF, a.GEMPRMPAY_NF, a.GANPAYORD_NT, a.RETCTR_NF, a.RETEND_NT, a.RETSEC_NF,
	a.RETRTY_NF, a.RETUW_NT, a.PLC_NT, a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF, a.RCL_NF, 
	a.RETCUR_CF, a.RETAMT_M, a.RTO_NF, a.INT_NF, a.RETPAY_NF, a.RETKEY_CF, a.ACCTRN_NT, a.COMMAC_LL, a.CRE_D,
	a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF, a.SPEENTTYP_CF, a.SPEENTNAT_CT, a.EVT_NF, a.REVT_NF 
into #TACCSUP_35
from  BEST..TACCSUP a
LEFT OUTER JOIN  btrt..tcontr b  on  a.ctr_nf = b.ctr_nf
                  and   a.uw_nt  = b.uw_nt
                  and   a.end_nt = b.end_nt
                  and   a.uwy_nf = b.uwy_nf
                  
LEFT OUTER JOIN bfac..tcontr c on a.ctr_nf = c.ctr_nf
                  and   a.uw_nt  = c.uw_nt 
                  and   a.end_nt = c.end_nt
                  and   a.uwy_nf = c.uwy_nf
                  
where ( a.VALPERY_NF > @p_balshtyea_nf or
      ( a.VALPERY_NF = @p_balshtyea_nf and a.VALPERMTH_NF >= @p_balshtmth_nf ) )
and    --MOD01 MOD02
      (a.balshey_nf < datepart(yy,@p_clodatmax_d) or 
      (a.balshey_nf = datepart(yy,@p_clodatmax_d) and a.balshrmth_nf <= datepart(mm,@p_clodatmax_d) ))
and   a.SPEENTNAT_CT = 1 
and a.ACCTYP_NF in (0,3,5)
and  ( ( b.ctr_nf != null and b.CTRLCK_B != 1 ) or ( c.ctr_nf != null and c.CTRLCK_B != 0 )) 

select @erreur = @@error
if @erreur != 0  goto fin

select 
   -- b.ctr_nf , b.CTRLCK_B , c.ctr_nf , c.CTRLCK_B , 
    a.TRN_NT, a.ACCTYP_NF, a.SSD_CF, a.ESB_CF, a.ENTPERY_NF, a.ENTPERMTH_NF, a.BALSHEY_NF, a.BALSHRMTH_NF,
	a.BALSHRDAY_NF, a.VALPERY_NF, a.VALPERMTH_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF, a.RETAUTGEN_B, a.CTR_NF,
	a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF  , a.CLM_NF, 
	a.CUR_CF, a.AMT_M, a.CED_NF, a.BRK_NF, a.GEMPRMPAY_NF, a.GANPAYORD_NT, a.RETCTR_NF, a.RETEND_NT, a.RETSEC_NF,
	a.RETRTY_NF, a.RETUW_NT, a.PLC_NT, a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF, a.RCL_NF, 
	a.RETCUR_CF, a.RETAMT_M, a.RTO_NF, a.INT_NF, a.RETPAY_NF, a.RETKEY_CF, a.ACCTRN_NT, a.COMMAC_LL, a.CRE_D,
	a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF, a.SPEENTTYP_CF, a.SPEENTNAT_CT, a.EVT_NF, a.REVT_NF   
into #TACCSUP_not_35
from  BEST..TACCSUP a
JOIN BREF..TBATCHSSD s on a.SSD_CF=s.SSD_CF and s.BATCHUSER_CF= @usr 
LEFT OUTER JOIN  btrt..tcontr b  on  a.ctr_nf = b.ctr_nf
                  and   a.uw_nt  = b.uw_nt
                  and   a.end_nt = b.end_nt
                  and   a.uwy_nf = b.uwy_nf
                  --and   b.CTRLCK_B != 1 
LEFT OUTER JOIN bfac..tcontr c on a.ctr_nf = c.ctr_nf
                  and   a.uw_nt  = c.uw_nt 
                  and   a.end_nt = c.end_nt
                  and   a.uwy_nf = c.uwy_nf
                  --and   c.CTRLCK_B != 0 
where ( a.VALPERY_NF > @p_balshtyea_nf or
      ( a.VALPERY_NF = @p_balshtyea_nf and a.VALPERMTH_NF >= @p_balshtmth_nf ) )
and    --MOD01 MOD02
      (a.balshey_nf < datepart(yy,@p_clodatmax_d) or 
      (a.balshey_nf = datepart(yy,@p_clodatmax_d) and a.balshrmth_nf <= datepart(mm,@p_clodatmax_d) ))
and   a.SPEENTNAT_CT = 1 
and a.ACCTYP_NF not in (0,3,5)
--and  TRN_NT = 1115756142
and  ( a.ctr_nf = null  or ( b.ctr_nf != null and b.CTRLCK_B != 1 ) or ( c.ctr_nf != null and c.CTRLCK_B != 0 )) 

select @erreur = @@error
if @erreur != 0  goto fin

if @@trancount = 0
begin
  select @tran_imbr = 0
  BEGIN TRAN
end

insert into  BTRAV..EST_ESIJ0090_TACCSUP  
select * 
from #TACCSUP_not_35
union 
select
    a.TRN_NT, a.ACCTYP_NF, a.SSD_CF, a.ESB_CF, a.ENTPERY_NF, a.ENTPERMTH_NF, a.BALSHEY_NF, a.BALSHRMTH_NF,
	a.BALSHRDAY_NF, a.VALPERY_NF, a.VALPERMTH_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF, a.RETAUTGEN_B, a.CTR_NF,
	a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF  , a.CLM_NF, 
	a.CUR_CF, a.AMT_M, a.CED_NF, a.BRK_NF, a.GEMPRMPAY_NF, a.GANPAYORD_NT, a.RETCTR_NF, a.RETEND_NT, a.RETSEC_NF,
	a.RETRTY_NF, a.RETUW_NT, a.PLC_NT, a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF, a.RCL_NF, 
	a.RETCUR_CF, a.RETAMT_M, a.RTO_NF, a.INT_NF, a.RETPAY_NF, a.RETKEY_CF, a.ACCTRN_NT, a.COMMAC_LL, a.CRE_D,
	a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF, a.SPEENTTYP_CF, a.SPEENTNAT_CT, a.EVT_NF, a.REVT_NF  
from #TACCSUP_35 a
JOIN BREF..TBATCHSSD s on( SSD_TRT =s.SSD_CF  or  SSD_FAC =s.SSD_CF ) and s.BATCHUSER_CF= @usr 

select @erreur = @@error
if @erreur != 0  goto fin

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
from  BTRAV..EST_ESIJ0090_TACCSUP
/**********************************************************************************/
if @tran_imbr = 0
   COMMIT TRAN
return 0

fin:
return 1
go
IF OBJECT_ID('PiESTACCSUP_02') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTACCSUP_02 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTACCSUP_02 >>>'
go
GRANT EXECUTE ON PiESTACCSUP_02 TO GOMEGA
go
GRANT EXECUTE ON PiESTACCSUP_02 TO GDBBATCH
go
