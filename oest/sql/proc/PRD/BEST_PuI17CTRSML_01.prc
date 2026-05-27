use BEST
go

if object_id('PuI17CTRSML_01') is not null
	begin
		drop procedure PuI17CTRSML_01
		if object_id('PuI17CTRSML_01') is not null
			print '<<< FAILED DROPPING procedure PuI17CTRSML_01 >>>'
		else
			print '<<< DROPPED procedure PuI17CTRSML_01 >>>'
	end
go

create procedure PuI17CTRSML_01
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
    Update or Insert data in BEST..TI17CTRSML using data from BTRAV..ESFD8000_TSECIFRS
Parametres:
 	@p_erreur varchar(64)=null output
***************************************************** 	
 	Modifications:
*****************************************************/

declare @erreur int,
		@tran_imbr	bit 
		
select @erreur = 0
select @tran_imbr = 1

/* ------------------------------------INSERT/UPDATE------------------------------- */
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

UPDATE BEST..TI17CTRSML
SET B.GRPINIPRO_CF = A.GRPINIPRO_CF,
	B.GRPRATEINDEX_CT = A.GRPRATEINDEX_CT,
	B.GRPINISTS_CT = A.GRPINISTS_CT,
	B.GRPFIRCLO_D = A.GRPFIRCLO_D,
	B.LSTUPD_D = A.LSTUPD_D,
	B.LSTUPDUSR_CF = A.LSTUPDUSR_CF
FROM BTRAV..ESFD8000_TSECIFRS A, BEST..TI17CTRSML B 
WHERE A.CTR_NF = B.CTR_NF
AND A.UWY_NF = B.UWY_NF
AND A.UW_NT = B.UW_NT
AND A.END_NT = B.END_NT
AND A.SEC_NF = B.SEC_NF
AND((B.GRPINIPRO_CF <> A.GRPINIPRO_CF OR (B.GRPINIPRO_CF IS NULL AND A.GRPINIPRO_CF IS NOT NULL) OR (B.GRPINIPRO_CF IS NOT NULL AND A.GRPINIPRO_CF IS NULL))
	OR (B.GRPRATEINDEX_CT <> A.GRPRATEINDEX_CT OR (B.GRPRATEINDEX_CT IS NULL AND A.GRPRATEINDEX_CT IS NOT NULL) OR (B.GRPRATEINDEX_CT IS NOT NULL AND A.GRPRATEINDEX_CT IS NULL))
	OR (B.GRPINISTS_CT <> A.GRPINISTS_CT OR (B.GRPINISTS_CT IS NULL AND A.GRPINISTS_CT IS NOT NULL) OR (B.GRPINISTS_CT IS NOT NULL AND A.GRPINISTS_CT IS NULL))
	OR (B.GRPFIRCLO_D <> A.GRPFIRCLO_D OR (B.GRPFIRCLO_D IS NULL AND A.GRPFIRCLO_D IS NOT NULL) OR (B.GRPFIRCLO_D IS NOT NULL AND A.GRPFIRCLO_D IS NULL))) 

select @erreur = @@error
   if @erreur != 0
    begin
     select @p_erreur="20001 APPLICATIF;1; " + convert(varchar(10), @erreur) + ";"
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
	A.CTR_NF,
	A.UWY_NF, 
	A.UW_NT, 
	A.END_NT, 
	A.SEC_NF, 
	A.GRPRATEINDEX_CT, 
	A.GRPFIRCLO_D, 
	A.GRPINIPRO_CF, 
	A.GRPINISTS_CT, 
	GETDATE(), 
	SUSER_NAME() 
FROM BTRAV..ESFD8000_TSECIFRS A
WHERE NOT EXISTS 
	(SELECT 1 
	FROM BEST..TI17CTRSML C 
	WHERE A.CTR_NF = C.CTR_NF 
	AND A.UWY_NF = C.UWY_NF 
	AND A.UW_NT = C.UW_NT 
	AND A.END_NT = C.END_NT 
	AND A.SEC_NF = C.SEC_NF)

select @erreur = @@error
   if @erreur != 0
    begin
     select @p_erreur="20001 APPLICATIF;2; " + convert(varchar(10), @erreur) + ";"
     goto fin
    end

/* ------------------------------------------------------------------- */

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

if object_id('PuI17CTRSML_01') is not null
	print '<<< CREATED PROC PuI17CTRSML_01 >>>'
else
	print '<<< FAILED CREATING PROC PuI17CTRSML_01 >>>'
go

grant execute on PuI17CTRSML_01 TO GOMEGA
go

grant execute on PuI17CTRSML_01 TO GDBBATCH
go