use BEST
go

IF OBJECT_ID('dbo.PsPeriFCT_BBNI_05') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPeriFCT_BBNI_05
    IF OBJECT_ID('dbo.PsPeriFCT_BBNI_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPeriFCT_BBNI_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPeriFCT_BBNI_05 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PsPeriFCT_BBNI_05
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

Programme: PsPeriFCT_BBNI_05

Description du programme:
	- création du fichier périmètre (S/I)ADPERIFCT

Parametres:

Conditions d'execution:
Test:
BEST..PsPeriFCT_BBNI_05 '1' , 2 , '20180501' 

Commentaires:

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


--------------------------------------------------------------------
-- Périmètre de souscription pour les traités et les facs SFFPERIFCT
--------------------------------------------------------------------

-- Cas multifiliale

if @p_ssd_cf = 00
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT, CNATYP_CT, 1 AS TAXBAS_CF
FROM   BTRT..TSECTION SECTION,
       BTRT..TCONTR CONTR,
       BTRT..TFAMCHGT FAMCHGT,
       BTRT..TSECIFRS SECIFRS
       
WHERE	 SECSTS_CT in ( 14, 16, 18, 19)   
    	 and CTRSTS_CT in ( 14, 16, 18, 19)
    	 and CONTR.UWORG_CF NOT IN (247, 248) 
and   CTRLCK_B <> 1 
and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.CTR_NF=FAMCHGT.CTR_NF and SECTION.UWY_NF=FAMCHGT.UWY_NF and SECTION.UW_NT=FAMCHGT.UW_NT and SECTION.END_NT=FAMCHGT.END_NT and SECTION.SEC_NF=FAMCHGT.SEC_NF
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   SECTION.CTR_NF=SECIFRS.CTR_NF and SECTION.END_NT=SECIFRS.END_NT and SECTION.UWY_NF=SECIFRS.UWY_NF and SECTION.UW_NT=SECIFRS.UW_NT
and   SECTION.SSD_CF in ( select SSD_CF from #ssds )
UNION ALL
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT,  CNATYP_CT, 1 AS TAXBAS_CF
FROM BFAC..TSECTION SECTION,
     BFAC..TCONTR CONTR,
     BFAC..TFAMCHGT FAMCHGT,
     BFAC..TSECIFRS SECIFRS
WHERE	 SECSTS_CT in ( 14, 16, 18, 19)   
    	 and CTRSTS_CT in ( 14, 16, 18, 19)
    	 and CONTR.UWORG_CF NOT IN (247, 248) 
and   CTRLCK_B = 1 
and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.CTR_NF=FAMCHGT.CTR_NF and SECTION.UWY_NF=FAMCHGT.UWY_NF and SECTION.UW_NT=FAMCHGT.UW_NT and SECTION.END_NT=FAMCHGT.END_NT and SECTION.SEC_NF=FAMCHGT.SEC_NF
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   SECTION.CTR_NF=SECIFRS.CTR_NF and SECTION.END_NT=SECIFRS.END_NT and SECTION.UWY_NF=SECIFRS.UWY_NF and SECTION.UW_NT=SECIFRS.UW_NT
and   isnull(FAMCHGT.TAXREF_CT,1) not in (2, 3)
and   SECTION.SSD_CF in ( select SSD_CF from #ssds )
  and CONTR.CTRINC_D >= dateadd(day, 1, @v_clo_date )
  and ( ( @norme_cf = 'EBS' ) 
 
  and (  SECIFRS.RECOD_D < @v_pos_booking_minus_days  ) 
      )
END

-- Cas monofiliale

ELSE
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT,  CNATYP_CT, 1 AS TAXBAS_CF
FROM BTRT..TSECTION SECTION,
     BTRT..TCONTR CONTR,
     BTRT..TFAMCHGT FAMCHGT,
     BTRT..TSECIFRS SECIFRS
WHERE	 SECSTS_CT in ( 14, 16, 18, 19)   
    	 and CTRSTS_CT in ( 14, 16, 18, 19)
    	 and CONTR.UWORG_CF NOT IN (247, 248) 
and   CTRLCK_B <> 1 --[003]
and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.SSD_CF=@p_ssd_cf
and   SECTION.CTR_NF=FAMCHGT.CTR_NF and SECTION.UWY_NF=FAMCHGT.UWY_NF and SECTION.UW_NT=FAMCHGT.UW_NT and SECTION.END_NT=FAMCHGT.END_NT and SECTION.SEC_NF=FAMCHGT.SEC_NF
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   SECTION.CTR_NF=SECIFRS.CTR_NF and SECTION.END_NT=SECIFRS.END_NT and SECTION.UWY_NF=SECIFRS.UWY_NF and SECTION.UW_NT=SECIFRS.UW_NT
UNION ALL
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT,  CNATYP_CT , 1 AS TAXBAS_CF
FROM BFAC..TSECTION SECTION,
     BFAC..TCONTR CONTR,
     BFAC..TFAMCHGT FAMCHGT,
     BFAC..TSECIFRS SECIFRS
WHERE	 SECSTS_CT in ( 14, 16, 18, 19)   
    	 and CTRSTS_CT in ( 14, 16, 18, 19)
    	 and CONTR.UWORG_CF NOT IN (247, 248) 
and   CTRLCK_B = 1 --[003] [004]
and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.SSD_CF=@p_ssd_cf
and   SECTION.CTR_NF=FAMCHGT.CTR_NF and SECTION.UWY_NF=FAMCHGT.UWY_NF and SECTION.UW_NT=FAMCHGT.UW_NT and SECTION.END_NT=FAMCHGT.END_NT and SECTION.SEC_NF=FAMCHGT.SEC_NF
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   SECTION.CTR_NF=SECIFRS.CTR_NF and SECTION.END_NT=SECIFRS.END_NT and SECTION.UWY_NF=SECIFRS.UWY_NF and SECTION.UW_NT=SECIFRS.UW_NT
and   isnull(FAMCHGT.TAXREF_CT,1) not in (2, 3)
  and CONTR.CTRINC_D >= dateadd(day, 1, @v_clo_date )
  and ( ( @norme_cf = 'EBS' ) 
  			and (  SECIFRS.RECOD_D < @v_pos_booking_minus_days  ) 
      )
END

   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go
IF OBJECT_ID('dbo.PsPeriFCT_BBNI_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPeriFCT_BBNI_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPeriFCT_BBNI_05 >>>'
go
GRANT EXECUTE ON dbo.PsPeriFCT_BBNI_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPeriFCT_BBNI_05 TO GDBBATCH
go
 
