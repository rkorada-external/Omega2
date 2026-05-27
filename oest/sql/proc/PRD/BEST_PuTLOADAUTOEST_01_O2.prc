USE BEST
go
IF OBJECT_ID('PuTLOADAUTOEST_01_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PuTLOADAUTOEST_01_O2
  IF OBJECT_ID('PuTLOADAUTOEST_01_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE PuTLOADAUTOEST_01_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE PuTLOADAUTOEST_01_O2 >>>'
END
go
create procedure PuTLOADAUTOEST_01_O2 (
	@p_ssd_cf USSD_CF,
	@p_esb_cf UESB_CF,
	@p_file_ll UL64,
	@p_fileunixname_ll UL64,
	@p_provider_cf UL16,
	@p_usr_cf UUSR_CF,
	@p_file_no_nt int,
	@p_max_upld_no_nt int,
  @p_mode char(1),
	@p_status_cf int = null,
	@p_nb_lines int = null
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain: Estimate
Base: BEST
Version: 1
Author: L. Wernert
Creation date: 10/08/2020
Description: Management of the tracking of automatic estimate loadings
Called by:
- ESIJ0811.cmd
_________________
Modification 1
Author: L. Wernert
Date: 12/10/2020
Description: 90632 - Add a date for files that will crash 
*****************************************************/
DECLARE
  @err int,
  @lines int,
  @datej char(20),
  @upld_no_nt int,
  @file_no_nt int,
  @nb_ano_ct int,
  @tran_imbr bit

SELECT @tran_imbr = 1


-- I: Inserting a new file upload tracking line
IF (@p_mode = 'I')
BEGIN
	IF @@trancount = 0
	BEGIN
   	SELECT @tran_imbr = 0
 		BEGIN TRAN
	END
		
  -- Insert in BEST..TLOADAUTOEST
	INSERT INTO 
		BEST..TLOADAUTOEST (UPLDNO_NT, FILENO_NT, SSD_CF, ESB_CF, FILE_LL, FILEUNIXNAME_LL, FILETYPE_NT, CRE_D, PROVIDER_CF, NBLINES_NT, NBLINESKO_NT, NBANO_NT, CREUSR_CF, STATUS_CF) 
	VALUES 
		(@p_max_upld_no_nt, @p_file_no_nt, @p_ssd_cf, @p_esb_cf, @p_file_ll, @p_fileunixname_ll, 1, getdate(), @p_provider_cf, @p_nb_lines, 0, 0, @p_usr_cf, @p_status_cf)
END

if @tran_imbr = 0
	COMMIT TRAN
	
	
-- U: Updating the file status
IF (@p_mode = 'U')
BEGIN
	IF @@trancount = 0
	BEGIN
   	SELECT @tran_imbr = 0
 		BEGIN TRAN
	END
	
	IF (@p_status_cf = null)
  BEGIN
		IF @@trancount = 0
  	BEGIN
	   	SELECT @tran_imbr = 0
   		BEGIN TRAN
  	END
	      
    -- Begin estimate treatment: update CRE_D
    UPDATE 
			BEST..TLOADAUTOEST 
    SET 
			CRE_D = getdate()
    WHERE 
			FILENO_NT = @p_file_no_nt
  END
	
	-- 10: Closed with anomalies	
  IF (@p_status_cf = 10)
	BEGIN
    -- Update BEST..TLOADAUTOEST with the new status
		SELECT 
			@nb_ano_ct = count(*) 
		FROM 
			BTRAV..EST_ESID0811_TCTRANO
    WHERE 
			SSD_CF = @p_ssd_cf  AND 
			SEGTYP_CT = 'L' AND 
			SEG_NF = @p_usr_cf AND 
			NUMLINE_NT != 0 AND 
			ESB_CF = @p_esb_cf AND 
			ANO_CT != 1
		
    UPDATE 
			BEST..TLOADAUTOEST 
    SET 
			STATUS_CF = @p_status_cf, 
      NBLINESKO_NT = @nb_ano_ct,
      NBANO_NT = @nb_ano_ct
    WHERE 
			FILENO_NT = @p_file_no_nt
  END
	
	-- 2: Closed if no anomalies are found
	IF (@p_status_cf = 2)
  BEGIN
		IF @@trancount = 0
  	BEGIN
	   	SELECT @tran_imbr = 0
   		BEGIN TRAN
  	END
	      
    -- Update BEST..TLOADAUTOEST with the status 2: "Closed"
    UPDATE 
			BEST..TLOADAUTOEST 
    SET 
			STATUS_CF = @p_status_cf 
    WHERE 
			FILENO_NT = @p_file_no_nt
  END
END

if @tran_imbr = 0
	COMMIT TRAN


select @err = @@error, @lines = @@rowcount, @datej = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8)
print 'Updated BEST..TLOADAUTOEST: lines = %1! @ %2!', @lines, @datej     

go
EXEC sp_procxmode 'PuTLOADAUTOEST_01_O2', 'unchained'
go

IF OBJECT_ID('PuTLOADAUTOEST_01_O2') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE PuTLOADAUTOEST_01_O2 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE PuTLOADAUTOEST_01_O2 >>>'
go
GRANT EXECUTE ON PuTLOADAUTOEST_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PuTLOADAUTOEST_01_O2 TO GDBBATCH
go
