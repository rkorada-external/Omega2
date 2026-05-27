USE BEST
go

IF OBJECT_ID('TI17CTRINFO_02') IS NOT NULL
	BEGIN
		DROP PROCEDURE TI17CTRINFO_02
		IF OBJECT_ID('TI17CTRINFO_02') IS NOT NULL
			PRINT '<<< FAILED DROPPING PROCEDURE TI17CTRINFO_02 >>>'
		ELSE
			PRINT '<<< DROPPED PROCEDURE TI17CTRINFO_02 >>>'
	END
go

create procedure TI17CTRINFO_02 
  (
  @p_closingd datetime,
  @p_usr_cf UUSR_CF,
  @p_credate datetime,
  @p_erreur varchar(64)=null output
  )
with execute as caller as

/*
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: Charles socie
Date de creation: 12/03/2021
Description du programme:
    insert data from BTRAV_ESFD4040_TI17CTRINFO_02 to BEST_TI17CTRINFO_02
Parametres:
    @p_erreur       varchar(64)=null output 
*/

DECLARE
  @enr        int,
  @err        int,
  @totenr     int,
  @trans_etat int,
  @erreur 	  int

SELECT 
  @enr    = 1,
  @err    = 0,
  @totenr = 0
  
SET ROWCOUNT 50000

/* ------------------------------------------------------------------- */  
 WHILE @enr > 0
  BEGIN
    BEGIN TRAN	
-- insert by group of 100K rows each time			
		INSERT INTO BEST..TI17CTRINFO (
			CTR_NF,
			SEC_NF,
			UWY_NF,
			UW_NT,
			END_NT,
			RETCTR_NF,
			RETSEC_NF,
			RTY_NF,
			RETUW_NT,
			RETEND_NT,
			LOFACTORSTD_R,
			LOFACTORINI_R,
			CSMPATTERN_R,
			LCPATTERN_R,
			ANNLIM_B,
			CLODAT_D,
			CRE_D,
			CREUSR_CF )
		SELECT A.CTR_NF,
			A.SEC_NF,
			A.UWY_NF,
			A.UW_NT,
			A.END_NT,
			A.RETCTR_NF,
			A.RETSEC_NF,
			A.RTY_NF,
			A.RETUW_NT,
			A.RETEND_NT,
			A.LOFACTORSTD_R,
			A.LOFACTORINI_R,
			A.CSMPATTERN_R,
			A.LCPATTERN_R,
			A.ANNLIM_B,
			@p_closingd,
			@p_credate,
			@p_usr_cf
		FROM BTRAV..ESFD4040_TI17CTRINFO A
				WHERE NOT EXISTS ( SELECT 1 from BEST..TI17CTRINFO B WHERE A.CTR_NF = B.CTR_NF AND A.SEC_NF = B.SEC_NF
						AND A.UWY_NF = B.UWY_NF AND A.UW_NT = B.UW_NT AND A.END_NT = B.END_NT
						AND A.RETCTR_NF = B.RETCTR_NF AND A.RETSEC_NF = B.RETSEC_NF AND A.RTY_NF = B.RTY_NF AND A.RETUW_NT = B.RETUW_NT
						AND A.RETEND_NT = B.RETEND_NT AND A.LOFACTORSTD_R = B.LOFACTORSTD_R AND A.LOFACTORINI_R = B.LOFACTORINI_R
						AND A.CSMPATTERN_R = B.CSMPATTERN_R AND A.LCPATTERN_R = B.LCPATTERN_R AND A.ANNLIM_B = B.ANNLIM_B )
	
		SELECT @enr = @@rowcount, 
				   @err = @@error,
				   @totenr = @totenr + @enr

		IF @err != 0
		BEGIN
		  ROLLBACK TRAN
		  BREAK
		END
		COMMIT TRAN

END
/* ------------------------------------------------------------------- */
SET ROWCOUNT 0

PRINT '%1! row(s) insert in BEST..TI17CTRINFO', @totenr

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

go

if object_id('TI17CTRINFO_02') is not null
  print '<<< CREATED PROC TI17CTRINFO_02 >>>'
else
  print '<<< FAILED CREATING PROC TI17CTRINFO_02 >>>'
go

grant execute on TI17CTRINFO_02 TO GOMEGA
go

grant execute on TI17CTRINFO_02 TO GDBBATCH
go
