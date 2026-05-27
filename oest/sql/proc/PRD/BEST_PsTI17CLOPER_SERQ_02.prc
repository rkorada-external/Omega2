USE BEST
go

IF OBJECT_ID('dbo.PsTI17CLOPER_SERQ_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTI17CLOPER_SERQ_02
    IF OBJECT_ID('dbo.PsTI17CLOPER_SERQ_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTI17CLOPER_SERQ_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTI17CLOPER_SERQ_02 >>>'
END
go

create procedure dbo.PsTI17CLOPER_SERQ_02(
		@norme_cf char(4),
		@p_PSTOMGEND17_D char(8),
		@PARM_REQCOD_CT varchar(20),
		@PARM_CRE_D char(8)
  )

as

/***************************************************
Domaine:					Estimations
Base principale:			BEST
Version:					1
Auteur:						CAS
Date de creation:			22/11/2019
Description du programme:	Extract param1 and param2 from TI17CLOPER
Conditions d'execution:		
Commentaires: 				US5850  Evolution SERQ : Merge  files
*****************************************************/

DECLARE @erreur int,
		@currentdate datetime,
		@p_currentdate char(8),
		@p_clo_date_delayed_parm5 char(8),
		@year int,
		@month int,
		@day int,
		@diff int
SELECT @erreur = 0
SELECT @currentdate = getdate()
SELECT @year = YEAR(@currentdate)
SELECT @month = MONTH(@currentdate)
SELECT @day = DAY(@currentdate)

BEGIN
SELECT @p_currentdate = CAST(@year*10000+@month*100+@day  AS CHAR(8))
END


BEGIN
SELECT @diff = DATEDIFF(Day,@p_PSTOMGEND17_D, @PARM_CRE_D)
END

print '==> @PARM_CRE_D = %1!', @PARM_CRE_D
print '==> @p_currentdate = %1!', @p_currentdate
print '==> @p_PSTOMGEND17_D = %1!', @p_PSTOMGEND17_D
print '==> @diff = %1!', @diff
print '==> @PARM_REQCOD_CT = %1!', @PARM_REQCOD_CT

IF(@norme_cf = 'I17G')
BEGIN
	SELECT 
	a.SSD_CF,
	a.ESB_CF,
	a.PARM1,
	a.PARM2,
	a.PARM3,
	a.PARM4,
	a.PARM5,
	a.PARM6,
	a.PARM7,
	a.PARM8,
	a.PARM9,
	a.PARM10
	FROM BEST..TI17CLOPER a

END

IF(@norme_cf = 'I17P')
BEGIN
	iF(@PARM_REQCOD_CT = 'I17PQPOSX' OR @PARM_REQCOD_CT = 'I17PYPOSX')	
		SELECT 
		a.SSD_CF,
		a.ESB_CF,
		a.PARM1,
		a.PARM2,
		a.PARM3,
		a.PARM4,
		a.PARM5,
		a.PARM6,
		a.PARM7,
		a.PARM8,
		a.PARM9,
		a.PARM10
		FROM BEST..TI17CLOPER a
		WHERE a.PARM1='1'
		AND @diff < CAST(a.PARM5 AS INT)
	ELSE
		SELECT 
		a.SSD_CF,
		a.ESB_CF,
		a.PARM1,
		a.PARM2,
		a.PARM3,
		a.PARM4,
		a.PARM5,
		a.PARM6,
		a.PARM7,
		a.PARM8,
		a.PARM9,
		a.PARM10
		FROM BEST..TI17CLOPER a
		WHERE 
		a.PARM1='1'
END

IF(@norme_cf = 'I17L')
BEGIN
	iF(@PARM_REQCOD_CT = 'I17LQPOSX' OR @PARM_REQCOD_CT = 'I17LYPOSX')
		SELECT 
		a.SSD_CF,
		a.ESB_CF,
		a.PARM1,
		a.PARM2,
		a.PARM3,
		a.PARM4,
		a.PARM5,
		a.PARM6,
		a.PARM7,
		a.PARM8,
		a.PARM9,
		a.PARM10
		FROM BEST..TI17CLOPER a
		INNER JOIN BREF.dbo.TBATCHSSD b
	 ON a.SSD_CF = b.SSD_CF
		WHERE b.BATCHUSER_CF = suser_name()
		AND a.PARM2='1'
		AND @diff < CAST(a.PARM5 AS INT)
	ELSE
		SELECT 
		a.SSD_CF,
		a.ESB_CF,
		a.PARM1,
		a.PARM2,
		a.PARM3,
		a.PARM4,
		a.PARM5,
		a.PARM6,
		a.PARM7,
		a.PARM8,
		a.PARM9,
		a.PARM10
		FROM BEST..TI17CLOPER a
		INNER JOIN BREF.dbo.TBATCHSSD b
	 ON a.SSD_CF = b.SSD_CF
		WHERE b.BATCHUSER_CF = suser_name()
		AND a.PARM2='1'
END

IF(@norme_cf = 'I17S')
BEGIN
	SELECT 
	a.SSD_CF,
	a.ESB_CF,
	a.PARM1,
	a.PARM2,
	a.PARM3,
	a.PARM4,
	a.PARM5,
	a.PARM6,
	a.PARM7,
	a.PARM8,
	a.PARM9,
	a.PARM10
	FROM BEST..TI17CLOPER a
	WHERE  a.PARM4='1'
END

select @erreur = @@error
if @erreur != 0
begin
    return @erreur
end

return 0
go

IF OBJECT_ID('dbo.PsTI17CLOPER_SERQ_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTI17CLOPER_SERQ_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTI17CLOPER_SERQ_02 >>>'
go

GRANT EXECUTE ON dbo.PsTI17CLOPER_SERQ_02 TO GOMEGA
go

GRANT EXECUTE ON dbo.PsTI17CLOPER_SERQ_02 TO GDBBATCH
go
