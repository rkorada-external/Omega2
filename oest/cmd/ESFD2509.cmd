#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 MERGE DE FICHIERS POUR GENERATION DAC IFRS17
# nom du script SHELL           : ESFD2509
# revision                      : $Revision:   1.0  $
# date de creation              : 07/04/2021
# auteur                        : MZM
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Merge des fichiers issu du ESID2210 (DCUMGTAA DAC I17) et des FICHIERS ESFD2220_DLGTAA,  
#                           et du ESFD3890 :
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[01] 14/04/2021 MZM Spira 90073
#[02] 09/06/2022 MZM spira:104058 : DAC I17 - AI TL missing ==> Bouclette 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT

# Get input parameters


ICLODAT_D=$3
TYPEINV=$4
IDF_CT=$5
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`


ICLODAT_3MOIS=`echo "$ICLODAT_D" | awk '{ y1 = substr($0,3,2); m1 = substr($0,5,2); j2 = substr($0,7,2); if (m1 > "03") {y2 = y1; m2 = m1-3;} else {y2 = y1-1; m2 = m1+9; } ; if (length(j2) < 2) j2 = "0" j2 ; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
ICLODAT_3MOIS_M=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,5,2)}'`
ICLODAT_3MOIS_A=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,1,4)}'`
ICLODAT_3MOIS_J=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,7,2)}'`



ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}  "
ECHO_LOG "#===> PATTYP_CT..................: ${PATTYP_CT}  "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D..............: $PARM_CLODAT_D"
ECHO_LOG "#===> ICLODAT_D .................: $ICLODAT_D "
ECHO_LOG "#===> PARM_INVCONSO_D ...........: $PARM_INVCONSO_D"
ECHO_LOG "#===> ICLODAT_A .................: $ICLODAT_A  "
ECHO_LOG "#===> ICLODAT_M .................: $ICLODAT_M  "
ECHO_LOG "#===> ICLODAT_J .................: $ICLODAT_J  "
ECHO_LOG "#===> ICLODAT_3MOIS .............: $ICLODAT_3MOIS  "
ECHO_LOG "#===> ICLODAT_3MOIS_A ...........: $ICLODAT_3MOIS_A  "
ECHO_LOG "#===> ICLODAT_3MOIS_M ...........: $ICLODAT_3MOIS_M  "
ECHO_LOG "#===> ICLODAT_3MOIS_J ...........: $ICLODAT_3MOIS_J  "
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#==> EST_DLCUMGTAATOT ...........:  $EST_DLCUMGTAATOT          "
ECHO_LOG "#==> EST_DLREGTAR ...............:  $EST_DLREGTAR          "
ECHO_LOG "#==> EST_DLRGTAA  ...............:  $EST_DLRGTAA           "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#==> EST_DLREGTAR_DACI17 ........:  $EST_DLREGTAR_DACI17  "
ECHO_LOG "#==> EST_DLREGTR_DACI17 .........:  $EST_DLREGTR_DACI17  "
ECHO_LOG "#==> ESF_DLRGTAA_DACI17 ..........:  $ESF_DLRGTAA_DACI17  "
ECHO_LOG "#========================================================================="



if [ ! -f ${EST_DLCUMGTAATOT} ]
then
	touch ${EST_DLCUMGTAATOT}
fi

# [002]
if [ ! -f ${EST_DLREGTAR} ]
then
	touch ${EST_DLREGTAR}
fi


if [ ! -f ${EST_DLRGTAA} ]
then
	touch ${EST_DLRGTAA}
fi

if [ ! -f ${ESF_DLEIGTAA_DACI17} ]
then
	touch ${ESF_DLEIGTAA_DACI17}
fi
 

if [ "${IDF_CT}" = "EBS_ESPD2550" ] 
then

if [ ! -f ${ESF_DLRGTAA_DACI17} ]
then
	touch ${ESF_DLRGTAA_DACI17}
fi


if [ ! -f ${ESF_DLRIGTAA_DACI17} ]
then
	touch ${ESF_DLRIGTAA_DACI17}
fi


#[001] ${EST_DLCUMGTAATOT}
NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_DLCUMGTAATOT file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLCUMGTAATOT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DAC_DLCUMGTAATOT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        TRNCOD_CF          6:1 - 6:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:
/KEYS 	CTR_NF,
      	END_NT,
      	SEC_NF,
      	UWY_NF,
      	UW_NT
/CONDITION DAC_IFRS17 (TRNCOD_CF = "1143060I")
/OUTFILE ${SORT_O}
/INCLUDE DAC_IFRS17      	
exit
EOF
SORT




NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_DLREGTAR file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLREGTAR}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DAC_DLDGTAR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        TRNCOD_CF          6:1 - 6:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:
/KEYS 	CTR_NF,
      	END_NT,
      	SEC_NF,
      	UWY_NF,
      	UW_NT
/CONDITION DAC_IFRS17 (TRNCOD_CF = "2143060I")
/OUTFILE ${SORT_O}
/INCLUDE DAC_IFRS17      	
exit
EOF
SORT



NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_DLREGTR file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLREGTR}
#SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DAC_DLDGTR_O.dat
SORT_O="${ESF_DLREGTR_DACI17} OVERWRITE" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        TRNCOD_CF          6:1 - 6:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:
/KEYS 	CTR_NF,
      	END_NT,
      	SEC_NF,
      	UWY_NF,
      	UW_NT
/CONDITION DAC_IFRS17 (TRNCOD_CF = "2143060I")
/OUTFILE ${SORT_O}
/INCLUDE DAC_IFRS17      	
exit
EOF
SORT



NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_DLDGTAA file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLDGTAA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DAC_DLDGTAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        TRNCOD_CF          6:1 - 6:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:
/KEYS 	CTR_NF,
      	END_NT,
      	SEC_NF,
      	UWY_NF,
      	UW_NT
/CONDITION DAC_IFRS17 (TRNCOD_CF = "1143060I")
/OUTFILE ${SORT_O}
/INCLUDE DAC_IFRS17      	
exit
EOF
SORT


# [01] Merge des Fichiers DAC IFRS17  et EST_DLDGTAA


NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="AGREGATES DAC_IFRS17 AND  EST_DLDGTAA Merge and sort files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_DAC_DLCUMGTAATOT_O.dat 1000 1" 
SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_DAC_DLDGTAR_O.dat 1000 1" 
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DACI17_DLDGTAR.dat 1000 1" 
SORT_O="${ESF_DLREGTAR_DACI17} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
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
        SCOENDMTH_NF     16:1 - 16:EN              
/KEYS   				
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT             
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLEIGTAA} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLEIGTAA.dat 1000 1" 
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLEIGTAA_DACI17.dat 1000 1" 
#SORT_O="${EST_DLEIGTAA} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
/OUTFILE ${SORT_O2}
/OMIT NO_DAC_IFRS17
exit
EOF
SORT 


NSTEP=${NJOB}_82
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort EST_DLDVGTR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLDVGTR} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDVGTR.dat 1000 1" 
#SORT_O="${EST_DLDVGTR} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
exit
EOF
SORT 


NSTEP=${NJOB}_84
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort EST_DLREGTR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLREGTR} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR.dat 1000 1" 
#SORT_O="${EST_DLREGTR} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
exit
EOF
SORT


## [002]

NSTEP=${NJOB}_86
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort EST_DLRGTAA files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLRGTAA} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLRGTAA.dat 1000 1" 
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLRGTAA_DACI17.dat 1000 1" 
#[002]SORT_O2="${ESF_DLRGTAA_DACI17} OVERWRITE"
#SORT_O="${EST_DLRGTAA} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
/OUTFILE ${SORT_O2}
/OMIT NO_DAC_IFRS17
exit
EOF
SORT



NSTEP=${NJOB}_88
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort EST_DLREGTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLREGTAR} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR.dat 1000 1" 
#SORT_O="${EST_DLREGTAR} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
exit
EOF
SORT





NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort EST_DLRIGTAA files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLRIGTAA} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLRIGTAA.dat 1000 1" 
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLRIGTAA_DACI17.dat 1000 1" 
#SORT_O="${EST_DLRIGTAA} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
/OUTFILE ${SORT_O2}
/OMIT NO_DAC_IFRS17
exit
EOF
SORT




NSTEP=${NJOB}_94
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort EST_DLREMAJGTR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLREMAJGTR} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREMAJGTR.dat 1000 1" 
#SORT_O="${EST_DLREMAJGTR} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
exit
EOF
SORT



NSTEP=${NJOB}_96
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort EST_DLREMAJGTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLREMAJGTAR} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREMAJGTAR.dat 1000 1" 
#SORT_O="${EST_DLREMAJGTAR} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
exit
EOF
SORT


NSTEP=${NJOB}_98
#-----------------------------------------------------------------------------
LIBEL="FILTER  and sort EST_DLDGTAA files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I=" ${EST_DLDGTAA} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat 1000 1" 
#SORT_O="${EST_DLDGTAA} OVERWRITE"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/CONDITION NO_DAC_IFRS17 ( (TRNCOD_CF != "1143060I") AND (TRNCOD_CF != "2143060I") )
/OUTFILE ${SORT_O}
/INCLUDE NO_DAC_IFRS17
exit
EOF
SORT


     

NSTEP=${NJOB}_100
#LIBEL="Copy De la Fusion --> DLREGTAR et DLREGTR..."
	EXECKSH "cp ${DFILT}/${NJOB}_80_${IB}_SORT_DLEIGTAA_DACI17.dat  ${ESF_DLEIGTAA_DACI17}"
	EXECKSH "cp ${DFILT}/${NJOB}_82_${IB}_SORT_DLDVGTR.dat  ${EST_DLDVGTR}"
	EXECKSH "cp ${DFILT}/${NJOB}_84_${IB}_SORT_DLREGTR.dat  ${EST_DLREGTR}"
	EXECKSH "cp ${DFILT}/${NJOB}_86_${IB}_SORT_DLRGTAA_DACI17.dat  ${ESF_DLRGTAA_DACI17}"
	EXECKSH "cp ${DFILT}/${NJOB}_88_${IB}_SORT_DLREGTAR.dat  ${EST_DLREGTAR}"		
	EXECKSH "cp ${DFILT}/${NJOB}_90_${IB}_SORT_DLRIGTAA_DACI17.dat  ${ESF_DLRIGTAA_DACI17}"	
	EXECKSH "cp ${DFILT}/${NJOB}_94_${IB}_SORT_DLREMAJGTR.dat  ${EST_DLREMAJGTR}"	
	EXECKSH "cp ${DFILT}/${NJOB}_96_${IB}_SORT_DLREMAJGTAR.dat  ${EST_DLREMAJGTAR}"	
	EXECKSH "cp ${DFILT}/${NJOB}_98_${IB}_SORT_DLDGTAA.dat  ${EST_DLDGTAA}"							


fi



JOBEND

