USE BEST
go

IF OBJECT_ID('TI17CTRINFO_01') IS NOT NULL
	BEGIN
		DROP PROCEDURE TI17CTRINFO_01
		IF OBJECT_ID('TI17CTRINFO_01') IS NOT NULL
			PRINT '<<< FAILED DROPPING PROCEDURE TI17CTRINFO_01 >>>'
		ELSE
			PRINT '<<< DROPPED PROCEDURE TI17CTRINFO_01 >>>'
	END
go

create procedure TI17CTRINFO_01 
  (
  @p_closingd datetime,
  @p_usr_cf UUSR_CF,
  @p_credate datetime,
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/*
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: Charles socie
Date de creation: 12/03/2021
Description du programme:
    insert data from BTRAV_ESFD4040_TI17CTRINFO_01 to BEST_TI17CTRINFO_01
Parametres:
    @p_erreur       varchar(64)=null output 
*/

declare @erreur int

BEGIN TRANSACTION

/* ------------------------------------------------------------------- */ 
		
DELETE FROM BEST..TI17CTRINFO
WHERE CLODAT_D = @p_closingd and CREUSR_CF = @p_usr_cf

PRINT '%1! row(s) delete in BEST..TI17CTRINFO ', @@rowcount

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


go

if object_id('TI17CTRINFO_01') is not null
  print '<<< CREATED PROC TI17CTRINFO_01 >>>'
else
  print '<<< FAILED CREATING PROC TI17CTRINFO_01 >>>'
go

grant execute on TI17CTRINFO_01 TO GOMEGA
go

grant execute on TI17CTRINFO_01 TO GDBBATCH
go
