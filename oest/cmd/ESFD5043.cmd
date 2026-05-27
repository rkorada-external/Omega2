#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5043.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 05\10\2022
# auteur                        : Florian CULIOLI
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Merge IADPERIFCI from 5030 & 5010
#	http://aenprdxwikiu/xwiki/wiki/omega/view/DEV/DF-CLO-916583
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

IADPERIFCI_5030=$1
IADPERIFCI_5010=$2
IADPERIFCI_MERGED=$3

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> IADPERIFCI_5010........................................................: ${IADPERIFCI_5010}"
ECHO_LOG "#===> IADPERIFCI_5030........................................................: ${IADPERIFCI_5030}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> IADPERIFCI_MERGED......................................................: ${IADPERIFCI_MERGED}"
ECHO_LOG "#============================================================================"


NSTEP=${NJOB}_05
# FILTER UNPAIRED RECORDS FROM IADPERIFCI_5010 WITH IADPERIFCI_5030
#------------------------------------------------------------------------------
LIBEL="FILTER UNPAIRED RECORDS FROM IADPERIFCI_5010 WITH IADPERIFCI_5030"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${IADPERIFCI_5010} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_UNPAIRED_IADPERIFCI_5030.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF       			1:1 - 1:,
	END_NT  				2:1 - 2:,
	SEC_NF       			3:1 - 3:,
	UWY_NF       			4:1 - 4:,
	UW_NT       			5:1 - 5:,
	IADPERIFCI				1:1 - 25:
/joinkeys 
	CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
	UW_NT
/INFILE ${IADPERIFCI_5030} 2000 1 "~"
/joinkeys 
	CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
	UW_NT
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT 
	rightside :IADPERIFCI
exit
EOF
SORT

NSTEP=${NJOB}_10
# Generate IADPERIFCI_5010 + UNPAIRED_5030 file by CSUOE
#-----------------------------------------------------------------------------
LIBEL="Generate IADPERIFCI_5010 + UNPAIRED_5030 file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${IADPERIFCI_5010} 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_UNPAIRED_IADPERIFCI_5030.dat 2000 1"
SORT_O="${IADPERIFCI_MERGED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						1:1 - 1:,
	END_NT						2:1 - 2:,
	SEC_NF						3:1 - 3:,
	UWY_NF						4:1 - 4:,
	UW_NT						5:1 - 5:,
	SEGTYP_CT					6:1 - 6:
/KEYS   CTR_NF ,
		END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
		SEGTYP_CT
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
