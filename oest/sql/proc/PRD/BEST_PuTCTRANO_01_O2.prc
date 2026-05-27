use BEST
go

IF OBJECT_ID ('PuTCTRANO_01_O2') IS NOT NULL
   BEGIN
      DROP PROCEDURE PuTCTRANO_01_O2

      IF OBJECT_ID ('PuTCTRANO_01_O2') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE PuTCTRANO_01_O2 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE PuTCTRANO_01_O2 >>>'
   END
go

create procedure PuTCTRANO_01_O2
(
  @p_ssd_cf       USSD_CF,
  @p_esb_cf       UESB_CF,
  @p_usr_cf       UUSR_CF
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain          : Estimate
Base              : BTRAV
Version           : 1
Author            : Lilian Wernert
Creation date   : 20/12/2018
Description       : ESTIMATION - [73919] Update the ERRORCODE_CT of BTRAV..EST_ESID0811_PERIMETER with the one from BTRAV..EST_ESID0811_TCTRANO and insert them in BTRAV..EST_ESID0811_TCTRANO
_________________
Modification MOD 1 - [77674]
Author: ThD
Date: 16/04/2019
Description: Delete data from BTRAV TCTARNO before update BTRAV TCTRANO
_________________
Modification 2 - [78745]
Author: L. Wernert
Date: 20/09/2019
Description: Adding fields in the join between the perimeter and the anomalies for more accuracy
_________________
Modification 2 - [82192]
Author: L. Wernert
Date: 06/05/2020
Description: Replace NULL by the ACY in insert statement
*****************************************************/
declare 
  @tran_imbr			bit,
  @erreur int      

SELECT @tran_imbr = 1

UPDATE 
  BTRAV..EST_ESID0811_PERIMETER
SET 
  ERRORCODE_CT = ANO_CT
FROM 
  BTRAV..EST_ESID0811_TCTRANO t, BTRAV..EST_ESID0811_PERIMETER p
WHERE 
  p.CTR_NF = t.CTR_NF AND 
  p.UWY_NF = t.UWY_NF AND 
  p.ACY_NF = t.ACY_NF AND 
  p.USR_CF = t.USR_CF AND 
  p.SSD_CF = t.SSD_CF AND 
  p.ESB_CF = t.ESB_CF AND 
  p.SEC_NF = t.SEC_NF AND
  p.GAAP_NT = t.GAAP_NT AND
  p.DETTRNCOD_CF = t.DETTRNCOD_CF


SELECT @erreur = @@error
IF @erreur != 0
  BEGIN
    RAISERROR 20004 "APPLICATIF;BTRAV..EST_ESID0811_PERIMETER"
    RETURN @erreur
  END


DELETE FROM 
	BTRAV..EST_ESID0811_TCTRANO
WHERE 
	SSD_CF = @p_ssd_cf AND 
	ESB_CF = @p_esb_cf AND 
	USR_CF = @p_usr_cf


INSERT INTO BTRAV..EST_ESID0811_TCTRANO
(
  CTR_NF, 
  END_NT, 
  SEC_NF, 
  VRS_NF, 
  SSD_CF, 
  SEGTYP_CT, 
  SEG_NF, 
  ANO_CT, 
  NUMLINE_NT, 
  UWY_NF,
  ACY_NF,
  BLOCKING_B,
  ESB_CF,
  USR_CF,
	GAAP_NT,
  DETTRNCOD_CF
)
SELECT 
	t.CTR_NF,
	t.END_NT,
	t.SEC_NF,
	1,
	@p_ssd_cf,
	'L',
	@p_usr_cf,
	t.ERRORCODE_CT,
	NUMLINE_NT,
	t.UWY_NF,
	t.ACY_NF,
	1,
	@p_esb_cf,
	@p_usr_cf,
	t.GAAP_NT,
  t.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESID0811_PERIMETER t
WHERE 
	t.ERRORCODE_CT != NULL AND 
	t.SSD_CF = @p_ssd_cf AND 
	t.ESB_CF = @p_esb_cf AND 
	t.USR_CF = @p_usr_cf

SELECT @erreur = @@error
IF @erreur != 0
  BEGIN
    RAISERROR 20001 "APPLICATIF;BTRAV..EST_ESID0811_PERIMETER"
    RETURN @erreur
  END
        
if @tran_imbr = 0
	COMMIT TRAN                                                                                                                                                                     


go
EXEC sp_procxmode 'PuTCTRANO_01_O2', 'unchained'
go

IF OBJECT_ID ('PuTCTRANO_01_O2') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE PuTCTRANO_01_O2 >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE PuTCTRANO_01_O2 >>>'
go

GRANT EXECUTE ON PuTCTRANO_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PuTCTRANO_01_O2 TO GDBBATCH
go
