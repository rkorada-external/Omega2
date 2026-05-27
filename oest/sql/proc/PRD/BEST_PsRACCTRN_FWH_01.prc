USE BEST
go
IF OBJECT_ID('dbo.PsRACCTRN_FWH_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsRACCTRN_FWH_01
    IF OBJECT_ID('dbo.PsRACCTRN_FWH_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsRACCTRN_FWH_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsRACCTRN_FWH_01 >>>'
END
go
create procedure dbo.PsRACCTRN_FWH_01 (
    @DateFinBilan DATE
)
as
/***************************************************
Programme:                  PsRACCTRN_FWH_01.prc
Fichier script associé :    PsRACCTRN_FWH_01.PRC
Domaine :                   Retrocession
Base principale :           BEST
Version:                    1
Auteur:                     Cyrille DESPRET
Date de creation:           23/10/2013
Description du programme:   Funds helds for Retrocession
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
    NULL CTRNCOD_CF,
    NULL CTR_NF,
    NULL END_NT,
    NULL SEC_NF,
    NULL UWY_NF,
    NULL UW_NT,
    NULL OCCYEA_NF,
    NULL ACY_NF,
    NULL SCOSTRMTH_NF,
    NULL SCOENDMTH_NF,
    NULL CLM_NF,
    NULL CUR_CF,
    NULL ORICURAMT_M,
    NULL CED_NF,
    NULL BRK_NF,
    NULL PAY_NF,
    NULL KEY_NF,
    ACC.RETCTR_NF,
    0 RETEND_NT,
    ACC.RETSEC_NF,
    ACC.RTY_NF RETRTY_NF,
    1 RETUW_NT,
    NULL RETOCCYEA_NF,
    ACC.ACY_NF RETACY_NF,
    ACC.SCOSTRMTH_NF RETSCOSTRMTH_NF,
    ACC.SCOENDMTH_NF RETSCOENDMTH_NF,
    NULL RCL_NF,
    ACC.CUR_CF RETCUR_CF,
    ACC.TRN_M RETAMT_M,
    ACC.PLC_NT,
    ACC.RTO_NF,
    NULL INT_NF,
    NULL RETPAY_NF,
    NULL RETKEY_CF
 FROM BRET..TRACCTRN ACC
  WHERE
  -- Code Rétrocession / Non vie et Code Fund helds
  --  substring(ACC.TRNCOD_CF,1,1)  =  '2' AND substring(ACC.TRNCOD_CF,3,2) in('81','84') AND
  ACC.TRNCOD_CF like '2_8[14]%' AND

  -- Exclure regroupement LOB (Line of Business = métier) de la vie
  ACC.LOB_CF  NOT IN  ('30', '31') AND
  -- Test sur la date
  ACC.BLCSHT_D <= @DateFinBilan AND
  ACC.SSD_CF in (select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = @suser_Name)

return 0
go
EXEC sp_procxmode 'dbo.PsRACCTRN_FWH_01', 'unchained'
go
IF OBJECT_ID('dbo.PsRACCTRN_FWH_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsRACCTRN_FWH_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsRACCTRN_FWH_01 >>>'
go
GRANT EXECUTE ON dbo.PsRACCTRN_FWH_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsRACCTRN_FWH_01 TO GDBBATCH
go
