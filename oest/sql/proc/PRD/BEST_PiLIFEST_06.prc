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

IF OBJECT_ID ('dbo.PiLIFEST_06') IS NOT NULL
   BEGIN
      DROP PROCEDURE dbo.PiLIFEST_06

      IF OBJECT_ID ('dbo.PiLIFEST_06') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiLIFEST_06 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE dbo.PiLIFEST_06 >>>'
   END
go

/*
*  Procedure creation
*/

CREATE PROCEDURE dbo.PiLIFEST_06 (
   @p_lob                       ULOB_CF,
   @p_ctr_nf                    UCTR_NF,
   @p_sec_nf                    USEC_NF,
   @p_uwy_nf                    UUWY_NF,
   @p_secsts_ct_before          UCTRSTS_CT,
   @p_secsts_ct_after           UCTRSTS_CT,
   @p_accadmtyp_ct_before       UACCADMTYP_CT,
   @p_accadmtyp_ct_after        UACCADMTYP_CT,
   @p_usr_cf                    UUSR_CF,
   @p_erreur                    CHAR (64) = NULL OUTPUT)
AS
   /***************************************************
   Domain            : Estimate
   Base              : BEST
   Version           : 1
   Author            : A. Deshpande
   Creation date     : 21/04/2015
   Description       : This procedure changes the accounting type of life treaty/section and clean the corresponding grids

   Domain            : Estimate
   Base              : BEST
   Version           : 2
   Author            : P. Marx
   Creation date     : 01/07/2015
   Description       : fix for defect 37067

   Domain            : Estimate
   Base              : BEST
   Version           : 3
   Author            : A.Deshpande
   Creation date     : 24/07/2015
   Description       : fix for defect 38188, 38627, 38629 and 38644


   Domain            : Estimate
   Base              : BEST
   Version           : 4
   Author            : A.Deshpande
   Creation date     : 18/08/2015
   Description       : Added ACMTRS_NT - 1304, 1324, 1340 and 1011 for accounting type 3 to 5 and 5 to 3 for spira #038548

   Domain            : Estimate
   Base              : BEST
   Version           : 5
   Author            : A.Deshpande
   Creation date     : 03/09/2015
   Description       : Fixed added for spira #39961

   Domain            : Estimate
   Base              : BEST
   Version           : 6
   Author            : P. Marx
   Creation date     : 25/09/2015
   Description       : Fixed added for spira #38548
   
   Domain            : Estimate
   Base              : BEST
   Version           : 7
   Author            : P. Marx
   Creation date     : 14/12/2015
   Description       : Added balance sheet date check (normalization as per spira #38928 for EST41/TRT106)

   Domain            : Estimate
   Base              : BEST
   Version           : 8
   Author            : P. Marx
   Creation date     : 04/01/2016
   Description       : EST30: changed the insertion balance sheet to reflect the current one
   
   Domain            : Estimate
   Base              : BEST
   Version           : 8
   Author            : Riyadh
   Creation date     : 20/02/2017
   Description       : Change for defect 55557 - 1304,1324,2304 and 2324 added for T4 to T1 conversion

   *****************************************************/

   DECLARE
	@v_erreur     int,
	@p_date       datetime,
	@p_oricodls   UL16,
   --@tran_imbr    int,
   --@v_rowcount   int
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
       WHERE     CTR_NF = @p_ctr_nf
             AND SEC_NF = @p_sec_nf
             AND UWY_NF >= @p_uwy_nf
			 AND BALSHEY_NF = @BLCSHTYEA_NF				-- [007] Only select current balance sheet year data
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



   IF (@p_accadmtyp_ct_before = 4 AND @p_accadmtyp_ct_after = 1)
      BEGIN
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
                   ESTMNT_M,
                   INDSUP_B,
                   ORICOD_LS,
                   CREUSR_CF,
                   c.LSTUPD_D,
                   c.LSTUPDUSR_CF,
                   ORICTR_NF,
                   ORISEC_NF,
                   ORIUWY_NF,
                   DIFF_M,
                   PROPAGATION_B,
                   CALCULATED_B,
                   BATCH_B
              FROM #TLIFEST_CRED c, BREF..TSUBTRSBLOCKLIFEST t -- Fix for #38548
             WHERE     c.DETTRNCOD_CF = t.PCPTRS_CF + t.TRS_CF + t.SUBTRS_CF
                   AND (   (    c.ACMTRS_NT IN (1014,
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
                                                1340,
                                                1304, --modif 08
                                                1324, --modif 08
                                                2304, --modif 08
                                                2324) --modif 08
                            AND c.ACY_NF = @p_uwy_nf + 1)
                        OR (    c.ACY_NF > @p_uwy_nf
                            AND (t.BLOCK_NF = 1 OR t.BLOCK_NF = 2)
                            AND c.ACMTRS_NT != 1160))
      END

   IF (@p_accadmtyp_ct_before = 1 AND @p_accadmtyp_ct_after = 4)
      BEGIN
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
             WHERE     ACMTRS_NT IN (1014,
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
                   AND UWY_NF = @p_uwy_nf + 1
      END

   IF (@p_accadmtyp_ct_before = 3 AND @p_accadmtyp_ct_after = 5)
      BEGIN
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
             WHERE     ACMTRS_NT IN (1014,
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
                   AND UWY_NF = @p_uwy_nf + 1
      END

   IF (@p_accadmtyp_ct_before = 5 AND @p_accadmtyp_ct_after = 3)
      BEGIN
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
                   ESTMNT_M,
                   INDSUP_B,
                   ORICOD_LS,
                   CREUSR_CF,
                   c.LSTUPD_D,
                   c.LSTUPDUSR_CF,
                   ORICTR_NF,
                   ORISEC_NF,
                   ORIUWY_NF,
                   DIFF_M,
                   PROPAGATION_B,
                   CALCULATED_B,
                   BATCH_B
              FROM #TLIFEST_CRED c, BREF..TSUBTRSBLOCKLIFEST t -- Fix for #38548
             WHERE     c.DETTRNCOD_CF = t.PCPTRS_CF + t.TRS_CF + t.SUBTRS_CF
                   AND (   (    ACMTRS_NT IN (1014,
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
                            AND ACY_NF = @p_uwy_nf + 1)
                        OR (    c.ACY_NF > @p_uwy_nf
                            AND (t.BLOCK_NF = 1 OR t.BLOCK_NF = 2)
                            AND c.ACMTRS_NT != 1160))
      END


   -- Now that values have been retrieved,
   DELETE #TLIFEST_CRED
    WHERE UWY_NF = @p_uwy_nf

   --2.If "Section Status Before" is Treaty or Section Status Enum.CANCELED AND ("Section Status After" is Treaty or Section Status Enum.FINALIZED)
   IF @p_secsts_ct_before = 19 AND @p_secsts_ct_after = 16
      BEGIN
         IF (@p_accadmtyp_ct_before = 4 AND @p_accadmtyp_ct_after = 1)
            BEGIN
               DELETE #TLIFEST_CRED

               INSERT INTO #TLIFEST_CRED
                  SELECT CTR_NF,
                         END_NT,
                         SEC_NF,
                         UWY_NF,
                         UW_NT,
                         @p_date,
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
                    FROM #TLIFEST_ACMTRS

               DELETE #TLIFEST_ACMTRS
                WHERE    UWY_NF != @p_uwy_nf
                      OR ACY_NF != @p_uwy_nf + 1
                      OR ACMTRS_NT NOT IN (1014,
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

               UPDATE #TLIFEST_ACMTRS
                  SET UWY_NF = UWY_NF + 1
                WHERE     UWY_NF = @p_uwy_nf
                      AND ACY_NF = @p_uwy_nf + 1
                      AND ACMTRS_NT IN (1014,
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

               SELECT @p_date = getdate ()

               UPDATE #TLIFEST_ACMTRS
                  SET CRE_D = @p_date
            END

         IF (@p_accadmtyp_ct_before = 5 AND @p_accadmtyp_ct_after = 3)
            BEGIN
               DELETE #TLIFEST_CRED

               INSERT INTO #TLIFEST_CRED
                  SELECT CTR_NF,
                         END_NT,
                         SEC_NF,
                         UWY_NF,
                         UW_NT,
                         @p_date,
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
                    FROM #TLIFEST_ACMTRS

               DELETE #TLIFEST_ACMTRS
                WHERE    UWY_NF != @p_uwy_nf
                      OR ACY_NF != @p_uwy_nf + 1
                      OR ACMTRS_NT NOT IN (1014,
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

               UPDATE #TLIFEST_ACMTRS
                  SET UWY_NF = UWY_NF + 1
                WHERE     UWY_NF = @p_uwy_nf
                      AND ACY_NF = @p_uwy_nf + 1
                      AND ACMTRS_NT IN (1014,
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

               SELECT @p_date = getdate ()

               UPDATE #TLIFEST_ACMTRS
                  SET CRE_D = @p_date
            END



         IF    (@p_accadmtyp_ct_before = 4 AND @p_accadmtyp_ct_after = 1)
            OR (@p_accadmtyp_ct_before = 5 AND @p_accadmtyp_ct_after = 3)
            BEGIN
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
      END


   --3.If "Section Status After" is Treaty or Section Status Enum.CANCELED
   IF @p_secsts_ct_after = 19
      BEGIN
         --1.If accounting type is Accounting Administrative Type Enum.Accounting_Year (type 1) to type 4
         IF @p_accadmtyp_ct_before = 1 AND @p_accadmtyp_ct_after = 4
            BEGIN
               UPDATE #TLIFEST_ACMTRS
                  SET UWY_NF = UWY_NF - 1

               UPDATE #TLIFEST_CRED
                  SET ESTMNT_M = 0, DIFF_M = 0      --resetting for future UWY
            END

         --2.If accounting type  is Accounting Administrative Type Enum.Underwriting_Year (type 2)
         IF @p_accadmtyp_ct_after = 2
            BEGIN
               UPDATE #TLIFEST_CRED
                  SET ESTMNT_M = 0, DIFF_M = 0
            END

         --3.If accounting type is Accounting Administrative Type Enum.Occurence_Year (type 3) to type 5
         IF @p_accadmtyp_ct_before = 3 AND @p_accadmtyp_ct_after = 5
            BEGIN
               UPDATE #TLIFEST_ACMTRS
                  SET UWY_NF = UWY_NF - 1

               UPDATE #TLIFEST_CRED
                  SET ESTMNT_M = 0, DIFF_M = 0      --resetting for future UWY
            END
      END


   IF @p_secsts_ct_after = 19
      BEGIN
         SELECT @p_date = getdate ()

         INSERT INTO BEST..TLIFEST
            SELECT CTR_NF,
                   END_NT,
                   SEC_NF,
                   UWY_NF,
                   UW_NT,
                   @p_date,
                   @BLCSHTYEA_NF,	-- [008] EST30: Use current balance sheet for insertion
                   @BLCSHTMTH_NF,	-- [008] EST30: Use current balance sheet for insertion
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

   SELECT @p_date = getdate ()

   INSERT INTO BEST..TLIFEST
      SELECT CTR_NF,
             END_NT,
             SEC_NF,
             UWY_NF,
             UW_NT,
             CRE_D,
             @BLCSHTYEA_NF,	-- [008] EST30: Use current balance sheet for insertion
             @BLCSHTMTH_NF,	-- [008] EST30: Use current balance sheet for insertion
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

EXEC sp_procxmode 'dbo.PiLIFEST_06', 'unchained'
go

IF OBJECT_ID ('dbo.PiLIFEST_06') IS NOT NULL
   PRINT '<<< CREATED PROCEDURE dbo.PiLIFEST_06 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROCEDURE dbo.PiLIFEST_06 >>>'
go

GRANT EXECUTE ON dbo.PiLIFEST_06 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiLIFEST_06 TO GDBBATCH
go
