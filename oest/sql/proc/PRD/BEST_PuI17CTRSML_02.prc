use BEST
go

if object_id('PuI17CTRSML_02') is not null
	begin
		drop procedure PuI17CTRSML_02
		if object_id('PuI17CTRSML_02') is not null
			print '<<< FAILED DROPPING procedure PuI17CTRSML_02 >>>'
		else
			print '<<< DROPPED procedure PuI17CTRSML_02 >>>'
	end
go

create procedure PuI17CTRSML_02
  (
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: Suraj Patil
Date de creation: 28/11/2022
Description du programme:
    Update or Insert data in BEST..TI17CTRSML using data from BTRAV..ESFD8000_TRETIFRS
Parametres:
 	@p_erreur varchar(64)=null output
***************************************************** 	
 	Modifications:
*****************************************************/

declare @erreur int,
		@tran_imbr	bit 
		
select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end
  
UPDATE BEST..TI17CTRSML
SET B.GRPRATEINDEX_CT = A.GRPRATEINDEX_CT,
	B.GRPINISTS_CT = A.GRPINISTS_CT,
	B.GRPFIRCLO_D = A.GRPFSTCLO_D,
	B.LSTUPD_D = A.LSTUPD_D,
	B.LSTUPDUSR_CF = A.LSTUPDUSR_CF
FROM BTRAV..ESFD8000_TRETIFRS A, BEST..TI17CTRSML B 
WHERE A.RETCTR_NF = B.CTR_NF 
AND A.RTY_NF= B.UWY_NF 
AND ((B.GRPRATEINDEX_CT <> A.GRPRATEINDEX_CT OR (B.GRPRATEINDEX_CT IS NULL AND A.GRPRATEINDEX_CT IS NOT NULL) OR (B.GRPRATEINDEX_CT IS NOT NULL AND A.GRPRATEINDEX_CT IS NULL))
	OR (B.GRPINISTS_CT <> A.GRPINISTS_CT OR (B.GRPINISTS_CT IS NULL AND A.GRPINISTS_CT IS NOT NULL) OR (B.GRPINISTS_CT IS NOT NULL AND A.GRPINISTS_CT IS NULL))
	OR (B.GRPFIRCLO_D <> A.GRPFSTCLO_D OR (B.GRPFIRCLO_D IS NULL AND A.GRPFSTCLO_D IS NOT NULL) OR (B.GRPFIRCLO_D IS NOT NULL AND A.GRPFSTCLO_D IS NULL)))

select @erreur = @@error
   if @erreur != 0
    begin
     select @p_erreur="20001 APPLICATIF;1;" + convert(varchar(10), @erreur) + ";"
     goto fin
    end
	
INSERT INTO BEST..TI17CTRSML(
	CTR_NF, 
	UWY_NF, 
	UW_NT, 
	END_NT, 
	SEC_NF, 
	GRPRATEINDEX_CT, 
	GRPFIRCLO_D, 
	GRPINIPRO_CF, 
	GRPINISTS_CT, 
	CRE_D, 
	CREUSR_CF)
SELECT 
	A.RETCTR_NF, 
	A.RTY_NF, 
	1, 
	0, 
	1, 
	A.GRPRATEINDEX_CT, 
	A.GRPFSTCLO_D, 
	'4', 
	A.GRPINISTS_CT, 
	GETDATE(), 
	SUSER_NAME()
FROM BTRAV..ESFD8000_TRETIFRS A 
WHERE NOT EXISTS 
	(SELECT 1 
	FROM BEST..TI17CTRSML C 
	WHERE A.RETCTR_NF = C.CTR_NF 
	AND A.RTY_NF = C.UWY_NF)

select @erreur = @@error
   if @erreur != 0
    begin
     select @p_erreur=" 20001 APPLICATIF;2;" + convert(varchar(10), @erreur) + ";"
     goto fin
    end

if @tran_imbr = 0
	COMMIT TRAN

return @erreur

fin:
if @tran_imbr = 0
BEGIN
	print @p_erreur
	select @p_erreur
	ROLLBACK TRAN
END

return @erreur

go

if object_id('PuI17CTRSML_02') is not null
	print '<<< CREATED PROC PuI17CTRSML_02 >>>'
else
	print '<<< FAILED CREATING PROC PuI17CTRSML_02 >>>'
go

grant execute on PuI17CTRSML_02 TO GOMEGA
go

grant execute on PuI17CTRSML_02 TO GDBBATCH
go
