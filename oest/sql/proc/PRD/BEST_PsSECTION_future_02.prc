use BEST
go
 
/*
 * DROP PROC dbo.PsSECTION_future_02  
 */
IF OBJECT_ID('dbo.PsSECTION_future_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSECTION_future_02
    PRINT '<<< DROPPED PROC dbo.PsSECTION_future_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_future_02(
	@p_clo_date char(8)
)
as

/***************************************************

Programme: PsSECTION_future_02


Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: Florian CULIOLI

Date de creation: 03/10/2022

Description du programme: 

Parametres: 

Conditions d'execution: 


Commentaires:

INITIALISATION
[001] FCI spira 105587 Onerous Q+1
[002] FCI spira 110735 FAC Accepted
*****************************************************/


declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr

declare @erreur int


BEGIN
	DECLARE
	@p_clo_date_plus_one char(8),
	@p_next_clo_date char(8),
	@year int,
	@month int
	
	SELECT @year = YEAR(@p_clo_date)
	SELECT @month = MONTH(@p_clo_date)

IF (@month = 3)
BEGIN
SELECT @p_next_clo_date = CAST(@year*10000+(@month+3)*100+30  AS CHAR(8)) --see BSV-CLO-911312 3) Closing Date
END

IF (@month = 6)
BEGIN
SELECT @p_next_clo_date = CAST(@year*10000+(@month+3)*100+30  AS CHAR(8))
END

IF (@month = 9)
BEGIN
SELECT @p_next_clo_date = CAST(@year*10000+(@month+3)*100+31  AS CHAR(8))
END

IF (@month = 12)
BEGIN
SELECT @p_next_clo_date =CAST((@year+1)*10000+03*100+31  AS CHAR(8))
END
	
	SELECT @p_clo_date_plus_one = convert(char(8), dateadd(day, 1, @p_clo_date), 112) --20140428
END

-- Sélection des familles de charges itérées (pour calculer le champ CTBCOM_B)

SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, CHGLIN_NT, RATTYP_B, MAX_R, MINRAT_R, MIN_R, MAXRAT_R
FROM	 BTRT..TSECTION SECTION, 
	 BTRT..TCONTR CONTR, 
       BTRT..TFAMCHG2 FAMCHG2,
	   BFAC..TSECIFRS SECIFRS
WHERE	 
	 (
	 (SECIFRS.FRCIFRSBTCH_NT  = 1                   	-- [001] onerous Q+1
	and CONTR.CTRINC_D >= @p_clo_date_plus_one
	and CONTR.CTRINC_D <= @p_next_clo_date)      		-- dernier jour du trimestre de closing suivant 
	OR(SECTION.SECSTS_CT = 14 AND CONTR.CTRSTS_CT =14)           -- [002] FAC Accepted  
	)
	 and SECTION.CTR_NF=SECIFRS.CTR_NF and SECTION.END_NT=SECIFRS.END_NT and SECTION.SEC_NF=SECIFRS.SEC_NF and SECTION.UWY_NF=SECIFRS.UWY_NF and SECTION.UW_NT=SECIFRS.UW_NT
     and SECTION.CTR_NF=FAMCHG2.CTR_NF and SECTION.END_NT=FAMCHG2.END_NT and SECTION.SEC_NF=FAMCHG2.SEC_NF and SECTION.UWY_NF=FAMCHG2.UWY_NF and SECTION.UW_NT=FAMCHG2.UW_NT
	 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
	 and SECTION.SSD_CF in ( select SSD_CF from #ssds ) 





   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go
IF OBJECT_ID('dbo.PsSECTION_future_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSECTION_future_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_future_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_future_02
 */
GRANT EXECUTE ON dbo.PsSECTION_future_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_future_02 TO GDBBATCH
go

