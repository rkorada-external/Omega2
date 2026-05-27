USE BEST
go
IF OBJECT_ID('dbo.PsLORETFACTOR_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLORETFACTOR_02
    IF OBJECT_ID('dbo.PsLORETFACTOR_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLORETFACTOR_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLORETFACTOR_02 >>>'
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


/*
 * creation de la procedure
 */
CREATE PROCEDURE dbo.PsLORETFACTOR_02
(
    @p_ICLODAT_D   datetime,
    @p_typeinv_cf 	char(4)
) 
AS

/***************************************************

Programme:              PsLORETFACTOR_02
Fichier script associé: PsLORETFACTOR_02.PRC
Domaine:                (ES) Estimation
Base principale:        BEST
Version:                :spira:90120: REQ11.7.2 RETRO AT CLOSING  --> Genere le fichier ESPD0060_FLORETFACTOR_STD_TYPEINV_DATECLOSING
Auteur:                 MZM
Date de creation:       28/09/2020
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
001 12/10/2020 : spira90724 : LO factor change ; Date Retro + 1 : SI a.ACCADMTYP_CT in (1,3,4,5) ;
002 15/12/2020 : spira91272 LO Factor - Formula Change : = [(min(assumed contract risk period ending date, retro expiry date) - max(retro inception date,closing date)) + 1 ] / 
                                                               [(assumed contract risk period ending date (R01-02) - closing date) + 1]
006 02/07/2021 : spira 97075 : Assumed ctrexp_d est vide on récupère la valeur du champ Assumed scoexp_d 
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
*****************************************************/
DECLARE @p_ssd_cf    USSD_CF
DECLARE @erreur INT
DECLARE @curr_usr UUPDUSR_CF
SELECT @curr_usr = USER_NAME ()

SELECT
    BATCHUSER_CF,
    SSD_CF
INTO #ssds
FROM BREF..TBATCHSSD
WHERE BATCHUSER_CF = @curr_usr

declare @sts_list table (Id TINYINT)
insert into @sts_list values (16)
insert into @sts_list values (18)
insert into @sts_list values (19)

IF(@p_typeinv_cf = 'POS')
BEGIN
  insert into @sts_list values (14)
END
        
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
            convert(char(8), @p_ICLODAT_D, 112) CLODAT_D,        
            LOFACTOR =                 
                            case       
                                    when (b.RETACCTYP_CT in (1,2,4) OR b.RETACCTYP_CT IS NULL) OR (c.ctrexp_d IS NULL AND c.scoexp_d IS NULL) --(b.RETACCTYP_CT in (3,5) OR b.RETACCTYP_CT IS NULL)
                                        then 1
                                    when (  cast(datediff(DAY, @p_ICLODAT_D, b.ctrexp_d) AS numeric(5,0)) < 0 )
                                        then 0	
                                        
                                    when (a.ACCADMTYP_CT in (1,3,4,5) AND  (cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) AND 
                                          (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) >= cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ))              --01
                                        then 1                                                                                 
                                         
                                    when (a.ACCADMTYP_CT in (1,3,4,5) AND  (cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) 
                                          AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) <= cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ) )
                                         -- AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) >= 0 )
                                        then cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(ISNULL(c.scoexp_d, c.ctrexp_d), b.ctrexp_d)) ) AS numeric(5,0)) / cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))                --001

                                    when ( ((a.ACCADMTYP_CT = 2) AND  (cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0 )) AND 
                                          (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) >= cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))) )  --001
                                        then 1                                             
                                    
                                    when ((a.ACCADMTYP_CT = 2) AND  (cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) != 0) 
                                          AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) <= cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0)) ) )
                                         -- AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) >= 0 )
                                        then cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.scoexp_d, c.ctrexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) / cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.scoexp_d, c.ctrexp_d))) AS numeric(5,0))                --001
                                                                                                                                                                            
                                    else 0
                                end,
            convert(char(8), b.CTRINCUWY_D, 112) retinc_d											                                                                                      				                       
        --INTO #LORETFACTOR
        FROM
            bret..tcession a,
            bret..tretctr b,
             #ssds s,
             btrt..tcontr c, 
             btrt..tsection e
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
        
            a.ssd_cf = s.ssd_cf     and               
            
            c.ctr_nf = e.ctr_nf			and   
            c.UW_NT =  e.UW_NT			and   
            c.UWY_NF = e.UWY_NF			and            
            
            b.ctrexp_d IS NOT NULL  and
            --c.ctrexp_d IS NOT NULL  and
            -- CTRSTS_CT IN (16, 18, 19) --and --[010]
            --CTRLCK_B != 0
            CTRSTS_CT IN (14, 16, 17, 19) --[010]
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
            convert(char(8), @p_ICLODAT_D, 112) CLODAT_D,
            --convert(char(8), e.ctrinc_d, 112) secinc_d,   --cast(LOFACTOR AS numeric(18, 3))             
            LOFACTOR =                 
                            case       
                                    when (b.RETACCTYP_CT in (1,2,4) OR b.RETACCTYP_CT IS NULL) OR (c.ctrexp_d IS NULL AND c.scoexp_d IS NULL) --(b.RETACCTYP_CT in (3,5) OR b.RETACCTYP_CT IS NULL)
                                        then 1
                                    when (  cast(datediff(DAY, @p_ICLODAT_D, b.ctrexp_d) AS numeric(5,0)) < 0 )
                                        then 0	
                                        
                                    when (a.ACCADMTYP_CT in (1,3,4,5) AND  (cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0)) != 0) AND 
                                          (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(ISNULL(c.ctrexp_d, c.scoexp_d), b.ctrexp_d)) ) AS numeric(5,0)) >= cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0)) ))              --01
                                        then 1                                                                                 
                                         
                                    when (a.ACCADMTYP_CT in (1,3,4,5) AND  (cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0)) != 0) 
                                          AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(ISNULL(c.ctrexp_d, c.scoexp_d), b.ctrexp_d)) ) AS numeric(5,0)) <= cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0)) ) )
                                         -- AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(ISNULL(c.ctrexp_d, c.scoexp_d), b.ctrexp_d)) ) AS numeric(5,0)) >= 0 )
                                        then cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(ISNULL(c.ctrexp_d, c.scoexp_d), b.ctrexp_d)) ) AS numeric(5,0)) / cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 1, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0))                --001

                                    when ( ((a.ACCADMTYP_CT = 2) AND  (cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0)) != 0 )) AND 
                                          (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.ctrexp_d, c.scoexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) >= cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0))) )  --001
                                        then 1                                             
                                    
                                    when ((a.ACCADMTYP_CT = 2) AND  (cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0)) != 0) 
                                          AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.ctrexp_d, c.scoexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) <= cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0)) ) )
                                         -- AND (cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.ctrexp_d, c.scoexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) >= 0 )
                                        then cast(datediff(DAY, dbo.Max2dates(b.CTRINCUWY_D, @p_ICLODAT_D), dateadd(day, 1, dbo.Min2dates(dateadd(day, 365, ISNULL(c.ctrexp_d, c.scoexp_d)), b.ctrexp_d)) ) AS numeric(5,0)) / cast(datediff(DAY, @p_ICLODAT_D, dateadd(day, 366, ISNULL(c.ctrexp_d, c.scoexp_d))) AS numeric(5,0))                --001
                                                                                                                                                                            
                                    else 0
                                end,
            convert(char(8), b.CTRINCUWY_D, 112) retinc_d                                                                                       				                       
        --INTO #LORETFACTOR
        FROM
            bret..tcession a,
            bret..tretctr b,
             #ssds s,
             bfac..tcontr c, 
             bfac..tsection e
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
        
            a.ssd_cf = s.ssd_cf     and             
            
            c.ctr_nf = e.ctr_nf			and   
            c.UW_NT =  e.UW_NT			and   
            c.UWY_NF = e.UWY_NF			and            
            
            b.ctrexp_d IS NOT NULL  and
            
            CTRSTS_CT IN (select Id from @sts_list)
            -- CTRSTS_CT IN (16, 18, 19) --and
            --CTRLCK_B != 0
            --CTRSTS_CT IN (14, 16, 17, 19)

           
            
        SELECT @erreur = @@ERROR
        IF @erreur != 0
            BEGIN
                RAISERROR 20005 "APPLICATIF;TCESSION"
                RETURN @erreur
            END
        RETURN 0
go
EXEC sp_procxmode 'dbo.PsLORETFACTOR_02', 'unchained'
go
IF OBJECT_ID('dbo.PsLORETFACTOR_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLORETFACTOR_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLORETFACTOR_02 >>>'
go
GRANT EXECUTE ON dbo.PsLORETFACTOR_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLORETFACTOR_02 TO GDBBATCH
go

