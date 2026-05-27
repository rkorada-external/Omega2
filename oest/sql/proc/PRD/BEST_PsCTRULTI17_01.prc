USE BEST
go

/*
 * DROP PROC dbo.PsCTRULTI17_01
 */
IF OBJECT_ID('dbo.PsCTRULTI17_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCTRULTI17_01
    PRINT '<<< DROPPED PROC dbo.PsCTRULTI17_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCTRULTI17_01(
		@p_clo_date char(8),
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
)
     
as

/***************************************************

Programme: PsCTRULTI17_01

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: Arnaud RUFFAULT

Date de creation: 07/06/2021

Description du programme: 
			Cree a partir de la procedure PsCTRULT_01 utilse dans IFRS4
   Selection des enregistrements les plus récents de la table TCTRULT en segemntation et en inventaire
 

Parametres:
 

Conditions d'execution: 


Commentaires:
_________________
MODIFICATIONS
[001] ART spira 97478 IFRS17 DryRun- Recognition date test for pericase
[002] ART spira 100168 FRS17 inception pericase- Extract Run-off if transition mode
[003] ART spira 999999 IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
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
	SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date  --[003]
	SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * -1, @v_pos_booking_d)
END
ELSE 
BEGIN
	SELECT @v_pos_booking_minus_days = convert(datetime, @p_quarter_end, 103)
END

declare @erreur      int        

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr



select @erreur = 0

select 
        A.CTR_NF,
        A.END_NT,
        A.SEC_NF,
    A.UWY_NF,
        A.UW_NT,
    CONVERT(char(8), A.CRE_D, 112),
    A.SSD_CF,
    A.DIV_NT,
    A.CUR_CF,
    A.CALAMTPRM_M,
    A.ENTAMTPRM_M,
    A.RETAMTPRM_M,
    A.ADMMODPRM_CT,
    A.RESPRM_M,
    A.CALAMTCLM_M,
    A.ENTAMTCLM_M,
    A.RETAMTCLM_M,
    A.ADMMODCLM_CT,
    A.ORICOD_LS,
    A.UPDUSR_CF,
    A.CREUSR_CF,
    CONVERT(char(8), A.LSTUPD_D, 112),
    A.LSTUPDUSR_CF 
from    BEST..TCTRULT A 
inner join #ssds S on A.SSD_CF = S.SSD_CF
inner join BTRT..TSECIFRS SECIFRS ON A.CTR_NF = SECIFRS.CTR_NF AND A.END_NT = SECIFRS.END_NT AND A.SEC_NF = SECIFRS.SEC_NF AND A.UWY_NF = SECIFRS.UWY_NF AND A.UW_NT = SECIFRS.UW_NT
where A.CRE_D = ( select max(b.CRE_D) from BEST..TCTRULT b
                  where a.CTR_NF = b.CTR_NF
                  and   a.END_NT = b.END_NT
                  and   a.SEC_NF = b.SEC_NF
                  and   a.UWY_NF = b.UWY_NF
                  and   a.UW_NT  = b.UW_NT   )
and SECIFRS.RECOD_D <= @v_pos_booking_minus_days
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)) --002
	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9)) --002
		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9)) --002
)
order by A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT


select @erreur = @@error

if @erreur != 0  goto fin


               
/**********************************************************************************/

return 0

fin:

return 1
go

/*
 * fin de la procedure 
 */

/*   Insertion dans la table des procedures
 *-------------------------------------------*/

go

IF OBJECT_ID('PsCTRULTI17_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsCTRULTI17_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsCTRULTI17_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsCTRULTI17_01
 */
GRANT EXECUTE ON PsCTRULTI17_01 TO GOMEGA
go
GRANT EXECUTE ON PsCTRULTI17_01 TO GDBBATCH
go

