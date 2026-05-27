USE BEST
GO

IF OBJECT_ID('dbo.PsCTRANO_22') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCTRANO_22
    PRINT '<<< DROPPED PROC dbo.PsCTRANO_22 >>>'
END
GO

/********************************************************************************
PsCTRANO_22
					BEST_PsCTRANO_22.prc

Description :
					Sélection des affaires en anomalies dans CTRANO.
					Description de l'anomalie avec ANO_CT dans TBANTECL
					pour les anomalies sur écriture de service = (ANO_CT = 17 à 25)

Parametres :
					ssd_cf 	integer	: filiale
					usr_cf		char(4)	: Identification de l'utilisateur
					lag_cf		char(1)	: langue de l'utilisateur

Valeurs de retour :
					0: 	OK
					-1:	Echec

Conditions d'execution : 

Commentaires :

Historique :
001	PADB	11/05/1998	version 1.00  Création
002 O.GIRAUX 14/01/2003 Récupératiopn du num de ligne
********************************************************************************/
CREATE PROCEDURE PsCTRANO_22
(
	@ssd_cf 	integer,
	@usr_cf	char(4),
	@lag_cf	char(1)
)
AS
BEGIN

	SELECT
        TCTRANO.NUMLINE_NT,           --MOD02 OG
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
		( TCTRANO.VRS_NF = 1 ) AND
		( TCTRANO.SEG_NF = @usr_cf ) AND
		( TCTRANO.SEGTYP_CT = "A" ) AND
		( BREF..TBANTECL.COL_LS = "ANO_CT" ) AND
		( convert(char(5),TCTRANO.ANO_CT) = BREF..TBANTECL.COLVAL_CT ) AND
		( BREF..TBANTECL.LAG_CF = @lag_cf )
    order by NUMLINE_NT        --MOD02 OG

RETURN 0
		
END 
GO

IF OBJECT_ID('dbo.PsCTRANO_22') IS NOT NULL
	PRINT '<<< CREATED PROC dbo.PsCTRANO_22 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCTRANO_22 >>>'
GO

GRANT EXECUTE ON dbo.PsCTRANO_22 TO GOMEGA
go
