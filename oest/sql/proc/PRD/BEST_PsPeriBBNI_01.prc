use BEST
go
if object_id('PsPeriBBNI_01') is not null
begin
   drop procedure PsPeriBBNI_01
   if object_id('PsPeriBBNI_01') is not null
     print '<<< FAILED DROPPING procedure PsPeriBBNI_01 >>>'
   else
     print '<<< DROPPED procedure PsPeriBBNI_01 >>>' 
end

go
create procedure PsPeriBBNI_01
(
  @p_clo_date       char(8),
  @p_segtyp_ct      char(1), --type de segmentation ( 'A' ou 'E' )
  @p_quarter_end     char(8),
  @norme_cf         char(5)
)
as
/***************************************************
Base principale : BEST
Version: 1
Auteur: MZM
Date de creation:
Description du programme:
    Creation d'un Pericase Dedié au BBNI ((Bound But Not yet Incurred)
Conditions d'execution:
	Couloir EBS
Commentaires:
_________________
MODIFICATIONS
[001] 
*****************************************************/
declare @erreur int

DECLARE
  @v_clo_date datetime
  
DECLARE
  @v_quarter_end datetime

 
IF(@norme_cf = 'EBS')
BEGIN
  SELECT @v_clo_date = CONVERT(datetime, @p_clo_date, 112)
  
 -- 

  IF(@p_quarter_end = 'NONE')   -- Si pas de CUT_OFF_Date alors 
  BEGIN
			SELECT @v_quarter_end = CONVERT(datetime, @p_clo_date, 112)
  END
  ELSE 
  BEGIN
  	SELECT @v_quarter_end = CONVERT(datetime, @p_quarter_end, 112)
  END
END


select SECTION.SSD_CF,
      @p_segtyp_ct,
      SECTION.CTR_NF,
      SECTION.END_NT,
      SECTION.SEC_NF,
      SECTION.UWY_NF,
      SECTION.UW_NT,
      ACCESB_CF,
      ADMMODPRM_CT,
      ANLCTY_CF,
      convert(char(8), CAN_DT, 112),
      CED_NF,
      CLI1.CLICTY_CF,
      CLI1.CLINAT_CF,
      CLMACT_M,
      COMTYP_CT=(case when ESTCOMTYP_CT=3 then 4                  
            when ESTCOMTYP_CT=4 then 2                            
                      when ESTCOMTYP_CT=null then 5               
                      else COMTYP_CT
                end),                                             
      CTBGENFEE_R,
      CTBTYP_CT=(case when ESTCBTTYP_CT=3 then 4                  
                      when ESTCBTTYP_CT=null then 4
                      else CTBTYP_CT
                end),                                             
      convert(char(8), CTRINC_D, 112),
      CTRRET_B = (case when (CLI1.CLISSD_CF <> null) then 1 else 0 end),  -- CTRRET_B
      CUTSHA_R,
      0,
      FAMLIA.EGPCUR_CF,
      CONTR.ESTCRB_CT,
      ESTCTR_NF,
      ESTEND_B,
      null,            -- ESTSEC_NF par defaut
      convert(char(8), SCOEXP_D, 112), -- EXP_D par defaut
      FIXCOM_R,
      SECTION.FRSUWY_NF,
      GANPAYORD_NT,
      GAR_CF,
      GENPRMPAY_NF,
      GENPRMSEN_NF,
      isnull(INSPOL_R,1),
      LAYCAP_M,
      LIFTRTTYP_CF,
      LOB_CF,
      LOSCOREXI_B,
      LOSCORHIG_R,
      LOSCORLOW_R,
      LOSCORRAT_R,
      LOSCTB_R,
      LOSCTBEXI_B,
      MAXCOM_R,
      MAXRATCLP_R,
      MINCOM_R,
      MINRATCLP_R,
      NAT_CF,
      null,        -- modifs du 08/10/1998, le champs ORDNBR_NT est forc� � null
      PCPCUR_CF,
      PCPRSKTRY_CF,
      isnull(POLDURMTH_NF,12),
      PRD_NF,
      PRFCOM_R,
      PRFCOMEXI_B,
      PRMEFFLOA_M,
      PRMEFFLOA_R,
      PRMFIXEFF_R,
      PRMFLCRAT_B,
      PRMMAXEFF_R,
      PRMMINEFF_R,
      PRMNETCOM_B,
      PRMPRTSCL_B,
      REIEXI_B,
      REIFRE_B, -- = (case when (FAMREI.REIPRMPTP_R=null OR FAMREI.REIPRMPTP_R != 0) then 0 else 1 end), -- REIFRE_B, [037]
      REINBR_N,
      REIUNL_B,
      RESTRFDUR_N,
      RESTRFTYP_CF,
      SBJCPTDEF_B,
      DEFSBJPRM_M,     --SBJPRM_M par defaut
      SCLCOMEXI_B,
      SCLCTBEXI_B,
      SCOGLOEGP_M = (case when (SCOGLOEGP_M=null and CONTR.UWORG_CF = 248) then SCOORGEGP_M else SCOGLOEGP_M end),     --SCOEGP_M par defaut  -- [036] SCOGLOEGP_M 
      convert(char(8), SCOINC_D, 112),
      SECACCSTS_CT,
      convert(char(8), SECINC_D, 112),
      SECSTS_CT,
      SEG_NF,
      SOB_CF,
      SUBNAT_CF,
      SUPLOATYP_CT,
      TOP_CF,
      'N',           -- CTRNAT_CT par defaut
      UWGRP_CF,
      ACCFRQ_CT,
      WRKCAT_CT,
      convert(char(8), ORGINC_D, 112),
      LIARIDSHA_B,
      FLAPRM_B,
      RIDSHA_R,
      CTBCALLVL_CF,
      0,               -- CTBCOM_B par defaut
      PRMPRT_M,
      PRMPRTCUR_CF,
      ACCADMTYP_CT,
      SBJPRMCUR_CF,
      CTRSTS_CT,
      OVRCOM_R,
      OVRCOMTYP_CT,
      TAXCNDEXI_B,
      PRDBRK_R,
      ACCBRK_R,
      LIACUR_CF,
      isnull(ERNPRMADM_B, 1),
      convert(char(8), SECCAN_D, 112),
      SCOORGEGP_M,                    
      ESTSBJPRM_M,                    
      SBJPRMCPT_M,                    

      null, 
      null, 
      null, 
      null, 

      SECTION.USRCRTCOD_CT,     
      SECTION.USRCRTVAL_LM,     

      FAMCHG.PRDBRKTYP_CT,      
      FAMCHG.ACCBRKTYP_CT,      

      CONTR.UWORG_CF,           

      SECTION.SECQUA_CF,        
      SECTION.SECQUA2_CF,       
      SECTION.SECQUA3_CF,       
      SECTION.SECQUA4_CF,       
      SECTION.SECQUA5_CF,       
      CONTR.ADMGRP_CF,          
      CONTR.ORGCED_NF,          
      CONTR.REITYP_CF,          
      FAMCOTP.PRMMINACT_R,      
      FAMCOTP.PRMFIXACT_R,      
      FAMCOTP.PRMMAXACT_R,      
      FAMCOTP.CLMPRMACT_R,      
      FAMCOTP.FLAPRM1_M,        
      FAMCOTP.FLAPRMCU1_CF,     
      FAMCOTP.FLAPRM2_M,        
      FAMCOTP.FLAPRMCU2_CF,     
      FAMCOTP.FLAPRM3_M,        
      FAMCOTP.FLAPRMCU3_CF,     
      FAMCOTP.MINPRVPR1_M,      
      FAMCOTP.PRVPRMCU1_CF,     
      FAMCOTP.MINPRVPR2_M,      
      FAMCOTP.PRVPRMCU2_CF,     
      FAMCOTP.MINPRVPR3_M,      
      FAMCOTP.PRVPRMCU3_CF,     
      null,                     
      FAMCOTP.PRVPRM_B,         
      FAMCOTP.DEFSBJPRM_M,           
      FAMCOTP.ESTSBJPRM_M,           
      FAMCOTP.SBJPRMCPT_M,           
      CONTR.CTRACCSTS_CT,            
      datepart( yy, CONTR.CTRACC_D ),
      FAMLIA.PMLRAT_R,               
      CLI1.HORDNBR_NT,               
      CLREPCR1.SORDNBR_NT,           
      CLI2.HORDNBR_NT,               
      CLREPCR2.SORDNBR_NT,           
      CLI3.HORDNBR_NT,               
      CLREPCR3.SORDNBR_NT,           
      CONTR.FACADMTYP_B,             
      convert(char(8), CRTVRSINC_D, 112),
      RECBRK_B,                          
      RECBRK_R,                          
      CONTR.CNATYP_CT,                   
      SECTION.CLMCUTOFF_B,               
      SECTION.PRMCUTOFF_B,               
      SECTION.CLMRUNOFF_B,               
      SECTION.PRMRUNOFF_B,               
      SECTION.ASSFINANCE_CT              
    ,FAMCOTP.FLAPRM4_M
    ,FAMCOTP.FLAPRMCU4_CF
    ,FAMCOTP.FLAPRM5_M
    ,FAMCOTP.FLAPRMCU5_CF
    ,FAMCOTP.MINPRVPR4_M
    ,FAMCOTP.PRVPRMCU4_CF
    ,FAMCOTP.MINPRVPR5_M
    ,FAMCOTP.PRVPRMCU5_CF
    ,FAMCHG.ESTLOSCORTYP_CT
    ,ESTV2C_COL_01=null
    ,SECTION.USGAAP_CT   
    ,FAMRSVP.URRCAL_R    
    ,FAMFUNW.CLMFUN_R    
    ,FAMFUNW.CLMFUNCAS_R 
    ,FAMFUNW.CLMFUNINT_R 
    ,FAMFUNW.URRFUN_R    
    ,FAMFUNW.URRFUNCAS_R 
    ,FAMFUNW.URRFUNINT_R 
    ,FAMFUNW.ANNFUNINT_R 
    ,(case when ACCSEND.PAYFRQ_CT is not null then isnull(convert(int,ACCSNDDEL_N),0) else isnull(convert(int,ACCSNDDEL_N),0) +isnull(convert(int,STLREQDEL_N),0)+isnull(convert(int,CFLDEL_N),0) end)                       --MODIF 022 + modif 033 : if the "Payment frequency" field is entered  then total delay = account delay, else  total delay = account delay + payment delay + cashflow delay.
    ,"TRT"  
    ,convert(char(8), CTRINC_D, 112) 
    ,SECTION.PARENTGAAPIO_CT
    ,SECTION.LOCALGAAPIO_CT
    ,ESTV2C_COL_16=null
    ,ESTV2C_COL_17=FAMCHG.COMBAS_CF
    ,FAMCOTP.PAYFRQ_CT                              
    ,convert ( char (8), FAMCOTP.FIRPAYDUE_D, 112)  
    ,null
    ,null
    ,convert(char(8), FAMRSVP.POLED_D, 112)         
    ,ESTV2C_COL_23=null
    ,ESTV2C_COL_24=null
    ,isnull(SECIFRS.CTRPRI_B,0) 
    ,isnull(SECIFRS.PRILR_R,0)  
    ,ESTV2C_COL_27=null	  
    ,ACCSEND.PAYFRQ_CT		 
    ,substring(convert(char(8), CTRINC_D, 112), 1,4)+isnull(substring(convert ( char (8), ACCSEND.PAYDUE_D, 112),5,4), '0101')     
    ,isnull(SECIFRS.CANEGP_M,0)         
		,CONTR.MULTUWY_NF
    ,convert(char(8), CONTR.CTREXP_D, 112)
    ,convert(char(8), FAMRSVP.MULTICAN_D, 112)
from BTRT..TSECTION SECTION
   	,BTRT..TCONTR CONTR
   	,BTRT..TFAMLIA FAMLIA
   	,BTRT..TFAMCHG FAMCHG
   	,BTRT..TFAMCOTP FAMCOTP
   	,BTRT..TACCSEND ACCSEND
   	,BCLI..TCLIENT CLIENT
    ,BTRT..TFAMRSVP FAMRSVP
  	,BCLI..TCLINTSU CLREPCR1  
  	,BCLI..TCLINTSU CLREPCR2  
  	,BCLI..TCLINTSU CLREPCR3  
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T        
    ,BTRT..TFAMFUNW FAMFUNW   
		,BTRT..TSECIFRS SECIFRS   

where   
      SECTION.CTR_NF=CONTR.CTR_NF
  and SECTION.END_NT=CONTR.END_NT
  and SECTION.UWY_NF=CONTR.UWY_NF
  and SECTION.UW_NT=CONTR.UW_NT
  and CTRLCK_B <> 1 -- Arret des estimations pour les traites Invalides
  
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

  and SECTION.CTR_NF*=FAMCOTP.CTR_NF
  and SECTION.END_NT*=FAMCOTP.END_NT
  and SECTION.SEC_NF*=FAMCOTP.SEC_NF
  and SECTION.UWY_NF*=FAMCOTP.UWY_NF
  and SECTION.UW_NT*=FAMCOTP.UW_NT

  and SECTION.CTR_NF*=ACCSEND.CTR_NF
  and CONTR.CED_NF*=CLIENT.CLI_NF

  and SECTION.CTR_NF*=FAMRSVP.CTR_NF
  and SECTION.END_NT*=FAMRSVP.END_NT
  and SECTION.SEC_NF*=FAMRSVP.SEC_NF
  and SECTION.UWY_NF*=FAMRSVP.UWY_NF
  and SECTION.UW_NT*=FAMRSVP.UW_NT

  and SECTION.CTR_NF*=FAMFUNW.CTR_NF
  and SECTION.END_NT*=FAMFUNW.END_NT
  and SECTION.SEC_NF*=FAMFUNW.SEC_NF
  and SECTION.UWY_NF*=FAMFUNW.UWY_NF
  and SECTION.UW_NT*=FAMFUNW.UW_NT  

  and SECTION.CTR_NF*=SECIFRS.CTR_NF
  and SECTION.END_NT*=SECIFRS.END_NT
  and SECTION.SEC_NF*=SECIFRS.SEC_NF
  and SECTION.UWY_NF*=SECIFRS.UWY_NF
  and SECTION.UW_NT*=SECIFRS.UW_NT  
  
  and CONTR.CED_NF*=CLI1.CLI_NF
  and CONTR.CED_NF*=CLREPCR1.CLI_NF
  and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF   
  and CONTR.ORGCED_NF*=CLI2.CLI_NF
  and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
  and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF   
  and CONTR.PRD_NF*=CLI3.CLI_NF
  and CONTR.PRD_NF*=CLREPCR3.CLI_NF
  and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF   


  and CONTR.SSD_CF  = T.SSD_CF                   
  and T.BATCHUSER_CF = suser_name()                  

  and ( ( @norme_cf = 'EBS' ) 
  and CONTR.CTRINC_D > @v_clo_date 
  and ( SECIFRS.RECOD_D < @v_clo_date OR  SECIFRS.RECOD_D < @v_quarter_end  )
   ) 
            
union
SELECT                       -- Perimetre pour les facs
  SECTION.SSD_CF  
 ,@p_segtyp_ct
 ,SECTION.CTR_NF
 ,SECTION.END_NT
 ,SECTION.SEC_NF
 ,SECTION.UWY_NF
 ,SECTION.UW_NT
 ,ACCESB_CF
 ,'M'  
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
--  ,CLI1.CLISSD_CF -- Permet l'affectation de CTRRET_B
 ,CTRRET_B = (case when (CLI1.CLISSD_CF <> null) then 1 else 0 end)  -- CTRRET_B
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
 ,NULL        
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
 ,SCOADDEGP_M = (case when (SCOADDEGP_M=null and CONTR.UWORG_CF = 248) then SCOORGEGP_M else SCOADDEGP_M end) 
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
 ,NULL 
 ,NULL 
 ,NULL 
 ,NULL 
 ,NULL 
 ,NULL 
 ,SECTION.USRCRTCOD_CT   
 ,SECTION.USRCRTVAL_LM   
 ,FAMCHG.PRDBRKTYP_CT        
 ,FAMCHG.ACCBRKTYP_CT       
 ,CONTR.UWORG_CF     
 ,SECTION.SECQUA_CF      
 ,SECTION.SECQUA2_CF     
 ,SECTION.SECQUA3_CF     
 ,SECTION.SECQUA4_CF     
 ,SECTION.SECQUA5_CF     
 ,CONTR.ADMGRP_CF       
 ,CONTR.ORGCED_NF        
 ,CONTR.REITYP_CF        
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL              
 ,NULL               
 ,NULL             
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL               
 ,FAMLIA.PRTCUR_CF      
 ,NULL               
 ,NULL               
 ,NULL               
 ,NULL               
 ,CONTR.CTRACCSTS_CT     
 ,datepart(yy,CONTR.CTRACC_D) 
 ,FAMLIA.PMLRAT_R        
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
,NULL --  CONTR.MULTUWY_NF for TRT
 ,convert(char(8), CONTR.SCOEXP_D , 112) -- EXP2_D
 ,NULL -- FAMRSVP.MULTICAN_D for TRT
 FROM BFAC..TSECTION SECTION, BFAC..TCONTR CONTR, BFAC..TFAMLIA FAMLIA, BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  
    ,BCLI..TCLINTSU CLREPCR2  
    ,BCLI..TCLINTSU CLREPCR3  
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   
	,BFAC..TSECIFRS SECIFRS   		
  WHERE SECSTS_CT in ( 14, 17, 18, 19)   
    and CTRSTS_CT in ( 14, 17, 18, 19)   
    and CTRLCK_B != 0 
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

    and SECTION.CTR_NF*=SECIFRS.CTR_NF    
    and SECTION.END_NT*=SECIFRS.END_NT    
    and SECTION.SEC_NF*=SECIFRS.SEC_NF   
    and SECTION.UWY_NF*=SECIFRS.UWY_NF    
    and SECTION.UW_NT*=SECIFRS.UW_NT     
  
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
   
   	 and ( ( @norme_cf = 'EBS' ) 
     and CONTR.CTRINC_D > @v_clo_date 
     and ( SECIFRS.RECOD_D < @v_clo_date OR  SECIFRS.RECOD_D < @v_quarter_end  )
      )             


if @@error!=0 return @@error

return 0
go
if object_id('PsPeriBBNI_01') is not null
  print '<<< CREATED procedure PsPeriBBNI_01 >>>'
else
  print '<<< FAILED CREATING procedure PsPeriBBNI_01 >>>'
go
grant execute on PsPeriBBNI_01 TO GDBBATCH, GOMEGA
go
