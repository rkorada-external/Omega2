USE BEST
GO

SETUSER 'dbo'
GO
IF object_id('BEST.dbo.PiSGTCPY_01') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.PiSGTCPY_01
	 IF OBJECT_ID('dbo.PiSGTCPY_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiSGTCPY_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiSGTCPY_01 >>>'
END
GO

SETUSER 'dbo'
GO



create proc PiSGTCPY_01
(
@p_sgt_nt int,
@p_sgtver_nt int,
@p_usr_cf UUPDUSR_CF,
@p_new_sgt_nt varchar(64)=NULL output
)
as

/*****************************************************
_________________
MODIFICATION 1
Auteur: rgandhe
Date: 05/12/2013
Description: 1) TIMESTAMP Removed.

_________________
MODIFICATION 2
Auteur: rgandhe
Date: 18/12/2013
Description: 1) CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF remain unchanged.
_________________
MODIFICATION 3
Auteur: rgandhe
Date: 04/03/2014
Description: 1) THE NEW SEGMENTATION CREATED SHOULD BE IN "DRAFT" STATUS.

*****************************************************/

declare @max_sgt_nt int
declare @tran_imbr int

select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

select @max_sgt_nt=MAX(sgt_nt)+1 from best..tsegmentation

INSERT INTO BEST..TSEGMENTATION(SGT_NT, SGTVER_NT, SGTTYP_NT, SGT_LM, SGTVER_LL, PRDSIT_CF, SSD_CF, SGTSTS_CF, 
                                SGTGRAN_CT, BALAI_B, PRIORITY_B, LASTOPTION_B, MAXLVL_NB, RSPGRP_CF, RSPUSR_CF,
                                ESBSCOPE_CT, CTRTYP_CT, ALLCTRSTS_B, ALLCTRCAT_B, ALLSECSTS_B, ALLSECACCSTS_B, 
                                FULFREQ_CT, DLTFREQ_CT, SNPFREQ_CT, ACTIV_D, ARCHIV_D, CRE_D, CREUSR_CF, 
                                LSTUPD_D, LSTUPDUSR_CF)
                         SELECT @max_sgt_nt, 1, SGTTYP_NT, SGT_LM, SGTVER_LL, PRDSIT_CF, SSD_CF, '1',
                                SGTGRAN_CT, BALAI_B, PRIORITY_B, LASTOPTION_B, MAXLVL_NB, RSPGRP_CF, RSPUSR_CF, 
                                ESBSCOPE_CT, CTRTYP_CT, ALLCTRSTS_B, ALLCTRCAT_B, ALLSECSTS_B, ALLSECACCSTS_B,
                                FULFREQ_CT, DLTFREQ_CT, SNPFREQ_CT, ACTIV_D, ARCHIV_D, CRE_D, CREUSR_CF, 
                                LSTUPD_D, LSTUPDUSR_CF 
                           FROM BEST..TSEGMENTATION
                          WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT=@p_sgtver_nt
					
------------------------------------------------------------------------------------------------------------------
INSERT INTO BEST..TSEG2ESB(SGT_NT, SGTVER_NT, SSD_CF, ESB_CF, CRE_D, CREUSR_CF)
                    SELECT @max_sgt_nt, 1, SSD_CF, ESB_CF, CRE_D, CREUSR_CF
			          FROM BEST..TSEG2ESB
			         WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt
			  
INSERT INTO BEST..TSEG2CTRSTS(SGT_NT, SGTVER_NT, CTRSTS_CF, CRE_D, CREUSR_CF)
                       SELECT @max_sgt_nt, 1, CTRSTS_CF, CRE_D, CREUSR_CF
			             FROM BEST..TSEG2CTRSTS
			            WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt
			  
INSERT INTO BEST..TSEG2CTRCAT(SGT_NT, SGTVER_NT, CTRCAT_CT, CRE_D, CREUSR_CF)
                       SELECT @max_sgt_nt, 1, CTRCAT_CT, CRE_D, CREUSR_CF
			             FROM BEST..TSEG2CTRCAT
			            WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt
			  
INSERT INTO BEST..TSEG2SECSTS(SGT_NT, SGTVER_NT, SECSTS_CF, CRE_D, CREUSR_CF)
                       SELECT @max_sgt_nt, 1, SECSTS_CF, CRE_D, CREUSR_CF
			             FROM BEST..TSEG2SECSTS
			            WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt
			  
INSERT INTO BEST..TSEG2SECACCSTS(SGT_NT, SGTVER_NT, SECACCSTS_CF, CRE_D, CREUSR_CF)
                          SELECT @max_sgt_nt, 1, SECACCSTS_CF, CRE_D, CREUSR_CF
			                FROM BEST..TSEG2SECACCSTS
			               WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt
			  
------------------------------------------------------------------------------------------------------------------	  
INSERT INTO BEST..TSEGMENTLVL(SGTLVL_CT, SGT_NT, SGTVER_NT,LVL_LS, LVL_LM, CRE_D, CREUSR_CF, 
                              LSTUPD_D, LSTUPDUSR_CF)
                       SELECT SGTLVL_CT, @max_sgt_nt, 1, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, 
				    	      LSTUPD_D, LSTUPDUSR_CF
			             FROM BEST..TSEGMENTLVL
			            WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt

------------------------------------------------------------------------------------------------------------------
INSERT INTO BEST..TSEGMT(SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT,
                         CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF)
				  SELECT SGMT_NF, @max_sgt_nt, 1, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT,
				         CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
				    FROM BEST..TSEGMT
				   WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt
------------------------------------------------------------------------------------------------------------------				   
INSERT INTO BEST..TSEGMENTEXCEPT(SGTEXC_NT, SGT_NT, SGTVER_NT, SGMT_NF, SEGCTRTYP_CT, CTR_NF, UWY_NF, UW_NT, 
                                 SEC_NF, RTO_NF, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF)
				          SELECT SGTEXC_NT, @max_sgt_nt, 1, SGMT_NF, SEGCTRTYP_CT, CTR_NF, UWY_NF, UW_NT,
					             SEC_NF, RTO_NF, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
					        FROM BEST..TSEGMENTEXCEPT
						   WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt
------------------------------------------------------------------------------------------------------------------						   
						   
INSERT INTO BEST..TSEGMENTRULE(SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T,
                               CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF)
						SELECT SGTRUL_NT, SGMT_NF, @max_sgt_nt, 1, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T,
			                   CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
					      FROM BEST..TSEGMENTRULE
						 WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt
			 
------------------------------------------------------------------------------------------------------------------
INSERT INTO BEST..TSEGMENTRULE2TYPE(SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF)
                             SELECT SGTRUL_NT, SGMT_NF, @max_sgt_nt, 1, SGTTYP_NT, CRE_D, CREUSR_CF
							   FROM BEST..TSEGMENTRULE2TYPE
							  WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt

INSERT INTO BEST..TSEGMENTRULE2CRI(SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) 							 
                            SELECT SGTRULE_NT, SGMT_NF, @max_sgt_nt, 1, SGTCRI_CF, CRE_D, CREUSR_CF
							  FROM BEST..TSEGMENTRULE2CRI
							 WHERE SGT_NT=@p_sgt_nt AND SGTVER_NT = @p_sgtver_nt

------------------------------------------------------------------------------------------------------------------
SELECT @p_new_sgt_nt = convert(char,@max_sgt_nt)

if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN
   




GO
IF OBJECT_ID('dbo.PiSGTCPY_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiSGTCPY_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiSGTCPY_01 >>>'
Grant Execute on BEST.dbo.PiSGTCPY_01 to GOMEGA
GO

SETUSER
GO