use BEST
go
if object_id('PsPeriFacIni') is not null
begin
   drop procedure PsPeriFacIni
   if object_id('PsPeriFacIni') is not null
     print '<<< FAILED DROPPING procedure PsPeriFacIni >>>'
   else
     print '<<< DROPPED procedure PsPeriFacIni >>>'
end
go
create procedure PsPeriFacIni
  (
		@p_clo_date 	char(8),
		@p_x_days 		int,
		@p_segtyp_ct 	char(1), --type de segmentation ( 'A' ou 'E' )
		@norme_cf 		char(4),
		@p_quarter_end 	varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
  )
as
/***************************************************
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    - Descente du p�rim�tre acceptation des bases facs au niveau CASEX.
Le filtre sur la date d'effet est fait ult�rieurement par un programme C
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
[001] ART spira 97478 IFRS17 DryRun- Recognition date test for pericase
[002] ART spira 100168 IFRS17 inception pericase- Extract Run-off if transition mode
[003] ART spira 102075 IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
[004] ART spira 102521 I17P/I17L- Pericase INI check on TI17CLOPER
[005] Bhimasen spira 106239 Pericase INI does not include contract recognized on cut off date
[006] DAD spira 109347 Pericase INI add the status 14 - Accepted
[007] FCI spira 109507 I17 - Modify rule of CSM and LC pattern computation for multi year contracts
[008] MZM           28/07/2025 :US 6250  : 112796 Cut-off management : Contract recognized day of cut-off should be taken into account
*****************************************************/


-------------------------
-- Recognition date - X days OR Dry run date retrieval [001]
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
	SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date --[003]
	SELECT @v_pos_booking_minus_days = dateadd(day,1,dateadd(day, @p_x_days * -1, @v_pos_booking_d) ) --008 dateadd(day, @p_x_days * -1, @v_pos_booking_d)
END
ELSE 
BEGIN
	SELECT @v_pos_booking_minus_days = dateadd(day, 1, convert(datetime, @p_quarter_end, 103) ) --008onvert(datetime, @p_quarter_end, 103)
END

declare @erreur int

/* Lancement de la proc qui g�n�re le perim�tre des affaires FAC */
/* ------------------------------------------------------------- */

IF(@norme_cf = 'I17G')
BEGIN
-- P�rim�tre pour les facs
SELECT
  SECTION.SSD_CF
 ,@p_segtyp_ct
 ,SECTION.CTR_NF
 ,SECTION.END_NT
 ,SECTION.SEC_NF
 ,SECTION.UWY_NF
 ,SECTION.UW_NT
 ,ACCESB_CF
 ,'M'  --  isnull( CTRULT.ADMMODPRM_CT,'M' )
 ,ANLCTY_CF
 ,CONVERT(char(8),CAN_DT,112)
 ,CED_NF
 ,CLI1.CLICTY_CF
 ,CLI1.CLINAT_CF
 ,NULL
 ,1           -- En Facs il s agit toujours de commissions fixes
 ,CTBGENFEE_R
 ,CTBTYP_CT
 ,CONVERT(char(8),CTRINC_D,112)
 ,CLI1.CLISSD_CF -- Permet l'affectation de CTRRET_B
 ,CUTSHA_R
 ,SECTION.DIV_NT
 ,FAMLIA.EGPCUR_CF
 ,CONTR.ESTCRB_CT
 ,ESTCTR_NF
 ,ESTEND_B
 ,NULL -- ESTSEC_NF par defaut
 ,CONVERT(char(8),CTREXP_D,112)
 ,FIXCOM_R
 ,SECTION.FRSUWY_NF
 ,GANPAYORD_NT
 ,GAR_CF
 ,GENPRMPAY_NF
 ,GENPRMSEN_NF
 ,NULL -- Non renseigne pour les facs
 ,LAYCAP_M
 ,LIFTRTTYP_CF
 ,LOB_CF
 ,LOSCOREXI_B
 ,LOSCORHIG_R
 ,LOSCORLOW_R
 ,LOSCORRAT_R
 ,LOSCTB_R
 ,LOSCTBEXI_B
 ,MAXCOM_R
 ,MAXRATCLP_R
 ,MINCOM_R
 ,MINRATCLP_R
 ,NAT_CF
 ,NULL        -- modifs du 08/10/1998 le champs ORDNBR_NT est forc� � NULL
 ,PCPCUR_CF
 ,PCPRSKTRY_CF
 ,NULL  -- Non renseigne pour les facs
 ,PRD_NF
 ,PRFCOM_R
 ,PRFCOMEXI_B
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,PRMNETCOM_B
 ,NULL -- Non renseigne pour les facs
 ,REIEXI_B
 ,REIFRE_B
 ,REINBR_N
 ,REIUNL_B
 ,RESTRFDUR_N
 ,RESTRFTYP_CF
 ,NULL
 ,NULL
 ,SCLCOMEXI_B
 ,SCLCTBEXI_B
 ,SCOADDEGP_M = (case when (SCOADDEGP_M=null and CONTR.UWORG_CF = 248) then SCOORGEGP_M else SCOADDEGP_M end) --[023] SCOADDEGP_M -- SCOEGP_M par defaut anciennement scogloegp (23/04/99)         
 ,CONVERT(char(8),SCOINC_D,112)
 ,SECACCSTS_CT
 ,CONVERT(char(8),CTRINC_D,112)  -- Affectation de SECINC_D
 ,SECSTS_CT
 ,SEG_NF
 ,SOB_CF
 ,SUBNAT_CF
 ,NULL
 ,TOP_CF
 ,'F'     -- CTRNAT_CT
 ,UWGRP_CF
 ,NULL
 ,NULL     -- Non renseigne pour les facs
 ,CONVERT(char(8),ORGINC_D,112)
 ,LIARIDSHA_B
 ,NULL
 ,RIDSHA_R
 ,CTBCALLVL_CF
 ,NULL -- Non renseigne pour les facs
 ,NULL
 ,NULL
 ,ACCADMTYP_CT
 ,NULL
 ,CTRSTS_CT
 ,OVRCOM_R
 ,OVRCOMTYP_CT
 ,TAXCNDEXI_B
 ,PRDBRK_R
 ,ACCBRK_R
 ,NULL -- LIACUR_CF : non utilis� pour les facs
 ,NULL -- ERNPRMADM_B : non utilis� pour les facs
 ,CONVERT(char(8),SECCAN_D,112) -- Permet l'affectation de EXP_D
 ,SCOORGEGP_M                     -- Permet l'affectation de SCOEGP_M
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
 ,SECTION.USRCRTCOD_CT   -- Champ rajout� au perim�tre modif du 12/03/98
 ,SECTION.USRCRTVAL_LM   -- Champ rajout� au perim�tre modif du 12/03/98
 ,FAMCHG.PRDBRKTYP_CT        -- Champ rajout� au perim�tre modif du 20/03/98
 ,FAMCHG.ACCBRKTYP_CT        -- Champ rajout� au perim�tre modif du 20/03/98
 ,CONTR.UWORG_CF     -- Champ rajout� au perim�tre modif du 26/05/98
 ,SECTION.SECQUA_CF      -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA2_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA3_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA4_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA5_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.ADMGRP_CF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.ORGCED_NF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.REITYP_CF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,FAMLIA.PRTCUR_CF       -- Champ rajout� au perim�tre modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,CONTR.CTRACCSTS_CT     -- Champ rajout� au perim�tre modif du 15/09/98
 ,datepart(yy,CONTR.CTRACC_D) -- Champ rajout� au perim�tre modif du 15/09/98
 ,FAMLIA.PMLRAT_R        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CLI1.HORDNBR_NT        --MODIF 007
 ,CLREPCR1.SORDNBR_NT    --MODIF 007
 ,CLI2.HORDNBR_NT        --MODIF 007
 ,CLREPCR2.SORDNBR_NT    --MODIF 007
 ,CLI3.HORDNBR_NT        --MODIF 007
 ,CLREPCR3.SORDNBR_NT    --MODIF 007
 ,FACADMTYP_B             --MODIF 008
 ,CONVERT(char(8),CRTVRSINC_D,112) --MODIF 009
 ,RECBRK_B       --MODIF 010
 ,RECBRK_R        --MODIF 010
 ,CONTR.CNATYP_CT   --MODIF 011
 ,SECTION.CLMCUTOFF_B  --MODIF 012
 ,SECTION.PRMCUTOFF_B  --MODIF 012
 ,SECTION.CLMRUNOFF_B  --MODIF 012
 ,SECTION.PRMRUNOFF_B   --MODIF 012
 ,SECTION.ASSFINANCE_CT  --MODIF 013   Champ rajout� au perim�tre modif du 09/12/2008  JR SPOT16593
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
 ,0                                                                                    --MODIF 18
 ,'FAC'                                                                              --MODIF 18
 ,CONVERT(char(8),CTRINC_D,112)                                                        --MODIF 18
 ,ESTV2C_COL_14=null
 ,ESTV2C_COL_15=null
 ,ESTV2C_COL_16=null
 ,ESTV2C_COL_17=FAMCHG.COMBAS_CF
 ,ESTV2C_COL_18=null
 ,ESTV2C_COL_19=null
 ,ESTV2C_COL_20=null
 ,ESTV2C_COL_21=null
 ,ESTV2C_COL_22=null
 ,ESTV2C_COL_23=null
 ,ESTV2C_COL_24=null
 ,isnull(SECIFRS.CTRPRI_B,0) -- modif [021]
 ,isnull(SECIFRS.PRILR_R,0)  -- modif [021]
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,isnull(SECIFRS.CANEGP_M,0) -- modif [022]
 ,NULL -- modif 007 CONTR.MULTUWY_NF for TRT
 ,convert(char(8), CONTR.SCOEXP_D , 112) -- modif 007 EXP2_D
 ,NULL -- modif 007 FAMRSVP.MULTICAN_D
 FROM BFAC..TSECTION SECTION, BFAC..TCONTR CONTR, BFAC..TFAMLIA FAMLIA, BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  --MODIF 007 MODIF 15
    ,BCLI..TCLINTSU CLREPCR2  --MODIF 007 MODIF 15
    ,BCLI..TCLINTSU CLREPCR3  --MODIF 007 MODIF 15
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   -- Modif 16
	,BFAC..TSECIFRS SECIFRS   --[021]		
  WHERE SECSTS_CT IN (16,18,19) 
    and CTRSTS_CT IN (16,18,19) 
    and CTRLCK_B != 0 -- modif 20 du 05/02/2018 ;   FAC Invalides	
    and SECTION.CTR_NF=CONTR.CTR_NF
    and SECTION.END_NT=CONTR.END_NT
    and SECTION.UWY_NF=CONTR.UWY_NF
    and SECTION.UW_NT=CONTR.UW_NT

    and SECTION.CTR_NF*=FAMLIA.CTR_NF
    and SECTION.END_NT*=FAMLIA.END_NT
    and SECTION.SEC_NF*=FAMLIA.SEC_NF
    and SECTION.UWY_NF*=FAMLIA.UWY_NF
    and SECTION.UW_NT*=FAMLIA.UW_NT

    and SECTION.CTR_NF*=FAMCHG.CTR_NF
    and SECTION.END_NT*=FAMCHG.END_NT
    and SECTION.SEC_NF*=FAMCHG.SEC_NF
    and SECTION.UWY_NF*=FAMCHG.UWY_NF
    and SECTION.UW_NT*=FAMCHG.UW_NT

    and SECTION.CTR_NF=SECIFRS.CTR_NF    -- MODIF [021]
    and SECTION.END_NT=SECIFRS.END_NT    -- MODIF [021]
    and SECTION.SEC_NF=SECIFRS.SEC_NF    -- MODIF [021]
    and SECTION.UWY_NF=SECIFRS.UWY_NF    -- MODIF [021]
    and SECTION.UW_NT=SECIFRS.UW_NT      -- MODIF [021]
  
     and CONTR.CED_NF*=CLI1.CLI_NF

     and CONTR.CED_NF*=CLREPCR1.CLI_NF
     and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF  -- MODIF 15
     
     and CONTR.ORGCED_NF*=CLI2.CLI_NF

     and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
     and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF  -- MODIF 15
     
     and CONTR.PRD_NF*=CLI3.CLI_NF

     and CONTR.PRD_NF*=CLREPCR3.CLI_NF
     and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF  -- MODIF 15

     and SECTION.SSD_CF  = T.SSD_CF           -- Modif 16
     and CONTR.SSD_CF  = T.SSD_CF             -- Modif 16
     and T.BATCHUSER_CF = suser_name()        -- Modif 16
					and SECIFRS.RECOD_D < @v_pos_booking_minus_days
					and (SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))--[002]
END
IF(@norme_cf = 'I17P')
BEGIN
-- P�rim�tre pour les facs
SELECT
  SECTION.SSD_CF
 ,@p_segtyp_ct
 ,SECTION.CTR_NF
 ,SECTION.END_NT
 ,SECTION.SEC_NF
 ,SECTION.UWY_NF
 ,SECTION.UW_NT
 ,ACCESB_CF
 ,'M'  --  isnull( CTRULT.ADMMODPRM_CT,'M' )
 ,ANLCTY_CF
 ,CONVERT(char(8),CAN_DT,112)
 ,CED_NF
 ,CLI1.CLICTY_CF
 ,CLI1.CLINAT_CF
 ,NULL
 ,1           -- En Facs il s agit toujours de commissions fixes
 ,CTBGENFEE_R
 ,CTBTYP_CT
 ,CONVERT(char(8),CTRINC_D,112)
 ,CLI1.CLISSD_CF -- Permet l'affectation de CTRRET_B
 ,CUTSHA_R
 ,SECTION.DIV_NT
 ,FAMLIA.EGPCUR_CF
 ,CONTR.ESTCRB_CT
 ,ESTCTR_NF
 ,ESTEND_B
 ,NULL -- ESTSEC_NF par defaut
 ,CONVERT(char(8),CTREXP_D,112)
 ,FIXCOM_R
 ,SECTION.FRSUWY_NF
 ,GANPAYORD_NT
 ,GAR_CF
 ,GENPRMPAY_NF
 ,GENPRMSEN_NF
 ,NULL -- Non renseigne pour les facs
 ,LAYCAP_M
 ,LIFTRTTYP_CF
 ,LOB_CF
 ,LOSCOREXI_B
 ,LOSCORHIG_R
 ,LOSCORLOW_R
 ,LOSCORRAT_R
 ,LOSCTB_R
 ,LOSCTBEXI_B
 ,MAXCOM_R
 ,MAXRATCLP_R
 ,MINCOM_R
 ,MINRATCLP_R
 ,NAT_CF
 ,NULL        -- modifs du 08/10/1998 le champs ORDNBR_NT est forc� � NULL
 ,PCPCUR_CF
 ,PCPRSKTRY_CF
 ,NULL  -- Non renseigne pour les facs
 ,PRD_NF
 ,PRFCOM_R
 ,PRFCOMEXI_B
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,PRMNETCOM_B
 ,NULL -- Non renseigne pour les facs
 ,REIEXI_B
 ,REIFRE_B
 ,REINBR_N
 ,REIUNL_B
 ,RESTRFDUR_N
 ,RESTRFTYP_CF
 ,NULL
 ,NULL
 ,SCLCOMEXI_B
 ,SCLCTBEXI_B
 ,SCOADDEGP_M = (case when (SCOADDEGP_M=null and CONTR.UWORG_CF = 248) then SCOORGEGP_M else SCOADDEGP_M end) --[023] SCOADDEGP_M -- SCOEGP_M par defaut anciennement scogloegp (23/04/99)         
 ,CONVERT(char(8),SCOINC_D,112)
 ,SECACCSTS_CT
 ,CONVERT(char(8),CTRINC_D,112)  -- Affectation de SECINC_D
 ,SECSTS_CT
 ,SEG_NF
 ,SOB_CF
 ,SUBNAT_CF
 ,NULL
 ,TOP_CF
 ,'F'     -- CTRNAT_CT
 ,UWGRP_CF
 ,NULL
 ,NULL     -- Non renseigne pour les facs
 ,CONVERT(char(8),ORGINC_D,112)
 ,LIARIDSHA_B
 ,NULL
 ,RIDSHA_R
 ,CTBCALLVL_CF
 ,NULL -- Non renseigne pour les facs
 ,NULL
 ,NULL
 ,ACCADMTYP_CT
 ,NULL
 ,CTRSTS_CT
 ,OVRCOM_R
 ,OVRCOMTYP_CT
 ,TAXCNDEXI_B
 ,PRDBRK_R
 ,ACCBRK_R
 ,NULL -- LIACUR_CF : non utilis� pour les facs
 ,NULL -- ERNPRMADM_B : non utilis� pour les facs
 ,CONVERT(char(8),SECCAN_D,112) -- Permet l'affectation de EXP_D
 ,SCOORGEGP_M                     -- Permet l'affectation de SCOEGP_M
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
 ,SECTION.USRCRTCOD_CT   -- Champ rajout� au perim�tre modif du 12/03/98
 ,SECTION.USRCRTVAL_LM   -- Champ rajout� au perim�tre modif du 12/03/98
 ,FAMCHG.PRDBRKTYP_CT        -- Champ rajout� au perim�tre modif du 20/03/98
 ,FAMCHG.ACCBRKTYP_CT        -- Champ rajout� au perim�tre modif du 20/03/98
 ,CONTR.UWORG_CF     -- Champ rajout� au perim�tre modif du 26/05/98
 ,SECTION.SECQUA_CF      -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA2_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA3_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA4_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA5_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.ADMGRP_CF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.ORGCED_NF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.REITYP_CF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,FAMLIA.PRTCUR_CF       -- Champ rajout� au perim�tre modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,CONTR.CTRACCSTS_CT     -- Champ rajout� au perim�tre modif du 15/09/98
 ,datepart(yy,CONTR.CTRACC_D) -- Champ rajout� au perim�tre modif du 15/09/98
 ,FAMLIA.PMLRAT_R        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CLI1.HORDNBR_NT        --MODIF 007
 ,CLREPCR1.SORDNBR_NT    --MODIF 007
 ,CLI2.HORDNBR_NT        --MODIF 007
 ,CLREPCR2.SORDNBR_NT    --MODIF 007
 ,CLI3.HORDNBR_NT        --MODIF 007
 ,CLREPCR3.SORDNBR_NT    --MODIF 007
 ,FACADMTYP_B             --MODIF 008
 ,CONVERT(char(8),CRTVRSINC_D,112) --MODIF 009
 ,RECBRK_B       --MODIF 010
 ,RECBRK_R        --MODIF 010
 ,CONTR.CNATYP_CT   --MODIF 011
 ,SECTION.CLMCUTOFF_B  --MODIF 012
 ,SECTION.PRMCUTOFF_B  --MODIF 012
 ,SECTION.CLMRUNOFF_B  --MODIF 012
 ,SECTION.PRMRUNOFF_B   --MODIF 012
 ,SECTION.ASSFINANCE_CT  --MODIF 013   Champ rajout� au perim�tre modif du 09/12/2008  JR SPOT16593
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
 ,0                                                                                    --MODIF 18
 ,'FAC'                                                                             --MODIF 18
 ,CONVERT(char(8),CTRINC_D,112)                                                        --MODIF 18
 ,ESTV2C_COL_14=null
 ,ESTV2C_COL_15=null
 ,ESTV2C_COL_16=null
 ,ESTV2C_COL_17=FAMCHG.COMBAS_CF
 ,ESTV2C_COL_18=null
 ,ESTV2C_COL_19=null
 ,ESTV2C_COL_20=null
 ,ESTV2C_COL_21=null
 ,ESTV2C_COL_22=null
 ,ESTV2C_COL_23=null
 ,ESTV2C_COL_24=null
 ,isnull(SECIFRS.CTRPRI_B,0) -- modif [021]
 ,isnull(SECIFRS.PRILR_R,0)  -- modif [021]
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,isnull(SECIFRS.CANEGP_M,0) -- modif [022]
 ,NULL -- modif 007 CONTR.MULTUWY_NF for TRT
 ,convert(char(8), CONTR.SCOEXP_D , 112) -- modif 007 EXP2_D
 ,NULL -- modif 007 FAMRSVP.MULTICAN_D
 FROM BFAC..TSECTION SECTION, BFAC..TCONTR CONTR, BFAC..TFAMLIA FAMLIA, BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  --MODIF 007 MODIF 15
    ,BCLI..TCLINTSU CLREPCR2  --MODIF 007 MODIF 15
    ,BCLI..TCLINTSU CLREPCR3  --MODIF 007 MODIF 15
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   -- Modif 16
	,BFAC..TSECIFRS SECIFRS   --[021]		
	,BEST..TI17CLOPER CLOPER
  WHERE SECSTS_CT IN (16,18,19)
    and CTRSTS_CT IN (16,18,19)
    and CTRLCK_B != 0 -- modif 20 du 05/02/2018 ;   FAC Invalides	
    and SECTION.CTR_NF=CONTR.CTR_NF
    and SECTION.END_NT=CONTR.END_NT
    and SECTION.UWY_NF=CONTR.UWY_NF
    and SECTION.UW_NT=CONTR.UW_NT

    and SECTION.CTR_NF*=FAMLIA.CTR_NF
    and SECTION.END_NT*=FAMLIA.END_NT
    and SECTION.SEC_NF*=FAMLIA.SEC_NF
    and SECTION.UWY_NF*=FAMLIA.UWY_NF
    and SECTION.UW_NT*=FAMLIA.UW_NT

    and SECTION.CTR_NF*=FAMCHG.CTR_NF
    and SECTION.END_NT*=FAMCHG.END_NT
    and SECTION.SEC_NF*=FAMCHG.SEC_NF
    and SECTION.UWY_NF*=FAMCHG.UWY_NF
    and SECTION.UW_NT*=FAMCHG.UW_NT

    and SECTION.CTR_NF=SECIFRS.CTR_NF    -- MODIF [021]
    and SECTION.END_NT=SECIFRS.END_NT    -- MODIF [021]
    and SECTION.SEC_NF=SECIFRS.SEC_NF    -- MODIF [021]
    and SECTION.UWY_NF=SECIFRS.UWY_NF    -- MODIF [021]
    and SECTION.UW_NT=SECIFRS.UW_NT      -- MODIF [021]
				
  
     and CONTR.CED_NF*=CLI1.CLI_NF

     and CONTR.CED_NF*=CLREPCR1.CLI_NF
     and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF  -- MODIF 15
     
     and CONTR.ORGCED_NF*=CLI2.CLI_NF

     and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
     and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF  -- MODIF 15
     
     and CONTR.PRD_NF*=CLI3.CLI_NF

     and CONTR.PRD_NF*=CLREPCR3.CLI_NF
     and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF  -- MODIF 15

     and SECTION.SSD_CF  = T.SSD_CF           -- Modif 16
     and CONTR.SSD_CF  = T.SSD_CF             -- Modif 16
     and T.BATCHUSER_CF = suser_name()        -- Modif 16
					and SECIFRS.RECOD_D < @v_pos_booking_minus_days
					
					
					and CONTR.ACCESB_CF = CLOPER.ESB_CF
					and SECTION.SSD_CF= CLOPER.SSD_CF --[004]
					and CLOPER.PARM1='1'
					and (SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9))--[002]
END
IF(@norme_cf = 'I17L')
BEGIN
-- P�rim�tre pour les facs
SELECT
  SECTION.SSD_CF
 ,@p_segtyp_ct
 ,SECTION.CTR_NF
 ,SECTION.END_NT
 ,SECTION.SEC_NF
 ,SECTION.UWY_NF
 ,SECTION.UW_NT
 ,ACCESB_CF
 ,'M'  --  isnull( CTRULT.ADMMODPRM_CT,'M' )
 ,ANLCTY_CF
 ,CONVERT(char(8),CAN_DT,112)
 ,CED_NF
 ,CLI1.CLICTY_CF
 ,CLI1.CLINAT_CF
 ,NULL
 ,1           -- En Facs il s agit toujours de commissions fixes
 ,CTBGENFEE_R
 ,CTBTYP_CT
 ,CONVERT(char(8),CTRINC_D,112)
 ,CLI1.CLISSD_CF -- Permet l'affectation de CTRRET_B
 ,CUTSHA_R
 ,SECTION.DIV_NT
 ,FAMLIA.EGPCUR_CF
 ,CONTR.ESTCRB_CT
 ,ESTCTR_NF
 ,ESTEND_B
 ,NULL -- ESTSEC_NF par defaut
 ,CONVERT(char(8),CTREXP_D,112)
 ,FIXCOM_R
 ,SECTION.FRSUWY_NF
 ,GANPAYORD_NT
 ,GAR_CF
 ,GENPRMPAY_NF
 ,GENPRMSEN_NF
 ,NULL -- Non renseigne pour les facs
 ,LAYCAP_M
 ,LIFTRTTYP_CF
 ,LOB_CF
 ,LOSCOREXI_B
 ,LOSCORHIG_R
 ,LOSCORLOW_R
 ,LOSCORRAT_R
 ,LOSCTB_R
 ,LOSCTBEXI_B
 ,MAXCOM_R
 ,MAXRATCLP_R
 ,MINCOM_R
 ,MINRATCLP_R
 ,NAT_CF
 ,NULL        -- modifs du 08/10/1998 le champs ORDNBR_NT est forc� � NULL
 ,PCPCUR_CF
 ,PCPRSKTRY_CF
 ,NULL  -- Non renseigne pour les facs
 ,PRD_NF
 ,PRFCOM_R
 ,PRFCOMEXI_B
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,PRMNETCOM_B
 ,NULL -- Non renseigne pour les facs
 ,REIEXI_B
 ,REIFRE_B
 ,REINBR_N
 ,REIUNL_B
 ,RESTRFDUR_N
 ,RESTRFTYP_CF
 ,NULL
 ,NULL
 ,SCLCOMEXI_B
 ,SCLCTBEXI_B
 ,SCOADDEGP_M = (case when (SCOADDEGP_M=null and CONTR.UWORG_CF = 248) then SCOORGEGP_M else SCOADDEGP_M end) --[023] SCOADDEGP_M -- SCOEGP_M par defaut anciennement scogloegp (23/04/99)         
 ,CONVERT(char(8),SCOINC_D,112)
 ,SECACCSTS_CT
 ,CONVERT(char(8),CTRINC_D,112)  -- Affectation de SECINC_D
 ,SECSTS_CT
 ,SEG_NF
 ,SOB_CF
 ,SUBNAT_CF
 ,NULL
 ,TOP_CF
 ,'F'     -- CTRNAT_CT
 ,UWGRP_CF
 ,NULL
 ,NULL     -- Non renseigne pour les facs
 ,CONVERT(char(8),ORGINC_D,112)
 ,LIARIDSHA_B
 ,NULL
 ,RIDSHA_R
 ,CTBCALLVL_CF
 ,NULL -- Non renseigne pour les facs
 ,NULL
 ,NULL
 ,ACCADMTYP_CT
 ,NULL
 ,CTRSTS_CT
 ,OVRCOM_R
 ,OVRCOMTYP_CT
 ,TAXCNDEXI_B
 ,PRDBRK_R
 ,ACCBRK_R
 ,NULL -- LIACUR_CF : non utilis� pour les facs
 ,NULL -- ERNPRMADM_B : non utilis� pour les facs
 ,CONVERT(char(8),SECCAN_D,112) -- Permet l'affectation de EXP_D
 ,SCOORGEGP_M                     -- Permet l'affectation de SCOEGP_M
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
 ,SECTION.USRCRTCOD_CT   -- Champ rajout� au perim�tre modif du 12/03/98
 ,SECTION.USRCRTVAL_LM   -- Champ rajout� au perim�tre modif du 12/03/98
 ,FAMCHG.PRDBRKTYP_CT        -- Champ rajout� au perim�tre modif du 20/03/98
 ,FAMCHG.ACCBRKTYP_CT        -- Champ rajout� au perim�tre modif du 20/03/98
 ,CONTR.UWORG_CF     -- Champ rajout� au perim�tre modif du 26/05/98
 ,SECTION.SECQUA_CF      -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA2_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA3_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA4_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA5_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.ADMGRP_CF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.ORGCED_NF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.REITYP_CF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,FAMLIA.PRTCUR_CF       -- Champ rajout� au perim�tre modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,CONTR.CTRACCSTS_CT     -- Champ rajout� au perim�tre modif du 15/09/98
 ,datepart(yy,CONTR.CTRACC_D) -- Champ rajout� au perim�tre modif du 15/09/98
 ,FAMLIA.PMLRAT_R        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CLI1.HORDNBR_NT        --MODIF 007
 ,CLREPCR1.SORDNBR_NT    --MODIF 007
 ,CLI2.HORDNBR_NT        --MODIF 007
 ,CLREPCR2.SORDNBR_NT    --MODIF 007
 ,CLI3.HORDNBR_NT        --MODIF 007
 ,CLREPCR3.SORDNBR_NT    --MODIF 007
 ,FACADMTYP_B             --MODIF 008
 ,CONVERT(char(8),CRTVRSINC_D,112) --MODIF 009
 ,RECBRK_B       --MODIF 010
 ,RECBRK_R        --MODIF 010
 ,CONTR.CNATYP_CT   --MODIF 011
 ,SECTION.CLMCUTOFF_B  --MODIF 012
 ,SECTION.PRMCUTOFF_B  --MODIF 012
 ,SECTION.CLMRUNOFF_B  --MODIF 012
 ,SECTION.PRMRUNOFF_B   --MODIF 012
 ,SECTION.ASSFINANCE_CT  --MODIF 013   Champ rajout� au perim�tre modif du 09/12/2008  JR SPOT16593
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
 ,0                                                                                    --MODIF 18
 ,'FAC'                                                                             --MODIF 18
 ,CONVERT(char(8),CTRINC_D,112)                                                        --MODIF 18
 ,ESTV2C_COL_14=null
 ,ESTV2C_COL_15=null
 ,ESTV2C_COL_16=null
 ,ESTV2C_COL_17=FAMCHG.COMBAS_CF
 ,ESTV2C_COL_18=null
 ,ESTV2C_COL_19=null
 ,ESTV2C_COL_20=null
 ,ESTV2C_COL_21=null
 ,ESTV2C_COL_22=null
 ,ESTV2C_COL_23=null
 ,ESTV2C_COL_24=null
 ,isnull(SECIFRS.CTRPRI_B,0) -- modif [021]
 ,isnull(SECIFRS.PRILR_R,0)  -- modif [021]
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,isnull(SECIFRS.CANEGP_M,0) -- modif [022]
 ,NULL -- modif 007 CONTR.MULTUWY_NF for TRT
 ,convert(char(8), CONTR.SCOEXP_D , 112) -- modif 007 EXP2_D
 ,NULL -- modif 007 FAMRSVP.MULTICAN_D
 FROM BFAC..TSECTION SECTION, BFAC..TCONTR CONTR, BFAC..TFAMLIA FAMLIA, BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  --MODIF 007 MODIF 15
    ,BCLI..TCLINTSU CLREPCR2  --MODIF 007 MODIF 15
    ,BCLI..TCLINTSU CLREPCR3  --MODIF 007 MODIF 15
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   -- Modif 16
	,BFAC..TSECIFRS SECIFRS   --[021]		
	,BEST..TI17CLOPER CLOPER
  WHERE SECSTS_CT IN (16,18,19)
    and CTRSTS_CT IN (16,18,19)
    and CTRLCK_B != 0 -- modif 20 du 05/02/2018 ;   FAC Invalides	
    and SECTION.CTR_NF=CONTR.CTR_NF
    and SECTION.END_NT=CONTR.END_NT
    and SECTION.UWY_NF=CONTR.UWY_NF
    and SECTION.UW_NT=CONTR.UW_NT

    and SECTION.CTR_NF*=FAMLIA.CTR_NF
    and SECTION.END_NT*=FAMLIA.END_NT
    and SECTION.SEC_NF*=FAMLIA.SEC_NF
    and SECTION.UWY_NF*=FAMLIA.UWY_NF
    and SECTION.UW_NT*=FAMLIA.UW_NT

    and SECTION.CTR_NF*=FAMCHG.CTR_NF
    and SECTION.END_NT*=FAMCHG.END_NT
    and SECTION.SEC_NF*=FAMCHG.SEC_NF
    and SECTION.UWY_NF*=FAMCHG.UWY_NF
    and SECTION.UW_NT*=FAMCHG.UW_NT

    and SECTION.CTR_NF=SECIFRS.CTR_NF    -- MODIF [021]
    and SECTION.END_NT=SECIFRS.END_NT    -- MODIF [021]
    and SECTION.SEC_NF=SECIFRS.SEC_NF    -- MODIF [021]
    and SECTION.UWY_NF=SECIFRS.UWY_NF    -- MODIF [021]
    and SECTION.UW_NT=SECIFRS.UW_NT      -- MODIF [021]
				
  
     and CONTR.CED_NF*=CLI1.CLI_NF

     and CONTR.CED_NF*=CLREPCR1.CLI_NF
     and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF  -- MODIF 15
     
     and CONTR.ORGCED_NF*=CLI2.CLI_NF

     and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
     and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF  -- MODIF 15
     
     and CONTR.PRD_NF*=CLI3.CLI_NF

     and CONTR.PRD_NF*=CLREPCR3.CLI_NF
     and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF  -- MODIF 15

     and SECTION.SSD_CF  = T.SSD_CF           -- Modif 16
     and CONTR.SSD_CF  = T.SSD_CF             -- Modif 16
     and T.BATCHUSER_CF = suser_name()        -- Modif 16
					and SECIFRS.RECOD_D < @v_pos_booking_minus_days
					
					
					and CONTR.ACCESB_CF = CLOPER.ESB_CF
					and SECTION.SSD_CF= CLOPER.SSD_CF  --[004]
					and CLOPER.PARM2='1'
					and (SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9))--[002]
END
if @@error!=0 return @@error

return 0
go
if object_id('PsPeriFacIni') is not null
  print '<<< CREATED procedure PsPeriFacIni >>>'
else
  print '<<< FAILED CREATING procedure PsPeriFacIni >>>'
go
grant execute on PsPeriFacIni TO GDBBATCH, GOMEGA
go
