#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5021.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04\03\2021
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Merge a retro pericase EBS with TI17CLOPER data in order to determine the perimeter depending on the norme
#
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

PERICASE=$1
PERICASE_NORMED=$2

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> PERICASE.............................................................: ${PERICASE}"
ECHO_LOG "#===> ESF_FI17CLOPER.........................................................: ${ESF_FI17CLOPER}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> PERICASE_NORMED......................................................: ${PERICASE_NORMED}"
ECHO_LOG "#============================================================================"

NSTEP=${NJOB}_05
# FILTER PERIMETER WITH TI17CLOPER
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH TI17CLOPER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PERICASE} 2000 1"
SORT_O="${PERICASE_NORMED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_NF 					1:1 - 1:,
	ESB_CF  				2:1 - 2:,
	CP_SSD_NF 				1:1 - 1:,
	CP_ACCESB_CF  			8:1 - 8:,
	IRDPERICASE				1:1 - 206:
/joinkeys 
	CP_SSD_NF ,
	CP_ACCESB_CF
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys 
	SSD_NF ,
	ESB_CF
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside: IRDPERICASE
exit
EOF
SORT


JOBEND
