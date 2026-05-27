USE BEST
go
IF OBJECT_ID('dbo.PsLORETFACTOR_INI_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLORETFACTOR_INI_01
    IF OBJECT_ID('dbo.PsLORETFACTOR_INI_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLORETFACTOR_INI_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLORETFACTOR_INI_01 >>>'
END
go

if object_id('dbo.Min2dates') is not null
begin
  drop function dbo.Min2dates
  if object_id('dbo.Min2dates') is not null
    print '<<< FAILED DROPPING function dbo.Min2dates >>>'
  else
    print '<<< DROPPED function dbo.Min2dates >>>'
end
go

if object_id('dbo.Max2dates') is not null
begin
  drop function dbo.Max2dates
  if object_id('dbo.Max2dates') is not null
    print '<<< FAILED DROPPING function dbo.Max2dates >>>'
  else
    print '<<< DROPPED function dbo.Max2dates >>>'
end
go


/*
 * creation des  fonctions 
 	Min2dates(DATE1, DATE2)   Retourne le min (date1, date2) ; si date1 < date2 alors date1 sinon date 2 
 	MAXDATE(DATE3, DATE4)     Retourne le max (date3, date4) ; si date3 < date4 alors date4 sinon date 3
  	
 	!!! Attention à la fonction datediff qui inverse le signe de la comparaison
 */  
             

CREATE FUNCTION dbo.Min2dates
(
  @DATE1 datetime, 
  @DATE2 datetime
) 
Returns Datetime 
as      
declare   @resultat datetime        
select @resultat=case when ( cast(datediff(DAY, @DATE1, @DATE2) AS numeric(5,0)) < 0 ) then @DATE2 else @DATE1 end  
return @resultat       
go


GRANT EXECUTE ON dbo.Min2dates TO GOMEGA,GDBBATCH,GCONSULT
go

CREATE FUNCTION dbo.Max2dates
(
  @DATE1 datetime, 
  @DATE2 datetime
) 
Returns Datetime 
as      
declare  @resultat datetime         
select @resultat=case when ( cast(datediff(DAY, @DATE1, @DATE2) AS numeric(5,0)) > 0 ) then @DATE2 else @DATE1 end  
return @resultat       
go

GRANT EXECUTE ON dbo.Max2dates TO GOMEGA,GDBBATCH,GCONSULT
go


/*
 * creation de la procedure
 */
CREATE PROCEDURE dbo.PsLORETFACTOR_INI_01
(
    @p_ICLODAT_D   datetime,
    @p_clo_date    datetime,
    @p_next_clo_date   datetime,
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10),   --, --quarter end for dry run,
    @p_typeinv_cf 	char(4)
)    

AS


/***************************************************

Programme:              PsLORETFACTOR_INI_01
Fichier script associé: PsLORETFACTOR_INI_01.PRC
Domaine:                (ES) Estimation
Base principale:        BEST
Version:                :US 7847: REQ11.7.2 RETRO AT INCEPTION   --> Genere le fichier LORETFACTOR EBS INI
Auteur:                 MZM
Date de creation:       22/01/2026
Description du programme:
		a)  même travail que PsCESSION_01:
				Extraction des versements de la base retrocession
				avec selection des versements valides et actifs ou historises et supprimes.
				
    b)  ajout pour prise en compte des champs: BLCSHTSTR_D et BLCSHTEND_D
    
		c) Ajout de la colonne LOFACTOR : Determination of the logical unit for the expenses calculations on Assumed and Retro sides

Parametres: Clodat 
Conditions d'execution:
*****************************************************
Modifications
001 - 
*****************************************************/



DECLARE
@v_pos_booking_minus_days datetime

IF(@p_quarter_end = 'NONE')
BEGIN
  
  DECLARE @v_year_clo_date int
  DECLARE @v_month_clo_date int
  DECLARE @v_pos_booking_d datetime
  
  --SELECT @v_year_clo_date = CONVERT(int, substring(@p_clo_date, 1, 4))
  --SELECT @v_month_clo_date = CONVERT(int, substring(@p_clo_date, 5, 2))
  
  SELECT @v_year_clo_date = datepart(yy,@p_clo_date)
  SELECT @v_month_clo_date = datepart(mm,@p_clo_date) 				
  
  SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date --[002]
  SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * -1, @v_pos_booking_d)
END
ELSE 
BEGIN
  SELECT @v_pos_booking_minus_days = convert(datetime, @p_quarter_end, 103)
END


-- [017]
declare @sts_list table (Id TINYINT)
insert into @sts_list values (16)
insert into @sts_list values (18)
insert into @sts_list values (19)

IF(@p_typeinv_cf = 'POS')
BEGIN
  insert into @sts_list values (14)
END


DECLARE @p_ssd_cf    USSD_CF
DECLARE @erreur INT
DECLARE @curr_usr UUPDUSR_CF
SELECT @curr_usr = USER_NAME()

SELECT
    BATCHUSER_CF,
    SSD_CF
INTO #ssds
FROM BREF..TBATCHSSD
WHERE BATCHUSER_CF = @curr_usr 
        
SELECT distinct
            a.CTR_NF,
            c.END_NT, --0 END_NT, 
            a.SEC_NF,
            a.UWY_NF,
            a.UW_NT,
            a.RETCTR_NF,
            0 RETEND_NT,
            a.RETSEC_NF,
            a.RTY_NF,
            1 RETUW_NT,
            a.CESACCSTA_N,
            a.CESACCEND_N,
            a.CESSH_R,
            a.SSD_CF,
            b.esb_cf,
            b.retctrcat_cf,
            a.ACCADMTYP_CT,
            b.retaccadm_b,
            b.clecutper_b,
            b.clecutper_nb,
            a.LOB_CF,
           ' ' CUR_CF,
            b.retpcpcur_cf,
            b.CONRETCTR_B,
            b.ACCFAM_CT,                    
            b.RETACCTYP_CT,
            convert(char(8), b.ctrexp_d, 112) retexp_d, 
            convert(char(8), ISNULL(c.scoexp_d, c.ctrexp_d), 112) ctrexp_d,
            --convert(char(8), @p_ICLODAT_D, 112) CLODAT_D,  
						convert(char(8), c.ctrinc_d, 112) ctrinc_d,                   
            LOFACTOR = 
                              case
                                    when (b.RETACCTYP_CT in (1,2,4) OR b.RETACCTYP_CT IS NULL) OR (c.ctrexp_d IS NULL AND c.scoexp_d IS NULL) --(b.RETACCTYP_CT in (3,5) OR b.RETACCTYP_CT IS NULL) 
                                        then 1
                                    when (  ( (a.ACCADMTYP_CT in (1,3,4,5) ) AND (cast(datediff(DAY, ISNULL(c.scoexp_d, c.ctrexp_d), b.CTRINCUWY_D) AS numeric(5,0)) > 0 ) ) OR (cast(datediff(DAY, c.ctrinc_d, b.ctrexp_d) AS numeric(5,0)) < 0)  )
                                        then 0	
                                        
                                    when (a.ACCADMTYP_CT in (1,3,4,5) AND  (cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) AND 
                                          (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1,dbo. Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) >= cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ))              --01
                                        then 1                                         
                                         
                                    when (  a.ACCADMTYP_CT in (1,3,4,5) AND  (cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) 
                                            AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) <= cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ) 
                                            --AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D,c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(c.ctrexp_d, b.ctrexp_d)) ) AS numeric(5,0)) >= 0 ) 
                                          )
                                        then cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) / cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))                --001
                                                                                                                 
                                        
                                    when ( ((a.ACCADMTYP_CT = 2) AND  (cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0 )) AND 
                                          (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) >= cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))) )  --001
                                        then 1                                             
                                    
                                    when ((a.ACCADMTYP_CT = 2) AND  (cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) 
                                          AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) <= cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ) )
                                          --AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) >= 0 )
                                        then cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) / cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))                --001
                                                                                                                                                          
                                    else 0 
                                end, 
						convert(char(8), b.CTRINCUWY_D, 112) retinc_d -- Inception Retro date                                                                                       				                       
        --INTO #LORETFACTOR
        FROM
            bret..tcession a,
            bret..tretctr b,
             #ssds s,
             btrt..tcontr c, 
             btrt..tsection e,
             btrt..tsecifrs f   --[013]     
         WHERE
            --a.cessts_cf IN ('01', '03')   AND  --[011]
            ((a.cesupdtyp_cf = '' AND
             a.cessts_cf = '01') OR
            (a.cesupdtyp_cf = 'S' AND
            a.cessts_cf = '03'))    AND
            a.CESSIONCAT_CF = "1"   AND   --[012]
            
            a.retctr_nf *= b.retctr_nf  AND
            a.rty_nf *= b.rty_nf         AND
            a.ssd_cf *= b.ssd_cf    and             
            
            a.UWY_NF = c.UWY_NF   	and
            a.UW_NT = c.UW_NT      	and
            a.CTR_NF = c.CTR_NF     and 
 
            a.UWY_NF = e.UWY_NF   	and
            a.UW_NT  = e.UW_NT    	and
            a.CTR_NF  = e.CTR_NF    and 
            a.SEC_NF  = e.SEC_NF    and 
            a.ssd_cf    = e.ssd_cf 	and            
                                          --[013]
            f.UWY_NF = e.UWY_NF   	and
            f.UW_NT  = e.UW_NT    	and
            f.CTR_NF  = e.CTR_NF    and 
            f.SEC_NF  = e.SEC_NF    and 
            f.end_nt  = e.end_nt 	  and 
        
            a.ssd_cf = s.ssd_cf     and               
            
            c.ctr_nf = e.ctr_nf			and   
            c.UW_NT =  e.UW_NT			and   
            c.UWY_NF = e.UWY_NF			and            
            
            b.ctrexp_d IS NOT NULL  and
            --c.ctrexp_d IS NOT NULL  and
            -- CTRSTS_CT IN (16, 18, 19) -- [010]
            (CTRSTS_CT IN (14, 16, 17, 19)  OR 
            ( (cast(datediff(DAY, @p_clo_date, c.CTRINC_D) AS numeric(5,0)) >= 0 ) and
               (cast(datediff(DAY, @p_next_clo_date, c.CTRINC_D) AS numeric(5,0)) <= 0 ) and
               (f.FRCIFRSBTCH_NT  = 1)) 
            )     -- [013]
            
					and (f.RECOD_D <= @v_pos_booking_minus_days or (@p_typeinv_cf = 'POS' and CTRSTS_CT in (12))) --[018]
					and ( 
								 (@norme_cf = 'EBS' 
                                  and f.SIIFIRCLO_D IS NULL 
                                  and ( f.SIIINISTS_CT  IS NULL OR f.SIIINISTS_CT = 1 ) )       
                       )           
           
union        
SELECT distinct
            a.CTR_NF,
            c.END_NT, --0 END_NT,
            a.SEC_NF,
            a.UWY_NF,
            a.UW_NT,
            a.RETCTR_NF,
            0 RETEND_NT,
            a.RETSEC_NF,
            a.RTY_NF,
            1 RETUW_NT,
            a.CESACCSTA_N,
            a.CESACCEND_N,
            a.CESSH_R,
            a.SSD_CF,
            b.esb_cf,
            b.retctrcat_cf,
            a.ACCADMTYP_CT,
            b.retaccadm_b,
            b.clecutper_b,
            b.clecutper_nb,
            a.LOB_CF,
           ' ' CUR_CF,
            b.retpcpcur_cf,
            b.CONRETCTR_B,
            b.ACCFAM_CT,                    
            b.RETACCTYP_CT,
            convert(char(8), b.ctrexp_d, 112) retexp_d, 
            convert(char(8), ISNULL(c.ctrexp_d, c.scoexp_d), 112) ctrexp_d,
            --convert(char(8), @p_ICLODAT_D, 112) CLODAT_D,
            convert(char(8), c.ctrinc_d, 112) ctrinc_d,   --cast(LOFACTOR AS numeric(18, 3))                                          
            LOFACTOR = 
                              case
                                    when (b.RETACCTYP_CT in (1,2,4) OR b.RETACCTYP_CT IS NULL) OR (c.ctrexp_d IS NULL AND c.scoexp_d IS NULL) --(b.RETACCTYP_CT in (3,5) OR b.RETACCTYP_CT IS NULL) 
                                        then 1
                                    when (  ( (a.ACCADMTYP_CT in (1,3,4,5) ) AND (cast(datediff(DAY, ISNULL(c.scoexp_d, c.ctrexp_d), b.CTRINCUWY_D) AS numeric(5,0)) > 0 ) ) OR (cast(datediff(DAY, c.ctrinc_d, b.ctrexp_d) AS numeric(5,0)) < 0)  )
                                        then 0	
                                        
                                    when (a.ACCADMTYP_CT in (1,3,4,5) AND  (cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) AND 
                                          (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1,dbo. Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) >= cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ))              --01
                                        then 1                                         
                                         
                                    when (  a.ACCADMTYP_CT in (1,3,4,5) AND  (cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) 
                                            AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) <= cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ) 
                                            --AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D,c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(c.ctrexp_d, b.ctrexp_d)) ) AS numeric(5,0)) >= 0 ) 
                                          )
                                        then cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) / cast(datediff(DAY, c.ctrinc_d, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))                --001
                                                                                                                 
                                        
                                    when ( ((a.ACCADMTYP_CT = 2) AND  (cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0 )) AND 
                                          (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) >= cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))) )  --001
                                        then 1                                             
                                    
                                    when ((a.ACCADMTYP_CT = 2) AND  (cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) 
                                          AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) <= cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ) )
                                          --AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) >= 0 )
                                        then cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, c.ctrinc_d), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) / cast(datediff(DAY, c.ctrinc_d, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))                --001
                                                                                                                                                          
                                    else 0 
                                end, 
						convert(char(8), b.CTRINCUWY_D, 112) retinc_d -- Inception Retro date                                                                                                				                       
        --INTO #LORETFACTOR
        FROM
            bret..tcession a,
            bret..tretctr b,
             #ssds s,
             bfac..tcontr c, 
             bfac..tsection e,
             bfac..tsecifrs f   --[013]            
         WHERE
            --a.cessts_cf IN ('01', '03')   AND  --[011]
            ((a.cesupdtyp_cf = '' AND
             a.cessts_cf = '01') OR
            (a.cesupdtyp_cf = 'S' AND
            a.cessts_cf = '03'))    AND
            a.CESSIONCAT_CF = "1"   AND   --[012]
            
            a.retctr_nf *= b.retctr_nf  AND
            a.rty_nf *= b.rty_nf        AND
            a.ssd_cf *= b.ssd_cf       and               
            
            a.UWY_NF = c.UWY_NF   	and
            a.UW_NT = c.UW_NT      	and
            a.CTR_NF = c.CTR_NF     and 
 
            a.UWY_NF = e.UWY_NF   	and
            a.UW_NT  = e.UW_NT    	and
            a.CTR_NF  = e.CTR_NF    and 
            a.SEC_NF  = e.SEC_NF    and 
            a.ssd_cf    = e.ssd_cf 	and
                                          --[013]
            f.UWY_NF = e.UWY_NF   	and
            f.UW_NT  = e.UW_NT    	and
            f.CTR_NF  = e.CTR_NF    and 
            f.SEC_NF  = e.SEC_NF    and 
            f.end_nt  = e.end_nt 	  and                        
        
            a.ssd_cf = s.ssd_cf     and             
            
            c.ctr_nf = e.ctr_nf			and   
            c.UW_NT =  e.UW_NT			and   
            c.UWY_NF = e.UWY_NF			and            
            
            b.ctrexp_d IS NOT NULL  and

            ((CTRSTS_CT IN (select Id from @sts_list) and CTRLCK_B != 0) OR 
            
             ( (cast(datediff(DAY, @p_clo_date, c.CTRINC_D) AS numeric(5,0)) >= 0 ) and
               (cast(datediff(DAY, @p_next_clo_date, c.CTRINC_D) AS numeric(5,0)) <= 0 ) and
               (f.FRCIFRSBTCH_NT  = 1))           
            
            )   --[013] 
            --CTRSTS_CT IN (14, 16, 17, 19)
					and (f.RECOD_D <= @v_pos_booking_minus_days or (@p_typeinv_cf = 'POS' and CTRSTS_CT in (12, 14))) --[018]
					and ( 
								 (@norme_cf = 'EBS' 
                                  and f.SIIFIRCLO_D IS NULL 
                                  and ( f.SIIINISTS_CT  IS NULL OR f.SIIINISTS_CT = 1 ) )       
                       )   
           
            
        SELECT @erreur = @@ERROR
        IF @erreur != 0
            BEGIN
                RAISERROR 20005 "APPLICATIF;TCESSION"
                RETURN @erreur
            END
        RETURN 0
go
EXEC sp_procxmode 'dbo.PsLORETFACTOR_INI_01', 'unchained'
go
IF OBJECT_ID('dbo.PsLORETFACTOR_INI_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLORETFACTOR_INI_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLORETFACTOR_INI_01 >>>'
go
GRANT EXECUTE ON dbo.PsLORETFACTOR_INI_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLORETFACTOR_INI_01 TO GDBBATCH
go

