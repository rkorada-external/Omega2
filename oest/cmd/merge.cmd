#!/bin/ksh
#=============================================================================
# nom de l'application          : Merge cashflox files
# nom du script SHELL           : merge.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 26\06\2019
# auteur                        : Antoine GRUNWALD
# references des specifications :
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT_1=$2
INPUT_2=$3
OUTPUT=$4

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT_1}.dat 1000 1"
SORT_I2="${INPUT_2}.dat 1000 1"
SORT_O="${OUTPUT}.dat 1000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
/OUTFILE ${SORT_O}

exit
EOF
SORT >> ${FLOG}