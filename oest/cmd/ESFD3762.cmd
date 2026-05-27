#!/bin/ksh
#=============================================================================
# nom de l'application          : INI
# nom du script SHELL           : ESFD3762.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 11/07/2022
# auteur                        : Bhimasen Karri
#-----------------------------------------------------------------------------
# description : Generate STD+INI Pericase for ASSUMED with IFRS Structure
#-----------------------------------------------------------------------------
# modif
# [001]   13/07/2022  MZM Spira #104925 Onerous Q+1- Missing LC data at closing Fix Issu On ITK
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

#[001] 1000 ==> 2000

NSTEP=${NJOB}_05
# FILTER UNPAIRED RECORDS FROM IADPERICASE_INI WITH IADPERICASE_STD
#------------------------------------------------------------------------------
LIBEL="FILTER UNPAIRED RECORDS FROM IADPERICASE_INI WITH IADPERICASE_STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EST_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF_F1       3:1 -  3:, 
    END_NT_F1       4:1 -  4:, 
    SEC_NF_F1       5:1 -  5:, 
	UWY_NF_F1       6:1 -  6:, 
    UW_NT_F1        7:1 -  7:,
	CTR_NF_F2       3:1 -  3:, 
    END_NT_F2       4:1 -  4:, 
    SEC_NF_F2       5:1 -  5:, 
	UWY_NF_F2       6:1 -  6:, 
    UW_NT_F2        7:1 -  7:,
	IADPERICASE		1:1 - 252:
/joinkeys 
	CTR_NF_F1,
	END_NT_F1,
	SEC_NF_F1,
	UWY_NF_F1,
	UW_NT_F1
/INFILE ${EST_IADPERICASE_INI} 2000 1 "~"
/joinkeys 
	CTR_NF_F2,
	END_NT_F2,
	SEC_NF_F2,
	UWY_NF_F2,
	UW_NT_F2
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT 
	rightside :IADPERICASE
exit
EOF
SORT

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Generate pericase STD+INI file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD} 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_SORT_EST_IADPERICASE.dat 2000 1"
SORT_O="${EST_IADPERICASE_MERGE} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						3:1 - 3:,
	END_NT						4:1 - 4:,
	SEC_NF						5:1 - 5:,
	UWY_NF						6:1 - 6:,
	UW_NT						7:1 - 7:
/KEYS   CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
		END_NT
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
