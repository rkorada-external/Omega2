#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - SEGMENTATION
#                                 Creation des perimetres segmentation 
# nom du script SHELL		: ESCD0001.cmd
# revision			: $Revision:   1.29  $
# date de creation		: 29/05/1997
# auteur			: CGI
# references des specifications	: ESTSEG01.DOC
#-----------------------------------------------------------------------------
# description
#   New Segmentation or Period Closing Perimeter. 
#   The passage of the OPTION Parameter allows to differentiate 
#   the segmentation perimeter (OPTION=S) from the period closing 
#   perimeter (OPTION=I).
#   The Period Closing Perimeter may have one or several subsidairies,
#   the BTRAV..TESTEST Table (SSD_CF=00) contains the list of subsidairies.
#   The Segmentation Perimeter has always one Subsidiary, SSD_CF contains
#   the requested subsidiary.
#   
# job launched by ESID0060.cmd (period closing) or in night batch after a PB
# request (estimation)
#-----------------------------------------------------------------------------
# historiques des modifications
#	09/09/1998 - M.HA-THUC : l'ancien job commun de generation des 
# perimetres a ete eclate en 3 jobs
#
# 	ESCD0001 -> devient le job de generation des perimetres de segmentation.
# Il est lance par la chaine ESEJ0000.
#
# 	ESEH1101 -> devient un job hebdomadaire ou de l'inventaire et genere
# les perimetres IADPERICASE0, IAVPERICASE0 et IADPERIFCT0. 
# Il est lance par la chaine ESEH1100.
#
# 	ESID0001 -> devient un job de l'inventaire et genere les perimetres
# annexes. 
# Il est lance par la chaine ESID0060.
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT
# Parameters
USR_CF=$1
SEGTYP_CT=$2
SSD_CF=$3
CRE_D=$4
OPTION=$5


#Identification of the permanent files
if [ "${OPTION}" = "S" ] 
then
. ${DCMD}/ESCD9001.cmd  $SSD_CF $SSD_CF 0 0 $CRE_D
fi

###################
# Tables Download #
###################

NSTEP=${NJOB}_05
#Download to the file, the fields necessary to the Treaties perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties perimeter... for Subsidiary = ${SSD_CF}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASETRT_O.dat
BCP_QRY="execute BEST..PsPERITRT_04 '${SEGTYP_CT}', ${SSD_CF}"
BCP               

NSTEP=${NJOB}_10
#Download to the file, the fields necessary to the FACS perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Facs Perimeter... for Subsidiary = ${SSD_CF}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASEFAC_O.dat
BCP_QRY="execute BEST..PsPERIFAC_04 '${SEGTYP_CT}', ${SSD_CF}"
BCP               

# Processing for Treaties Perimeter #
#####################################

NSTEP=${NJOB}_15
#Treaties Perimeter File Sort by Contract/Endorsement/UW Year 
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Sort of Treaties perimeter file... for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_PERICASETRT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASETRT_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, UWY_NF, UW_NT, SEC_NF
exit
EOF
SORT

NSTEP=${NJOB}_20
#Temporary file deletion
LIBEL="PERICASETRT temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_BCP_PERICASETRT_O.dat

NSTEP=${NJOB}_25
#Download to the file of charges reiterated and used for the CTBCOM_B
#Field Calculation for treaties.
#-----------------------------------------------------------------------------
LIBEL="Current Generation of reiterated Charges file...  for Subsidiary = ${SSD_CF}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FAMCHG2_O.dat
BCP_QRY="execute BEST..PsSECTION_09 ${SSD_CF}, '${CRE_D}'"
BCP               

NSTEP=${NJOB}_30
#Sort of reiterated charges file by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Reiterated charges file Sort...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_25_${IB}_BCP_FAMCHG2_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FAMCHG2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:, CHGLIN_NT 6:1 - 6:
/KEYS CTR_NF, END_NT, UWY_NF, UW_NT, SEC_NF, CHGLIN_NT
exit
EOF
SORT

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="FAMCHG2 temporary file deletion"
RMFIL ${DFILT}/${NJOB}_25_${IB}_BCP_FAMCHG2_O.dat
                                                               
NSTEP=${NJOB}_40
#Field CTBCOM_B first part Calculation for Treaties Perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Calculation of field CTBCOM_B 1/2 of Treaties perimeter...  for Subsidiary = ${SSD_CF}"
PRG=ESTC0104
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_PERICASETRT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_FAMCHG2_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASETRT_O.dat
EXECPRG

NSTEP=${NJOB}_45
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_PERICASETRT_O.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_FAMCHG2_O.dat

NSTEP=${NJOB}_50
#Treaties Perimeter File Sort by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Treaties perimeter file sort...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC0104_PERICASETRT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASETRT_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, UWY_NF, UW_NT, SEC_NF DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_55
#Temporary file deletion
LIBEL="PERICASETRT temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC0104_PERICASETRT_O.dat

NSTEP=${NJOB}_60
#Field CTRCOM_B second part calculation for Treaties Perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Calculation of field CTBCOM_B 2/2 of Treaties Perimeter...  for Subsidiary = ${SSD_CF}"
PRG=ESTC0102
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_PERICASETRT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASETRT_O.dat
EXECPRG

NSTEP=${NJOB}_65
#Temporary file deletion
LIBEL="PERICASETRT temporary file deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_PERICASETRT_O.dat 

NSTEP=${NJOB}_110
#Merge and Sort of perimeter files by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC0102_PERICASETRT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_BCP_PERICASEFAC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_115
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_60_${IB}_ESTC0102_PERICASETRT_O.dat

NSTEP=${NJOB}_120
#Download to the XADPERIFR Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFR Perimeter File...  for Subsidiary = ${SSD_CF}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFR_O.dat
BCP_QRY="execute BEST..PsSECTION_03 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
BCP               

NSTEP=${NJOB}_125
#Download to the XADPERIFCI Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCI Perimeter File...  for Subsidiary = ${SSD_CF}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFCI_O.dat
BCP_QRY="execute BEST..PsSECTION_04 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
BCP               

NSTEP=${NJOB}_130
#Download to the XADPERIFCT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCT perimeter File...  for Subsidiary = ${SSD_CF}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFCT_O.dat
BCP_QRY="execute BEST..PsSECTION_05 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
BCP               

NSTEP=${NJOB}_135
#Download to the XADPERIPRMD Perimeter File 
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIPRMD Perimeter File...  for Subsidiary = ${SSD_CF}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIPRMD_O.dat
BCP_QRY="execute BEST..PsSECTION_22 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
BCP

NSTEP=${NJOB}_140
#Perimeter Fields Update
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters Fields Update...  for Subsidiary = ${SSD_CF}"
PRG=ESTC0108
export ${PRG}_I1=${DFILT}/${NJOB}_110_${IB}_SORT_PERICASE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASE_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICAS_O.dat
EXECPRG

NSTEP=${NJOB}_145
#-----------------------------------------------------------------------------
LIBEL="Filter of SADPERICASE0 Perimeter file for subsidiary...  for Subsidiary = ${SSD_CF}" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SADPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:EN, SEGTYP_CT 2: 1 - 2:
/COPY
/CONDITION FILIALE SSD_CF EQ ${SSD_CF} and SEGTYP_CT EQ "${SEGTYP_CT}"
/OMIT FILIALE
exit
EOF
SORT  

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="Merge of SADPERICASE0 Perimeter file...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_145_${IB}_SORT_PERICASE_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_140_${IB}_ESTC0108_PERICASE_O.dat 1000 1"
SORT_O="${EST_SADPERICASE0} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_155
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_145_${IB}_SORT_PERICASE_O.dat

NSTEP=${NJOB}_160
#-----------------------------------------------------------------------------
LIBEL="Filter of SADPERICAS0 Perimeter file for subsidiary...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SADPERICAS0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICAS_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 25:1 - 25:EN, SEGTYP_CT 23:1 - 23:
/COPY
/CONDITION FILIALE SSD_CF EQ ${SSD_CF} and SEGTYP_CT EQ "${SEGTYP_CT}"
/OMIT FILIALE
exit
EOF
SORT 

NSTEP=${NJOB}_165
#-----------------------------------------------------------------------------
LIBEL="Merge of SADPERICAS0 Perimeter file...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_160_${IB}_SORT_PERICAS_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_140_${IB}_ESTC0108_PERICAS_O.dat 1000 1"
SORT_O="${EST_SADPERICAS0} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:
/KEYS CTR_NF, END_NT, SEC_NF
exit
EOF
SORT

NSTEP=${NJOB}_170
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_PERICAS_O.dat

NSTEP=${NJOB}_175
#-----------------------------------------------------------------------------
LIBEL="Filter of SADPERIFR0 Perimeter file for subsidiary...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SADPERIFR0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERIFR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 12:1 - 12:EN, SEGTYP_CT 11:1 - 11:
/COPY
/CONDITION FILIALE SSD_CF EQ ${SSD_CF} and SEGTYP_CT EQ "${SEGTYP_CT}"
/OMIT FILIALE
exit
EOF
SORT  

NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
LIBEL="Merge of SADPERIFR0 Perimeter File...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_175_${IB}_SORT_PERIFR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_120_${IB}_BCP_PERIFR_O.dat 1000 1"
SORT_O="${EST_SADPERIFR0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_185
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_175_${IB}_SORT_PERIFR_O.dat

NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
LIBEL="Filter of SADPERIFCI0 Perimeter file for subsidiary...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SADPERIFCI0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERIFCI_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 14:1 - 14:EN, SEGTYP_CT 13:1 - 13:
/COPY
/CONDITION FILIALE SSD_CF EQ ${SSD_CF} and SEGTYP_CT EQ "${SEGTYP_CT}"
/OMIT FILIALE
exit
EOF
SORT

NSTEP=${NJOB}_195
#-----------------------------------------------------------------------------
LIBEL="Merge of XADPERIFCI0 Perimeter File...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_SORT_PERIFCI_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_125_${IB}_BCP_PERIFCI_O.dat 1000 1"
SORT_O="${EST_SADPERIFCI0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="Filter of SADPERIFCT0 Perimeter file for subsidiary...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SADPERIFCT0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERIFCT_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 7:1 - 7:EN, SEGTYP_CT 6:1 - 6:
/COPY
/CONDITION FILIALE SSD_CF EQ ${SSD_CF} and SEGTYP_CT EQ "${SEGTYP_CT}"
/OMIT FILIALE
exit
EOF
SORT  

NSTEP=${NJOB}_205
#-----------------------------------------------------------------------------
LIBEL="Merge of SADPERIFCT0 Perimeter File...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_SORT_PERIFCT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_130_${IB}_BCP_PERIFCT_O.dat 1000 1"
SORT_O="${EST_SADPERIFCT0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_210
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_200_${IB}_SORT_PERIFCT_O.dat

NSTEP=${NJOB}_215
#-----------------------------------------------------------------------------
LIBEL="Filter of SADPERIPRMD0 Perimeter file for subsidiary...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SADPERIPRMD0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERIPRMD_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 11:1 - 11:EN, SEGTYP_CT 10:1 - 10:
/COPY
/CONDITION FILIALE SSD_CF EQ ${SSD_CF} and SEGTYP_CT EQ "${SEGTYP_CT}"
/OMIT FILIALE
exit
EOF
SORT  

NSTEP=${NJOB}_220
#-----------------------------------------------------------------------------
LIBEL="Merge of SADPERIPRMD0 Perimeter File...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_215_${IB}_SORT_PERIPRMD_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_135_${IB}_BCP_PERIPRMD_O.dat 1000 1"
SORT_O="${EST_SADPERIPRMD0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_225
#Temporary files deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_215_${IB}_SORT_PERIPRMD_O.dat

NSTEP=${NJOB}_230
#Portfolio File Generation with SADPERICAS File
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Portfolio File Generation  for Subsidiary = ${SSD_CF}"
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_ESTC0108_PERICAS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICAS_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, CED_NF 5:1 - 5:, CTRNAT_CF 7:1 - 7:, CTRRET_B 8:1 - 8:, DIV_NT 9:1 - 9:, EXP_D 12:1 - 12:, INC_D 13:1 - 13:, LOB_CF 15:1 - 15:, NAT_CF 16:1 - 16:, PCPRSKTRY_CF 19:1 - 19:, SEGTYP_CT 23:1 - 23:, SOB_CF 24:1 - 24:, SSD_CF 25:1 - 25:, SUBNAT_CF 26:1 - 26:, TOP_CF 27:1 - 27:, UWGRP_CF 28:1 - 28:
/COPY
/REFORMAT CTR_NF, END_NT, SEC_NF, CED_NF, CTRNAT_CF, CTRRET_B, DIV_NT, EXP_D, INC_D, LOB_CF, NAT_CF, PCPRSKTRY_CF, SEGTYP_CT, SOB_CF, SSD_CF, SUBNAT_CF, TOP_CF, UWGRP_CF
exit
EOF
SORT

NSTEP=${NJOB}_235
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_140_${IB}_ESTC0108_PERICAS_O.dat

NSTEP=${NJOB}_240
#Deletion of Temporary Table
#-----------------------------------------------------------------------------
LIBEL="Deletion of Current Temporary Table...  for Subsidiary = ${SSD_CF}"
ISQL_QRY="truncate table BTRAV..ESTPERIRED"
ISQL_BASE='BTRAV'
ISQL

NSTEP=${NJOB}_245
#Data Base Loading of Portfolio File
#-----------------------------------------------------------------------------
LIBEL="Current Data Base Loading of Portfolio File...  for Subsidiary = ${SSD_CF}"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_230_${IB}_SORT_PERICAS_O.dat
BCP_TABLE="BTRAV..ESTPERIRED"
BCP               

NSTEP=${NJOB}_250
# Filling of portfolio Table
#-----------------------------------------------------------------------------
LIBEL="Current Filling of portfolio Table...  for Subsidiary = ${SSD_CF}"
ISQL_QRY="execute BEST..PsSECTION_34 '${SEGTYP_CT}', ${SSD_CF}"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_255
#-----------------------------------------------------------------------------
LIBEL="delete $SSD_CF, $SEGTYP_CT rows of EST_FINFOSEGPOR ...  for Subsidiary = ${SSD_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FINFOSEGPOR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FINFOSEGPOR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS  SEGTYP_CT 4:1 - 4:, SSD_CF 5:1 - 5:EN  
/COPY
/CONDITION FILIALE SSD_CF EQ $SSD_CF and SEGTYP_CT EQ "$SEGTYP_CT"
/OMIT FILIALE
exit
EOF
SORT

NSTEP=${NJOB}_260
#Reformat of Portfolio File before the merge with EST_FINFOSEGPOR
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Reformat of Portfolio File  for Subsidiary = ${SSD_CF}"
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_230_${IB}_SORT_PERICAS_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FINFOSEGPOR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, SEGTYP_CT 13:1 - 13:, SSD_CF 15:1 - 15:, CTRRET_B 6:1 - 6:, CTRNAT_CT 5:1 - 5:
/COPY
/REFORMAT CTR_NF, END_NT, SEC_NF, SEGTYP_CT, SSD_CF, CTRNAT_CT, CTRRET_B
exit
EOF
SORT   

NSTEP=${NJOB}_265
#Generation of FSEGPOR Portfolio File
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Current Generation of FSEGPOR Portfolio File...  for Subsidiary = ${SSD_CF}"
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_260_${IB}_SORT_FINFOSEGPOR_O.dat
SORT_I2=${DFILT}/${NJOB}_255_${IB}_SORT_FINFOSEGPOR_O.dat
SORT_O="${EST_FINFOSEGPOR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT   

NSTEP=${NJOB}_270
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_230_${IB}_SORT_PERICAS_O.dat 
RMFIL ${DFILT}/${NJOB}_255_${IB}_SORT_FINFOSEGPOR_O.dat

NSTEP=${NJOB}_275
#Segmentation Table Update
#-----------------------------------------------------------------------------
LIBEL="Current Segmentation Table Update...  for Subsidiary = ${SSD_CF}"
ISQL_QRY="exec BEST..PsSECTION_35 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_280
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_285
# Delete of BSAR..TSEGPOR
#-----------------------------------------------------------------------------
LIBEL="Delete of BSAR..TSEGPOR table  for Subsidiary = ${SSD_CF}"
ISQL_QRY="delete BSAR..TSEGPOR where SSD_CF = ${SSD_CF} and SEGTYP_CT = '${SEGTYP_CT}'"
ISQL_BASE="BSAR"
ISQL

NSTEP=${NJOB}_290
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Copy of EST_FINFOSEGPOR file into BSAR..TSEGPOR  for Subsidiary = ${SSD_CF}"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_260_${IB}_SORT_FINFOSEGPOR_O.dat
BCP_TABLE="BSAR..TSEGPOR"
BCP 

NSTEP=${NJOB}_295
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
