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

CREATE TABLE #TLIFEST_ACMTRS
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

IF OBJECT_ID ('dbo.PiLIFEST_07') IS NOT NULL
   BEGIN
      DROP PROCEDURE dbo.PiLIFEST_07

      IF OBJECT_ID ('dbo.PiLIFEST_07') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiLIFEST_07 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE dbo.PiLIFEST_07 >>>'
   END
go

/***** create procedure dbo.PiLIFEST_07 *****/


/*
*  Procedure creation
*/

CREATE PROCEDURE dbo.PiLIFEST_07 (
   @p_ctr_nf                 UCTR_NF,
   @p_uwy_nf                 UUWY_NF,
   @p_secsts_ct_before       UCTRSTS_CT,
   @p_secsts_ct_after        UCTRSTS_CT,
   @p_usr_cf                 UUSR_CF,
   @p_erreur                 CHAR (64) = NULL OUTPUT)
AS
   /***************************************************
   Domain            : Estimate
   Base              : BEST
   Version           : 1
   Author            : P.-E. Marx
   Creation date     : 10/06/2015
   Description    : This procedure changes the accounting type of life treaty/section and cleans the corresponding grids
   This procedure is used when user does a status change at treaty level (as compared to PiLIFEST_06 which is called for treaty/section level).

   _________________
   HISTORIQUE
   Modif   Auteur        Date         Description
   1       A.Deshpande   25/06/2015 - Removed checks for Type2 and Type 3 # 37388, 37390
   2       P.Marx     	 01/07/2015 - fix for defect 37067
   3       A.Deshpande   24/07/2015 - fix for defect 38188, 38627, 38629 and 38644
   4       A.Deshpande   18/08/2015 - Added ACMTRS_NT - 1304, 1324, 1340 and 1011 for accounting type 3 to 5 and 5 to 3 for spira #038548
   5       A.Deshpande   03/09/2015 - Fixed added for Spira # 39961
   6       P. Marx	 14/12/2015 - Added balance sheet date check (normalization as per spira #38928 for EST41/TRT106)
   7       P. Marx	 04/01/2016 - EST30: changed the insertion balance sheet to reflect the current one 
   *****************************************************/

   DECLARE
      @v_erreur     int,
      --@tran_imbr    int,
      --@v_rowcount   int
      @p_date       datetime,
      @p_oricodls   UL16,
	  @erreur             Int,
	  @TYPPER             Char(1),    -- type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)
	  @BLCSHTYEA_NF       Smallint,
	  @BLCSHTMTH_NF       Tinyint,
	  @SPCEND_D           Datetime,
	  @ACCOUNT_D          Datetime,   -- date de comptabilisation ( fin service )
	  @CLOSING_B          Bit         -- top inventaire groupe


   SELECT @p_date = getdate ()

   SELECT @p_oricodls = 'TRT106'
   
	SELECT @TYPPER = 'E'
	EXECUTE @erreur = BREF..PsCALEND_02 @p_date,@TYPPER,@BLCSHTYEA_NF output,@BLCSHTMTH_NF output,@SPCEND_D output,@ACCOUNT_D output,@CLOSING_B output

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
       WHERE CTR_NF = @p_ctr_nf AND UWY_NF >= @p_uwy_nf
			 AND BALSHEY_NF = @BLCSHTYEA_NF				-- [006] Only select current balance sheet year data
			 AND BALSHTMTH_NF <= @BLCSHTMTH_NF

   --and ESTMNT_M != 0


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
       WHERE     t.ESTMNT_M != 0
             AND t.CRE_D =
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


   IF @p_secsts_ct_before = 19 AND @p_secsts_ct_after = 16
      BEGIN
         INSERT INTO #TLIFEST_ACMTRS
            SELECT c.CTR_NF,
                   c.END_NT,
                   c.SEC_NF,
                   c.UWY_NF,
                   c.UW_NT,
                   c.CRE_D,
                   c.BALSHEY_NF,
                   c.BALSHTMTH_NF,
                   c.ACY_NF,
                   c.GAAP_NT,
                   c.DETTRNCOD_CF,
                   c.ACM_NF,
                   c.PRS_CF,
                   c.ACMTRS_NT,
                   c.SSD_CF,
                   c.CUR_CF,
                   c.ESTMNT_M,
                   c.INDSUP_B,
                   c.ORICOD_LS,
                   c.CREUSR_CF,
                   c.LSTUPD_D,
                   c.LSTUPDUSR_CF,
                   c.ORICTR_NF,
                   c.ORISEC_NF,
                   c.ORIUWY_NF,
                   c.DIFF_M,
                   c.PROPAGATION_B,
                   c.CALCULATED_B,
                   c.BATCH_B
              FROM #TLIFEST_CRED c,
                   BTRT..TSECTION s,
                   BREF..TSUBTRSBLOCKLIFEST t                -- Fix for #38548
             WHERE     s.CTR_NF = c.CTR_NF
                   AND s.SEC_NF = c.SEC_NF
                   AND s.UWY_NF = @p_uwy_nf
                   AND s.ACCADMTYP_CT = 1
                   AND c.DETTRNCOD_CF = t.PCPTRS_CF + t.TRS_CF + t.SUBTRS_CF -- Fix for #38548
                   AND (   (    c.ACY_NF = @p_uwy_nf + 1
                            AND c.ACMTRS_NT IN (1014,
                                                1064,
                                                1094,
                                                1074,
                                                1084,
                                                1144,
                                                1164,
                                                1184,
                                                1194,
                                                1244,
                                                1264,
                                                1504,
                                                1524,
                                                1534,
                                                1604,
                                                1624,
                                                1634,
                                                1340))       -- Fix for #38548
                        OR (    c.ACY_NF > @p_uwy_nf
                            AND (t.BLOCK_NF = 1 OR t.BLOCK_NF = 2)
                            AND c.ACMTRS_NT != 1160))        -- Fix for #38548

         INSERT INTO #TLIFEST_ACMTRS
            SELECT c.CTR_NF,
                   c.END_NT,
                   c.SEC_NF,
                   c.UWY_NF,
                   c.UW_NT,
                   c.CRE_D,
                   c.BALSHEY_NF,
                   c.BALSHTMTH_NF,
                   c.ACY_NF,
                   c.GAAP_NT,
                   c.DETTRNCOD_CF,
                   c.ACM_NF,
                   c.PRS_CF,
                   c.ACMTRS_NT,
                   c.SSD_CF,
                   c.CUR_CF,
                   c.ESTMNT_M,
                   c.INDSUP_B,
                   c.ORICOD_LS,
                   c.CREUSR_CF,
                   c.LSTUPD_D,
                   c.LSTUPDUSR_CF,
                   c.ORICTR_NF,
                   c.ORISEC_NF,
                   c.ORIUWY_NF,
                   c.DIFF_M,
                   c.PROPAGATION_B,
                   c.CALCULATED_B,
                   c.BATCH_B
              FROM #TLIFEST_CRED c,
                   BTRT..TSECTION s,
                   BREF..TSUBTRSBLOCKLIFEST t                -- Fix for #38548
             WHERE     s.CTR_NF = c.CTR_NF
                   AND s.SEC_NF = c.SEC_NF
                   AND s.UWY_NF = @p_uwy_nf
                   AND s.ACCADMTYP_CT = 3
                   AND c.DETTRNCOD_CF = t.PCPTRS_CF + t.TRS_CF + t.SUBTRS_CF -- Fix for #38548
                   AND (   (    c.ACY_NF = @p_uwy_nf + 1
                            AND c.ACMTRS_NT IN (1014,
                                                1064,
                                                1094,
                                                1074,
                                                1084,
                                                1144,
                                                1164,
                                                1184,
                                                1194,
                                                1504,
                                                1524,
                                                1534,
                                                1604,
                                                1624,
                                                1634))       -- Fix for #38548
                        OR (    c.ACY_NF > @p_uwy_nf
                            AND (t.BLOCK_NF = 1 OR t.BLOCK_NF = 2)
                            AND c.ACMTRS_NT != 1160))        -- Fix for #38548
      END

   IF @p_secsts_ct_after = 19
      BEGIN
         INSERT INTO #TLIFEST_ACMTRS
            SELECT c.CTR_NF,
                   c.END_NT,
                   c.SEC_NF,
                   c.UWY_NF,
                   c.UW_NT,
                   c.CRE_D,
                   c.BALSHEY_NF,
                   c.BALSHTMTH_NF,
                   c.ACY_NF,
                   c.GAAP_NT,
                   c.DETTRNCOD_CF,
                   c.ACM_NF,
                   c.PRS_CF,
                   c.ACMTRS_NT,
                   c.SSD_CF,
                   c.CUR_CF,
                   c.ESTMNT_M,
                   c.INDSUP_B,
                   c.ORICOD_LS,
                   c.CREUSR_CF,
                   c.LSTUPD_D,
                   c.LSTUPDUSR_CF,
                   c.ORICTR_NF,
                   c.ORISEC_NF,
                   c.ORIUWY_NF,
                   c.DIFF_M,
                   c.PROPAGATION_B,
                   c.CALCULATED_B,
                   c.BATCH_B
              FROM #TLIFEST_CRED c, BTRT..TSECTION s
             WHERE     c.ACMTRS_NT IN (1014,
                                       1064,
                                       1094,
                                       1074,
                                       1084,
                                       1144,
                                       1164,
                                       1184,
                                       1194,
                                       1244,
                                       1264,
                                       1504,
                                       1524,
                                       1534,
                                       1604,
                                       1624,
                                       1634,
                                       1340)
                   AND c.UWY_NF = @p_uwy_nf + 1
                   AND s.CTR_NF = c.CTR_NF
                   AND s.SEC_NF = c.SEC_NF
                   AND s.UWY_NF = @p_uwy_nf
                   AND s.ACCADMTYP_CT = 4


         INSERT INTO #TLIFEST_ACMTRS
            SELECT c.CTR_NF,
                   c.END_NT,
                   c.SEC_NF,
                   c.UWY_NF,
                   c.UW_NT,
                   c.CRE_D,
                   c.BALSHEY_NF,
                   c.BALSHTMTH_NF,
                   c.ACY_NF,
                   c.GAAP_NT,
                   c.DETTRNCOD_CF,
                   c.ACM_NF,
                   c.PRS_CF,
                   c.ACMTRS_NT,
                   c.SSD_CF,
                   c.CUR_CF,
                   c.ESTMNT_M,
                   c.INDSUP_B,
                   c.ORICOD_LS,
                   c.CREUSR_CF,
                   c.LSTUPD_D,
                   c.LSTUPDUSR_CF,
                   c.ORICTR_NF,
                   c.ORISEC_NF,
                   c.ORIUWY_NF,
                   c.DIFF_M,
                   c.PROPAGATION_B,
                   c.CALCULATED_B,
                   c.BATCH_B
              FROM #TLIFEST_CRED c, BTRT..TSECTION s
             WHERE     c.ACMTRS_NT IN (1014,
                                       1064,
                                       1094,
                                       1074,
                                       1084,
                                       1144,
                                       1164,
                                       1184,
                                       1194,
                                       1504,
                                       1524,
                                       1534,
                                       1604,
                                       1624,
                                       1634)
                   AND c.UWY_NF = @p_uwy_nf + 1
                   AND s.CTR_NF = c.CTR_NF
                   AND s.SEC_NF = c.SEC_NF
                   AND s.UWY_NF = @p_uwy_nf
                   AND s.ACCADMTYP_CT = 5

         DELETE #TLIFEST_CRED
           FROM #TLIFEST_CRED c, BTRT..TSECTION s
          WHERE     s.CTR_NF = c.CTR_NF
                AND s.SEC_NF = c.SEC_NF
                AND s.UWY_NF = @p_uwy_nf
                AND (s.ACCADMTYP_CT = 1 OR s.ACCADMTYP_CT = 3)
      END



   -- Now that values have been retrieved,
   DELETE #TLIFEST_CRED
    WHERE UWY_NF = @p_uwy_nf

   --2.If "Section Status Before" is Treaty or Section Status Enum.CANCELED AND ("Section Status After" is Treaty or Section Status Enum.FINALIZED)
   IF @p_secsts_ct_before = 19 AND @p_secsts_ct_after = 16
      BEGIN
         -- Passing to finalized => all sections will be passed to finalized or equivalent
         DELETE #TLIFEST_CRED

         INSERT INTO #TLIFEST_CRED
            SELECT a.CTR_NF,
                   a.END_NT,
                   a.SEC_NF,
                   a.UWY_NF,
                   a.UW_NT,
                   @p_date,
                   a.BALSHEY_NF,
                   a.BALSHTMTH_NF,
                   a.ACY_NF,
                   a.GAAP_NT,
                   a.DETTRNCOD_CF,
                   a.ACM_NF,
                   a.PRS_CF,
                   a.ACMTRS_NT,
                   a.SSD_CF,
                   a.CUR_CF,
                   0,
                   a.INDSUP_B,
                   a.ORICOD_LS,
                   a.CREUSR_CF,
                   a.LSTUPD_D,
                   a.LSTUPDUSR_CF,
                   a.ORICTR_NF,
                   a.ORISEC_NF,
                   a.ORIUWY_NF,
                   0,
                   a.PROPAGATION_B,
                   a.CALCULATED_B,
                   a.BATCH_B
              FROM #TLIFEST_ACMTRS a

         DELETE #TLIFEST_ACMTRS
           FROM #TLIFEST_ACMTRS a, BTRT..TSECTION s
          WHERE     a.CTR_NF = s.CTR_NF
                AND a.SEC_NF = s.SEC_NF
                AND s.UWY_NF = @p_uwy_nf
                AND (   (a.ACY_NF != @p_uwy_nf + 1)
                     OR (a.UWY_NF != @p_uwy_nf)
                     OR (    a.ACMTRS_NT NOT IN (1014,
                                                 1064,
                                                 1094,
                                                 1074,
                                                 1084,
                                                 1144,
                                                 1164,
                                                 1184,
                                                 1194,
                                                 1504,
                                                 1524,
                                                 1534,
                                                 1604,
                                                 1624,
                                                 1634)
                         AND s.ACCADMTYP_CT = 3)
                     OR (    a.ACMTRS_NT NOT IN (1014,
                                                 1064,
                                                 1094,
                                                 1074,
                                                 1084,
                                                 1144,
                                                 1164,
                                                 1184,
                                                 1194,
                                                 1244,
                                                 1264,
                                                 1504,
                                                 1524,
                                                 1534,
                                                 1604,
                                                 1624,
                                                 1634,
                                                 1340)
                         AND s.ACCADMTYP_CT = 1))

         -- Fix for #38548
         UPDATE #TLIFEST_ACMTRS
            SET a.UWY_NF = a.UWY_NF + 1 -- Brings back the selected releases from cancelled UWY to the next one
           FROM #TLIFEST_ACMTRS a, BTRT..TSECTION s
          WHERE     a.UWY_NF = @p_uwy_nf
                AND (   (    (    a.ACY_NF = @p_uwy_nf + 1
                              AND a.ACMTRS_NT IN (1014,
                                                  1064,
                                                  1094,
                                                  1074,
                                                  1084,
                                                  1144,
                                                  1164,
                                                  1184,
                                                  1194,
                                                  1504,
                                                  1524,
                                                  1534,
                                                  1604,
                                                  1624,
                                                  1634))
                         AND s.ACCADMTYP_CT = 3)
                     OR (    (    a.ACY_NF = @p_uwy_nf + 1
                              AND a.ACMTRS_NT IN (1014,
                                                  1064,
                                                  1094,
                                                  1074,
                                                  1084,
                                                  1144,
                                                  1164,
                                                  1184,
                                                  1194,
                                                  1244,
                                                  1264,
                                                  1504,
                                                  1524,
                                                  1534,
                                                  1604,
                                                  1624,
                                                  1634,
                                                  1340))
                         AND s.ACCADMTYP_CT = 1))
                AND s.CTR_NF = a.CTR_NF
                AND s.SEC_NF = a.SEC_NF
                AND s.UWY_NF = @p_uwy_nf

         SELECT @p_date = getdate ()

         UPDATE #TLIFEST_ACMTRS
            SET CRE_D = @p_date

         INSERT INTO #TLIFEST_ACMTRS
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
                   0,
                   INDSUP_B,
                   ORICOD_LS,
                   CREUSR_CF,
                   LSTUPD_D,
                   LSTUPDUSR_CF,
                   ORICTR_NF,
                   ORISEC_NF,
                   ORIUWY_NF,
                   0,
                   PROPAGATION_B,
                   CALCULATED_B,
                   BATCH_B
              FROM #TLIFEST_CRED
      END


   --3.If "Section Status After" is Treaty or Section Status Enum.CANCELED
   IF @p_secsts_ct_after = 19
      BEGIN
         UPDATE #TLIFEST_ACMTRS
            SET UWY_NF = UWY_NF - 1 -- Passes releases to previous UWYs. Only acc. type 4 or 5 will have filled this table anyway

         UPDATE #TLIFEST_CRED
            SET ESTMNT_M = 0, DIFF_M = 0           -- resetting for future UWY

         SELECT @p_date = getdate ()

         INSERT INTO BEST..TLIFEST
            SELECT CTR_NF,
                   END_NT,
                   SEC_NF,
                   UWY_NF,
                   UW_NT,
                   @p_date,
                   @BLCSHTYEA_NF,	-- [007] EST30: Use current balance sheet for insertion
                   @BLCSHTMTH_NF,	-- [007] EST30: Use current balance sheet for insertion
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
                   @p_oricodls,
                   @p_usr_cf,
                   @p_date,
                   @p_usr_cf,
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
                         + ";"                    /* erreur de modification */
               GOTO fin
            END

         SELECT @p_date = getdate ()

         UPDATE #TLIFEST_ACMTRS
            SET CRE_D = @p_date
      END



   INSERT INTO BEST..TLIFEST
      SELECT CTR_NF,
             END_NT,
             SEC_NF,
             UWY_NF,
             UW_NT,
             CRE_D,
             @BLCSHTYEA_NF,	-- [007] EST30: Use current balance sheet for insertion
             @BLCSHTMTH_NF,	-- [007] EST30: Use current balance sheet for insertion
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
             @p_oricodls,
             @p_usr_cf,
             @p_date,
             @p_usr_cf,
             ORICTR_NF,
             ORISEC_NF,
             ORIUWY_NF,
             DIFF_M,
             PROPAGATION_B,
             CALCULATED_B,
             BATCH_B
        FROM #TLIFEST_ACMTRS

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

   DELETE #TLIFEST_ACMTRS

   --if @tran_imbr = 0 commit tran
   RETURN 0

  fin:
   --if @tran_imbr=0 rollback tran
   RETURN @v_erreur
go
EXEC sp_procxmode 'dbo.PiLIFEST_07', 'unchained'
go

IF OBJECT_ID ('dbo.PiLIFEST_07') IS NOT NULL
   PRINT '<<< CREATED PROCEDURE dbo.PiLIFEST_07 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROCEDURE dbo.PiLIFEST_07 >>>'
go

GRANT EXECUTE ON dbo.PiLIFEST_07 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiLIFEST_07 TO GDBBATCH
go
