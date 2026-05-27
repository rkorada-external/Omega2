use BEST
go

if object_id('PuSEGPROF_02') is not null
	begin
		drop procedure PuSEGPROF_02
		if object_id('PuSEGPROF_02') is not null
			print '<<< FAILED DROPPING procedure PuSEGPROF_02 >>>'
		else
			print '<<< DROPPED procedure PuSEGPROF_02 >>>'
	end
go

create procedure PuSEGPROF_02
  (
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: CAS
Date de creation: 24/10/2019
Description du programme:
    Update or Insert data in BEST..TSEGPROF using data from BTRAV..ESFD8000_TSEGPROF
Parametres:
 	@p_erreur varchar(64)=null output
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION

/* ------------------------------------------------------------------- */ 

UPDATE BEST..TSEGPROF
SET B.SEGPOS_CF = A.SEGPOS_CF,
	B.LSTUPDUSR_CF = A.LSTUPDUSR_CF,
	B.LSTUPD_D = A.LSTUPD_D
FROM BTRAV..ESFD8000_TSEGPROF A, BEST..TSEGPROF B 
WHERE B.IFRSSEG_CT = A.IFRSSEG_CT
AND B.NORME_CF = A.NORME_CF
AND B.PER_CF = A.PER_CF
AND B.CLODAT_D = A.CLODAT_D
AND B.BCHUSR_CF = A.BCHUSR_CF
AND (B.SEGPOS_CF <> A.SEGPOS_CF OR (B.SEGPOS_CF IS NULL AND A.SEGPOS_CF IS NOT NULL))
	
INSERT INTO BEST..TSEGPROF (
	IFRSSEG_CT,
	UWY_NF,
	NORME_CF,
	INIPRO_CF,
	CLODAT_D,
	PER_CF,
	BCHUSR_CF,
	CLOPRO_CF,
	CSMAMT_M,
	SEGPOS_CF,
	CRE_D,
	CREUSR_CF,
	LSTUPDUSR_CF,
	LSTUPD_D)
SELECT A.IFRSSEG_CT,
	A.UWY_NF,
	A.NORME_CF,
	A.INIPRO_CF,	
	A.CLODAT_D,
	A.PER_CF,
	A.BCHUSR_CF,
	A.CLOPRO_CF,
	A.CSMAMT_M,
	A.SEGPOS_CF,
	A.CRE_D,
	A.CREUSR_CF,
	A.LSTUPDUSR_CF,
	A.LSTUPD_D
FROM BTRAV..ESFD8000_TSEGPROF A
WHERE NOT EXISTS (
	SELECT * 
	FROM BEST..TSEGPROF B
	WHERE B.IFRSSEG_CT = A.IFRSSEG_CT
	AND B.NORME_CF = A.NORME_CF
	AND B.PER_CF = A.PER_CF
	AND B.CLODAT_D = A.CLODAT_D
	AND B.BCHUSR_CF = A.BCHUSR_CF)

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

if object_id('PuSEGPROF_02') is not null
	print '<<< CREATED PROC PuSEGPROF_02 >>>'
else
	print '<<< FAILED CREATING PROC PuSEGPROF_02 >>>'
go

grant execute on PuSEGPROF_02 TO GOMEGA
go

grant execute on PuSEGPROF_02 TO GDBBATCH
go