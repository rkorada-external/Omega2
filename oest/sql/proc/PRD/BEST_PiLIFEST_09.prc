USE BEST
go

CREATE TABLE #TLIFEST
(
   CTR_NF          UCTR_NF,
   END_NT          UEND_NT,
   SEC_NF          USEC_NF,
   UWY_NF          UUWY_NF,
   UW_NT           UUW_NT,
   CRE_D           UUPD_D,
   BALSHEY_NF      smallint,
   BALSHTMTH_NF    tinyint,
   ACY_NF          smallint,
   GAAP_NT         tinyint,
   DETTRNCOD_CF    char (5),
   ACM_NF          tinyint,
   PRS_CF          smallint NULL,
   ACMTRS_NT       smallint,
   SSD_CF          USSD_CF,
   CUR_CF          UCUR_CF,
   ESTMNT_M        UAMT_M NULL,
   INDSUP_B        bit,
   ORICOD_LS       UL16,
   CREUSR_CF       UUPDUSR_CF,
   LSTUPD_D        UUPD_D,
   LSTUPDUSR_CF    UUPDUSR_CF,
   ORICTR_NF       UCTR_NF NULL,
   ORISEC_NF       USEC_NF NULL,
   ORIUWY_NF       UUWY_NF NULL,
   DIFF_M          UAMT_M NULL,
   PROPAGATION_B   bit,
   CALCULATED_B    bit,
   BATCH_B         bit
)

CREATE TABLE #TLIFEST_CRED
(
   CTR_NF          UCTR_NF,
   END_NT          UEND_NT,
   SEC_NF          USEC_NF,
   UWY_NF          UUWY_NF,
   UW_NT           UUW_NT,
   CRE_D           UUPD_D,
   BALSHEY_NF      smallint,
   BALSHTMTH_NF    tinyint,
   ACY_NF          smallint,
   GAAP_NT         tinyint,
   DETTRNCOD_CF    char (5),
   ACM_NF          tinyint,
   PRS_CF          smallint NULL,
   ACMTRS_NT       smallint,
   SSD_CF          USSD_CF,
   CUR_CF          UCUR_CF,
   ESTMNT_M        UAMT_M NULL,
   INDSUP_B        bit,
   ORICOD_LS       UL16,
   CREUSR_CF       UUPDUSR_CF,
   LSTUPD_D        UUPD_D,
   LSTUPDUSR_CF    UUPDUSR_CF,
   ORICTR_NF       UCTR_NF NULL,
   ORISEC_NF       USEC_NF NULL,
   ORIUWY_NF       UUWY_NF NULL,
   DIFF_M          UAMT_M NULL,
   PROPAGATION_B   bit,
   CALCULATED_B    bit,
   BATCH_B         bit
)
go

IF OBJECT_ID ('dbo.PiLIFEST_09') IS NOT NULL
   BEGIN
      DROP PROCEDURE dbo.PiLIFEST_09

      IF OBJECT_ID ('dbo.PiLIFEST_09') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiLIFEST_09 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE dbo.PiLIFEST_09 >>>'
   END
go

/***** create procedure dbo.PiLIFEST_09 *****/


/*
*  Procedure creation
*/

CREATE PROCEDURE dbo.PiLIFEST_09 (
   @p_ctr_nf                 UCTR_NF,
   @p_usr_cf                 UUSR_CF,
   @p_ssd_cf    			 USSD_CF,
   @p_esb_cf 			     UESB_CF,
   @p_erreur                 CHAR (64) = NULL OUTPUT)
AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : P.-E. Marx
Creation date     : 20/11/2015
Description    	 : This procedure cleans the Estimates grid when user passes to Automatic Estimates type.

_________________
HISTORIQUE
  Auteur        Date         Description
  P. Marx		14/12/2015 - Added balance sheet date check (normalization as per spira #38928 for EST41/TRT106)
  P. Marx		04/01/2016 - EST30: changed the insertion balance sheet to reflect the current one


*****************************************************/

DECLARE
  @v_erreur     int,
  --@tran_imbr    int,
  --@v_rowcount   int
  @date         datetime,
  @oricodls     UL16,
  @ptprem       char (5),
  @nptprem      char (5),
  @erreur             Int,
  @TYPPER             Char(1),    -- type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)
  @BLCSHTYEA_NF       Smallint,
  @BLCSHTMTH_NF       Tinyint,
  @SPCEND_D           Datetime,
  @ACCOUNT_D          Datetime,   -- date de comptabilisation ( fin service )
  @CLOSING_B          Bit         -- top inventaire groupe

SELECT @date = getdate ()

SELECT @oricodls = 'EST41-RESET'

SELECT @ptprem = PCPTRS_CF+TRS_CF+SUBTRS_CF FROM BREF..TSUBTRSESBPROP WHERE SSD_CF = @p_ssd_cf AND ESB_CF = @p_esb_cf AND PREMIUMPNPEGPI_CT = 1

SELECT @nptprem = PCPTRS_CF+TRS_CF+SUBTRS_CF FROM BREF..TSUBTRSESBPROP WHERE SSD_CF = @p_ssd_cf AND ESB_CF = @p_esb_cf AND PREMIUMPNPEGPI_CT = 2

SELECT @TYPPER = 'E'
EXECUTE @erreur = BREF..PsCALEND_02 @date,@TYPPER,@BLCSHTYEA_NF output,@BLCSHTMTH_NF output,@SPCEND_D output,@ACCOUNT_D output,@CLOSING_B output

if @erreur != 0
begin
	Raiserror 20005 "APPLICATIF;TCALEND"
	return @erreur
end

/*select @v_erreur=0,@tran_imbr=1
if @@trancount=0
begin
 select @tran_imbr=0
 begin TRAN
end*/

-- Premiums T Codes are excluded

INSERT INTO #TLIFEST
  SELECT CTR_NF,
		 END_NT,
		 SEC_NF,
		 UWY_NF,
		 UW_NT,
		 CRE_D,
		 BALSHEY_NF,
		 BALSHTMTH_NF,
		 ACY_NF,
		 GAAP_NT,
		 DETTRNCOD_CF,
		 ACM_NF,
		 PRS_CF,
		 ACMTRS_NT,
		 SSD_CF,
		 CUR_CF,
		 ESTMNT_M,
		 INDSUP_B,
		 ORICOD_LS,
		 CREUSR_CF,
		 LSTUPD_D,
		 LSTUPDUSR_CF,
		 ORICTR_NF,
		 ORISEC_NF,
		 ORIUWY_NF,
		 DIFF_M,
		 PROPAGATION_B,
		 CALCULATED_B,
		 BATCH_B
	FROM BEST..TLIFEST
   WHERE CTR_NF = @p_ctr_nf
     AND DETTRNCOD_CF NOT IN (@ptprem, @nptprem)
	 AND BALSHEY_NF = @BLCSHTYEA_NF				-- [001] Only select current balance sheet year data
	 AND BALSHTMTH_NF <= @BLCSHTMTH_NF

-- All complete account years are excluded

INSERT INTO #TLIFEST_CRED
  SELECT t.CTR_NF,
		 t.END_NT,
		 t.SEC_NF,
		 t.UWY_NF,
		 t.UW_NT,
		 t.CRE_D,
		 t.BALSHEY_NF,
		 t.BALSHTMTH_NF,
		 t.ACY_NF,
		 t.GAAP_NT,
		 t.DETTRNCOD_CF,
		 t.ACM_NF,
		 t.PRS_CF,
		 t.ACMTRS_NT,
		 t.SSD_CF,
		 t.CUR_CF,
		 t.ESTMNT_M,
		 t.INDSUP_B,
		 t.ORICOD_LS,
		 t.CREUSR_CF,
		 t.LSTUPD_D,
		 t.LSTUPDUSR_CF,
		 t.ORICTR_NF,
		 t.ORISEC_NF,
		 t.ORIUWY_NF,
		 t.DIFF_M,
		 t.PROPAGATION_B,
		 t.CALCULATED_B,
		 t.BATCH_B
	FROM #TLIFEST t
   WHERE t.CRE_D =
				(SELECT MAX (CRE_D)
				   FROM #TLIFEST D
				  WHERE     D.DETTRNCOD_CF = t.DETTRNCOD_CF
						AND D.UWY_NF = t.UWY_NF
						AND D.acy_nf = t.acy_nf
						AND D.CTR_NF = t.CTR_NF
						AND D.END_NT = t.END_NT
						AND D.SEC_NF = t.SEC_NF
						AND D.UW_NT = t.UW_NT
						AND D.prs_cf = t.prs_cf
						AND D.gaap_nt = t.gaap_nt)
	 AND NOT EXISTS(SELECT 1
				      FROM BEST..TLIFDRI dri
			         WHERE dri.CTR_NF   = t.CTR_NF
				       AND dri.SEC_NF   = t.SEC_NF
					   AND dri.ACY_NF   = t.ACY_NF
					   AND dri.COMACC_B = 1)

-- Releases are ignored on the first non complete accounting year

DELETE #TLIFEST_CRED
  FROM #TLIFEST_CRED c
 WHERE EXISTS(SELECT 1
				FROM BREF..TSUBTRSASSO a
			   WHERE a.DETTRNCOD2_CF = c.DETTRNCOD_CF
			     AND a.ASSOTYP_CT    = '1')
   AND EXISTS(SELECT 1
				  FROM BEST..TLIFDRI dri
				 WHERE dri.CTR_NF   = c.CTR_NF
				   AND dri.SEC_NF   = c.SEC_NF
				   AND dri.ACY_NF   = c.ACY_NF - 1
				   AND dri.COMACC_B = 1)

UPDATE #TLIFEST_CRED
   SET ESTMNT_M 	= 0,
	   DIFF_M 		= 0,
	   CRE_D 		= @date, 
	   LSTUPD_D 	= @date, 
	   CREUSR_CF 	= @p_usr_cf,
	   LSTUPDUSR_CF = @p_usr_cf,
	   ORICOD_LS 	= @oricodls,
	   BATCH_B 		= 0,
	   BALSHEY_NF	= @BLCSHTYEA_NF,	-- EST30: use current balance sheet when inserting
	   BALSHTMTH_NF	= @BLCSHTMTH_NF		-- EST30: use current balance sheet when inserting

INSERT INTO BEST..TLIFEST
  SELECT CTR_NF,
		 END_NT,
		 SEC_NF,
		 UWY_NF,
		 UW_NT,
		 CRE_D,
		 BALSHEY_NF,
		 BALSHTMTH_NF,
		 ACY_NF,
		 GAAP_NT,
		 DETTRNCOD_CF,
		 ACM_NF,
		 PRS_CF,
		 ACMTRS_NT,
		 SSD_CF,
		 CUR_CF,
		 ESTMNT_M,
		 INDSUP_B,
		 ORICOD_LS,
		 CREUSR_CF,
		 LSTUPD_D,
		 LSTUPDUSR_CF,
		 ORICTR_NF,
		 ORISEC_NF,
		 ORIUWY_NF,
		 DIFF_M,
		 PROPAGATION_B,
		 CALCULATED_B,
		 BATCH_B
	FROM #TLIFEST_CRED

SELECT @v_erreur = @@error

IF @v_erreur != 0
  BEGIN
	 SELECT @p_ERREUR =
				 "20004 APPLICATIF;TLIFEST, INSERT"
			   + convert (VARCHAR (10), @v_erreur)
			   + ";"                          /* erreur de modification */
	 GOTO fin
  END

DELETE #TLIFEST

DELETE #TLIFEST_CRED

--if @tran_imbr = 0 commit tran
RETURN 0

fin:
--if @tran_imbr=0 rollback tran
RETURN @v_erreur
go
EXEC sp_procxmode 'dbo.PiLIFEST_09', 'unchained'
go

IF OBJECT_ID ('dbo.PiLIFEST_09') IS NOT NULL
   PRINT '<<< CREATED PROCEDURE dbo.PiLIFEST_09 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROCEDURE dbo.PiLIFEST_09 >>>'
go

GRANT EXECUTE ON dbo.PiLIFEST_09 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiLIFEST_09 TO GDBBATCH
go
