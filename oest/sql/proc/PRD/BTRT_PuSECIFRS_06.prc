use BTRT
go

if object_id('PuSECIFRS_06') is not null
	begin
		drop procedure PuSECIFRS_06
		if object_id('PuSECIFRS_06') is not null
			print '<<< FAILED DROPPING procedure PuSECIFRS_06 >>>'
		else
			print '<<< DROPPED procedure PuSECIFRS_06 >>>'
	end
go

create procedure PuSECIFRS_06
  (
		@closing_date  varchar(8)
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BTRT
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation: 23/03/2022
Description du programme:
    Update table BTRT..TSECIFRS for internal assum related to run off
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION
/* ------------------------------------------------------------------- */

UPDATE BTRT..TSECIFRS
SET c.GRPINISTS_CT = b.GRPINISTS_CT,
c.GRPINIPRO_CF = '3',
c.GRPFIRCLO_D = b.GRPFSTCLO_D,
c.GRPRATEINDEX_CT = b.GRPRATEINDEX_CT,
c.LSTUPD_D = getDate(),
c.LSTUPDUSR_CF = user
FROM BRET..TSSDACTR a 
INNER JOIN BRET..TRETIFRS b 
ON a.RETCTR_NF = b.RETCTR_NF AND a.RTY_NF = b.RTY_NF
INNER JOIN BTRT..TSECIFRS c 
ON a.CTR_NF = c.CTR_NF AND a.SEC_NF = c.SEC_NF AND a.UWY_NF = c.UWY_NF AND a.UW_NT = c.UW_NT AND a.END_NT = c.END_NT
INNER JOIN BREF..TBATCHSSD d ON a.SSD_CF = d.SSD_CF 
WHERE b.GRPINISTS_CT = 9
AND b.GRPFSTCLO_D = @closing_date
AND ((c.GRPINISTS_CT <> b.GRPINISTS_CT OR (b.GRPINISTS_CT IS NULL AND c.GRPINISTS_CT IS NOT NULL) OR (b.GRPINISTS_CT IS NOT NULL AND c.GRPINISTS_CT IS NULL))
	OR (c.GRPFIRCLO_D <> b.GRPFSTCLO_D OR (b.GRPFSTCLO_D IS NULL AND c.GRPFIRCLO_D IS NOT NULL) OR (b.GRPFSTCLO_D IS NOT NULL AND c.GRPFIRCLO_D IS NULL))
	OR (c.GRPRATEINDEX_CT <> b.GRPRATEINDEX_CT OR (b.GRPRATEINDEX_CT IS NULL AND c.GRPRATEINDEX_CT IS NOT NULL) OR (b.GRPRATEINDEX_CT IS NOT NULL AND c.GRPRATEINDEX_CT IS NULL)))
AND d.BATCHUSER_CF = suser_name()


PRINT ' %1! row(s) updated in BTRT..TSECIFRS ', @@rowcount

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

if object_id('PuSECIFRS_06') is not null
	print '<<< CREATED PROC PuSECIFRS_06 >>>'
else
	print '<<< FAILED CREATING PROC PuSECIFRS_06 >>>'
go

grant execute on PuSECIFRS_06 TO GOMEGA
go

grant execute on PuSECIFRS_06 TO GDBBATCH
go