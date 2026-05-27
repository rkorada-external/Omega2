USE BEST
go

IF OBJECT_ID('PtULAERAT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PtULAERAT_01
    IF OBJECT_ID('PtULAERAT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PtULAERAT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PtULAERAT_01 >>>'
END
go

create procedure PtULAERAT_01
(
	@p_CRE_D                UUPD_D,
	@p_clodat_d 			datetime,			--MOD003
	@p_per_cf   			char(3)				--MOD003
)
as

/***************************************************
Program: PtULAERAT_01
Base principal : BEST
Description : EST49 - This SP uses cursor and call The store procedure BREF..PsCALEND_EBS with the the creation date as parameters, the following elements are retrieved :
The closing Type
The closing Date
Then, for each row in working table (BTRAV..EST_ESID0851_ULAERAT), the row related is updated or created in Ulae Ratio table (BEST..TULAERAT) with the closing Type and Closing Date retrieved
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
Description: Before inserting new data, the ULAE ratio table (BEST..TULAERAT) is cleaned removing the rows which match with the closing type and closing date just retrieved.
__________________
MODIFICATION 0003
Author: KBHIMASEN
Date: 18/04/2023
Version: 1.1
Spira:109188
Description: Two new input parameters are added, Initially we are retreving the closing date&type from calendar, now we are directly taking from the GUI screen.
__________________
20/03/2024 - DAD - spira:110913 - new column CTRNAT_CT, UWY_NF, LOBN2_NF added
*****************************************************/
DECLARE
@erreur      			int,
@p_SSD_CF               USSD_CF,                         
@p_ESB_CF               UESB_CF,                                          
@p_RATIO_NF             USHA_R,                        
@p_CREUSR_CF            UUPDUSR_CF,
@p_date   				datetime,
@p_CTRNAT_CT   			char(1),
@p_UWY_NF   			UUWY_NF,
@p_LOBN2_NF   			int,

--@p_clodat_d 			datetime,
--@p_per_cf   			char(3),
@isExists				int       
	
	--The store procedure BREF..PsCALEND_EBS is called with the the creation date as parameters
	--MOD003 below code commented out because now we are directly taking the closing date & type value from screen.
--	exec @erreur = BREF..PsCALEND_EBS  @p_CRE_D ,1,@p_clodat_d output ,@p_per_cf output
--	if @erreur!=0 or @@error!=0 return 999
	
	--Before inserting new data, the ULAE ratio table (BEST..TULAERAT) is cleaned removing the rows which match with the closing type and closing date just retrieved.
	
	DELETE BEST..TULAERAT WHERE PER_CF = @p_per_cf AND CLOSING_D = @p_clodat_d	--modif 0002
	
	--for each row in working table (BTRAV..EST_ESID0851_ULAERAT), the row related is updated or created in Ulae Ratio table (BEST..TULAERAT) with the closing Type and Closing Date retrieved
	
    DECLARE ULAERAT_CUR CURSOR FOR
           SELECT SSD_CF, ESB_CF, RATIO_NF, CRE_D, CREUSR_CF, CTRNAT_CT, UWY_NF, LOBN2_NF
			FROM 
			BTRAV..EST_ESID0851_ULAERAT
			if @@error!=0 return 999
	
	OPEN ULAERAT_CUR
	
		fetch ULAERAT_CUR into
			@p_SSD_CF , @p_ESB_CF , @p_RATIO_NF , @p_CRE_D , @p_CREUSR_CF , @p_CTRNAT_CT , @p_UWY_NF , @p_LOBN2_NF
            IF (@@sqlstatus = 1)
					BEGIN
                    PRINT "ERROR in ULAERAT_CUR Procedure PtULAERAT_01"
                    CLOSE ULAERAT_CUR
                    RETURN
            END
            WHILE (@@sqlstatus != 2)
                BEGIN
					SET @isExists = (SELECT count(*) FROM BEST..TULAERAT where SSD_CF = @p_SSD_CF AND ESB_CF = @p_ESB_CF AND PER_CF = @p_per_cf AND CLOSING_D = @p_clodat_d AND CTRNAT_CT = @p_CTRNAT_CT AND UWY_NF = @p_UWY_NF AND LOBN2_NF = @p_LOBN2_NF)
						if (@isExists > 0)
							BEGIN
								UPDATE BEST..TULAERAT  SET RATIO_NF = @p_RATIO_NF, CREUSR_CF = @p_CREUSR_CF, CRE_D = @p_CRE_D WHERE SSD_CF = @p_SSD_CF AND ESB_CF = @p_ESB_CF AND PER_CF = @p_per_cf AND CLOSING_D = @p_clodat_d AND CTRNAT_CT = @p_CTRNAT_CT AND UWY_NF = @p_UWY_NF AND LOBN2_NF = @p_LOBN2_NF
								select @erreur=@@error
								if @erreur!=0 return 999
							END
							ELSE 
								BEGIN
									INSERT INTO BEST..TULAERAT (SSD_CF, ESB_CF, PER_CF, CLOSING_D, RATIO_NF, CRE_D, CREUSR_CF, CTRNAT_CT, UWY_NF, LOBN2_NF) VALUES (@p_SSD_CF , @p_ESB_CF,@p_per_cf,@p_clodat_d, @p_RATIO_NF , @p_CRE_D , @p_CREUSR_CF, @p_CTRNAT_CT , @p_UWY_NF , @p_LOBN2_NF)
									select @erreur=@@error
									if @erreur!=0 return 999
								END
				

							fetch ULAERAT_CUR into
								@p_SSD_CF , @p_ESB_CF , @p_RATIO_NF , @p_CRE_D , @p_CREUSR_CF , @p_CTRNAT_CT , @p_UWY_NF , @p_LOBN2_NF

                END
                CLOSE ULAERAT_CUR
            DEALLOCATE CURSOR ULAERAT_CUR
			
	return 0

Go

EXEC sp_procxmode 'PtULAERAT_01', 'unchained'
go

IF OBJECT_ID('PtULAERAT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PtULAERAT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PtULAERAT_01 >>>'
go
GRANT EXECUTE ON PtULAERAT_01 TO GOMEGA
go
grant execute on PtULAERAT_01 to GDBBATCH
go
