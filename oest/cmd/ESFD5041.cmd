#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5041.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 05\10\2022
# auteur                        : Florian CULIOLI
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Merge pericase from 5030 & 5010
#	http://aenprdxwikiu/xwiki/wiki/omega/view/DEV/DF-CLO-903328
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

PERICASE_5030=$1
PERICASE_5010=$2
PERICASE_MERGED=$3

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> PERICASE_5010..........................................................: ${PERICASE_5010}"
ECHO_LOG "#===> PERICASE_5030..........................................................: ${PERICASE_5030}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> PERICASE_MERGED........................................................: ${PERICASE_MERGED}"
ECHO_LOG "#============================================================================"


NSTEP=${NJOB}_05
# FILTER UNPAIRED RECORDS FROM PERICASE_5010 WITH PERICASE_5030
#------------------------------------------------------------------------------
LIBEL="FILTER UNPAIRED RECORDS FROM PERICASE_5010 WITH PERICASE_5030"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PERICASE_5010} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_UNPAIRED_PERICASE_5030.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF       			3:1 - 3:,
	END_NT  				4:1 - 4:,
	SEC_NF       			5:1 - 5:,
	UWY_NF       			6:1 - 6:,
	UW_NT       			7:1 - 7:,
	PERICASE				1:1 - 209:
/joinkeys 
	CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
	UW_NT
/INFILE ${PERICASE_5030} 2000 1 "~"
/joinkeys 
	CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
	UW_NT
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT 
	rightside :PERICASE
exit
EOF
SORT

NSTEP=${NJOB}_10
# Generate PERICASE_5010 + UNPAIRED_5030 file by CSUOE
#-----------------------------------------------------------------------------
LIBEL="Generate PERICASE_5010 + UNPAIRED_5030 file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PERICASE_5010} 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_UNPAIRED_PERICASE_5030.dat 2000 1"
SORT_O="${PERICASE_MERGED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						3:1 - 3:,
	END_NT						4:1 - 4:,
	SEC_NF						5:1 - 5:,
	UWY_NF						6:1 - 6:,
	UW_NT						7:1 - 7:
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
