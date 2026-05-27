#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD8030.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28\01\2022
# auteur                        : Arnaud RUFFAULT
#---------------------------------------------------------------------------------
# description
#  Copy to all sections (valid or not) the info IFRS 17  on rate index, first closing date and profitability once at least a section of the treaty or facultative is initialised
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}



# Extracting the number of days to substract on the pos booking date
set `GETPRM ${DPRM}/ESFD5000.prm`
export X_DAYS=$1

ECHO_LOG "#===> GREP ON...............................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> GREP IN...............................................................: ${DPRM}/ESFD5000.prm"

export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESFD5000.prm | cut -d' ' -f 2` 

if [ -z "$QUARTER_END_FOUND" -o "$QUARTER_END_FOUND" -eq "${PARM_ICLODAT_D}" ];
then
	export QUARTER_END_FOUND=NONE
fi

if [ -z "$PARM_IS_TRN" ]
then
 export PARM_IS_TRN=NO
fi



ECHO_LOG "#===> QUARTER_END_FOUND.....................................................: ${QUARTER_END_FOUND}"

# Launch applicative job ESFD8031
NJOB="ESFD8031${TYPEINV}"
${DCMD}/ESFD8031.cmd | ${TEE}

CHAINEND