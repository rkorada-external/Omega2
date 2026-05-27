#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Injection du Rapprochement Retro
# nom du script SHELL		: ESID8531.cmd
# revision			: $Revision:   1.5  $
# date de creation		: 02/10/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Injection of Retrocession Comparison into the Infocenter
#
# Input files
#       EST_FRAPP     DFILI
#
# Launch C program ESTC8800
#
# launched by ESID8530.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#
# 07 10 2004 J. Ribot    ajout cartes SORT_WDIR=${SORTWORK} et SORT_CMD=`CFTMP`
#                         dans le step15
#[002] 27/06/2012 Roger Cassis :spot:23802 - gzip fichiers en entree pour permettre relancement de la chaine au lieu de suppression
#[003] 12/09/2013 Florent      :spot:25427 Closing batches adaptation for centralization, maj step 35
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get Input Parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the TRETCOMP table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TRETCOMP', '${CLODAT_D}',
                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TTECLEDASNEM results is
RETCOMP=`cat ${ISQL_FRES} | sed -e s/\ //g`
TRETCOMP=T${RETCOMP}

NSTEP=${NJOB}_10
#sort with condition not requested Inventary Filiale
#---------------------------------------------------------------------------------
LIBEL="sort with condition not requested Inventary Filiale"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FRETCOMP}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FRAPP_1.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OMIT INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_15
#sort to add Frapp_1 and FRAPP_0
#---------------------------------------------------------------------------------
LIBEL="sort to add Frapp_1 and FRAPP_0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FRAPP}
SORT_I2=${DFILT}/${NJOB}_10_${IB}_SORT_FRAPP_1.dat
SORT_O=${EST_FRETCOMP}
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_FRETCOMP_OTHERS.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, ESB_CF 2:1 - 2: EN, CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:, RETCTR_NF 8:1 - 8:, RETEND_NT 9:1 - 9:, RETSEC_NF 10:1 - 10:, RTY_NF 11:1 - 11:, RETUW_NT 12:1 - 12:, RETCUR_CF 13:1 - 13:, RETNAT_CT 14:1 - 14:
/KEYS SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETCUR_CF, RETNAT_CT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O2}
/OMIT INVENTAIRE

exit
EOF
SORT

NSTEP=${NJOB}_20
# Adding an identity column to the Accetance TL
#-----------------------------------------------------------------------------
LIBEL="Adding an identity column to the Accetance TL"
PRG=ESTC8800
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TRN_NT 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_FRETCOMP}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FRAPP_O.dat
EXECPRG

NSTEP=${NJOB}_25
LIBEL="Erase temporary file"
RMFIL "${DFILT}/${NJOB}_10_{IB}_SORT_FRAPP_1.dat"

#[002]
NSTEP=${NJOB}_26
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree"
EXECKSH_MODE=P
RMFIL "${EST_FRAPP}.gz"
EXECKSH "gzip ${EST_FRAPP}"

NSTEP=${NJOB}_35
#--------------------------------
LIBEL="filling ${TRETCOMP} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_20_${IB}_ESTC8800_FRAPP_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TRETCOMP}"
BCP

NSTEP=${NJOB}_45
# Update TBOPAR
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TRETCOMP', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_50
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
