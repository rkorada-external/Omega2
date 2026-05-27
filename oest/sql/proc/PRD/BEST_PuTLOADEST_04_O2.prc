USE BEST
go
IF OBJECT_ID('PuTLOADEST_04_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PuTLOADEST_04_O2
    IF OBJECT_ID('PuTLOADEST_04_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PuTLOADEST_04_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PuTLOADEST_04_O2 >>>'
END
go
create procedure PuTLOADEST_04_O2 (
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

Description       : ESTIMATION - Update file loading status in BEST..TLOADEST after an ESID0811 job launch regarding the status passed in parameter and the presence of anomalies in BEST..TCTRANO
_________________
MODIFICATION  001
Auteur:       B. Lagha
Date:         10/02/2021
Version:      2
Description:  67721 : NUMLINE_NT peut etre egale a ZERO '0' et le nombre de ligne KO peut etre != du nombre d'anomalies.
*****************************************************/
 DECLARE
    @err                int,
    @lines              int,
    @datej              char(20),
    @status		        int,
    @file_no_nt 	    int,
	@nb_ano_ct			int,
	@nb_LineKo_ct		int,
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
        WHERE FILETYPE_NT = 1 
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
        IF EXISTS (SELECT * FROM BTRAV..EST_ESID0811_TCTRANO
                            WHERE SSD_CF = @p_ssd_cf  AND SEGTYP_CT='L' 
                            AND SEG_NF = @p_usr_cf --and NUMLINE_NT != 0 
							AND NUMLINE_NT != NULL
							AND ESB_CF = @p_esb_cf
                            AND ANO_CT != 1)
            BEGIN
                -- Retrieve file number from TLOADEST
                SELECT @file_no_nt = MAX(FILENO_NT)
                FROM BEST..TLOADEST 
                WHERE FILETYPE_NT = 1 
                AND SSD_CF = @p_ssd_cf 
                AND ESB_CF = @p_esb_cf
                AND CREUSR_CF = @p_usr_cf 
                
                -- Update BEST..TLOADEST with the new status
				SELECT @nb_ano_ct    = count(*),                  -- nombre d'anomalies
				       @nb_LineKo_ct = count(Distinct NUMLINE_NT) -- nombre de ligne KO
				FROM BTRAV..EST_ESID0811_TCTRANO
                WHERE SSD_CF = @p_ssd_cf  AND SEGTYP_CT = 'L' 
                AND SEG_NF = @p_usr_cf --and NUMLINE_NT != 0 
				AND NUMLINE_NT != NULL
				AND ESB_CF = @p_esb_cf
                AND ANO_CT != 1
				
                UPDATE BEST..TLOADEST 
                SET STATUS_CF = @p_status_cf, 
	                NBLINESKO_NT = @nb_LineKo_ct,
	                NBANO_NT = @nb_ano_ct
                WHERE FILENO_NT = @file_no_nt
            END
			
		-- 2: Closed if no anomalies are found
		IF NOT EXISTS (SELECT * FROM BTRAV..EST_ESID0811_TCTRANO
		                WHERE SSD_CF = @p_ssd_cf  AND SEGTYP_CT='L' 
		                AND SEG_NF = @p_usr_cf --and NUMLINE_NT != 0 
						AND NUMLINE_NT != NULL
						AND ESB_CF = @p_esb_cf
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
		        WHERE FILETYPE_NT = 1 
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
EXEC sp_procxmode 'PuTLOADEST_04_O2', 'unchained'
go

IF OBJECT_ID('PuTLOADEST_04_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PuTLOADEST_04_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PuTLOADEST_04_O2 >>>'
go
GRANT EXECUTE ON PuTLOADEST_04_O2 TO GOMEGA
go
GRANT EXECUTE ON PuTLOADEST_04_O2 TO GDBBATCH
go
