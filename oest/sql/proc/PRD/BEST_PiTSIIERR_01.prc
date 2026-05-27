USE BEST
go

IF OBJECT_ID('dbo.PiTSIIERR_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiTSIIERR_01
    IF OBJECT_ID('dbo.PiTSIIERR_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiTSIIERR_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiTSIIERR_01 >>>'
END
go

create procedure dbo.PiTSIIERR_01
(
@p_upid_nt              int,
@p_iliasnbr_nt          int,
@p_mess_n               int,
@p_errtyp_ct            UBANVAL_CT,
@p_messthm_c            UMESSTHM_C,
@p_errrow_nf            int,
@p_errcol_lm            UL32,
@p_ctr_nf               UCTR_NF,
@p_sec_nf               USEC_NF,
@p_usr_cf            	UUPDUSR_CF,
@p_erreur 	    	    char(64)   = NULL OUTPUT
)
as

/***************************************************
Program: PiTSIIERR_01
Base principal : BEST
Description : SII03 - This stored procedure inserts the error and other details in the TSIIERR table.
Creation Date : 07/05/2014 (dd/mm/yyyy)
Author : AdbulWaajed SHAIKH
Version : 1.0

Modification History :
_________________
MODIFICATION 0001
Author:
Date:
Version: 1.1
Description:

*****************************************************/
declare @erreur                int,
        @tran_imbr             bit
		
select @erreur = 0		
select @tran_imbr = 1

if @@trancount = 0
	begin
		  select @tran_imbr = 0
		  begin tran tran_PiTSIIERR_01
	end

	INSERT INTO TSIIERR
		  (
			UPID_NT,
			ILIASNBR_NT,
			MESS_N,
			ERRTYP_CT,
			MESSTHM_C,
			ERRROW_NF,
			ERRCOL_LM,
			CTR_NF,
			SEC_NF,
			CRE_D,
			CREUSR_CF,
			LSTUPD_D,
			LSTUPDUSR_CF
		  )
		  VALUES
		  (
			@p_upid_nt,
			@p_iliasnbr_nt,
			@p_mess_n,
			@p_errtyp_ct,
			@p_messthm_c,
			@p_errrow_nf,
			@p_errcol_lm,
			@p_ctr_nf,
			@p_sec_nf,
			getdate(),
            @p_usr_cf,
            getdate(),
            @p_usr_cf
		  )	

select @erreur = @@error
if @erreur != 0 
   begin
    PRINT '<<< Insertion in TSIIERR table failed. >>>'
   	select @p_erreur = '20001 APPLICATIF'
	goto fin
   end

if @tran_imbr = 0 COMMIT TRAN tran_PiTSIIERR_01
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN tran_PiTSIIERR_01
return @erreur
go

EXEC sp_procxmode 'dbo.PiTSIIERR_01', 'unchained'
go

IF OBJECT_ID('dbo.PiTSIIERR_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiTSIIERR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiTSIIERR_01 >>>'
go
GRANT EXECUTE ON dbo.PiTSIIERR_01 TO GOMEGA
go
grant execute on dbo.PiTSIIERR_01 to GDBBATCH
go
