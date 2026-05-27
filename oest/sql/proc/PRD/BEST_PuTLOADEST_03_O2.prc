USE BEST
go
IF OBJECT_ID('PuTLOADEST_03_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PuTLOADEST_03_O2
    IF OBJECT_ID('PuTLOADEST_03_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PuTLOADEST_03_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PuTLOADEST_03_O2 >>>'
END
go
create procedure PuTLOADEST_03_O2 (
@p_ssd_cf USSD_CF,
@p_esb_cf UESB_CF,
@p_usr_cf UUSR_CF,
@p_status_cf int
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain          : Estimate
Base              : BEST
Version           : 1
Author            : Lilian Wernert
Creation date   : 25/04/2018

Description       : PLAN ADJ. - Update file loading status in BEST..TLOADEST after an ESID0871 job launch regarding the status passed in parameter and the presence of anomalies in BEST..TCTRANO
_________________
Modification X - 
Author: 
Date: XX/XX/XXXX
Description: 
*****************************************************/
 DECLARE
    @err                int,
    @lines              int,
    @datej              char(20),
    @status		        int,
    @file_no_nt 	    int,
	@nb_ano_ct			int,
	@tran_imbr 			bit

SELECT @tran_imbr = 1


-- 1: In force
IF (@p_status_cf = 1)
    BEGIN
		IF @@trancount = 0
		  	BEGIN
			   	SELECT @tran_imbr = 0
		   		BEGIN TRAN
		  	END
        -- Retrieve file number from TLOADEST
        SELECT @file_no_nt = MAX(FILENO_NT)
        FROM BEST..TLOADEST 
        WHERE FILETYPE_NT = 3 
        AND SSD_CF = @p_ssd_cf 
        AND ESB_CF = @p_esb_cf
        AND CREUSR_CF = @p_usr_cf 
        
        -- Update BEST..TLOADEST with the new status
        UPDATE BEST..TLOADEST 
        SET STATUS_CF = @p_status_cf 
        WHERE FILENO_NT = @file_no_nt
    END

if @tran_imbr = 0
	COMMIT TRAN
	
	
-- 10: Closed with anomalies or 2: Closed if no anomalies are found
IF (@p_status_cf = 10)
    BEGIN
		IF @@trancount = 0
		  	BEGIN
			   	SELECT @tran_imbr = 0
		   		BEGIN TRAN
		  	END
			
		-- 10: Closed with anomalies	
        IF EXISTS (SELECT * FROM BEST..TCTRANO
                            WHERE SSD_CF = @p_ssd_cf  AND SEGTYP_CT='P' 
                            AND SEG_NF = @p_usr_cf and NUMLINE_NT != 0 
                            AND ANO_CT != 1)
            BEGIN
                -- Retrieve file number from TLOADEST
                SELECT @file_no_nt = MAX(FILENO_NT)
                FROM BEST..TLOADEST 
                WHERE FILETYPE_NT = 3 
                AND SSD_CF = @p_ssd_cf 
                AND ESB_CF = @p_esb_cf
                AND CREUSR_CF = @p_usr_cf 
                
                -- Update BEST..TLOADEST with the new status
				SELECT @nb_ano_ct = count(*) 
				FROM BEST..TCTRANO 
                WHERE SSD_CF = @p_ssd_cf  AND SEGTYP_CT = 'P' 
                AND SEG_NF = @p_usr_cf and NUMLINE_NT != 0 
                AND ANO_CT != 1
				
                UPDATE BEST..TLOADEST 
                SET STATUS_CF = @p_status_cf, 
	                NBLINESKO_NT = @nb_ano_ct,
	                NBANO_NT = @nb_ano_ct
                WHERE FILENO_NT = @file_no_nt
            END
			
		-- 2: Closed if no anomalies are found	
		IF NOT EXISTS (SELECT * FROM BEST..TCTRANO
                WHERE SSD_CF = @p_ssd_cf  AND SEGTYP_CT='P' 
                AND SEG_NF = @p_usr_cf and NUMLINE_NT != 0 
                AND ANO_CT != 1)
		    BEGIN
				IF @@trancount = 0
				  	BEGIN
					   	SELECT @tran_imbr = 0
				   		BEGIN TRAN
				  	END
		        -- Retrieve file number from TLOADEST
		        SELECT @file_no_nt = MAX(FILENO_NT)
		        FROM BEST..TLOADEST 
		        WHERE FILETYPE_NT = 3 
		        AND SSD_CF = @p_ssd_cf 
		        AND ESB_CF = @p_esb_cf
		        AND CREUSR_CF = @p_usr_cf 
		        
		        -- Update BEST..TLOADEST with the status 2: "Closed"
		        UPDATE BEST..TLOADEST 
		        SET STATUS_CF = 2 
		        WHERE FILENO_NT = @file_no_nt
		    END
    END

if @tran_imbr = 0
	COMMIT TRAN


select @err = @@error, @lines = @@rowcount, @datej = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8)
print 'Updated BEST..TLOADEST: lines = %1! @ %2!', @lines, @datej     

go
EXEC sp_procxmode 'PuTLOADEST_03_O2', 'unchained'
go

IF OBJECT_ID('PuTLOADEST_03_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PuTLOADEST_03_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PuTLOADEST_03_O2 >>>'
go
GRANT EXECUTE ON PuTLOADEST_03_O2 TO GOMEGA
go
GRANT EXECUTE ON PuTLOADEST_03_O2 TO GDBBATCH
go
