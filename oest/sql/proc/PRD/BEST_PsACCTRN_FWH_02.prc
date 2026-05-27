USE BEST
go
IF OBJECT_ID('dbo.PsACCTRN_FWH_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsACCTRN_FWH_02
    IF OBJECT_ID('dbo.PsACCTRN_FWH_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsACCTRN_FWH_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsACCTRN_FWH_02 >>>'
END
go
create procedure dbo.PsACCTRN_FWH_02 (
    @suser_Name varchar(20)
)

as
/***************************************************
Programme:                  PsACCTRN_FWH_02.prc
Fichier script associé :    PsACCTRN_FWH_02.PRC
Domaine :                   Acceptation compta
Base principale :           BEST
Version:                    1
Auteur:                     JYP PERSEE
Date de creation:           24/03/2022
Description du programme:   Funds helds for Acceptation for 20211231 with DBATOOLS
*****************************************************/
declare
@p_DateClosing DATE
  

SELECT
    ACC.SSD_CF,
    ACC.ESB_CF,
    '2022',
    '1' , 
    '1', 
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
    case when c.CUR_CF is not null then  'EUR' else  ACC.CUR_CF end,
    case when c.CUR_CF is not null then round(ACC.ORICURAMT_M / c.EXC_R ,2) else ACC.ORICURAMT_M end ,
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
    NULL RETKEY_CF
 FROM BCTA..TACCTRN ACC ,  bref..teurocur c
 WHERE
  (
  ( ACC.TRNCOD_CF like '1_8[14]%' OR ACC.TRNCOD_CF like '3_8[14]%' ) AND 
  ACC.BLCSHT_D  <=  '20211231' AND
  (Substring(
      replicate('N', 1*(1 - abs(sign(ACC.MTH_B-0))))
     +replicate('Y', 1*(1 - abs(sign(ACC.MTH_B-1)))), 1, 1)  =  'N'
  OR
   Substring(
     replicate('N', 1*(1 - abs(sign(ACC.MTH_B-0))))
    +replicate('Y', 1*(1 - abs(sign(ACC.MTH_B-1)))), 1, 1)  =  'Y'
  AND
   ACC.MTH_D  >  '20211231' )
  ) AND
  ACC.SSD_CF in (select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = @suser_Name)
  AND ACC.CUR_CF *= c.CUR_CF 

return 0
go
EXEC sp_procxmode 'dbo.PsACCTRN_FWH_02', 'unchained'
go
IF OBJECT_ID('dbo.PsACCTRN_FWH_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsACCTRN_FWH_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsACCTRN_FWH_02 >>>'
go
GRANT EXECUTE ON dbo.PsACCTRN_FWH_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCTRN_FWH_02 TO GDBBATCH
go
