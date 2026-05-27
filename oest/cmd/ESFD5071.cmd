#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS BBNI  
# Nom du script SHELL           : ESFD.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 1/0/20
# Auteur                        : MZM
# References des specifications :
#----------------------------------------------------------------------------------------------------
# http://aenprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-920946
# 
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#[001] 					22/09/2022  		MZM	
#[002] 15/07/2025 MZM : US 6065 BBNI - Missing 1A46060G transaction	Spira 113133
#[003] 18/07/2025 MZM : US 6065 BBNI - Missing 1A46060G transaction	Spira 113133			
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES " 


##ESF_DLDGTAASII/scordata_aenitko2batch/ubeu/perm/T_ESFD2230_BBNI_DLDGTAA_EBS_INV_20250630.dat
##EPO_DLDGTAASII/scordata_aenitko2batch/ubeu/perm/T_ESFD2230_DLDGTAA_EBS_INV_20250630.dat

if [ ! -f ${ESF_DLSGTR_BBNI} ]
then
        ECHO_LOG "ESF_DLSGTR_BBNI=${ESF_DLSGTR_BBNI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLSGTR_BBNI}"
fi

if [ ! -f ${ESF_DLREGTR_BBNI} ]
then
        ECHO_LOG "ESF_DLREGTR_BBNI=${ESF_DLREGTR_BBNI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLREGTR_BBNI}"
fi

if [ ! -f ${ESF_DLRGTAA_BBNI} ]
then
        ECHO_LOG "ESF_DLRGTAA_BBNI=${ESF_DLRGTAA_BBNI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAA_BBNI}"
fi


if [ ! -f ${ESF_DLDGTAR_E_BBNI} ]
then
        ECHO_LOG "ESF_DLDGTAR_E_BBNI=${ESF_DLDGTAR_E_BBNI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLDGTAR_E_BBNI}"
fi

if [ ! -f ${ESF_DLDGTR_E_BBNI} ]
then
        ECHO_LOG "ESF_DLDGTR_E_BBNI=${ESF_DLDGTR_E_BBNI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLDGTR_E_BBNI}"
fi

if [ ! -f ${ESF_DLREGTAR_BBNI} ]
then
        ECHO_LOG "ESF_DLREGTAR_BBNI=${ESF_DLREGTAR_BBNI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLREGTAR_BBNI}"
fi

if [ ! -f ${ESF_DLDGTAASII_BBNI} ]
then
        ECHO_LOG "ESF_DLREMAJGTAR_BBNI=${ESF_DLREMAJGTAR_BBNI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLREMAJGTAR_BBNI}"
fi

if [ ! -f ${ESF_DLSGTAASII_BBNI} ]
then
        ECHO_LOG "ESF_DLREMAJGTR_BBNI=${ESF_DLREMAJGTR_BBNI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLREMAJGTR_BBNI}"
fi

#################################################
# EBS futures to EBS BBNI Futures               #
#################################################

NORME_SUFFIX='G'



ECHO_LOG "NORME_SUFFIX = ${NORME_SUFFIX}"  >> $FLOG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> IDF_CT...................: ${IDF_CT}"
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"

ECHO_LOG "#==========================INPUT========================================" 

ECHO_LOG "#===> EST_GTSII_ICR      ......................................:${EST_GTSII_ICR}"                
ECHO_LOG "#===> EST_DLCUMGTAAR     ......................................:${EST_DLCUMGTAAR}"               
ECHO_LOG "#===> EST_DLSIIGTAA'               ........................... :${EST_DLSIIGTAA}"                
ECHO_LOG "#===> EST_DLSIIGTAR'               ........................... :${EST_DLSIIGTAR}"                
ECHO_LOG "#===> EST_GTSII_CASHFLOW'          ........................... :${EST_GTSII_CASHFLOW}"           
ECHO_LOG "#===> EST_GTSII_CLACC_CASHFLOW     ........................... :${EST_GTSII_CLACC_CASHFLOW}"     
ECHO_LOG "#===> EST_GTSII_GLOBAL_CASHFLOW    ........................... :${EST_GTSII_GLOBAL_CASHFLOW}"    
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAE   ........................... :${EST_GTSII_REMAINTOPAY_ULAE}"   
ECHO_LOG "#===> EST_DLCUMGTAAR_IBNR_FUTCLAIMS........................... :${EST_DLCUMGTAAR_IBNR_FUTCLAIMS}"
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAEINF........................... :${EST_GTSII_REMAINTOPAY_ULAEINF} "
ECHO_LOG "#===> EST_GTSII_DLEIFTECLEDSIIEP...............................:${EST_GTSII_DLEIFTECLEDSIIEP}" 
ECHO_LOG "#===> EST_GTEP.................................................:${EST_GTEP}"


ECHO_LOG "#===> EST_GTSII_ICR_BBNI .....................................:${EST_GTSII_ICR_BBNI} "                
ECHO_LOG "#===> EST_DLCUMGTAAR_BBNI ....................................:${EST_DLCUMGTAAR_BBNI}"                
ECHO_LOG "#===> EST_DLSIIGTAA_BBNI......................................:${EST_DLSIIGTAA_BBNI}"                 
ECHO_LOG "#===> EST_DLSIIGTAR_BBNI......................................:${EST_DLSIIGTAR_BBNI} "                
ECHO_LOG "#===> EST_GTSII_CASHFLOW_BBNI          .......................:${EST_GTSII_CASHFLOW_BBNI}"            
ECHO_LOG "#===> EST_GTSII_CLACC_CASHFLOW_BBNI     ......................:${EST_GTSII_CLACC_CASHFLOW_BBNI} "     
ECHO_LOG "#===> EST_GTSII_GLOBAL_CASHFLOW_BBNI    ......................:${EST_GTSII_GLOBAL_CASHFLOW_BBNI} "    
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAE_BBNI   ......................:${EST_GTSII_REMAINTOPAY_ULAE_BBNI}"    
ECHO_LOG "#===> EST_DLCUMGTAAR_IBNR_FUTCLAIMS_BBNI......................:${EST_DLCUMGTAAR_IBNR_FUTCLAIMS_BBNI}" 
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAEINF_BBNI......................:${EST_GTSII_REMAINTOPAY_ULAEINF_BBNI}" 
ECHO_LOG "#===> EST_GTSII_DLEIFTECLEDSIIEP_BBNI.........................:${EST_GTSII_DLEIFTECLEDSIIEP_BBNI}"
ECHO_LOG "#===> EST_GTEP_BBNI.................................................:${EST_GTEP_BBNI}"



ECHO_LOG "#===> ESF_DLSGTR_BBNI      ....................................:${ESF_DLSGTR_BBNI}"        
ECHO_LOG "#===> ESF_DLREGTR_BBNI     ....................................:${ESF_DLREGTR_BBNI}"       
ECHO_LOG "#===> ESF_DLRGTAA_BBNI     ....................................:${ESF_DLRGTAA_BBNI}" 
ECHO_LOG "#===> ESF_DLEIGTAA_BBNI		....................................:${ESF_DLEIGTAA_BBNI}"      
                                                                                                     
ECHO_LOG "#===> ESF_DLDGTAR_E_BBNI   ....................................:${ESF_DLDGTAR_E_BBNI}"     
ECHO_LOG "#===> ESF_DLDGTR_E_BBNI    ....................................:${ESF_DLDGTR_E_BBNI}"      
ECHO_LOG "#===> ESF_DLREGTAR_BBNI    ....................................:${ESF_DLREGTAR_BBNI}"      
ECHO_LOG "#===> ESF_DLSGTAASO_BBNI   ....................................:${ESF_DLSGTAASO_BBNI}"     
ECHO_LOG "#===> ESF_DLSGTARCO_BBNI   ....................................:${ESF_DLSGTARCO_BBNI}"     
ECHO_LOG "#===> ESF_DLSGTARSO_BBNI   ....................................:${ESF_DLSGTARSO_BBNI}"     
ECHO_LOG "#===> ESF_DLDGTAASII_BBNI  ....................................:${ESF_DLDGTAASII_BBNI}"    
ECHO_LOG "#===> ESF_DLSGTAASII_BBNI  ....................................:${ESF_DLSGTAASII_BBNI}"    
                                                                                                     
ECHO_LOG "#===> ESF_DLASIIGTR_BBNI   ....................................:${ESF_DLASIIGTR_BBNI}"     
ECHO_LOG "#===> ESF_DLDSIIGTR_BBNI   ....................................:${ESF_DLDSIIGTR_BBNI}"     
ECHO_LOG "#===> ESF_DLSGTARSIICO_BBNI....................................:${ESF_DLSGTARSIICO_BBNI}"  
ECHO_LOG "#===> ESF_DLSGTARSIISO_BBNI....................................:${ESF_DLSGTARSIISO_BBNI}"  
ECHO_LOG "#===> ESF_DLASIIGTAA_BBNI  ....................................:${ESF_DLASIIGTAA_BBNI}"    
ECHO_LOG "#===> ESF_DLASIIGTAR_BBNI  ....................................:${ESF_DLASIIGTAR_BBNI}"    
ECHO_LOG "#===> ESF_DLDSIIGTAA_BBNI  ....................................:${ESF_DLDSIIGTAA_BBNI}"    
ECHO_LOG "#===> ESF_DLREMAJGTR_BBNI  ....................................:${ESF_DLREMAJGTR_BBNI}"    
ECHO_LOG "#===> ESF_DLREMAJGTAR_BBNI ....................................:${ESF_DLREMAJGTAR_BBNI}"   
 

ECHO_LOG "#===> EPO_DLSGTR         ....................................:${EPO_DLSGTR}"         
ECHO_LOG "#===> EPO_DLREGTR         ....................................:${EPO_DLREGTR}"        
ECHO_LOG "#===> EPO_DLRGTAA        ....................................:${EPO_DLRGTAA}"       
                     
ECHO_LOG "#===> EPO_DLDGTAR_E      ....................................:${EPO_DLDGTAR_E}"     
ECHO_LOG "#===> EPO_DLDGTR_E       ....................................:${EPO_DLDGTR_E}"      
ECHO_LOG "#===> EPO_DLREGTAR       ....................................:${EPO_DLREGTAR}"      
ECHO_LOG "#===> EPO_DLSGTAASO      ....................................:${EPO_DLSGTAASO}"     
ECHO_LOG "#===> EPO_DLSGTARCO      ....................................:${EPO_DLSGTARCO}"     
ECHO_LOG "#===> EPO_DLSGTARSO      ....................................:${EPO_DLSGTARSO}"     
ECHO_LOG "#===> EPO_DLDGTAASII     ....................................:${EPO_DLDGTAASII}"    
ECHO_LOG "#===> EPO_DLSGTAASII     ....................................:${EPO_DLSGTAASII}"    
                      
ECHO_LOG "#===> EPO_DLASIIGTR      ....................................:${EPO_DLASIIGTR}"     
ECHO_LOG "#===> EPO_DLDSIIGTR      ....................................:${EPO_DLDSIIGTR}"     
ECHO_LOG "#===> EPO_DLSGTARSIICO   ....................................:${EPO_DLSGTARSIICO}"  
ECHO_LOG "#===> EPO_DLSGTARSIISO   ....................................:${EPO_DLSGTARSIISO}"  
ECHO_LOG "#===> EPO_DLASIIGTAA     ....................................:${EPO_DLASIIGTAA}"    
ECHO_LOG "#===> EPO_DLASIIGTAR     ....................................:${EPO_DLASIIGTAR}"    
ECHO_LOG "#===> EPO_DLDSIIGTAA     ....................................:${EPO_DLDSIIGTAA}"    
ECHO_LOG "#===> EPO_DLREMAJGTR     ....................................:${EPO_DLREMAJGTR}"    
ECHO_LOG "#===> EPO_DLREMAJGTAR    ....................................:${EPO_DLREMAJGTAR}"   
                                                                                                                                                       
ECHO_LOG "#==========================OUTPUT========================================"                                                                            

ECHO_LOG "#===> ESF_GTSII_ICR'               ........................... :${ESF_GTSII_ICR}"                
ECHO_LOG "#===> ESF_DLCUMGTAAR               ........................... :${ESF_DLCUMGTAAR}"               
ECHO_LOG "#===> ESF_DLSIIGTAA'               ........................... :${ESF_DLSIIGTAA}"                
ECHO_LOG "#===> ESF_DLSIIGTAR'               ........................... :${ESF_DLSIIGTAR}"                
ECHO_LOG "#===> ESF_GTSII_CASHFLOW'          ........................... :${ESF_GTSII_CASHFLOW}"           
ECHO_LOG "#===> ESF_GTSII_CLACC_CASHFLOW     ........................... :${ESF_GTSII_CLACC_CASHFLOW}"     
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW    ........................... :${ESF_GTSII_GLOBAL_CASHFLOW}"    
ECHO_LOG "#===> ESF_GTSII_REMAINTOPAY_ULAE   ........................... :${ESF_GTSII_REMAINTOPAY_ULAE}"   
ECHO_LOG "#===> ESF_DLCUMGTAAR_IBNR_FUTCLAIMS........................... :${ESF_DLCUMGTAAR_IBNR_FUTCLAIMS}"
ECHO_LOG "#===> ESF_GTSII_REMAINTOPAY_ULAEINF........................... :${ESF_GTSII_REMAINTOPAY_ULAEINF}"
ECHO_LOG "#===> ESF_GTSII_DLEIFTECLEDSIIEP...............................:${EST_GTSII_DLEIFTECLEDSIIEP}"
ECHO_LOG "#===> ESF_GTEP.................................................:${ESF_GTEP}"

                                                                              
ECHO_LOG "#===> ESF_DLSGTR      ....................................:${ESF_DLSGTR}"        
ECHO_LOG "#===> ESF_DLREGTR			....................................:${ESF_DLREGTR}"      	
ECHO_LOG "#===> ESF_DLRGTAA			....................................:${ESF_DLRGTAA}"  
ECHO_LOG "#===> ESF_DLEIGTAA		....................................:${ESF_DLEIGTAA}"    	
                                                                            
ECHO_LOG "#===> ESF_DLDGTAR_E		....................................:${ESF_DLDGTAR_E}"    	
ECHO_LOG "#===> ESF_DLDGTR_E			....................................:${ESF_DLDGTR_E}"     
ECHO_LOG "#===> ESF_DLREGTAR			....................................:${ESF_DLREGTAR}"     
ECHO_LOG "#===> ESF_DLSGTAASO		....................................:${ESF_DLSGTAASO}"    	
ECHO_LOG "#===> ESF_DLSGTARCO		....................................:${ESF_DLSGTARCO}"    	
ECHO_LOG "#===> ESF_DLSGTARSO		....................................:${ESF_DLSGTARSO}"    	
ECHO_LOG "#===> ESF_DLDGTAASII		....................................:${ESF_DLDGTAASII}"   
ECHO_LOG "#===> ESF_DLSGTAASII		....................................:${ESF_DLSGTAASII}"   
                                                                            
ECHO_LOG "#===> ESF_DLASIIGTR		....................................:${ESF_DLASIIGTR}"    	
ECHO_LOG "#===> ESF_DLDSIIGTR		....................................:${ESF_DLDSIIGTR}"    	
ECHO_LOG "#===> ESF_DLSGTARSIICO....................................:${ESF_DLSGTARSIICO}" 
ECHO_LOG "#===> ESF_DLSGTARSIISO....................................:${ESF_DLSGTARSIISO}" 
ECHO_LOG "#===> ESF_DLASIIGTAA		....................................:${ESF_DLASIIGTAA}"   
ECHO_LOG "#===> ESF_DLASIIGTAR		....................................:${ESF_DLASIIGTAR}"   
ECHO_LOG "#===> ESF_DLDSIIGTAA		....................................:${ESF_DLDSIIGTAA}"   
ECHO_LOG "#===> ESF_DLREMAJGTR		....................................:${ESF_DLREMAJGTR}"   
ECHO_LOG "#===> ESF_DLREMAJGTAR	....................................:${ESF_DLREMAJGTAR}"  
   
##${ESF_DLRGTAA_BBNI}    
##${ESF_DLASIIGTAA_BBNI} 
##${ESF_DLDSIIGTAA_BBNI} 
##${ESF_DLDGTAASII_BBNI} 
##${ESF_DLSGTAASII_BBNI} 
##${ESF_DLSGTAASO_BBNI}                    
##  
##${ESF_DLDGTR_E_BBNI}   
##${ESF_DLREGTAR_BBNI} 
##
##  
##                                                                           
##${ESF_DLSGTARCO_BBNI}  
##${ESF_DLSGTARSO_BBNI} 
##                   
##${ESF_DLASIIGTR_BBNI}  
##${ESF_DLDSIIGTR_BBNI}  
##${ESF_DLSGTARSIICO_BBNI}
##${ESF_DLSGTARSIISO_BBNI}
##
##${ESF_DLASIIGTAR_BBNI} 
##
##${ESF_DLREMAJGTR_BBNI} 
##${ESF_DLREMAJGTAR_BBNI}

##T_ESFD5070_ESFD5071_O3_AEnItkO2Batch_20250416175858_21902_AWK_ESF_DLREGTAR_BBNI.dat
##T_ESFD5070_ESFD5071_03_AEnItkO2Batch_20250416175858_21902_AWK_ESF_DLREGTAR_BBNI.dat



NSTEP=${NJOB}_03
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLREGTAR_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLREGTAR_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G";print \$0;}  
if (\$6 == "2A100022") { \$6 = "2A10062G";print \$0;}  
if (\$6 == "2A120062") { \$6 = "2A14061G";print \$0;}  
if (\$6 == "2A120012") { \$6 = "2A12001G";print \$0;}  
if (\$6 == "2A120052") { \$6 = "2A12007G";print \$0;}  
if (\$6 == "2A120072") { \$6 = "2A12007G";print \$0;}  
if (\$6 == "2A494302") { \$6 = "2A49461G";print \$0;}  
if (\$6 == "2A200712") { \$6 = "2A49462G";print \$0;}   
if (\$6 == "2A416012") { \$6 = "2A41101G";print \$0;}  
if (\$6 == "2A121212") { \$6 = "2A12161G";print \$0;}  



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Merge BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03_${IB}_AWK_ESF_DLREGTAR_BBNI.dat  2000 1"
SORT_I2="${EPO_DLREGTAR}  2000 1"
SORT_O="${ESF_DLREGTAR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT



NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLDGTR_E_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLDGTR_E_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}  
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}  
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}  
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}  
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;} 
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}   
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}  
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}    
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}  
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}  



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="Merge BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_AWK_ESF_DLDGTR_E_BBNI.dat  2000 1"
SORT_I2="${EPO_DLDGTR_E}  2000 1"
SORT_O="${ESF_DLDGTR_E} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT




## ${ESF_DLSGTR_BBNI}

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLSGTR_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLSGTR_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}  
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}  
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}  
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}  
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;} 
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}   
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}  
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}    
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}  
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}  



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Merge BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_AWK_ESF_DLSGTR_BBNI.dat  2000 1"
SORT_I2="${EPO_DLSGTR}  2000 1"
SORT_O="${ESF_DLSGTR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT


## ${ESF_DLREGTR_BBNI} 

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLREGTR_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLREGTR_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}  
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK

NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Merge BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_AWK_ESF_DLREGTR_BBNI.dat  2000 1"
SORT_I2="${EPO_DLREGTR}  2000 1"
SORT_O="${ESF_DLREGTR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT

## ${ESF_DLREGTAR_BBNI} 

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLDGTAR_E_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLDGTAR_E_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G";print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G";print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G";print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G";print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G";print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G";print \$0;}  
if (\$6 == "2A494302") { \$6 = "2A49461G";print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G";print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G";print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G";print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Merge BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_AWK_ESF_DLDGTAR_E_BBNI.dat 2000 1"
SORT_I2="${EPO_DLDGTAR_E}  2000 1"
SORT_O="${ESF_DLDGTAR_E} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT


if [  ${TYPEINV} = "POC" ]
then

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLSGTARCO_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLSGTARCO_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}  
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="Merge BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_AWK_ESF_DLSGTARCO_BBNI.dat 2000 1"
SORT_I2="${EPO_DLSGTARCO}  2000 1"
SORT_O="${ESF_DLSGTARCO} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT


else

##${ESF_DLSGTARSO_BBNI}

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLSGTARSO_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLSGTARSO_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}  
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL="Merge BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_AWK_ESF_DLSGTARSO_BBNI.dat 2000 1"
SORT_I2="${EPO_DLSGTARSO}  2000 1"
SORT_O="${ESF_DLSGTARSO} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT

fi 

##${ESF_DLASIIGTR_BBNI} 

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLASIIGTR_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLASIIGTR_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLASIIGTR_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}  
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_75
#-----------------------------------------------------------------------------
LIBEL="Merge BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_AWK_ESF_DLASIIGTR_BBNI.dat 2000 1"
SORT_I2="${EPO_DLASIIGTR}  2000 1"
SORT_O="${ESF_DLASIIGTR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT


##${ESF_DLDSIIGTR_BBNI} 

###NSTEP=${NJOB}_80
####-----------------------------------------------------------------------------
###LIBEL="Transforme ESF_DLDSIIGTR_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
###AWK_I="${ESF_DLDSIIGTR_BBNI} "
###AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLDSIIGTR_BBNI.dat"
###AWK_CMD=`CFTMP`
###INPUT_TEXT ${AWK_CMD} <<EOF
###BEGIN{ FS="\~"; OFS="\~" }
###  {
###
###if (\$6 == "2A100012") { \$6 = "2A10001G";print \$0;}
###if (\$6 == "2A100022") { \$6 = "2A10062G";print \$0;}
###if (\$6 == "2A120062") { \$6 = "2A14061G";print \$0;}
###if (\$6 == "2A120012") { \$6 = "2A12001G";print \$0;}
###if (\$6 == "2A120052") { \$6 = "2A12007G";print \$0;}
###if (\$6 == "2A120072") { \$6 = "2A12007G";print \$0;}
###if (\$6 == "2A494302") { \$6 = "2A49461G";print \$0;}
###if (\$6 == "2A200712") { \$6 = "2A49462G";print \$0;}
###if (\$6 == "2A416012") { \$6 = "2A41101G";print \$0;}
###if (\$6 == "2A121212") { \$6 = "2A12161G";print \$0;}
###
###
###
###fi
###  }
###exit
###EOF
###AWK
###
###
###NSTEP=${NJOB}_85
####-----------------------------------------------------------------------------
###LIBEL="Merge DLDSIIGTR BBNI TRANSCODIFIES et des EBS CLASSIQUE"
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_80_${IB}_AWK_ESF_DLDSIIGTR_BBNI.dat 2000 1"
###SORT_I2="${EPO_DLDSIIGTR}  2000 1"
###SORT_O="${ESF_DLDSIIGTR} 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS TRNCOD_CF        6:1 -  6:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        RETOCCYEA_NF    29:1 - 29:,
###        RETACY_NF       30:1 - 30:,
###        RETSCOSTRMTH_NF 31:1 - 31:,
###        RETSCOENDMTH_NF 32:1 - 32:,
###        RCL_NF          33:1 - 33:,
###        RETCUR_CF       34:1 - 34:,
###        PLC_NT          36:1 - 36:
###/KEYS RETCTR_NF,
###      RETEND_NT,
###      RETSEC_NF,
###      RTY_NF,
###      RETUW_NT,
###      RETACY_NF,
###      RETSCOENDMTH_NF,
###      RETSCOSTRMTH_NF,
###      RETOCCYEA_NF,
###      RCL_NF,
###      RETCUR_CF,
###      PLC_NT,
###      TRNCOD_CF
###exit
###EOF
###SORT


##${ESF_DLSGTARSIICO_BBNI} 

if [  ${TYPEINV} = "POC"]
then

NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLSGTARSIICO_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLSGTARSIICO_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLSGTARSIICO_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLSGTARSIICO BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_AWK_ESF_DLSGTARSIICO_BBNI.dat 2000 1"
SORT_I2="${EPO_DLSGTARSIICO}  2000 1"
SORT_O="${ESF_DLSGTARSIICO} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT

else


##${ESF_DLSGTARSIISO_BBNI} 

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLSGTARSIISO_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLSGTARSIISO_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLSGTARSIISO_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLSGTARSIISO BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_AWK_ESF_DLSGTARSIISO_BBNI.dat 2000 1"
SORT_I2="${EPO_DLSGTARSIISO}  2000 1"
SORT_O="${ESF_DLSGTARSIISO} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT

fi

##${ESF_DLASIIGTAR_BBNI} 

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLASIIGTAR_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLASIIGTAR_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLASIIGTAR_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_115
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLASIIGTAR BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_AWK_ESF_DLASIIGTAR_BBNI.dat 2000 1"
SORT_I2="${EPO_DLASIIGTAR}  2000 1"
SORT_O="${ESF_DLASIIGTAR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT




##${ESF_DLREMAJGTR_BBNI} 

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLREMAJGTR_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLREMAJGTR_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLREMAJGTR_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLREMAJGTR BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_AWK_ESF_DLREMAJGTR_BBNI.dat 2000 1"
SORT_I2="${EPO_DLREMAJGTR}  2000 1"
SORT_O="${ESF_DLREMAJGTR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT


##${ESF_DLREMAJGTAR_BBNI} 

NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLREMAJGTAR_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLREMAJGTAR_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLREMAJGTAR_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2A10001G"; print \$0;}
if (\$6 == "2A100022") { \$6 = "2A10062G"; print \$0;}
if (\$6 == "2A120062") { \$6 = "2A14061G"; print \$0;}
if (\$6 == "2A120012") { \$6 = "2A12001G"; print \$0;}
if (\$6 == "2A120052") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A120072") { \$6 = "2A12007G"; print \$0;}
if (\$6 == "2A494302") { \$6 = "2A49461G"; print \$0;}
if (\$6 == "2A200712") { \$6 = "2A49462G"; print \$0;}
if (\$6 == "2A416012") { \$6 = "2A41101G"; print \$0;}
if (\$6 == "2A121212") { \$6 = "2A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_135
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLREMAJGTAR BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_AWK_ESF_DLREMAJGTAR_BBNI.dat 2000 1"
SORT_I2="${EPO_DLREMAJGTAR}  2000 1"
SORT_O="${ESF_DLREMAJGTAR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT 

##ESF_DLRGTAA_BBNI

NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLRGTAA_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLRGTAA_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLRGTAA_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1A10001G"; print \$0;}
if (\$6 == "1A100022") { \$6 = "1A10062G"; print \$0;}
if (\$6 == "1A120062") { \$6 = "1A14061G"; print \$0;}
if (\$6 == "1A120012") { \$6 = "1A12001G"; print \$0;}
if (\$6 == "1A120052") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A120072") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A494302") { \$6 = "1A49461G"; print \$0;}
if (\$6 == "1A200712") { \$6 = "1A49462G"; print \$0;}
if (\$6 == "1A461112") { \$6 = "1A46060G"; print \$0;}
if (\$6 == "1A416012") { \$6 = "1A41101G"; print \$0;}
if (\$6 == "1A121212") { \$6 = "1A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_145
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLRGTAA BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_AWK_ESF_DLRGTAA_BBNI.dat 2000 1"
SORT_I2="${EPO_DLRGTAA}  2000 1"
SORT_O="${ESF_DLRGTAA} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT


##ESF_DLASIIGTAA_BBNI

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLASIIGTAA_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLASIIGTAA_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLASIIGTAA_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1A10001G"; print \$0;}
if (\$6 == "1A100022") { \$6 = "1A10062G"; print \$0;}
if (\$6 == "1A120062") { \$6 = "1A14061G"; print \$0;}
if (\$6 == "1A120012") { \$6 = "1A12001G"; print \$0;}
if (\$6 == "1A120052") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A120072") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A494302") { \$6 = "1A49461G"; print \$0;}
if (\$6 == "1A200712") { \$6 = "1A49462G"; print \$0;}
if (\$6 == "1A461112") { \$6 = "1A46060G"; print \$0;}
if (\$6 == "1A416012") { \$6 = "1A41101G"; print \$0;}
if (\$6 == "1A121212") { \$6 = "1A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_155
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLASIIGTAA_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_AWK_ESF_DLASIIGTAA_BBNI.dat 2000 1"
SORT_I2="${EPO_DLASIIGTAA}  2000 1"
SORT_O="${ESF_DLASIIGTAA} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT


NSTEP=${NJOB}_157
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLEIGTAA_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLEIGTAA_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLEIGTAA_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1A10001G"; print \$0;}
if (\$6 == "1A100022") { \$6 = "1A10062G"; print \$0;}
if (\$6 == "1A120062") { \$6 = "1A14061G"; print \$0;}
if (\$6 == "1A120012") { \$6 = "1A12001G"; print \$0;}
if (\$6 == "1A120052") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A120072") { \$6 = "1A12007G"; print \$0;} 
if (\$6 == "1A494302") { \$6 = "1A49461G"; print \$0;}
if (\$6 == "1A200712") { \$6 = "1A49462G"; print \$0;}
if (\$6 == "1A461112") { \$6 = "1A46060G"; print \$0;}
if (\$6 == "1A416012") { \$6 = "1A41101G"; print \$0;}
if (\$6 == "1A121212") { \$6 = "1A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_158
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLEIGTAA BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_157_${IB}_AWK_ESF_DLEIGTAA_BBNI.dat 2000 1"
SORT_I2="${EPO_DLEIGTAA}  2000 1"
SORT_O="${ESF_DLEIGTAA} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT


####ESF_DLDSIIGTAA_BBNI
##
##NSTEP=${NJOB}_160
###-----------------------------------------------------------------------------
##LIBEL="Transforme ESF_DLDSIIGTAA_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
##AWK_I="${ESF_DLDSIIGTAA_BBNI} "
##AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLDSIIGTAA_BBNI.dat"
##AWK_CMD=`CFTMP`
##INPUT_TEXT ${AWK_CMD} <<EOF
##BEGIN{ FS="\~"; OFS="\~" }
##  {
##
##if (\$6 == "1A100012") { \$6 = "1A10001G"; print \$0;}
##if (\$6 == "1A100022") { \$6 = "1A10062G"; print \$0;}
##if (\$6 == "1A120062") { \$6 = "1A14061G"; print \$0;}
##if (\$6 == "1A120012") { \$6 = "1A12001G"; print \$0;}
##if (\$6 == "1A120052") { \$6 = "1A12007G"; print \$0;}
##if (\$6 == "1A120072") { \$6 = "1A12007G"; print \$0;} 
##if (\$6 == "1A494302") { \$6 = "1A49461G"; print \$0;}
##if (\$6 == "1A200712") { \$6 = "1A49462G"; print \$0;}

##if (\$6 == "1A461112") { \$6 = "1A46060G"; print \$0;}
##
##if (\$6 == "1A416012") { \$6 = "1A41101G"; print \$0;}
##if (\$6 == "1A121212") { \$6 = "1A12161G"; print \$0;}
##
##
##
##fi
##  }
##exit
##EOF
##AWK
##
##
##NSTEP=${NJOB}_165
###-----------------------------------------------------------------------------
##LIBEL="Merge ESF_DLDSIIGTAA_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_160_${IB}_AWK_ESF_DLDSIIGTAA_BBNI.dat 2000 1"
##SORT_I2="${EPO_DLDSIIGTAA}  2000 1"
##SORT_O="${ESF_DLDSIIGTAA} 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS TRNCOD_CF        6:1 -  6:,
##        CTR_NF           8:1 -  8:,
##        END_NT           9:1 -  9:,
##        SEC_NF          10:1 - 10:,
##        UWY_NF          11:1 - 11:,
##        UW_NT           12:1 - 12:,
##        ACY_NF          14:1 - 14:,
##        SCOSTRMTH_NF    15:1 - 15:,
##        SCOENDMTH_NF    16:1 - 16:,
##        CUR_CF          18:1 - 18:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##      TRNCOD_CF,
##      ACY_NF,
##      SCOSTRMTH_NF,
##      SCOENDMTH_NF,
##      CUR_CF
##exit
##EOF
##SORT


##${ESF_DLDGTAASII_BBNI} 

NSTEP=${NJOB}_170
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLDGTAASII_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLDGTAASII_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLDGTAASII_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1A10001G"; print \$0;}
if (\$6 == "1A100022") { \$6 = "1A10062G"; print \$0;}
if (\$6 == "1A120062") { \$6 = "1A14061G"; print \$0;}
if (\$6 == "1A120012") { \$6 = "1A12001G"; print \$0;}
if (\$6 == "1A120052") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A120072") { \$6 = "1A12007G"; print \$0;} 
if (\$6 == "1A494302") { \$6 = "1A49461G"; print \$0;}
if (\$6 == "1A200712") { \$6 = "1A49462G"; print \$0;}
if (\$6 == "1A461112") { \$6 = "1A46060G"; print \$0;}
if (\$6 == "1A416012") { \$6 = "1A41101G"; print \$0;}
if (\$6 == "1A121212") { \$6 = "1A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_175
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLDGTAASII_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_170_${IB}_AWK_ESF_DLDGTAASII_BBNI.dat 2000 1"
SORT_I2="${EPO_DLDGTAASII}  2000 1"
SORT_O="${ESF_DLDGTAASII} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT

if [  ${TYPEINV} != "POS" ]
then

##${ESF_DLSGTAASII_BBNI} 

NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLSGTAASII_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLSGTAASII_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLSGTAASII_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1A10001G"; print \$0;}
if (\$6 == "1A100022") { \$6 = "1A10062G"; print \$0;}
if (\$6 == "1A120062") { \$6 = "1A14061G"; print \$0;}
if (\$6 == "1A120012") { \$6 = "1A12001G"; print \$0;}
if (\$6 == "1A120052") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A120072") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A494302") { \$6 = "1A49461G"; print \$0;}
if (\$6 == "1A200712") { \$6 = "1A49462G"; print \$0;}
if (\$6 == "1A461112") { \$6 = "1A46060G"; print \$0;}
if (\$6 == "1A416012") { \$6 = "1A41101G"; print \$0;}
if (\$6 == "1A121212") { \$6 = "1A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_185
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLSGTAASII_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_AWK_ESF_DLSGTAASII_BBNI.dat 2000 1"
SORT_I2="${EPO_DLSGTAASII}  2000 1"
SORT_O="${ESF_DLSGTAASII} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT

else

## ${ESF_DLSGTAASO_BBNI}

##

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="Transforme ESF_DLSGTAASO_BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${ESF_DLSGTAASO_BBNI} "
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_ESF_DLSGTAASO_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1A10001G"; print \$0;}
if (\$6 == "1A100022") { \$6 = "1A10062G"; print \$0;}
if (\$6 == "1A120062") { \$6 = "1A14061G"; print \$0;}
if (\$6 == "1A120012") { \$6 = "1A12001G"; print \$0;}
if (\$6 == "1A120052") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A120072") { \$6 = "1A12007G"; print \$0;}
if (\$6 == "1A494302") { \$6 = "1A49461G"; print \$0;}
if (\$6 == "1A200712") { \$6 = "1A49462G"; print \$0;}
if (\$6 == "1A461112") { \$6 = "1A46060G"; print \$0;}
if (\$6 == "1A416012") { \$6 = "1A41101G"; print \$0;}
if (\$6 == "1A121212") { \$6 = "1A12161G"; print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_205
#-----------------------------------------------------------------------------
LIBEL="Merge ESF_DLSGTAASO_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_AWK_ESF_DLSGTAASO_BBNI.dat 2000 1"
SORT_I2="${EPO_DLSGTAASO}  2000 1"
SORT_O="${ESF_DLSGTAASO} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT

fi


## TRANSCO 3610

ECHO_LOG "#===> EST_GTSII_ICR               ........................... :${EST_GTSII_ICR}"               
ECHO_LOG "#===> EST_DLCUMGTAAR               ........................... :${EST_DLCUMGTAAR}"              
ECHO_LOG "#===> EST_DLSIIGTAA'               ........................... :${EST_DLSIIGTAA}"               
ECHO_LOG "#===> EST_DLSIIGTAR'               ........................... :${EST_DLSIIGTAR}"               
ECHO_LOG "#===> EST_GTSII_CASHFLOW'          ........................... :${EST_GTSII_CASHFLOW}"           
ECHO_LOG "#===> EST_GTSII_CLACC_CASHFLOW     ........................... :${EST_GTSII_CLACC_CASHFLOW}"     
ECHO_LOG "#===> EST_GTSII_GLOBAL_CASHFLOW    ........................... :${EST_GTSII_GLOBAL_CASHFLOW}"    
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAE   ........................... :${EST_GTSII_REMAINTOPAY_ULAE}"   
ECHO_LOG "#===> EST_DLCUMGTAAR_IBNR_FUTCLAIMS........................... :${EST_DLCUMGTAAR_IBNR_FUTCLAIMS}"
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAEINF........................... :${EST_GTSII_REMAINTOPAY_ULAEINF}" 

## if (\$6 == "1A416012") { \$6 = "1A46060G"; \$7 = "1B46060G";print \$0;}


## if (\$6 == "1A461112") { \$6 = "1A46060G";print \$0;}   ##ce sont les IME

NSTEP=${NJOB}_210
#-----------------------------------------------------------------------------
LIBEL="Transforme EST_GTSII_GLOBAL_CASHFLOW _BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${EST_GTSII_GLOBAL_CASHFLOW_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_GTSII_GLOBAL_CASHFLOW_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {





if ( (\$6 == "1A100012") && (\$50 == "ALLNO") ) { \$6 = "1A10001G" ;print \$0;}  else if ((\$6 == "1A100012") && (\$50 != "ALLNO") ) { \$6 = "1A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A100022") && (\$50 == "ALLNO") ) { \$6 = "1A10062G" ;print \$0;}  else if ((\$6 == "1A100022") && (\$50 != "ALLNO") ) { \$6 = "1A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120062") && (\$50 == "ALLNO") ) { \$6 = "1A14061G" ;print \$0;}  else if ((\$6 == "1A120062") && (\$50 != "ALLNO") ) { \$6 = "1A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120012") && (\$50 == "ALLNO") ) { \$6 = "1A12001G" ;print \$0;}  else if ((\$6 == "1A120012") && (\$50 != "ALLNO") ) { \$6 = "1A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120052") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120052") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120072") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120072") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A461112") && (\$50 == "ALLNO") ) { \$6 = "1A46060G" ;print \$0;}  else if ((\$6 == "1A461112") && (\$50 != "ALLNO") ) { \$6 = "1A46060G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A494302") && (\$50 == "ALLNO") ) { \$6 = "1A49461G" ;print \$0;}  else if ((\$6 == "1A494302") && (\$50 != "ALLNO") ) { \$6 = "1A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A200712") && (\$50 == "ALLNO") ) { \$6 = "1A49462G" ;print \$0;}  else if ((\$6 == "1A200712") && (\$50 != "ALLNO") ) { \$6 = "1A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A416012") && (\$50 == "ALLNO") ) { \$6 = "1A41101G" ;print \$0;}  else if ((\$6 == "1A416012") && (\$50 != "ALLNO") ) { \$6 = "1A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A121212") && (\$50 == "ALLNO") ) { \$6 = "1A12161G" ;print \$0;}  else if ((\$6 == "1A121212") && (\$50 != "ALLNO") ) { \$6 = "1A12161G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100012") && (\$50 == "ALLNO") ) { \$6 = "2A10001G" ;print \$0;}  else if ((\$6 == "2A100012") && (\$50 != "ALLNO") ) { \$6 = "2A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100022") && (\$50 == "ALLNO") ) { \$6 = "2A10062G" ;print \$0;}  else if ((\$6 == "2A100022") && (\$50 != "ALLNO") ) { \$6 = "2A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120062") && (\$50 == "ALLNO") ) { \$6 = "2A14061G" ;print \$0;}  else if ((\$6 == "2A120062") && (\$50 != "ALLNO") ) { \$6 = "2A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120012") && (\$50 == "ALLNO") ) { \$6 = "2A12001G" ;print \$0;}  else if ((\$6 == "2A120012") && (\$50 != "ALLNO") ) { \$6 = "2A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120052") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120052") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120072") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120072") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A494302") && (\$50 == "ALLNO") ) { \$6 = "2A49461G" ;print \$0;}  else if ((\$6 == "2A494302") && (\$50 != "ALLNO") ) { \$6 = "2A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A200712") && (\$50 == "ALLNO") ) { \$6 = "2A49462G" ;print \$0;}  else if ((\$6 == "2A200712") && (\$50 != "ALLNO") ) { \$6 = "2A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A416012") && (\$50 == "ALLNO") ) { \$6 = "2A41101G" ;print \$0;}  else if ((\$6 == "2A416012") && (\$50 != "ALLNO") ) { \$6 = "2A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A121212") && (\$50 == "ALLNO") ) { \$6 = "2A12161G" ;print \$0;}  else if ((\$6 == "2A121212") && (\$50 != "ALLNO") ) { \$6 = "2A12161G"; \$50 = "SII";print \$0;}



## { \$50 = "SII";print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_215
#-----------------------------------------------------------------------------
LIBEL="Merge EST_GTSII_GLOBAL_CASHFLOW_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_210_${IB}_AWK_EST_GTSII_GLOBAL_CASHFLOW_BBNI.dat 2000 1"
SORT_I2="${EST_GTSII_GLOBAL_CASHFLOW}  2000 1"
SORT_O="${ESF_GTSII_GLOBAL_CASHFLOW} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT


NSTEP=${NJOB}_220
#-----------------------------------------------------------------------------
LIBEL="Transforme EST_GTSII_CASHFLOW _BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${EST_GTSII_CASHFLOW_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_GTSII_CASHFLOW_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


if ( (\$6 == "1A100012") && (\$50 == "ALLNO") ) { \$6 = "1A10001G" ;print \$0;}  else if ((\$6 == "1A100012") && (\$50 != "ALLNO") ) { \$6 = "1A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A100022") && (\$50 == "ALLNO") ) { \$6 = "1A10062G" ;print \$0;}  else if ((\$6 == "1A100022") && (\$50 != "ALLNO") ) { \$6 = "1A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120062") && (\$50 == "ALLNO") ) { \$6 = "1A14061G" ;print \$0;}  else if ((\$6 == "1A120062") && (\$50 != "ALLNO") ) { \$6 = "1A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120012") && (\$50 == "ALLNO") ) { \$6 = "1A12001G" ;print \$0;}  else if ((\$6 == "1A120012") && (\$50 != "ALLNO") ) { \$6 = "1A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120052") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120052") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120072") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120072") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A461112") && (\$50 == "ALLNO") ) { \$6 = "1A46060G" ;print \$0;}  else if ((\$6 == "1A461112") && (\$50 != "ALLNO") ) { \$6 = "1A46060G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A494302") && (\$50 == "ALLNO") ) { \$6 = "1A49461G" ;print \$0;}  else if ((\$6 == "1A494302") && (\$50 != "ALLNO") ) { \$6 = "1A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A200712") && (\$50 == "ALLNO") ) { \$6 = "1A49462G" ;print \$0;}  else if ((\$6 == "1A200712") && (\$50 != "ALLNO") ) { \$6 = "1A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A416012") && (\$50 == "ALLNO") ) { \$6 = "1A41101G" ;print \$0;}  else if ((\$6 == "1A416012") && (\$50 != "ALLNO") ) { \$6 = "1A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A121212") && (\$50 == "ALLNO") ) { \$6 = "1A12161G" ;print \$0;}  else if ((\$6 == "1A121212") && (\$50 != "ALLNO") ) { \$6 = "1A12161G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100012") && (\$50 == "ALLNO") ) { \$6 = "2A10001G" ;print \$0;}  else if ((\$6 == "2A100012") && (\$50 != "ALLNO") ) { \$6 = "2A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100022") && (\$50 == "ALLNO") ) { \$6 = "2A10062G" ;print \$0;}  else if ((\$6 == "2A100022") && (\$50 != "ALLNO") ) { \$6 = "2A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120062") && (\$50 == "ALLNO") ) { \$6 = "2A14061G" ;print \$0;}  else if ((\$6 == "2A120062") && (\$50 != "ALLNO") ) { \$6 = "2A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120012") && (\$50 == "ALLNO") ) { \$6 = "2A12001G" ;print \$0;}  else if ((\$6 == "2A120012") && (\$50 != "ALLNO") ) { \$6 = "2A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120052") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120052") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120072") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120072") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A494302") && (\$50 == "ALLNO") ) { \$6 = "2A49461G" ;print \$0;}  else if ((\$6 == "2A494302") && (\$50 != "ALLNO") ) { \$6 = "2A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A200712") && (\$50 == "ALLNO") ) { \$6 = "2A49462G" ;print \$0;}  else if ((\$6 == "2A200712") && (\$50 != "ALLNO") ) { \$6 = "2A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A416012") && (\$50 == "ALLNO") ) { \$6 = "2A41101G" ;print \$0;}  else if ((\$6 == "2A416012") && (\$50 != "ALLNO") ) { \$6 = "2A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A121212") && (\$50 == "ALLNO") ) { \$6 = "2A12161G" ;print \$0;}  else if ((\$6 == "2A121212") && (\$50 != "ALLNO") ) { \$6 = "2A12161G"; \$50 = "SII";print \$0;} 


## { \$50 = "SII";print \$0;}

fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_225
#-----------------------------------------------------------------------------
LIBEL="Merge EST_GTSII_CASHFLOW_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_220_${IB}_AWK_EST_GTSII_CASHFLOW_BBNI.dat 2000 1"
SORT_I2="${EST_GTSII_CASHFLOW}  2000 1"
SORT_O="${ESF_GTSII_CASHFLOW} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT


NSTEP=${NJOB}_230
#-----------------------------------------------------------------------------
LIBEL="Transforme EST_GTSII_CLACC_CASHFLOW _BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${EST_GTSII_CLACC_CASHFLOW_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_GTSII_CLACC_CASHFLOW_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


if ( (\$6 == "1A100012") && (\$50 == "ALLNO") ) { \$6 = "1A10001G" ;print \$0;}  else if ((\$6 == "1A100012") && (\$50 != "ALLNO") ) { \$6 = "1A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A100022") && (\$50 == "ALLNO") ) { \$6 = "1A10062G" ;print \$0;}  else if ((\$6 == "1A100022") && (\$50 != "ALLNO") ) { \$6 = "1A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120062") && (\$50 == "ALLNO") ) { \$6 = "1A14061G" ;print \$0;}  else if ((\$6 == "1A120062") && (\$50 != "ALLNO") ) { \$6 = "1A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120012") && (\$50 == "ALLNO") ) { \$6 = "1A12001G" ;print \$0;}  else if ((\$6 == "1A120012") && (\$50 != "ALLNO") ) { \$6 = "1A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120052") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120052") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120072") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120072") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A461112") && (\$50 == "ALLNO") ) { \$6 = "1A46060G" ;print \$0;}  else if ((\$6 == "1A461112") && (\$50 != "ALLNO") ) { \$6 = "1A46060G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A494302") && (\$50 == "ALLNO") ) { \$6 = "1A49461G" ;print \$0;}  else if ((\$6 == "1A494302") && (\$50 != "ALLNO") ) { \$6 = "1A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A200712") && (\$50 == "ALLNO") ) { \$6 = "1A49462G" ;print \$0;}  else if ((\$6 == "1A200712") && (\$50 != "ALLNO") ) { \$6 = "1A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A416012") && (\$50 == "ALLNO") ) { \$6 = "1A41101G" ;print \$0;}  else if ((\$6 == "1A416012") && (\$50 != "ALLNO") ) { \$6 = "1A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A121212") && (\$50 == "ALLNO") ) { \$6 = "1A12161G" ;print \$0;}  else if ((\$6 == "1A121212") && (\$50 != "ALLNO") ) { \$6 = "1A12161G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100012") && (\$50 == "ALLNO") ) { \$6 = "2A10001G" ;print \$0;}  else if ((\$6 == "2A100012") && (\$50 != "ALLNO") ) { \$6 = "2A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100022") && (\$50 == "ALLNO") ) { \$6 = "2A10062G" ;print \$0;}  else if ((\$6 == "2A100022") && (\$50 != "ALLNO") ) { \$6 = "2A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120062") && (\$50 == "ALLNO") ) { \$6 = "2A14061G" ;print \$0;}  else if ((\$6 == "2A120062") && (\$50 != "ALLNO") ) { \$6 = "2A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120012") && (\$50 == "ALLNO") ) { \$6 = "2A12001G" ;print \$0;}  else if ((\$6 == "2A120012") && (\$50 != "ALLNO") ) { \$6 = "2A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120052") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120052") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120072") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120072") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A494302") && (\$50 == "ALLNO") ) { \$6 = "2A49461G" ;print \$0;}  else if ((\$6 == "2A494302") && (\$50 != "ALLNO") ) { \$6 = "2A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A200712") && (\$50 == "ALLNO") ) { \$6 = "2A49462G" ;print \$0;}  else if ((\$6 == "2A200712") && (\$50 != "ALLNO") ) { \$6 = "2A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A416012") && (\$50 == "ALLNO") ) { \$6 = "2A41101G" ;print \$0;}  else if ((\$6 == "2A416012") && (\$50 != "ALLNO") ) { \$6 = "2A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A121212") && (\$50 == "ALLNO") ) { \$6 = "2A12161G" ;print \$0;}  else if ((\$6 == "2A121212") && (\$50 != "ALLNO") ) { \$6 = "2A12161G"; \$50 = "SII";print \$0;}


## { \$50 = "SII";print \$0;}


fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_235
#-----------------------------------------------------------------------------
LIBEL="Merge EST_GTSII_CLACC_CASHFLOW_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_230_${IB}_AWK_EST_GTSII_CLACC_CASHFLOW_BBNI.dat 2000 1"
SORT_I2="${EST_GTSII_CLACC_CASHFLOW}  2000 1"
SORT_O="${ESF_GTSII_CLACC_CASHFLOW} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_240
#-----------------------------------------------------------------------------
LIBEL="Transforme EST_GTSII_REMAINTOPAY_ULAE _BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${EST_GTSII_REMAINTOPAY_ULAE_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_GTSII_REMAINTOPAY_ULAE_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


if ( (\$6 == "1A100012") && (\$50 == "ALLNO") ) { \$6 = "1A10001G" ;print \$0;}  else if ((\$6 == "1A100012") && (\$50 != "ALLNO") ) { \$6 = "1A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A100022") && (\$50 == "ALLNO") ) { \$6 = "1A10062G" ;print \$0;}  else if ((\$6 == "1A100022") && (\$50 != "ALLNO") ) { \$6 = "1A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120062") && (\$50 == "ALLNO") ) { \$6 = "1A14061G" ;print \$0;}  else if ((\$6 == "1A120062") && (\$50 != "ALLNO") ) { \$6 = "1A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120012") && (\$50 == "ALLNO") ) { \$6 = "1A12001G" ;print \$0;}  else if ((\$6 == "1A120012") && (\$50 != "ALLNO") ) { \$6 = "1A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120052") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120052") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120072") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120072") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A461112") && (\$50 == "ALLNO") ) { \$6 = "1A46060G" ;print \$0;}  else if ((\$6 == "1A461112") && (\$50 != "ALLNO") ) { \$6 = "1A46060G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A494302") && (\$50 == "ALLNO") ) { \$6 = "1A49461G" ;print \$0;}  else if ((\$6 == "1A494302") && (\$50 != "ALLNO") ) { \$6 = "1A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A200712") && (\$50 == "ALLNO") ) { \$6 = "1A49462G" ;print \$0;}  else if ((\$6 == "1A200712") && (\$50 != "ALLNO") ) { \$6 = "1A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A416012") && (\$50 == "ALLNO") ) { \$6 = "1A41101G" ;print \$0;}  else if ((\$6 == "1A416012") && (\$50 != "ALLNO") ) { \$6 = "1A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A121212") && (\$50 == "ALLNO") ) { \$6 = "1A12161G" ;print \$0;}  else if ((\$6 == "1A121212") && (\$50 != "ALLNO") ) { \$6 = "1A12161G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100012") && (\$50 == "ALLNO") ) { \$6 = "2A10001G" ;print \$0;}  else if ((\$6 == "2A100012") && (\$50 != "ALLNO") ) { \$6 = "2A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100022") && (\$50 == "ALLNO") ) { \$6 = "2A10062G" ;print \$0;}  else if ((\$6 == "2A100022") && (\$50 != "ALLNO") ) { \$6 = "2A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120062") && (\$50 == "ALLNO") ) { \$6 = "2A14061G" ;print \$0;}  else if ((\$6 == "2A120062") && (\$50 != "ALLNO") ) { \$6 = "2A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120012") && (\$50 == "ALLNO") ) { \$6 = "2A12001G" ;print \$0;}  else if ((\$6 == "2A120012") && (\$50 != "ALLNO") ) { \$6 = "2A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120052") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120052") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120072") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120072") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A494302") && (\$50 == "ALLNO") ) { \$6 = "2A49461G" ;print \$0;}  else if ((\$6 == "2A494302") && (\$50 != "ALLNO") ) { \$6 = "2A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A200712") && (\$50 == "ALLNO") ) { \$6 = "2A49462G" ;print \$0;}  else if ((\$6 == "2A200712") && (\$50 != "ALLNO") ) { \$6 = "2A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A416012") && (\$50 == "ALLNO") ) { \$6 = "2A41101G" ;print \$0;}  else if ((\$6 == "2A416012") && (\$50 != "ALLNO") ) { \$6 = "2A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A121212") && (\$50 == "ALLNO") ) { \$6 = "2A12161G" ;print \$0;}  else if ((\$6 == "2A121212") && (\$50 != "ALLNO") ) { \$6 = "2A12161G"; \$50 = "SII";print \$0;}


## { \$50 = "SII";print \$0;}

fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_245
#-----------------------------------------------------------------------------
LIBEL="Merge EST_GTSII_REMAINTOPAY_ULAE_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_240_${IB}_AWK_EST_GTSII_REMAINTOPAY_ULAE_BBNI.dat 2000 1"
SORT_I2="${EST_GTSII_REMAINTOPAY_ULAE}  2000 1"
SORT_O="${ESF_GTSII_REMAINTOPAY_ULAE} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT


NSTEP=${NJOB}_250
#-----------------------------------------------------------------------------
LIBEL="Transforme EST_GTSII_REMAINTOPAY_ULAEINF _BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${EST_GTSII_REMAINTOPAY_ULAEINF_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_GTSII_REMAINTOPAY_ULAEINF_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


if ( (\$6 == "1A100012") && (\$50 == "ALLNO") ) { \$6 = "1A10001G" ;print \$0;}  else if ((\$6 == "1A100012") && (\$50 != "ALLNO") ) { \$6 = "1A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A100022") && (\$50 == "ALLNO") ) { \$6 = "1A10062G" ;print \$0;}  else if ((\$6 == "1A100022") && (\$50 != "ALLNO") ) { \$6 = "1A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120062") && (\$50 == "ALLNO") ) { \$6 = "1A14061G" ;print \$0;}  else if ((\$6 == "1A120062") && (\$50 != "ALLNO") ) { \$6 = "1A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120012") && (\$50 == "ALLNO") ) { \$6 = "1A12001G" ;print \$0;}  else if ((\$6 == "1A120012") && (\$50 != "ALLNO") ) { \$6 = "1A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120052") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120052") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120072") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120072") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A461112") && (\$50 == "ALLNO") ) { \$6 = "1A46060G" ;print \$0;}  else if ((\$6 == "1A461112") && (\$50 != "ALLNO") ) { \$6 = "1A46060G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A494302") && (\$50 == "ALLNO") ) { \$6 = "1A49461G" ;print \$0;}  else if ((\$6 == "1A494302") && (\$50 != "ALLNO") ) { \$6 = "1A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A200712") && (\$50 == "ALLNO") ) { \$6 = "1A49462G" ;print \$0;}  else if ((\$6 == "1A200712") && (\$50 != "ALLNO") ) { \$6 = "1A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A416012") && (\$50 == "ALLNO") ) { \$6 = "1A41101G" ;print \$0;}  else if ((\$6 == "1A416012") && (\$50 != "ALLNO") ) { \$6 = "1A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A121212") && (\$50 == "ALLNO") ) { \$6 = "1A12161G" ;print \$0;}  else if ((\$6 == "1A121212") && (\$50 != "ALLNO") ) { \$6 = "1A12161G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100012") && (\$50 == "ALLNO") ) { \$6 = "2A10001G" ;print \$0;}  else if ((\$6 == "2A100012") && (\$50 != "ALLNO") ) { \$6 = "2A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100022") && (\$50 == "ALLNO") ) { \$6 = "2A10062G" ;print \$0;}  else if ((\$6 == "2A100022") && (\$50 != "ALLNO") ) { \$6 = "2A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120062") && (\$50 == "ALLNO") ) { \$6 = "2A14061G" ;print \$0;}  else if ((\$6 == "2A120062") && (\$50 != "ALLNO") ) { \$6 = "2A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120012") && (\$50 == "ALLNO") ) { \$6 = "2A12001G" ;print \$0;}  else if ((\$6 == "2A120012") && (\$50 != "ALLNO") ) { \$6 = "2A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120052") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120052") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120072") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120072") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A494302") && (\$50 == "ALLNO") ) { \$6 = "2A49461G" ;print \$0;}  else if ((\$6 == "2A494302") && (\$50 != "ALLNO") ) { \$6 = "2A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A200712") && (\$50 == "ALLNO") ) { \$6 = "2A49462G" ;print \$0;}  else if ((\$6 == "2A200712") && (\$50 != "ALLNO") ) { \$6 = "2A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A416012") && (\$50 == "ALLNO") ) { \$6 = "2A41101G" ;print \$0;}  else if ((\$6 == "2A416012") && (\$50 != "ALLNO") ) { \$6 = "2A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A121212") && (\$50 == "ALLNO") ) { \$6 = "2A12161G" ;print \$0;}  else if ((\$6 == "2A121212") && (\$50 != "ALLNO") ) { \$6 = "2A12161G"; \$50 = "SII";print \$0;}


## { \$50 = "SII";print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_255
#-----------------------------------------------------------------------------
LIBEL="Merge EST_GTSII_REMAINTOPAY_ULAEINF_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_AWK_EST_GTSII_REMAINTOPAY_ULAEINF_BBNI.dat 2000 1"
SORT_I2="${EST_GTSII_REMAINTOPAY_ULAEINF}  2000 1"
SORT_O="${ESF_GTSII_REMAINTOPAY_ULAEINF} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT




NSTEP=${NJOB}_260
#-----------------------------------------------------------------------------
LIBEL="Transforme EST_DLCUMGTAAR_IBNR_FUTCLAIMS _BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${EST_DLCUMGTAAR_IBNR_FUTCLAIMS_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_DLCUMGTAAR_IBNR_FUTCLAIMS_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {




if ( (\$6 == "1A100012") && (\$50 == "ALLNO") ) { \$6 = "1A10001G" ;print \$0;}  else if ((\$6 == "1A100012") && (\$50 != "ALLNO") ) { \$6 = "1A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A100022") && (\$50 == "ALLNO") ) { \$6 = "1A10062G" ;print \$0;}  else if ((\$6 == "1A100022") && (\$50 != "ALLNO") ) { \$6 = "1A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120062") && (\$50 == "ALLNO") ) { \$6 = "1A14061G" ;print \$0;}  else if ((\$6 == "1A120062") && (\$50 != "ALLNO") ) { \$6 = "1A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120012") && (\$50 == "ALLNO") ) { \$6 = "1A12001G" ;print \$0;}  else if ((\$6 == "1A120012") && (\$50 != "ALLNO") ) { \$6 = "1A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120052") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120052") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120072") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120072") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A461112") && (\$50 == "ALLNO") ) { \$6 = "1A46060G" ;print \$0;}  else if ((\$6 == "1A461112") && (\$50 != "ALLNO") ) { \$6 = "1A46060G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A494302") && (\$50 == "ALLNO") ) { \$6 = "1A49461G" ;print \$0;}  else if ((\$6 == "1A494302") && (\$50 != "ALLNO") ) { \$6 = "1A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A200712") && (\$50 == "ALLNO") ) { \$6 = "1A49462G" ;print \$0;}  else if ((\$6 == "1A200712") && (\$50 != "ALLNO") ) { \$6 = "1A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A416012") && (\$50 == "ALLNO") ) { \$6 = "1A41101G" ;print \$0;}  else if ((\$6 == "1A416012") && (\$50 != "ALLNO") ) { \$6 = "1A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A121212") && (\$50 == "ALLNO") ) { \$6 = "1A12161G" ;print \$0;}  else if ((\$6 == "1A121212") && (\$50 != "ALLNO") ) { \$6 = "1A12161G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100012") && (\$50 == "ALLNO") ) { \$6 = "2A10001G" ;print \$0;}  else if ((\$6 == "2A100012") && (\$50 != "ALLNO") ) { \$6 = "2A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100022") && (\$50 == "ALLNO") ) { \$6 = "2A10062G" ;print \$0;}  else if ((\$6 == "2A100022") && (\$50 != "ALLNO") ) { \$6 = "2A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120062") && (\$50 == "ALLNO") ) { \$6 = "2A14061G" ;print \$0;}  else if ((\$6 == "2A120062") && (\$50 != "ALLNO") ) { \$6 = "2A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120012") && (\$50 == "ALLNO") ) { \$6 = "2A12001G" ;print \$0;}  else if ((\$6 == "2A120012") && (\$50 != "ALLNO") ) { \$6 = "2A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120052") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120052") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120072") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120072") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A494302") && (\$50 == "ALLNO") ) { \$6 = "2A49461G" ;print \$0;}  else if ((\$6 == "2A494302") && (\$50 != "ALLNO") ) { \$6 = "2A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A200712") && (\$50 == "ALLNO") ) { \$6 = "2A49462G" ;print \$0;}  else if ((\$6 == "2A200712") && (\$50 != "ALLNO") ) { \$6 = "2A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A416012") && (\$50 == "ALLNO") ) { \$6 = "2A41101G" ;print \$0;}  else if ((\$6 == "2A416012") && (\$50 != "ALLNO") ) { \$6 = "2A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A121212") && (\$50 == "ALLNO") ) { \$6 = "2A12161G" ;print \$0;}  else if ((\$6 == "2A121212") && (\$50 != "ALLNO") ) { \$6 = "2A12161G"; \$50 = "SII";print \$0;}





## { \$50 = "SII";print \$0;}


fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_265
#-----------------------------------------------------------------------------
LIBEL="Merge EST_DLCUMGTAAR_IBNR_FUTCLAIMS_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_260_${IB}_AWK_EST_DLCUMGTAAR_IBNR_FUTCLAIMS_BBNI.dat 2000 1"
SORT_I2="${EST_DLCUMGTAAR_IBNR_FUTCLAIMS}  2000 1"
SORT_O="${ESF_DLCUMGTAAR_IBNR_FUTCLAIMS} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_270
#-----------------------------------------------------------------------------
LIBEL="Transforme EST_GTEP _BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${EST_GTEP_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_GTEP_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


if ( (\$6 == "1A100012") && (\$50 == "ALLNO") ) { \$6 = "1A10001G" ;print \$0;}  else if ((\$6 == "1A100012") && (\$50 != "ALLNO") ) { \$6 = "1A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A100022") && (\$50 == "ALLNO") ) { \$6 = "1A10062G" ;print \$0;}  else if ((\$6 == "1A100022") && (\$50 != "ALLNO") ) { \$6 = "1A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120062") && (\$50 == "ALLNO") ) { \$6 = "1A14061G" ;print \$0;}  else if ((\$6 == "1A120062") && (\$50 != "ALLNO") ) { \$6 = "1A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120012") && (\$50 == "ALLNO") ) { \$6 = "1A12001G" ;print \$0;}  else if ((\$6 == "1A120012") && (\$50 != "ALLNO") ) { \$6 = "1A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120052") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120052") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120072") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120072") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A461112") && (\$50 == "ALLNO") ) { \$6 = "1A46060G" ;print \$0;}  else if ((\$6 == "1A461112") && (\$50 != "ALLNO") ) { \$6 = "1A46060G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A494302") && (\$50 == "ALLNO") ) { \$6 = "1A49461G" ;print \$0;}  else if ((\$6 == "1A494302") && (\$50 != "ALLNO") ) { \$6 = "1A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A200712") && (\$50 == "ALLNO") ) { \$6 = "1A49462G" ;print \$0;}  else if ((\$6 == "1A200712") && (\$50 != "ALLNO") ) { \$6 = "1A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A416012") && (\$50 == "ALLNO") ) { \$6 = "1A41101G" ;print \$0;}  else if ((\$6 == "1A416012") && (\$50 != "ALLNO") ) { \$6 = "1A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A121212") && (\$50 == "ALLNO") ) { \$6 = "1A12161G" ;print \$0;}  else if ((\$6 == "1A121212") && (\$50 != "ALLNO") ) { \$6 = "1A12161G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100012") && (\$50 == "ALLNO") ) { \$6 = "2A10001G" ;print \$0;}  else if ((\$6 == "2A100012") && (\$50 != "ALLNO") ) { \$6 = "2A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100022") && (\$50 == "ALLNO") ) { \$6 = "2A10062G" ;print \$0;}  else if ((\$6 == "2A100022") && (\$50 != "ALLNO") ) { \$6 = "2A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120062") && (\$50 == "ALLNO") ) { \$6 = "2A14061G" ;print \$0;}  else if ((\$6 == "2A120062") && (\$50 != "ALLNO") ) { \$6 = "2A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120012") && (\$50 == "ALLNO") ) { \$6 = "2A12001G" ;print \$0;}  else if ((\$6 == "2A120012") && (\$50 != "ALLNO") ) { \$6 = "2A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120052") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120052") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120072") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120072") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A494302") && (\$50 == "ALLNO") ) { \$6 = "2A49461G" ;print \$0;}  else if ((\$6 == "2A494302") && (\$50 != "ALLNO") ) { \$6 = "2A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A200712") && (\$50 == "ALLNO") ) { \$6 = "2A49462G" ;print \$0;}  else if ((\$6 == "2A200712") && (\$50 != "ALLNO") ) { \$6 = "2A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A416012") && (\$50 == "ALLNO") ) { \$6 = "2A41101G" ;print \$0;}  else if ((\$6 == "2A416012") && (\$50 != "ALLNO") ) { \$6 = "2A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A121212") && (\$50 == "ALLNO") ) { \$6 = "2A12161G" ;print \$0;}  else if ((\$6 == "2A121212") && (\$50 != "ALLNO") ) { \$6 = "2A12161G"; \$50 = "SII";print \$0;}


## { \$50 = "SII";print \$0;}



fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_275
#-----------------------------------------------------------------------------
LIBEL="Merge EST_GTEP_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_AWK_EST_GTEP_BBNI.dat 2000 1"
SORT_I2="${EST_GTEP}  2000 1"
SORT_O="${ESF_GTEP} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT


#####

NSTEP=${NJOB}_280
#-----------------------------------------------------------------------------
LIBEL="Transforme EST_DLEIFTECLEDSIIEP _BBNI TRNCOD en Norme EBS : '1Axxxxx2' en EBS BBNI' "
AWK_I="${EST_DLEIFTECLEDSIIEP_BBNI}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_DLEIFTECLEDSIIEP_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


if ( (\$6 == "1A100012") && (\$50 == "ALLNO") ) { \$6 = "1A10001G" ;print \$0;}  else if ((\$6 == "1A100012") && (\$50 != "ALLNO") ) { \$6 = "1A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A100022") && (\$50 == "ALLNO") ) { \$6 = "1A10062G" ;print \$0;}  else if ((\$6 == "1A100022") && (\$50 != "ALLNO") ) { \$6 = "1A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120062") && (\$50 == "ALLNO") ) { \$6 = "1A14061G" ;print \$0;}  else if ((\$6 == "1A120062") && (\$50 != "ALLNO") ) { \$6 = "1A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120012") && (\$50 == "ALLNO") ) { \$6 = "1A12001G" ;print \$0;}  else if ((\$6 == "1A120012") && (\$50 != "ALLNO") ) { \$6 = "1A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120052") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120052") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A120072") && (\$50 == "ALLNO") ) { \$6 = "1A12007G" ;print \$0;}  else if ((\$6 == "1A120072") && (\$50 != "ALLNO") ) { \$6 = "1A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A461112") && (\$50 == "ALLNO") ) { \$6 = "1A46060G" ;print \$0;}  else if ((\$6 == "1A461112") && (\$50 != "ALLNO") ) { \$6 = "1A46060G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A494302") && (\$50 == "ALLNO") ) { \$6 = "1A49461G" ;print \$0;}  else if ((\$6 == "1A494302") && (\$50 != "ALLNO") ) { \$6 = "1A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A200712") && (\$50 == "ALLNO") ) { \$6 = "1A49462G" ;print \$0;}  else if ((\$6 == "1A200712") && (\$50 != "ALLNO") ) { \$6 = "1A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A416012") && (\$50 == "ALLNO") ) { \$6 = "1A41101G" ;print \$0;}  else if ((\$6 == "1A416012") && (\$50 != "ALLNO") ) { \$6 = "1A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "1A121212") && (\$50 == "ALLNO") ) { \$6 = "1A12161G" ;print \$0;}  else if ((\$6 == "1A121212") && (\$50 != "ALLNO") ) { \$6 = "1A12161G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100012") && (\$50 == "ALLNO") ) { \$6 = "2A10001G" ;print \$0;}  else if ((\$6 == "2A100012") && (\$50 != "ALLNO") ) { \$6 = "2A10001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A100022") && (\$50 == "ALLNO") ) { \$6 = "2A10062G" ;print \$0;}  else if ((\$6 == "2A100022") && (\$50 != "ALLNO") ) { \$6 = "2A10062G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120062") && (\$50 == "ALLNO") ) { \$6 = "2A14061G" ;print \$0;}  else if ((\$6 == "2A120062") && (\$50 != "ALLNO") ) { \$6 = "2A14061G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120012") && (\$50 == "ALLNO") ) { \$6 = "2A12001G" ;print \$0;}  else if ((\$6 == "2A120012") && (\$50 != "ALLNO") ) { \$6 = "2A12001G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120052") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120052") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A120072") && (\$50 == "ALLNO") ) { \$6 = "2A12007G" ;print \$0;}  else if ((\$6 == "2A120072") && (\$50 != "ALLNO") ) { \$6 = "2A12007G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A494302") && (\$50 == "ALLNO") ) { \$6 = "2A49461G" ;print \$0;}  else if ((\$6 == "2A494302") && (\$50 != "ALLNO") ) { \$6 = "2A49461G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A200712") && (\$50 == "ALLNO") ) { \$6 = "2A49462G" ;print \$0;}  else if ((\$6 == "2A200712") && (\$50 != "ALLNO") ) { \$6 = "2A49462G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A416012") && (\$50 == "ALLNO") ) { \$6 = "2A41101G" ;print \$0;}  else if ((\$6 == "2A416012") && (\$50 != "ALLNO") ) { \$6 = "2A41101G"; \$50 = "SII";print \$0;}
if ( (\$6 == "2A121212") && (\$50 == "ALLNO") ) { \$6 = "2A12161G" ;print \$0;}  else if ((\$6 == "2A121212") && (\$50 != "ALLNO") ) { \$6 = "2A12161G"; \$50 = "SII";print \$0;}

## { \$50 = "SII";print \$0;}

fi
  }
exit
EOF
AWK

NSTEP=${NJOB}_285
#-----------------------------------------------------------------------------
LIBEL="Merge EST_DLEIFTECLEDSIIEP_BBNI TRANSCODIFIES et des EBS CLASSIQUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_280_${IB}_AWK_EST_DLEIFTECLEDSIIEP_BBNI.dat 2000 1"
SORT_I2="${EST_DLEIFTECLEDSIIEP}  2000 1"
SORT_O="${ESF_DLEIFTECLEDSIIEP} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        NORME_CF         50:1 - 50:,
        RATING_CF        51:1 - 51:,
        PATCAT_CT        52:1 - 52:,
        PATTYP_CT        53:1 - 53:,
        PATTERN_ID       54:1 - 54:,
        FIN              55:1 - 119:,
        COEF_LOB        120:1 - 120:,
        DSCCUR_CF       121:1 - 121:,
        COMMENT         122:1 - 122:,
        TOTAUX_M        123:1 - 123:EN 15/3,
        CLISSD_NF       124:1 - 124:,
        CLOPRD          125:1 - 125:,
        DBCLO_D         126:1 - 126:,
        CRE2_D          127:1 - 127:,
        ORGSSD_CF       128:1 - 128:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        TRNCOD_CF,
        DBLTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CED_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        PLC_NT,
        RTO_NF,
        ACMTRS_NT,
        ACMCUR_CF,
        PRS_CF,
        NORME_CF,
        RATING_CF,
        PATCAT_CT,
        PATTYP_CT,
        PATTERN_ID,
        DSCCUR_CF
exit
EOF
SORT

####

JOBEND

