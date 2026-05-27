-- drop table #TSEGMENTRULE 

USE BEST
GO

CREATE TABLE #TSEGMENTRULE (
	SGTRUL_NT			INTEGER,
	SGMT_NF				USGMT_NF,
	SGT_NT				USGT_NT,
	SGTVER_NT			USGTVER_NT,
	RULE_LS				UL16,
	RULPRIO_CT			INTEGER,
	FUNCDEF_T			TEXT,
	TECHDEF_T			TEXT,
	CRE_D				UUPD_D,
	CREUSR_CF			UUPDUSR_CF,
	LSTUPD_D			UUPD_D,
	LSTUPDUSR_CF		UUPDUSR_CF
)

GO

DECLARE C_SEGMENT_RULE CURSOR FOR
	SELECT 	SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, FUNCDEF_T, TECHDEF_T
	FROM 	#TSEGMENTRULE
	ORDER BY SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT
GO

-- 	Déclaration de variables
declare @gCommit VARCHAR (01)
declare @gTodayD DATETIME
declare @startTime DATETIME
declare @endTime DATETIME

-- Variables de curseur
declare @lSgtrulNt				INTEGER
declare @lSgmtNf				USGMT_NF
declare @lSgtNt					USGT_NT
declare @lSgtverNt				USGTVER_NT
declare @lRuleLs				UL16
declare @lFuncdefT				TEXT
declare @lAdjustFuncVarchar		VARCHAR(16000)
declare @lTechdefT				TEXT
declare @lAdjustTechVarchar		VARCHAR(16000)

-- Initialisation des variables
SELECT @gCommit = 'O'
SELECT @gTodayD = getdate()

SELECT @startTime = getdate()

-- Insertion des règles dans la table temporaire
INSERT INTO #TSEGMENTRULE ( 
		SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, 
		FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
		)
SELECT	SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, 
		FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
FROM	BEST..TSEGMENTRULE
WHERE FUNCDEF_T like '%SBS_INDICATOR%' --AND SGT_NT=544 AND SGTVER_NT=9
-- Premiers tests
-- AND		SGT_NT = 127 AND SGTVER_NT IN (1, 2)

PRINT 'BEFORE CHANGES'
SELECT	SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, 
		FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
FROM	#TSEGMENTRULE

-- Traitement des règles
OPEN C_SEGMENT_RULE
FETCH C_SEGMENT_RULE INTO @lSgtrulNt, @lSgmtNf, @lSgtNt, @lSgtverNt, @lRuleLs, @lFuncdefT, @lTechdefT

WHILE @@sqlstatus = 0
begin
	SELECT @lAdjustFuncVarchar = Convert(varchar(16000), @lFuncdefT)
	SELECT @lAdjustFuncVarchar = STR_REPLACE(@lAdjustFuncVarchar, 'SBS_INDICATOR=true', 'FAC_ADMIN_TYPE = 1')
	SELECT @lAdjustFuncVarchar = STR_REPLACE(@lAdjustFuncVarchar, 'SBS_INDICATOR=false', 'FAC_ADMIN_TYPE = 0')	 

	
    SELECT @lAdjustTechVarchar = CONVERT(VARCHAR(16000), @lTechdefT)
    SELECT @lAdjustTechVarchar = STR_REPLACE(@lAdjustTechVarchar, 'BooleanUtils.equals(c.getFacadmtypCt(), false)', 'IntegerUtils.equals(c.getFacadmtypCt(), 0)')
    SELECT @lAdjustTechVarchar = STR_REPLACE(@lAdjustTechVarchar, 'BooleanUtils.equals(c.getFacadmtypCt(), true)', 'IntegerUtils.equals(c.getFacadmtypCt(), 1)')
	

	UPDATE	#TSEGMENTRULE
	SET		FUNCDEF_T 	= Convert(TEXT, @lAdjustFuncVarchar),
			TECHDEF_T	= Convert(TEXT, @lAdjustTechVarchar)
	WHERE	SGTRUL_NT	= @lSgtrulNt
	AND		SGMT_NF		= @lSgmtNf
	AND		SGT_NT		= @lSgtNt
	AND		SGTVER_NT	= @lSgtverNt
	AND		RULE_LS		= @lRuleLs
	
	FETCH C_SEGMENT_RULE INTO @lSgtrulNt, @lSgmtNf, @lSgtNt, @lSgtverNt, @lRuleLs, @lFuncdefT, @lTechdefT
end

CLOSE C_SEGMENT_RULE
DEALLOCATE C_SEGMENT_RULE

PRINT 'AFTER CHANGES'
SELECT	SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, 
		FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
FROM	#TSEGMENTRULE

BEGIN TRAN

UPDATE	BEST..TSEGMENTRULE
SET		FUNCDEF_T = T.FUNCDEF_T,
		TECHDEF_T = T.TECHDEF_T
FROM	#TSEGMENTRULE T,
		BEST..TSEGMENTRULE R
WHERE	R.SGTRUL_NT = T.SGTRUL_NT
AND		R.SGMT_NF = T.SGMT_NF
AND		R.SGT_NT = T.SGT_NT
AND		R.SGTVER_NT = T.SGTVER_NT
AND		R.RULE_LS = T.RULE_LS

-- ------------------- --
-- End transaction     --
-- ------------------- --

IF @gCommit = 'O' 
    BEGIN
        COMMIT TRAN
        PRINT 'COMMIT SUCCESSFUL'
    END
ELSE
    BEGIN
        ROLLBACK TRAN
        PRINT 'ROLLBACK SUCCESSFUL'
    END

fin:

select @endTime = getdate()

select 'Script Time', datediff(ss, @startTime, @endTime), 'seconds'

SET NOCOUNT OFF

GO
