#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Creation des perimetres annexes pour  
#                                 l'inventaire
# nom du script SHELL		: ESID0001.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 09/09/1998
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
#       09/09/1998 - M.HA-THUC : l'ancien job commun de generation des
# perimetres a ete eclate en 3 jobs
#
#       ESCD0001 -> devient le job de generation des perimetres de segmentation.
# Il est lance par la chaine ESEJ0000.
#
#       ESEH1101 -> devient un job hebdomadaire ou de l'inventaire et genere
# les perimetres IADPERICASE0, IAVPERICASE0 et IADPERIFCT0.
# Il est lance par la chaine ESEH1100.
#
#       ESID0001 -> devient un job de l'inventaire et genere les perimetres
# annexes.
# Il est lance par la chaine ESID0060.
#
#===============================================================================
#[001] 15/05/2025 JYP : Spira 111673 : bugfix Spira 111062 I17 - No retro link for LC assumed cession on onerous Q+1




# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT
# Parameters
SEGTYP_CT=$1
CRE_D=$2

# SSD_CF=00, used for all subsidiaries
SSD_CF=00


###################
# Tables Download #
###################

NSTEP=${NJOB}_05
#Download to the XADPERIFR Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFR Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFR_O.dat
BCP_QRY="execute BEST..PsSECTION_03 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
BCP               

NSTEP=${NJOB}_10
#Download to the XADPERIFCI Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCI Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFCI_O.dat
BCP_QRY="execute BEST..PsSECTION_04 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
BCP                             

NSTEP=${NJOB}_15
#Download to the XADPERIPRMD Perimeter File 
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIPRMD Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIPRMD_O.dat
BCP_QRY="execute BEST..PsSECTION_22 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
BCP

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Current Sort of XADPERIPRMD Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_BCP_PERIPRMD_O.dat 1000 1"
SORT_O="${EST_IADPERIPRMD0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_25
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_BCP_PERIPRMD_O.dat

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Current Sort of XADPERIFR Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_PERIFR_O.dat 1000 1"
SORT_O="${EST_IADPERIFR0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_BCP_PERIFR_O.dat

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Current Sort of XADPERIFCI Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_BCP_PERIFCI_O.dat 1000 1"
SORT_O="${EST_IADPERIFCI0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_45
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_BCP_PERIFCI_O.dat 

NSTEP=${NJOB}_50
#Generation of IRDPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRDPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_08 '${SEGTYP_CT}', ${SSD_CF} , '${PARM_I4I_ICLODAT_D}' "
BCP               

NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="Current Sort of IRDPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_O="${EST_IRDPERICASE0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_60
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_BCP_PERICASE_O.dat

NSTEP=${NJOB}_65
#Generation of IRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_21 '${SEGTYP_CT}', ${SSD_CF}"
BCP               

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Current Sort of IRVPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_65_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_O="${EST_IRVPERICASE0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_75
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_65_${IB}_BCP_PERICASE_O.dat

#-----------------------------------------------------------------------------
# Perimeter for non selected contracts
#-----------------------------------------------------------------------------

# Tables Download

NSTEP=${NJOB}_80
#Constituting treaty perimeter file with BTRT database fields
#In case of subsidary 00, all the subsidaries are taken into account
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASETRT_O.dat
BCP_QRY="execute BEST..PsPERITRT_03 '${SEGTYP_CT}'"
BCP               

NSTEP=${NJOB}_85
#Download to the file, the fields necessary to the 
#facultatives perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Facs Perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASEFAC_O.dat
BCP_QRY="execute BEST..PsPERIFAC_03 '${SEGTYP_CT}'"
BCP               

NSTEP=${NJOB}_90
#Merge and Sort of perimeter files by Contract/Endorsement/Section/UW Year
# and UW Year sequence number
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_BCP_PERICASETRT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_85_${IB}_BCP_PERICASEFAC_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:, UWORG_CF 119:1 - 119:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION  CTR_NOT_DUMMY UWORG_CF != "248"
/OUTFILE  ${SORT_O}
/INCLUDE CTR_NOT_DUMMY
exit
EOF
SORT

NSTEP=${NJOB}_95
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_80_${IB}_BCP_PERICASETRT_O.dat
RMFIL ${DFILT}/${NJOB}_85_${IB}_BCP_PERICASEFAC_O.dat

NSTEP=${NJOB}_100
#Perimeter Fields Update
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters Fields Update..."
PRG=ESTC0103
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${EST_OADPERICASE0}
export ${PRG}_O2=${EST_OAVPERICASE0}
EXECPRG

NSTEP=${NJOB}_105
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_PERICASE_O.dat

NSTEP=${NJOB}_110
#Generation of ORDPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRDPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_46 '${SEGTYP_CT}'"
BCP               

NSTEP=${NJOB}_115
#-----------------------------------------------------------------------------
LIBEL="Current Sort of ORDPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_O="${EST_ORDPERICASE0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_120
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_110_${IB}_BCP_PERICASE_O.dat


NSTEP=${NJOB}_125
#Generation of IRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of ORVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_47 '${SEGTYP_CT}'"
BCP               

NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="Current Sort of ORVPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_O="${EST_ORVPERICASE0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT  

NSTEP=${NJOB}_135
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
