#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE 
#                                 Preparation de l'edition rapprochement
#                                 retrocession
# nom du script SHELL		: ESID2532.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 01/10/97
# auteur			: C.G.I. (KUHNA)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#  Preparation of matching report print out
#  Accounting and theoretical results matching report
#
# job lance par ESID2530.cmd 
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd


# Job Initialisation
JOBINIT

# Parameters
CLODAT_D=$1
CRE_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
DBCLO_D=$5


NSTEP=${NJOB}_05
# Sort of matching report file
#-----------------------------------------------------------------------------
LIBEL="Sort of matching report in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FRAPP} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FRAPP_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        RETNAT_CF 14:1 - 14:,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        RETCTR_NF 8:1 - 8:,
        RETEND_NT 9:1 - 9:,
        RETSEC_NF 10:1 - 10:,
        RTY_NF 11:1 - 11:,
        RETUW_NT 12:1 - 12:,
        RETCUR_CF 13:1 - 13:
/KEYS SSD_CF, ESB_CF, RETNAT_CF DESCENDING, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETSEC_NF, RTY_NF, RETUW_NT, RETCUR_CF
/CONDITION NONSCORVIE SSD_CF ne "4"
/INCLUDE NONSCORVIE
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Preparation of matching report file for print out"
PRG=ESTC2314
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_FRAPP_O.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FRAPP_O.dat
EXECPRG   


NSTEP=${NJOB}_15
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_FRAPP_O.dat


NSTEP=${NJOB}_20
# Sort of matching report outfile
#-----------------------------------------------------------------------------
LIBEL="Sort of matching report file before print out in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC2314_FRAPP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FRAPP_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        RETNAT_CF 14:1 - 14:,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        RETCTR_NF 8:1 - 8:,
        RETEND_NT 9:1 - 9:,
        RETSEC_NF 10:1 - 10:, 
        RTY_NF 11:1 - 11:,
        RETUW_NT 12:1 - 12:,
        RETCUR_CF 13:1 - 13:
/KEYS SSD_CF, ESB_CF, RETNAT_CF DESCENDING, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETSEC_NF, RTY_NF, RETUW_NT, RETCUR_CF
exit
EOF
SORT


NSTEP=${NJOB}_25
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTC2314_FRAPP_O.dat


NSTEP=${NJOB}_30
# subject : Formatting data
#---------------------------------------------------------------
PRG=ESTR2301
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
CRE_D ${CRE_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
DBCLO_D ${DBCLO_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_FRAPP_O.dat
export ${PRG}_I2=${EST_FLIBEL2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_O.dat
EXECPRG


NSTEP=${NJOB}_35
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_FRAPP_O.dat


NSTEP=${NJOB}_40
#subject : Split Files by SSD
#---------------------------------------------------------------
LIBEL="Split files by SSD"
SPLIT_PREFIX=${NJOB}_30
SPLIT_PREFIX_NEW=${NCHAIN}_ESID2533
SPLIT_I=${DFILT}/${NJOB}_30_${IB}_ESTR2301_O.dat
SPLIT_SSD

NSTEP=${NJOB}_45
# Delete of temporary files
#---------------------------------------------------------------
LIBEL="Delete of temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*.dat"


JOBEND
