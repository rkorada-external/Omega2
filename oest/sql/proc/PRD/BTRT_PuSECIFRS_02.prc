use BTRT
go

if object_id('PuSECIFRS_02') is not null
	begin
		drop procedure PuSECIFRS_02
		if object_id('PuSECIFRS_02') is not null
			print '<<< FAILED DROPPING procedure PuSECIFRS_02 >>>'
		else
			print '<<< DROPPED procedure PuSECIFRS_02 >>>'
	end
go

create procedure PuSECIFRS_02
  (
		@norme_cf  char(4),
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
    Update data in BTRT..TSECIFRS depending on the norme_cf
Parametres:
 	@p_erreur varchar(64)=null output
Modifications
[001] 31/03/2021 filter update by region and and filter on LOB_CF
[002] 03/03/2022 ART Spira 102316 IFRS 17 - Life - Inception status at Booked
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION
/* ------------------------------------------------------------------- */

--[003]
IF(@norme_cf = 'I17G')
BEGIN
	UPDATE BTRT..TSECIFRS
		SET GRPINISTS_CT  = 2, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BTRT..TSECIFRS t1
		INNER JOIN BTRT..TSECTION t2 --1
		ON t1.CTR_NF = t2.CTR_NF AND t1.SEC_NF = t2.SEC_NF AND t1.UWY_NF = t2.UWY_NF AND t1.UW_NT = t2.UW_NT AND t1.END_NT = t2.END_NT --1
		INNER JOIN BREF..TBATCHSSD t3 --1
		ON t2.SSD_CF = t3.SSD_CF --1
		WHERE t1.GRPINISTS_CT = 1 AND t1.GRPFIRCLO_D IS NOT NULL
		AND t3.BATCHUSER_CF= suser_name() --1
END

IF(@norme_cf = 'I17P')
BEGIN
	UPDATE BTRT..TSECIFRS
		SET PARINISTS_CT  = 2, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BTRT..TSECIFRS t1
		INNER JOIN BTRT..TSECTION t2 --1
		ON t1.CTR_NF = t2.CTR_NF AND t1.SEC_NF = t2.SEC_NF AND t1.UWY_NF = t2.UWY_NF AND t1.UW_NT = t2.UW_NT AND t1.END_NT = t2.END_NT --1
		INNER JOIN BREF..TBATCHSSD t3 --1
		ON t2.SSD_CF = t3.SSD_CF --1
		WHERE t1.PARINISTS_CT = 1 AND t1.PARFIRCLO_D IS NOT NULL
		AND t3.BATCHUSER_CF= suser_name() --1
END

IF(@norme_cf = 'I17L')
BEGIN
	UPDATE BTRT..TSECIFRS
		SET LOCINISTS_CT  = 2, LSTUPDUSR_CF = @user_cf, LSTUPD_D  = getDate()
		FROM BTRT..TSECIFRS t1
		INNER JOIN BTRT..TSECTION t2 --1
		ON t1.CTR_NF = t2.CTR_NF AND t1.SEC_NF = t2.SEC_NF AND t1.UWY_NF = t2.UWY_NF AND t1.UW_NT = t2.UW_NT AND t1.END_NT = t2.END_NT --1
		INNER JOIN BREF..TBATCHSSD t3 --1
		ON t2.SSD_CF = t3.SSD_CF --1
		WHERE t1.LOCINISTS_CT = 1 AND t1.LOCFIRCLO_D IS NOT NULL
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

if object_id('PuSECIFRS_02') is not null
	print '<<< CREATED PROC PuSECIFRS_02 >>>'
else
	print '<<< FAILED CREATING PROC PuSECIFRS_02 >>>'
go

grant execute on PuSECIFRS_02 TO GOMEGA
go

grant execute on PuSECIFRS_02 TO GDBBATCH
go