USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_06_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_06_O2
    IF OBJECT_ID('PsEST_IFRS17_06_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_06_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_06_O2 >>>'
END
go
create procedure PsEST_IFRS17_06_O2 
AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Riyadh
Creation date     : 09/07/2018

Description       : 
_________________
Modification: MOD1 
Author: 
Date: 
Description: 
_________________
*/


INSERT INTO #TASSUMED
SELECT DISTINCT P.CTR_NF, P.UWY_NF, C.ESTCRB_CT, P.ESTCRB_CT 
FROM BTRAV..EST_IFRS17_PERIMETER P , BTRT..TCONTR C 
WHERE P.CTR_NF IS NOT NULL
AND P.CTR_NF  = C.CTR_NF
AND P.UWY_NF  = C.UWY_NF


INSERT INTO #TCONTR
Select 
C.CTR_NF              
,C.UWY_NF              
,UW_NT               
,END_NT              
,SSD_CF              
,CTRTYP_CT           
,CTRINC_D            
,SCOINC_D            
,ORGINC_D            
,CTREXP_D            
,ORGEXP_D            
,SCOEXP_D            
,CED_NF              
,CEDOFF_NF           
,CNC_B               
,DIRUW_B             
,PRD_NF              
,PRDOFF_NF           
,GENPRMPAY_NF        
,GANPAYORD_NT        
,CLMPAY_NF           
,CLMPAYORD_NT        
,GENPRMSEN_NF        
,ORGCED_NF           
,ORGBRK_NF           
,ORGLDI_NF           
,CTRPCPNAM_LL        
,ACCESB_CF           
,UWGRP_CF            
,UWRSPUSR_CF         
,ADMGRP_CF           
,ADMUSR_CF           
,ACCGRP_CF           
,CTRSTS_CT           
,CTRSTS_D            
,CTRLCK_B            
,EVA_CT              
,OFF_D               
,PRVSTS_CT           
,PRVSTS_D            
,RENTYP_CT           
,REN_B               
,RENWAIPER_N         
,RENMONDAY_B         
,CANCTR_D            
,CAN_DT              
,CANREA_CF           
,CANSCO_B            
,CANCED_B            
,PNOEXTPER_N         
,PNOEXTMON_B         
,PNOEXTREA_CF        
,PNOEXTSCO_B         
,PNOEXTCED_B         
,PNOPLC_D            
,PNOSCO_B            
,PNOCED_B            
,COVCNT_B            
,COVCNTEXP_D         
,CTRRCP_DT           
,BINDUR_N            
,VRSCRE_D            
,VRSINC_D            
,ENDINC_D            
,ENDEXP_D            
,LSTEND_B            
,FRSUWY_NF           
,FRSINC_D            
,LSTUWY_B            
,LSTUWYRSK_B         
,FACADMTYP_B         
,COMTEC_B            
,CTRACCSTS_CT        
,CTRACC_D            
,PRG_NF              
,BOQ_NF              
,MAS_NF              
,CTRGRP_NF           
,LNKDIVSEC_N         
,PCPLOB_CF           
,PCPSOB_CF           
,PCPTOP_CF           
,PCPOCC_CF           
,PCPGAR_CF           
,PCPNAT_CF           
,PCPDIV_NF           
,PCPIND_NF           
,PRDROJCTR_NF        
,CTRQUA_CF           
,CTRQUA2_CF          
,CTRQUA3_CF          
,CTRQUA4_CF          
,CTRQUA5_CF          
,NAH_B               
,TECADV_B            
,FRT_B               
,CAT_B               
,TOBREN_B            
,REFTOBREE_B         
,LONDURCTR_B         
,CPTNAM_B            
,CMPREF_B            
,LDISCO_B            
,PRCRSK_NF           
,REITYP_CF           
,PCPEXTREF_LL        
,UWORG_CF            
,ENDISS_N            
,RSKCOMPRM_B         
,LIFTRTTYP_CF        
,ROJCTR_B            
,OBGPRT_B            
,SAMCTREXI_B         
,BNF_LM              
,CTLOFF_LM           
,INTCASBAL_B         
,FIXINTCAS_B         
,INTCASBAL_R         
,INTTECBAL_R         
,CTROLDNBR_LM        
,UMRACCADM_CT        
,UMRCTR_LM           
,MNGUWSRC_NF         
,CTRSLPREC_D         
,CTRSLPSND_D         
,WRDREC_D            
,WRDSND_D            
,PNOPER_CT           
,TRTVERNBR_NT        
,COTDEP_D            
,COTRET_D            
,INTRET_B            
,MANRET_B            
,ALLTRT_B            
,GETDATE()
,USER           
,GETDATE()
,USER        
,LSTUPD_LS           
,NULL         
,A.NEW_ESTCRB_CT           
,RETCTR_NF           
,CTRORG_NF           
,MULTUWY_NF          
,FACACTSCT_CT        
,CTRACCSTS2_CT       
,PNOPLCSCO_D         
,CNATYP_CT           
,ENDMULTUWY_NF       
,UWRSPUSR2_CF        
,ESTCRB_D            
,ADMDOC_CT           
,NAHNUWY_NF          
,PROVEQU_B           
,FDSADMUSR_CF        
,FDSCTRVALG_D        
,FDSUWRSPUSR_CF      
,FDSCTRVALS_D        
,FDSMODIFTYP_CT      
,CTRQUA6_CF          
,CTRQUA7_CF          
,CTRQUA8_CF          
,CTRQUA9_CF          
,CTRQUA10_CF         
,CTRNEW_CT           
,INTCASBALVAR_R      
,INTTECBALVAR_R      
,INTTECBALVAR_B      
,INTCASBALVARBASE_CT 
,INTTECBALVARBASE_CT 
,CTRATT_NF           
,ACCUSR_CF           
,COMMSTS_CT          
,CTRVISSTS_CT        
,FINTYP_CF           
,AUTORENEW_CF        
,MAITPA_NF           
,WRDSIGN_D           
FROM BTRT..TCONTR C, #TASSUMED A
Where C.CTR_NF = A.CTR_NF
  AND C.UWY_NF = A.UWY_NF


go 
EXEC sp_procxmode 'PsEST_IFRS17_06_O2', 'unchained'
go

IF OBJECT_ID('PsEST_IFRS17_06_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_06_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_06_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_06_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_06_O2 TO GDBBATCH
go


