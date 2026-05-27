use BSEG
go

if object_id('PsOmegaExtract') is not null
	begin
		drop procedure PsOmegaExtract
		if object_id('PsOmegaExtract') is not null
			print '<<< FAILED DROPPING procedure PsOmegaExtract >>>'
		else
			print '<<< DROPPED procedure PsOmegaExtract >>>'
	end
go

create procedure PsOmegaExtract
  (
   @p_PARM_DATE     varchar(8),
			@norme_cf  char(4),
   @p_erreur 		varchar(64)= null output
  )
as

/***************************************************
Domaine : (ES) Estimation
Base principale : BSEG
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation: 18/06/2020
Description du programme:
    Get the perimeter of contracts to retrieve the Omega 2 extract
Parametres:
	@p_PARM_DATE     varchar(8)
 @p_erreur 		 varchar(64)=null output
modifications:
	[001] Spira 92573:  Transition: Gaps between expected and observed amounts FP-UPR
*****************************************************/

IF OBJECT_ID('tempdb..#OMEGA2EXTRACT_tmp') IS NOT NULL DROP TABLE tempdb..#OMEGA2EXTRACT_tmp
CREATE TABLE #OMEGA2EXTRACT_tmp
(
	SSD_CF															USSD_CF 			 NULL,
	ESB_CF															UESB_CF 			 NULL,
	CTR_NF															UCTR_NF 			 NULL,
	SEC_NF															USEC_NF 			 NULL,
	UWY_NF															UUWY_NF 			 NULL,
	UW_NT																UUW_NT					 NULL,
	END_NT															UEND_NT				 NULL,
	RETSSD_CF												USSD_CF					NULL,
	RETESB_CF												UESB_CF 			 NULL,
	RETCTR_NF												UCTR_NF 			 NULL,
	RETSEC_NF												USEC_NF 			 NULL,
	RTY_NF															UUWY_NF 			 NULL,
	RETUW_NT													UUW_NT					 NULL,
	RETEND_NT												UEND_NT				 NULL,
	CTRINC_D													datetime				NULL,
	CTR_FLAG													char(1)					NOT NULL,
	CTR_PROP													char(1)					NULL,
	CLIENT_NF												UCLI_NF					NULL,
	MULTI_YEAR_TO_NF					smallint				NULL,
	PRILR_T														USHORAT_R			NULL,
	CTRPRI_B													UBOOLEAN_B		NULL,
	CR_NF																char(10)				NULL,
	CR_UWY_NF 											UUWY_NF 				NULL,
	CR_UW_NT 												UUW_NT						NULL,
	FP 																		UAMT_M 					NULL,
	UPR 																	UAMT_M 					NULL,
	FP_CR_LVL 											UAMT_M 					NULL,
	UPR_CR_LVL 										UAMT_M 					NULL,
	FP_MINUS_UPR 								UAMT_M 					NULL
)

DECLARE
@v_tablename_assum varchar (20), -- the table name depends on the date in input parameter
@v_tablename_retro varchar (20) -- the table name depends on the date in input parameter

-- we retrieve the TTECLADA table to use depending on the input parameter @p_date
SELECT @v_tablename_assum = p.TABCIBLE_CF FROM BSAR..TBOPAR p WHERE p.TAB_CF = 'TTECLEDA' AND p.FIELD2_CF = @p_PARM_DATE 

IF @v_tablename_assum IS NOT NULL
BEGIN
	EXEC BSEG..PsOmegaExtract_FAC @p_PARM_DATE, @norme_cf --[001] add norme_cf in parameter
	EXEC BSEG..PsOmegaExtract_TRT @p_PARM_DATE, @norme_cf --[001] add norme_cf in parameter
END 

-- we retrieve the TTECLADR table to use depending on the input parameter @p_date
SELECT @v_tablename_retro = p.TABCIBLE_CF FROM BSAR..TBOPAR p WHERE p.TAB_CF = 'TTECLEDR' AND p.FIELD2_CF = @p_PARM_DATE 

IF @v_tablename_retro IS NOT NULL
BEGIN
	EXEC BSEG..PsOmegaExtract_RET @p_PARM_DATE
END

SELECT 
SSD_CF, 
ESB_CF, 
CTR_NF, 
SEC_NF, 
UWY_NF, 
UW_NT, 
END_NT,
RETSSD_CF,
RETESB_CF,
RETCTR_NF,
RETSEC_NF,
RTY_NF,
RETUW_NT,
RETEND_NT,
convert(char(8), CTRINC_D, 112), 
CTR_FLAG,
CTR_PROP, 
CLIENT_NF, 
MULTI_YEAR_TO_NF, 
PRILR_T, 
CTRPRI_B, 
CR_NF, 
CR_UWY_NF, 
CR_UW_NT, 
FP, 
UPR, 
FP_CR_LVL, 
UPR_CR_LVL, 
FP_MINUS_UPR
FROM #OMEGA2EXTRACT_tmp 

GO 

if object_id('PsOmegaExtract') is not null
	print '<<< CREATED PROC PsOmegaExtract >>>'
else
	print '<<< FAILED CREATING PROC PsOmegaExtract >>>'
go

grant execute on PsOmegaExtract TO GOMEGA
go

grant execute on PsOmegaExtract TO GDBBATCH
go