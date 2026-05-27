use BEST
go
/*
 * DROP PROC dbo.PsPeriFCI_EBS_INI_04
 */
IF OBJECT_ID('dbo.PsPeriFCI_EBS_INI_04') IS NOT NULL
BEGIN
    DROP PROC dbo.PsPeriFCI_EBS_INI_04
    PRINT '<<< DROPPED PROC dbo.PsPeriFCI_EBS_INI_04 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsPeriFCI_EBS_INI_04
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_seg_d               char(8),
  		 @p_clo_date       			char(8),
  		 @p_x_days         			int,
  		 @norme_cf         			char(4),
  		 @p_quarter_end    			varchar(10) --quarter end for dry run,       
     )
as

/***************************************************

Programme: PsPeriFCI_EBS_INI_04

Date de creation: 10/10/2025
US 7847
Description du programme: 

Création du fichier périmètre SFFPERIFCI

Parametres: 

Conditions d'execution: 


*****************************************************/
declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr


declare @erreur int

DECLARE
  @v_year_clo_date int,
  @v_month_clo_date int,
  @v_pos_booking_d datetime,
  @v_pos_booking_minus_days datetime,
  @v_clo_date datetime

-- [038]
IF(@norme_cf = 'EBS')
BEGIN
  SELECT @v_clo_date = CONVERT(datetime, @p_clo_date, 112)

  -- [039]
  IF(@p_quarter_end = 'NONE')
  BEGIN
    SELECT @v_year_clo_date = CONVERT(int, substring(@p_clo_date, 1, 4))
    SELECT @v_month_clo_date = CONVERT(int, substring(@p_clo_date, 5, 2))
    SELECT @v_pos_booking_d = EBSPSTOMGEND_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF = @v_month_clo_date
    SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * -1, @v_pos_booking_d)
  END
  ELSE 
  BEGIN
    SELECT @v_pos_booking_minus_days = dateadd(day, 1, convert(datetime, @p_quarter_end, 103) ) -- 042 convert(datetime, @p_quarter_end, 103)
  END
END

-----------------------
-- Filtre sur les dates
-----------------------

declare @date_maxTRT datetime, @date_maxFAC datetime

EXEC BEST..PsSECTION_32 @date_maxTRT output, @date_maxFAC output, @p_seg_d


--------------------------------------------------------
-- Périmètre de souscription pour les traités SFFPERIFCI
--------------------------------------------------------

-- Cas multifiliale

if @p_ssd_cf = 00
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, CHGLIN_NT, CHGTYP_B, MAX_R, MAXRAT_R, MIN_R, MINRAT_R, RATTYP_B, @p_segtyp_ct, SECTION.SSD_CF
FROM	 BTRT..TSECTION SECTION, 
	 		 BTRT..TCONTR CONTR, 
       BTRT..TFAMCHG2 FAMCHG2,
       BTRT..TSECIFRS SECIFRS       
WHERE	 SECSTS_CT in ( 14, 16, 18, 19)   
    	 and CTRSTS_CT in ( 14, 16, 18, 19)
    	 and CONTR.UWORG_CF NOT IN (247, 248)    	     
	     and CTRLCK_B <> 1 /* [003] */
       and SECINC_D<=@date_maxTRT
       and LOB_CF<>'30' and LOB_CF<>'31'
       and SECTION.CTR_NF=FAMCHG2.CTR_NF and SECTION.END_NT=FAMCHG2.END_NT and SECTION.SEC_NF=FAMCHG2.SEC_NF and SECTION.UWY_NF=FAMCHG2.UWY_NF and SECTION.UW_NT=FAMCHG2.UW_NT 
	 		 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
	 		 and SECTION.CTR_NF=SECIFRS.CTR_NF and SECTION.END_NT=SECIFRS.END_NT and SECTION.UWY_NF=SECIFRS.UWY_NF and SECTION.UW_NT=SECIFRS.UW_NT
			 and  SECTION.SSD_CF in ( select SSD_CF from #ssds)
     --and CONTR.CTRINC_D >= dateadd(day, 1, @v_clo_date )

  and ( ( @norme_cf = 'EBS' )

  and (  SECIFRS.RECOD_D < @v_pos_booking_minus_days  )
      )
  and ( SECIFRS.SIIFIRCLO_D is null ) and (( SECIFRS.SIIINISTS_CT = 1)  OR (  SECIFRS.SIIINISTS_CT is null ) )		 
END


-- Cas monofiliale

ELSE
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, CHGLIN_NT, CHGTYP_B, MAX_R, MAXRAT_R, MIN_R, MINRAT_R, RATTYP_B, @p_segtyp_ct, SECTION.SSD_CF
FROM	 BTRT..TSECTION SECTION, 
	 		 BTRT..TCONTR CONTR, 
       BTRT..TFAMCHG2 FAMCHG2,
       BTRT..TSECIFRS SECIFRS       
WHERE	 SECSTS_CT in ( 14, 16, 18, 19)   
    	 and CTRSTS_CT in ( 14, 16, 18, 19)
    	 and CONTR.UWORG_CF NOT IN (247, 248) 
         and CTRLCK_B <> 1 /* [003] */		 
      	 and SECINC_D<=@date_maxTRT
       and LOB_CF<>'30' and LOB_CF<>'31'
       and SECTION.SSD_CF=@p_ssd_cf
       and SECTION.CTR_NF=FAMCHG2.CTR_NF and SECTION.END_NT=FAMCHG2.END_NT and SECTION.SEC_NF=FAMCHG2.SEC_NF and SECTION.UWY_NF=FAMCHG2.UWY_NF and SECTION.UW_NT=FAMCHG2.UW_NT 
	 		 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
	 		 and SECTION.CTR_NF=SECIFRS.CTR_NF and SECTION.END_NT=SECIFRS.END_NT and SECTION.UWY_NF=SECIFRS.UWY_NF and SECTION.UW_NT=SECIFRS.UW_NT

     --and CONTR.CTRINC_D >= dateadd(day, 1, @v_clo_date )

  and ( ( @norme_cf = 'EBS' )

  and (  SECIFRS.RECOD_D < @v_pos_booking_minus_days  )
      )
  and ( SECIFRS.SIIFIRCLO_D is null ) and (( SECIFRS.SIIINISTS_CT = 1)  OR (  SECIFRS.SIIINISTS_CT is null ) )



	 
END

   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go
IF OBJECT_ID('dbo.PsPeriFCI_EBS_INI_04') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsPeriFCI_EBS_INI_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsPeriFCI_EBS_INI_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPeriFCI_EBS_INI_04
 */
GRANT EXECUTE ON dbo.PsPeriFCI_EBS_INI_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPeriFCI_EBS_INI_04 TO GDBBATCH
go

