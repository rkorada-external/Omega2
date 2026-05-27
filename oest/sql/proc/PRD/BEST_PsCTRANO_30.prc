USE BEST
Go

IF OBJECT_ID('dbo.PsCTRANO_30') IS NOT NULL
    BEGIN
        DROP PROCEDURE dbo.PsCTRANO_30
        IF OBJECT_ID('dbo.PsCTRANO_30') IS NOT NULL
            PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCTRANO_30 >>>'
        ELSE
            PRINT '<<< DROPPED PROCEDURE dbo.PsCTRANO_30 >>>'
    END
go

CREATE PROCEDURE PsCTRANO_30 (
	@ssd_cf 	integer,
	@usr_cf	char(4),
	@lag_cf	char(1))

AS

/********************************************************************************
PsCTRANO_30
Description :
Parametres              : ssd_cf 	integer	: filiale
			              usr_cf		char(4)	: Identification de l'utilisateur
			              lag_cf		char(1)	: langue de l'utilisateur
Valeurs de retour       :  0 : 	OK
					      -1 :	Echec
Conditions d'execution  : 
Commentaires            :
_________________
MODIFICATION            : 1
Auteur                  : G.BUISSON
Date                    : 01/06/2005
Version                 : V05.1
Description             : Spot 10543 : On ajoute l'EX et l'AC du mouvement dans 
                          les anomalies

********************************************************************************/

SELECT  TCTRANO.NUMLINE_NT,
		TCTRANO.CTR_NF,
		TCTRANO.END_NT,
		TCTRANO.SEC_NF,
		TCTRANO.SEG_NF,
		TMESSAGE.MESS_L,
		TCTRANO.UWY_NF,
		TCTRANO.ACY_NF
FROM    TCTRANO TCTRANO, BREF..TMESSAGE TMESSAGE
WHERE   TCTRANO.SSD_CF     = @ssd_cf 
AND     TCTRANO.SEG_NF     = @usr_cf 
AND     TCTRANO.SEGTYP_CT  = "L" 
AND     TMESSAGE.MESS_N    = TCTRANO.ANO_CT 
AND     TMESSAGE.LANG_C    = @lag_cf 
AND     TMESSAGE.MESSTHM_C = "ESTIMATION"
		
RETURN 0
go

GRANT EXECUTE ON dbo.PsCTRANO_30 TO GOMEGA
go

IF OBJECT_ID('dbo.PsCTRANO_30') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCTRANO_30 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCTRANO_30 >>>'
go

EXEC sp_procxmode 'dbo.PsCTRANO_30','unchained'
go
