USE BEST
go
IF OBJECT_ID('dbo.PsPeriRetIni') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPeriRetIni
    IF OBJECT_ID('dbo.PsPeriRetIni') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPeriRetIni >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPeriRetIni >>>'
END
go
create procedure PsPeriRetIni
(
		@p_clo_date char(8),
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode --quarter end for dry run
)
with execute as caller as
/***************************************************
Domaine :   Estimations
Base principale : BEST
Version:    1
Auteur:     A.RUFFAULT
Date de creation: 01/03/2021
Description du programme:       Extract closing inception perimeter retro 
Conditions d'execution:
Commentaires: 
_________________
MODIFICATION 1
Auteur: A.RUFFAULT
Date: 24/06/21
Spira: 95809
Description: - ajout des champs CTBGENFEE_R, PRFCOM_R et BRK_R, filtre sur l'inception status uniquement pour les contrats NP
_________________
MODIFICATION 2
Auteur: A.RUFFAULT
Date: 30/08/21
Spira: 97478
Description: spira 97478 IFRS17 DryRun- Recognition date test for pericase
_________________
MODIFICATION 3
Auteur: A.RUFFAULT
Date: 10/11/21
Spira: 100168
Description: IFRS17 inception pericase- Extract Run-off if transition mode
_________________
MODIFICATION 4
Auteur: A.RUFFAULT
Date: 11/01/22
Spira: 102075
Description: IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
_________________
MODIFICATION 5
Auteur: A.RUFFAULT
Date: 23/03/22
Spira: 102521
Description: I17P/I17L- Pericase INI check on TI17CLOPER
_________________
MODIFICATION 6
Auteur: Bhimasen
Date: 08/06/2023
Spira: 106239
Description: Pericase INI does not include contract recognized on cut off date
_________________
MODIFICATION 7

Description:  Cut-off management : Contract recognized day of cut-off should be taken into account
[007] MZM           28/07/2025 :US 6250  : 112796 Cut-off management : Contract recognized day of cut-off should be taken into account
*****************************************************/


-------------------------
-- Recognition date - X days OR Dry run date retrieval --modif2
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
	SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date --[004]
	SELECT @v_pos_booking_minus_days = dateadd(day,1,dateadd(day, @p_x_days * -1, @v_pos_booking_d) )--007 dateadd(day, @p_x_days * -1, @v_pos_booking_d)
END
ELSE 
BEGIN
	SELECT @v_pos_booking_minus_days =  dateadd(day, 1, convert(datetime, @p_quarter_end, 103) ) --007 convert(datetime, @p_quarter_end, 103)
END

declare @erreur int

-------------------------
-- Périmètre rétrocession
-------------------------

-- Cas multifiliale
-- La liste des filiales est dans la table BTRAV..TESTSSD
-- Le filtre est fait sur la date maximum du libelle d'inventaire passee en paramètre





if object_id('#TABLE_TRFAMPRM') is not null drop Table #TABLE_TRFAMPRM

if object_id('#TABLE_TRFAMPRE') is not null drop Table #TABLE_TRFAMPRE

select  RETPCPCUR_CF=case when SEC.RETSPECUR_CF not in(null,'') then SEC.RETSPECUR_CF else CTR.RETPCPCUR_CF end, PRM.PRMDUECUR_CF, PRM.RETCTR_NF, PRM.RTY_NF, PRM.SSD_CF, PRM.PRMDUE_M, PRM.PRMDUE_M* cast(case when (CUR.EXC_R>0) then CUR2.EXC_R/CUR.EXC_R else 1.0 end AS NUMERIC(24,12)) as CUR_PRMDUE_M 
INTO #TABLE_TRFAMPRM
from BRET..TRFAMPRM PRM, BRET..TRETCTR CTR, 
BRET..TRETSEC SEC, BREF..TCURQUOT CUR, BREF..TCURQUOT CUR2
where 
PRM.RETCTR_NF = CTR.RETCTR_NF 
and PRM.RTY_NF = CTR.RTY_NF 
and PRM.SSD_CF = CTR.SSD_CF 
and PRM.RETCTR_NF = SEC.RETCTR_NF 
and PRM.RTY_NF = SEC.RTY_NF 
and PRM.SSD_CF = SEC.SSD_CF 
and SEC.RETSEC_NF =1
and CUR.ssd_cf = PRM.ssd_cf
       and CUR.CUR_CF = case when SEC.RETSPECUR_CF not in(null,'') then SEC.RETSPECUR_CF else CTR.RETPCPCUR_CF end
       and CUR.EXC_D = (select max(C2.exc_d) from BREF..TCURQUOT C2 where C2.ssd_cf=PRM.ssd_cf and C2.cur_cf=case when SEC.RETSPECUR_CF not in(null,'') then SEC.RETSPECUR_CF else CTR.RETPCPCUR_CF end
                       and C2.exc_d <= convert(datetime,convert(char(10),PRM.RTY_NF) + "/12/31"))
and CUR2.ssd_cf = PRM.ssd_cf
       and CUR2.CUR_CF = PRM.PRMDUECUR_CF
       and CUR2.EXC_D = (select max(C2.exc_d) from BREF..TCURQUOT C2 where C2.ssd_cf=PRM.ssd_cf and C2.cur_cf=PRM.PRMDUECUR_CF
                       and C2.exc_d <= convert(datetime,convert(char(10),PRM.RTY_NF) + "/12/31"))

 
select PRM.RETCTR_NF, PRM.RTY_NF, PRM.RETPCPCUR_CF, PRM.SSD_CF,1 as  RETSEC_NF, cast(SUM(PRM.PRMDUE_M) AS decimal(18, 3)) AS PRMDUE_SUM, cast(SUM(CUR_PRMDUE_M) AS decimal(18, 3)) AS FLAPROPRM_M 
INTO #TABLE_TRFAMPRE
from #TABLE_TRFAMPRM PRM 
GROUP BY PRM.RETCTR_NF, PRM.RTY_NF, PRM.SSD_CF, PRM.RETPCPCUR_CF 

IF(@norme_cf = 'I17G')
BEGIN

-- Affichage du périmètre rétrocession non vie
select
    RETSEC.SSD_CF,
    null,
    RETSEC.RETCTR_NF,
    0,
    RETSEC.RETSEC_NF,
    RETSEC.RTY_NF,
    1,
    RETCTR.ESB_CF,
    null,
    null,
    convert(char(8), RETCTR.CAN_DT, 112),
    null,
    null,
    null,
    null,
    null,
    RFAMMIS.CTBGENFEE_R,  --[001]
    null,
    convert(char(8), CTRINC_D, 112), 
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    convert(char(8), RETCTR.CTREXP_D, 112), 
    null,
    null,
    null,
    RETSEC.GAR_CF, -- recuperation du champs à partir de TRETSEC;
    null,
    null,
    null,
    null,
    null,
    LOB_CF,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    NAT_CF,
    null,
    RETPCPCUR_CF=case when RETSEC.RETSPECUR_CF not in(null,'') then RETSEC.RETSPECUR_CF else RETCTR.RETPCPCUR_CF end, -- Rècuperer la devise du contrat si celle de la section n'existe pas, EST29a-R1
    RETSEC.PCPRSKTRY_CF, -- recuperation du champs à partir de TRETSEC
    null,
    null,
    PRFCOM_R = case when RETSEC.nat_cf in ('10','11','12','20','21','22','23') then RFAMMIS.PRFCOM_R else PNFAMPO.PRFCOM_R end, --[001]
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETSEC.SOB_CF, -- recuperation du champs à partir de TRETSEC
    null,
    null,
    RETSEC.TOP_CF, -- recuperation du champs à partir de TRETSEC
    CTRNAT_CF = case when RETSEC.nat_cf in ('10','11','12','20','21','22','23') then 'P' else  'N' end,  --null, -- SBE A ajouter CTRNAT
    null,
    PROPER_N,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETCTR.RETACCTYP_CT, -- recuperation du champs à partir de TRETCTR
    null,
    RETCTRSTS_CT,
    null,
    null,
    null,
    null,
    null,
    FAMPRE.BRK_R,  --[001]
    null,
    RETCTRCAT_CF,
    CLECUTPER_B,
    CLECUTPER_NB,
    ORICUR_B,
    RETACCADM_B,
    RETCTR.SSDRTO_B,
    RETCTR.RAICOM_B,
    null,
    RETSEC.USRCRTCOD_CT,    
    RETSEC.USRCRTVAL_LM,    
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé (segmentation client),
    null,   -- Champ non utilisé (segmentation client),
    null,   -- Champ non utilisé (segmentation client),
    null,   -- Champ non utilisé (segmentation client),
    null,   -- Champ non utilisé (segmentation client),
    null,   -- Champ non utilisé (segmentation client),
    0,             
    null,          
    null,   -- Champ non utilisé
    null,    -- Champ non utilisé
    null    --   champ non utilisé
   ,CLMCUTOFF_B=null
   ,PRMCUTOFF_B=null
   ,CLMRUNOFF_B=null
   ,PRMRUNOFF_B=null
   ,ASSFINANCE_CT=null
   ,FLAPRM4_M=null
   ,FLAPRMCU4_CF=null
   ,FLAPRM5_M=null
   ,FLAPRMCU5_CF=null
   ,MINPRVPR4_M=null
   ,PRVPRMCU4_CF=null
   ,MINPRVPR5_M=null
   ,PRVPRMCU5_CF=null
   ,ESTLOSCORTYP_CT=null
   ,ESTV2C_COL_01=null
   ,ESTV2C_COL_02=null
   ,ESTV2C_COL_03=null
   ,ESTV2C_COL_04=null
   ,ESTV2C_COL_05=null
   ,ESTV2C_COL_06=null
   ,ESTV2C_COL_07=null
   ,ESTV2C_COL_08=null
   ,ESTV2C_COL_09=null
   ,ESTV2C_COL_10=null
   ,STLREQDEL_N                                                                 
   ,"RET"                                                                       
   ,convert(char(8), CTRINCUWY_D, 112)                                          
   ,ESTV2C_COL_14=null
   ,ESTV2C_COL_15=null
   ,TERCTR_B                                                                     
   ,ESTV2C_COL_17=null
   ,RACCCOND.ACCFRQ_CT                              
   ,convert ( char (8), FAMPRE.FIRPAYDUE_D, 112)      
   ,RETCTR.CLOFAM_CT
   ,RETCTR.ACCFAM_CT
   ,ESTV2C_COL_22=null
   ,ESTV2C_COL_23=null
   ,ESTV2C_COL_24=null
   ,RETIFRS.PRICEDCTR_B                 --ESTV2C_COL_25=null
   ,RETIFRS.PRICEDLR_R                  --ESTV2C_COL_26=null 
   ,TFAMPRE.FLAPROPRM_M                                                                  
   ,ESTV2C_COL_28=null
   ,ESTV2C_COL_29=null
   ,ESTV2C_COL_30=null  	
  from   BRET..TRETSEC RETSEC, 
  BRET..TRETCTR RETCTR, 
  BRET..TRACCCOND RACCCOND,
  BRET..TRFAMPRE FAMPRE, 
  #TABLE_TRFAMPRE TFAMPRE, 
  BRET..TRETIFRS RETIFRS,
  BREF..TBATCHSSD BATCHSSD,
		BRET..TRFAMMIS RFAMMIS,  --[001]
	 BRET..TPNFAMPO PNFAMPO  --[001]
  where  RETSEC.SSD_CF=BATCHSSD.SSD_CF and BATCHSSD.BATCHUSER_CF=suser_name()
  and RETCTR.RETCTRSTS_CT in (3, 19)
  and RETCTR.TERCTR_B <> 1  
  and LOB_CF<>'30' and LOB_CF<>'31' -- à vérifier at inception
  and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF and RETSEC.RTY_NF=RETCTR.RTY_NF
  and RETSEC.RETCTR_NF*=RACCCOND.RETCTR_NF
		and RETSEC.RETCTR_NF*=TFAMPRE.RETCTR_NF and RETSEC.RTY_NF*=TFAMPRE.RTY_NF and RETSEC.SSD_CF*=TFAMPRE.SSD_CF and RETSEC.RETSEC_NF*=TFAMPRE.RETSEC_NF
  and RETSEC.RETCTR_NF*= FAMPRE.RETCTR_NF and RETSEC.RTY_NF*= FAMPRE.RTY_NF and RETSEC.RETSEC_NF*= FAMPRE.RETSEC_NF
  and RETSEC.RETCTR_NF=RETIFRS.RETCTR_NF and RETSEC.RTY_NF=RETIFRS.RTY_NF   
		and RETSEC.RETCTR_NF*=RFAMMIS.RETCTR_NF and RETSEC.RTY_NF*=RFAMMIS.RTY_NF and RETSEC.RETSEC_NF*=RFAMMIS.RETSEC_NF  --[001]
	 and RETSEC.RETCTR_NF*=PNFAMPO.RETCTR_NF and RETSEC.RTY_NF*=PNFAMPO.RTY_NF and RETSEC.RETSEC_NF*=PNFAMPO.RETSEC_NF  --[001]
		and RETIFRS.RETRECOD_D < @v_pos_booking_minus_days
		and (
			RETSEC.nat_cf IN ('10','11','12','20','21','22','23') --[001]
			OR (RETSEC.nat_cf NOT IN ('10','11','12','20','21','22','23') 
				AND (RETIFRS.GRPINISTS_CT  = 0 OR RETIFRS.GRPINISTS_CT = 1  OR (@p_is_transition = 'YES' and RETIFRS.GRPINISTS_CT = 9)) --[003]
				AND CTRINCUWY_D <= @p_clo_date) --[001]
		)
END
IF(@norme_cf = 'I17P')
BEGIN

-- Affichage du périmètre rétrocession non vie
select
    RETSEC.SSD_CF,
    null,
    RETSEC.RETCTR_NF,
    0,
    RETSEC.RETSEC_NF,
    RETSEC.RTY_NF,
    1,
    RETCTR.ESB_CF,
    null,
    null,
    convert(char(8), RETCTR.CAN_DT, 112),
    null,
    null,
    null,
    null,
    null,
    RFAMMIS.CTBGENFEE_R,  --[001]
    null,
    convert(char(8), CTRINC_D, 112), 
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    convert(char(8), RETCTR.CTREXP_D, 112),
    null,
    null,
    null,
    RETSEC.GAR_CF, -- recuperation du champs à partir de TRETSEC
    null,
    null,
    null,
    null,
    null,
    LOB_CF,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    NAT_CF,
    null,
    RETPCPCUR_CF=case when RETSEC.RETSPECUR_CF not in(null,'') then RETSEC.RETSPECUR_CF else RETCTR.RETPCPCUR_CF end, -- Rècuperer la devise du contrat si celle de la section n'existe pas, EST29a-R1
    RETSEC.PCPRSKTRY_CF, -- recuperation du champs à partir de TRETSEC
    null,
    null,
    PRFCOM_R = case when RETSEC.nat_cf in ('10','11','12','20','21','22','23') then RFAMMIS.PRFCOM_R else PNFAMPO.PRFCOM_R end,  --[001]
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETSEC.SOB_CF, -- recuperation du champs à partir de TRETSEC
    null,
    null,
    RETSEC.TOP_CF, -- recuperation du champs à partir de TRETSEC
    CTRNAT_CF = case when RETSEC.nat_cf in ('10','11','12','20','21','22','23') then 'P' else  'N' end,  --null, -- SBE A ajouter CTRNAT
    null,
    PROPER_N,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETCTR.RETACCTYP_CT, -- recuperation du champs à partir de TRETCTR
    null,
    RETCTRSTS_CT,
    null,
    null,
    null,
    null,
    null,
    FAMPRE.BRK_R,  --[001]
    null,
    RETCTRCAT_CF,
    CLECUTPER_B,
    CLECUTPER_NB,
    ORICUR_B,
    RETACCADM_B,
    RETCTR.SSDRTO_B,
    RETCTR.RAICOM_B,
    null,
    RETSEC.USRCRTCOD_CT,    -- Champ rajouté au perimètre
    RETSEC.USRCRTVAL_LM,    -- Champ rajouté au perimètre
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé (segmentation client)
    null,   -- Champ non utilisé (segmentation client)
    null,   -- Champ non utilisé (segmentation client)
    null,   -- Champ non utilisé (segmentation client)
    null,   -- Champ non utilisé (segmentation client)
    null,    -- Champ non utilisé (segmentation client)
    0,             
    null,          
    null,   -- Champ non utilisé
    null,    -- Champ non utilisé
    null    --   champ non utilisé
   ,CLMCUTOFF_B=null
   ,PRMCUTOFF_B=null
   ,CLMRUNOFF_B=null
   ,PRMRUNOFF_B=null
   ,ASSFINANCE_CT=null
   ,FLAPRM4_M=null
   ,FLAPRMCU4_CF=null
   ,FLAPRM5_M=null
   ,FLAPRMCU5_CF=null
   ,MINPRVPR4_M=null
   ,PRVPRMCU4_CF=null
   ,MINPRVPR5_M=null
   ,PRVPRMCU5_CF=null
   ,ESTLOSCORTYP_CT=null
   ,ESTV2C_COL_01=null
   ,ESTV2C_COL_02=null
   ,ESTV2C_COL_03=null
   ,ESTV2C_COL_04=null
   ,ESTV2C_COL_05=null
   ,ESTV2C_COL_06=null
   ,ESTV2C_COL_07=null
   ,ESTV2C_COL_08=null
   ,ESTV2C_COL_09=null
   ,ESTV2C_COL_10=null
   ,STLREQDEL_N                                                                  
   ,"RET"                                                                        
   ,convert(char(8), CTRINCUWY_D, 112)                                           
   ,ESTV2C_COL_14=null
   ,ESTV2C_COL_15=null
   ,TERCTR_B                                                                      -- ESTV2C_COL_16=null
   ,ESTV2C_COL_17=null
   ,RACCCOND.ACCFRQ_CT                               
   ,convert ( char (8), FAMPRE.FIRPAYDUE_D, 112)      
   ,RETCTR.CLOFAM_CT
   ,RETCTR.ACCFAM_CT
   ,ESTV2C_COL_22=null
   ,ESTV2C_COL_23=null
   ,ESTV2C_COL_24=null
   ,RETIFRS.PRICEDCTR_B                 --ESTV2C_COL_25=null 
   ,RETIFRS.PRICEDLR_R                  --ESTV2C_COL_26=null 
   ,TFAMPRE.FLAPROPRM_M                                                                  --ESTV2C_COL_27=null 
   ,ESTV2C_COL_28=null
   ,ESTV2C_COL_29=null
   ,ESTV2C_COL_30=null  	
  from   BRET..TRETSEC RETSEC, 
  BRET..TRETCTR RETCTR, 
  BRET..TRACCCOND RACCCOND,
  BRET..TRFAMPRE FAMPRE, 
  #TABLE_TRFAMPRE TFAMPRE, 
  BRET..TRETIFRS RETIFRS,
  BREF..TBATCHSSD BATCHSSD,
		BEST..TI17CLOPER CLOPER,
		BRET..TRFAMMIS RFAMMIS,  --[001]
	 BRET..TPNFAMPO PNFAMPO  --[001]
  where  RETSEC.SSD_CF=BATCHSSD.SSD_CF and BATCHSSD.BATCHUSER_CF=suser_name()
  and RETCTR.RETCTRSTS_CT in (3, 19)
  and RETCTR.TERCTR_B <> 1  
  and LOB_CF<>'30' and LOB_CF<>'31' -- à vérifier at inception
  and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF and RETSEC.RTY_NF=RETCTR.RTY_NF
  and RETSEC.RETCTR_NF*=RACCCOND.RETCTR_NF
		and RETSEC.RETCTR_NF*=TFAMPRE.RETCTR_NF and RETSEC.RTY_NF*=TFAMPRE.RTY_NF and RETSEC.SSD_CF*=TFAMPRE.SSD_CF and RETSEC.RETSEC_NF*=TFAMPRE.RETSEC_NF
  and RETSEC.RETCTR_NF*= FAMPRE.RETCTR_NF and RETSEC.RTY_NF*= FAMPRE.RTY_NF and RETSEC.RETSEC_NF*= FAMPRE.RETSEC_NF
  and RETSEC.RETCTR_NF=RETIFRS.RETCTR_NF and RETSEC.RTY_NF=RETIFRS.RTY_NF   
		and RETSEC.RETCTR_NF*=RFAMMIS.RETCTR_NF and RETSEC.RTY_NF*=RFAMMIS.RTY_NF and RETSEC.RETSEC_NF*=RFAMMIS.RETSEC_NF  --[001]
	 and RETSEC.RETCTR_NF*=PNFAMPO.RETCTR_NF and RETSEC.RTY_NF*=PNFAMPO.RTY_NF and RETSEC.RETSEC_NF*=PNFAMPO.RETSEC_NF  --[001]
		and RETIFRS.RETRECOD_D < @v_pos_booking_minus_days
		and RETCTR.ESB_CF = CLOPER.ESB_CF
		and RETSEC.SSD_CF= CLOPER.SSD_CF --[005]
		and CLOPER.PARM1='1'
		and (
			RETSEC.nat_cf IN ('10','11','12','20','21','22','23') --retro P --[001]
			OR (RETSEC.nat_cf NOT IN ('10','11','12','20','21','22','23') 
				AND (RETIFRS.PARINISTS_CT  = 0 OR RETIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and RETIFRS.PARINISTS_CT = 9))--[003] 
				AND CTRINCUWY_D <= @p_clo_date) --[001]
		)
END
IF(@norme_cf = 'I17L')
BEGIN

-- Affichage du périmètre rétrocession non vie
select
    RETSEC.SSD_CF,
    null,
    RETSEC.RETCTR_NF,
    0,
    RETSEC.RETSEC_NF,
    RETSEC.RTY_NF,
    1,
    RETCTR.ESB_CF,
    null,
    null,
    convert(char(8), RETCTR.CAN_DT, 112), 
    null,
    null,
    null,
    null,
    null,
    RFAMMIS.CTBGENFEE_R,  --[001]
    null,
    convert(char(8), CTRINC_D, 112), 
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    convert(char(8), RETCTR.CTREXP_D, 112), 
    null,
    null,
    null,
    RETSEC.GAR_CF, -- recuperation du champs à partir de TRETSEC
    null,
    null,
    null,
    null,
    null,
    LOB_CF,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    NAT_CF,
    null,
    RETPCPCUR_CF=case when RETSEC.RETSPECUR_CF not in(null,'') then RETSEC.RETSPECUR_CF else RETCTR.RETPCPCUR_CF end, -- Rècuperer la devise du contrat si celle de la section n'existe pas, EST29a-R1
    RETSEC.PCPRSKTRY_CF, -- recuperation du champs à partir de TRETSEC
    null,
    null,
    PRFCOM_R = case when RETSEC.nat_cf in ('10','11','12','20','21','22','23') then RFAMMIS.PRFCOM_R else PNFAMPO.PRFCOM_R end,  --[001]
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETSEC.SOB_CF, -- recuperation du champs à partir de TRETSEC
    null,
    null,
    RETSEC.TOP_CF, -- recuperation du champs à partir de TRETSEC
    CTRNAT_CF = case when RETSEC.nat_cf in ('10','11','12','20','21','22','23') then 'P' else  'N' end,  --null, -- SBE A ajouter CTRNAT
    null,
    PROPER_N,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETCTR.RETACCTYP_CT, -- recuperation du champs à partir de TRETCTR
    null,
    RETCTRSTS_CT,
    null,
    null,
    null,
    null,
    null,
    FAMPRE.BRK_R,  --[001]
    null,
    RETCTRCAT_CF,
    CLECUTPER_B,
    CLECUTPER_NB,
    ORICUR_B,
    RETACCADM_B,
    RETCTR.SSDRTO_B,
    RETCTR.RAICOM_B,
    null,
    RETSEC.USRCRTCOD_CT,    -- Champ rajouté au perimètre
    RETSEC.USRCRTVAL_LM,    -- Champ rajouté au perimètre
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ acceptation non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé en rétro
    null,   -- Champ non utilisé (segmentation client)
    null,   -- Champ non utilisé (segmentation client)
    null,   -- Champ non utilisé (segmentation client)
    null,   -- Champ non utilisé (segmentation client)
    null,   -- Champ non utilisé (segmentation client)
    null,    -- Champ non utilisé (segmentation client)
    0,             
    null,         
    null,   -- Champ non utilisé
    null,    -- Champ non utilisé
    null    --   champ non utilisé
   ,CLMCUTOFF_B=null
   ,PRMCUTOFF_B=null
   ,CLMRUNOFF_B=null
   ,PRMRUNOFF_B=null
   ,ASSFINANCE_CT=null
   ,FLAPRM4_M=null
   ,FLAPRMCU4_CF=null
   ,FLAPRM5_M=null
   ,FLAPRMCU5_CF=null
   ,MINPRVPR4_M=null
   ,PRVPRMCU4_CF=null
   ,MINPRVPR5_M=null
   ,PRVPRMCU5_CF=null
   ,ESTLOSCORTYP_CT=null
   ,ESTV2C_COL_01=null
   ,ESTV2C_COL_02=null
   ,ESTV2C_COL_03=null
   ,ESTV2C_COL_04=null
   ,ESTV2C_COL_05=null
   ,ESTV2C_COL_06=null
   ,ESTV2C_COL_07=null
   ,ESTV2C_COL_08=null
   ,ESTV2C_COL_09=null
   ,ESTV2C_COL_10=null
   ,STLREQDEL_N                                                                  
   ,"RET"                                                                        
   ,convert(char(8), CTRINCUWY_D, 112)                                           
   ,ESTV2C_COL_14=null
   ,ESTV2C_COL_15=null
   ,TERCTR_B                                                                      -- ESTV2C_COL_16=null 
   ,ESTV2C_COL_17=null
   ,RACCCOND.ACCFRQ_CT                               
   ,convert ( char (8), FAMPRE.FIRPAYDUE_D, 112)      
   ,RETCTR.CLOFAM_CT
   ,RETCTR.ACCFAM_CT
   ,ESTV2C_COL_22=null
   ,ESTV2C_COL_23=null
   ,ESTV2C_COL_24=null
   ,RETIFRS.PRICEDCTR_B                 --ESTV2C_COL_25=null 
   ,RETIFRS.PRICEDLR_R                  --ESTV2C_COL_26=null 
   ,TFAMPRE.FLAPROPRM_M                                                                  --ESTV2C_COL_27=null 
   ,ESTV2C_COL_28=null
   ,ESTV2C_COL_29=null
   ,ESTV2C_COL_30=null  	
  from   BRET..TRETSEC RETSEC, 
  BRET..TRETCTR RETCTR, 
  BRET..TRACCCOND RACCCOND,
  BRET..TRFAMPRE FAMPRE, 
  #TABLE_TRFAMPRE TFAMPRE, 
  BRET..TRETIFRS RETIFRS,
  BREF..TBATCHSSD BATCHSSD,
		BEST..TI17CLOPER CLOPER,
		BRET..TRFAMMIS RFAMMIS,  --[001]
	 BRET..TPNFAMPO PNFAMPO  --[001]
  where  RETSEC.SSD_CF=BATCHSSD.SSD_CF and BATCHSSD.BATCHUSER_CF=suser_name()
  and RETCTR.RETCTRSTS_CT in (3, 19)
  and RETCTR.TERCTR_B <> 1  
  and LOB_CF<>'30' and LOB_CF<>'31' -- à vérifier at inception
  and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF and RETSEC.RTY_NF=RETCTR.RTY_NF
  and RETSEC.RETCTR_NF*=RACCCOND.RETCTR_NF
		and RETSEC.RETCTR_NF*=TFAMPRE.RETCTR_NF and RETSEC.RTY_NF*=TFAMPRE.RTY_NF and RETSEC.SSD_CF*=TFAMPRE.SSD_CF and RETSEC.RETSEC_NF*=TFAMPRE.RETSEC_NF
  and RETSEC.RETCTR_NF*= FAMPRE.RETCTR_NF and RETSEC.RTY_NF*= FAMPRE.RTY_NF and RETSEC.RETSEC_NF*= FAMPRE.RETSEC_NF
  and RETSEC.RETCTR_NF=RETIFRS.RETCTR_NF and RETSEC.RTY_NF=RETIFRS.RTY_NF  
		and RETSEC.RETCTR_NF*=RFAMMIS.RETCTR_NF and RETSEC.RTY_NF*=RFAMMIS.RTY_NF and RETSEC.RETSEC_NF*=RFAMMIS.RETSEC_NF  --[001]
	 and RETSEC.RETCTR_NF*=PNFAMPO.RETCTR_NF and RETSEC.RTY_NF*=PNFAMPO.RTY_NF and RETSEC.RETSEC_NF*=PNFAMPO.RETSEC_NF  --[001]
		and RETIFRS.RETRECOD_D < @v_pos_booking_minus_days
		and RETCTR.ESB_CF = CLOPER.ESB_CF
		and RETSEC.SSD_CF= CLOPER.SSD_CF  --[005]
		and CLOPER.PARM2='1'
		and (
			RETSEC.nat_cf IN ('10','11','12','20','21','22','23') --retro P --[001]
			OR (RETSEC.nat_cf NOT IN ('10','11','12','20','21','22','23') 
				AND (RETIFRS.LOCINISTS_CT  = 0 OR RETIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and RETIFRS.LOCINISTS_CT = 9))--[001] 
				AND CTRINCUWY_D <= @p_clo_date) --[001]
		)
END

   select @erreur = @@error
   if @erreur != 0
   begin
      return @erreur
   end
return 0
go
EXEC sp_procxmode 'dbo.PsPeriRetIni', 'unchained'
go
IF OBJECT_ID('dbo.PsPeriRetIni') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPeriRetIni >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPeriRetIni >>>'
go
GRANT EXECUTE ON dbo.PsPeriRetIni TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPeriRetIni TO GDBBATCH
go


