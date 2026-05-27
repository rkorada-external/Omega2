#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5045.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 05\10\2022
# auteur                        : Florian CULIOLI
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Merge IADPERIFR from 5030 & 5010
#	http://aenprdxwikiu/xwiki/wiki/omega/view/DEV/DF-CLO-916595
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

IADPERIFR_5030=$1
IADPERIFR_5010=$2
IADPERIFR_MERGED=$3

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> IADPERIFR_5010........................................................: ${IADPERIFR_5010}"
ECHO_LOG "#===> IADPERIFR_5030........................................................: ${IADPERIFR_5030}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> IADPERIFR_MERGED......................................................: ${IADPERIFR_MERGED}"
ECHO_LOG "#============================================================================"



NSTEP=${NJOB}_05
# FILTER UNPAIRED RECORDS FROM IADPERIFR_5010 WITH IADPERIFR_5030
#------------------------------------------------------------------------------
LIBEL="FILTER UNPAIRED RECORDS FROM IADPERIFR_5010 WITH IADPERIFR_5030"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${IADPERIFR_5010} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_UNPAIRED_IADPERIFR_5030.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF       			1:1 - 1:,
	END_NT  				2:1 - 2:,
	SEC_NF       			3:1 - 3:,
	UWY_NF       			4:1 - 4:,
	UW_NT       			5:1 - 5:,
	IADPERIFR				1:1 - 25:
/joinkeys 
	CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
	UW_NT
/INFILE ${IADPERIFR_5030} 2000 1 "~"
/joinkeys 
	CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
	UW_NT
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT 
	rightside :IADPERIFR
exit
EOF
SORT

NSTEP=${NJOB}_10
# Generate IADPERIFR_5010 + UNPAIRED_5030 file by CSUOE
#-----------------------------------------------------------------------------
LIBEL="Generate IADPERIFR_5010 + UNPAIRED_5030 file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${IADPERIFR_5010} 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_UNPAIRED_IADPERIFR_5030.dat 2000 1"
SORT_O="${IADPERIFR_MERGED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						1:1 - 1:,
	END_NT						2:1 - 2:,
	SEC_NF						3:1 - 3:,
	UWY_NF						4:1 - 4:,
	UW_NT						5:1 - 5:
/KEYS   CTR_NF ,
		END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT 
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_15
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
