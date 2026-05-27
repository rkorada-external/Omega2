use BEST
go

 /* DROP PROC dbo.PsSECTIONI17_11 
*/
IF OBJECT_ID('dbo.PsSECTIONI17_11') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSECTIONI17_11
   PRINT '<<< DROPPED PROC dbo.PsSECTIONI17_11 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTIONI17_11
     (
       @p_segtyp_ct           char(1),
       @p_seg_d               char(8),
		@p_clo_date            char(8),
		@p_x_days              int,
		@norme_cf              char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
     )
as

/***************************************************

Programme: PsSECTIONI17_11

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: Florian CULIOLI

Date de creation: 03/10/2022

Description du programme: 
						Cree a partir de la procedure PsSECTION_03 utilise dans IFRS4
      Création du fichier périmètre SFFPERIFR

Parametres: 

Conditions d'execution: 


Commentaires:
_________________
INITIALISATION
[001] FCI spira 105587 Onerous Q+1
*****************************************************/


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
	print '==> @p_next_clo_date = %1!', @p_next_clo_date
	print '==> @p_clo_date_plus_one = %1!', @p_clo_date_plus_one
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


-------------------------------------------------------
-- Périmètre de souscription pour les traités SFFPERIFR
-------------------------------------------------------

-- Cas multifiliale


SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, REILIN_NT, REIPRM_M, REIPRM_R, REIPRMBAS_R, REIRNK_N, @p_segtyp_ct, SECTION.SSD_CF, REIPROTMP_B, REIPRMPTP_R
FROM	 BTRT..TSECTION SECTION, 
	     BTRT..TCONTR CONTR, 
      BTRT..TFAMREI FAMREI,
						BTRT..TSECIFRS SECIFRS
WHERE	 LOB_CF<>'30' and LOB_CF<>'31'
and SECTION.CTR_NF = FAMREI.CTR_NF and SECTION.END_NT = FAMREI.END_NT and SECTION.SEC_NF = FAMREI.SEC_NF and SECTION.UWY_NF = FAMREI.UWY_NF and SECTION.UW_NT = FAMREI.UW_NT
and SECTION.CTR_NF = SECIFRS.CTR_NF and SECTION.END_NT = SECIFRS.END_NT and SECTION.SEC_NF = SECIFRS.SEC_NF and SECTION.UWY_NF = SECIFRS.UWY_NF and SECTION.UW_NT = SECIFRS.UW_NT
and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and SECTION.SSD_CF in ( select SSD_CF from #ssds )
and SECIFRS.FRCIFRSBTCH_NT  = 1                   		-- onerous Q+1
and CONTR.CTRINC_D >= @p_clo_date_plus_one
and CONTR.CTRINC_D <= @p_next_clo_date      			-- dernier jour du trimestre de closing suivant
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))) --[002]
 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9))) --[002]
 or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9))) --[002]
 or (@norme_cf = 'I17S' and ( SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)))
)




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

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

IF OBJECT_ID('dbo.PsSECTIONI17_11') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSECTIONI17_11 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSECTIONI17_11 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTIONI17_11
 */
GRANT EXECUTE ON dbo.PsSECTIONI17_11 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTIONI17_11 TO GDBBATCH
go

