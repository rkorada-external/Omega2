use BRET
go

if object_id('PuRETIFRS_02') is not null
	begin
		drop procedure PuRETIFRS_02
		if object_id('PuRETIFRS_02') is not null
			print '<<< FAILED DROPPING procedure PuRETIFRS_02 >>>'
		else
			print '<<< DROPPED procedure PuRETIFRS_02 >>>'
	end
go

create procedure PuRETIFRS_02
  (
		@norme_cf  char(4),
		@user_cf char(4),
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation: 29/04/2020
Description du programme:
    Update data in BRET..TRETIFRS depending on the norme_cf
Parametres:
 	@p_erreur varchar(64)=null output
Modifications
[001] 01/04/2021 filter update by region and and filter on LOB_CF
[002] 03/03/2022 ART Spira 102316 IFRS 17 - Life - Inception status at Booked
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION
/* ------------------------------------------------------------------- */

IF(@norme_cf = 'I17G')
BEGIN
	UPDATE BRET..TRETIFRS
		SET GRPINISTS_CT  = 2, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BRET..TRETIFRS t1
		INNER JOIN BRET..TRETSEC t2 --1
		ON t1.RETCTR_NF = t2.RETCTR_NF AND t1.RTY_NF = t2.RTY_NF --1
		INNER JOIN BREF..TBATCHSSD t3 --1
		ON t2.SSD_CF = t3.SSD_CF --1
		WHERE t1.GRPINISTS_CT = 1 AND t1.GRPFSTCLO_D IS NOT NULL
		AND t3.BATCHUSER_CF= suser_name() --1
END

IF(@norme_cf = 'I17P')
BEGIN
	UPDATE BRET..TRETIFRS
		SET PARINISTS_CT  = 2, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BRET..TRETIFRS t1
		INNER JOIN BRET..TRETSEC t2 --1
		ON t1.RETCTR_NF = t2.RETCTR_NF AND t1.RTY_NF = t2.RTY_NF --1
		INNER JOIN BREF..TBATCHSSD t3 --1
		ON t2.SSD_CF = t3.SSD_CF --1
		WHERE t1.PARINISTS_CT = 1 AND t1.PARFSTCLO_D IS NOT NULL
		AND t3.BATCHUSER_CF= suser_name() --1
END

IF(@norme_cf = 'I17L')
BEGIN
	UPDATE BRET..TRETIFRS
		SET LOCINISTS_CT  = 2, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BRET..TRETIFRS t1
		INNER JOIN BRET..TRETSEC t2 --1
		ON t1.RETCTR_NF = t2.RETCTR_NF AND t1.RTY_NF = t2.RTY_NF --1
		INNER JOIN BREF..TBATCHSSD t3 --1
		ON t2.SSD_CF = t3.SSD_CF --1
		WHERE t1.LOCINISTS_CT = 1 AND t1.LCLFSTCLO_D IS NOT NULL
		AND t3.BATCHUSER_CF= suser_name() --1
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

if object_id('PuRETIFRS_02') is not null
	print '<<< CREATED PROC PuRETIFRS_02 >>>'
else
	print '<<< FAILED CREATING PROC PuRETIFRS_02 >>>'
go

grant execute on PuRETIFRS_02 TO GOMEGA
go

grant execute on PuRETIFRS_02 TO GDBBATCH
go