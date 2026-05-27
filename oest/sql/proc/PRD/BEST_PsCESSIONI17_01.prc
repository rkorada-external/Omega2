USE BEST
go
IF OBJECT_ID('PsCESSIONI17_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PsCESSIONI17_01
    IF OBJECT_ID('PsCESSIONI17_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsCESSIONI17_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsCESSIONI17_01 >>>'
END
go
/*
 * creation de la procedure
 */

create procedure PsCESSIONI17_01(
		@p_clo_date char(8),
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
)

as

/***************************************************

Programme: PsCESSIONI17_01
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation: 07/06/2021
Description du programme:
		Version I17 de la procedure PsCESSION_01
		Extraction des versements de la base retrocession
		avec selection des les versements valides et actifs
	    	ou historises et supprimes.

Parametres: aucun
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
[001] ART spira 100168 IFRS17 inception pericase- Extract Run-off if transition mode
*________________
MODIFICATIONS
[002] ART spira 100168 IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
[003] Suraj P    22/11/2022  :spira :106239 Pericase INI does not include contract recognized on cut off date
[004] 17/10/2025 MZM   US 7046 : Cut off management - actuarial segment is empty on contracts taken into account the day of cut off
*****************************************************/
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
	SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date --[002]
	SELECT @v_pos_booking_minus_days = dateadd( day, 1, (dateadd(day, @p_x_days * -1, @v_pos_booking_d))) -- [004]
END
ELSE 
BEGIN
	SELECT @v_pos_booking_minus_days = dateadd(day, 1, convert(datetime, @p_quarter_end, 103)) --[004]
END

declare @erreur int

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr

-- CREATION OF TEMPORARY TABLE
CREATE TABLE #CESSION
(
    CTR_NF 	      UCTR_NF NULL,
    END_NT 	      UEND_NT NULL,
    SEC_NF 	      USEC_NF NULL,
    UWY_NF 	      UUWY_NF NULL,
    UW_NT 	       UUW_NT NULL,
    RETCTR_NF	    URETCTR_NF NULL,
    RETEND_NT     SMALLINT NULL,
	 	 RETSEC_NF     URETSEC_NF NULL,
	 	 RTY_NF        UUWY_NF NULL,
	 	 RETUW_NT      SMALLINT NULL,
	 	 CESACCSTA_N   INT NULL,
	 	 CESACCEND_N   INT NULL,
	 	 CESSH_R       USHORAT_R NULL,
	 	 SSD_CF        USSD_CF NULL,
	 	 ESB_CF        UESB_CF NULL,
	 	 RETCTRCAT_CF  char(2) NULL,
	 	 ACCADMTYP_CT  TINYINT NULL,
	 	 RETACCADM_B   BIT NOT NULL,
	 	 CLECUTPER_B   BIT NOT NULL,
	 	 CLECUTPER_NB  INT NULL,
	 	 LOB_CF        ULOB_CF NULL,
	   CUR_CF        UCUR_CF NULL,            
	 	 RETPCPCUR_CF  UCUR_CF NULL, 
	   CONRETCTR_B   BIT NOT NULL,      
		  ACCFAM_CT     UBANVAL_CT NULL
)   

--FAC
INSERT INTO #CESSION
select
	 	a.CTR_NF,
	 	0 END_NT,
	 	a.SEC_NF,
	 	a.UWY_NF,
	 	a.UW_NT	,
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
	  	'' CUR_CF,             /* champ cur_cf */
	 	b.retpcpcur_cf ,
	    b.CONRETCTR_B,         
		b.ACCFAM_CT    
from	bret..tcession a, bret..tretctr b, #ssds s, BFAC..TSECIFRS SECIFRS
where 	((a.cesupdtyp_cf='' AND a.cessts_cf='01') OR
       (a.cesupdtyp_cf='S' AND a.cessts_cf='03'))
and 	a.CESSIONCAT_CF= "1"
and 	a.retctr_nf*=b.retctr_nf and a.rty_nf*=b.rty_nf
and SECIFRS.CTR_NF= a.CTR_NF and SECIFRS.SEC_NF= a.SEC_NF and SECIFRS.UWY_NF= a.UWY_NF and SECIFRS.UW_NT= a.UW_NT and SECIFRS.END_NT= 0
and     a.ssd_cf = s.ssd_cf
and SECIFRS.RECOD_D < @v_pos_booking_minus_days			--MODIF[003]
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT  IS NULL OR SECIFRS.GRPINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)) --001
	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT  IS NULL OR SECIFRS.PARINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9)) --001
		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT  IS NULL OR SECIFRS.LOCINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9)) --001
)


--TRT
INSERT INTO #CESSION
select
	 	a.CTR_NF,
	 	0 END_NT,
	 	a.SEC_NF,
	 	a.UWY_NF,
	 	a.UW_NT	,
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
	  	'' CUR_CF,             /* champ cur_cf */
	 	b.retpcpcur_cf ,
	    b.CONRETCTR_B,         
		b.ACCFAM_CT    
from	bret..tcession a, bret..tretctr b, #ssds s, BTRT..TSECIFRS SECIFRS
where 	((a.cesupdtyp_cf='' AND a.cessts_cf='01') OR
       (a.cesupdtyp_cf='S' AND a.cessts_cf='03'))
and 	a.CESSIONCAT_CF= "1"
and 	a.retctr_nf*=b.retctr_nf and a.rty_nf*=b.rty_nf
and SECIFRS.CTR_NF= a.CTR_NF and SECIFRS.SEC_NF= a.SEC_NF and SECIFRS.UWY_NF= a.UWY_NF and SECIFRS.UW_NT= a.UW_NT and SECIFRS.END_NT= 0
and     a.ssd_cf = s.ssd_cf
and SECIFRS.RECOD_D < @v_pos_booking_minus_days 		--MODIF[003]
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT  IS NULL OR SECIFRS.GRPINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)) --001
	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT  IS NULL OR SECIFRS.PARINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9)) --001
		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT  IS NULL OR SECIFRS.LOCINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9)) --001
)



select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCESSION"
      return @erreur
   end
   
-- Mettre � jour la devise � partir de la section si cette derni�re est renseign�e   
update #CESSION
   set retpcpcur_cf = b.RETSPECUR_CF
 from  #CESSION c, bret..tretsec b
 where c.retctr_nf = b.retctr_nf
   and c.retsec_nf = b.retsec_nf
   and c.rty_nf = b.rty_nf
   and b.RETSPECUR_CF is not null 
   and b.RETSPECUR_CF != ' '


select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCESSION"
      return @erreur
   end
   
   
 select CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT	,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        CESACCSTA_N,
        CESACCEND_N,
        CESSH_R,
        SSD_CF,
        esb_cf,
        retctrcat_cf,
        ACCADMTYP_CT,
        retaccadm_b,
        clecutper_b,
        clecutper_nb,
        LOB_CF,
        CUR_CF,
        retpcpcur_cf,
        CONRETCTR_B,
		ACCFAM_CT
   from #CESSION
	order by CTR_NF, END_NT,SEC_NF,UWY_NF, UW_NT


select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCESSION"
      return @erreur
   end

return 0
go
EXEC sp_procxmode 'PsCESSIONI17_01', 'unchained'
go
IF OBJECT_ID('PsCESSIONI17_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsCESSIONI17_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsCESSIONI17_01 >>>'
go
GRANT EXECUTE ON PsCESSIONI17_01 TO GOMEGA,GDBBATCH
go
