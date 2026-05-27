USE BEST
GO

IF object_id('BEST.dbo.PiSGTRNW_01') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.PiSGTRNW_01
	 IF OBJECT_ID('dbo.PiSGTRNW_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiSGTRNW_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiSGTRNW_01 >>>'
END
GO


CREATE PROC PiSGTRNW_01
(
@p_sgttyp_nt int,
@p_rty_nf int,
@p_usr_cf UUPDUSR_CF,
@p_new_sgttyp_nt varchar(64)=NULL OUTPUT
)
AS

/*****************************************************
Domain : (SEG) SEGMENTATION
Base principle : BEST
Version : 1
Author : DheerajS
Creation Date : 23/07/2025
Program Description : Used to renew NP Retro Segmentation Type to Retro Underwriting Year + 1.
*****************************************************/

DECLARE @max_rty_nf int
DECLARE @max_sgttyp_nt int
DECLARE @max_sgt_nt int
DECLARE @tran_imbr int
DECLARE @sgt_nt int
DECLARE @sgtver_nt int


SELECT @tran_imbr = 1

IF @@trancount = 0
  BEGIN
   SELECT @tran_imbr = 0
   BEGIN TRAN
END


SELECT @max_sgttyp_nt = MAX(SGTTYP_NT)+1 FROM BEST..TSEGTYPE

SELECT @max_rty_nf = MAX(rty_nf)+1 FROM BEST..TSEGTYPE WHERE SGTTYP_NT = @p_sgttyp_nt

INSERT INTO BEST..TSEGTYPE(SGTTYP_NT, SGTTYP_LM, SGTMGTLVL_CT, SGTSCOPE_CT, SGTTYPSTS_CT, UWABSTR_B, CRE_D,
							CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, RTY_NF, SGTTYPMOD_NT)
							SELECT @max_sgttyp_nt, SGTTYP_LM, SGTMGTLVL_CT, SGTSCOPE_CT, '1', UWABSTR_B, getdate(),
							@p_usr_cf, getdate(), @p_usr_cf, @max_rty_nf, SGTTYPMOD_NT FROM BEST..TSEGTYPE WHERE SGTTYP_NT = @p_sgttyp_nt
IF @@ERROR <> 0 GOTO fin
							

DECLARE valid_Seg_Cursor CURSOR FOR 
SELECT SGT_NT, SGTVER_NT FROM BEST..TSEGMENTATION WHERE SGTTYP_NT = @p_sgttyp_nt AND SGTSTS_CF =  '3'
OPEN valid_Seg_Cursor
FETCH valid_Seg_Cursor INTO @sgt_nt, @sgtver_nt
WHILE @@SQLSTATUS = 0
BEGIN 
	SELECT @max_sgt_nt = MAX(SGT_NT)+1 FROM BEST..TSEGMENTATION

INSERT INTO BEST..TSEGMENTATION(SGT_NT, SGTVER_NT, SGTTYP_NT, SGT_LM, SGTVER_LL, PRDSIT_CF, SSD_CF, SGTSTS_CF, 
                                SGTGRAN_CT, BALAI_B, PRIORITY_B, LASTOPTION_B, MAXLVL_NB, RSPGRP_CF, RSPUSR_CF,
                                ESBSCOPE_CT, CTRTYP_CT, ALLCTRSTS_B, ALLCTRCAT_B, ALLSECSTS_B, ALLSECACCSTS_B, 
                                FULFREQ_CT, DLTFREQ_CT, SNPFREQ_CT, ACTIV_D, ARCHIV_D, CRE_D, CREUSR_CF, 
                                LSTUPD_D, LSTUPDUSR_CF)
                         SELECT @max_sgt_nt, 1, @max_sgttyp_nt, SGT_LM, SGTVER_LL, PRDSIT_CF, SSD_CF, '1',
                                SGTGRAN_CT, BALAI_B, PRIORITY_B, LASTOPTION_B, MAXLVL_NB, RSPGRP_CF, RSPUSR_CF, 
                                ESBSCOPE_CT, CTRTYP_CT, ALLCTRSTS_B, ALLCTRCAT_B, ALLSECSTS_B, ALLSECACCSTS_B,
                                FULFREQ_CT, DLTFREQ_CT, SNPFREQ_CT, ACTIV_D, NULL, getdate(), @p_usr_cf, 
                                getdate(), @p_usr_cf 
                           FROM BEST..TSEGMENTATION
                          WHERE SGTTYP_NT = @p_sgttyp_nt AND SGT_NT = @sgt_nt AND SGTVER_NT = @sgtver_nt
				
--------------------------------------------------------------------------------------------------------------------
INSERT INTO BEST..TSEG2ESB(SGT_NT, SGTVER_NT, SSD_CF, ESB_CF, CRE_D, CREUSR_CF)
                    SELECT @max_sgt_nt, 1, SSD_CF, ESB_CF, CRE_D, CREUSR_CF
			          FROM BEST..TSEG2ESB
			         WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt
			  
INSERT INTO BEST..TSEG2CTRSTS(SGT_NT, SGTVER_NT, CTRSTS_CF, CRE_D, CREUSR_CF)
                       SELECT @max_sgt_nt, 1, CTRSTS_CF, CRE_D, CREUSR_CF
			             FROM BEST..TSEG2CTRSTS
			            WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt
			  
INSERT INTO BEST..TSEG2CTRCAT(SGT_NT, SGTVER_NT, CTRCAT_CT, CRE_D, CREUSR_CF)
                       SELECT @max_sgt_nt, 1, CTRCAT_CT, CRE_D, CREUSR_CF
			             FROM BEST..TSEG2CTRCAT
			            WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt
			  
INSERT INTO BEST..TSEG2SECSTS(SGT_NT, SGTVER_NT, SECSTS_CF, CRE_D, CREUSR_CF)
                       SELECT @max_sgt_nt, 1, SECSTS_CF, CRE_D, CREUSR_CF
			             FROM BEST..TSEG2SECSTS
			            WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt
			  
INSERT INTO BEST..TSEG2SECACCSTS(SGT_NT, SGTVER_NT, SECACCSTS_CF, CRE_D, CREUSR_CF)
                          SELECT @max_sgt_nt, 1, SECACCSTS_CF, CRE_D, CREUSR_CF
			                FROM BEST..TSEG2SECACCSTS
			               WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt
			  
------------------------------------------------------------------------------------------------------------------	  
INSERT INTO BEST..TSEGMENTLVL(SGTLVL_CT, SGT_NT, SGTVER_NT,LVL_LS, LVL_LM, CRE_D, CREUSR_CF, 
                              LSTUPD_D, LSTUPDUSR_CF)
                       SELECT SGTLVL_CT, @max_sgt_nt, 1, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, 
				    	      LSTUPD_D, LSTUPDUSR_CF
			             FROM BEST..TSEGMENTLVL
			            WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt

--------------------------------------------------------------------------------------------------------------------
INSERT INTO BEST..TSEGMT(SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF,
						 BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF)
				  SELECT SGMT_NF, @max_sgt_nt, 1,
					CASE WHEN EXISTS (SELECT 1 FROM BRET..TRETCTR R WHERE R.RETCTR_NF = T.SGMT_LS 
										AND R.RTY_NF = @max_rty_nf AND R.RETCTRSTS_CT IN (1, 2, 3, 19)) 
										THEN T.SGMT_LS ELSE '' END,
						 SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
					FROM BEST..TSEGMT T
				   WHERE T.SGT_NT = @sgt_nt AND T.SGTVER_NT = @sgtver_nt

------------------------------------------------------------------------------------------------------------------				   
INSERT INTO BEST..TSEGMENTEXCEPT(SGTEXC_NT, SGT_NT, SGTVER_NT, SGMT_NF, SEGCTRTYP_CT, CTR_NF, UWY_NF, UW_NT, 
                                 SEC_NF, RTO_NF, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF)
				          SELECT SGTEXC_NT, @max_sgt_nt, 1, SGMT_NF, SEGCTRTYP_CT, CTR_NF, UWY_NF, UW_NT,
					             SEC_NF, RTO_NF, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
					        FROM BEST..TSEGMENTEXCEPT
						   WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt
------------------------------------------------------------------------------------------------------------------							
INSERT INTO BEST..TSEGMENTRULE(SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T,
                               CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF)
						SELECT SGTRUL_NT, SGMT_NF, @max_sgt_nt, 1, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T,
			                   CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
					      FROM BEST..TSEGMENTRULE
						 WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt
			 
------------------------------------------------------------------------------------------------------------------
INSERT INTO BEST..TSEGMENTRULE2TYPE(SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF)
                             SELECT SGTRUL_NT, SGMT_NF, @max_sgt_nt, 1, SGTTYP_NT, CRE_D, CREUSR_CF
							   FROM BEST..TSEGMENTRULE2TYPE
							  WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt

INSERT INTO BEST..TSEGMENTRULE2CRI(SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) 							 
                            SELECT SGTRULE_NT, SGMT_NF, @max_sgt_nt, 1, SGTCRI_CF, CRE_D, CREUSR_CF
							  FROM BEST..TSEGMENTRULE2CRI
							 WHERE SGT_NT=@sgt_nt AND SGTVER_NT = @sgtver_nt

	FETCH valid_Seg_Cursor INTO @sgt_nt, @sgtver_nt

IF @@ERROR <> 0 GOTO fin
	
END

CLOSE valid_Seg_Cursor
DEALLOCATE valid_Seg_Cursor

SELECT @p_new_sgttyp_nt = CONVERT(char,@max_sgttyp_nt)

IF @tran_imbr = 0
   COMMIT TRAN

RETURN 0

fin:
IF @tran_imbr = 0
   ROLLBACK TRAN
   

GO
IF OBJECT_ID('dbo.PiSGTRNW_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiSGTRNW_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiSGTRNW_01 >>>'
GRANT EXECUTE ON BEST.dbo.PiSGTRNW_01 TO GOMEGA
GO
