use BTRT
go

if object_id('PuSECIFRS_04') is not null
	begin
		drop procedure PuSECIFRS_04
		if object_id('PuSECIFRS_04') is not null
			print '<<< FAILED DROPPING procedure PuSECIFRS_04 >>>'
		else
			print '<<< DROPPED procedure PuSECIFRS_04 >>>'
	end
go

create procedure PuSECIFRS_04
  (
  @norme_cf  char(4),
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BTRT
Version: 1
Auteur: CAS
Date de creation: 17/02/2021
Description du programme:
    Update data in BTRT..TSECIFRS using data from BTRAV..ESFD8000_TSECIFRS for multi-year contracts
Parametres:
	@norme_cf char(4)
 	@p_erreur varchar(64)=null output
*****************************************************
Modification:

#[002] 12/02/2026 MZM: US7847 EBS INI UPDATE TSCIFRS AND TRETIFRS Via BTRAV..ESFD8000_TSECEBSINI  BTRAV..ESFD8000_TRETEBSINI
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION

/* ------------------------------------------------------------------- */

--[001]
IF(@norme_cf = 'I17G')
BEGIN
	UPDATE BTRT..TSECIFRS
	SET B.GRPINISTS_CT = A.GRPINISTS_CT
	FROM BTRAV..ESFD8000_TSECIFRS A, BTRT..TSECIFRS B 
	WHERE A.CTR_NF = B.CTR_NF
	AND A.UWY_NF = B.UWY_NF
	AND A.UW_NT = B.UW_NT
	AND A.END_NT = B.END_NT
	AND A.SEC_NF = B.SEC_NF
	AND A.CTRTYP_CT = 'TRT'
	AND (A.GRPINISTS_CT <> B.GRPINISTS_CT OR (B.GRPINISTS_CT IS NULL AND A.GRPINISTS_CT IS NOT NULL) OR (B.GRPINISTS_CT IS NOT NULL AND A.GRPINISTS_CT IS NULL))
END

IF(@norme_cf = 'I17P')
BEGIN
	UPDATE BTRT..TSECIFRS
	SET B.PARINISTS_CT = A.PARINISTS_CT
	FROM BTRAV..ESFD8000_TSECIFRS A, BTRT..TSECIFRS B 
	WHERE A.CTR_NF = B.CTR_NF
	AND A.UWY_NF = B.UWY_NF
	AND A.UW_NT = B.UW_NT
	AND A.END_NT = B.END_NT
	AND A.SEC_NF = B.SEC_NF
	AND A.CTRTYP_CT = 'TRT'
	AND (A.PARINISTS_CT <> B.PARINISTS_CT OR (B.PARINISTS_CT IS NULL AND A.PARINISTS_CT IS NOT NULL) OR (B.PARINISTS_CT IS NOT NULL AND A.PARINISTS_CT IS NULL))
END

IF(@norme_cf = 'I17L')
BEGIN
	UPDATE BTRT..TSECIFRS
	SET B.LOCINISTS_CT = A.LOCINISTS_CT
	FROM BTRAV..ESFD8000_TSECIFRS A, BTRT..TSECIFRS B 
	WHERE A.CTR_NF = B.CTR_NF
	AND A.UWY_NF = B.UWY_NF
	AND A.UW_NT = B.UW_NT
	AND A.END_NT = B.END_NT
	AND A.SEC_NF = B.SEC_NF
	AND A.CTRTYP_CT = 'TRT'
	AND (A.LOCINISTS_CT <> B.LOCINISTS_CT OR (B.LOCINISTS_CT IS NULL AND A.LOCINISTS_CT IS NOT NULL) OR (B.LOCINISTS_CT IS NOT NULL AND A.LOCINISTS_CT IS NULL))
END

/* ------------------------------------------------------------------- */


--[002]
IF(@norme_cf = 'EBS')
BEGIN
	UPDATE BTRT..TSECIFRS
	SET B.SIIINISTS_CT = A.SIIINISTS_CT
	FROM BTRAV..ESFD8000_TSECEBSINI A, BTRT..TSECIFRS B 
	WHERE A.CTR_NF = B.CTR_NF
	AND A.UWY_NF = B.UWY_NF
	AND A.UW_NT = B.UW_NT
	AND A.END_NT = B.END_NT
	AND A.SEC_NF = B.SEC_NF
	--AND A.CTRTYP_CT = 'TRT'
	AND (A.SIIINISTS_CT <> B.SIIINISTS_CT OR (B.SIIINISTS_CT IS NULL AND A.SIIINISTS_CT IS NOT NULL) OR (B.SIIINISTS_CT IS NOT NULL AND A.SIIINISTS_CT IS NULL))
END

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

if object_id('PuSECIFRS_04') is not null
	print '<<< CREATED PROC PuSECIFRS_04 >>>'
else
	print '<<< FAILED CREATING PROC PuSECIFRS_04 >>>'
go

grant execute on PuSECIFRS_04 TO GOMEGA
go

grant execute on PuSECIFRS_04 TO GDBBATCH
go
