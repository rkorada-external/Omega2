USE BREF
GO

SET NOCOUNT ON

-- ######################################################################################################################################
-- Script           			: EST_SPIRA85857_MESSAGE.sql
-- Domaine          			: OEST
-- Author           			: KBAGWE
-- Date of creation 			: 08/04/2020
-- Spira						: 85857-New message for EST
-- ######################################################################################################################################


 
declare	@gCommit	VARCHAR(01)
declare @gTodayD	datetime
declare @err	int 
declare @errmsg	char(150), @usr char(4)
SELECT @gCommit		= 'Y'  --used for debug, Y means commit and N means rollback 
SELECT @gTodayD = getdate(), @usr = 'INF0'



BEGIN TRAN
print "Begin Tran"
SELECT "Before Delete ", * FROM BREF..TMESSAGE WHERE MESS_N = 30116 AND MESSTHM_C = "ESTIMATION" AND LANG_C in ("E","F")

DELETE BREF..TMESSAGE WHERE MESS_N = 30116 AND MESSTHM_C = "ESTIMATION" AND LANG_C in ("E","F")


INSERT INTO BREF..TMESSAGE 
(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
VALUES ('E','ESTIMATION',30116,'Import is not possible for Upload Type § and Contract Type §',1, 0)


SELECT @err=@@error, @errmsg = "Insert error : BREF..TMESSAGE LAG=E" 

IF (@err =0 )
BEGIN

INSERT INTO BREF..TMESSAGE 
(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
VALUES ('F','ESTIMATION',30116,'Importation impossible pour le Type de Chargement § et le Type de Contrat §',1, 0)


SELECT @err=@@error, @errmsg = "Insert error : BREF..TMESSAGE LAG=F" 

END



IF (@err !=0 )
BEGIN
	SELECT @err, @errmsg
	print "ROLLBACK TRAN"
	ROLLBACK TRAN
END
ELSE
BEGIN
	print "COMMTT TRAN"		
	COMMIT TRAN
	SELECT * FROM BREF..TMESSAGE WHERE MESS_N = 30116 AND MESSTHM_C = "ESTIMATION" AND LANG_C in ("E","F")
END

GO
