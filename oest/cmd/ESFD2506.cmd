#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - TAXES retrocession Management
# nom du script SHELL           : ESFD2506.cmd
# revision                      : $Revision:  
# date de creation              : 05/10/2021
# auteur                        : MZM
#-----------------------------------------------------------------------------
# Description :
#  TAXES retrocession Management
#
# job launched by ESID2550.cmd ; ESPD2550.cmd ; ESFD2550.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get parameters
BALSHTYEA_NF=$1
CLODAT_D=$2
TYPEINV=$3
NORME=$4

# Job initialisation
JOBINIT               



##TU

##ESF_TAXRETMGNT=/scor/scordata/ubam/perm/D_ESPD0060_TAXRETMGNT_EBS_POS_20210930.dat
##EST_DLREGTR=/scor/home/u006596/martin/temporaire/D_ESPD2550_DLREGTR_EBS_INV_20210930.dat
##EST_DLREGTR_OVR=/scor/scordata/ubam/perm/D_ESPD2550_DLREGTR_OVR_EBS_POS_20210930.dat
##
##EST_DLREGTAR=/scor/home/u006596/martin/temporaire/D_ESPD2550_DLREGTAR_EBS_INV_20210930.dat
##
##EST_FTRSLNK_TXT=/scor/scordata/ubam/perm/D_ESCJ0660_FTRSLNK_TXT.dat
##
##ESF_DLREGTR_TAXRETMGNT=$DFILT/M_DLREGTR_TAXRETMGNT.dat
##ESF_DLREGTAR_TAXRETMGNT=$DFILT/M_DLREGTAR_TAXRETMGNT.dat
##


if [ ! -f ${EST_DLREGTAR_OVR} ]
then
	touch ${EST_DLREGTAR_OVR}
fi

if [ ! -f ${EST_DLREGTAR} ]
then
	touch ${EST_DLREGTAR}
fi

if [ ! -f ${EST_DLREGTR_OVR} ]
then
	touch ${EST_DLREGTR_OVR}
fi

if [ ! -f ${EST_DLREGTR} ]
then
	touch ${EST_DLREGTR}
fi

if [ ! -f ${ESF_TAXRETMGNT} ]
then
	touch ${ESF_TAXRETMGNT}
fi

if [ ! -f ${ESF_DLREGTAR_TAXRETMGNT} ]
then
	touch ${ESF_DLREGTAR_TAXRETMGNT}
fi

if [ ! -f ${ESF_DLREGTR_TAXRETMGNT} ]
then
	touch ${ESF_DLREGTR_TAXRETMGNT}
fi



ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV................: ${TYPEINV}"
ECHO_LOG "#===> NORME..................: ${NORME}"
ECHO_LOG "#===> NORME_CF...............: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT.................: ${IDF_CT}"
ECHO_LOG "#===> EST_DLREGTAR_OVR.......: ${EST_DLREGTAR_OVR}"
ECHO_LOG "#===> EST_DLREGTAR...........: ${EST_DLREGTAR}"
ECHO_LOG "#===> EST_DLREGTR_OVR........: ${EST_DLREGTR_OVR}"
ECHO_LOG "#===> EST_FTRSLNK_TXT........: ${EST_FTRSLNK_TXT}"
ECHO_LOG "#===> EST_DLREGTR............: ${EST_DLREGTR}"
ECHO_LOG "#===> ESF_TAXRETMGNT.........: ${ESF_TAXRETMGNT}" 
ECHO_LOG "#===> ESF_DLREGTAR_TAXRETMGNT: ${ESF_DLREGTAR_TAXRETMGNT}"
ECHO_LOG "#===> ESF_DLREGTR_TAXRETMGNT.: ${ESF_DLREGTR_TAXRETMGNT}"
ECHO_LOG "#========================================================================="




NSTEP=${NJOB}_05
# Filter EST_FTRSLNK_TXT on PRS_CF = "51" AND ACMTRS_NT IN (1, 2)
#-----------------------------------------------------------------------------
LIBEL="Filter EST_FTRSLNK_TXT on PRS_CF = "51""
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_51.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF    		1:1 -  1:,
         ACMTRS_NT    2:1 -  2:
/CONDITION IS_PRS_51 ( PRS_CF = "51" ) AND (ACMTRS_NT= "1" OR ACMTRS_NT= "2" )
/OUTFILE $SORT_O
/INCLUDE IS_PRS_51
/COPY
exit
EOF
SORT




# TRNCOD_ CUMUL GT  "9T999909~" SORT_I="${EST_DLREGTR_OVR} 1000 1"

NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files DLREGTAR_OVR and DLREGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_O.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT    36:1 - 36 :,
        FIELD_37_40 37:1 - 40 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        FIELD_42_55 42:1 - 55 :,        
        TRN_NT 56:1 - 56:,
        FIELD_57 57:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        FIELD_59_72 59:1 - 71:,
        ALL_FIELDS_F1 1:1 - 72:,
        PRS_CF_F2 1:1 - 1:,  
        ACMTRS_NT_F2 2:1 - 2:,                
        DETTRS_CF_F2 3:1 - 3:
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FTRSLNK_51.dat 1000 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/OUTFILE ${SORT_O}
/REFORMAT  ALL_FIELDS_F1             
exit
EOF
SORT


# TRNCOD_ CUMUL GT  "9T999909~"

NSTEP=${NJOB}_20
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files DLREGTAR_OVR and DLREGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_DLREGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_O.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT    36:1 - 36 :,
        FIELD_37_40 37:1 - 40 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        FIELD_42_55 42:1 - 55 :,        
        TRN_NT 56:1 - 56:,
        FIELD_57 57:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        FIELD_59_72 59:1 - 71:,
        PRS_CF_F2 1:1 - 1:,  
        ACMTRS_NT_F2 2:1 - 2:,                
        DETTRS_CF_F2 3:1 - 3:
/KEYS   
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETCUR_CF,
        PLC_NT
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS  
/DERIVEDFIELD TRNCOD_CF_NEW  "9T999909~" 
/DERIVEDFIELD DBLTRNCOD_CF_NEW  "9T999909~"       
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/REFORMAT                   
         SSD_CF
         ,ESB_CF              
         ,BALSHEY_NF          
         ,BALSHRMTH_NF        
         ,BALSHRDAY_NF        
         ,TRNCOD_CF_NEW           
         ,DBLTRNCOD_CF_NEW        
         ,CTR_NF              
         ,END_NT              
         ,SEC_NF              
         ,UWY_NF              
         ,UW_NT               
         ,OCCYEA_NF           
         ,ACY_NF              
         ,SCOSTRMTH_NF        
         ,SCOENDMTH_NF        
         ,CLM_NF              
         ,CUR_CF              
         ,AMT_M              
         ,CED_NF              
         ,BRK_NF              
         ,PAY_NF              
         ,KEY_NF              
         ,RETCTR_NF           
         ,RETEND_NT           
         ,RETSEC_NF           
         ,RTY_NF              
         ,RETUW_NT            
         ,RETOCCYEA_NF        
         ,RETACY_NF           
         ,RETSCOSTRMTH_NF
         ,RETSCOENDMTH_NF 
         ,RCL_NF              
         ,RETCUR_CF           
         ,RETAMT_MC          
         ,PLC_NT              
         ,FIELD_37_40 
         ,RETINTAMT_MC
         ,FIELD_42_55 
         ,TRN_NT 
         ,FIELD_57
         ,RETROAUTO_B 
         ,FIELD_59_72                      
exit
EOF
SORT


# TRIE du fichier ESF_TAXRETMGNT sur RETCTR_NF, RTY_NF, PLC_NT, RETPRMTAX_CT, TAXTRNCOD_CF

NSTEP=${NJOB}_30
# ESF_TAXRETMGNT 
#-----------------------------------------------------------------------------
LIBEL="SORT OF TAXRETMGNT BY RETCTR,RETENT, RETSEC, RTY, RETUW ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TAXRETMGNT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TAXRETMGNT.dat 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	
					RETCTR_NF	               1:1 - 1:,  
					RTY_NF	                 2:1 - 2:,  
					PLC_NT	                 3:1 - 3:,  
					PLCVER_NT	               4:1 - 4:,  
					RETPRMTAXORD_NT          5:1 - 5:,  
					SSD_CF	                 6:1 - 6:,  
					ESB_CF	                 7:1 - 7:,  
					RTO_NF	                 8:1 - 8:,  
					RETPRMTAX_CT	           9:1 - 9:,  
					PLCRETPRMTAX_R	         10:1 - 10:,
					PLCTAXSTRAPP_D	         11:1 - 11:,  
					PLCTAXENDAPP_D	         12:1 - 12:,  
					CTLGPRMTAX_CT	           13:1 - 13:,  
					PRMTAXBASIS_NT	         14:1 - 14:,  
					CTLGPRMTAX_R	           15:1 - 15:,  
					TAXTRNCOD_CF	           16:1 - 16:,  
					TAXESTMGT_B	             17:1 - 17:,  
					CTLGPRMTAXACT_B          18:1 - 18:,  
					CTLGTAXSTRAPP_D          19:1 - 19:,  
					CTLGTAXENDAPP_D          20:1 - 20:				
/KEYS RETCTR_NF,
      RTY_NF,
      PLC_NT,
      RETPRMTAX_CT,
      TAXTRNCOD_CF
exit
EOF
SORT


# En fonction du type de closing, transformer le second digit --> EBS 1 --> A,E,J ; I4I Pas de changt ; I17 Regle de transcodification a voir


NSTEP=${NJOB}_45
# Join and sort of  DLREGTR File and TAXRETMGNT by RETCTR,RETENT, RETSEC, RTY, RETUW , PLC_NT
#------------------------------------------------------------------------------
LIBEL="Current DLREGTR_O File Sort, Join and Fusion With ESF_TAXRETMGNT ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLREGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_TAXRETMGNT_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
        	ALL_F1 					        1:1 - 72:,        	
					RETCTR_NF_F2               1:1 - 1:,  
        	RTY_NF_F2	                 2:1 - 2:,  
					PLC_NT_F2	                 3:1 - 3:,  
					PLCVER_NT_F2	             4:1 - 4:,  
					RETPRMTAXORD_NT_F2         5:1 - 5:,  
        	SSD_CF_F2	                 6:1 - 6:,  
					ESB_CF_F2	                 7:1 - 7:,  
					RTO_NF_F2	                 8:1 - 8:,  
					RETPRMTAX_CT_F2	           9:1 - 9:,  			
        	PLCRETPRMTAX_R_F2	         10:1 - 10:,
					PLCTAXSTRAPP_D_F2	         11:1 - 11:,
					PLCTAXENDAPP_D_F2	         12:1 - 12:,
					CTLGPRMTAX_CT_F2           13:1 - 13:,
					PRMTAXBASIS_NT_F2	         14:1 - 14:,
					CTLGPRMTAX_R_F2            15:1 - 15:,
					TAXTRNCOD_CF_F2            16:1 - 16:,
					TAXESTMGT_B_F2             17:1 - 17:,
					CTLGPRMTAXACT_B_F2         18:1 - 18:,
					CTLGTAXSTRAPP_D_F2         19:1 - 19:,
					CTLGTAXENDAPP_D_F2         20:1 - 20:								
/JOINKEYS RETCTR_NF,
          RETRTY_NF,
          PLC_NT
/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_TAXRETMGNT.dat 1000 1 "~"
/JOINKEYS RETCTR_NF_F2,
          RTY_NF_F2,
          PLC_NT_F2          
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE:RETCTR_NF_F2, RIGHTSIDE:RTY_NF_F2, RIGHTSIDE:PLC_NT_F2, RIGHTSIDE:RETPRMTAX_CT_F2, RIGHTSIDE:PLCRETPRMTAX_R_F2, RIGHTSIDE:TAXTRNCOD_CF_F2      
exit
EOF
SORT   


NSTEP=${NJOB}_50
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_SORT_DLREGTR_TAXRETMGNT_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_TAXRETMGNT_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 93:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT



NSTEP=${NJOB}_75
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying TAXEMANAGEMENT RETRO to DLREGTR..."
PRG=ESTC2408  
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_DLREGTR_TAXRETMGNT_O.dat
##export ${PRG}_O1=${ESF_DLREGTR_TAXRETMGNT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREGTR_TAXRETMGNT_O.dat
EXECPRG

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : 'x1xxxxxx' en 'xAxxxxxx' ET 9T999909 ==> VIDE " 
AWK_I=${DFILT}/${NJOB}_75_${IB}_ESTC2408_DLREGTR_TAXRETMGNT_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLREGTR_TAXRETMGNT_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
    \$7 = "";
    
    if ( ("${VNORME}" != "I4I") && ("${VNORME}" != "" ) ) 
    {
      if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,6);
      if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "E" substr(\$6,3,6);
      if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,6);
    }
    print \$0;
  }
exit
EOF
AWK



NSTEP=${NJOB}_120
#LIBEL="Copy Generation du TAX_DLREGTAR   partir du TAX_DLREGTR..."
	EXECKSH "cp ${DFILT}/${NJOB}_100_${IB}_AWK_DLREGTR_TAXRETMGNT_O.dat  ${ESF_DLREGTAR_TAXRETMGNT}"
	EXECKSH "cp ${DFILT}/${NJOB}_100_${IB}_AWK_DLREGTR_TAXRETMGNT_O.dat  ${ESF_DLREGTR_TAXRETMGNT}"	


## MERGE DU TAX_DLREGTAR AVEC DLREGTAR ET TAX_DLREGTR AVEC DLREGTR

NSTEP=${NJOB}_140
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files DLREGTR_TAXMGNT and DLREGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
##SORT_I="${ESF_DLREGTR_TAXRETMGNT} 1000 1"
SORT_I="${DFILT}/${NJOB}_100_${IB}_AWK_DLREGTR_TAXRETMGNT_O.dat 1000 1"
SORT_I2="${EST_DLREGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_O.dat OVERWRITE"
##SORT_O="${EST_DLREGTR} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT    36:1 - 36 :,
        FIELD_37_40 37:1 - 40 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        FIELD_42_55 42:1 - 55 :,        
        TRN_NT 56:1 - 56:,
        FIELD_57 57:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        FIELD_59_72 59:1 - 71:
/KEYS   
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETCUR_CF,
        PLC_NT
/OUTFILE ${SORT_O}                   
exit
EOF
SORT

NSTEP=${NJOB}_145
#LIBEL="Copy Generation du DLGTR Final..."
	EXECKSH "cp ${DFILT}/${NJOB}_140_${IB}_SORT_DLREGTR_O.dat  ${EST_DLREGTR}"




ECHO_LOG "#===> EST_DLREGTR.....007.......: ${EST_DLREGTR}"


NSTEP=${NJOB}_150
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files DLREGTAR_TAXMGNT and DLREGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${ESF_DLREGTAR_TAXRETMGNT} 1000 1"
SORT_I="${DFILT}/${NJOB}_100_${IB}_AWK_DLREGTR_TAXRETMGNT_O.dat 1000 1"
SORT_I2="${EST_DLREGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR_O.dat OVERWRITE"
#SORT_O="${EST_DLREGTAR} OVERWRITE 1000 1 "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT    36:1 - 36 :,
        FIELD_37_40 37:1 - 40 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        FIELD_42_55 42:1 - 55 :,        
        TRN_NT 56:1 - 56:,
        FIELD_57 57:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        FIELD_59_72 59:1 - 71:
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
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT             

ECHO_LOG "#===> EST_DLREGTAR..007.........: ${EST_DLREGTAR}"

NSTEP=${NJOB}_155
#LIBEL="Copy Generation du DLGTAR Final..."
	EXECKSH "cp ${DFILT}/${NJOB}_150_${IB}_SORT_DLREGTAR_O.dat  ${EST_DLREGTAR}"


JOBEND

