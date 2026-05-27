USE BEST
GO

/* *********************************************************************************************************************** 	*/
/*                                                                                                                         	*/
/* 	   					Mise à jour TI17REQ SPIRA 105764															    */
/*																															*/
/* ************************************************************************************************************************	*/

DECLARE @MSG VARCHAR(100)
SELECT @MSG = @@SERVERNAME + ' => ' + HOST_NAME() + ' DEBUT SPIRA105764 ' + CONVERT(CHAR(9), GETDATE(), 6) + ' ' + CONVERT(CHAR(9), GETDATE(), 8)
PRINT @MSG
GO

BEGIN

    DECLARE @erreur         int
          , @trans_etat     int
       
	BEGIN TRAN

			-- mise à jour --
 			   Update BEST..TI17REQ
				Set    REQCOD_LL		= 'POST OMEGA LOCAL'
				From   BEST..TI17REQ a
				Where  a.REQCOD_CT = 'Y'
	
			-- récuperer codes retour update --
			   SELECT @erreur = @@error, @trans_etat = @@transtate
			   IF @erreur != 0 OR @trans_etat > 1
				  BEGIN
					   PRINT 'MAJ BEST..TI17REQ - ERREUR : %1!',@erreur
					   ROLLBACK TRAN
					   GOTO fin
				  END
	 
			-- mise à jour --
 			   Update BEST..TI17REQ
				Set    REQCOD_LL		= 'Annual POC IFRS 17 Local booking'
				From   BEST..TI17REQ a
				Where  a.REQCOD_CT = 'I17LYPOCB'
	
			-- récuperer codes retour update --
			   SELECT @erreur = @@error, @trans_etat = @@transtate
			   IF @erreur != 0 OR @trans_etat > 1
				  BEGIN
					   PRINT 'MAJ BEST..TI17REQ - ERREUR : %1!',@erreur
					   ROLLBACK TRAN
					   GOTO fin
				  END

			-- mise à jour --
 			   Update BEST..TI17REQ
				Set    REQCOD_LL		= 'Yearly POC IFRS 17 Parent'
				From   BEST..TI17REQ a
				Where  a.REQCOD_CT = 'I17PYPOC'
	
			-- récuperer codes retour update --
			   SELECT @erreur = @@error, @trans_etat = @@transtate
			   IF @erreur != 0 OR @trans_etat > 1
				  BEGIN
					   PRINT 'MAJ BEST..TI17REQ - ERREUR : %1!',@erreur
					   ROLLBACK TRAN
					   GOTO fin
				  END

			-- mise à jour --
 			   Update BEST..TI17REQ
				Set    REQCOD_LL		= 'Annual POS IFRS 17 Parent booking'
				From   BEST..TI17REQ a
				Where  a.REQCOD_CT = 'I17PYPOSB'
	
			-- récuperer codes retour update --
			   SELECT @erreur = @@error, @trans_etat = @@transtate
			   IF @erreur != 0 OR @trans_etat > 1
				  BEGIN
					   PRINT 'MAJ BEST..TI17REQ - ERREUR : %1!',@erreur
					   ROLLBACK TRAN
					   GOTO fin
				  END

	COMMIT TRAN

fin:
END
GO

Declare @msg Char(100)
Select @msg = @@servername + ' => ' + Host_Name() + ' Fin SPIRA105764 ' + Convert(Char(9), GetDate(), 6) + ' ' + Convert(Char(9), GetDate(), 8)
Print  @msg
go
