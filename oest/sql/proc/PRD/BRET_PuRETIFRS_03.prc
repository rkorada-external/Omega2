use BRET
go

if object_id('PuRETIFRS_03') is not null
	begin
		drop procedure PuRETIFRS_03
		if object_id('PuRETIFRS_03') is not null
			print '<<< FAILED DROPPING procedure PuRETIFRS_03 >>>'
		else
			print '<<< DROPPED procedure PuRETIFRS_03 >>>'
	end
go

create procedure PuRETIFRS_03
  (
	@norme_cf  char(4),
	@p_erreur varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: Charles Socie
Date de creation: 25/06/2020
Description du programme:
    Update lines in the table BRET..TRETIFRS using data from the tmp table BTRAV..ESFD8000_TRETIFRS
Parametres:
 	@p_erreur varchar(64)=null output
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION
/* ------------------------------------------------------------------- */

IF(@norme_cf = 'I17G')
BEGIN
	UPDATE BRET..TRETIFRS
		SET B.GRPRATEINDEX_CT = A.GRPRATEINDEX_CT,
			B.LSTUPD_D = A.LSTUPD_D,
			B.LSTUPDUSR_CF = A.LSTUPDUSR_CF,
			B.GRPINISTS_CT = ISNULL(A.GRPINISTS_CT, 0)
		FROM BTRAV..ESFD8000_TRETIFRS A, BRET..TRETIFRS B 
		WHERE A.RETCTR_NF = B.RETCTR_NF
		AND A.RTY_NF = B.RTY_NF
		OR (A.GRPRATEINDEX_CT <> B.GRPRATEINDEX_CT OR (B.GRPRATEINDEX_CT IS NULL AND A.GRPRATEINDEX_CT IS NOT NULL))
		OR (A.GRPINISTS_CT <> B.GRPINISTS_CT OR (B.GRPINISTS_CT IS NULL AND A.GRPINISTS_CT IS NOT NULL))
END

IF(@norme_cf = 'I17P')
BEGIN
	UPDATE BRET..TRETIFRS
		SET B.PARRATEINDEX_CT = A.PARRATEINDEX_CT,
			B.LSTUPD_D = A.LSTUPD_D,
			B.LSTUPDUSR_CF = A.LSTUPDUSR_CF,
			B.PARINISTS_CT = ISNULL(A.PARINISTS_CT, 0)
		FROM BTRAV..ESFD8000_TRETIFRS A, BRET..TRETIFRS B 
		WHERE A.RETCTR_NF = B.RETCTR_NF
		AND A.RTY_NF = B.RTY_NF
		OR (A.PARRATEINDEX_CT <> B.PARRATEINDEX_CT OR (B.PARRATEINDEX_CT IS NULL AND A.PARRATEINDEX_CT IS NOT NULL))
		OR (A.PARINISTS_CT <> B.PARINISTS_CT OR (B.PARINISTS_CT IS NULL AND A.PARINISTS_CT IS NOT NULL))
END

IF(@norme_cf = 'I17L')
BEGIN
	UPDATE BRET..TRETIFRS
		SET B.LCLRATEINDEX_CT = A.LCLRATEINDEX_CT,
			B.LSTUPD_D = A.LSTUPD_D,
			B.LSTUPDUSR_CF = A.LSTUPDUSR_CF,
			B.LOCINISTS_CT = ISNULL(A.LOCINISTS_CT, 0)
		FROM BTRAV..ESFD8000_TRETIFRS A, BRET..TRETIFRS B 
		WHERE A.RETCTR_NF = B.RETCTR_NF
		AND A.RTY_NF = B.RTY_NF
		OR (A.LCLRATEINDEX_CT <> B.LCLRATEINDEX_CT OR (B.LCLRATEINDEX_CT IS NULL AND A.LCLRATEINDEX_CT IS NOT NULL))
		OR (A.LOCINISTS_CT <> B.LOCINISTS_CT OR (B.LOCINISTS_CT IS NULL AND A.LOCINISTS_CT IS NOT NULL))
END



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

if object_id('PuRETIFRS_03') is not null
	print '<<< CREATED PROC PuRETIFRS_03 >>>'
else
	print '<<< FAILED CREATING PROC PuRETIFRS_03 >>>'
go

grant execute on PuRETIFRS_03 TO GOMEGA
go

grant execute on PuRETIFRS_03 TO GDBBATCH
go