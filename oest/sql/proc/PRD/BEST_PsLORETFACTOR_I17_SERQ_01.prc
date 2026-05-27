USE BEST
go
IF OBJECT_ID('dbo.PsLORETFACTOR_I17_SERQ_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLORETFACTOR_I17_SERQ_01
    IF OBJECT_ID('dbo.PsLORETFACTOR_I17_SERQ_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLORETFACTOR_I17_SERQ_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLORETFACTOR_I17_SERQ_01 >>>'
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
CREATE PROCEDURE dbo.PsLORETFACTOR_I17_SERQ_01
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

Programme:              PsLORETFACTOR_I17_SERQ_01
Fichier script associé: PsLORETFACTOR_I17_SERQ_01.PRC
Domaine:                (ES) Estimation
Base principale:        BEST
Version:                :spira:79070: REQ11.7.2 RETRO AT INCEPTION   --> Genere le fichier ESPD0060_FLORETFACTOR_INI_TYPEINV_DATECLOSING
Auteur:                 MZM
Date de creation:       21/02/2020
Description du programme:
		a)  même travail que PsCESSION_01:
				Extraction des versements de la base retrocession
				avec selection des versements valides et actifs ou historises et supprimes.
				
    b)  ajout pour prise en compte des champs: BLCSHTSTR_D et BLCSHTEND_D
    
		c) Ajout de la colonne LOFACTOR : Determination of the logical unit for the expenses calculations on Assumed and Retro sides
BEST..PsLORETFACTOR_I17_01   '20250930', '20250930', '20250908', 5, 'I17G', 'NONE', 'INV'
Parametres: Clodat 
Conditions d'execution:
*****************************************************
Modifications
001 16/07/2020 : spira88641 : LO factor change ; Si LOFACTOR >= 1 return 1 ; Si LOFACTOR <= 0 alors return 0 ;
002 29/09/2020 : spira90120 : LO factor change ; USE INCEPTION DATE instead of Closing Date ;
003 12/10/2020 : spira90724 : LO factor change ; Date Retro + 1 : SI a.ACCADMTYP_CT in (1,3,4,5) ;
004 04/12/2020 : spira91167 : LO factor change ; ( assumed contract inception date > retro expiry date)  or (assumed contract risk period ending date < retro inception date) ;		
--                                                LO Retro Factor = 0 
005 15/12/2020 : spira91272 LO Factor - Formula Change : = [(min(assumed contract risk period ending date, retro expiry date) - max(retro inception date, Ass Contract inception date)) + 1 ] / 
                                                               [(assumed contract risk period ending date (R01-02) - Assume Contract Inception date) + 1] 

Assumed risk period ending date definition

- if the assumed contract is clean cut (ACCADMTYP_CT = 1 or 4) then "contract expiry date"

- if the assumed contract is loss occuring  (ACCADMTYP_CT = 3 or 5) then "contract expiry date"

Spira 88641

- if the assumed contract is risk attaching ( ACCADMTYP_CT = 2) then "contract expiry date" + 365

End Spira 88641
006 08/07/2021 : spira 97075 : Assumed ctrexp_d est vide on récupère la valeur du champ Assumed scoexp_d 
TRAITES
	Si scoexp_d est vide on récupère la valeur du champ ctrexp_d. Si ce dernier est vide, Lo Retro Factor = 1 
FAC :
	Si ctrexp_d est vide on récupère la valeur du champ scoexp_d. Si ce dernier est vide, Lo Retro Factor = 1
007 12/08/2021 : spira95950 LO Factor - Forma numeric(18,3) --> numeric(5,0)
008 15/09/2021 : spira98764 Complement livraison Delta EBS LOFACTOR
009 12/10/2021 : spira99008 Format LOFACTOR 
[010] 23/02/2022 : DaD : spira 101988 LO Factor - Status update
[011] 23/05/2022 : MZM : spira 104396 LO Factor - Cession Status update
[012] 08/08/2022 : MZM : spira 105660 LO FACTOR Table update process (Revert de la 204396) 
[013] 17/10/2022 : MZM : spira 102482 IFRS17 Onerous Q+1 - additional scope
[014] 20/10/2022 : MZM : spira 105660 LO FACTOR Table update process I17 
[015] 15/11/2022 : MZM : spira 107535 LO FACTOR Missing INI cession - Future contracts 
[016] 28/11/2022 : MZM : spira 105660 LO FACTOR Table update process I17 (Fix BUG UAT suppression des Separateurs Section DECLARE ...)
[017] 26/09/2023 : DAD : spira 109347 EBS/I17 - Fac status Accepted only POS
[018] 19/07/2024 : DAD : spira 111932 Missing LO retro factor INI
[018] 13/08/2025 : M.NAJI US5850 SERQS - Impact estimation IFRS17
[019] 25/11/2025 : M.NAJI US7359 SERQS - fix doublons
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
  SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * (-1) + 1, @v_pos_booking_d)
END
ELSE 
BEGIN
  SELECT @v_pos_booking_minus_days =   dateadd(day,  1, convert(datetime, @p_quarter_end, 103))
 
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

-- SELECT
--     BATCHUSER_CF,
--     SSD_CF
-- INTO #ssds
-- FROM BREF..TBATCHSSD
-- WHERE BATCHUSER_CF = @curr_usr 
        
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
            b.SSD_CF,
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
        FROM					bret..tcession a
				join   BREF..TBATCHSSD bssd on   bssd.ssd_cf = a.ACCSSD_CF and bssd.BATCHUSER_CF =@curr_usr
				left outer join bret..tretctr b  on a.retctr_nf=b.retctr_nf    and a.rty_nf=b.rty_nf --and a.ssd_cf = b.ssd_cf 
				join  			btrt..tcontr c   on a.UWY_NF = c.UWY_NF and a.UW_NT = c.UW_NT and a.CTR_NF = c.CTR_NF
				join  			btrt..tsection e on a.UWY_NF = e.UWY_NF and a.UW_NT = e.UW_NT and a.CTR_NF  = e.CTR_NF and a.SEC_NF  = e.SEC_NF --and  a.ssd_cf = e.ssd_cf
				join  			btrt..tsecifrs f on f.UWY_NF = e.UWY_NF and f.UW_NT = e.UW_NT and f.CTR_NF  = e.CTR_NF and f.SEC_NF  = e.SEC_NF and  f.end_nt  = e.end_nt
				left outer join BREF..TBATCHSSD acc on   a.ACCSSD_CF = acc.SSD_CF
				left outer join   BREF..TBATCHSSD ret on    a.RETSSD_CF = ret.SSD_CF
        WHERE
            ((a.cesupdtyp_cf = '' AND
             a.cessts_cf = '01') OR
            (a.cesupdtyp_cf = 'S' AND
            a.cessts_cf = '03'))    AND
            a.CESSIONCAT_CF = "1"   AND   --[012]
             ( ( a.ssd_cf = 99 and acc.BATCHUSER_CF  = ret. BATCHUSER_CF ) or (acc.BATCHUSER_CF  != ret.BATCHUSER_CF and a.ssd_cf = 99 ) ) and 
            b.ctrexp_d IS NOT NULL  and
            (CTRSTS_CT IN (14, 16, 17, 19)  OR 
				( 	(cast(datediff(DAY, @p_clo_date, c.CTRINC_D) AS numeric(5,0)) >= 0 ) and
					(cast(datediff(DAY, @p_next_clo_date, c.CTRINC_D) AS numeric(5,0)) <= 0 ) and
					(f.FRCIFRSBTCH_NT  = 1)
				) 
            )     -- [013]
        	and (f.RECOD_D <= @v_pos_booking_minus_days or (@p_typeinv_cf = 'POS' and CTRSTS_CT in (12))) --[018]
			and ( 
					   (@norme_cf = 'I17G' and ( f.GRPINISTS_CT  IS NULL OR f.GRPINISTS_CT = 1 ) ) --014
					or (@norme_cf = 'I17P' and ( f.PARINISTS_CT  IS NULL OR f.PARINISTS_CT = 1 ) ) --014
					or (@norme_cf = 'I17L' and ( f.LOCINISTS_CT  IS NULL OR f.LOCINISTS_CT = 1 ) ) --014
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
            b.SSD_CF,
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
        FROM	bret..tcession a
				join   			 BREF..TBATCHSSD bssd on   bssd.ssd_cf = a.ACCSSD_CF and bssd.BATCHUSER_CF =@curr_usr
				left outer join  bret..tretctr b  on a.retctr_nf=b.retctr_nf    and a.rty_nf=b.rty_nf --and a.ssd_cf = b.ssd_cf 
						   join  bfac..tcontr c   on a.UWY_NF = c.UWY_NF and a.UW_NT = c.UW_NT and a.CTR_NF = c.CTR_NF
						   join  bfac..tsection e on a.UWY_NF = e.UWY_NF and a.UW_NT = e.UW_NT and a.CTR_NF  = e.CTR_NF and a.SEC_NF  = e.SEC_NF  --and  a.ssd_cf = e.ssd_cf
						   join  bfac..tsecifrs f on f.UWY_NF = e.UWY_NF and f.UW_NT = e.UW_NT and f.CTR_NF  = e.CTR_NF and f.SEC_NF  = e.SEC_NF and  f.end_nt  = e.end_nt
				left outer join   BREF..TBATCHSSD acc on   a.ACCSSD_CF = acc.SSD_CF
				left outer join   BREF..TBATCHSSD ret on    a.RETSSD_CF = ret.SSD_CF
         WHERE
            (	(a.cesupdtyp_cf = '' AND a.cessts_cf = '01') OR
				(a.cesupdtyp_cf = 'S' AND a.cessts_cf = '03')
			)    AND
			a.CESSIONCAT_CF = "1"   AND   --[012]
            ( ( a.ssd_cf = 99 and acc.BATCHUSER_CF  = ret. BATCHUSER_CF ) or (acc.BATCHUSER_CF  != ret.BATCHUSER_CF and a.ssd_cf = 99 ) ) and
			b.ctrexp_d IS NOT NULL  and
            ((CTRSTS_CT IN (select Id from @sts_list) and CTRLCK_B != 0) OR 
            
				( 	(cast(datediff(DAY, @p_clo_date, c.CTRINC_D) AS numeric(5,0)) >= 0 ) and
					(cast(datediff(DAY, @p_next_clo_date, c.CTRINC_D) AS numeric(5,0)) <= 0 ) and
					(f.FRCIFRSBTCH_NT  = 1)
				)           
            
			)   --[013] 
			and (f.RECOD_D <= @v_pos_booking_minus_days or (@p_typeinv_cf = 'POS' and CTRSTS_CT in (12, 14))) --[018]
			and ( 
						 (@norme_cf = 'I17G' and ( f.GRPINISTS_CT  IS NULL OR f.GRPINISTS_CT = 1 ) ) --014
					or (@norme_cf = 'I17P' and ( f.PARINISTS_CT  IS NULL OR f.PARINISTS_CT = 1 ) ) --014
					or (@norme_cf = 'I17L' and ( f.LOCINISTS_CT  IS NULL OR f.LOCINISTS_CT = 1 ) ) --014
				)   
           
            
        SELECT @erreur = @@ERROR
        IF @erreur != 0
            BEGIN
                RAISERROR 20005 "APPLICATIF;TCESSION"
                RETURN @erreur
            END
        RETURN 0
go
EXEC sp_procxmode 'dbo.PsLORETFACTOR_I17_SERQ_01', 'unchained'
go
IF OBJECT_ID('dbo.PsLORETFACTOR_I17_SERQ_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLORETFACTOR_I17_SERQ_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLORETFACTOR_I17_SERQ_01 >>>'
go
GRANT EXECUTE ON dbo.PsLORETFACTOR_I17_SERQ_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLORETFACTOR_I17_SERQ_01 TO GDBBATCH
go

