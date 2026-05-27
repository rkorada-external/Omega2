use BEST
go

/* DROP PROC dbo.PsFAMPROTI17_01
*/
IF OBJECT_ID('dbo.PsFAMPROTI17_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsFAMPROTI17_01
   PRINT '<<< DROPPED PROC dbo.PsFAMPROTI17_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsFAMPROTI17_01(
		@p_clo_date char(8),
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
)
     
as

/***************************************************

Programme: PsFAMPROTI17_01

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: Arnaud RUFFAULT

Date de creation: 08/06/2021

Description du programme: 
	Cree a partir de la procedure PsFAMPROT_01 utitlise en IFRS4
	Descente de la table BFAC..TFAMPROT 

Parametres: 

Conditions d'execution: 

Commentaires:


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

select @erreur = 0

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr



/***************************************/
/* Descente de la table BFAC..TFAMPROT */
/***************************************/

select S.SSD_CF, F.CTR_NF, F.END_NT , F.SEC_NF, F.UWY_NF, F.UW_NT, LAYTYP_CT, LAYCOS_M, LAYPLCSHA_R
from   BFAC..TFAMPROT F, BFAC..TSECTION S , #ssds BS, BFAC..TSECIFRS SECIFRS
where F.CTR_NF = S.CTR_NF and F.END_NT = S.END_NT and F.SEC_NF = S.SEC_NF and F.UWY_NF = S.UWY_NF and F.UW_NT = S.UW_NT
and F.CTR_NF = SECIFRS.CTR_NF AND F.END_NT = SECIFRS.END_NT AND F.SEC_NF = SECIFRS.SEC_NF AND F.UWY_NF = SECIFRS.UWY_NF AND F.UW_NT = SECIFRS.UW_NT
and S.SSD_CF = BS.SSD_CF
and SECIFRS.RECOD_D < @v_pos_booking_minus_days			--MODIF[004]
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))) --[002]
	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9))) --[002]
		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9))) --[002]
)
order by CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT

select @erreur = @@error

if @erreur != 0
   begin
      return @erreur
   end

return 0
go

/*
 * fin de la procedure 
 */


IF OBJECT_ID('dbo.PsFAMPROTI17_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsFAMPROTI17_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsFAMPROTI17_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsFAMPROTI17_01
 */
GRANT EXECUTE ON dbo.PsFAMPROTI17_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFAMPROTI17_01 TO GDBBATCH
go

