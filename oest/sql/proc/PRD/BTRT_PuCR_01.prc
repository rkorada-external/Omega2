use BTRT
go

if object_id('PuCR_01') is not null
	begin
		drop procedure PuCR_01
		if object_id('PuCR_01') is not null
			print '<<< FAILED DROPPING procedure PuCR_01 >>>'
		else
			print '<<< DROPPED procedure PuCR_01 >>>'
	end
go

create procedure PuCR_01
  (
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BTRT
Version: 1
Auteur: AGD
Date de creation: 19/09/2019
Description du programme:
    Update data in BTRT..TCR using data from BTRAV..ESFD8000_TCR
Parametres:
 	@p_erreur varchar(64)=null output
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION

/* ------------------------------------------------------------------- */
 
	UPDATE BTRT..TCR
	SET B.GRPFIRCLO_D = A.GRPFIRCLO_D,
		B.PARFIRCLO_D = A.PARFIRCLO_D,
		B.LOCFIRCLO_D = A.LOCFIRCLO_D,
		B.LSTUPD_D = A.LSTUPD_D,
		B.LSTUPDUSR_CF = A.LSTUPDUSR_CF
	FROM BTRAV..ESFD8000_TCR A, BTRT..TCR B 
	WHERE A.CR_NF = B.CR_NF
	AND A.CRUWY_NF = B.CRUWY_NF
	AND A.CRUW_NT = B.CRUW_NT
	AND A.CTRTYP_CT = 'TRT'
	AND ((A.GRPFIRCLO_D <> B.GRPFIRCLO_D OR (B.GRPFIRCLO_D IS NULL AND A.GRPFIRCLO_D IS NOT NULL))
	OR (A.PARFIRCLO_D <> B.PARFIRCLO_D OR (B.GRPFIRCLO_D IS NULL AND A.GRPFIRCLO_D IS NOT NULL))
	OR (A.LOCFIRCLO_D <> B.LOCFIRCLO_D OR (B.GRPFIRCLO_D IS NULL AND A.GRPFIRCLO_D IS NOT NULL)))

/* ------------------------------------------------------------------- */

select @erreur = @@error
if @erreur != 0
	begin
		goto err
	end

COMMIT TRAN
return 0

err:
	ROLLBACK TRANSACTION
	return @erreur

end
go

if object_id('PuCR_01') is not null
	print '<<< CREATED PROC PuCR_01 >>>'
else
	print '<<< FAILED CREATING PROC PuCR_01 >>>'
go

grant execute on PuCR_01 TO GOMEGA
go

grant execute on PuCR_01 TO GDBBATCH
go