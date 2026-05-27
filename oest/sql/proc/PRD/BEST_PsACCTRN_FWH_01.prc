USE BEST
go
IF OBJECT_ID('dbo.PsACCTRN_FWH_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsACCTRN_FWH_01
    IF OBJECT_ID('dbo.PsACCTRN_FWH_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsACCTRN_FWH_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsACCTRN_FWH_01 >>>'
END
go
create procedure dbo.PsACCTRN_FWH_01 (
  @p_DateClosing DATE
)

as
/***************************************************
Programme:                  PsACCTRN_FWH_01.prc
Fichier script associé :    PsACCTRN_FWH_01.PRC
Domaine :                   Acceptation compta
Base principale :           BEST
Version:                    1
Auteur:                     Cyrille DESPRET
Date de creation:           23/10/2013
Description du programme:   Funds helds for Acceptation
_________________
MODIFICATIONS
[000] 23/10/2013  Cyrille Despret       :spot:26391 Creation
[001] 10/12/2014  Cyrille DESPRET       :spot:26391  Ajout du filtre sur les filiales
*****************************************************/
declare
  @erreur int
 ,@site_cf    varchar(10)
 ,@suser_Name varchar(20)
 ,@p_CRE_D                 datetime
 ,@p_date_t                datetime
 ,@p_site_cf               varchar(10)
 ,@P_Booking_D             Char(8)
 ,@P_PsTomGen_D            Char(8)
 ,@P_EnConso_D             Char(8)
 ,@P_DateInventaireConso   Char(8)
 ,@P_PeriodeConsoAA        numeric(4,0)
 ,@P_PeriodeConsoMM        numeric(2,0)
 ,@P_DateInventaireService Char(8)
 ,@P_PeriodeServiceAA      numeric(4,0)
 ,@P_PeriodeServiceMM      numeric(2,0)
 ,@P_SuffixeTable          char(1)
 ,@P_Erreur                int
 ,@P_EBSPsTomGen_D         Char(8)
 ,@P_Booking17_D           Char(8)
 ,@P_PsTomGen17_D          Char(8)
 ,@P_EnConso17_D           Char(8)

select @erreur=0,@p_CRE_D=getdate(),@suser_Name=suser_Name()

Execute @erreur=BEST..PsSITE_01 @suser_Name,'0',@site_cf output
if @erreur != 0
begin
  raiserror 20005 'APPLICATIF;PsSITE_01'
  return @erreur
end

execute PtREQJOB_05
 @p_CRE_D,@site_cf,
 @P_Booking_D             output,     -- Date de Booking T-1
 @P_PsTomGen_D            output,     -- Date de Fin de Saisie Post Omega Social (Periode T)
 @P_EnConso_D             output,     -- Date de Fin de Saisie Ecritures Conso (Periode T)
 @P_DateInventaireConso   output,     -- Periode AAAAMM Pour Saisie Ecriture Conso & Social (Periode T-1)
 @P_PeriodeConsoAA        output,     -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
 @P_PeriodeConsoMM        output,     -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
 @P_DateInventaireService output,     -- Periode AAAAMM Pour Saisie Ecriture Services (Periode T)
 @P_PeriodeServiceAA      output,     -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
 @P_PeriodeServiceMM      output,     -- Periode MM Pour Saisie Ecriture Services (Periode T)
 @P_SuffixeTable          output,
 @P_Erreur                output,     -- CodeRetour Erreur pour Message Appli
 @P_EBSPsTomGen_D         output,     -- Date de Fin de Saisie Post Omega Social (Periode
 @P_Booking17_D	          output,       
 @P_PsTomGen17_D          output,
 @P_EnConso17_D           output
select @erreur= @@error
If @erreur != 0
Begin
    Raiserror 20005 'APPLICATIF;PtREQJOB_05'
    Return @erreur
End

SELECT
    ACC.SSD_CF,
    ACC.ESB_CF,
    BALSHEY_NF=@P_PeriodeConsoAA,
    BALSHRMTH_NF=right(convert(char(3),@P_PeriodeConsoMM+100),2),
    BALSHRDAY_NF=right(convert(char(3),day(BLCSHT_D)+100),2),
    ACC.TRNCOD_CF,
    ACC.CTRNCOD_CF,
    ACC.CTR_NF,
    ACC.END_NT,
    ACC.SEC_NF,
    ACC.UWY_NF,
    ACC.UW_NT,
    ACC.OCCYEA_NF,
    ACC.ACY_NF,
    ACC.SCOSTRMTH_NF,
    ACC.SCOENDMTH_NF,
    ACC.CLM_NF,
    ACC.CUR_CF,
    ACC.ORICURAMT_M,
    ACC.CED_NF,
    NULL BRK_NF,
    NULL PAY_NF,
    NULL KEY_NF,
    NULL RETCTR_NF,
    NULL RETEND_NT,
    NULL RETSEC_NF,
    NULL RETRTY_NF,
    NULL RETUW_NT,
    NULL RETOCCYEA_NF,
    NULL RETACY_NF,
    NULL RETSCOSTRMTH_NF,
    NULL RETSCOENDMTH_NF,
    NULL RCL_NF,
    NULL RETCUR_CF,
    NULL RETAMT_M,
    NULL PLC_NT,
    NULL RTO_NF,
    NULL INT_NF,
    NULL RETPAY_NF,
    NULL RETKEY_CF/*,
    0.000,
    NULL CompanyCode,
    NULL CompanyID,
    NULL LedgerGroup,
    NULL GL_ACCOUNT_Principal,
    NULL GL_ACCOUNT_CounterPart,
    NULL Accounting_Year,
    NULL Accounting_Month,
    NULL Partner,
    NULL Cedent,
    NULL Segment,
    NULL Transaction_Type,
    NULL GAAP_Diff,
    NULL Document_Type,
    NULL Reconciliation_Key,
    ACC.TRN_NT,
    'FWHGTA' ORICOD_LS  */
 FROM BCTA..TACCTRN ACC
 WHERE
  (
  -- Acceptation / No Life and Funds held
  -- substring(ACC.TRNCOD_CF,1,1)  =  '1' AND substring(ACC.TRNCOD_CF,3,2)  in('81','84') AND
  ACC.TRNCOD_CF like '1_8[14]%' AND

  -- LOB (Line of Business) : No life
  ACC.LOB_CF  NOT IN  ('30', '31') AND

  -- Dates : écritures dont la date d'écriture est antérieure ou égale à la date considérée
  -- et qui ne sont pas lettrées ou ont été lettrées après la date considérée
  ACC.BLCSHT_D  <=  @p_DateClosing AND
  (Substring(
      replicate('N', 1*(1 - abs(sign(ACC.MTH_B-0))))
     +replicate('Y', 1*(1 - abs(sign(ACC.MTH_B-1)))), 1, 1)  =  'N'
  OR
   Substring(
     replicate('N', 1*(1 - abs(sign(ACC.MTH_B-0))))
    +replicate('Y', 1*(1 - abs(sign(ACC.MTH_B-1)))), 1, 1)  =  'Y'
  AND
   ACC.MTH_D  >  @p_DateClosing)
  ) AND
  ACC.SSD_CF in (select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = @suser_Name)

return 0
go
EXEC sp_procxmode 'dbo.PsACCTRN_FWH_01', 'unchained'
go
IF OBJECT_ID('dbo.PsACCTRN_FWH_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsACCTRN_FWH_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsACCTRN_FWH_01 >>>'
go
GRANT EXECUTE ON dbo.PsACCTRN_FWH_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCTRN_FWH_01 TO GDBBATCH
go
