USE BEST
GO

IF OBJECT_ID('dbo.PdLIFEST_H_02') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PdLIFEST_H_02
  IF OBJECT_ID('dbo.PdLIFEST_H_02') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdLIFEST_H_02 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PdLIFEST_H_02 >>>'
END
GO

CREATE PROCEDURE dbo.PdLIFEST_H_02
(
  @p_balshtyea_nf  smallint,
  @p_ssd_cf        int = -1
)
as
/*****************************************************************************
** Domaine                   : (ES) Estimation
** Base principale           : BEST
** Version                   : 1
** Auteur                    : BEL : version 1.0
** Date de creation          : 17 Mars 2020
** Description du programme  : Purge TLIFEST_H pour une année bilan.
******************************************************************************/
---------------------------------------------------------
-- Begin of proc
---------------------------------------------------------

---------------------------------------------------------
-- Save latest update date of each line from TLIFEST_H
-- Attention cette requete prendra beaucoup de temps
---------------------------------------------------------
PRINT 'Save latest update date of each line from TLIFEST_H'
PRINT 'Attention cette requete prendra beaucoup de temps !!! ...'

DECLARE @bal_year int,
		@ssd_cf int,
		@ssdMax_cf int,
		@erreur	int,
		@block  int,
		@TOTAL_LINE int,
		@TOTAL_LATEST int,
		@cur_time varchar(20)
SELECT  @bal_year = @p_balshtyea_nf,		-- DEFINIR L'ANNÉE BILAN ICI
	    @ssd_cf   = @p_ssd_cf, 
		@erreur   = 0,
		@block    = 500000,
		@TOTAL_LINE = 0,
		@TOTAL_LATEST = 0
		

PRINT 'CREATE TOMPORARY TABLE >> BTRAV..TLIFEST_H_TMP5'
CREATE TABLE BTRAV..TLIFEST_H_TMP5 (
  CTR_NF UCTR_NF not null,
  END_NT UEND_NT not null,
  SEC_NF USEC_NF not null,
  UWY_NF UUWY_NF not null,
  UW_NT  UUW_NT  not null,
  BALSHEY_NF smallint not null,
  ACY_NF smallint not null,
  PRS_CF smallint not null, 
  ACMTRS_NT smallint not null, 
  GAAP_NT tinyint not null, 
  DETTRNCOD_CF varchar(5) not null,
  MAX_CRE_D UUPD_D not null
)

SELECT @erreur = @@error
IF @erreur != 0 RETURN

CREATE INDEX ILIFEST_TMP ON  BTRAV..TLIFEST_H_TMP5(
    CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, BALSHEY_NF, ACY_NF, PRS_CF, ACMTRS_NT, GAAP_NT, DETTRNCOD_CF)

SELECT @erreur = @@error
IF @erreur != 0 GOTO fin0


PRINT 'CREATE TABLE >> BTRAV..TLIFEST_H_COPY5 IF SCRIPT FAILED AND LOST DATA FROM TLIFEST_H WE CAN FOUND THE DATA IN THIS TABLE'
create table BTRAV..TLIFEST_H_COPY5 (
  CTR_NF UCTR_NF not null,
  END_NT UEND_NT not null,
  SEC_NF USEC_NF not null,
  UWY_NF UUWY_NF not null,
  UW_NT UUW_NT not null,
  CRE_D UUPD_D not null,
  BALSHEY_NF smallint not null,
  BALSHTMTH_NF tinyint not null,
  ACY_NF smallint not null,
  GAAP_NT tinyint not null,
  DETTRNCOD_CF char(5) default ''  not null,
  ACM_NF tinyint default 13  not null,
  PRS_CF smallint not null,
  ACMTRS_NT smallint not null,
  SSD_CF USSD_CF not null,
  CUR_CF UCUR_CF not null,
  ESTMNT_M UAMT_M not null,
  INDSUP_B bit default 0  not null,
  ORICOD_LS UL16 null,
  CREUSR_CF UUPDUSR_CF not null,
  LSTUPD_D UUPD_D not null,
  LSTUPDUSR_CF UUPDUSR_CF not null,
  ORICTR_NF UCTR_NF null,
  ORISEC_NF USEC_NF null,
  ORIUWY_NF UUWY_NF null,
  DIFF_M UAMT_M null,
  PROPAGATION_B bit default 0  not null,
  CALCULATED_B bit default 0  not null,
  BATCH_B bit default 0  not null
)

SELECT @erreur = @@error
IF @erreur != 0 GOTO fin0

CREATE INDEX ILIFEST_COPY ON  BTRAV..TLIFEST_H_COPY5(
    CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, BALSHEY_NF, ACY_NF, PRS_CF, ACMTRS_NT, GAAP_NT, DETTRNCOD_CF, CRE_D)

SELECT @erreur = @@error
IF @erreur != 0 GOTO fin

select @cur_time =  CONVERT(CHAR(9), GETDATE(),6) + ' ' + CONVERT(CHAR(8), GETDATE(),8)
PRINT '%1! >>> debut de copy', @cur_time
----------------------------------------------------------------
-- COPY ALL ROWS OF BALSHEY_NF =  @bal_year TO TLIFEST_H_COPY5
----------------------------------------------------------------
BEGIN TRAN
declare @balshmth_min int, @balshmth_max int
IF @ssd_cf != -1
BEGIN
	select  @balshmth_min = 0, @balshmth_max = 3, @ssdMax_cf = @ssd_cf
END ELSE
BEGIN
	select  @balshmth_min = 0, @balshmth_max = 12, @ssdMax_cf = 27
END
WHILE @balshmth_max   < 13
BEGIN
  PRINT 'copie de balshtmth %1! < balshtmth <= %2!', @balshmth_min, @balshmth_max
  INSERT INTO BTRAV..TLIFEST_H_COPY5
  (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, GAAP_NT, DETTRNCOD_CF, ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, 
   ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ORICTR_NF, ORISEC_NF, ORIUWY_NF,  DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B)
  SELECT 
   CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, GAAP_NT, DETTRNCOD_CF, ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, 
   ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ORICTR_NF, ORISEC_NF, ORIUWY_NF,  DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B
  FROM	BEST..TLIFEST_H (INDEX ILIFEST_H)
  WHERE   BALSHEY_NF = @bal_year AND BALSHTMTH_NF > @balshmth_min AND BALSHTMTH_NF <= @balshmth_max AND SSD_CF >= @ssd_cf AND SSD_CF <= @ssdMax_cf
  ORDER BY CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, BALSHEY_NF, ACY_NF, PRS_CF, ACMTRS_NT, GAAP_NT, DETTRNCOD_CF, CRE_D

  SELECT @erreur = @@error, @TOTAL_LINE = @TOTAL_LINE + @@rowcount
  IF @erreur != 0
  BEGIN
    ROLLBACK TRAN
    GOTO fin
  END
  
  select @balshmth_min = @balshmth_max, @balshmth_max = @balshmth_max + 3
  COMMIT TRAN
END


select @cur_time =  CONVERT(CHAR(9), GETDATE(),6) + ' ' + CONVERT(CHAR(8), GETDATE(),8)
PRINT '%1! >>> fin de copy et debut recup latest', @cur_time 
----------------------------------------------------------------
-- SAVE MAX CRE_D OF EACH KEY IN TLIFEST_H_TMP5
----------------------------------------------------------------
INSERT INTO BTRAV..TLIFEST_H_TMP5 
		(CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, BALSHEY_NF, ACY_NF, PRS_CF, ACMTRS_NT, GAAP_NT, DETTRNCOD_CF, MAX_CRE_D)
SELECT 	 CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, BALSHEY_NF, ACY_NF, PRS_CF, ACMTRS_NT, GAAP_NT, DETTRNCOD_CF, MAX(CRE_D)
FROM     BTRAV..TLIFEST_H_COPY5 (INDEX ILIFEST_COPY)
GROUP BY CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, BALSHEY_NF, ACY_NF, PRS_CF, ACMTRS_NT, GAAP_NT, DETTRNCOD_CF
ORDER BY CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, BALSHEY_NF, ACY_NF, PRS_CF, ACMTRS_NT, GAAP_NT, DETTRNCOD_CF 

SELECT @erreur = @@error, @TOTAL_LATEST = @@rowcount
IF @erreur != 0 GOTO fin

select @cur_time =  CONVERT(CHAR(9), GETDATE(),6) + ' ' + CONVERT(CHAR(8), GETDATE(),8)
PRINT '%1! >>> Fin du trie latest', @cur_time

IF @TOTAL_LINE = @TOTAL_LATEST GOTO fin

STEP2:
PRINT 'BEFORE PURGE NB ROWS = %1!, @TOTAL_LATEST = %2!', @TOTAL_LINE, @TOTAL_LATEST   -- TO DELETE

----------------------------------------------------------------	
-- Purge of TLIFEST_H_COPY5
----------------------------------------------------------------
BEGIN TRAN
--SET flushmessage ON
--SET nocount ON
DECLARE @trans_etat		int,
		@enr			int,
		@totenr			int

SELECT	@enr    = 1,
		@totenr = 0,
		@erreur = 0
SET rowcount @block
WHILE @enr > 0
BEGIN
	DELETE BTRAV..TLIFEST_H_COPY5 FROM BTRAV..TLIFEST_H_COPY5 A (INDEX ILIFEST_COPY), BTRAV..TLIFEST_H_TMP5 B (INDEX ILIFEST_TMP)
	WHERE   A.CTR_NF       = B.CTR_NF
		AND A.END_NT       = B.END_NT
		AND A.SEC_NF       = B.SEC_NF
		AND A.UWY_NF       = B.UWY_NF
		AND A.UW_NT        = B.UW_NT
		AND A.BALSHEY_NF   = B.BALSHEY_NF
		AND A.ACY_NF       = B.ACY_NF
		AND A.PRS_CF       = B.PRS_CF
		AND A.ACMTRS_NT    = B.ACMTRS_NT
		AND A.GAAP_NT      = B.GAAP_NT
		AND A.DETTRNCOD_CF = B.DETTRNCOD_CF
		AND A.CRE_D       != B.MAX_CRE_D
	
	SELECT	@erreur = @@error,
			@enr    = @@rowcount,
			@totenr = @totenr + @@rowcount
			
	IF @@transtate > 1 OR @erreur != 0 
	BEGIN
		SELECT @enr = -1
		BREAK
	END
	COMMIT TRAN
END

IF @@transtate > 1 OR @erreur != 0 
BEGIN
	PRINT 'PURGE BEST..TLIFEST_H - ERROR : %1!', @erreur
	ROLLBACK TRAN
	GOTO fin
END

select @cur_time =  CONVERT(CHAR(9), GETDATE(),6) + ' ' + CONVERT(CHAR(8), GETDATE(),8)
PRINT '%1! >>> FIN purge table temp, %2! rows deleted', @cur_time, @totenr
IF @totenr = 0 GOTO fin

DECLARE @CMPT INT
SELECT  @CMPT = 0
STEP3:

select @cur_time =  CONVERT(CHAR(9), GETDATE(),6) + ' ' + CONVERT(CHAR(8), GETDATE(),8)
PRINT '%2! >>> DELETE ALL ROWS OF BALSHEY_NF = %1!, SSD_CF =  %3! FROM TLIFEST_H', @bal_year, @cur_time, @ssd_cf
----------------------------------------------------------------	
-- DELETE ALL ROWS OF BALSHEY_NF = @bal_year FROM TLIFEST_H
----------------------------------------------------------------
SELECT @CMPT = @CMPT + 1
BEGIN TRAN
SELECT	@enr    = 1,
		@totenr = 0,
		@erreur = 0
IF @ssd_cf != -1
BEGIN
	select  @ssdMax_cf = @ssd_cf
END ELSE
BEGIN
	select  @ssdMax_cf = 27
END
SET rowcount @block
WHILE @enr > 0
BEGIN
	DELETE BEST..TLIFEST_H FROM BEST..TLIFEST_H A (INDEX ILIFEST_H)
	WHERE   A.BALSHEY_NF = @bal_year AND SSD_CF >= @ssd_cf AND SSD_CF <= @ssdMax_cf
	
	SELECT	@erreur = @@error,
			@enr    = @@rowcount,
			@totenr = @totenr + @@rowcount
			
	IF @@transtate > 1 OR @erreur != 0 
	BEGIN
		SELECT @enr = -1
		BREAK
	END
	COMMIT TRAN
END

IF @@transtate > 1 OR @erreur != 0 
BEGIN
	PRINT 'TRY:%2! >>> PURGE BEST..TLIFEST_H - ERROR : %1!', @erreur, @CMPT
	ROLLBACK TRAN
	IF @CMPT < 4 GOTO STEP3
	ELSE GOTO fin1
END


STEP4:
select @cur_time =  CONVERT(CHAR(9), GETDATE(),6) + ' ' + CONVERT(CHAR(8), GETDATE(),8)
PRINT '%1! >>> COPY ROWS FROM BTRAV..TLIFEST_H_COPY5 TO TLIFEST_H', @cur_time
----------------------------------------------------------------	
-- COPY ROWS FROM TLIFEST_H_COPY5 TO TLIFEST_H
----------------------------------------------------------------
--SELECT @CMPT = @CMPT + 1
SET rowcount 0
BEGIN TRAN
SELECT	@totenr = 0,
		@erreur = 0,
		@enr    = 1

IF @ssd_cf != -1
BEGIN
	select  @balshmth_min = 0, @balshmth_max = 3
END ELSE
BEGIN
	select  @balshmth_min = 0, @balshmth_max = 12
END
WHILE @balshmth_max < 13
BEGIN
  PRINT 'copie de balshtmth %1! < balshtmth <= %2!', @balshmth_min, @balshmth_max
  INSERT INTO BEST..TLIFEST_H
  (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, GAAP_NT, DETTRNCOD_CF, ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, 
   ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ORICTR_NF, ORISEC_NF, ORIUWY_NF,  DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B)
  SELECT
   CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, GAAP_NT, DETTRNCOD_CF, ACM_NF, PRS_CF, ACMTRS_NT, SSD_CF, CUR_CF, 
   ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ORICTR_NF, ORISEC_NF, ORIUWY_NF,  DIFF_M, PROPAGATION_B, CALCULATED_B, BATCH_B
  FROM	BTRAV..TLIFEST_H_COPY5 A
  WHERE A.BALSHTMTH_NF > @balshmth_min AND A.BALSHTMTH_NF <= @balshmth_max 

  SELECT	@erreur = @@error,
  		@enr    = @@rowcount,
  		@totenr = @totenr + @@rowcount
  IF @@transtate > 1 OR @erreur != 0
    BREAK
    
  select @balshmth_min = @balshmth_max, @balshmth_max = @balshmth_max + 3
  COMMIT TRAN
END

IF @@transtate > 1 OR @erreur != 0 
BEGIN
	PRINT 'TRY:%2! >>> PURGE BEST..TLIFEST_H - ERROR : %1!', @erreur, @CMPT
	ROLLBACK TRAN
	IF @CMPT < 4 GOTO STEP3
	ELSE GOTO fin1
END
COMMIT TRAN

PRINT 'Total rows copied to TLIFEST_H : %1!', @totenr

----------------------------------------------------------------
-- DELETE tomporary table 
----------------------------------------------------------------
fin:
DROP TABLE BTRAV..TLIFEST_H_COPY5
fin0:
DROP TABLE BTRAV..TLIFEST_H_TMP5
fin1:
SET rowcount 0
--PRINT 'failed in create tomporary tables or save latest cre_d '
GO

---------------------------------------------------------
-- END of proc
---------------------------------------------------------

EXEC sp_procxmode 'dbo.PdLIFEST_H_02', 'unchained'
IF OBJECT_ID('dbo.PdLIFEST_H_02') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PdLIFEST_H_02 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PdLIFEST_H_02 >>>'
GO
GRANT EXECUTE ON dbo.PdLIFEST_H_02 TO GOMEGA
GO
GRANT EXECUTE ON dbo.PdLIFEST_H_02 TO GDBBATCH
GO
