USE BEST
go
IF OBJECT_ID('PiCTRANO_02_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PiCTRANO_02_O2
  IF OBJECT_ID('PiCTRANO_02_O2') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE PiCTRANO_02_O2 >>>'
  ELSE
		PRINT '<<< DROPPED PROCEDURE PiCTRANO_02_O2 >>>'
END
go

create procedure PiCTRANO_02_O2(
  @p_ssd_cf     USSD_CF,
  @p_esb_cf     UESB_CF,
  @p_usr_cf 		UUSR_CF,
	@p_cre_d			datetime,
	@p_run_mode		varchar(1),
	@p_file_name	varchar(255),
	@p_fileno_nt  int = null
)
with execute as caller as

/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Amit D
Creation date     : 11/04/2014

Description       :  This procedure updates TCTRANO  with the data from BTRAV...EST_ESID0811_TCTRANO 
_________________
Domain            : Estimate
Base              : BEST
Version           : 2
Author            : Manoja Swaro
Creation date     : 15/09/2014

Description       :  duplicate key insert into best..TCTRANO table
_________________
Domain            : Estimate
Base              : BEST
Version           : 3
Author            : Sumit Gupta
Creation date     : 09/12/2014

Description       :  File upload : errors not inserted => estimates not loaded [IN:033273]
_________________
modified by :- Manish paryani ( defect no. 035005)
_________________
Modification      : [MOD5] 
Domain            : Estimate
Base              : BEST
Version           : 5
Author            : L. Wernert
Creation date     : 10/10/2018

Description       : Delete anomalies from previous treatments
_________________
Modification      : [MOD6] 
Domain            : Estimates
Base              : BEST
Version           : 6
Author            : L. Wernert
Creation date     : 06/04/2020
Spira							: 82192
Description       : Add statements in order to handle automatic estimates upload
_________________
Modification      : [MOD7] 
Domain            : Estimates
Base              : BEST
Version           : 6
Author            : L. Wernert
Creation date     : 12/08/2020
Spira							: 87213
Description       : Link between TLOADAUTOEST and TANOUPLD
*****************************************************/


declare @erreur int,
				@file_id int,
				@max_file_id int
				

IF @p_run_mode = 'A'
BEGIN
	INSERT INTO 
		TANOUPLD
	SELECT DISTINCT
		@p_fileno_nt,
		NUMLINE_NT,
		CTR_NF,
		SEC_NF,
		UWY_NF,
		ACY_NF,
		GAAP_NT,
		DETTRNCOD_CF,
		SEGTYP_CT,
		SEG_NF,
		ANO_CT,
		@p_cre_d,
		@p_file_name
	FROM 
		BTRAV..EST_ESID0811_TCTRANO
	WHERE
		SSD_CF = @p_ssd_cf AND 
		ESB_CF = @p_esb_cf AND 
		USR_CF = @p_usr_cf
END
ELSE
BEGIN
	DELETE 
		BEST..TCTRANO 
	WHERE 
		SEG_NF=@p_usr_cf AND 
		SSD_CF=@p_ssd_cf AND 
		SEGTYP_CT='L' --[MOD5]

	INSERT INTO TCTRANO
	SELECT DISTINCT --2
		CTR_NF,
		END_NT,
		SEC_NF,
		VRS_NF,
		SSD_CF,
		SEGTYP_CT,
		SEG_NF,
		ANO_CT,
		NUMLINE_NT+1, --modified for #035005
		UWY_NF,
		ACY_NF
	FROM 
		BTRAV..EST_ESID0811_TCTRANO
	WHERE -- a.BLOCKING_B = 1 -- 3
		SSD_CF = @p_ssd_cf AND 
		ESB_CF = @p_esb_cf AND 
		USR_CF = @p_usr_cf
END

select @erreur = @@error
if @erreur != 0
begin
  raiserror 20001 "APPLICATIF;ESID0811:TCTRANO" 
  return @erreur       
end

go
EXEC sp_procxmode 'PiCTRANO_02_O2', 'unchained'
go
IF OBJECT_ID('PiCTRANO_02_O2') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE PiCTRANO_02_O2>>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE PiCTRANO_02_O2>>>'
go
GRANT EXECUTE ON PiCTRANO_02_O2 TO GOMEGA
go
GRANT EXECUTE ON PiCTRANO_02_O2 to GDBBATCH
go