USE BEST
go
IF OBJECT_ID('dbo.PdCTRANO_06_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PdCTRANO_06_O2
    IF OBJECT_ID('dbo.PdCTRANO_06_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdCTRANO_06_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PdCTRANO_06_O2 >>>'
END
go
create procedure PdCTRANO_06_O2
(
	@p_ssd_cf	USSD_CF,
	@p_usr_cf	UUSR_CF
)
with execute as caller as
/********************************************************************************
PdCTRANO_06_O2

Description :
					Suppression du suivi des affaires en anomalies dans CTRANO.
					Pour le suivi des écritures de service plan

Parametres :
					@p_ssd_cf 	integer	: filiale
					@p_usr_cf	char(4)	: Identification de l'utilisateur

Valeurs de retour :
					0: 	OK
					-1:	Echec

Conditions d'execution : 

Commentaires :

Historique :
001	P.-E. Marx (Capgemini)	23/02/2015	version 1.00  Création
********************************************************************************/
BEGIN

declare @erreur int,
		@nbligne  smallint
        
select @erreur = 0


/* ---------------------------------------------------------------------
   purge de la table d'erreurs
   --------------------------------------------------------------------- */

	SELECT @erreur = @@error

	DELETE
		TCTRANO
	WHERE
		( TCTRANO.SSD_CF = @p_ssd_cf  ) AND
		( TCTRANO.VRS_NF = 1 ) AND
		( TCTRANO.SEG_NF = @p_usr_cf ) AND
		( TCTRANO.SEGTYP_CT = "P" ) 

select @nbligne = @@rowcount
select @nbligne

	RETURN @erreur
END
go

EXEC sp_procxmode 'dbo.PdCTRANO_06_O2', 'unchained'
go
IF OBJECT_ID('dbo.PdCTRANO_06_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PdCTRANO_06_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PdCTRANO_06_O2 >>>'
go
GRANT EXECUTE ON dbo.PdCTRANO_06_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdCTRANO_06_O2 TO GDBBATCH
go
