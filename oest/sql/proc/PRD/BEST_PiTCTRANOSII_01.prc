USE BEST
go
IF OBJECT_ID('dbo.PiTCTRANOSII_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiTCTRANOSII_01
    IF OBJECT_ID('dbo.PiTCTRANOSII_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiTCTRANOSII_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiTCTRANOSII_01 >>>'
END
go
create procedure dbo.PiTCTRANOSII_01
(
	@p_CTR_NF     UCTR_NF,
    @p_END_NT     UEND_NT,
    @p_SEC_NF     USEC_NF,
    @p_VRS_NF     numeric(10,0) ,
    @p_SSD_CF     USSD_CF,
    @p_SEGTYP_CT  USEGTYP_CT,
    @p_SEG_NF     USEG_NF,
    @p_ANO_CT     int,
    @p_NUMLINE_NT int,
    @p_erreur 	  char(64)   	= NULL OUTPUT
)
as

/***************************************************
Program: PiTCTRANOSII_01
Base principal : BEST
Description : SII03 - This stored procedure inserts the error and other details in the TCTRANO table.
Creation Date : 23/07/2014 (dd/mm/yyyy)
Author : Sohal SINHA
Version : 1.0
Parameters :CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT
Modification History :

*****************************************************/
declare @erreur                int,
        @tran_imbr             bit
		
select @erreur = 0		
select @tran_imbr = 1

if @@trancount = 0
	begin
		  select @tran_imbr = 0
		  begin tran tran_PiTCTRANOSII_01
	end

	IF NOT EXISTS (SELECT 1 FROM BEST..TCTRANO where 
				CTR_NF = @p_CTR_NF AND 
				END_NT = @p_END_NT AND 
				SEC_NF = @p_SEC_NF AND  
				VRS_NF = @p_VRS_NF AND 
				SSD_CF = @p_SSD_CF AND 
				SEGTYP_CT = @p_SEGTYP_CT AND  
				SEG_NF = @p_SEG_NF AND 
				ANO_CT = @p_ANO_CT AND 
				NUMLINE_NT = @p_NUMLINE_NT)
	BEGIN
		INSERT INTO
		BEST..TCTRANO( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
		VALUES( @p_CTR_NF, @p_END_NT, @p_SEC_NF, @p_VRS_NF, @p_SSD_CF, 
                @p_SEGTYP_CT, @p_SEG_NF, @p_ANO_CT, @p_NUMLINE_NT)
	END

select @erreur = @@error
if @erreur != 0 
   begin
    PRINT '<<< Insertion in TCTRANO table failed. >>>'
   	select @p_erreur = '20001 APPLICATIF'
	goto fin
   end

if @tran_imbr = 0 COMMIT TRAN tran_PiTCTRANOSII_01
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN tran_PiTCTRANOSII_01
return @erreur
go
EXEC sp_procxmode 'dbo.PiTCTRANOSII_01', 'unchained'
go
IF OBJECT_ID('dbo.PiTCTRANOSII_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiTCTRANOSII_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiTCTRANOSII_01 >>>'
go
GRANT EXECUTE ON dbo.PiTCTRANOSII_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiTCTRANOSII_01 TO GDBBATCH
go
