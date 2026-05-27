USE BEST
go
IF OBJECT_ID('dbo.PsTLOADAUTOEST_01_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsTLOADAUTOEST_01_O2
  IF OBJECT_ID('dbo.PsTLOADAUTOEST_01_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTLOADAUTOEST_01_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsTLOADAUTOEST_01_O2 >>>'
END
GO

CREATE PROCEDURE PsTLOADAUTOEST_01_O2 ( 
	@p_APPL      VARCHAR(10),
	@p_DIR       VARCHAR(50),  
	@p_DATE      DATETIME,
	@p_PREFIX    VARCHAR(10) = NULL,
	@p_UPLDNO_NT int = NULL,
	@p_empty_dir char(1),
	@p_erreur    varchar(250) = NULL output
)
WITH EXECUTE AS CALLER AS

/******************************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert
Creation date     : 17/08/2020
Description       : Generate an upload summary email of an automatic estimates loading
Called by:
ESIJ0813.cmd
_________________
Modification: 1
Author: L. Wernert
Date: 05/10/2020
Description: 90501 -  I17: Interface of estimates upload
_________________
Modification: 1
Author: B. Lagha
Date: 18/11/2021
Description: 98809 -  Update HTML Code for using SENDMAIL function
********************************************************************/

CREATE TABLE #TEXTEMAIL
(  
	ORDRE	INT	NOT NULL, 
	TEXTE	VARCHAR(250)	NOT NULL
)

-- ------------------------- --
-- Declare variables --
-- ------------------------- --

DECLARE 
	@erreur			int, 
	@tran_imbr		bit, 
	@trans_etat		int, 
	@dateparam		char(10),
	@v_step			char(02)

DECLARE 
	@NB_LIGNE		INT, 
	@NB_TOTAL		INT, 
	@NB_CLOSED		INT, 
	@NB_FAILED		INT, 
	@NB_CLOSED_ANO	INT, 
	@NB_HEADLINES	INT, 
	@V_FILE_LL		VARCHAR(60), 
	@V_STATUS_CF	INT, 
	@V_CRE_D		DATETIME, 
	@V_APPLI		VARCHAR(50),
	@V_STATUS_LL	VARCHAR(50)
	
DECLARE
	@c_endHtmlLine		char(05),
	@c_beginHtmlLine	char(03)
SELECT 
	@c_endHtmlLine		= '<!-- ',
	@c_beginHtmlLine	= '-->'

-- --------------------- --
-- Beginning --
-- --------------------- --
-- Init variables
SELECT @erreur = 0, @tran_imbr = 1, @NB_LIGNE = 0
DELETE FROM #TEXTEMAIL

IF @@trancount = 0
BEGIN
  SELECT @tran_imbr = 0
  BEGIN TRAN
END


SELECT @V_APPLI = CASE WHEN @p_APPL = 'EST AUTO' THEN 'ESIJ0810 - AUTOMATIC ESTIMATES UPLOAD - ' ELSE 'UNKNOWN APPLICATION  - ' END

-- Checking entry parameters :  --  
SELECT @v_step = '01'

IF (@p_APPL = NULL OR @p_DIR = NULL OR @p_DATE = NULL)
BEGIN
  PRINT 'ALL PARAMETERS ARE MANDATORY ! APPLI. : %1! - DIRECTORY : %2! - LOADING DATE : %3! ', @p_APPL, @p_DIR, @p_DATE
	
  INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
  SELECT 1, @V_APPLI + 'FILE-LOADING REPORT GOT TROUBLE WITH PARAMETERS - SEE IT SERVICE'
END  
ELSE
BEGIN
	-- --------------------- --
	-- Generating the email --    
	-- --------------------- --
	SELECT @v_step = '05'

	-- Init paramters
	SELECT 
		@dateparam = CONVERT(char(25), @p_DATE, 121), 
		@NB_TOTAL  = 0, 
		@NB_CLOSED = 0, 
		@NB_FAILED = 0, 
		@NB_CLOSED_ANO = 0
	

	-- Create report header
	SELECT @v_step = '10'

	SELECT @NB_LIGNE = @NB_LIGNE + 1
	INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, '-----------------------------------------------------------------------------------------------------------------------'

	SELECT @NB_LIGNE = @NB_LIGNE + 1
	INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, '-- ' + @V_APPLI + ' FILE-LOADING REPORT ON ' + @dateparam + ' --'

	SELECT @NB_LIGNE = @NB_LIGNE + 1
	INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, '-----------------------------------------------------------------------------------------------------------------------' 
	
	SELECT @NB_HEADLINES = @NB_LIGNE
  
	
	IF @p_empty_dir = 'N'
	BEGIN
		-- Declare and open cursor on TSUIVINTACC
		SELECT @v_step = '15'
		DECLARE curs_TLOADAUTOEST CURSOR FOR
			SELECT 
				T1.FILE_LL, T1.STATUS_CF, T1.CRE_D
			FROM 
				BEST..TLOADAUTOEST T1,BREF..TBATCHSSD TSSD
			WHERE
				T1.UPLDNO_NT = @p_UPLDNO_NT AND
				T1.SSD_CF = TSSD.SSD_CF AND 
				TSSD.BATCHUSER_CF = suser_name()                          
			ORDER BY 
				T1.CRE_D                  

		SELECT @v_step = '20'
		OPEN curs_TLOADAUTOEST
		SELECT @v_step = '25'
		FETCH curs_TLOADAUTOEST INTO @V_FILE_LL, @V_STATUS_CF, @V_CRE_D       

		SELECT @erreur = @@error, @trans_etat = @@transtate
		IF @erreur != 0 OR @trans_etat > 1
		BEGIN
			PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
			ROLLBACK TRAN
			GOTO fin
		END
	                            
		-- Loop Fetch/insert
		WHILE (@@sqlstatus != 2)
		BEGIN
			SELECT @v_step = '30'

			-- Begin the insert of the summary table
			IF @NB_LIGNE = @NB_HEADLINES
			BEGIN
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, '<table>' + @c_endHtmlLine
				
				--Insert summary table header
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, @c_beginHtmlLine + '<thead><tr>' + @c_endHtmlLine
				
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, @c_beginHtmlLine + '<th id="file">FILE</th>' + @c_endHtmlLine 
				
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, @c_beginHtmlLine + '<th/><th/><th/><th/><th/>' + @c_endHtmlLine 
				
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, @c_beginHtmlLine + '<th id="status">STATUS</th>' + @c_endHtmlLine
				
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, @c_beginHtmlLine + '<th/><th/><th/><th/><th/>' + @c_endHtmlLine 
				
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, @c_beginHtmlLine + '<th id="date">LOADING DATE</th>' + @c_endHtmlLine
				
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, @c_beginHtmlLine + '</tr></thead>' + @c_endHtmlLine
				
				-- Insert the table body
				SELECT @NB_LIGNE = @NB_LIGNE + 1
				INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
				SELECT @NB_LIGNE, @c_beginHtmlLine + '<tbody>' + @c_endHtmlLine
			END

			-- Add 1 to nb_lines and Insert into #TEXTEMAIL
			SELECT @v_step = '32'
			
			SELECT @NB_LIGNE = @NB_LIGNE + 1
			INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
			SELECT @NB_LIGNE, @c_beginHtmlLine + '<tr>' + @c_endHtmlLine
			
			-- File name
			SELECT @NB_LIGNE = @NB_LIGNE + 1
			INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
			SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>' + @V_FILE_LL + '</td>' + @c_endHtmlLine
			
			SELECT @NB_LIGNE = @NB_LIGNE + 1
			INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
			SELECT @NB_LIGNE, @c_beginHtmlLine + '<td/><td/><td/><td/><td/>' + @c_endHtmlLine 
			
			-- Status
			select @V_STATUS_LL = CASE WHEN @V_STATUS_CF = 2 THEN 'SUCCEEDED' WHEN @V_STATUS_CF = 5 THEN 'FAILED' WHEN @V_STATUS_CF = 10 THEN 'CLOSED W/ ANO.' END
			SELECT @NB_LIGNE = @NB_LIGNE + 1
			INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
			SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>' + @V_STATUS_LL + '</td>' + @c_endHtmlLine
			
			SELECT @NB_LIGNE = @NB_LIGNE + 1
			INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
			SELECT @NB_LIGNE, @c_beginHtmlLine + '<td/><td/><td/><td/><td/>' + @c_endHtmlLine 
			
			-- Loading date
			SELECT @NB_LIGNE = @NB_LIGNE + 1
			INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
			SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>' + CONVERT(CHAR(20),@V_CRE_D,116) + '</td>' + @c_endHtmlLine
			
			
			SELECT @NB_LIGNE = @NB_LIGNE + 1
			INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
			SELECT @NB_LIGNE, @c_beginHtmlLine + '</tr>' + @c_endHtmlLine
			
	                 
			-- traiter code retour  --
			SELECT @erreur = @@error, @trans_etat = @@transtate
			IF @erreur != 0 OR @trans_etat > 1
			BEGIN
				PRINT 'PROBLEME INSERTION DANS #TEXTEMAIL - ERROR : %1!', @erreur
				ROLLBACK TRAN
				GOTO fin
			END

			-- Tally different results 
			SELECT @NB_TOTAL = @NB_TOTAL + 1
			IF @V_STATUS_CF = 2
			BEGIN
				SELECT @NB_CLOSED = @NB_CLOSED + 1
			END
			ELSE
			BEGIN
			  IF @V_STATUS_CF = 5
				BEGIN
					SELECT @NB_FAILED = @NB_FAILED + 1
				END
			  ELSE
				IF @V_STATUS_CF = 10
				BEGIN
					SELECT @NB_CLOSED_ANO = @NB_CLOSED_ANO + 1
				END
			END

			-- Fetch next
			SELECT @v_step = '35'
			FETCH curs_TLOADAUTOEST INTO @V_FILE_LL, @V_STATUS_CF, @V_CRE_D       

			SELECT @erreur = @@error, @trans_etat = @@transtate
			IF @erreur != 0 OR @trans_etat > 1
			BEGIN
				PRINT 'PROBLEME FETCH CURSOR - ERROR : %1!', @erreur
				ROLLBACK TRAN
				GOTO fin
			END
		END
		
		-- Close table 
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tbody></table>' + @c_endHtmlLine
		
		-- Add carriage return
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<br>'
		

		SELECT @v_step = '40'
		CLOSE curs_TLOADAUTOEST
		DEALLOCATE CURSOR curs_TLOADAUTOEST
	END
	
	-- Insert file counting table
	SELECT @NB_LIGNE = @NB_LIGNE + 1
	INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, '<table>' + @c_endHtmlLine

	--  Report if directory is not empty : different results
	IF @p_empty_dir = 'N'
	BEGIN
		SELECT @v_step = '50'
		
		-- Insert body
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<tbody><tr>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>NUMBER OF FILES</td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td> : </td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>' + CONVERT(CHAR(03),@NB_TOTAL) + '</td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tr>' + @c_endHtmlLine 

		-- Successful file loading w/o anomalies
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<tr>' + @c_endHtmlLine 
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>SUCCEEDED</td>' + @c_endHtmlLine 
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td> : </td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>'+ CONVERT(CHAR(05),@NB_CLOSED) +'</td>' + @c_endHtmlLine
		
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tr>' + @c_endHtmlLine 
		
		-- Failed file loading
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<tr>' + @c_endHtmlLine 
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>FAILED</td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td> : </td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>' + CONVERT(CHAR(05),@NB_FAILED) + '</td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tr>' + @c_endHtmlLine
		
		-- Successful file loading w/ anomalies
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<tr>' + @c_endHtmlLine 
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>CLOSED WITH ANOMALIES</td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td> : </td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td>' + CONVERT(CHAR(05),@NB_CLOSED_ANO) + '</td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tr>' + @c_endHtmlLine 
		
		-- Close table 
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tbody></table>' + @c_endHtmlLine
		
		-- Add carriage return
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<br>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<p>FOR MORE INFORMATION, PLEASE SEE BO REPORT.</p>'  
	END 
	--  Report if directory is empty
	ELSE 
	BEGIN
		SELECT @v_step = '55'
		-- 1st row
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<tr>' + @c_endHtmlLine 
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<th>NO LOADED FILE : File or Directory "' + @p_DIR + '" may be empty.</th>' + @c_endHtmlLine 
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tr>' + @c_endHtmlLine 
		
		-- 2nd row
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<tr>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<td> EXPECTED FILE PREFIX : "' + @p_PREFIX + '_' + '"</td>' + @c_endHtmlLine
		
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tr>' + @c_endHtmlLine 
		
		-- Close table 
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '</tbody></table>' + @c_endHtmlLine
		
		-- Add carriage return
		SELECT @NB_LIGNE = @NB_LIGNE + 1
		INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
		SELECT @NB_LIGNE, @c_beginHtmlLine + '<br>'
	END 

	-- Create end of report 
	SELECT @v_step = '60'
	SELECT @NB_LIGNE = @NB_LIGNE + 1
	INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, ' ' 

	SELECT @v_step = '62'
	SELECT @NB_LIGNE = @NB_LIGNE + 1
	INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, '-----------------------------------------------------------------------------------------------------------------------' 

	SELECT @v_step = '64'
	SELECT @NB_LIGNE = @NB_LIGNE + 1
  INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, '------------------------------------------------ END OF REPORT ------------------------------------------------' 

	SELECT @v_step = '66'
	SELECT @NB_LIGNE = @NB_LIGNE + 1
	INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, '-----------------------------------------------------------------------------------------------------------------------'
	
	SELECT @NB_LIGNE = @NB_LIGNE + 1
	INSERT INTO #TEXTEMAIL (ORDRE, TEXTE)
	SELECT @NB_LIGNE, '</body></html>'
END  
  
-- Create Result Set 
SELECT @v_step = '70'
SELECT TEXTE FROM #TEXTEMAIL

-- Commit tran
IF @tran_imbr = 0
	BEGIN
	COMMIT TRAN
END

return 0


-- Rollback
fin:

--   DROP TABLE #TEXTEMAIL  --  laisser en commentaire
IF @tran_imbr = 0
	BEGIN
	ROLLBACK TRAN
END

select @p_erreur = 'Error PsTLOADAUTOEST_01_O2 - Step: ' + @v_step + ' - SQLCode: ' + convert(char(5),@erreur)
PRINT @p_erreur

return -1
go

EXEC sp_procxmode 'dbo.PsTLOADAUTOEST_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsTLOADAUTOEST_01_O2') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PsTLOADAUTOEST_01_O2 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTLOADAUTOEST_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PsTLOADAUTOEST_01_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTLOADAUTOEST_01_O2 TO GDBBATCH
go
