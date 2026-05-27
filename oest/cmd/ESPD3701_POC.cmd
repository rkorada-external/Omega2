#!/bin/ksh
#==============================================================================
#nom de l'application          : IFRS POC Batch
#nom du source                 : ESPD3701_POC.cmd
#date de creation              : 18/09/2018
#auteur                        : Parth
#references des specifications :
#------------------------------------------------------------------------------
#description :
#==============================================================================

. ${DUTI}/fctgen.cmd

CHAININIT $0 $1

# Get input parameters
set `GETPRM ${DPRM}/ESPD3701_POC.prm`
IDATE=$1

echo ${IDATE}

NJOB="ESPD3703_POC"
${DCMD}/ESPD3703_POC.cmd ${IDATE} 2>&1 | ${TEE}

CHAINEND
