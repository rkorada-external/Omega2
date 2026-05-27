use BEST
go

IF OBJECT_ID ('dbo.PdCTRANO_07') IS NOT NULL
   BEGIN
      DROP PROCEDURE dbo.PdCTRANO_07

      IF OBJECT_ID ('dbo.PdCTRANO_07') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE dbo.PdCTRANO_07 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE dbo.PdCTRANO_07 >>>'
   END
go

/***** create procedure dbo.PdCTRANO_07 *****/
create procedure dbo.PdCTRANO_07
(
	@p_ssd_cf	USSD_CF,
	@p_usr_cf	UUSR_CF
)
as
/********************************************************************************
PdCTRANO_07

Description :
					Remove the anomalies from previous uploads in TCTRANO.
					This procedure is used for New Business upload

Parametres :
					@p_ssd_cf 	integer	: subsidiary
					@p_usr_cf	char(4)	: user ID

Valeurs de retour :
					0: 	OK
					-1:	Failure

Conditions d'execution : 

Commentaires :

Historique :
001	P.-E. Marx (Capgemini)	10/12/2015	version 1.00  Creation
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
		( TCTRANO.SEGTYP_CT = "N" ) 

select @nbligne = @@rowcount
select @nbligne

	RETURN @erreur
END


 


EXEC sp_procxmode 'dbo.PdCTRANO_07', 'unchained'
go

IF OBJECT_ID ('dbo.PdCTRANO_07') IS NOT NULL
   PRINT '<<< CREATED PROCEDURE dbo.PdCTRANO_07 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROCEDURE dbo.PdCTRANO_07 >>>'
go

GRANT EXECUTE ON dbo.PdCTRANO_07 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdCTRANO_07 TO GDBBATCH
go
