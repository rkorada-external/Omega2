USE BEST
GO

IF OBJECT_ID('dbo.PsCTRANO_21') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCTRANO_21
    PRINT '<<< DROPPED PROC dbo.PsCTRANO_21 >>>'
END
GO

/********************************************************************************
PsCTRANO_21
					oest/V1_0/work/sql/proc/segment/essctr21.prc

Description :
					Sélection des affaires en anomalies dans CTRANO.
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
001	PADB	11/05/1998	version 1.00  Création
********************************************************************************/
CREATE PROCEDURE PsCTRANO_21
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
		TCTRANO.CTR_NF,
		TCTRANO.END_NT,
		TCTRANO.SEC_NF,
		TCTRANO.SEG_NF,
		BREF..TBANTECL.COLVAL_LM
	FROM
		TCTRANO,
		BREF..TBANTECL
	WHERE
		( TCTRANO.SSD_CF = @ssd_cf  ) AND
		( TCTRANO.VRS_NF = @vers_nf ) AND
		( TCTRANO.SEGTYP_CT = @segtyp_ct ) AND
		( BREF..TBANTECL.COL_LS = "ANO_CT" ) AND
		( convert(char(1),TCTRANO.ANO_CT) = BREF..TBANTECL.COLVAL_CT ) AND
		( BREF..TBANTECL.LAG_CF = @lag_cf )

RETURN 0
		
END 
GO

IF OBJECT_ID('dbo.PsCTRANO_21') IS NOT NULL
BEGIN
	GRANT EXECUTE ON dbo.PsCTRANO_21 TO GOMEGA
	PRINT '<<< CREATED PROC dbo.PsCTRANO_21 >>>'
END
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCTRANO_21 >>>'
GO
