use BEST
go

if object_id('PuTHRHLDLOB_01') is not null
	begin
		drop procedure PuTHRHLDLOB_01
		if object_id('PuTHRHLDLOB_01') is not null
			print '<<< FAILED DROPPING procedure PuTHRHLDLOB_01 >>>'
		else
			print '<<< DROPPED procedure PuTHRHLDLOB_01 >>>'
	end
go

create procedure PuTHRHLDLOB_01
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
    Update FCLODAT_D in BEST..TTHRHLDLOB
Parametres:
 	@p_erreur varchar(64)=null output
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION
/* ------------------------------------------------------------------- */
UPDATE BEST..TTHRHLDLOB
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

if object_id('PuTHRHLDLOB_01') is not null
	print '<<< CREATED PROC PuTHRHLDLOB_01 >>>'
else
	print '<<< FAILED CREATING PROC PuTHRHLDLOB_01 >>>'
go

grant execute on PuTHRHLDLOB_01 TO GOMEGA
go

grant execute on PuTHRHLDLOB_01 TO GDBBATCH
go