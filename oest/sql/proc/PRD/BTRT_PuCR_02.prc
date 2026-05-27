use BTRT
go

if object_id('PuCR_02') is not null
	begin
		drop procedure PuCR_02
		if object_id('PuCR_02') is not null
			print '<<< FAILED DROPPING procedure PuCR_02 >>>'
		else
			print '<<< DROPPED procedure PuCR_02 >>>'
	end
go

create procedure PuCR_02
  (
		@norme_cf  char(4),
  @closing_date char(8),
		@user_cf char(4),
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BTRT
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation: 10/04/2020
Description du programme:
    Update data in BTRT..TCR using first closing date depending on the norme_cf
Parametres:
 	@p_erreur varchar(64)=null output
Modifications
[001] 31/03/2021 filter update by region and and filter on LOB_CF
[002] 03/03/2022 ART Spira 102316 IFRS 17 - Life - Inception status at Booked
*****************************************************/

begin

declare 
@user_name varchar(20),
@erreur int

BEGIN TRANSACTION
SELECT @user_name=suser_name()
/* ------------------------------------------------------------------- */
IF(@norme_cf = 'I17G')
BEGIN
	UPDATE BTRT..TCR
		SET GRPFIRCLO_D = @closing_date, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BTRT..TCR t1
		INNER JOIN BTRT..TCRCONTR t2
		ON t1.CR_NF = t2.CR_NF AND t1.CRUWY_NF = t2.CRUWY_NF AND t1.CRUW_NT = t2.CRUW_NT
		INNER JOIN BTRT..TSECIFRS t3
		ON t2.CTR_NF = t3.CTR_NF AND t2.UWY_NF = t3.UWY_NF AND t2.UW_NT = t3.UW_NT AND t2.END_NT = t3.END_NT --1
		INNER JOIN BREF..TBATCHSSD t5 --1
		ON t1.SSD_CF = t5.SSD_CF
		WHERE t3.GRPINISTS_CT = 1 AND  t3.GRPFIRCLO_D IS NOT NULL
		AND t5.BATCHUSER_CF= suser_name() --1
END

IF(@norme_cf = 'I17P')
BEGIN
	UPDATE BTRT..TCR
		SET PARFIRCLO_D = @closing_date, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BTRT..TCR t1
		INNER JOIN BTRT..TCRCONTR t2
		ON t1.CR_NF = t2.CR_NF AND t1.CRUWY_NF = t2.CRUWY_NF AND t1.CRUW_NT = t2.CRUW_NT
		INNER JOIN BTRT..TSECIFRS t3
		ON t2.CTR_NF = t3.CTR_NF AND t2.UWY_NF = t3.UWY_NF AND t2.UW_NT = t3.UW_NT AND t2.END_NT = t3.END_NT --1
		INNER JOIN BREF..TBATCHSSD t5 --1
		ON t1.SSD_CF = t5.SSD_CF
		WHERE t3.PARINISTS_CT = 1 AND  t3.PARFIRCLO_D IS NOT NULL
		AND t5.BATCHUSER_CF= suser_name() --1
END

IF(@norme_cf = 'I17L')
BEGIN
	UPDATE BTRT..TCR
		SET LOCFIRCLO_D = @closing_date, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BTRT..TCR t1
		INNER JOIN BTRT..TCRCONTR t2
		ON t1.CR_NF = t2.CR_NF AND t1.CRUWY_NF = t2.CRUWY_NF AND t1.CRUW_NT = t2.CRUW_NT
		INNER JOIN BTRT..TSECIFRS t3
		ON t2.CTR_NF = t3.CTR_NF AND t2.UWY_NF = t3.UWY_NF AND t2.UW_NT = t3.UW_NT AND t2.END_NT = t3.END_NT --1
		INNER JOIN BREF..TBATCHSSD t5 --1
		ON t1.SSD_CF = t5.SSD_CF
		WHERE t3.LOCINISTS_CT = 1 AND  t3.LOCFIRCLO_D IS NOT NULL
		AND t5.BATCHUSER_CF= suser_name() --1
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

if object_id('PuCR_02') is not null
	print '<<< CREATED PROC PuCR_02 >>>'
else
	print '<<< FAILED CREATING PROC PuCR_02 >>>'
go

grant execute on PuCR_02 TO GOMEGA
go

grant execute on PuCR_02 TO GDBBATCH
go