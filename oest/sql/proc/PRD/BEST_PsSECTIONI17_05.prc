use BEST
go

IF OBJECT_ID('dbo.PsSECTIONI17_05') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSECTIONI17_05
    IF OBJECT_ID('dbo.PsSECTIONI17_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSECTIONI17_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSECTIONI17_05 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PsSECTIONI17_05
     (
       @p_segtyp_ct           char(1),
       @p_seg_d               char(8),
							@p_clo_date 											char(8),
							@p_x_days 													int,
							@norme_cf 													char(4),
							@p_quarter_end varchar(10), --quarter end for dry run
							@p_is_transition varchar(3) = 'NO' --transition mode
     )
as

/***************************************************

Programme: PsSECTIONI17_05

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: Arnaud RUFFAULT

Date de creation: 08/06/2021

Description du programme:
cree a partir de la procedure PsSECTION_05 utilise en IFRS4
	- création du fichier périmètre (S/I)ADPERIFCT

Parametres:

Conditions d'execution:


Commentaires:

_________________
MODIFICATIONS
[001] ART spira 97478 IFRS17 DryRun- Recognition date test for pericase
[002] ART spira 100168 IFRS17 inception pericase- Extract Run-off if transition mode
[003] ART spira 102075 IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
[004] Suraj P    22/11/2022  :spira :106239 Pericase INI does not include contract recognized on cut off date
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


declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr


declare @erreur int

-----------------------
-- Filtre sur les dates
-----------------------

--declare @date_maxTRT datetime, @date_maxFAC datetime

--EXEC BEST..PsSECTION_32 @date_maxTRT output, @date_maxFAC output, @p_seg_d


--------------------------------------------------------------------
-- Périmètre de souscription pour les traités et les facs SFFPERIFCT
--------------------------------------------------------------------

-- Cas multifiliale


SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT, CNATYP_CT, 1 AS TAXBAS_CF
FROM   BTRT..TSECTION SECTION,
       BTRT..TCONTR CONTR,
       BTRT..TFAMCHGT FAMCHGT,
							BTRT..TSECIFRS SECIFRS
WHERE SECSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRLCK_B <> 1 
--and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.CTR_NF = FAMCHGT.CTR_NF and SECTION.UWY_NF = FAMCHGT.UWY_NF and SECTION.UW_NT = FAMCHGT.UW_NT and SECTION.END_NT = FAMCHGT.END_NT and SECTION.SEC_NF = FAMCHGT.SEC_NF
and   SECTION.CTR_NF = SECIFRS.CTR_NF AND SECTION.END_NT = SECIFRS.END_NT AND SECTION.SEC_NF = SECIFRS.SEC_NF AND SECTION.UWY_NF = SECIFRS.UWY_NF AND SECTION.UW_NT = SECIFRS.UW_NT
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   SECTION.SSD_CF in ( select SSD_CF from #ssds )
and SECIFRS.RECOD_D < @v_pos_booking_minus_days			--MODIF[004]
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))) --[002]
	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9))) --[002]
		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9))) --[002]
)
UNION ALL
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT,  CNATYP_CT, 1 AS TAXBAS_CF
FROM BFAC..TSECTION SECTION,
     BFAC..TCONTR CONTR,
     BFAC..TFAMCHGT FAMCHGT,
					BFAC..TSECIFRS SECIFRS
WHERE SECSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRLCK_B = 1 
--and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.CTR_NF = FAMCHGT.CTR_NF and SECTION.UWY_NF = FAMCHGT.UWY_NF and SECTION.UW_NT = FAMCHGT.UW_NT and SECTION.END_NT = FAMCHGT.END_NT and SECTION.SEC_NF = FAMCHGT.SEC_NF
and   SECTION.CTR_NF = SECIFRS.CTR_NF AND SECTION.END_NT = SECIFRS.END_NT AND SECTION.SEC_NF = SECIFRS.SEC_NF AND SECTION.UWY_NF = SECIFRS.UWY_NF AND SECTION.UW_NT = SECIFRS.UW_NT
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   isnull(FAMCHGT.TAXREF_CT,1) not in (2, 3)
and   SECTION.SSD_CF in ( select SSD_CF from #ssds )
and SECIFRS.RECOD_D < @v_pos_booking_minus_days			--MODIF[004]
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))) --[002]
	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9))) --[002]
		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9))) --[002]
)

   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go
IF OBJECT_ID('dbo.PsSECTIONI17_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSECTIONI17_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSECTIONI17_05 >>>'
go
GRANT EXECUTE ON dbo.PsSECTIONI17_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTIONI17_05 TO GDBBATCH
go
 
