#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD3921.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 12\04\2021
# auteur                        : Cyril AVINENS
#-----------------------------------------------------------------------------
# description : Generate EBS Pericase for ASSUMED with IFRS Structure
#-----------------------------------------------------------------------------
# modif
# [01] 16/10/2024 DaD - Spira : 111562 : Add AEs into NDIC Cash computation
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#======================================================================"
ECHO_LOG "#===> ............ INPUT .............................................."
ECHO_LOG "#===> EST_FBOPRSLNK_TXT................................................: ${EST_FBOPRSLNK_TXT}"
ECHO_LOG "#===> ESF_DLSGTAA......................................................: ${ESF_DLSGTAA}"
ECHO_LOG "#===> ............ OUTPUT ............................................."
ECHO_LOG "#===> ESF_DLSGTAA_FILTERED.............................................: ${ESF_DLSGTAA_FILTERED}"
ECHO_LOG "#======================================================================"


NSTEP=${NJOB}_00
LIBEL="MANAGE UNFOUND FILES "

if [ ! -f ${ESF_DLSGTAA} ]
then
    ECHO_LOG "ESF_DLSGTAA=${ESF_DLSGTAA} does not exist, take an empty file"
    EXECKSH "touch ${ESF_DLSGTAA}"
fi

if [ ! -f ${EST_FBOPRSLNK_TXT} ]
then
    ECHO_LOG "EST_FBOPRSLNK_TXT=${EST_FBOPRSLNK_TXT} does not exist, take an empty file"
    EXECKSH "touch ${EST_FBOPRSLNK_TXT}"
fi


NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Filter ESF_DLSGTAA with EST_FBOPRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTAA} 2000 1"
SORT_O="${ESF_DLSGTAA_FILTERED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
    ACMTRSL3_NT     5:1 - 5:,
	TRNCOD_CF       6:1 - 6:,
    DETTRS_CF       9:1 - 9:,
    COL_1_64        1:1 - 64:
/JOINKEYS
	TRNCOD_CF
/INFILE ${EST_FBOPRSLNK_TXT} 2000 1 "~"
/JOINKEYS 
	DETTRS_CF
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside: COL_1_64, rightside: ACMTRSL3_NT
exit
EOF
SORT


NSTEP=${NJOB}_10
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND 
