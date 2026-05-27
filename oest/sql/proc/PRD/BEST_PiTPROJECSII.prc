USE BEST
go
IF OBJECT_ID('dbo.PiTPROJECSII') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiTPROJECSII
    IF OBJECT_ID('dbo.PiTPROJECSII') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiTPROJECSII >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiTPROJECSII >>>'
END
go
CREATE PROCEDURE dbo.PiTPROJECSII 
(@P_SSD_CF USSD_CF,
 @P_USR_CF UUSR_CF)
    AS
	
/***************************************************
Program: PiTPROJECSII
Base principal : BEST
Description : SII06B - This stored procedure get the records from working table 
EST_ESID0841_SIICASHFLOWS, do functional validations and insert into BEST..TPROJECSII
Author : Anil Gavate
Version : 1.0
_________________
MODIFICATIONS
1 Partha        11/09/2014      Modified for defect #30752
*****************************************************/


        DECLARE
		    @SSD_CF USSD_CF,
            @END_NT UEND_NT,
            @UW_NT UUW_NT,
            @ESB_CF UESB_CF,
            @CLODAT_D DATETIME,
            @CTR_NF UCTR_NF,
            @UWY_NF UUWY_NF,
            @SEC_NF USEC_NF,
            @ACMTRS_NT SMALLINT,
            @TABLECOUNT INT,
            @P_CLODAT_D DATETIME,
            @P_PER_CF CHAR (3),
            @P_CURRDAT_D DATETIME,
            @ANOMALYFLAG TINYINT,
			@erreur int,
            @p_erreur CHAR (64),
			@dec_CUR_CF UCUR_CF,
			@dec_AN1  UAMT_M ,
			@dec_AN2  UAMT_M , 
			@dec_AN3  UAMT_M , 
			@dec_AN4  UAMT_M,  
			@dec_AN5  UAMT_M, 
			@dec_AN6  UAMT_M, 
			@dec_AN7  UAMT_M ,  
			@dec_AN8  UAMT_M ,  
			@dec_AN9  UAMT_M , 
			@dec_AN10 UAMT_M ,
            @dec_AN11 UAMT_M ,
			@dec_AN12 UAMT_M , 
			@dec_AN13 UAMT_M , 
			@dec_AN14 UAMT_M , 
			@dec_AN15 UAMT_M , 
			@dec_AN16 UAMT_M , 
			@dec_AN17 UAMT_M , 
			@dec_AN18 UAMT_M , 
			@dec_AN19 UAMT_M , 
			@dec_AN20 UAMT_M ,
            @dec_AN21 UAMT_M ,
			@dec_AN22 UAMT_M , 
			@dec_AN23 UAMT_M , 
			@dec_AN24 UAMT_M , 
			@dec_AN25 UAMT_M , 
			@dec_AN26 UAMT_M , 
			@dec_AN27 UAMT_M , 
			@dec_AN28 UAMT_M , 
			@dec_AN29 UAMT_M , 
			@dec_AN30 UAMT_M ,
            @dec_AN31 UAMT_M ,
			@dec_AN32 UAMT_M , 
			@dec_AN33 UAMT_M , 
			@dec_AN34 UAMT_M , 
			@dec_AN35 UAMT_M , 
			@dec_AN36 UAMT_M , 
			@dec_AN37 UAMT_M , 
			@dec_AN38 UAMT_M , 
			@dec_AN39 UAMT_M , 
			@dec_AN40 UAMT_M ,
            @dec_AN41 UAMT_M ,
			@dec_AN42 UAMT_M , 
			@dec_AN43 UAMT_M , 
			@dec_AN44 UAMT_M , 
			@dec_AN45 UAMT_M , 
			@dec_AN46 UAMT_M ,
			@dec_AN47 UAMT_M , 
			@dec_AN48 UAMT_M , 
			@dec_AN49 UAMT_M , 
			@dec_AN50 UAMT_M , 
			@dec_AN51 UAMT_M ,
			@dec_AN52 UAMT_M , 
			@dec_AN53 UAMT_M , 
			@dec_AN54 UAMT_M , 
			@dec_AN55 UAMT_M , 
			@dec_AN56 UAMT_M ,
			@dec_AN57 UAMT_M , 
			@dec_AN58 UAMT_M , 
			@dec_AN59 UAMT_M , 
			@dec_AN60 UAMT_M ,
            @dec_AN61 UAMT_M ,
			@dec_AN62 UAMT_M ,
			@dec_AN63 UAMT_M , 
			@dec_AN64 UAMT_M , 
			@dec_AN65 UAMT_M ,
			@dec_CREUSR_CF UUPDUSR_CF,
			@dec_LINE_N int
			
        SET @SSD_CF = @P_SSD_CF /* ADAPTIVE SERVER HAS EXPANDED ALL '*' ELEMENTS IN THE FOLLOWING STATEMENT */
        /* Adaptive Server has expanded all '*' elements in the following statement */
        
		/* For the defect IN032612 */
		DELETE BEST..TCTRANO WHERE SEG_NF=@P_USR_CF AND SSD_CF=@P_SSD_CF AND SEGTYP_CT='S'
		
		DECLARE SIICASHFLOWS_CUR CURSOR FOR
		SELECT
            CTR_NF, SEC_NF, UWY_NF, ACMTRS_NT, CUR_CF,
			AN1, AN2, AN3, AN4, AN5, AN6, AN7, AN8, AN9, AN10,
            AN11,AN12, AN13, AN14, AN15, AN16, AN17, AN18, AN19, AN20,
            AN21,AN22, AN23, AN24, AN25, AN26, AN27, AN28, AN29, AN30,
            AN31,AN32, AN33, AN34, AN35, AN36, AN37, AN38, AN39, AN40,
            AN41,AN42, AN43, AN44, AN45, AN46, AN47, AN48, AN49, AN50, 
			AN51,AN52, AN53, AN54, AN55, AN56, AN57, AN58, AN59, AN60,
            AN61,AN62, AN63, AN64, AN65 , CREUSR_CF,LINE_N
        FROM BTRAV..EST_ESID0841_SIICASHFLOWS  WHERE CREUSR_CF = @P_USR_CF
		
		OPEN SIICASHFLOWS_CUR
	
		fetch SIICASHFLOWS_CUR into
		@CTR_NF, @SEC_NF, @UWY_NF, @ACMTRS_NT, @dec_CUR_CF,
		@dec_AN1  ,	@dec_AN2  ,	@dec_AN3  ,	@dec_AN4  ,	@dec_AN5  ,	@dec_AN6  ,	@dec_AN7  ,	@dec_AN8  ,	@dec_AN9  ,	@dec_AN10 ,
		@dec_AN11 ,	@dec_AN12 ,	@dec_AN13 ,	@dec_AN14 ,	@dec_AN15 ,	@dec_AN16 ,	@dec_AN17 ,	@dec_AN18 ,	@dec_AN19 ,	@dec_AN20 ,
		@dec_AN21 ,	@dec_AN22 ,	@dec_AN23 ,	@dec_AN24 ,	@dec_AN25 ,	@dec_AN26 ,	@dec_AN27 ,	@dec_AN28 ,	@dec_AN29 ,	@dec_AN30 ,
		@dec_AN31 ,	@dec_AN32 ,	@dec_AN33 ,	@dec_AN34 ,	@dec_AN35 ,	@dec_AN36 ,	@dec_AN37 ,	@dec_AN38 ,	@dec_AN39 ,	@dec_AN40 ,
		@dec_AN41 ,	@dec_AN42 ,	@dec_AN43 ,	@dec_AN44 ,	@dec_AN45 ,	@dec_AN46 ,	@dec_AN47 ,	@dec_AN48 ,	@dec_AN49 ,	@dec_AN50 ,
		@dec_AN51 ,	@dec_AN52 ,	@dec_AN53 ,	@dec_AN54 ,	@dec_AN55 ,	@dec_AN56 ,	@dec_AN57 ,	@dec_AN58 ,	@dec_AN59 ,	@dec_AN60 ,
		@dec_AN61 ,	@dec_AN62 ,	@dec_AN63 ,	@dec_AN64 ,	@dec_AN65, @dec_CREUSR_CF  ,@dec_LINE_N
		IF (@@sqlstatus = 1)
			BEGIN
                  PRINT "ERROR in SIICASHFLOWS_CUR Procedure PiTPROJECSII"
                  CLOSE SIICASHFLOWS_CUR
                  RETURN 1
			END
		
        /*SELECT @TABLECOUNT = COUNT (*)
        FROM BTRAV..EST_ESID0841_SIICASHFLOWS*/
        
        SET @ANOMALYFLAG = 0
		
        WHILE (@@sqlstatus != 2)
            
			BEGIN --CLOSE-1
                
				IF EXISTS (SELECT 1 FROM BTRT..TCONTR WHERE CTR_NF = @CTR_NF AND UWY_NF = @UWY_NF)
                    ---- ASSUMED CONTRACT STARTS
                    BEGIN
						SELECT @ESB_CF = ACCESB_CF, @END_NT = t1.END_NT, @UW_NT = t1.UW_NT
								FROM BTRT..TCONTR t1 INNER JOIN BTRT..TSECTION T2
								ON  t1.CTR_NF = T2.CTR_NF AND  t1.UWY_NF = T2.UWY_NF AND
									t1.UW_NT = T2.UW_NT AND t1.END_NT = T2.END_NT
                        WHERE t1.CTR_NF = @CTR_NF AND t1.UWY_NF = @UWY_NF AND T2.SEC_NF = @SEC_NF
                        
						/* CHECK: ASSUMED-- SUBSIDIARY CHECK */
                        IF NOT EXISTS (SELECT 1 FROM BTRT..TCONTR A WHERE A.SSD_CF = @P_SSD_CF AND A.CTR_NF = @CTR_NF)
                            BEGIN
                                PRINT '<<< SUBSIDIARY CHECK FAILED >>>'
                                EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 90, @dec_LINE_N, @p_erreur = @p_erreur output      --modif 1
								--ERROR Check Handling
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
                                SET @ANOMALYFLAG = 1
							END 
						
						/* CHECK: ASSUMED -- CONTRACT IS  Exists OR NOT */
                        IF NOT EXISTS (SELECT 1 FROM BTRT..TCONTR A, BTRT..TSECTION C WHERE
                                A.CTR_NF = C.CTR_NF AND A.UWY_NF = C.UWY_NF AND A.UW_NT = C.UW_NT AND
                                A.END_NT = C.END_NT AND A.CTR_NF = @CTR_NF AND A.UWY_NF = @UWY_NF AND
                                A.UW_NT = @UW_NT AND A.END_NT = @END_NT AND C.SEC_NF = @SEC_NF)
                            BEGIN
								EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 2, @dec_LINE_N, @p_erreur = @p_erreur output     --modif 1  
								--ERROR Check Handling
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
								SET @ANOMALYFLAG = 1
                            END 
						
						/* CHECK: ASSUMED -- DUMMY CONTRACT CHECK */
                        IF NOT EXISTS (SELECT 1 FROM BTRT..TCONTR A WHERE A.ESTCRB_CT = 'D' AND A.CTR_NF = @CTR_NF AND
                                           A.UWY_NF = @UWY_NF AND A.UW_NT = @UW_NT AND A.END_NT = @END_NT)
                            BEGIN
                                PRINT '<<< DUMMY CONTRACT CHECK FAILED >>>'
								EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 91, @dec_LINE_N, @p_erreur = @p_erreur output		--modif 1
                                --ERROR Check Handling
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
								SET @ANOMALYFLAG = 1
                            END 
						
						/* CHECK: ASSUMED-- CONTRACT STATUS (TERMINATED OR NOT) */
                        IF EXISTS (SELECT 1 FROM BTRT..TCONTR A, BTRT..TSECTION C WHERE A.CTR_NF = C.CTR_NF AND
                                       A.UWY_NF = C.UWY_NF AND A.UW_NT = C.UW_NT AND A.END_NT = C.END_NT AND
                                       A.CTR_NF = @CTR_NF AND C.SEC_NF = @SEC_NF AND A.UWY_NF = @UWY_NF AND
                                       A.UW_NT = @UW_NT AND A.END_NT = @END_NT AND C.SECSTS_CT IN ( 16, 17, 19 )
                                       AND C.SECACCSTS_CT IN (8, 9))
                            BEGIN
                                PRINT '<<< CONTRACT IS TERMINATED >>>'
								EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 47, @dec_LINE_N, @p_erreur = @p_erreur output		--modif 1
                                --ERROR Check Handling
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
                                SET @ANOMALYFLAG = 1
                            END 
						
						/* CHECK: ASSUMED -- LEDGER CHECK/AUTHORIZATION */
                        IF NOT EXISTS (SELECT 1 FROM BREF..TESB T1, BTRT..TCONTR T2, BREF..TGRP2USR T3, BREF..TGRP2ESB T4
                                       WHERE T1.SSD_CF = T4.SSD_CF AND T1.ESB_CF = T4.ESB_CF AND T4.GRP_CF = T3.GRP_CF 
									   AND T3.USR_CF = @P_USR_CF AND T2.CTR_NF = @CTR_NF AND T2.SSD_CF = T1.SSD_CF AND
                                           T1.ESB_CF = T2.ACCESB_CF AND T1.SSD_CF = @SSD_CF AND T1.ESB_CF = @ESB_CF)
                            BEGIN
                                PRINT '<<< NO AUTHORIZATION FOR SELECTED LEDGER >>>'
                                EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 90, @dec_LINE_N, @p_erreur = @p_erreur output		--modif 1
                                --ERROR Check Handling
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
								SET @ANOMALYFLAG = 1
                            END
                    END 
					/*  END IF ASSUMED */
                -- RETRO CONTRACT STARTS
                ELSE  IF EXISTS (SELECT 1 FROM BRET..TRETCTR WHERE RETCTR_NF = @CTR_NF AND RTY_NF = @UWY_NF)
                    BEGIN
                        SELECT @ESB_CF = ESB_CF FROM BRET..TRETCTR T1 WHERE T1.RETCTR_NF = @CTR_NF AND T1.RTY_NF = @UWY_NF
						
						/* CHECK: RETRO-- SUBSIDIARY CHECK */
                        IF NOT EXISTS (SELECT 1 FROM BRET..TRETCTR A WHERE A.RETCTR_NF = @CTR_NF AND A.SSD_CF = @P_SSD_CF)
                            BEGIN
                                PRINT '<<< SUBSIDIARY CHECK FAILED >>>'
								EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 90, @dec_LINE_N, @p_erreur = @p_erreur output		--modif 1
                                --ERROR Check Handling
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
								SET @ANOMALYFLAG = 1
                            END 
						/* CHECK: RETRO--CONTRACT IS A RETROCESSION CONTRACT CHECK */
                        IF NOT EXISTS (SELECT 1 FROM BRET..TRETCTR A, BRET..TRETSEC C WHERE
                                        C.RETCTR_NF = A.RETCTR_NF AND A.RTY_NF = C.RTY_NF AND
										C.RETSEC_NF = @SEC_NF AND A.RETCTR_NF = @CTR_NF AND A.RTY_NF = @UWY_NF)
                            BEGIN
                                PRINT '<<< Contract/Underwriting year/Section : check failed >>>'
								EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 2, @dec_LINE_N, @p_erreur = @p_erreur output			--modif 1
                                if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
								SET @ANOMALYFLAG = 1
                            END 
						
						/* CHECK: RETRO--DUMMY CONTRACT CHECK */
                        IF NOT EXISTS (SELECT 1 FROM BRET..TRETCTR A WHERE A.ESTCRB_CT = 'D' AND A.RETCTR_NF = @CTR_NF AND A.RTY_NF = @UWY_NF)
                            BEGIN
								PRINT '<<< DUMMY CONTRACT CHECK FAILED >>>'
                                EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 91, @dec_LINE_N, @p_erreur = @p_erreur output		--modif 1
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
								SET @ANOMALYFLAG = 1
                            END 
							
						/* CHECK: RETRO-- CONTRACT STATUS (TERMINATED OR NOT) */
                        IF EXISTS (SELECT 1 FROM BRET..TRETCTR A WHERE A.RETCTR_NF = @CTR_NF AND A.RTY_NF = @UWY_NF AND 
									A.RETCTRSTS_CT IN (3, 19) AND A.TERCTR_B = 1)
                            BEGIN
                                PRINT '<<< CONTRACT IS TERMINATED >>>'
								EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 47, @dec_LINE_N, @p_erreur = @p_erreur output		--modif 1
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
								SET @ANOMALYFLAG = 1
                            END 
						/* CHECK: RETRO-- LEDGER CHECK/AUTHORIZATION */
                        IF NOT EXISTS (SELECT 1 FROM BREF..TESB T1, BRET..TRETCTR T2, BREF..TGRP2USR T3, BREF..TGRP2ESB T4
                                           WHERE T1.SSD_CF = T4.SSD_CF AND T1.ESB_CF = T4.ESB_CF AND T4.GRP_CF = T3.GRP_CF AND
                                               T3.USR_CF = @P_USR_CF AND T2.RETCTR_NF = @CTR_NF AND T2.SSD_CF = T1.SSD_CF AND
                                               T1.ESB_CF = T2.ESB_CF AND T1.SSD_CF = @SSD_CF AND T1.ESB_CF = @ESB_CF)
                            BEGIN
                                PRINT '<<< NO AUTHORIZATION FOR SELECTED LEDGER>>>'
                                EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 90, @dec_LINE_N, @p_erreur = @p_erreur output		--modif 1
								if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
								SET @ANOMALYFLAG = 1
                            END
                        END 
						--END FOR RETRO--
                        /* --WHEN CONTRACT IS NIETHER ASSUMED NOR RETRO */
                ELSE
					BEGIN
                            PRINT '<<< CONTRACT IS NEITHER AN ASSUMED CONTRACT OR A RETROCESSION CONTRACT FAILED >>>'
                            EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 2, @dec_LINE_N, @p_erreur = @p_erreur output				--modif 1
							if @erreur != 0 
									BEGIN
										select @p_erreur
										goto fin
									END
							SET @ANOMALYFLAG = 1
                    END 
						/* CHECK: Currency */
			IF NOT EXISTS (SELECT 1 FROM BREF..TCUR WHERE CUR_CF = @dec_CUR_CF) 
			BEGIN 
				EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 85, @dec_LINE_N, @p_erreur = @p_erreur output			--modif 1
				if @erreur != 0 
					BEGIN
						select @p_erreur
						goto fin
					END
				SET @ANOMALYFLAG = 1
			END 
			/* CHECK: Accumulation Transaction Code */
			IF NOT EXISTS (SELECT 1 FROM BREF..TACMTRS WHERE ACMTRS_NT = @ACMTRS_NT AND PRS_CF = 700)
			BEGIN 
				EXECUTE @erreur = BEST..PiTCTRANOSII_01 @CTR_NF, 0, @SEC_NF, 1, @SSD_CF, 'S', @P_USR_CF, 92, @dec_LINE_N, @p_erreur = @p_erreur output			--modif 1
				if @erreur != 0 
					BEGIN
						select @p_erreur
						goto fin
					END
				SET @ANOMALYFLAG = 1
			END
						
			
			
			fetch SIICASHFLOWS_CUR into
				@CTR_NF, @SEC_NF, @UWY_NF, @ACMTRS_NT, @dec_CUR_CF,
				@dec_AN1  ,	@dec_AN2  ,	@dec_AN3  ,	@dec_AN4  ,	@dec_AN5  ,	@dec_AN6  ,	@dec_AN7  ,	@dec_AN8  ,	@dec_AN9  ,	@dec_AN10 ,
				@dec_AN11 ,	@dec_AN12 ,	@dec_AN13 ,	@dec_AN14 ,	@dec_AN15 ,	@dec_AN16 ,	@dec_AN17 ,	@dec_AN18 ,	@dec_AN19 ,	@dec_AN20 ,
				@dec_AN21 ,	@dec_AN22 ,	@dec_AN23 ,	@dec_AN24 ,	@dec_AN25 ,	@dec_AN26 ,	@dec_AN27 ,	@dec_AN28 ,	@dec_AN29 ,	@dec_AN30 ,
				@dec_AN31 ,	@dec_AN32 ,	@dec_AN33 ,	@dec_AN34 ,	@dec_AN35 ,	@dec_AN36 ,	@dec_AN37 ,	@dec_AN38 ,	@dec_AN39 ,	@dec_AN40 ,
				@dec_AN41 ,	@dec_AN42 ,	@dec_AN43 ,	@dec_AN44 ,	@dec_AN45 ,	@dec_AN46 ,	@dec_AN47 ,	@dec_AN48 ,	@dec_AN49 ,	@dec_AN50 ,
				@dec_AN51 ,	@dec_AN52 ,	@dec_AN53 ,	@dec_AN54 ,	@dec_AN55 ,	@dec_AN56 ,	@dec_AN57 ,	@dec_AN58 ,	@dec_AN59 ,	@dec_AN60 ,
				@dec_AN61 ,	@dec_AN62 ,	@dec_AN63 ,	@dec_AN64 ,	@dec_AN65 ,@dec_CREUSR_CF  ,@dec_LINE_N
			
			END --CLOSE-1
		
		CLOSE SIICASHFLOWS_CUR
        DEALLOCATE CURSOR SIICASHFLOWS_CUR	
		
		
		/* CHECK: 2 - Calculation of the closing period and closing type */
        SET @P_CURRDAT_D = GETDATE ()
		--Calculation of the closing period and closing type
        EXEC BREF..PSCALEND_EBS @P_CURRDAT_D, 1, @P_CLODAT_D = @P_CLODAT_D OUTPUT, @P_PER_CF = @P_PER_CF OUTPUT 
		
		/*DELETION IN THE DATABASE -- For each ledger of the contracts present in the working table and for the closing period (p_clodat_d), 
									it removes the existing data in the BEST..TPROJECSII table.*/
        IF @ANOMALYFLAG = 0
            BEGIN
                /* CHECK: 3 - Deletion in the Database */
                DELETE FROM BEST..TPROJECSII WHERE SSD_CF = @P_SSD_CF AND CLODAT_D = @P_CLODAT_D 
                
                /* CHECK: 4 - Insertion in the Database        */
                        INSERT INTO BEST..TPROJECSII
                        SELECT
                            @P_SSD_CF, 
							T2.ACCESB_CF AS ESB_CF, 
							@P_CLODAT_D, @P_PER_CF, T1.CTR_NF, T1.UWY_NF,  
							T2.UW_NT, 
							T2.END_NT,
							T1.SEC_NF, NULL, T1.ACMTRS_NT, T1.CUR_CF,
                            NULL, NULL, NULL, GETDATE (), @P_USR_CF,
                            T1.AN1, T1.AN2, T1.AN3, T1.AN4, T1.AN5, T1.AN6, T1.AN7, T1.AN8, T1.AN9, T1.AN10,
                            T1.AN11, T1.AN12, T1.AN13, T1.AN14, T1.AN15, T1.AN16, T1.AN17, T1.AN18, T1.AN19, T1.AN20,
                            T1.AN21, T1.AN22, T1.AN23, T1.AN24, T1.AN25, T1.AN26, T1.AN27, T1.AN28, T1.AN29, T1.AN30,
                            T1.AN31, T1.AN32, T1.AN33, T1.AN34, T1.AN35, T1.AN36, T1.AN37, T1.AN38, T1.AN39, T1.AN40,
                            T1.AN41, T1.AN42, T1.AN43, T1.AN44, T1.AN45, T1.AN46, T1.AN47, T1.AN48, T1.AN49, T1.AN50, 
							T1.AN51, T1.AN52, T1.AN53, T1.AN54, T1.AN55, T1.AN56, T1.AN57, T1.AN58, T1.AN59, T1.AN60,
                            T1.AN61, T1.AN62, T1.AN63, T1.AN64, T1.AN65
                        FROM BTRAV..EST_ESID0841_SIICASHFLOWS T1,BTRT..TCONTR T2 
						WHERE T2.CTR_NF = T1.CTR_NF AND T2.UWY_NF = T1.UWY_NF AND T1.CREUSR_CF = @P_USR_CF
                        
						INSERT INTO BEST..TPROJECSII
                        SELECT @P_SSD_CF, 
								T2.ESB_CF, 
								@P_CLODAT_D, @P_PER_CF, T1.CTR_NF, T1.UWY_NF,
								0, 0, T1.SEC_NF, NULL,T1.ACMTRS_NT,T1.CUR_CF,
								NULL, NULL, NULL, GETDATE (), @P_USR_CF,
								T1.AN1, T1.AN2, T1.AN3, T1.AN4, T1.AN5, T1.AN6, T1.AN7, T1.AN8, T1.AN9, T1.AN10,
								T1.AN11, T1.AN12, T1.AN13, T1.AN14, T1.AN15, T1.AN16, T1.AN17, T1.AN18, T1.AN19, T1.AN20,
								T1.AN21, T1.AN22, T1.AN23, T1.AN24, T1.AN25, T1.AN26, T1.AN27, T1.AN28, T1.AN29, T1.AN30,
								T1.AN31, T1.AN32, T1.AN33, T1.AN34, T1.AN35, T1.AN36, T1.AN37, T1.AN38, T1.AN39, T1.AN40,
								T1.AN41, T1.AN42, T1.AN43, T1.AN44, T1.AN45, T1.AN46, T1.AN47, T1.AN48, T1.AN49, T1.AN50, 
								T1.AN51, T1.AN52, T1.AN53, T1.AN54, T1.AN55, T1.AN56, T1.AN57, T1.AN58, T1.AN59, T1.AN60,
								T1.AN61, T1.AN62, T1.AN63, T1.AN64, T1.AN65
							FROM BTRAV..EST_ESID0841_SIICASHFLOWS T1,BRET..TRETCTR T2 
							WHERE T2.RETCTR_NF = T1.CTR_NF AND T2.RTY_NF = T1.UWY_NF AND T1.CREUSR_CF = @P_USR_CF
            END
        ELSE 
		
		return 0
		
fin:
return @erreur

EXEC SP_PROCXMODE 'DBO.PiTPROJECSII', 'UNCHAINED'
go
EXEC sp_procxmode 'dbo.PiTPROJECSII', 'unchained'
go
IF OBJECT_ID('dbo.PiTPROJECSII') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiTPROJECSII >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiTPROJECSII >>>'
go
GRANT EXECUTE ON dbo.PiTPROJECSII TO GOMEGA
go
GRANT EXECUTE ON dbo.PiTPROJECSII TO GDBBATCH
go
