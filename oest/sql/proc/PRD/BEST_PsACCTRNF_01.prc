use BEST
go
if object_id('dbo.PsACCTRNF_01') is not null
begin
  drop PROC dbo.PsACCTRNF_01
  print '<<< DROPPED PROC dbo.PsACCTRNF_01 >>>'
end
go
create procedure PsACCTRNF_01
as
/***************************************************
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:             M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation:   27/10/97
Description du programme:   - Mise au format GT des écritures de BCTA..TACCTRNF
_________________
MODIFICATION    1
Auteur:         M.HA-THUC
Date:           07/04/98
Version:
Description:    - recherche du poste de contre-partie dans la table BREF..TDETTRS
_________________
MODIFICATION    2
Auteur:         J. Ribot
Date:           14/03/03
Version:
Description:    - AJOUT DERNIERE COLONNE a ZERO POUR RETRO INTERNE
_________________
MODIFICATION :  [003]
Auteur:         D.GATIBELZA
Date:           02/02/2011
Version:        11.1
Description:    1GL
[04] 12/08/2013 Florent :spot:25427 Centralisation des bases (filiales)
[05] 14/01/2016 Florent :spot:29066 ajout colonnes GT
*****************************************************/
/* ---------------------------------------------------------------------------------
   Mise au format GT des écritures de TACCTRNF et descente de la table en fichier
   --------------------------------------------------------------------------------- */
select 
  A.SSD_CF
 ,A.ESB_CF
 ,datepart(yy,A.BLCSHT_D)
 ,datepart(mm,A.BLCSHT_D)
 ,datepart(dd,A.BLCSHT_D)
 ,A.TRNCOD_CF
 ,C.CTRSCOD_CF
 ,A.CTR_NF
 ,A.END_NT
 ,A.SEC_NF
 ,A.UWY_NF
 ,A.UW_NT
 ,A.OCCYEA_NF
 ,A.ACY_NF
 ,A.SCOSTRMTH_NF
 ,A.SCOENDMTH_NF
 ,A.CLM_NF
 ,A.CUR_CF
 ,A.ORICURAMT_M
 ,A.CED_NF
 ,B.PRD_NF
 ,B.GENPRMPAY_NF
 ,B.GANPAYORD_NT
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,null
 ,'0.000'
 ,CompanyCode=null            --[003]
 ,CompanyID=null              --[003]
 ,LedgerGroup=null            --[003]
 ,GL_ACCOUNT_Principal=null   --[003]
 ,GL_ACCOUNT_CounterPart=null --[003]
 ,Accounting_Year=null        --[003]
 ,Accounting_Month=null       --[003]
 ,Partner=null                --[003]
 ,Cedent=null                 --[003]
 ,Segment=null                --[003]
 ,Transaction_Type=null       --[003]
 ,GAAP_Diff=null              --[003]
 ,Document_Type=null          --[003]
 ,Reconciliation_Key=null     --[003]
 ,TRN_NT=null                 --[003]
 ,ORICOD_LS=null              --[003]
 ,RETROAUTO_B=null            --[005] et les austres colonnes
 ,SPEENTNAT_CT=null
 ,EVT_NF=null
 ,REVT_NF=null
 ,RETARDRETINT_B=null
 ,NEWCOLS1_NF=null
 ,NEWCOLS2_NF=null
 ,NEWCOLS3_NF=null
 ,NEWCOLS4_NF=null
 ,NEWCOLS5_NF=null
 ,NEWCOLS6_NF=null
 ,NEWCOLS7_NF=null
 ,NEWCOLS8_NF=null
 ,NEWCOLS9_NF=null
from BCTA..TACCTRNF A, BFAC..TCONTR B, BREF..TDETTRS C, BREF..TBATCHSSD x
where A.CTR_NF = B.CTR_NF
  and A.UWY_NF = B.UWY_NF
  and A.UW_NT  = B.UW_NT
  and A.END_NT = B.END_NT
  and A.TRNCOD_CF = C.DETTRS_CF
  and B.SSD_CF=x.SSD_CF
  and A.SSD_CF=x.SSD_CF
  and x.BATCHUSER_CF=suser_name()
go
if object_id('dbo.PsACCTRNF_01') is not null
  print '<<< CREATED PROC dbo.PsACCTRNF_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsACCTRNF_01 >>>'
go
grant execute on dbo.PsACCTRNF_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCTRNF_01 TO GDBBATCH
go
