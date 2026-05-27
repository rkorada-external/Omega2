USE BEST
GO

IF OBJECT_ID('dbo.PsSEGANO_22') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSEGANO_22
    PRINT '<<< DROPPED PROC dbo.PsSEGANO_22 >>>'
END
GO

/********************************************************************************
PsSEGANO_22
					oest/work/sql/proc/essseg22.prc

Description :
					Sélection des segments en anomalies dans SEGANO.
					Description de l'anomalie avec ANO_CT dans TBANTECL

Parametres :
					ssd_cf 	integer	: filiale
					vers_nf	numeric	: Numéro de version
					segtyp_ct	char(1)   	: type de segment (A ou E)
					lag_cf		char(1)	: langue de l'utilisateur

Valeurs de retour :
					0: 	OK
					-1:	Echec

Conditions d'execution : 

Commentaires :

Historique :
001	PADB	23/07/1998	version 1.00  Création
********************************************************************************/
CREATE PROCEDURE PsSEGANO_22
(
	@ssd_cf 	integer,
	@vers_nf	numeric (10,0),
	@segtyp_ct	char(1),
	@lag_cf	char(1)
)
AS
BEGIN

	IF (@vers_nf = 0)
		SELECT 
			@vers_nf = max(VRS_NF)
		FROM
			TVERSION
		WHERE
			( SSD_CF = @ssd_cf  ) AND
			( SEGTYP_CT = @segtyp_ct )
	
	SELECT
		TSEGANO.SEG_NF,
		TSEGANO.UWY_NF,
		BREF..TBANTECL.COLVAL_LM
	FROM
		TSEGANO,
		BREF..TBANTECL
	WHERE
		( TSEGANO.SSD_CF = @ssd_cf  ) AND
		( TSEGANO.VRS_NF = @vers_nf ) AND
		( TSEGANO.SEGTYP_CT = @segtyp_ct ) AND
		( BREF..TBANTECL.COL_LS = "ANO_CT" ) AND
		( convert(char(5),TSEGANO.ANO_CT) = BREF..TBANTECL.COLVAL_CT ) AND
		( BREF..TBANTECL.LAG_CF = @lag_cf )

RETURN 0
		
END 
GO

IF OBJECT_ID('dbo.PsSEGANO_22') IS NOT NULL
BEGIN
GRANT EXECUTE ON dbo.PsSEGANO_22 TO GOMEGA
PRINT '<<< CREATED PROC dbo.PsSEGANO_22 >>>'
END
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSEGANO_22 >>>'
GO
