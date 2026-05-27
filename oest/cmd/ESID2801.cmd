#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
# nom du script SHELL		: ESID2801.cmd
# revision			: $Revision:   1.8  $
# date de creation		: 10/1997
# auteur			: CGI (KUHNA)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description 
#   Preparation for technical balance print out
#
# job launched by ESID2800.cmd
#-----------------------------------------------------------------------------
# historiques des modifications : 
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 09/05/2011
#Version        : 11.1
#Description    : ESTDOM21408 OneLedger
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd

# Initialization of the Job
JOBINIT

# Parameters
CLODAT_D=$1
CRE_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
DBCLO_D=$5


NSTEP=${NJOB}_05
#Sort and Summarize GT = TOTGTAa(2060) + DLREJGTAa(2900)  
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#-----------------------------------------------------------------------------
LIBEL="Sort and Summarize TOTGTAA+TOTGTAR+DLREJGTAA+DLREJGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAA} 1000 1"
SORT_I2="${EST_TOTGTAR} 1000 1"
if [ "${EST_ESID2800_COND1}" = "Y" ]
then
    SORT_I3="${EST_DLREJGTAA} 1000 1"
	SORT_I4="${EST_DLREJGTAR} 1000 1"
fi  
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTA_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 20/3,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 20/3
/KEYS SSD_CF,
      ESB_CF,
      BALSHEY_NF,
      TRNCOD_CF,
      DBLTRNCOD_CF,
      CUR_CF,
      RETCUR_CF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AMT_MC    AMT_M    COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD SEP2       "~~"
/DERIVEDFIELD SEP5       "~~~~~"
/DERIVEDFIELD SEP10      "~~~~~~~~~~"
/DERIVEDFIELD SEP14      "~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          SEP2,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          SEP10,
          CUR_CF,
          AMT_MC,
          SEP14,
          RETCUR_CF,
          RETAMT_MC,
          SEP5
exit
EOF
SORT     

NSTEP=${NJOB}_10
#subject : Change to simple part and TL file conversion
#---------------------------------------------------------------
LIBEL="Change to simple part of TL file"
PRG=ESTC7601
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_GTA_O.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSIMP_O.dat
EXECPRG

NSTEP=${NJOB}_15
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_GTA_O.dat

NSTEP=${NJOB}_20
#Simple part TL file sort and accumulation before printing
#-----------------------------------------------------------------------------
LIBEL="Sort and accumulation of simple part TL before printing"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_ESTC7601_GTSIMP_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTSIMP_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        TRNCOD_CF 4:1 - 4:,
        CUR_CF 5:1 - 5:,
        AMT_M 6:1 - 6:EN 20/3,
        RETAMT_M 7: 1 - 7:EN 20/3
/KEYS SSD_CF,
      ESB_CF,
      BALSHEY_NF,
      TRNCOD_CF,
      CUR_CF
/SUMMARIZE TOTAL AMT_M,
           TOTAL RETAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_25
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTC7601_GTSIMP_O.dat  

NSTEP=${NJOB}_30
#subject : Simple TL amounts accumulation
#---------------------------------------------------------------
LIBEL="Simple TL amounts accumulation"
PRG=ESTC7602
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTSIMP_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSIMP_O.dat
EXECPRG

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTSIMP_O.dat

# WARNING : do not insert sort with transaction code  #
#              between these 2 steps                  #

NSTEP=${NJOB}_40
#subject : Putting into format before technical balance printing
#---------------------------------------------------------------
LIBEL="Putting into format before technical balance printing ..."
PRG=ESTR7630
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
CLODAT_D ${CLODAT_D}
CRE_D ${CRE_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
DBCLO_D ${DBCLO_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_ESTC7602_GTSIMP_O.dat
export ${PRG}_I2=${EST_FLIBEL2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSIMP_O.dat
EXECPRG

NSTEP=${NJOB}_45
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTC7602_GTSIMP_O.dat 

NSTEP=${NJOB}_50
#subject : Split Files by SSD
#---------------------------------------------------------------
LIBEL="Split files by SSD"
SPLIT_PREFIX=${NJOB}_40
SPLIT_PREFIX_NEW=${NCHAIN}_ESID2802
SPLIT_I=${DFILT}/${NJOB}_40_${IB}_ESTR7630_GTSIMP_O.dat
SPLIT_SSD

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_55
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
 
JOBEND
