USE BEST
GO

IF OBJECT_ID('dbo.PdCTRANO_05') IS NOT NULL
BEGIN
    DROP PROC dbo.PdCTRANO_05
    PRINT '<<< DROPPED PROC dbo.PdCTRANO_05 >>>'
END
GO

/********************************************************************************
PdCTRANO_05
					oest/V1_0/work/sql/proc/esdctr05.prc

Description :
					Suppression du suivi des affaires en anomalies dans CTRANO.
					Pour le suivi des écritures de service

Parametres :
					@p_ssd_cf 	integer	: filiale
					@p_usr_cf		char(4)	: Identification de l'utilisateur

Valeurs de retour :
					0: 	OK
					-1:	Echec

Conditions d'execution : 

Commentaires :

Historique :
001	PADB	17/07/1998	version 1.00  Création
002 HR      19/01/2026  US8023 SERQS - one AE load may create AE on several ssd instead of 1 => abnomalies should be retrieved for all regarded ssd
********************************************************************************/
CREATE PROCEDURE PdCTRANO_05
(
	@p_usr_cf	char(4)
)
AS
BEGIN

declare @erreur int,
 	  @nbligne  int
        
select @erreur = 0


/* ---------------------------------------------------------------------
   purge des tables TRESSUM, TIPPORT, TCALPRE, TEARIPP, TLOARAT, TPRMLOA
   --------------------------------------------------------------------- */

	SELECT @erreur = @@error

	DELETE
		TCTRANO
	WHERE
		( TCTRANO.VRS_NF = 1 ) AND
		( TCTRANO.SEG_NF = @p_usr_cf ) AND
		( TCTRANO.SEGTYP_CT = "A" ) 

select @nbligne = @@rowcount
select @nbligne

	RETURN @erreur
END
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDCTR05', 'PdCTRANO_05', 'BEST', 'ME31'
go
		

IF OBJECT_ID('dbo.PdCTRANO_05') IS NOT NULL
BEGIN
	GRANT EXECUTE ON dbo.PdCTRANO_05 TO GOMEGA
	PRINT '<<< CREATED PROC dbo.PdCTRANO_05 >>>'
END
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PdCTRANO_05 >>>'
GO

GRANT EXECUTE ON dbo.PdCTRANO_05 TO GOMEGA
go

GRANT EXECUTE ON dbo.PdCTRANO_05 TO GDBBATCH
go
