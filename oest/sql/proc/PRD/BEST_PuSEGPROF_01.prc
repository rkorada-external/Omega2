use BEST
go

if object_id('PuSEGPROF_01') is not null
	begin
		drop procedure PuSEGPROF_01
		if object_id('PuSEGPROF_01') is not null
			print '<<< FAILED DROPPING procedure PuSEGPROF_01 >>>'
		else
			print '<<< DROPPED procedure PuSEGPROF_01 >>>'
	end
go

create procedure PuSEGPROF_01
  (
   @p_CLOSING_D     datetime
  ,@p_CLOSING_T     UBANVAL_CT
  ,@p_BCH_USR       UUPDUSR_CF
  ,@p_NORME_CF      UBANVAL_CT
  ,@p_erreur 		varchar(64)=null output
  )
with execute as caller as

/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: AGD
Date de creation: 24/10/2019
Description du programme:
    Update or Insert data in BEST..TSEGPROF using data from BTRAV..ESFD8000_TSEGPROF
Parametres:
	@p_CLOSING_D     datetime
	@p_CLOSING_T     UBANVAL_CT
	@p_BCH_USR       UUPDUSR_CF
	@p_NORME_CF      UBANVAL_CT
 	@p_erreur 		 varchar(64)=null output
		
		--modif 1: Spira #85316
*****************************************************/

begin

declare @erreur int

BEGIN TRANSACTION

/* ------------------------------------------------------------------- */ 


--START modif 1
IF(@p_CLOSING_T = 'INI')
BEGIN
		DELETE BEST..TSEGPROF
		WHERE CLODAT_D = @p_CLOSING_D
		AND BCHUSR_CF = @p_BCH_USR
		AND NORME_CF = @p_NORME_CF
		AND PER_CF = 'INI'
END

IF(@p_CLOSING_T != 'INI')
BEGIN
		DELETE BEST..TSEGPROF
		WHERE CLODAT_D = @p_CLOSING_D
		AND BCHUSR_CF = @p_BCH_USR
		AND NORME_CF = @p_NORME_CF
		AND PER_CF != 'INI'
END
--END modif 1



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
		AND B.UWY_NF = A.UWY_NF
		AND B.NORME_CF = A.NORME_CF
		AND B.INIPRO_CF = A.INIPRO_CF
		AND B.CLODAT_D = A.CLODAT_D
		AND B.PER_CF = A.PER_CF
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

if object_id('PuSEGPROF_01') is not null
	print '<<< CREATED PROC PuSEGPROF_01 >>>'
else
	print '<<< FAILED CREATING PROC PuSEGPROF_01 >>>'
go

grant execute on PuSEGPROF_01 TO GOMEGA
go

grant execute on PuSEGPROF_01 TO GDBBATCH
go