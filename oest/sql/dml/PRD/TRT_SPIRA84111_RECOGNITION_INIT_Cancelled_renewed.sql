USE BREF
GO

SET NOCOUNT ON

-- ######################################################################################################################################
-- Script           			: TRT_SPIRA84111_RECOGNITION_INIT.sql
-- Domaine          			: OTRT
-- Author           			: KBAGWE
-- Date of creation 			: 01/04/2020
-- Last update					: Addition of "Renewed" and "Cancelled" contrat status
-- Last update date				: 27/10/2020 
-- Last update author			: Romain Flouquet
-- ######################################################################################################################################


 
declare	@gCommit	VARCHAR(01)
declare @gTodayD	datetime
declare @err	int, @btrt_row int , @bfac_row int
declare @errmsg	char(150), @usr char(4)
SELECT @gCommit		= 'Y'  --used for debug, Y means commit and N means rollback 
SELECT @gTodayD = getdate(), @usr = 'INF0'



/*
SELECT "BTRT",  B.CTR_NF, B.UWY_NF, B.UW_NT, B.END_NT, B.SEC_NF, B.RECOD_D, B.LSTUPD_D, B.LSTUPDUSR_CF FROM BTRT..TCONTR A,BTRT..TSECIFRS B,BTRT..TSECTION C 
WHERE A.CTRSTS_CT IN (14,16,17,19) AND 
	A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT AND A.END_NT =B.END_NT AND 
	A.CTR_NF = C.CTR_NF AND A.UWY_NF = C.UWY_NF AND A.UW_NT = C.UW_NT AND A.END_NT =C.END_NT AND
	B.SEC_NF = C.SEC_NF AND B.RECOD_D = NULL
union
SELECT "BFAC",  B.CTR_NF, B.UWY_NF, B.UW_NT, B.END_NT, B.SEC_NF, B.RECOD_D, B.LSTUPD_D, B.LSTUPDUSR_CF 
FROM BFAC..TCONTR A,BFAC..TSECIFRS B,BFAC..TSECTION C WHERE A.CTRSTS_CT IN (14,16,17,19) AND 
	A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT AND A.END_NT =B.END_NT AND 
	A.CTR_NF = C.CTR_NF AND A.UWY_NF = C.UWY_NF AND A.UW_NT = C.UW_NT AND A.END_NT =C.END_NT AND
	B.SEC_NF = C.SEC_NF AND B.DIV_NT= C.DIV_NT  AND B.RECOD_D = NULL

*/

BEGIN TRAN
print "Begin Tran"

UPDATE BTRT..TSECIFRS
SET RECOD_D = C.SECINC_D,
	LSTUPD_D = @gTodayD,
	LSTUPDUSR_CF = @usr
FROM BTRT..TCONTR A,BTRT..TSECIFRS B,BTRT..TSECTION C WHERE A.CTRSTS_CT IN (14,16,17,19) AND 
A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT AND A.END_NT =B.END_NT AND 
A.CTR_NF = C.CTR_NF AND A.UWY_NF = C.UWY_NF AND A.UW_NT = C.UW_NT AND A.END_NT =C.END_NT AND
B.SEC_NF = C.SEC_NF AND B.RECOD_D = NULL

SELECT @err=@@error, @errmsg = "Update error : BTRT..TSECIFRS", @btrt_row = @@rowcount

IF (@err =0 )
BEGIN

UPDATE BFAC..TSECIFRS
SET RECOD_D = C.SECINC_D,
	LSTUPD_D = @gTodayD,
	LSTUPDUSR_CF = @usr
FROM BFAC..TCONTR A,BFAC..TSECIFRS B,BFAC..TSECTION C WHERE A.CTRSTS_CT IN (14,16,17,19) AND 
A.CTR_NF = B.CTR_NF AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT AND A.END_NT =B.END_NT AND 
A.CTR_NF = C.CTR_NF AND A.UWY_NF = C.UWY_NF AND A.UW_NT = C.UW_NT AND A.END_NT =C.END_NT AND
B.SEC_NF = C.SEC_NF AND B.DIV_NT= C.DIV_NT AND B.RECOD_D = NULL

SELECT @err=@@error, @errmsg = "Update error : BFAC..TSECIFRS", @bfac_row = @@rowcount

END



SELECT "BTRT",  B.CTR_NF, B.UWY_NF, B.UW_NT, B.END_NT, B.SEC_NF, B.RECOD_D, B.LSTUPD_D, B.LSTUPDUSR_CF FROM BTRT..TSECIFRS B 
	WHERE  LSTUPD_D = @gTodayD AND LSTUPDUSR_CF = @usr
union
SELECT "BFAC",  B.CTR_NF, B.UWY_NF, B.UW_NT, B.END_NT, B.SEC_NF, B.RECOD_D, B.LSTUPD_D, B.LSTUPDUSR_CF FROM BFAC..TSECIFRS B
	WHERE  LSTUPD_D = @gTodayD AND LSTUPDUSR_CF = @usr




IF (@err !=0 )
BEGIN
	SELECT @err, @errmsg
	print "ROLLBACK TRAN"
	ROLLBACK TRAN
END
ELSE
BEGIN
    SELECT "ROWS UPDATED IN BTRT_TSECIFRS = " , @btrt_row
    SELECT "ROWS UPDATED IN BFAC_TSECIFRS = " , @bfac_row
	
	IF (@gCommit = "Y")
	BEGIN
		print "COMMTT TRAN"		
		COMMIT TRAN
	END
	ELSE
	BEGIN
		PRINT "DEBUG MODE IS ON..ROLLBACK TRAN"
		ROLLBACK TRAN		
	END
END

GO
