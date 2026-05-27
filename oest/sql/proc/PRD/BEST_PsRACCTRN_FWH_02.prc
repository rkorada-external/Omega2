USE BEST
go
IF OBJECT_ID('dbo.PsRACCTRN_FWH_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsRACCTRN_FWH_02
    IF OBJECT_ID('dbo.PsRACCTRN_FWH_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsRACCTRN_FWH_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsRACCTRN_FWH_02 >>>'
END
go
create procedure dbo.PsRACCTRN_FWH_02 (
	@suser_Name varchar(20)
)
as
/***************************************************
Programme:                  PsRACCTRN_FWH_02.prc
Fichier script associé :    PsRACCTRN_FWH_02.PRC
Domaine :                   Retrocession
Base principale :           BEST
Version:                    1
Auteur:                     JYP
Date de creation:           23/03/2022
Description du programme:   Funds helds for Retrocession for 20211231 with DBATOOLS
*****************************************************/
declare
 @site_cf    varchar(10)

SELECT
    ACC.SSD_CF,
    ACC.ESB_CF,
    '2022',
    '1' , 
    '1', 
    ACC.TRNCOD_CF,
    tc.ctrscod_cf,
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
    case when c.CUR_CF is not null then  'EUR' else  ACC.CUR_CF end,
    case when c.CUR_CF is not null then round( ACC.TRN_M  / c.EXC_R , 2) else ACC.TRN_M  end ,
    ACC.PLC_NT,
    ACC.RTO_NF,
    NULL INT_NF,
    NULL RETPAY_NF,
    NULL RETKEY_CF
 FROM BRET..TRACCTRN ACC ,  bref..teurocur c , bref..tdettrs tc
  WHERE
  (ACC.TRNCOD_CF like '2_8[14]%'  OR ACC.TRNCOD_CF like '4_8[14]%'  ) AND 
  ACC.BLCSHT_D <= '20211231' AND
  ACC.SSD_CF in (select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = @suser_Name)
  AND ACC.CUR_CF *= c.CUR_CF 
  AND ACC.TRNCOD_CF *= tc.DETTRS_CF
  AND NOT (RETCTR_NF = '10Z07100W' AND ACC.RTY_NF = 1992 AND ACC.RETSEC_NF = 18 )

return 0
go
EXEC sp_procxmode 'dbo.PsRACCTRN_FWH_02', 'unchained'
go
IF OBJECT_ID('dbo.PsRACCTRN_FWH_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsRACCTRN_FWH_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsRACCTRN_FWH_02 >>>'
go
GRANT EXECUTE ON dbo.PsRACCTRN_FWH_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsRACCTRN_FWH_02 TO GDBBATCH
go
