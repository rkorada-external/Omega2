use BEST
go
if object_id('PsPeriFacIni_02') is not null
begin
   drop procedure PsPeriFacIni_02
   if object_id('PsPeriFacIni_02') is not null
     print '<<< FAILED DROPPING procedure PsPeriFacIni_02 >>>'
   else
     print '<<< DROPPED procedure PsPeriFacIni_02 >>>'
end
go
create procedure PsPeriFacIni_02
  (
		@p_clo_date char(8),
		@p_x_days int,
		@p_segtyp_ct char(1), --type de segmentation ( 'A' ou 'E' )
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
  )
as
/***************************************************
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    - Descente du périmètre acceptation des bases facs au niveau CASEX.
Le filtre sur la date d'effet est fait ultérieurement par un programme C
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

/* Lancement de la proc qui génère le perimètre des affaires FAC */
/* ------------------------------------------------------------- */
print '==> @p_next_clo_date = %1!', @p_next_clo_date
print '==> @p_clo_date_plus_one = %1!', @p_clo_date_plus_one

IF(@norme_cf = 'I17G')
BEGIN
-- Périmètre pour les facs
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
 ,NULL        -- modifs du 08/10/1998 le champs ORDNBR_NT est forcé à NULL
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
 ,NULL -- LIACUR_CF : non utilisé pour les facs
 ,NULL -- ERNPRMADM_B : non utilisé pour les facs
 ,CONVERT(char(8),SECCAN_D,112) -- Permet l'affectation de EXP_D
 ,SCOORGEGP_M                     -- Permet l'affectation de SCOEGP_M
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
 ,SECTION.USRCRTCOD_CT   -- Champ rajouté au perimètre modif du 12/03/98
 ,SECTION.USRCRTVAL_LM   -- Champ rajouté au perimètre modif du 12/03/98
 ,FAMCHG.PRDBRKTYP_CT        -- Champ rajouté au perimètre modif du 20/03/98
 ,FAMCHG.ACCBRKTYP_CT        -- Champ rajouté au perimètre modif du 20/03/98
 ,CONTR.UWORG_CF     -- Champ rajouté au perimètre modif du 26/05/98
 ,SECTION.SECQUA_CF      -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA2_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA3_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA4_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA5_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.ADMGRP_CF        -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.ORGCED_NF        -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.REITYP_CF        -- Champ rajouté au perimètre modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,FAMLIA.PRTCUR_CF       -- Champ rajouté au perimètre modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,CONTR.CTRACCSTS_CT     -- Champ rajouté au perimètre modif du 15/09/98
 ,datepart(yy,CONTR.CTRACC_D) -- Champ rajouté au perimètre modif du 15/09/98
 ,FAMLIA.PMLRAT_R        -- Champ rajouté au perimètre modif du 15/09/98
 ,CLI1.HORDNBR_NT        
 ,CLREPCR1.SORDNBR_NT    
 ,CLI2.HORDNBR_NT        
 ,CLREPCR2.SORDNBR_NT    
 ,CLI3.HORDNBR_NT        
 ,CLREPCR3.SORDNBR_NT    
 ,FACADMTYP_B             
 ,CONVERT(char(8),CRTVRSINC_D,112) 
 ,RECBRK_B       
 ,RECBRK_R        
 ,CONTR.CNATYP_CT   
 ,SECTION.CLMCUTOFF_B  
 ,SECTION.PRMCUTOFF_B  
 ,SECTION.CLMRUNOFF_B  
 ,SECTION.PRMRUNOFF_B   
 ,SECTION.ASSFINANCE_CT  
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
 ,0                                                                                    
 ,'FAC'                                                                              
 ,CONVERT(char(8),CTRINC_D,112)                                                        
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
 ,isnull(SECIFRS.CTRPRI_B,0) 
 ,isnull(SECIFRS.PRILR_R,0)  
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,isnull(SECIFRS.CANEGP_M,0) 
 FROM BFAC..TSECTION SECTION 
	,BFAC..TCONTR CONTR
	,BFAC..TFAMLIA FAMLIA
	,BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  
    ,BCLI..TCLINTSU CLREPCR2  
    ,BCLI..TCLINTSU CLREPCR3  
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   
	,BFAC..TSECIFRS SECIFRS   		
  WHERE 	
     SECTION.CTR_NF=CONTR.CTR_NF
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

    and SECTION.CTR_NF=SECIFRS.CTR_NF    
    and SECTION.END_NT=SECIFRS.END_NT    
    and SECTION.SEC_NF=SECIFRS.SEC_NF    
    and SECTION.UWY_NF=SECIFRS.UWY_NF    
    and SECTION.UW_NT=SECIFRS.UW_NT     
  
     and CONTR.CED_NF*=CLI1.CLI_NF

     and CONTR.CED_NF*=CLREPCR1.CLI_NF
     and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF  
     
     and CONTR.ORGCED_NF*=CLI2.CLI_NF

     and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
     and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF  
     
     and CONTR.PRD_NF*=CLI3.CLI_NF

     and CONTR.PRD_NF*=CLREPCR3.CLI_NF
     and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF 

     and SECTION.SSD_CF  = T.SSD_CF          
     and CONTR.SSD_CF  = T.SSD_CF             
     and T.BATCHUSER_CF = suser_name()        
	
	and (SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))
	
	and (
	(SECIFRS.FRCIFRSBTCH_NT  = 1                   	-- [001] onerous Q+1
	and CONTR.CTRINC_D >= @p_clo_date_plus_one
	and CONTR.CTRINC_D <= @p_next_clo_date)      		-- dernier jour du trimestre de closing suivant 
	OR (SECTION.SECSTS_CT = 14 							-- [002] Fac Accepted
    and CONTR.CTRSTS_CT = 14)
	) 
END
IF(@norme_cf = 'I17P')
BEGIN
-- Périmètre pour les facs
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
 ,NULL        -- modifs du 08/10/1998 le champs ORDNBR_NT est forcé à NULL
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
 ,NULL -- LIACUR_CF : non utilisé pour les facs
 ,NULL -- ERNPRMADM_B : non utilisé pour les facs
 ,CONVERT(char(8),SECCAN_D,112) -- Permet l'affectation de EXP_D
 ,SCOORGEGP_M                     -- Permet l'affectation de SCOEGP_M
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
 ,SECTION.USRCRTCOD_CT   -- Champ rajouté au perimètre modif du 12/03/98
 ,SECTION.USRCRTVAL_LM   -- Champ rajouté au perimètre modif du 12/03/98
 ,FAMCHG.PRDBRKTYP_CT        -- Champ rajouté au perimètre modif du 20/03/98
 ,FAMCHG.ACCBRKTYP_CT        -- Champ rajouté au perimètre modif du 20/03/98
 ,CONTR.UWORG_CF     -- Champ rajouté au perimètre modif du 26/05/98
 ,SECTION.SECQUA_CF      -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA2_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA3_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA4_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA5_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.ADMGRP_CF        -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.ORGCED_NF        -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.REITYP_CF        -- Champ rajouté au perimètre modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,FAMLIA.PRTCUR_CF       -- Champ rajouté au perimètre modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,CONTR.CTRACCSTS_CT     -- Champ rajouté au perimètre modif du 15/09/98
 ,datepart(yy,CONTR.CTRACC_D) -- Champ rajouté au perimètre modif du 15/09/98
 ,FAMLIA.PMLRAT_R        -- Champ rajouté au perimètre modif du 15/09/98
 ,CLI1.HORDNBR_NT        
 ,CLREPCR1.SORDNBR_NT    
 ,CLI2.HORDNBR_NT        
 ,CLREPCR2.SORDNBR_NT    
 ,CLI3.HORDNBR_NT        
 ,CLREPCR3.SORDNBR_NT    
 ,FACADMTYP_B             
 ,CONVERT(char(8),CRTVRSINC_D,112) 
 ,RECBRK_B      
 ,RECBRK_R        
 ,CONTR.CNATYP_CT   
 ,SECTION.CLMCUTOFF_B  
 ,SECTION.PRMCUTOFF_B  
 ,SECTION.CLMRUNOFF_B  
 ,SECTION.PRMRUNOFF_B   
 ,SECTION.ASSFINANCE_CT  
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
 ,0                                                                                    
 ,'FAC'                                                                             
 ,CONVERT(char(8),CTRINC_D,112)                                                        
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
 ,isnull(SECIFRS.CTRPRI_B,0) 
 ,isnull(SECIFRS.PRILR_R,0)  
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,isnull(SECIFRS.CANEGP_M,0) 
 FROM BFAC..TSECTION SECTION, BFAC..TCONTR CONTR, BFAC..TFAMLIA FAMLIA, BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  
    ,BCLI..TCLINTSU CLREPCR2  
    ,BCLI..TCLINTSU CLREPCR3  
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   
	,BFAC..TSECIFRS SECIFRS   		
	,BEST..TI17CLOPER CLOPER
  WHERE 
     SECTION.CTR_NF=CONTR.CTR_NF
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

    and SECTION.CTR_NF=SECIFRS.CTR_NF    
    and SECTION.END_NT=SECIFRS.END_NT   
    and SECTION.SEC_NF=SECIFRS.SEC_NF    
    and SECTION.UWY_NF=SECIFRS.UWY_NF    
    and SECTION.UW_NT=SECIFRS.UW_NT      
				
  
     and CONTR.CED_NF*=CLI1.CLI_NF

     and CONTR.CED_NF*=CLREPCR1.CLI_NF
     and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF  
     
     and CONTR.ORGCED_NF*=CLI2.CLI_NF

     and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
     and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF  
     
     and CONTR.PRD_NF*=CLI3.CLI_NF

     and CONTR.PRD_NF*=CLREPCR3.CLI_NF
     and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF  

     and SECTION.SSD_CF  = T.SSD_CF           
     and CONTR.SSD_CF  = T.SSD_CF             
     and T.BATCHUSER_CF = suser_name()        
	
	
	and CONTR.ACCESB_CF = CLOPER.ESB_CF
	and SECTION.SSD_CF= CLOPER.SSD_CF --[004]
	and CLOPER.PARM1='1'
	and (SECIFRS.PARINISTS_CT IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9))
	
	and (SECIFRS.FRCIFRSBTCH_NT  = 1                   	-- onerous Q+1
	and CONTR.CTRINC_D >= @p_clo_date_plus_one
	and CONTR.CTRINC_D <= @p_next_clo_date      		-- dernier jour du trimestre de closing suivant 
	OR (SECTION.SECSTS_CT = 14 							-- [002] Fac Accepted
    and CONTR.CTRSTS_CT = 14)
	)
END
IF(@norme_cf = 'I17L')
BEGIN
-- Périmètre pour les facs
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
 ,NULL        -- modifs du 08/10/1998 le champs ORDNBR_NT est forcé à NULL
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
 ,NULL -- LIACUR_CF : non utilisé pour les facs
 ,NULL -- ERNPRMADM_B : non utilisé pour les facs
 ,CONVERT(char(8),SECCAN_D,112) -- Permet l'affectation de EXP_D
 ,SCOORGEGP_M                     -- Permet l'affectation de SCOEGP_M
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
 ,SECTION.USRCRTCOD_CT   -- Champ rajouté au perimètre modif du 12/03/98
 ,SECTION.USRCRTVAL_LM   -- Champ rajouté au perimètre modif du 12/03/98
 ,FAMCHG.PRDBRKTYP_CT        -- Champ rajouté au perimètre modif du 20/03/98
 ,FAMCHG.ACCBRKTYP_CT        -- Champ rajouté au perimètre modif du 20/03/98
 ,CONTR.UWORG_CF     -- Champ rajouté au perimètre modif du 26/05/98
 ,SECTION.SECQUA_CF      -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA2_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA3_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA4_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA5_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.ADMGRP_CF        -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.ORGCED_NF        -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.REITYP_CF        -- Champ rajouté au perimètre modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,FAMLIA.PRTCUR_CF       -- Champ rajouté au perimètre modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,CONTR.CTRACCSTS_CT     -- Champ rajouté au perimètre modif du 15/09/98
 ,datepart(yy,CONTR.CTRACC_D) -- Champ rajouté au perimètre modif du 15/09/98
 ,FAMLIA.PMLRAT_R        -- Champ rajouté au perimètre modif du 15/09/98
 ,CLI1.HORDNBR_NT        
 ,CLREPCR1.SORDNBR_NT   
 ,CLI2.HORDNBR_NT        
 ,CLREPCR2.SORDNBR_NT    
 ,CLI3.HORDNBR_NT        
 ,CLREPCR3.SORDNBR_NT    
 ,FACADMTYP_B             
 ,CONVERT(char(8),CRTVRSINC_D,112) 
 ,RECBRK_B       
 ,RECBRK_R        
 ,CONTR.CNATYP_CT   
 ,SECTION.CLMCUTOFF_B  
 ,SECTION.PRMCUTOFF_B  
 ,SECTION.CLMRUNOFF_B  
 ,SECTION.PRMRUNOFF_B   
 ,SECTION.ASSFINANCE_CT  
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
 ,0                                                                                    
 ,'FAC'                                                                             
 ,CONVERT(char(8),CTRINC_D,112)                                                        
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
 ,isnull(SECIFRS.CTRPRI_B,0) 
 ,isnull(SECIFRS.PRILR_R,0)  
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,isnull(SECIFRS.CANEGP_M,0) 
 FROM BFAC..TSECTION SECTION, 
 BFAC..TCONTR CONTR, 
 BFAC..TFAMLIA FAMLIA, 
 BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  
    ,BCLI..TCLINTSU CLREPCR2  
    ,BCLI..TCLINTSU CLREPCR3  
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   
	,BFAC..TSECIFRS SECIFRS   		
	,BEST..TI17CLOPER CLOPER
  WHERE  SECTION.CTR_NF=CONTR.CTR_NF
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

    and SECTION.CTR_NF=SECIFRS.CTR_NF    
    and SECTION.END_NT=SECIFRS.END_NT    
    and SECTION.SEC_NF=SECIFRS.SEC_NF    
    and SECTION.UWY_NF=SECIFRS.UWY_NF    
    and SECTION.UW_NT=SECIFRS.UW_NT      
				
  
     and CONTR.CED_NF*=CLI1.CLI_NF

     and CONTR.CED_NF*=CLREPCR1.CLI_NF
     and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF  
     
     and CONTR.ORGCED_NF*=CLI2.CLI_NF

     and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
     and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF  
     
     and CONTR.PRD_NF*=CLI3.CLI_NF

     and CONTR.PRD_NF*=CLREPCR3.CLI_NF
     and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF  

     and SECTION.SSD_CF  = T.SSD_CF           
     and CONTR.SSD_CF  = T.SSD_CF             
     and T.BATCHUSER_CF = suser_name()        
	
	
	
	and CONTR.ACCESB_CF = CLOPER.ESB_CF
	and SECTION.SSD_CF= CLOPER.SSD_CF  
	and CLOPER.PARM2='1'
	and (SECIFRS.LOCINISTS_CT IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9))
	
	and (SECIFRS.FRCIFRSBTCH_NT  = 1                   	-- [001] onerous Q+1
	and CONTR.CTRINC_D >= @p_clo_date_plus_one
	and CONTR.CTRINC_D <= @p_next_clo_date      		-- dernier jour du trimestre de closing suivant 
	OR (SECTION.SECSTS_CT = 14 							-- [002] Fac Accepted
    and CONTR.CTRSTS_CT = 14)
	)
END

IF(@norme_cf = 'I17S')
BEGIN
-- Périmètre pour les facs
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
 ,NULL        -- modifs du 08/10/1998 le champs ORDNBR_NT est forcé à NULL
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
 ,NULL -- LIACUR_CF : non utilisé pour les facs
 ,NULL -- ERNPRMADM_B : non utilisé pour les facs
 ,CONVERT(char(8),SECCAN_D,112) -- Permet l'affectation de EXP_D
 ,SCOORGEGP_M                     -- Permet l'affectation de SCOEGP_M
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
 ,SECTION.USRCRTCOD_CT   -- Champ rajouté au perimètre modif du 12/03/98
 ,SECTION.USRCRTVAL_LM   -- Champ rajouté au perimètre modif du 12/03/98
 ,FAMCHG.PRDBRKTYP_CT        -- Champ rajouté au perimètre modif du 20/03/98
 ,FAMCHG.ACCBRKTYP_CT        -- Champ rajouté au perimètre modif du 20/03/98
 ,CONTR.UWORG_CF     -- Champ rajouté au perimètre modif du 26/05/98
 ,SECTION.SECQUA_CF      -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA2_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA3_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA4_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,SECTION.SECQUA5_CF     -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.ADMGRP_CF        -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.ORGCED_NF        -- Champ rajouté au perimètre modif du 15/09/98
 ,CONTR.REITYP_CF        -- Champ rajouté au perimètre modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,FAMLIA.PRTCUR_CF       -- Champ rajouté au perimètre modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,NULL               -- Champ non utilisé modif du 15/09/98
 ,CONTR.CTRACCSTS_CT     -- Champ rajouté au perimètre modif du 15/09/98
 ,datepart(yy,CONTR.CTRACC_D) -- Champ rajouté au perimètre modif du 15/09/98
 ,FAMLIA.PMLRAT_R        -- Champ rajouté au perimètre modif du 15/09/98
 ,CLI1.HORDNBR_NT        
 ,CLREPCR1.SORDNBR_NT    
 ,CLI2.HORDNBR_NT        
 ,CLREPCR2.SORDNBR_NT    
 ,CLI3.HORDNBR_NT        
 ,CLREPCR3.SORDNBR_NT    
 ,FACADMTYP_B             
 ,CONVERT(char(8),CRTVRSINC_D,112) 
 ,RECBRK_B       
 ,RECBRK_R        
 ,CONTR.CNATYP_CT   
 ,SECTION.CLMCUTOFF_B  
 ,SECTION.PRMCUTOFF_B  
 ,SECTION.CLMRUNOFF_B  
 ,SECTION.PRMRUNOFF_B   
 ,SECTION.ASSFINANCE_CT  
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
 ,0                                                                                    
 ,'FAC'                                                                              
 ,CONVERT(char(8),CTRINC_D,112)                                                        
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
 ,isnull(SECIFRS.CTRPRI_B,0) 
 ,isnull(SECIFRS.PRILR_R,0)  
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,isnull(SECIFRS.CANEGP_M,0) 
 FROM BFAC..TSECTION SECTION 
	,BFAC..TCONTR CONTR
	,BFAC..TFAMLIA FAMLIA
	,BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  
    ,BCLI..TCLINTSU CLREPCR2  
    ,BCLI..TCLINTSU CLREPCR3  
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   
	,BFAC..TSECIFRS SECIFRS   		
  WHERE 	
     SECTION.CTR_NF=CONTR.CTR_NF
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

    and SECTION.CTR_NF=SECIFRS.CTR_NF    
    and SECTION.END_NT=SECIFRS.END_NT    
    and SECTION.SEC_NF=SECIFRS.SEC_NF    
    and SECTION.UWY_NF=SECIFRS.UWY_NF    
    and SECTION.UW_NT=SECIFRS.UW_NT     
  
     and CONTR.CED_NF*=CLI1.CLI_NF

     and CONTR.CED_NF*=CLREPCR1.CLI_NF
     and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF  
     
     and CONTR.ORGCED_NF*=CLI2.CLI_NF

     and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
     and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF  
     
     and CONTR.PRD_NF*=CLI3.CLI_NF

     and CONTR.PRD_NF*=CLREPCR3.CLI_NF
     and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF 

     and SECTION.SSD_CF  = T.SSD_CF          
     and CONTR.SSD_CF  = T.SSD_CF             
     and T.BATCHUSER_CF = suser_name()        
	
	and (SECIFRS.GRPINISTS_CT IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9))
	
	and SECIFRS.FRCIFRSBTCH_NT  = 1                   	-- onerous Q+1
	and CONTR.CTRINC_D >= @p_clo_date_plus_one
	and CONTR.CTRINC_D <= @p_next_clo_date      		-- dernier jour du trimestre de closing suivant 
END

if @@error!=0 return @@error

return 0
go
if object_id('PsPeriFacIni_02') is not null
  print '<<< CREATED procedure PsPeriFacIni_02 >>>'
else
  print '<<< FAILED CREATING procedure PsPeriFacIni_02 >>>'
go
grant execute on PsPeriFacIni_02 TO GDBBATCH, GOMEGA
go
