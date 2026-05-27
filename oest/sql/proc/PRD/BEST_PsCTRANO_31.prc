USE BEST
Go

go
IF OBJECT_ID('dbo.PsCTRANO_31') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsCTRANO_31
    IF OBJECT_ID('dbo.PsCTRANO_31') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCTRANO_31 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsCTRANO_31 >>>'
END
go
/********************************************************************************
PsCTRANO_31
					

Description :
					

Parametres :
					ssd_cf 	integer	: filiale
					usr_cf		char(4)	: Identification de l'utilisateur
					lag_cf		char(1)	: langue de l'utilisateur

Valeurs de retour :

Conditions d'execution : 

Commentaires :

Historique :

********************************************************************************/
CREATE PROCEDURE PsCTRANO_31
(
	@p_ssd_cf	integer,
	@p_usr_cf	char(4)
)
AS
BEGIN


declare @ret int

select @ret = 0 -- par defaut, on considere qu'il n'y a pas d'ano bloquante


select @ret = count(*)
FROM
	TCTRANO TCTRANO,
	BREF..TMESSAGE TMESSAGE
WHERE
		TCTRANO.SSD_CF = @p_ssd_cf AND
		( TCTRANO.SEG_NF = @p_usr_cf ) AND
		( TCTRANO.SEGTYP_CT = "L" ) AND
		( TMESSAGE.MESS_N = TCTRANO.ANO_CT) AND
		( TMESSAGE.MESSTHM_C = "ESTIMATION" ) AND
		( TMESSAGE.LANG_C = "F") AND -- peu importe la langue, c'est juste pour compter
		( TMESSAGE.ICON_T = 1) -- bloquante

select @ret
		
RETURN 0
		
END
go
GRANT EXECUTE ON dbo.PsCTRANO_31 TO GOMEGA
go
IF OBJECT_ID('dbo.PsCTRANO_31') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCTRANO_31 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCTRANO_31 >>>'
go
EXEC sp_procxmode 'dbo.PsCTRANO_31','unchained'
go
