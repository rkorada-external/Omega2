USE BEST
go
IF OBJECT_ID('PsCESSIONI17_02') IS NOT NULL
BEGIN
    DROP PROCEDURE PsCESSIONI17_02
    IF OBJECT_ID('PsCESSIONI17_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsCESSIONI17_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsCESSIONI17_02 >>>' 
END
go
/*
 * creation de la procedure
 */

create procedure PsCESSIONI17_02(
		@p_clo_date char(8),
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
)

as

/***************************************************

Programme: PsCESSIONI17_02
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: Florian CULIOLI
Date de creation: 03/10/2022
Description du programme:
		Version I17 de la procedure PsCESSION
		Extraction des versements de la base retrocession
		avec selection des les versements valides et actifs
	    	ou historises et supprimes.

Parametres: aucun
Conditions d'execution:
Commentaires:
_________________
INITIALISATION
[001] FCI spira 105587 Onerous Q+1 
[002] FCI spira 110735 FAC Accepted
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
from	bret..tcession a, bret..tretctr b, #ssds s, BFAC..TSECIFRS SECIFRS, BFAC..TCONTR CONTR
where 	((a.cesupdtyp_cf='' AND a.cessts_cf='01') OR
       (a.cesupdtyp_cf='S' AND a.cessts_cf='03'))
and 	a.CESSIONCAT_CF= "1"
and 	a.retctr_nf*=b.retctr_nf and a.rty_nf*=b.rty_nf
and SECIFRS.CTR_NF= a.CTR_NF and SECIFRS.SEC_NF= a.SEC_NF and SECIFRS.UWY_NF= a.UWY_NF and SECIFRS.UW_NT= a.UW_NT and SECIFRS.END_NT= 0
and SECIFRS.CTR_NF=CONTR.CTR_NF and SECIFRS.END_NT=CONTR.END_NT and SECIFRS.UWY_NF=CONTR.UWY_NF and SECIFRS.UW_NT=CONTR.UW_NT
and     a.ssd_cf = s.ssd_cf
and (
(SECIFRS.FRCIFRSBTCH_NT  = 1                   		-- onerous Q+1
and CONTR.CTRINC_D >= @p_clo_date_plus_one
and CONTR.CTRINC_D <= @p_next_clo_date)
or(CONTR.CTRSTS_CT = 14)                            -- [002] FAC Accepted
)
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT  IS NULL OR SECIFRS.GRPINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)) --001
	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT  IS NULL OR SECIFRS.PARINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9)) --001
		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT  IS NULL OR SECIFRS.LOCINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9)) --001
		or (@norme_cf = 'I17S' and ( SECIFRS.GRPINISTS_CT  IS NULL OR SECIFRS.GRPINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)) 
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
from	bret..tcession a, bret..tretctr b, #ssds s, BTRT..TSECIFRS SECIFRS, BTRT..TCONTR CONTR
where 	((a.cesupdtyp_cf='' AND a.cessts_cf='01') OR
       (a.cesupdtyp_cf='S' AND a.cessts_cf='03'))
and 	a.CESSIONCAT_CF= "1"
and 	a.retctr_nf*=b.retctr_nf and a.rty_nf*=b.rty_nf
and SECIFRS.CTR_NF= a.CTR_NF and SECIFRS.SEC_NF= a.SEC_NF and SECIFRS.UWY_NF= a.UWY_NF and SECIFRS.UW_NT= a.UW_NT and SECIFRS.END_NT= 0
and SECIFRS.CTR_NF=CONTR.CTR_NF and SECIFRS.END_NT=CONTR.END_NT and SECIFRS.UWY_NF=CONTR.UWY_NF and SECIFRS.UW_NT=CONTR.UW_NT
and     a.ssd_cf = s.ssd_cf
and SECIFRS.FRCIFRSBTCH_NT  = 1                   		-- onerous Q+1
and CONTR.CTRINC_D >= @p_clo_date_plus_one
and CONTR.CTRINC_D <= @p_next_clo_date
and ( 
	(@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT  IS NULL OR SECIFRS.GRPINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)) --001
	 or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT  IS NULL OR SECIFRS.PARINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9)) --001
		or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT  IS NULL OR SECIFRS.LOCINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9)) --001
		or (@norme_cf = 'I17S' and ( SECIFRS.GRPINISTS_CT  IS NULL OR SECIFRS.GRPINISTS_CT = 1 ) OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))
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
EXEC sp_procxmode 'PsCESSIONI17_02', 'unchained'
go
IF OBJECT_ID('PsCESSIONI17_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsCESSIONI17_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsCESSIONI17_02 >>>'
go
GRANT EXECUTE ON PsCESSIONI17_02 TO GOMEGA,GDBBATCH
go
