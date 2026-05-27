use BEST
go

if object_id('PuUOASII_01') is not null
	begin
		drop procedure PuUOASII_01
		if object_id('PuUOASII_01') is not null
			print '<<< FAILED DROPPING procedure PuUOASII_01 >>>'
		else
			print '<<< DROPPED procedure PuUOASII_01 >>>'
	end
go

create procedure PuUOASII_01
  (
		@closing_date  char(8),
		@norme_cf char(4),
		@user_cf char(4),
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine: (ES) Estimation
Base principale: BEST
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation: 10/04/2020
Description du programme:
    Update FCLODAT_D in BEST..TUOASII
Parametres:
 	@p_erreur varchar(64)=null output
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION
/* ------------------------------------------------------------------- */
UPDATE BEST..TUOASII
SET FCLODAT_D = @closing_date, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
WHERE FCLODAT_D IS NULL AND NORME_CF = @norme_cf

/* ------------------------------------------------------------------- */

select @erreur = @@error
if @erreur != 0
	begin
		goto err
	end

COMMIT TRANSACTION
return 0

err:
	ROLLBACK TRANSACTION
	return @erreur

end
go

if object_id('PuUOASII_01') is not null
	print '<<< CREATED PROC PuUOASII_01 >>>'
else
	print '<<< FAILED CREATING PROC PuUOASII_01 >>>'
go

grant execute on PuUOASII_01 TO GOMEGA
go

grant execute on PuUOASII_01 TO GDBBATCH
go