USE BEST
go

IF OBJECT_ID('PtRSKMRG_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PtRSKMRG_01
    IF OBJECT_ID('PtRSKMRG_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PtRSKMRG_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PtRSKMRG_01 >>>'
END
go

create procedure PtRSKMRG_01
(
	@p_CRE_D                UUPD_D,
	@p_clodat_d 			datetime,		--MOD003
	@p_per_cf   			char(3)			--MOD003
)
as

/***************************************************
Program: PtRSKMRG_01
Base principal : BEST
Description : EST49 - This SP uses cursor and call The store procedure BREF..PsCALEND_EBS with the the creation date as parameters, the following elements are retrieved :
The closing Type
The closing Date
Then, for each row in working table (BTRAV..EST_ESID0851_RSKMRGAMT), the row related is updated or created in Ulae Ratio table (BEST..TRSKMRGSSD) with the closing Type and Closing Date retrieved
Creation Date : 25/06/2014 (dd/mm/yyyy)
Author : Rahul Gandhe
Version : 1.0

Modification History :
_________________
MODIFICATION 0001
Author:
Date:
Version: 1.1
Description:
_________________
MODIFICATION 0002
Author: RGANDHE
Date: 15-JULY-2014
Version: 1.1
Description: Before inserting new rows, the Risk Margin table (BEST..TRSKMRGSSD) is cleaned removing the rows which match with the closing type and closing date just retrieved.
__________________
MODIFICATION 0003
Author: KBHIMASEN
Date: 18/04/2023
Version: 1.1
Spira:109188
Description: Two new input parameters are added, Initially we are retreving the closing date&type from calendar, now we are directly taking from the GUI screen.

*****************************************************/
DECLARE
@erreur      			int,
@p_LGENSGTVRS_NT        USGTVER_NT,                         
@p_LGENSGMT_NF          USGMT_NF,                                          
@p_LOBSIISGMTVRS_NT     USGTVER_NT,
@p_LOBSIISGMT_NF        USGMT_NF,
@p_NORME_CF             UBANVAL_CT,
@p_AMT_M             	UAMT_M,
@p_CUR_CF             	UCUR_CF,                        
@p_CREUSR_CF            UUPDUSR_CF,
@p_date   				datetime,
--@p_clodat_d 			datetime,
--@p_per_cf   			char(3),
@isExists				int       
	
	--The store procedure BREF..PsCALEND_EBS is called with the the creation date as parameters
	--MOD003 below code commented out because now we are directly taking the closing date & type value from screen.
--	exec @erreur = BREF..PsCALEND_EBS  @p_CRE_D ,1,@p_clodat_d output ,@p_per_cf output
--	if @erreur!=0 or @@error!=0 return 999
	
	--Before inserting new rows, the Risk Margin table (BEST..TRSKMRGSSD) is cleaned removing the rows which match with the closing type and closing date just retrieved.
	
	DELETE BEST..TRSKMRGSSD WHERE PER_CF = @p_per_cf AND CLOSING_D = @p_clodat_d	--modif 0002
	
	--for each row in working table (BTRAV..EST_ESID0851_RSKMRGAMT), the row related is updated or created in Ulae Ratio table (BEST..TRSKMRGSSD) with the closing Type and Closing Date retrieved
	
    DECLARE RSKMRGSSD_CUR CURSOR FOR
           SELECT LGENSGTVRS_NT, LGENSGMT_NF, LOBSIISGMTVRS_NT, LOBSIISGMT_NF, NORME_CF, AMT_M, CUR_CF, CREUSR_CF, CRE_D 
			FROM 
			BTRAV..EST_ESID0851_RSKMRGAMT
			if @@error!=0 return 999
	
	OPEN RSKMRGSSD_CUR
	
		fetch RSKMRGSSD_CUR into
			@p_LGENSGTVRS_NT, @p_LGENSGMT_NF, @p_LOBSIISGMTVRS_NT, @p_LOBSIISGMT_NF, @p_NORME_CF, @p_AMT_M, @p_CUR_CF, @p_CREUSR_CF, @p_CRE_D 
            IF (@@sqlstatus = 1)
					BEGIN
                    PRINT "ERROR in RSKMRGSSD_CUR Procedure PtRSKMRG_01"
                    CLOSE RSKMRGSSD_CUR
                    RETURN
            END
            WHILE (@@sqlstatus != 2)
                BEGIN
					SET @isExists = (SELECT count(*) FROM BEST..TRSKMRGSSD where LGENSGTVRS_NT = @p_LGENSGTVRS_NT AND LGENSGMT_NF = @p_LGENSGMT_NF AND LOBSIISGMTVRS_NT = @p_LOBSIISGMTVRS_NT AND LOBSIISGMT_NF = @p_LOBSIISGMT_NF AND NORME_CF = @p_NORME_CF AND PER_CF = @p_per_cf AND CLOSING_D = @p_clodat_d)
						if (@isExists > 0)
							BEGIN
								UPDATE BEST..TRSKMRGSSD  SET AMT_M = @p_AMT_M, CREUSR_CF = @p_CREUSR_CF, CRE_D = @p_CRE_D WHERE LGENSGTVRS_NT = @p_LGENSGTVRS_NT AND LGENSGMT_NF = @p_LGENSGMT_NF AND LOBSIISGMTVRS_NT = @p_LOBSIISGMTVRS_NT AND LOBSIISGMT_NF = @p_LOBSIISGMT_NF AND NORME_CF = @p_NORME_CF AND PER_CF = @p_per_cf AND CLOSING_D = @p_clodat_d
								select @erreur=@@error
								if @erreur!=0 return 999
							END
							ELSE 
								BEGIN
									INSERT INTO BEST..TRSKMRGSSD
											(LGENSGTVRS_NT, LGENSGMT_NF, LOBSIISGMTVRS_NT, LOBSIISGMT_NF, NORME_CF, 
													PER_CF, CLOSING_D, AMT_M, CUR_CF, CREUSR_CF, CRE_D) 
											VALUES (@p_LGENSGTVRS_NT, @p_LGENSGMT_NF, @p_LOBSIISGMTVRS_NT, @p_LOBSIISGMT_NF, @p_NORME_CF, @p_per_cf, @p_clodat_d, @p_AMT_M, @p_CUR_CF, @p_CREUSR_CF, @p_CRE_D )
											select @erreur=@@error
											if @erreur!=0 return 999
								END
				

							fetch RSKMRGSSD_CUR into
								@p_LGENSGTVRS_NT, @p_LGENSGMT_NF, @p_LOBSIISGMTVRS_NT, @p_LOBSIISGMT_NF, @p_NORME_CF, @p_AMT_M, @p_CUR_CF, @p_CREUSR_CF, @p_CRE_D

                END
                CLOSE RSKMRGSSD_CUR
            DEALLOCATE CURSOR RSKMRGSSD_CUR
			
	return 0

Go

EXEC sp_procxmode 'PtRSKMRG_01', 'unchained'
go

IF OBJECT_ID('PtRSKMRG_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PtRSKMRG_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PtRSKMRG_01 >>>'
go
GRANT EXECUTE ON PtRSKMRG_01 TO GOMEGA
go
grant execute on PtRSKMRG_01 to GDBBATCH
go
