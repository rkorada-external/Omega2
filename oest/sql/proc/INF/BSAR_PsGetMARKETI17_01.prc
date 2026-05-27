USE BSAR
go
IF OBJECT_ID('dbo.PsGetMARKETI17_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsGetMARKETI17_01
    IF OBJECT_ID('dbo.PsGetMARKETI17_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsGetMARKETI17_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsGetMARKETI17_01 >>>'
END
go
/* creation de la procedure */
create procedure dbo.PsGetMARKETI17_01(
		@p_clo_date char(8),
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
)
AS



/***************************************************

Procedure: PsGetMARKETI17_01

Base principale : BSAR

Version: 1

Auteur: Arnaud RUFFAULT

Date de creation: 16/06/2021

_________________
MODIFICATIONS
[001] ART spira 97478 IFRS17 DryRun- Recognition date test for pericase
[002] ART spira 100168 IFRS17 inception pericase- Extract Run-off if transition mode
[003] ART spira 999999 IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
[004] Suraj P    22/11/2022  :spira :106239 Pericase INI does not include contract recognized on cut off date
*
*****************************************************/

-------------------------
-- Recognition date - X days OR Dry run date retrieval [001]
-------------------------
DECLARE
@v_pos_booking_minus_days datetime

IF(@p_quarter_end = 'NONE')
BEGIN
	DECLARE
	@v_year_clo_date int,
	@v_month_clo_date int,
	@v_pos_booking_d datetime
	
	SELECT @v_year_clo_date = CONVERT(int, substring(@p_clo_date, 1, 4))
	SELECT @v_month_clo_date = CONVERT(int, substring(@p_clo_date, 5, 2))
	SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date --[003]
	SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * -1, @v_pos_booking_d)
END
ELSE 
BEGIN
	SELECT @v_pos_booking_minus_days = convert(datetime, @p_quarter_end, 103)
END

declare @erreur int


BEGIN

SELECT DISTINCT UWSEC.CTR_NF, UWSEC.END_NT, UWSEC.SEC_NF, UWSEC.UWY_NF, UWSEC.UW_NT, UWSEC.CTRNAT_CT, UWSEC.SUBMRK_LS, UWSEC.MRKUNT_NT, UWSEC.SUBMRK_NT ,UWSEC.GRPGRP3_NT
    FROM BSBO..TUWSEC UWSEC
				INNER JOIN BTRT..TSECIFRS SECIFRS
				ON UWSEC.CTR_NF = SECIFRS.CTR_NF AND UWSEC.UWY_NF = SECIFRS.UWY_NF AND UWSEC.UW_NT = SECIFRS.UW_NT AND UWSEC.END_NT = SECIFRS.END_NT AND UWSEC.SEC_NF = SECIFRS.SEC_NF
				WHERE SECIFRS.RECOD_D < @v_pos_booking_minus_days		--MODIF[004]
    AND ( 
    	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))) --[002]
    	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9))) --[002]
    		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9))) --[002]
    )
UNION ALL	
SELECT DISTINCT UWSEC.CTR_NF, UWSEC.END_NT, UWSEC.SEC_NF, UWSEC.UWY_NF, UWSEC.UW_NT, UWSEC.CTRNAT_CT, UWSEC.SUBMRK_LS, UWSEC.MRKUNT_NT, UWSEC.SUBMRK_NT ,UWSEC.GRPGRP3_NT
    FROM BSBO..TUWSEC UWSEC
				INNER JOIN BFAC..TSECIFRS SECIFRS
				ON UWSEC.CTR_NF = SECIFRS.CTR_NF AND UWSEC.UWY_NF = SECIFRS.UWY_NF AND UWSEC.UW_NT = SECIFRS.UW_NT AND UWSEC.END_NT = SECIFRS.END_NT AND UWSEC.SEC_NF = SECIFRS.SEC_NF
				WHERE SECIFRS.RECOD_D < @v_pos_booking_minus_days		--MODIF[004]
    AND ( 
    	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))) --[002]
    	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9))) --[002]
    		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9))) --[002]
    )
ORDER BY CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF asc
	
END

return 0
go
EXEC sp_procxmode 'dbo.PsGetMARKETI17_01', 'unchained'
go
IF OBJECT_ID('dbo.PsGetMARKETI17_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsGetMARKETI17_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsGetMARKETI17_01 >>>'
go
GRANT EXECUTE ON dbo.PsGetMARKETI17_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsGetMARKETI17_01 TO GDBBATCH
go
