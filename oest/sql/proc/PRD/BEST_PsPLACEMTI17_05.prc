use BEST
go


/*
 * DROP PROC dbo.PsPLACEMTI17_05 */
IF OBJECT_ID('dbo.PsPLACEMTI17_05') IS NOT NULL
BEGIN
    DROP PROC dbo.PsPLACEMTI17_05
    PRINT '<<< DROPPED PROC dbo.PsPLACEMTI17_05 >>>'
END
go

/*
 * creation de la procedure */
create procedure PsPLACEMTI17_05(
		@p_clo_date char(8),
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
)

as
/***************************************************
Programme:                  PsPLACEMTI17_05
Domaine :                   Estimation
Base principale :           BEST
Version:                    1
Auteur:                     Arnaud RUFFAULT
Date de creation:           08/06/2021
Description du programme:   
SP basé sur le procédure utilisé sur IFRS4 PsPLACEMT_05
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
	SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date --003
	SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * -1, @v_pos_booking_d)
END
ELSE 
BEGIN
	SELECT @v_pos_booking_minus_days = convert(datetime, @p_quarter_end, 103)
END


select p.RETCTR_NF, p.RTY_NF, p.PLC_NT, p.RTO_NF, p.SSDRTO_B   
into #temp
from BRET..TPLACEMT p, BREF..TBATCHSSD T1, BRET..TRETIFRS RETIFRS, BRET..TRETCTR RETCTR, BRET..TRETSEC RETSEC
where p.his_b = 0
and   p.ssd_cf = T1.SSD_CF
and   T1.BATCHUSER_CF = suser_name()
and RETIFRS.RETCTR_NF= p.RETCTR_NF and RETIFRS.RTY_NF= p.RTY_NF
and RETIFRS.RETCTR_NF= RETCTR.RETCTR_NF and RETIFRS.RTY_NF= RETCTR.RTY_NF
and RETSEC.RETCTR_NF= RETCTR.RETCTR_NF and RETSEC.RTY_NF= RETCTR.RTY_NF
and RETIFRS.RETRECOD_D < @v_pos_booking_minus_days			--MODIF[004]
and (
	RETSEC.nat_cf IN ('10','11','12','20','21','22','23')
	OR(RETSEC.nat_cf NOT IN ('10','11','12','20','21','22','23')  
	 AND RETCTR.CTRINC_D <= CTRINCUWY_D
		AND ( 
	  (@norme_cf = 'I17G' and ( RETIFRS.GRPINISTS_CT  = 0 OR RETIFRS.GRPINISTS_CT = 1  OR (@p_is_transition = 'YES' and RETIFRS.GRPINISTS_CT = 9))) --002
	   or (@norme_cf = 'I17P' and ( RETIFRS.PARINISTS_CT  = 0 OR RETIFRS.PARINISTS_CT = 1  OR (@p_is_transition = 'YES' and RETIFRS.PARINISTS_CT = 9))) --002
		  or (@norme_cf = 'I17L' and ( RETIFRS.LOCINISTS_CT  = 0 OR RETIFRS.LOCINISTS_CT = 1  OR (@p_is_transition = 'YES' and RETIFRS.LOCINISTS_CT = 9))) --002
		)
	)
)

UNION

select a.RETCTR_NF, a.RTY_NF, a.PLC_NT, a.RTO_NF, a.SSDRTO_B
from BRET..TPLACEMT a, BREF..TBATCHSSD T2, BRET..TRETIFRS RETIFRS, BRET..TRETCTR RETCTR, BRET..TRETSEC RETSEC

where a.ssd_cf = T2.SSD_CF
and   T2.BATCHUSER_CF = suser_name()
and RETIFRS.RETCTR_NF= a.RETCTR_NF and RETIFRS.RTY_NF= a.RTY_NF
and RETIFRS.RETCTR_NF= RETCTR.RETCTR_NF and RETIFRS.RTY_NF= RETCTR.RTY_NF
and RETSEC.RETCTR_NF= RETCTR.RETCTR_NF and RETSEC.RTY_NF= RETCTR.RTY_NF
and RETIFRS.RETRECOD_D < @v_pos_booking_minus_days			--MODIF[004]
and (
	RETSEC.nat_cf IN ('10','11','12','20','21','22','23')
	OR(RETSEC.nat_cf NOT IN ('10','11','12','20','21','22','23')  
	 AND RETCTR.CTRINC_D <= CTRINCUWY_D
		AND ( 
	  (@norme_cf = 'I17G' and ( RETIFRS.GRPINISTS_CT  = 0 OR RETIFRS.GRPINISTS_CT = 1  OR (@p_is_transition = 'YES' and RETIFRS.GRPINISTS_CT = 9))) --002
	   or (@norme_cf = 'I17P' and ( RETIFRS.PARINISTS_CT  = 0 OR RETIFRS.PARINISTS_CT = 1  OR (@p_is_transition = 'YES' and RETIFRS.PARINISTS_CT = 9))) --002
		  or (@norme_cf = 'I17L' and ( RETIFRS.LOCINISTS_CT  = 0 OR RETIFRS.LOCINISTS_CT = 1  OR (@p_is_transition = 'YES' and RETIFRS.LOCINISTS_CT = 9))) --002
		)
	)
)
and  not exists (select 1 from bret..tplacemt b, BREF..TBATCHSSD T3
                 where a.retctr_nf = b.retctr_nf
                  and   a.rty_nf    = b.rty_nf
                  and   a.plc_nt    = b.plc_nt
                  and   b.his_b     = 0
                  and   b.ssd_cf = T3.SSD_CF
                  and   T3.BATCHUSER_CF = suser_name())
                                     
and  a.plcver_nt = (select max(b.plcver_nt) from bret..tplacemt b, BREF..TBATCHSSD T4
                  where a.retctr_nf = b.retctr_nf
                  and   a.rty_nf    = b.rty_nf
                  and   a.plc_nt    = b.plc_nt
                  and   b.his_b     = 1
                  and   b.ssd_cf = T4.SSD_CF
                  and   T4.BATCHUSER_CF = suser_name())                   
and a.his_b = 1



select * from #temp
order by RETCTR_NF, RTY_NF, PLC_NT


return 0
go

IF OBJECT_ID('dbo.PsPLACEMTI17_05') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsPLACEMTI17_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsPLACEMTI17_05 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsPLACEMTI17_05 */
GRANT EXECUTE ON dbo.PsPLACEMTI17_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPLACEMTI17_05 TO GDBBATCH
go

