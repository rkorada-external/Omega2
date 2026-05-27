use BEST
go
if object_id('PsPeriFAC_BBNI_01') is not null
begin
   drop procedure PsPeriFAC_BBNI_01
   if object_id('PsPeriFAC_BBNI_01') is not null
     print '<<< FAILED DROPPING procedure PsPeriFAC_BBNI_01 >>>'
   else
     print '<<< DROPPED procedure PsPeriFAC_BBNI_01 >>>' 
end

go
create procedure PsPeriFAC_BBNI_01
(
  @p_segtyp_ct      char(1), --type de segmentation ( 'A' ou 'E' )
  @p_clo_date       char(8),
  @p_x_days         int,
  @norme_cf         char(4),
  @p_quarter_end    varchar(10) --quarter end for dry run,
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
    SELECT @v_pos_booking_minus_days = dateadd(day,1,dateadd(day, @p_x_days * -1, @v_pos_booking_d) )
  END
  ELSE 
  BEGIN
    SELECT @v_pos_booking_minus_days = dateadd(day, 1, convert(datetime, @p_quarter_end, 103) ) -- 042 convert(datetime, @p_quarter_end, 103)
  END
END


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
 ,0 --,NULL        
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
  WHERE SECSTS_CT in ( 14, 16, 18, 19)   
    and CTRSTS_CT in ( 14, 16, 18, 19) 
    and CONTR.UWORG_CF NOT IN (247, 248)  
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
   
     and CONTR.CTRINC_D >= dateadd(day, 1, @v_clo_date )
   	 and ( ( @norme_cf = 'EBS' ) 
 
     and (  SECIFRS.RECOD_D < @v_pos_booking_minus_days  ) 
      )             


if @@error!=0 return @@error

return 0
go
if object_id('PsPeriFAC_BBNI_01') is not null
  print '<<< CREATED procedure PsPeriFAC_BBNI_01 >>>'
else
  print '<<< FAILED CREATING procedure PsPeriFAC_BBNI_01 >>>'
go
grant execute on PsPeriFAC_BBNI_01 TO GDBBATCH, GOMEGA
go
