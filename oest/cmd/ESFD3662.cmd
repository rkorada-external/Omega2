#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3662.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 12\09\2019
# auteur                        : David DA SILVA TEIXEIRA
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 11.5 : Forward discount and unwind discount calculation
#
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES"

if [ ! -f ${ESF_GTSII_GLOBAL_CASHFLOW_RAD} ]
then
    ECHO_LOG "ESF_GTSII_GLOBAL_CASHFLOW_RAD=${ESF_GTSII_GLOBAL_CASHFLOW_RAD}  does not exist, take an empty file"
    EXECKSH "touch ${ESF_GTSII_GLOBAL_CASHFLOW_RAD}"
fi

if [ ! -f ${ESF_GTSII_GLOBAL_CASHFLOW_RAD_PREV} ]
then
    ECHO_LOG "ESF_GTSII_GLOBAL_CASHFLOW_RAD_PREV=${ESF_GTSII_GLOBAL_CASHFLOW_RAD_PREV}  does not exist, take an empty file"
    EXECKSH "touch ${ESF_GTSII_GLOBAL_CASHFLOW_RAD_PREV}"
fi

if [ ! -f ${ESF_GTSII_ESCOMPTE_RAD} ]
then
    ECHO_LOG "ESF_GTSII_ESCOMPTE_RAD=${ESF_GTSII_ESCOMPTE_RAD}  does not exist, take an empty file"
    EXECKSH "touch ${ESF_GTSII_ESCOMPTE_RAD}"
fi

if [ ! -f ${ESF_GTSII_ESCOMPTE_RAD_PREVCLODAT} ]
then
    ECHO_LOG "ESF_GTSII_ESCOMPTE_RAD_PREVCLODAT=${ESF_GTSII_ESCOMPTE_RAD_PREVCLODAT}  does not exist, take an empty file"
    EXECKSH "touch ${ESF_GTSII_ESCOMPTE_RAD_PREVCLODAT}"
fi

JOBEND